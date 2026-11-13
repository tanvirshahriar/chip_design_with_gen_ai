# Recovered cipher — LES crypto IP (iCE40 bitstream)

The target is the Hackster "lightweight" crypto accelerator. Everything below
was recovered from the **bitstream only** (`ice40_bitstream.bin`), unpacked with
Project IceStorm and cross-checked against the one known-answer pair the
challenge ships (`0x59C359C3` encrypts to `0x9CD84392`).

## Interface
Raw SPI peripheral + sideband, exactly as in `ice40_cryptographic_IP.md`
(`SCK, RST_N, MOSI, MISO, NORM_CS_N, START, ENC_DEC, BUSY, ICE_LED`). One unified
clock domain: `SCK` clocks the shift register *and* the crypto FSM. Sequence:
reset -> shift in 32 bits (CS low, MSB first) -> raise CS -> pulse START ->
poll BUSY -> shift out 32 bits on MISO.

## Algorithm (4 rounds, 32-bit block)
```
encrypt:  x0 = plaintext ;  x_(i+1) = Sinv( ROTR8(x_i) ) XOR K ;  ciphertext = x4
decrypt:  y0 = ciphertext;  y_(i+1) = ROTL8( Sfwd( y_i XOR K ) ); plaintext  = y4
```
- `ROTR8` / `ROTL8` = rotate the 32-bit word right / left by 8 bits.
- `Sinv` = the stored 256-byte S-box, applied one byte per lane.
- `Sfwd` = inverse permutation of `Sinv` (used by the decrypt core).

## Embedded key
```
K = 0xA0A7D0AC
```
Recovered by exhausting all 2^32 keys against the known-answer pair under the
round function above (unique solution for the ROTR8 / stored-S-box convention;
confirmed by a 200k-vector encrypt/decrypt round-trip).

## S-box recovery
The 4 `SB_RAM40_4K` blocks in the netlist are **identical** (one per byte lane)
and run in 512x8 even-lane mode (`RDATA` wired on bits [14,12,...,0]). Unpacking
`INIT_0..INIT_7` with the even-lane / parity-split layout (word = addr>>1,
parity = addr&1, LSB-first) is the only unpacking that yields a bijection. That
256-byte permutation is the stored S-box (`docs/sbox_enc_Sinv.hex`); the diagram
labels it "AES S-box^-1", but it is a **custom** table, not the textbook AES one.

## Validation status
- `enc(0x59C359C3) = 0x9CD84392` — matches the shipped KAT.
- `dec(0x9CD84392) = 0x59C359C3` — decrypt inverts encrypt.
- RTL (`rtl/les_crypto_clean.v`) reproduces the KAT + 7 model vectors in
  Icarus simulation (`tb/tb_clean.v`), and enc/dec round-trip on 200k random
  words in the Python golden model (`ai/ref_model.py`).
