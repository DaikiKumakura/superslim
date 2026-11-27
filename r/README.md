# superslim (R)

<!-- badges: start -->
[![R-universe](https://daikikumakura.r-universe.dev/badges/superslim)](https://daikikumakura.r-universe.dev/superslim)
[![R-CMD-check](https://github.com/DaikiKumakura/superslim/actions/workflows/r-ci.yml/badge.svg)](https://github.com/DaikiKumakura/superslim/actions/workflows/r-ci.yml)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.24393778.svg)](https://doi.org/10.5281/zenodo.24393778)
<!-- badges: end -->

R interface to **SuperSLIM**: it predicts the mean change in gene expression after knocking down a gene, in the cell systems learned in a small pretrained model file. The inference is written in base R and returns the same values as the [Python package](https://github.com/DaikiKumakura/superslim) in the same repository (maximum difference below 1e-6 on the released model). SuperSLIM is a compact descendant of SLIM (RasmussenLab, MIT) and is not affiliated with the SLIM authors.

## Install

```r
# install.packages("pak")
pak::pak("DaikiKumakura/superslim/r")   # the R package lives in the r/ folder of the superslim repository
```

The only dependency is the CRAN package [archive](https://cran.r-project.org/package=archive) (it reads the LZMA-compressed model file; on Linux it needs the system library `libarchive`).

## Use

```r
library(superslim)
path <- ss_download("open-v4")      # downloads once (5.9 MB), checks the SHA-256
m <- ss_load(path)                  # about 2 seconds
ss_lines(m)                         # k562_gwps, hct116, hek293t, cd4_rest, cd4_stim8hr, cd4_stim48hr, kolf2_strong, rpe1_essential, jurkat_essential, hepg2_essential

p <- ss_predict(m, c("TP53", "EGFR"), line = "cd4_rest")
ss_top(p, "EGFR", n = 10)           # most strongly decreased genes
ss_compare(m, "TP53")               # the same gene in every system (each in its own output genes and units)
```

`p$values` is a matrix with one row per gene and one column per output gene. Nothing is downloaded unless `ss_download()` is called; the file is cached in `tools::R_user_dir("superslim", "cache")` (or the folder in the environment variable `SUPERSLIM_HOME`).

A step-by-step walk through, with the output of every call and how to read it: [the tutorial](https://daikikumakura.github.io/superslim/articles/tutorial.html).

## The model files

The model files (documented in [`models/`](https://github.com/DaikiKumakura/superslim/tree/main/models), archived as [DOI 10.5281/zenodo.24395561](https://doi.org/10.5281/zenodo.24395561); attached to the releases) were trained only on data with verified terms and shared under **CC BY-NC-SA 4.0** (non-commercial). **Only the systems in a model file are predicted; there is no transfer to unseen cell lines or states.** Predictions for genes that were training targets are fitted values, and predictions for genes never measured are hypotheses. The model card lists the validation on held-out genes and the limits.

## Tests

`devtools::test()` runs a synthetic model whose golden values come from the Python package; CI regenerates them from the Python code of the same commit (`tools/make_fixtures.py`). `R CMD check` passes without errors or warnings. Setting `SUPERSLIM_MODEL` to a downloaded model file also enables a comparison on the real model.

## Cite and licence

Cite the model archive (Zenodo concept DOI 10.5281/zenodo.24395561) and the SuperSLIM software, which includes this R package (10.5281/zenodo.24393778; see [CITATION.cff](../CITATION.cff)); if you use the design, also cite [SLIM](https://github.com/RasmussenLab/SLIM) (Hu et al., bioRxiv 2026, 10.64898/2026.08.07.743481). Code: MIT. Model files: CC BY-NC-SA 4.0.
