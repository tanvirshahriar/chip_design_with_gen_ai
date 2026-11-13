# Hardware Trojan Generation with LLM HW

**Attack class:** Information leakage — the embedded key is exfiltrated over MISO under a hidden trigger
**AI model:** `nvidia/nemotron-3.5-super-vl-120b-a12b`

---

## TL;DR

- Reverse-engineered the cipher and recovered the embedded key **from the bitstream alone** (bonus).
- Built a **one-click** notebook pipeline where the LLM writes the Trojan, the exploit testbench, and an activation recipe — no hardware written by a human.
- The Trojan is **stealthy**: every non-trigger input is bit-identical to the clean design. Under the AI-chosen trigger, the 32-bit key is shifted out on MISO.
- Every model call is logged under `ai/logs/`. An independent oracle verifies the leak so the result does not rest on the attacker's own testbench.

## Repository layout

```
README.md                  this technical brief
trojangen_hw.ipynb         the one-click pipeline (reverse-engineered model -> Trojan -> exploit -> verify)
rtl/
  les_crypto_clean.v       clean RTL recovered from the bitstream (golden reference)
  les_crypto_trojan.v      AI-generated Trojaned module
tb/
  exploit_tb.v             AI-generated exploit testbench (proves normal op + trigger, dumps exploit.vcd)
  activation_recipe.json   AI-declared steps to fire the trigger
  exploit.vcd              waveform from the exploit run
ai/
  logs/                    every LLM prompt + response (required; do not delete)
docs/
  recovered_cipher.md      full cipher recovery write-up
  sbox_enc_Sinv.hex        recovered S-box (encryption substitution)
  sbox_dec_Sfwd.hex        its inverse (decryption substitution)
```

---

## 1. Bitstream reverse engineering

Everything below came from the shipped bitstream only, cross-checked against the single known-answer pair the challenge provides (`0x59C359C3` encrypts to `0x9CD84392`).

- Unpacked the bitstream with **Project IceStorm** (`iceunpack`), then recovered a gate-level netlist with `icebox_vlog`.
- Identified the **raw SPI peripheral** and sideband from the interface doc: `SCK, RST_N, MOSI, MISO, NORM_CS_N, START, ENC_DEC, BUSY, ICE_LED`. One unified clock domain — `SCK` clocks both the shift register and the crypto FSM. MSB first, up to 1 MHz.
- Found the datapath: a 32-bit shift register, a round function, and a 6-state FSM (`IDLE, R1..R4, DONE`) — four rounds.
- Found **four identical `SB_RAM40_4K` block RAMs**, one per byte lane, holding the S-box.
- Recovered the embedded **key constant** from the datapath XOR.
- Rebuilt a clean, readable module (`rtl/les_crypto_clean.v`) and confirmed it reproduces the KAT and random vectors in Icarus simulation.

### The S-box decode

The four BRAMs run in `512x8` even-lane mode (`RDATA` wired on the even bits). The initialization words `INIT_0..INIT_7` only decode to a valid bijection under one specific layout: **word = addr >> 1, parity = addr & 1, LSB-first within each byte**. Every other unpacking produces a non-permutation. That decoded 256-byte permutation is the stored S-box (`docs/sbox_enc_Sinv.hex`). The vendor diagram labels it "AES S-box⁻¹", but it is a **custom table** — the textbook AES S-box does not satisfy the KAT.

## 2. The encryption system (recovered)

A small 4-round, 32-bit block cipher. One clock domain, MSB first over SPI.

```
encrypt:  x0 = plaintext ;  x_{i+1} = Sinv( ROTR8(x_i) ) XOR K ;  ciphertext = x4
decrypt:  y0 = ciphertext;  y_{i+1} = ROTL8( Sfwd( y_i XOR K ) ); plaintext  = y4
```

- `ROTR8 / ROTL8` — rotate the 32-bit word right / left by 8 bits.
- `Sinv` — the recovered 256-byte S-box, applied one byte per lane; `Sfwd` is its inverse (used by the decrypt path).
- **Embedded key:** `K = 0xA0A7D0AC`, recovered by exhausting all 2³² keys against the known-answer pair under this round function (unique solution; confirmed by a 200k-vector encrypt/decrypt round-trip).

