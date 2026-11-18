# GateLock Reproduction (Agent-Based)

Reproduction of:
**V. S. Rathor, M. Singh, K. S. Sahoo, S. P. Mohanty, "GateLock: Input-Dependent Key-Based Locked Gates for SAT Resistant Logic Locking," IEEE TVLSI, vol. 32, no. 2, pp. 361–371, 2024.**
[Paper PDF](https://sarajumohanty.github.io/Publications_Journals/2024/Mohanty_IEEE-TVLSI_2024-Feb_GateLock.pdf)

Built with an AI agent (Claude), following the LockForge workflow. All prompts, errors and fixes are in [AGENT_LOG.md](AGENT_LOG.md).

## Paper idea

Normal logic locking has one correct key. The SAT attack uses that fact to find it.

GateLock replaces normal 2-input gates (AND, NAND, OR, NOR, XOR, XNOR) with locked gates that take 2 key bits each.
The right key depends on the gate's inputs:
- inputs `00, 01` (A = 0) need key `00`
- inputs `10, 11` (A = 1) need key `11`

So no single key works for all inputs. The SAT attack runs out of consistent keys and ends with "UNSAT model".

## What is implemented

| File | What it does |
|---|---|
| `GateLock.py` | Locks a `.bench` netlist. Replaces `k/2` random 2-input gates with the locked gates from **Table IV** of the paper. `--validate` checks the locked circuit matches the original when each gate gets its input-dependent key (`K1K2 = AA`). `--scheme rll` does random XOR/XNOR locking for the control run. |
| `sat_attack.py` | Oracle-guided SAT attack (Subramanyan et al., HOST 2015) using PySAT. Reports iterations, time, and outcome: `UNSAT MODEL` (no key exists), `KEY FOUND` (key matches the original on 2000 random patterns) or `WRONG KEY` (attack ended with a key that does not match). |
| `run_experiments.sh` | Runs everything and writes `results.csv`. |
| `benchmarks/` | Standard ISCAS-85 c432–c7552 `.bench` netlists. |
| `GateLock_Locked/` | Locked netlists produced by the runs. |
| `results.csv` | All results. |

## How to run

```bash
pip install python-sat
./run_experiments.sh
```

Takes about 20 seconds on a laptop CPU.

Single run:
```bash
python GateLock.py --in benchmarks/c432.bench --out GateLock_Locked/c432_k16.bench --key-size 16 --seed 7 --validate
python sat_attack.py --locked GateLock_Locked/c432_k16.bench --oracle benchmarks/c432.bench
```

## Results

**Correctness:** all 36 locked circuits match the original on 500/500 random patterns with the input-dependent key.

**SAT attack on GateLock** (number of SAT iterations; outcome is `UNSAT MODEL` unless marked):

| Bench | 16 keys | 32 keys | 64 keys | 128 keys |
|---|---|---|---|---|
| c432 | 8 | 5 | 10 | 2 |
| c499 | 2 | 2 | 2 | 3 |
| c880 | 6 | 4 | 2 | 2 |
| c1355 | 4 | 2 | 13 | 2 |
| c1908 | 3 | 7 | 3 | 6 |
| c2670 | 7 (WRONG KEY) | 5 | 4 | 4 |
| c3540 | 4 | 7 | 3 | 3 |
| c5315 | 6 | 7 | 8 | 3 |
| c7552 | 4 | 5 | 4 | 2 |

Every attack finishes in well under a second (exact times vary by machine; see `results.csv`).

- **35/36** runs end in `UNSAT MODEL`: no key fits the original circuit's behaviour.
- **c2670, 16 keys** ends with a key, but it is wrong: it matches the original on only 1039/2000 random patterns. The attack stops when all remaining keys behave the same as each other, but none of them is the real key. So GateLock still beats the attack here, just with a different outcome label.

**Control (RLL, c432, 16 keys):** the same attack finds the key in 12 iterations. It equals the correct key exactly and matches the oracle on 2000/2000 patterns. This shows the attack works, so the UNSAT results come from GateLock, not from a bug.

**Comparison to the paper:** the paper (Table V) reports `UNSAT Model` for every ISCAS-85 benchmark with a few iterations (e.g. c432 16 keys: 8 iterations, 0.023 s). We get the same outcome on 35 of 36 runs. In the other run (c2670, 16 keys) the attack ends with a wrong key, so it still fails to unlock the circuit. Iteration counts and the c2670 case differ because gate selection is random.

## Differences from the paper

- **Locked gate source:** the AND equation printed in the paper's text does not match its Table IV (complement bars lost). We used Table IV.
- **SAT attack:** our own PySAT implementation of the standard attack, not the original binary the paper used.
- **Not reproduced:** area/power/delay overhead (needs Cadence RTL Compiler + 45 nm library), ISCAS-89/ITC benchmarks, and the brute-force analysis.
