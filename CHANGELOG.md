# Changelog

## 0.6.0
- Default model is now `open-v3`: adds the KOLF2.1J iPSC system `kolf2_strong` (strong-effect targets only). The six earlier systems are unchanged. `open-v2` stays available.

## 0.5.0
- Default model is now `open-v2` (the K562 system is rebuilt directly from the genome-wide screen; signals change by at most 0.005). `open-v1` is no longer listed; the file stays available in the models release 1.0.1.

## 0.4.0
- First release: Python API (`SuperSLIM`, `Prediction`), command line (`superslim`), model download with a SHA-256 check (`download_model`, `superslim download`), runtime benchmark, benchmark document, and continuous integration on Linux, Windows and macOS.
