# Attribution and terms

The model file is a derivative of the data below. Terms were checked on 2026-11-20 (KOLF2.1J: 2026-11-23; RPE1, Jurkat, HepG2: 2026-11-27). The model file is distributed under **CC BY-NC-SA 4.0** because one input (X-Atlas/Orion) carries that licence; changes made: aggregation of single-cell data to per-gene mean responses, compression into a low-rank model with a small neural network, quantization.

| Source | Used for | Licence and obligation |
|---|---|---|
| **Replogle et al. 2022**, genome-wide K562 Perturb-seq (Zenodo record 13350497) | `k562_gwps` system, response codes | CC BY 4.0 — credit the authors; cite *Mapping information-rich genotype-phenotype landscapes with genome-scale Perturb-seq*, Cell 2022 |
| **X-Atlas/Orion** (Xaira Therapeutics), HCT116 and HEK293T, Hugging Face `Xaira-Therapeutics/X-Atlas-Orion` | `hct116` and `hek293t` systems, response codes | **CC BY-NC-SA 4.0** — non-commercial, share-alike; cite Huang et al., *X-Atlas/Orion: Genome-wide Perturb-seq Datasets via a Scalable Fix-Cryopreserve Platform for Training Dose-Dependent Biological Foundation Models*, bioRxiv 2025 (10.1101/2025.06.11.659105) |
| **Genome-scale CRISPRi map in human pluripotent stem cell lines** (Cell Genomics 2026; figshare 26819743) | response codes only (not a predicted system) | MIT |
| **Replogle et al. 2022**, RPE1 essential-gene Perturb-seq (scPerturb, Zenodo 13350497; also figshare+ 20029387) | `rpe1_essential` system | CC BY 4.0 — credit the authors; cite the Cell 2022 paper above |
| **Nadig et al.**, Jurkat and HepG2 essential-gene Perturb-seq (as redistributed in scPerturb, Zenodo 13350497; original deposit GEO GSE264667) | `jurkat_essential` and `hepg2_essential` systems | CC BY 4.0 as stated for the scPerturb record (the original GEO deposit states no separate licence) — credit the authors (Nadig, O'Connor et al., *Transcriptome-wide analysis of differential expression in perturbation atlases*, Nature Genetics 2025) and scPerturb (Peidli et al., Nature Methods 2024) |
| **KOLF2.1J iPSC CRISPRi perturbation atlas** (Nourreddine, Doctor et al.; figshare+ 10.25452/figshare.plus.27261219; file `KOLF_Strong_Perturbations.h5ad`) | `kolf2_strong` system | CC BY 4.0 — credit the authors; cite *A genome-scale CRISPRi perturbation atlas of human induced pluripotent stem cells*, Nature Biotechnology 2026 (10.1038/s41587-026-03199-w) |
| **Primary human CD4+ T-cell Perturb-seq** (Marson and Pritchard laboratories; CZ Virtual Cell Models) | `cd4_*` systems, response codes | MIT with the provider's use terms (no discriminatory or biased analyses) |
| **STRING** protein-network embeddings (as distributed with SLIM, RasmussenLab/SLIM, MIT) | gene features | STRING: CC BY 4.0; SLIM repository: MIT; cite Hu et al., *SLIM: A small linear model with STRING embeddings for single-cell genetic perturbation prediction*, bioRxiv 2026 (10.64898/2026.08.07.743481) |
| **ESM-2** protein language model embeddings (Lin et al., Science 2023) | gene features | MIT |
| **Reactome** pathways | gene features | CC0 |
| **Gene Ontology** | gene features | CC BY 4.0 |

Not used: Kaden et al. RPE1 data, A549 (GSE345058), H1 (Arc), Pan et al. H1 pseudo-bulk, the K562 essential-gene screen, and the original GEO deposit of the HepG2 and Jurkat data (GSE264667; the model uses the scPerturb redistribution listed above instead) — their terms are unverified or absent. `provenance.json` lists each input file with its SHA-256.

## Sharing

You may share and adapt the model file for non-commercial purposes if you give appropriate credit (this repository, the package, and the sources above), indicate changes, and license your derivative under CC BY-NC-SA 4.0. The licence text is in `LICENSE`.
