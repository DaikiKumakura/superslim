# SuperSLIM open v4 — model card

**Task.** Given a gene, predict the mean change in expression (log1p counts per 10,000; log1p CPM for `kolf2_strong`; log fold change for the hiPSC source) of every output gene after knocking it down, in one of ten learned systems. **Only these systems are predicted; there is no transfer to unseen cell lines or states.**

**File.** `superslim_open_v4.npz`, 5,891,974 bytes, format `superslim-open-v1`, read by SuperSLIM 0.8.0 or newer. NumPy only at inference.

## Training data (all terms verified; details in `provenance.json`)

| System | Data | Targets used | Output genes |
|---|---|---|---|
| `k562_gwps` | Replogle et al. 2022 genome-wide K562 CRISPRi (CC BY 4.0), rebuilt directly from the genome-wide screen | 9,174 | 8,248 |
| `hct116` | X-Atlas/Orion HCT116 (CC BY-NC-SA 4.0) | 12,519 | 14,685 |
| `hek293t` | X-Atlas/Orion HEK293T (CC BY-NC-SA 4.0) | 13,128 | 14,685 |
| `cd4_rest`, `cd4_stim8hr`, `cd4_stim48hr` | Primary human CD4+ T-cell Perturb-seq pseudo-bulk (MIT, use terms) | 10,484 / 10,549 / 10,523 | 6,089 |
| `kolf2_strong` | KOLF2.1J iPSC genome-scale CRISPRi atlas, "strong perturbations" file (CC BY 4.0) | 1,525 | 15,419 |
| `rpe1_essential` | Replogle et al. 2022 RPE1 CRISPRi, essential-gene screen (CC BY 4.0) | 2,012 | 8,749 |
| `jurkat_essential` | Nadig et al. Jurkat CRISPRi, essential-gene screen (CC BY 4.0 as redistributed by scPerturb) | 2,134 | 8,882 |
| `hepg2_essential` | Nadig et al. HepG2 CRISPRi, essential-gene screen (CC BY 4.0 as redistributed by scPerturb) | 1,817 | 9,624 |

An additional candidate, hiPSC (MIT), failed the pre-set accuracy gate as a predicted system (signal 0.049, lower bound 0.044 < 0.05). Its responses are used as an input feature source. Gene features: STRING embeddings, ESM-2, Reactome, Gene Ontology; no response data.

## Design

Per system: a median base vector, a 24-dimensional INT8 basis, and a latent response predicted by a ridge-linear map mixed with a small INT8 MLP, from gene features and the same gene's responses in the other systems (32-dimensional codes from each source). Output is floored so that expression cannot go below zero where a baseline exists (not for hiPSC); the perturbed gene itself is set to a constant (the median own-gene change in training).

## Validation (held-out genes, one evaluation per system)

Targets were split by a hash of the gene name (about 20% held out); settings were chosen by 5-fold cross-validation inside the development targets only. Intervals are 95% bootstrap intervals over held-out targets. The released model is retrained on all targets, so these numbers describe the design on held-out genes, not the released fit.

| System | Held-out targets | Target-specific signal | Error vs predicting zero | Error vs median response | Gate |
|---|---|---|---|---|---|
| `k562_gwps` | 1,778 | 0.168 (0.158-0.177) | -2.72% (2.26 to 3.20) | -2.41% (1.96 to 2.87) | passed |
| `hct116` | 2,430 | 0.086 (0.078-0.094) | -1.03% (0.77 to 1.30) | -0.86% (0.60 to 1.13) | passed |
| `hek293t` | 2,542 | 0.104 (0.091-0.117) | -1.13% (0.93 to 1.34) | -0.97% (0.78 to 1.17) | passed |
| `cd4_rest` | 2,031 | 0.548 (0.539-0.557) | -17.47% (16.81 to 18.13) | -16.84% (16.18 to 17.51) | passed |
| `cd4_stim8hr` | 2,038 | 0.555 (0.547-0.562) | -16.79% (16.30 to 17.29) | -16.32% (15.81 to 16.85) | passed |
| `cd4_stim48hr` | 2,035 | 0.521 (0.513-0.530) | -14.81% (14.23 to 15.38) | -14.44% (13.87 to 15.02) | passed |
| `kolf2_strong` | 287 | 0.201 (0.172-0.228) | -12.75% (11.70 to 13.85) | -2.04% (1.47 to 2.61) | passed |
| `rpe1_essential` | 378 | 0.481 (0.444-0.515) | -21.10% (18.63 to 23.41) | -13.27% (10.94 to 15.53) | passed |
| `jurkat_essential` | 396 | 0.369 (0.344-0.393) | -10.73% (9.19 to 12.29) | -8.06% (6.79 to 9.37) | passed |
| `hepg2_essential` | 330 | 0.420 (0.389-0.451) | -15.41% (12.78 to 17.95) | -12.21% (9.91 to 14.45) | passed |
| `hipsc` | 1,221 | 0.049 (0.044-0.055) | -0.41% | -0.18% | not passed |

"Target-specific signal" is the correlation between the predicted and observed response after subtracting each gene's mean over targets, excluding the perturbed gene. "Error" is the mean absolute error over output genes (a reduction is better). The genome-wide systems include many genes with little effect, so their numbers are small by nature; in the CD4+ T-cell data the responses are larger relative to the noise, so the same design reaches a much higher signal.

**`kolf2_strong` covers strong-effect targets only.** The source file keeps only perturbations whose cells differ significantly from non-targeting cells, so the system predicts responses of genes that, when knocked down in iPSCs, have a clear effect; its numbers are not comparable with the genome-wide systems, and its predictions for genes with weak effects are not meaningful. It is a predicted system only: it is not used as an input source for the other systems, whose files are identical to the previous model version.

**The three `*_essential` systems cover essential genes only** (about 2,400 targeted genes per screen), so they predict responses of essential genes; their numbers are not comparable with the genome-wide systems. Like `kolf2_strong`, they are predicted systems only and are not used as input sources for the other systems, whose files are identical to the previous model version. Unit: log1p counts per 10,000.

**Read the CD4 numbers with care.** The three CD4 states come from the same experiment, so each state's prediction uses the same gene's measured response in the sibling states as input; the high signal applies to genes measured in a sibling state. Without the other systems' responses, the catalog features alone give a signal of about 0.03 for `cd4_rest`.

## Verification

The package output equals an independent NumPy re-implementation from the raw arrays (maximum absolute difference 0) and is bit-identical across repeated calls and fresh loads (`verification.json`).

## Limits

- Ten systems only. Unseen cell lines and states are not predicted.
- Predictions for genes that were training targets are fitted values, not accuracy estimates.
- For genes absent from a system's training data the model extrapolates from gene features and from the other systems. These predictions were not validated against an independent measurement platform; use them as hypotheses, not for decisions about drug targets.
- Responses of the HCT116 and HEK293T screens are small for most genes; use the signal values above to judge usefulness.
- Non-commercial use only (CC BY-NC-SA 4.0). Primary CD4+ T-cell data: do not use for discriminatory or biased analyses (the data provider's terms).
