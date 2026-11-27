# SuperSLIM guide

[![tests](https://github.com/DaikiKumakura/superslim/actions/workflows/ci.yml/badge.svg)](https://github.com/DaikiKumakura/superslim/actions/workflows/ci.yml) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.24393778.svg)](https://doi.org/10.5281/zenodo.24393778)

A small, NumPy-only predictor of the **mean transcriptome response to knocking down a gene** in a fixed set of learned cell systems. The model file is about 4 MB; on a laptop CPU it loads in about 0.3 s, predicts one gene in about 0.3 to 0.9 ms (depending on the number of output genes), and needs about 120 MB of memory. No GPU, no PyTorch, no scikit-learn at inference time.

SuperSLIM is a compact descendant of [SLIM](https://github.com/RasmussenLab/SLIM) (Rasmussen Lab, MIT licence). It keeps SLIM's idea (a low-rank map from gene knowledge to responses) and changes three things: it adds catalog features (STRING, ESM-2, Reactome, GO) next to the STRING embedding, it uses **the responses of the same gene in the other systems** as input, and it predicts a 24-dimensional latent response with a ridge-linear map mixed with a small INT8 MLP. SuperSLIM is an independent project and is **not affiliated with the SLIM authors**.

<a id="install"></a>

## Installation

```bash
pip install git+https://github.com/DaikiKumakura/superslim.git   # Python >= 3.9, NumPy only
superslim download                                                  # fetches the model file (SHA-256 checked) into ~/.cache/superslim
```

<a id="use"></a>

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

```bash
superslim info    --model ~/.cache/superslim/superslim_open_v4.npz
superslim predict --model ~/.cache/superslim/superslim_open_v4.npz --line cd4_rest --gene TP53 --gene EGFR --out out.csv
```

Output unit: change of the mean expression versus control cells (log1p counts per 10,000 for most systems). Expression (control + change) is floored at zero, and the perturbed gene itself is set to a constant.

## Documentation

[Model files](#the-model-file) · [Benchmarks](docs/BENCHMARKS.md) · [日本語](README_JA.md)

## The model file

The model file `superslim_open_v4.npz` (attached to the releases; documented in [`models/`](https://github.com/DaikiKumakura/superslim/tree/main/models); archived as [DOI 10.5281/zenodo.24395561](https://doi.org/10.5281/zenodo.24395561)) covers K562 (genome-wide), HCT116, HEK293T, primary CD4+ T cells (rest, 8 h and 48 h stimulation) and KOLF2.1J iPSC (strong-effect targets) and RPE1, Jurkat and HepG2 (essential genes), trained only on data with verified terms and shared under **CC BY-NC-SA 4.0** (non-commercial). **Only the systems in a model file are predicted; there is no transfer to unseen cell lines or states.** Inputs are the 21,688 catalog genes. The model card there lists the validation on held-out genes and the limits.

R users: the base-R interface in [`r/`](r/README.md) gives the same predictions; CI checks it against golden values regenerated from the Python code of the same commit.

## Tests and benchmarks

```bash
pytest                                                 # synthetic model, no data needed
python benchmarks/bench_runtime.py --model model.npz   # load time, latency, throughput, memory, determinism
```

## Roadmap

- A PyPI release (the publishing workflow is prepared; it needs a PyPI account setting).
- More systems as further data with verified terms become available.

<a id="evidence"></a>

## Validation and limitations

[docs/BENCHMARKS.md](docs/BENCHMARKS.md) reports held-out accuracy, ablation, learning curve, coverage, a same-split comparison with a SLIM-style baseline, runtime and correctness. Treat predictions for genes that were not training targets as hypotheses.

## Citation

Kumakura, D. (2026). *SuperSLIM: a compact NumPy-only predictor of transcriptome responses to gene perturbations* [Software]. [DOI: 10.5281/zenodo.24393778](https://doi.org/10.5281/zenodo.24393778).

Citation metadata: [CITATION.cff](CITATION.cff).

Also cite SLIM if you use its design. See the [Japanese README](README_JA.md).

## License

This project is licensed under MIT. See [LICENSE](LICENSE) for the license terms.

The separately distributed [model files](https://github.com/DaikiKumakura/superslim/tree/main/models) are licensed under CC BY-NC-SA 4.0. See [data license notes](docs/DATA_LICENSES.md).
