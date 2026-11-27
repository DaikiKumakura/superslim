# Changelog

## 0.8.0
- Default model is now `open-v4`: adds three predicted systems from essential-gene Perturb-seq screens (`rpe1_essential`, `jurkat_essential`, `hepg2_essential`; essential genes only). The seven earlier systems are unchanged; `open-v2` and `open-v3` stay available. Python and R (`r/`) share the version number.
- The separate `superslim-models` repository is merged into this one: its documentation (model card, attribution, provenance, evaluation, licence) is in `models/`, and the model files (`open-v2`, `open-v3`, `open-v4`) are attached to the GitHub releases of this repository, so `download_model` now fetches from here. Versions 0.7.0 and earlier point to the removed `superslim-models` repository and can no longer download models; upgrade to 0.8.0. The archived model records (DOI 10.5281/zenodo.24395561) stay valid.

## 0.7.0
- Adds the R interface (`r/`, base R, same predictions as the Python package; `pak::pak("DaikiKumakura/superslim/r")`). Version numbers of the two packages are kept equal. CI runs the R checks with golden values regenerated from the Python code. No change to the Python API.

## 0.6.0
- Default model is now `open-v3`: adds the KOLF2.1J iPSC system `kolf2_strong` (strong-effect targets only). The six earlier systems are unchanged. `open-v2` stays available.

## 0.5.0
- Default model is now `open-v2` (the K562 system is rebuilt directly from the genome-wide screen; signals change by at most 0.005). `open-v1` is no longer listed; the file stays available in the models release 1.0.1.

## 0.4.0
- First release: Python API (`SuperSLIM`, `Prediction`), command line (`superslim`), model download with a SHA-256 check (`download_model`, `superslim download`), runtime benchmark, benchmark document, and continuous integration on Linux, Windows and macOS.
