"""Command line: ``superslim lines|genes|predict --model FILE.npz``."""
from __future__ import annotations

import argparse
import csv
import sys

from . import __version__
from .model import SuperSLIM


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(prog="superslim", description="Predict mean transcriptome responses to gene perturbations in learned cell systems.")
    ap.add_argument("--version", action="version", version=f"superslim {__version__}")
    sub = ap.add_subparsers(dest="cmd", required=True)
    dl = sub.add_parser("download", help="download a released model file (SHA-256 checked)")
    dl.add_argument("--name", default="open-v4")
    dl.add_argument("--dest", help="folder (default: ~/.cache/superslim or $SUPERSLIM_HOME)")
    for name in ("info", "lines", "genes", "predict"):
        sp = sub.add_parser(name)
        sp.add_argument("--model", required=True, help="path to a SuperSLIM .npz model file")
    sp = sub.choices["predict"]
    sp.add_argument("--line", required=True)
    sp.add_argument("--gene", action="append", default=[], help="input gene symbol (repeat for several genes)")
    sp.add_argument("--genes-file", help="text file with one gene symbol per line")
    sp.add_argument("--out", default="prediction.csv", help="CSV output (wide: one row per output gene, one column per input gene)")
    a = ap.parse_args(argv)
    if a.cmd == "download":
        from .hub import download_model

        print(download_model(a.name, a.dest))
        return 0
    m = SuperSLIM.load(a.model)
    if a.cmd == "info":
        for k, v in m.info().items():
            print(f"{k}: {v}")
        return 0
    if a.cmd == "lines":
        print("\n".join(m.lines))
        return 0
    if a.cmd == "genes":
        print("\n".join(m.genes()))
        return 0
    genes = list(a.gene)
    if a.genes_file:
        genes += [x.strip() for x in open(a.genes_file, encoding="utf-8") if x.strip()]
    if not genes:
        print("give --gene or --genes-file", file=sys.stderr)
        return 2
    res = m.predict(genes, a.line)
    with open(a.out, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["output_gene"] + genes)
        for j, g in enumerate(res.output_genes):
            w.writerow([g] + [f"{res.values[i, j]:.6g}" for i in range(len(genes))])
    print(f"saved {a.out}: {len(res.output_genes)} output genes x {len(genes)} input genes ({a.line})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
