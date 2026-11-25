# SuperSLIM

[![tests](https://github.com/DaikiKumakura/superslim/actions/workflows/ci.yml/badge.svg)](https://github.com/DaikiKumakura/superslim/actions/workflows/ci.yml) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.24393778.svg)](https://doi.org/10.5281/zenodo.24393778)

A small, NumPy-only predictor of the **mean transcriptome response to knocking down a gene** in a fixed set of learned cell systems. The model file is about 4 MB; on a laptop CPU it loads in about 0.3 s, predicts one gene in about 1 ms, and needs about 110 MB of memory. No GPU, no PyTorch, no scikit-learn at inference time.

## Installation

```bash
pip install git+https://github.com/DaikiKumakura/superslim.git   # Python >= 3.9, NumPy only
superslim download                                                  # fetches the model file (SHA-256 checked) into ~/.cache/superslim
```

## Quick start

```python
from superslim import SuperSLIM, download_model

m = SuperSLIM.load(download_model("open-v3"))   # or SuperSLIM.load("path/to/model.npz")
m.info()                                         # systems, input genes, output genes per system
res = m.predict(["TP53", "EGFR"], line="cd4_rest")
res.values.shape                                 # (2, number of output genes)
res.top("EGFR", n=10, direction="down")          # most strongly decreased genes
m.compare("TP53")                                # the same gene in every system (each in its own output genes and units)
```

## Documentation

[Usage guide](https://github.com/DaikiKumakura/superslim/blob/main/README-GUIDE.md)

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

The separately distributed [model files](https://github.com/DaikiKumakura/superslim-models) are licensed under CC BY-NC-SA 4.0. See [data license notes](docs/DATA_LICENSES.md).
