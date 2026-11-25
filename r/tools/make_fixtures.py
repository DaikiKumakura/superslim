"""Regenerate the synthetic model and golden values used by the R tests from the Python package of this repository.
Run from the repository root:  python r/tools/make_fixtures.py"""
import csv, sys
from pathlib import Path
import numpy as np
root = Path(__file__).resolve().parents[2]; sys.path[:0] = [str(root / "src"), str(root / "tests")]
from test_model import make_open
from superslim import SuperSLIM
fx = root / "r" / "tests" / "testthat" / "fixtures"; fx.mkdir(parents=True, exist_ok=True)
np.savez_compressed(fx / "synthetic_open.npz", **make_open(0))
m = SuperSLIM.load(str(fx / "synthetic_open.npz")); genes = ["G0", "G1", "G5", "G19"]; r = m.predict(genes, "sysa")
with open(fx / "golden_sysa.csv", "w", newline="") as f:
    w = csv.writer(f); w.writerow(["gene"] + list(r.output_genes))
    for g, row in zip(genes, r.values): w.writerow([g] + [repr(float(x)) for x in row])
print("wrote", fx)
