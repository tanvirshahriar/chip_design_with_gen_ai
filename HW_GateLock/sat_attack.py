"""Oracle-guided SAT attack (Subramanyan et al., HOST 2015) using PySAT.

Key inputs are the INPUTs whose names start with 'keyinput'.
The oracle is the original (unlocked) netlist.

Outcome:
  KEY FOUND   - a key consistent with all DIPs exists and matches the oracle on 2000 random patterns.
  WRONG KEY   - the attack terminated with a key, but it does not match the oracle.
  UNSAT MODEL - no single key is consistent with the oracle's I/O pairs (GateLock's expected result).

Usage:
  python sat_attack.py --locked GateLock_Locked/c432_k16.bench --oracle benchmarks/c432.bench \
      [--csv results.csv --label c432 --scheme gatelock]
"""
import argparse
import csv
import os
import random
import time

from pysat.solvers import Glucose4

from GateLock import eval_gate, parse_bench, simulate, topo_order


class Encoder:
    def __init__(self, solver):
        self.s = solver
        self.n = 0

    def new(self):
        self.n += 1
        return self.n

    def gate(self, op, ins):
        y = self.new()
        add = self.s.add_clause
        if op in ("BUFF", "NOT"):
            x = ins[0] if op == "BUFF" else -ins[0]
            add([-y, x]); add([y, -x])
        elif op in ("AND", "NAND", "OR", "NOR"):
            neg_in = op in ("OR", "NOR")
            lits = [-i for i in ins] if neg_in else list(ins)
            z = y if op in ("AND", "OR") else -y
            if neg_in:
                z = -z
            # z <-> AND(lits)
            for l in lits:
                add([-z, l])
            add([z] + [-l for l in lits])
        elif op in ("XOR", "XNOR"):
            acc = ins[0]
            for i in ins[1:]:
                t = self.new()
                add([-t, acc, i]); add([-t, -acc, -i]); add([t, -acc, i]); add([t, acc, -i])
                acc = t
            x = acc if op == "XOR" else -acc
            add([-y, x]); add([y, -x])
        else:
            raise ValueError(op)
        return y

    def circuit(self, gates, order, var):
        var = dict(var)
        for g in order:
            op, ins = gates[g]
            var[g] = self.gate(op, [var[i] for i in ins])
        return var


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--locked", required=True)
    ap.add_argument("--oracle", required=True)
    ap.add_argument("--csv")
    ap.add_argument("--label", default="")
    ap.add_argument("--scheme", default="")
    ap.add_argument("--max-iter", type=int, default=100000)
    args = ap.parse_args()

    l_in, l_out, l_gates = parse_bench(args.locked)
    o_in, o_out, o_gates = parse_bench(args.oracle)
    keys = [i for i in l_in if i.startswith("keyinput")]
    pis = [i for i in l_in if not i.startswith("keyinput")]
    l_order = topo_order(l_in, l_gates)
    o_order = topo_order(o_in, o_gates)

    s = Glucose4()
    enc = Encoder(s)
    X = {i: enc.new() for i in pis}
    K1 = {k: enc.new() for k in keys}
    K2 = {k: enc.new() for k in keys}
    c1 = enc.circuit(l_gates, l_order, {**X, **K1})
    c2 = enc.circuit(l_gates, l_order, {**X, **K2})
    act = enc.new()  # miter is active only under this assumption
    diffs = []
    for o in l_out:
        d = enc.new()
        a, b = c1[o], c2[o]
        s.add_clause([-d, a, b]); s.add_clause([-d, -a, -b]); s.add_clause([d, -a, b]); s.add_clause([d, a, -b])
        diffs.append(d)
    s.add_clause([-act] + diffs)

    t0 = time.time()
    it = 0
    while it < args.max_iter and s.solve(assumptions=[act]):
        it += 1
        m = set(l for l in s.get_model() if l > 0)
        dip = {i: int(X[i] in m) for i in pis}
        y = simulate(o_in, o_gates, o_order, dip)
        for K in (K1, K2):
            xv = {}
            for i in pis:
                v = enc.new()
                s.add_clause([v] if dip[i] else [-v])
                xv[i] = v
            c = enc.circuit(l_gates, l_order, {**xv, **K})
            for o in l_out:
                s.add_clause([c[o]] if y[o] else [-c[o]])

    if s.solve(assumptions=[-act]):
        m = set(l for l in s.get_model() if l > 0)
        key = {k: int(K1[k] in m) for k in keys}
        outcome = "KEY FOUND"
    else:
        key = None
        outcome = "UNSAT MODEL"
    elapsed = time.time() - t0

    # check a recovered key on random patterns against the oracle
    equiv = ""
    if key is not None:
        rng = random.Random(0)
        good = 0
        for _ in range(2000):
            x = {i: rng.randint(0, 1) for i in pis}
            a = simulate(l_in, l_gates, l_order, {**x, **key})
            b = simulate(o_in, o_gates, o_order, x)
            good += all(a[o] == b[o] for o in o_out)
        equiv = f"{good}/2000"
        if good < 2000:
            outcome = "WRONG KEY"

    key_str = "".join(str(key[k]) for k in keys) if key else "-"
    print(f"{args.label} {args.scheme} keys={len(keys)} iterations={it} time={elapsed:.3f}s "
          f"outcome={outcome} key={key_str} equiv_check={equiv or '-'}")

    if args.csv:
        new = not os.path.exists(args.csv)
        with open(args.csv, "a", newline="") as f:
            w = csv.writer(f)
            if new:
                w.writerow(["bench", "scheme", "key_bits", "sat_iterations", "time_s", "outcome",
                            "recovered_key", "equiv_check_2000"])
            w.writerow([args.label, args.scheme, len(keys), it, f"{elapsed:.3f}", outcome, key_str, equiv or "-"])


if __name__ == "__main__":
    main()
