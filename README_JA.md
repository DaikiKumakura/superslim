# SuperSLIM

学習済みの細胞系で、**遺伝子をノックダウンしたときの平均的な転写応答**を予測する、小さなNumPyだけのパッケージです。モデルのファイルは約4 MB。ノートパソコンのCPUで、読み込みは約0.3秒、1遺伝子の予測は約0.3〜0.9ミリ秒（出力遺伝子の数による）、メモリは約120 MBです。推論にGPU・PyTorch・scikit-learnは要りません。

[SLIM](https://github.com/RasmussenLab/SLIM)（Rasmussen Lab、MIT）から出発した軽量版です。SLIMの考え方（遺伝子の知識から応答への低ランクの写像）を保ちつつ、(1) STRINGに加えてカタログ特徴（STRING・ESM-2・Reactome・GO）を使い、(2) **同じ遺伝子の他の系での応答を入力にし**、(3) 24次元の潜在応答を、線形（ridge）と小さなINT8のMLPの混合で予測します。**SLIMの作者とは無関係の独立したプロジェクトです。**

## インストールと使い方
```bash
pip install git+https://github.com/DaikiKumakura/superslim.git
superslim download        # モデルのファイルを取得（SHA-256を検証）
```

Rからも同じ予測が使えます（基本のRのみ。パッケージはこのリポジトリの [`r/`](r/) フォルダにあり、版番号はPython版と同じ）。

```r
pak::pak("DaikiKumakura/superslim/r")
library(superslim); m <- ss_load(ss_download("open-v3")); ss_predict(m, c("TP53", "EGFR"), "cd4_rest")
```
```python
from superslim import SuperSLIM, download_model
m = SuperSLIM.load(download_model("open-v3"))
res = m.predict(["TP53", "EGFR"], line="cd4_rest")
```
```bash
superslim predict --model ~/.cache/superslim/superslim_open_v3.npz --line cd4_rest --gene TP53 --out out.csv
```

## モデルのファイル
[`superslim-models`](https://github.com/DaikiKumakura/superslim-models)（[DOI 10.5281/zenodo.24395561](https://doi.org/10.5281/zenodo.24395561)）の `superslim_open_v3.npz`：K562（ゲノム規模）、HCT116、HEK293T、初代CD4+ T細胞（安静・8時間・48時間刺激）、KOLF2.1J iPSC（強い応答の標的のみ）。利用条件を確認したデータだけで学習し、**CC BY-NC-SA 4.0（非商用）**で共有しています。**モデルのファイルにある系だけが予測でき、未知の細胞系・状態の予測はできません。** 保留した遺伝子での検証と限界はモデルカードにあります。

## 性能と根拠
[docs/BENCHMARKS.md](docs/BENCHMARKS.md)（保留した遺伝子での精度、アブレーション、学習曲線、被覆別の精度、SLIM型との同一分割での比較、実行時間、正しさの確認）。学習標的でない遺伝子の予測は仮説として使ってください。

## ライセンス

本プロジェクトはMITライセンスで配布します。条件は [LICENSE](LICENSE) を参照してください。別配布のモデルはCC BY-NC-SA 4.0です。

## 引用

引用は [CITATION.cff](CITATION.cff) を参照してください。SLIMの考え方を使う場合はSLIMも引用してください。
