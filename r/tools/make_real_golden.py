"""Write Python predictions of the released model for a few genes in every system (read by the R tests in CI).
Run from the repository root:  python r/tools/make_real_golden.py [model.npz]   (default: download_model())"""
import sys
from pathlib import Path
import numpy as np
from superslim import SuperSLIM, download_model

path = sys.argv[1] if len(sys.argv) > 1 else str(download_model())
m = SuperSLIM.load(path); genes = ["TP53", "EGFR", "MYC", "KRAS"]
out = {"genes": np.array(genes)}
for line in m.lines: out[line] = m.predict(genes, line).values.astype(np.float64)
dest = Path(__file__).resolve().parents[1] / "tests" / "testthat" / "fixtures" / "golden_real.npz"
np.savez_compressed(dest, **out); print(path)
