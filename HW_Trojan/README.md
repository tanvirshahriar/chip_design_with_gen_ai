# Hardware Trojan — CSAW AI Hardware Attack Challenge 2026 (Qualifier)

**Author:** Tanvir Shahriar
**Target:** iCE40 cryptographic accelerator, recovered from its bitstream
**Payload class:** Information leakage (embedded key exfiltrated over MISO)
**Pipeline model:** `nvidia/nemotron-3-super-120b-a12b`

## Layout
- `rtl/`  — recovered clean RTL, and the AI-generated Trojaned RTL
- `tb/`   — baseline (normal-operation) testbench and the exploit testbench
- `ai/`   — the logged pipeline notebook (`pipeline.ipynb`) and `ai/logs/` with every prompt + response
- `docs/` — technical brief, figures, recovered S-box + cipher spec

## How to run
Open `ai/pipeline.ipynb` (Colab or Jupyter) and run the cells top to bottom:
1. **Setup** — installs `openai`, sets the model/endpoint, prompts for `LLM_API_KEY`
   (entered with `getpass`, never written to disk or committed).
2. **Logged client** — defines `ask()` / `chat()`; every call lands in `ai/logs/`.
3. **Smoke test** — should print `pipeline OK`.
4. **Golden model** — the recovered cipher, used to score generated RTL.

## AI pipeline
All hardware (clean RTL, Trojan, exploit testbench) is produced through the
logged pipeline in `ai/pipeline.ipynb`. Every model interaction is recorded in
`ai/logs/`.

## Technical brief
See `docs/technical_brief.md`.
