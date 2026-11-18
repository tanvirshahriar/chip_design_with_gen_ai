"""GateLock: Input-Dependent Key-Based Locked Gates (Rathor et al., TVLSI 2024).

Replaces k/2 randomly chosen 2-input gates with IDKLL locked gates (2 key bits each).
Locked gate functions come from Table IV of the paper.
Also supports --scheme rll (random XOR/XNOR locking) for the control experiment.

Usage:
  python GateLock.py --in benchmarks/c432.bench --out GateLock_Locked/c432_k16.bench \
      --key-size 16 --seed 7 --validate --patterns 1000
"""
import argparse
import random
import re

# Table IV of the paper. Rows are AB = 00, 01, 10, 11.
# Y1..Y6 = locked AND, NAND, OR, NOR, XOR, XNOR.
TABLE_IV = {
    "AND":  {"00": [0, 0, 1, 0], "01": [1, 1, 1, 1], "10": [0, 0, 0, 0], "11": [1, 1, 0, 1]},
    "NAND": {"00": [1, 1, 0, 1], "01": [1, 1, 1, 1], "10": [0, 0, 0, 0], "11": [0, 0, 1, 0]},
    "OR":   {"00": [0, 1, 0, 0], "01": [1, 1, 1, 1], "10": [0, 0, 0, 0], "11": [1, 0, 1, 1]},
    "NOR":  {"00": [1, 0, 1, 1], "01": [1, 1, 1, 1], "10": [0, 0, 0, 0], "11": [0, 1, 0, 0]},
    "XOR":  {"00": [0, 1, 0, 1], "01": [1, 1, 1, 1], "10": [1, 0, 0, 0], "11": [1, 0, 1, 0]},
    "XNOR": {"00": [1, 0, 1, 0], "01": [1, 1, 1, 1], "10": [0, 0, 1, 0], "11": [0, 1, 0, 1]},
}
LOCKABLE = set(TABLE_IV)


# ---------------------------------------------------------------- bench I/O
def parse_bench(path):
    inputs, outputs, gates = [], [], {}
    for line in open(path):
        line = line.split("#")[0].strip()
        if not line:
            continue
        m = re.match(r"INPUT\((.+)\)", line)
        if m:
            inputs.append(m.group(1).strip())
            continue
        m = re.match(r"OUTPUT\((.+)\)", line)
        if m:
            outputs.append(m.group(1).strip())
            continue
        m = re.match(r"(\S+)\s*=\s*(\w+)\((.*)\)", line)
        if m:
            op = m.group(2).upper()
            op = "BUFF" if op == "BUF" else op
            gates[m.group(1)] = (op, [x.strip() for x in m.group(3).split(",")])
    return inputs, outputs, gates


def write_bench(path, inputs, outputs, gates):
    with open(path, "w") as f:
        f.writelines(f"INPUT({i})\n" for i in inputs)
        f.write("\n")
        f.writelines(f"OUTPUT({o})\n" for o in outputs)
        f.write("\n")
        f.writelines(f"{g} = {op}({', '.join(ins)})\n" for g, (op, ins) in gates.items())


def topo_order(inputs, gates):
    done, order = set(inputs), []
    pending = dict(gates)
    while pending:
        ready = [g for g, (_, ins) in pending.items() if all(i in done for i in ins)]
        if not ready:
            raise ValueError("combinational loop or undriven wire")
        for g in ready:
            order.append(g)
            done.add(g)
            del pending[g]
    return order


def eval_gate(op, vals):
    if op == "AND":
        return int(all(vals))
    if op == "NAND":
        return int(not all(vals))
    if op == "OR":
        return int(any(vals))
    if op == "NOR":
        return int(not any(vals))
    if op == "XOR":
        return sum(vals) & 1
    if op == "XNOR":
        return 1 - (sum(vals) & 1)
    if op == "NOT":
        return 1 - vals[0]
    if op == "BUFF":
        return vals[0]
    raise ValueError(op)


def simulate(inputs, gates, order, assignment):
    v = dict(assignment)
    for g in order:
        op, ins = gates[g]
        v[g] = eval_gate(op, [v[i] for i in ins])
    return v


