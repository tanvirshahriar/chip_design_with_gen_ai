# Agent Interaction Log

Agent: Claude (Anthropic), running as an agent with a shell, file tools and web search.
User: Tanvir Shahriar.
This log records the prompts I gave, what the agent did, the errors it hit, and how it fixed them.

---

## Session 1 — Picking the paper (Nov 13)

**Prompt:**
> [assignment text + sheet link] choose one for me to do

**Agent actions:**
- Read the sheet. Listed the unassigned papers on the LL sheet.
- Searched the web for the top candidates (#9 and #10).
- Picked **#10 GateLock (Rathor et al., IEEE TVLSI 2024)**.

**Reasoning given:**
- Method is simple: replace 2-input gates with key-controlled gates.
- Main experiment (SAT attack on ISCAS-85) runs on CPU in minutes with PySAT.
- Clear pass/fail result: SAT attack should end in UNSAT.
- Paper PDF is free on the author's site.

---

## Session 2 — Planning (Nov 17)

**Prompt 1:**
> We are going to do this to complete this assignment ... Here are my guidelines: 1. Only do whats necessary, nothing extra at all 2. Give me the plan to get this completed 3. Keep it similar to these lockforge examples if possible. [GUIDE notebook link] 4. here is the lockforge github [LockForge link]

**Agent actions:**
- Cloned LockForge and GUIDE. Looked at the per-technique folders (SARO, DECOR, Harpoon).
- Pattern found: one `<Name>.py` with argparse + `--validate`, a README, a `<Name>_BCSRP.yaml`, a locked-bench folder, logs.
- Read the GateLock paper (via web fetch) for: gate design, benchmarks, key sizes, SAT attack, metrics.
- Proposed a repo layout and 7 steps.

**Prompt 2:**
> explain the papers main takeawy and link me to paper

**Agent actions:** Explained IDKLL in short form. Linked the PDF.

**Prompt 3:**
> check the repo layout and implementation plan and only keep the absolute necessities

**Refinement:** Agent cut the BCSRP yaml, the logs folder, and the separate README. Flagged that dropping the control run would leave no proof the attack works.

**Prompt 4:**
> 1. we should keep the control run. 2. The assignment asks to document agent interactions, you are the agent, keep a running interaction log for this work

**Refinement:** Control run kept. This log started.

---

## Session 3 — Implementation (Nov 17)

### Step 1: Paper details

- Fetched the paper again, asking for Table III/IV (locked gate truth tables) as data.
- **Issue found:** the AND equation in the text (`Y1 = K2·A + K2·B + K1·A·B`) does not match Table IV. The PDF text extraction loses the complement bars.
- **Fix:** used Table IV directly as the source of truth, not the equation.
- **Check:** with key `00` for A=0 and key `11` for A=1, Table IV gives exactly AND/NAND/OR/NOR/XOR/XNOR for all six gates. So the valid key for each locked gate is `K1K2 = A A`.

### Step 2: Benchmarks

- **Error:** `curl` to the author's site was blocked by the sandbox network proxy (403). Also several GitHub repos with `.bench` files were private/missing (`could not read Username`).
- **Fix:** cloned `jpsety/verilog_benchmark_circuits`, which has gate-level Verilog for ISCAS-85. Wrote `v2bench.py` to convert Verilog primitives to `.bench`.
- Edge case: one `assign N = 1'b0` constant. Converted to `AND(x, NOT x)`.
- Check: input/output counts for all 9 circuits match the official ISCAS-85 table (e.g. c432 36/7, c7552 207/108).
- Note: gate counts differ from the originals because these netlists were re-synthesized with Cadence Genus. Function is the same.

### Step 3: `GateLock.py`

- Followed the LockForge script style (SARO.py): argparse, `--in/--out/--key-size/--seed/--validate/--patterns`.
- Each locked gate = Table IV function built from NOT/AND/OR (one product term per 1 in the table). 2 key bits per gate, so `key-size k` locks `k/2` random 2-input gates. Random selection, same as the paper's experiments.
- Added `--scheme rll` (random XOR/XNOR key gates) for the control run.
- **Design decision:** how to validate an input-dependent key. The paper says a LUT memory feeds `K1K2` based on the gate's inputs. So validation sets `K1K2 = A A` at each locked gate using the golden value of A, then compares outputs.
- Results: c432 k=16 → 1000/1000 match with correct key. c7552 k=128 → 300/300. A random static key → 528/1000 and 0/300.
- Extra check: exhaustively simulated all 6 locked gate netlists for all 16 (K1,K2,A,B) combos. All match Table IV. Key `AA` always gives the original gate.

### Step 4: `sat_attack.py`

- Standard DIP loop (Subramanyan et al. 2015): two locked copies sharing X, miter on outputs, oracle query per DIP, add I/O constraints on both key copies.
- Used an activation literal on the miter. When no DIP is left, solve again without the miter to get a key consistent with all DIPs. If that is UNSAT → `UNSAT MODEL` (no key exists), which is what the paper reports.
- A recovered key is checked against the oracle on 2000 random patterns.
- **Control test:** c432 RLL k=16 → KEY FOUND in 10 iterations, key exactly equals the correct key, 2000/2000 match. So the attack works.
- **GateLock test:** c432 k=16 → UNSAT MODEL after 3 iterations. Matches the paper's claim.

### Step 5: Full experiments (`run_experiments.sh`)

- 9 ISCAS-85 benchmarks × key sizes 16/32/64/128 = 36 GateLock runs, plus 1 RLL control. Fixed seed 7.
- **Minor error:** after the run, `column` (used to pretty-print the CSV) was not installed in the sandbox (exit 127). Did not affect results. Printed the CSV with `cat` instead.
- Results: 36/36 validations passed (500/500 patterns). 36/36 attacks ended in UNSAT MODEL in 2–11 iterations, all under 0.12 s. Control found the exact key.
- Whole run: ~20 s on CPU.

### Step 6: README + checks

- Wrote README.md: paper idea, files, how to run, results, differences from paper.
- Checked the README results table against `results.csv` with a script. All 36 cells match.
- Listed what was not reproduced (area/power/delay needs Cadence; ISCAS-89/ITC; brute-force analysis).

---

## Summary of agent errors and refinements

| # | Problem | Fix |
|---|---|---|
| 1 | Paper's AND equation contradicts its Table IV | Used Table IV; verified exhaustively |
| 2 | Sandbox blocked the paper PDF and several benchmark repos | Read paper via web fetch; converted public Verilog netlists with `v2bench.py` |
| 3 | Constant `1'b0` assign in a netlist | Mapped to `AND(x, NOT x)` |
| 4 | How to "validate" a key that changes with the input | Feed `K1K2 = AA` per gate from golden values (models the paper's key LUT) |
| 5 | UNSAT could hide an attack bug | Added RLL control run; attack recovers exact key |
| 6 | `column` not installed | Used `cat` |
| 7 | User asked to cut the plan to essentials | Dropped BCSRP yaml, logs folder, extra README; kept control run at user's request |

---

## Session 4 — Testing guide + standard benchmarks (Nov 17)

**Prompt:**
> 1. Give me the steps to test this 2. How can i download the standard .bench files and test with those

**Refinement:** some standard ISCAS-85 `.bench` copies write buffers as `BUF`, not `BUFF`. Added a `BUF` → `BUFF` alias in `parse_bench`. Re-ran `run_experiments.sh`; results unchanged (36/36 UNSAT, control key found).

**User test run (Windows PowerShell):** user ran the full experiment on their own machine and shared `run_log.txt` and `results.csv`.
- 36/36 validations `500/500`, 36/36 `UNSAT MODEL`, control `KEY FOUND` with the exact key.
- Iteration counts identical to the agent's run (fixed seed works across machines).
- Times were slower (max 0.186 s vs 0.116 s), so the README's "under 0.12 s" claim was wrong for other machines. Changed to "under 0.2 s, varies by machine".

---

## Session 5 — Switch to standard ISCAS-85 files (Nov 17)

**Prompt 1:**
> [uploaded ISCAS.7z] where are the files

**Agent actions:**
- Listed the archive. The `.bench` netlists are in `bench/` (c432–c7552). Other folders are the same circuits in other formats.
- Ran the full experiment on a copy with these files. Parser worked as-is (handles the `#` header comments).
- **New finding:** c2670 with 16 keys ended in `KEY FOUND`, but the key matched the oracle on only 1039/2000 patterns.
- **Explanation:** the DIP loop stops when all remaining keys agree with each other. Normally that means the key is correct. But GateLock has no correct static key, so the surviving keys all agree with each other and are all wrong. The attack still fails.
- Offered two options: keep converted netlists, or switch to standard ones.

**Prompt 2:**
> the standard files, can u do the replacing

**Refinements:**
- Copied the 9 standard `.bench` files into `benchmarks/`. Deleted `v2bench.py` (no longer needed).
- `sat_attack.py`: a key that fails the 2000-pattern check is now labelled `WRONG KEY` instead of `KEY FOUND`, so the CSV is not misleading.
- Re-ran `run_experiments.sh`: 36/36 validations 500/500; 35/36 `UNSAT MODEL`; c2670 k=16 `WRONG KEY` (1039/2000); control `KEY FOUND` exact key (12 iterations, 2000/2000).
- Updated README: files table, results table, c2670 note, comparison to paper, removed the "Genus netlists" difference. Checked the README table against `results.csv` with a script.

**User test run 2 (standard files):** outcomes and iteration counts identical to the agent's run (36/36 validations, 35 UNSAT + c2670 k=16 WRONG KEY, control exact key). Slowest attack on the user's machine was 0.224 s, so the README's "under 0.2 s" was wrong again. Changed to "well under a second, varies by machine" so it holds on any machine.
