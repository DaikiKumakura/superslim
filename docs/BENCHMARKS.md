# Benchmarks

Everything here concerns the released model `superslim_open_v2.npz` (4,180,253 bytes; repository [`superslim-models`](https://github.com/DaikiKumakura/superslim-models)). Two quantities are reported per held-out target: **MAE** over output genes, and **target-specific signal**, the correlation of the predicted and observed response after subtracting each gene's mean over targets (excluding the perturbed gene itself). Intervals are 95% bootstrap intervals over targets. Training used only development targets; held-out targets (about 20%) were split by a hash of the gene name, and settings were chosen by cross-validation inside the development targets. The released model is retrained on all targets, so these numbers describe the design on held-out genes, not the released fit.

## 1. Held-out accuracy of every system

Gates were set in advance: signal lower bound above 0.05, and error below both predicting zero and predicting the median response.

| System | Held-out targets | Signal (95% CI) | Error vs predicting zero | Error vs median response |
|---|---|---|---|---|
| `k562_gwps` | 1,778 | 0.168 (0.158-0.177) | -2.72% | -2.41% |
| `hct116` | 2,430 | 0.086 (0.078-0.094) | -1.03% | -0.86% |
| `hek293t` | 2,542 | 0.104 (0.091-0.117) | -1.13% | -0.97% |
| `cd4_rest` | 2,031 | 0.548 (0.539-0.557) | -17.47% | -16.84% |
| `cd4_stim8hr` | 2,038 | 0.555 (0.547-0.562) | -16.79% | -16.32% |
| `cd4_stim48hr` | 2,035 | 0.521 (0.513-0.530) | -14.81% | -14.44% |

A seventh candidate (hiPSC) did not pass (signal 0.049, lower bound 0.044) and is not predicted. The median response carries no target-specific signal (0.00), so the signal is what the model adds. **Read the CD4 numbers with care:** the three CD4 states come from the same experiment, so each state's prediction uses the same gene's measured response in the sibling states as input; the numbers apply to genes that are measured in a sibling state (see section 4). The genome-wide systems contain many genes with little effect, so their signals are small by nature.


## 2. Comparison with a SLIM-style baseline

A STRING-embedding bilinear model (our re-implementation of SLIM's recipe) trained on the same development targets and evaluated on the same held-out targets.

| System | Held-out targets | MAE: SLIM-style / SuperSLIM | Signal: SLIM-style / SuperSLIM |
|---|---|---|---|
| `k562_gwps` | 1,778 | 0.02661 / 0.02587 | 0.065 / 0.168 |
| `hct116` | 2,430 | 0.01674 / 0.01656 | 0.024 / 0.086 |
| `cd4_rest` | 2,031 | 0.03108 / 0.02566 | 0.024 / 0.548 |

## 3. Ablation (signal, 95% CI)

| Input / head | `k562_gwps` | `hct116` | `cd4_rest` |
|---|---|---|---|
| Catalog features only (linear + MLP) | 0.138 (0.129-0.147) | 0.035 (0.027-0.044) | 0.026 (0.008-0.043) |
| + responses of the same gene in the other systems (linear only) | 0.144 (0.135-0.153) | 0.078 (0.071-0.085) | 0.539 (0.530-0.548) |
| + small MLP mixed in (released design) | 0.168 (0.158-0.177) | 0.086 (0.078-0.094) | 0.548 (0.539-0.557) |

The other systems' responses carry most of the signal for HCT116 and the CD4 states; for K562 the catalog features already give most of it, and the MLP adds the most there (+0.02).

## 4. Dependence on how many other systems measured the gene (signal, then error as a share of predicting zero)

| Other systems with the gene | `k562_gwps` | `hct116` | `cd4_rest` |
|---|---|---|---|
| 0 | 0.090, 0.96 (n=19, few) | -0.302, 1.04 (n=1, few) | none |
| 1 | 0.316, 0.90 (n=54) | 0.074, 0.99 (n=423) | none |
| 2 or more | 0.164, 0.98 (n=1,705) | 0.088, 0.99 (n=2,006) | 0.548, 0.83 (n=2,031) |

Almost every held-out gene was measured in several other systems, so this cannot say how the model does for a gene measured nowhere else.

## 5. Learning curve (signal)

| Training targets (share of development set) | `k562_gwps` | `hct116` | `cd4_rest` |
|---|---|---|---|
| 25% | 0.139 (n=1,849) | 0.076 (n=2,522) | 0.520 (n=2,113) |
| 50% | 0.157 (n=3,698) | 0.078 (n=5,044) | 0.539 (n=4,226) |
| 100% | 0.168 (n=7,396) | 0.086 (n=10,089) | 0.548 (n=8,453) |

The curve is still rising at 100% for the genome-wide systems.

## 6. Runtime

Windows 11, 12 logical CPUs, Python 3.12, NumPy 2.2, SuperSLIM 0.5.0.

| Quantity | Value |
|---|---|
| Model file | 4,180,253 bytes |
| Load (median of 5) | 281 ms |
| Peak memory, all systems used | 107 MB |
| Repeat calls and fresh load | bit-identical output, all values finite |

| System | Output genes | One gene (ms, median) | Genes per second (batch of 1,000) |
|---|---|---|---|
| `k562_gwps` | 8,248 | 0.32 | 17,171 |
| `hct116` | 14,685 | 0.78 | 11,824 |
| `hek293t` | 14,685 | 0.77 | 11,549 |
| `cd4_rest` | 6,089 | 0.29 | 22,342 |
| `cd4_stim8hr` | 6,089 | 0.29 | 20,638 |
| `cd4_stim48hr` | 6,089 | 0.29 | 20,217 |
Reproduce: `python benchmarks/bench_runtime.py --model model.npz`.

## 7. Correctness

- The package output equals an independent NumPy re-implementation written from the raw arrays (maximum absolute difference 0) for all six systems, and is bit-identical across repeated calls and fresh loads (`verification.json` in the model repository).
- Nine synthetic-model tests, including fixed expected values and the command line, run in CI on Linux, Windows and macOS for Python 3.9-3.13, and with the oldest supported NumPy (1.22).

## 8. Limits

- Only the systems in the model file are predicted; there is no transfer to unseen cell lines.
- Predictions for genes that were training targets are fitted values, not accuracy estimates.
- Predictions for genes a system never measured are extrapolations and were not validated against an independent measurement platform; treat them as hypotheses.
