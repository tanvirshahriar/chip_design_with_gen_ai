#!/bin/bash
# Lock every ISCAS-85 benchmark with GateLock at 16/32/64/128 key bits, run the SAT attack,
# and run the RLL control. Results go to results.csv.
set -e
cd "$(dirname "$0")"
rm -f results.csv
mkdir -p GateLock_Locked

for c in c432 c499 c880 c1355 c1908 c2670 c3540 c5315 c7552; do
  for k in 16 32 64 128; do
    out=GateLock_Locked/${c}_k${k}.bench
    python3 GateLock.py --in benchmarks/$c.bench --out $out --key-size $k --seed 7 --validate --patterns 500
    python3 sat_attack.py --locked $out --oracle benchmarks/$c.bench --csv results.csv --label $c --scheme gatelock
  done
done

# Control: same attack on random XOR/XNOR locking must recover the key
python3 GateLock.py --in benchmarks/c432.bench --out GateLock_Locked/c432_rll_k16.bench --key-size 16 --seed 7 --scheme rll --validate
python3 sat_attack.py --locked GateLock_Locked/c432_rll_k16.bench --oracle benchmarks/c432.bench --csv results.csv --label c432 --scheme rll_control