Validation: `enc(0x59C359C3) = 0x9CD84392` (matches the shipped KAT), `dec(0x9CD84392) = 0x59C359C3`. Full detail in `docs/recovered_cipher.md`.

## 3. AI methods — the pipeline

The whole attack is driven by a single logged notebook, `trojangen_hw.ipynb`, run top to bottom:

1. **Golden model.** The recovered cipher is implemented in Python and used to score generated RTL. It emits the clean reference module so the notebook is self-contained.
2. **Oracle.** Icarus Verilog plus a protocol-accurate stealth testbench (the KAT + 16 random vectors) checks that any generated design still behaves like the real cipher on normal inputs.
3. **Agentic generation loop.** In one prompt the model produces **three** artifacts: the Trojaned module, a self-checking exploit testbench, and a JSON **activation recipe** describing how to fire its own trigger. The loop then:
   - runs the stealth test (normal operation must be bit-identical),
   - **replays the model's activation recipe through an independent, protocol-correct harness** to confirm the key actually reaches MISO (ground truth — it does not trust the model's own testbench),
   - runs the model's exploit testbench and checks it reads the real key,
   - on any failure, feeds a precise diagnosis back to the model and iterates.
4. **One-click.** A single cell takes the attack from clean RTL to a verified Trojan + working exploit, saving `rtl/les_crypto_trojan.v`, `tb/exploit_tb.v`, and `tb/activation_recipe.json`.

Every call lands in `ai/logs/` as the evidence the hardware was AI-written.

**Integrity note.** The grading oracle is deliberately kept separate from the attacker. The independent harness knows the recovered key and reads MISO correctly, so a Trojan is only accepted when the key leak is confirmed by ground truth — not merely because the model's own testbench said so. During development this caught a real bug: an early exploit testbench had an SPI readout-timing error and under-reported the leak even though the Trojan was correct. The lesson — never trust an attacker's self-report — is baked into the pipeline.

## 4. Trojan design

- **Type:** information leakage (key exfiltration), the highest-value payload class — not denial of service or blind corruption.
- **Trigger:** encrypting the specific plaintext word `0xDEADBEEF`. This value is never submitted in normal use; when it is, the Trojan fires and the next MISO readout returns the 32-bit key `0xA0A7D0AC` in place of the ciphertext. The exact activation is recorded in `tb/activation_recipe.json`.
- **Payload:** when the trigger fires, the next MISO readout shifts out the 32-bit embedded key `0xA0A7D0AC` in place of the normal ciphertext.
- **Stealth:** the S-box ROM, the round datapath, and the FSM are untouched. For every non-triggering input, encryption and decryption are **bit-identical** to the clean design — verified against the KAT and 16 random vectors every run.
- **Overhead:** minimal — a trigger comparator plus a mux on the readout path. No change to the critical round logic.

## 5. Exploit

`tb/exploit_tb.v` (AI-generated) demonstrates the attack end to end and is enough to reproduce it on real hardware once a bitstream is built:

1. **Normal operation proof.** It encrypts `0x59C359C3`, checks the output is `0x9CD84392`, and prints `NORMAL OK` — showing the part behaves like a legitimate cipher.
2. **Trigger + leak.** It drives the activation sequence over SPI (the steps in `activation_recipe.json`), then reads MISO and prints `LEAK: <key>`.
3. **Verdict + waveform.** It prints `RESULT PASS` only if normal operation checks out **and** the leaked value equals the key, and dumps `exploit.vcd` for inspection.

To exploit on hardware: speak the standard SPI sequence (reset → shift in 32 bits, CS low, MSB first → raise CS → pulse START → poll BUSY → shift out 32 bits), following the recipe to reach the trigger, then read the key off MISO on the final readout.

## 6. Reproduce

1. Open `trojangen_hw.ipynb` in Google Colab (or Jupyter).
2. Run top to bottom. It installs `openai` + `iverilog`, asks once for an NVIDIA API key (`getpass`, never written to disk), rebuilds the clean RTL, and runs the generation + verification loop.
3. Outputs land in `rtl/`, `tb/`, and `ai/logs/`. The final cell prints the converged Trojan and saves all three artifacts.
