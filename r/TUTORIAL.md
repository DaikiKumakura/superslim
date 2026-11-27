# Predict what happens when you knock down a gene

superslim answers one question: if I knock down gene X in cell system Y, which genes change in their mean
expression, and by how much? The answer comes from a small pretrained file, in base R, in a fraction of a second
per gene. This page loads the model, predicts, reads the result and compares systems. All output below comes from
running the code.

## 1. Get the model

```r
library(superslim)

ss_models()[, c("name", "bytes")]
```

```text
     name   bytes
1 open-v2 4180253
2 open-v3 4725210
```

```r
path <- ss_download("open-v3")   # downloads once (4.7 MB), checks the SHA-256, keeps it in a cache folder
m <- ss_load(path)               # about 2 seconds
```

Nothing is downloaded unless you call `ss_download()`. The file is cached under `tools::R_user_dir("superslim",
"cache")`, or in the folder named by the environment variable `SUPERSLIM_HOME`. The model files are under
CC BY-NC-SA 4.0 (non-commercial).

## 2. What the model covers

```r
ss_lines(m)
ss_info(m)$n_input_genes
ss_info(m)$n_output_genes
```

```text
[1] "k562_gwps"    "hct116"       "hek293t"      "cd4_rest"     "cd4_stim8hr"  "cd4_stim48hr" "kolf2_strong"

[1] 21688

   k562_gwps       hct116      hek293t     cd4_rest  cd4_stim8hr cd4_stim48hr kolf2_strong
        8248        14685        14685         6089         6089         6089        15419
```

- **Systems** (`ss_lines()`): the seven cell systems the model learned. Only these can be predicted; there is no
  transfer to an unseen cell line.
- **Input genes**: the 21,688 genes you can knock down. `ss_genes(m)` lists them.
- **Output genes**: each system has its own set (6,089 to 15,419 genes), the genes measured in that system.
  `ss_output_genes(m, "cd4_rest")` lists one set.

## 3. Predict

```r
p <- ss_predict(m, c("TP53", "EGFR"), line = "cd4_rest")
dim(p$values)
rownames(p$values)
```

```text
[1]    2 6089
[1] "TP53" "EGFR"
```

`p$values` is a matrix: one row per gene you knocked down, one column per output gene of the system. Each value is
the predicted change of that gene's mean expression compared with control cells, in the unit of the system
(log1p counts per 10,000 for most). Negative means decreased.

## 4. Read the result

```r
ss_top(p, "EGFR", n = 5)                      # most strongly decreased
ss_top(p, "EGFR", n = 5, direction = "up")    # most strongly increased
```

```text
   gene     change
1 HSPD1 -0.2310338
2 MYBL2 -0.2273387
3  RRM2 -0.2253257
4  TYMS -0.2236101
5  CDK1 -0.2164383

    gene    change
1   BTG1 0.1977898
2  ZMAT3 0.1752418
3  PNRC1 0.1670675
4   MCL1 0.1594691
5 SQSTM1 0.1515023
```

`ss_top()` sorts one row of the matrix. The decreased genes after EGFR knockdown in resting CD4 T cells include
proliferation genes (`MYBL2`, `RRM2`, `TYMS`, `CDK1`). This is a prediction to be tested, not a measurement.

## 5. The same gene in every system

Effects depend on the system. `ss_compare()` predicts one gene in all seven, each in its own output genes:

```r
cmp <- ss_compare(m, "TP53")
names(cmp)
sapply(cmp, function(x) length(x$values))
```

```text
[1] "k562_gwps"    "hct116"       "hek293t"      "cd4_rest"     "cd4_stim8hr"  "cd4_stim48hr" "kolf2_strong"

   k562_gwps       hct116      hek293t     cd4_rest  cd4_stim8hr cd4_stim48hr kolf2_strong
        8248        14685        14685         6089         6089         6089        15419
```

Each element is the prediction for that system (`line`, `genes`, `output_genes`, `values`). Compare the size of
the effect in two systems:

```r
ss_top(ss_predict(m, "TP53", "cd4_rest"),  "TP53", n = 3)
ss_top(ss_predict(m, "TP53", "k562_gwps"), "TP53", n = 3)
```

```text
   gene     change
1 PNRC1 -0.1814438
2 ZMAT3 -0.1264590
3 IFITM2 -0.1215466

  gene       change
1  HBZ -0.024674641
2 APOE -0.013091872
3 HBG2 -0.011763864
```

In resting CD4 T cells the strongest predicted change is −0.18, with `PNRC1` and `ZMAT3` (genes usually
described as p53 targets) at the top. In K562 every predicted change of the TP53 knockdown lies between −0.025
and 0.014. The model reports what it learned for each system; do not carry a gene list from one system to
another without a reason. The units can differ between systems too.

How much two systems agree on a gene is a question you can ask with ordinary R:

```r
a <- ss_top(ss_predict(m, "EGFR", "k562_gwps"), "EGFR", n = 200)$gene
b <- ss_top(ss_predict(m, "EGFR", "hct116"),    "EGFR", n = 200)$gene
length(intersect(a, b))
head(intersect(a, b), 8)
```

```text
[1] 67
[1] "HSPE1"   "RANBP1"  "CACYBP"  "HMGB1"   "EIF5A"   "CYCS"    "ATP5MC3" "HSPD1"
```

Of the 200 most decreased genes after EGFR knockdown, 67 are the same in K562 and HCT116.

## 6. Errors tell you what to change

```r
ss_predict(m, "NOTAGENE", "cd4_rest")
ss_predict(m, "TP53", "nosuchline")
```

```text
Unsupported input gene (no feature row): NOTAGENE
Unknown system 'nosuchline'. Available: k562_gwps, hct116, hek293t, cd4_rest, cd4_stim8hr, cd4_stim48hr, kolf2_strong
```

## 7. What to remember

- Predictions are for the systems in the model file only.
- A gene that was a training target gets a fitted value; a gene never measured gets a hypothesis. Treat both as
  starting points for an experiment.
- The R and Python packages return the same values (maximum difference below 1e-6 on the released model), so a
  result from one can be rechecked in the other.
- [Model card and validation](https://github.com/DaikiKumakura/superslim/tree/main/models) and
  [benchmarks](https://github.com/DaikiKumakura/superslim/blob/main/docs/BENCHMARKS.md).
