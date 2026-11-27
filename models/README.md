# SuperSLIM models

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.24395561.svg)](https://doi.org/10.5281/zenodo.24395561)

Trained model files for the SuperSLIM package. This directory holds the documentation (model card, attribution, provenance, evaluation, licence); **the model files themselves are attached to the [GitHub releases](https://github.com/DaikiKumakura/superslim/releases) of this repository and are not stored in the repository tree.** Every model was trained **only on data whose terms were verified**; the inputs and their terms are listed in [`provenance.json`](provenance.json) and [`ATTRIBUTION.md`](ATTRIBUTION.md).

| File | Systems | Size | Licence |
|---|---|---|---|
| `superslim_open_v4.npz` | K562 (genome-wide), HCT116, HEK293T, primary CD4+ T cells (rest, 8 h and 48 h stimulation), KOLF2.1J iPSC (strong-effect targets), RPE1, Jurkat and HepG2 (essential genes) | 5,891,974 bytes | **CC BY-NC-SA 4.0** (non-commercial, share-alike) |

Earlier models stay available as release attachments: `superslim_open_v3.npz` (4,725,210 bytes, SHA-256 `a3bf0c575eef4d93d97c58e71b49b296195c25890ee1795236751aed8353c098`) and `superslim_open_v2.npz` (4,180,253 bytes, SHA-256 `88dd09321133f4a562b29ae1b631dd63d0f9d5e5bb39a85d3f2361af5f924321`). Current model SHA-256: `f2daaaf286ca93aa7b2f9e48264f3aa245a82f08c6d813e34be1e773ab761b92`; all three are in `SHA256SUMS.txt`.

<a id="use"></a>

## Quick start

```bash
pip install git+https://github.com/DaikiKumakura/superslim.git   # version 0.8.0 or newer
# then download and check the model (SHA-256) with the package:
#   python -c "import superslim; print(superslim.download_model('open-v4'))"
```

```python
from superslim import SuperSLIM
m = SuperSLIM.load("superslim_open_v4.npz")
m.lines                                     # ['k562_gwps', 'hct116', 'hek293t', 'cd4_rest', 'cd4_stim8hr', 'cd4_stim48hr', 'kolf2_strong', 'rpe1_essential', 'jurkat_essential', 'hepg2_essential']
res = m.predict(["TP53", "EGFR"], line="cd4_rest")
```

## Documentation

[Model card](MODEL_CARD.md) · [Attribution](ATTRIBUTION.md) · [Python package](https://github.com/DaikiKumakura/superslim)

<a id="what-the-model-can-and-cannot-do"></a>

## Validation and limitations

See [`MODEL_CARD.md`](MODEL_CARD.md). In short: it predicts the mean transcriptome response to knocking down a gene in the ten listed systems only (no unseen cell lines), with small to moderate target-specific accuracy for the genome-wide systems and larger accuracy for the CD4+ T-cell systems. Treat predictions for genes not in the training set as hypotheses.

<a id="cite"></a>

## Citation

Kumakura, D. (2026). *SuperSLIM models: trained model files built from data with verified terms* [Software model files]. [DOI: 10.5281/zenodo.24395561](https://doi.org/10.5281/zenodo.24395561).

Citation metadata of the model archive: [CITATION.cff](CITATION.cff) (the archive was previously published as the separate repository `superslim-models`, now part of this repository).

Also cite the [SuperSLIM package](https://github.com/DaikiKumakura/superslim#citation) and the data sources in [ATTRIBUTION.md](ATTRIBUTION.md).

## License

This project is licensed under CC BY-NC-SA 4.0. See [LICENSE](LICENSE) for the license terms.

The model file is a derivative of the X-Atlas/Orion data (CC BY-NC-SA 4.0), so the whole file is shared under **CC BY-NC-SA 4.0**: you may share and adapt it with attribution, **not for commercial use**, and derivatives must use the same licence. The primary CD4+ T-cell data carry additional use terms (no discriminatory or biased analyses). See [`ATTRIBUTION.md`](ATTRIBUTION.md). The code that reads the file is a separate package under the MIT licence.