# ---------------------------------------------------------------- locking
def locked_gate_netlist(out, op, a, b, k1, k2, tag):
    """Build the Table IV function Y(K1,K2,A,B) from primitive gates (SOP per key)."""
    g = {}
    g[f"{tag}_nk1"] = ("NOT", [k1])
    g[f"{tag}_nk2"] = ("NOT", [k2])
    g[f"{tag}_na"] = ("NOT", [a])
    g[f"{tag}_nb"] = ("NOT", [b])
    lit = {("k1", 0): f"{tag}_nk1", ("k1", 1): k1, ("k2", 0): f"{tag}_nk2", ("k2", 1): k2,
           ("a", 0): f"{tag}_na", ("a", 1): a, ("b", 0): f"{tag}_nb", ("b", 1): b}
    terms = []
    for key, col in TABLE_IV[op].items():
        kb = (int(key[0]), int(key[1]))
        if all(col):  # constant 1 for this key
            t = f"{tag}_t{key}"
            g[t] = ("AND", [lit[("k1", kb[0])], lit[("k2", kb[1])]])
            terms.append(t)
            continue
        for idx, val in enumerate(col):
            if val:
                av, bv = idx >> 1, idx & 1
                t = f"{tag}_t{key}_{idx}"
                g[t] = ("AND", [lit[("k1", kb[0])], lit[("k2", kb[1])], lit[("a", av)], lit[("b", bv)]])
                terms.append(t)
    g[out] = ("OR", terms)
    return g


def apply_gatelock(inputs, gates, key_size, rng):
    cands = [n for n, (op, ins) in gates.items() if op in LOCKABLE and len(ins) == 2]
    n_lock = key_size // 2
    if n_lock > len(cands):
        raise ValueError(f"only {len(cands)} lockable 2-input gates")
    chosen = rng.sample(cands, n_lock)
    new = {}
    keys, sites = [], []
    for n, (op, ins) in gates.items():
        if n in chosen:
            i = len(sites)
            k1, k2 = f"keyinput{2 * i}", f"keyinput{2 * i + 1}"
            keys += [k1, k2]
            sites.append((n, ins[0], k1, k2))  # valid key for this gate: K1 = K2 = A
            new.update(locked_gate_netlist(n, op, ins[0], ins[1], k1, k2, f"gl{i}"))
        else:
            new[n] = (op, ins)
    return keys, new, sites


def apply_rll(inputs, gates, key_size, rng):
    chosen = rng.sample(list(gates), key_size)
    new, keys, correct = {}, [], {}
    for n, (op, ins) in gates.items():
        if n in chosen:
            i = len(keys)
            k = f"keyinput{i}"
            keys.append(k)
            kind = rng.choice(["XOR", "XNOR"])
            correct[k] = 0 if kind == "XOR" else 1
            new[f"{n}__pre"] = (op, ins)
            new[n] = (kind, [f"{n}__pre", k])
        else:
            new[n] = (op, ins)
    return keys, new, correct


# ---------------------------------------------------------------- main
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="inp", required=True)
    ap.add_argument("--out", dest="outp", required=True)
    ap.add_argument("--key-size", type=int, default=16)
    ap.add_argument("--seed", type=int, default=7)
    ap.add_argument("--scheme", choices=["gatelock", "rll"], default="gatelock")
    ap.add_argument("--validate", action="store_true")
    ap.add_argument("--patterns", type=int, default=1000)
    args = ap.parse_args()

    rng = random.Random(args.seed)
    inputs, outputs, gates = parse_bench(args.inp)
    if args.scheme == "gatelock":
        keys, lgates, sites = apply_gatelock(inputs, gates, args.key_size, rng)
    else:
        keys, lgates, correct = apply_rll(inputs, gates, args.key_size, rng)
    write_bench(args.outp, inputs + keys, outputs, lgates)
    print(f"Locked file: {args.outp}  scheme={args.scheme}  key bits={len(keys)}")
    if args.scheme == "gatelock":
        print("Correct key: input-dependent, K1K2 = AA at each locked gate (A = gate's first input)")
    else:
        print("Correct key:", "".join(str(correct[k]) for k in keys))

    if not args.validate:
        return
    order_g = topo_order(inputs, gates)
    order_l = topo_order(inputs + keys, lgates)
    ok_correct = ok_static = 0
    static_key = {k: rng.randint(0, 1) for k in keys}
    for _ in range(args.patterns):
        x = {i: rng.randint(0, 1) for i in inputs}
        gold = simulate(inputs, gates, order_g, x)
        if args.scheme == "gatelock":
            # LUT/key memory delivers K1K2 = AA per gate; A is taken from the golden value
            kv = {}
            for _, a, k1, k2 in sites:
                kv[k1] = kv[k2] = gold[a]
        else:
            kv = correct
        lc = simulate(inputs + keys, lgates, order_l, {**x, **kv})
        ls = simulate(inputs + keys, lgates, order_l, {**x, **static_key})
        ok_correct += all(lc[o] == gold[o] for o in outputs)
        ok_static += all(ls[o] == gold[o] for o in outputs)
    print(f"Validation: Matches(correct)={ok_correct}/{args.patterns} | "
          f"Matches(random static key)={ok_static}/{args.patterns}")


if __name__ == "__main__":
    main()
