# Chip Design with Generative AI

Homework for the **LLM4ChipDesign** course (GenAI-based chip design).
Each folder holds one assignment: an executed Colab notebook, the generated Verilog, logs, and a report.

All assignments use `nvidia/nemotron-3-super-120b-a12b` through NVIDIA's OpenAI-compatible API, and
Icarus Verilog (`iverilog` / `vvp`) for simulation.

## Assignments

| Folder | Topic | Report |
|---|---|---|
| [`HW_TestbenchGen`](HW_TestbenchGen) | LLM-aided testbench generation for `mux2to1`, `adder4bit` and a custom `sat_adder8`, with a buggy-design demo | [TestbenchGen_Report.pdf](HW_TestbenchGen/TestbenchGen_Report.pdf) |
| [`HW_ChipChat`](HW_ChipChat) | Conversational Verilog generation (ChipChat) for eight benchmark designs and an 8-bit accumulator CPU | [ChipChat_Report.pdf](HW_ChipChat/ChipChat_Report.pdf) |
| [`HW_AutoChip`](HW_AutoChip) | Automated generate–simulate–feedback loop (AutoChip) for the same eight designs and a co-designed 8-bit CPU | [AutoChip_Report.pdf](HW_AutoChip/AutoChip_Report.pdf) |
| [`HW_ROME_Coverage`](HW_ROME_Coverage) | Hierarchical RTL generation (ROME) for a mux hierarchy and a `half_adder → adder8` hierarchy, with iVerilog + Covered coverage-guided testbench refinement | [ROME_Report.pdf](HW_ROME_Coverage/ROME_Report.pdf) |

## Running a notebook

1. Open the notebook in Google Colab.
2. Put your NVIDIA API key in the API-key cell.
3. Run all cells top to bottom.

## License

[MIT](LICENSE)
