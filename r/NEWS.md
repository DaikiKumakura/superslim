# superslim 0.8.0

* Default model is now `open-v4` (ten systems, adds `rpe1_essential`, `jurkat_essential`, `hepg2_essential`); `open-v2` and `open-v3` stay available. Version numbers follow the Python package.
* Model files are now downloaded from the releases of this repository; versions 0.7.0 and earlier pointed to the removed `superslim-models` repository and can no longer download models.

# superslim 0.7.0

* First release of the R interface, now developed in the same repository as the Python package (`r/`); version numbers follow the Python package.
* `ss_load()`, `ss_predict()`, `ss_top()`, `ss_compare()`, `ss_lines()`, `ss_genes()`, `ss_output_genes()`, `ss_info()`, `ss_download()` (SHA-256 checked), `ss_models()` and `read_npz()`.
* Reads SuperSLIM model files of format `superslim-open-v1`; default model `open-v3` (seven systems); `open-v2` stays available.
* Predictions equal the Python package (maximum difference 4e-7 on the released model); CI regenerates the golden values from the Python package.
