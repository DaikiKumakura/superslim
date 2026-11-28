# SuperSLIM

<!-- badges: start -->
[![tests](https://github.com/DaikiKumakura/superslim/actions/workflows/ci.yml/badge.svg)](https://github.com/DaikiKumakura/superslim/actions/workflows/ci.yml)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.24393778.svg)](https://doi.org/10.5281/zenodo.24393778)
<!-- badges: end -->

A small, NumPy-only predictor of the **mean transcriptome response to knocking down a gene** in a fixed set of learned cell systems. The model file is about 5.9 MB; on a 12-thread Windows PC it loads in about 0.75 s, predicts one gene in about 0.5 to 2 ms (depending on the number of output genes), and needs about 130 MB of memory (measured in [docs/BENCHMARKS.md](docs/BENCHMARKS.md)). No GPU, no PyTorch, no scikit-learn at inference time.

## Installation

```bash
pip install git+https://github.com/DaikiKumakura/superslim.git   # Python >= 3.9, NumPy only
superslim download                                                  # fetches the model file (SHA-256 checked) into ~/.cache/superslim
```

The same predictions are available in **R** (base R; the package lives in the [`r/`](r/) folder of this repository; version numbers follow the Python package):

```r
pak::pak("DaikiKumakura/superslim/r")
library(superslim); m <- ss_load(ss_download("open-v4")); ss_predict(m, c("TP53", "EGFR"), "cd4_rest")
```

## Quick start

```python
from superslim import SuperSLIM, download_model

m = SuperSLIM.load(download_model("open-v4"))   # or SuperSLIM.load("path/to/model.npz")
m.info()                                         # systems, input genes, output genes per system
res = m.predict(["TP53", "EGFR"], line="cd4_rest")
res.values.shape                                 # (2, number of output genes)
res.top("EGFR", n=10, direction="down")          # most strongly decreased genes
m.compare("TP53")                                # the same gene in every system (each in its own output genes and units)
```

Printed by these calls with the `open-v4` model (the top-10 call shown with `n=5`):

```text
m.info()         {'systems': ['k562_gwps', 'hct116', 'hek293t', 'cd4_rest', 'cd4_stim8hr', 'cd4_stim48hr', 'kolf2_strong',
                  'rpe1_essential', 'jurkat_essential', 'hepg2_essential'],
                  'n_input_genes': 21688, 'n_output_genes': {'k562_gwps': 8248, 'hct116': 14685, 'hek293t': 14685,
                  'cd4_rest': 6089, 'cd4_stim8hr': 6089, 'cd4_stim48hr': 6089, 'kolf2_strong': 15419,
                  'rpe1_essential': 8749, 'jurkat_essential': 8882, 'hepg2_essential': 9624}}
res.values.shape (2, 6089)
res.top("EGFR", n=5, direction="down")
                 [('HSPD1', -0.2310), ('MYBL2', -0.2273), ('RRM2', -0.2253), ('TYMS', -0.2236), ('CDK1', -0.2164)]
m.compare("TP53") a dict with one entry per system
```

Each value is the predicted change of the mean expression of that gene when the target is knocked down
(negative: decreased). Rows of `res.values` are the genes you asked for, columns the output genes of the chosen
system. The first call downloads the 5.9 MB model once (SHA-256 checked) and reuses the cached file.

## Documentation

[Usage guide](https://github.com/DaikiKumakura/superslim/blob/main/README-GUIDE.md) · [R interface](r/README.md)

## Validation and limitations

- **Validation:** Evaluated held-out targets, ablations, runtime and same-split comparisons with a SLIM-style baseline.
- **Results:** The benchmarks report accuracy and runtime by system and test that the implementation reproduces the reference calculation.
- **Limitations:** Predictions are limited to the systems in the model file; treat untested targets as hypotheses.
- **Reproduction:** [docs/BENCHMARKS.md](https://github.com/DaikiKumakura/superslim/blob/main/docs/BENCHMARKS.md).

## Citation

Kumakura, D. (2026). *SuperSLIM: a compact NumPy-only predictor of transcriptome responses to gene perturbations* [Software]. [DOI: 10.5281/zenodo.24393778](https://doi.org/10.5281/zenodo.24393778).

Citation metadata: [CITATION.cff](CITATION.cff).

Also cite SLIM if you use its design. See the [Japanese README](README_JA.md).

## License

This project is licensed under MIT. See [LICENSE](LICENSE) for the license terms.

The model files, attached to the releases and documented in [`models/`](https://github.com/DaikiKumakura/superslim/tree/main/models), are licensed under CC BY-NC-SA 4.0. See [data license notes](docs/DATA_LICENSES.md).
