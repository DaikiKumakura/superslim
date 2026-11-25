"""Download released model files. Nothing is downloaded unless ``download_model`` is called; every file is checked against a SHA-256 value before it is accepted."""
from __future__ import annotations

import hashlib
import os
import shutil
import tempfile
import urllib.request
from pathlib import Path
from typing import Dict, Optional

MODELS: Dict[str, Dict[str, object]] = {
    "open-v2": {
        "url": "https://github.com/DaikiKumakura/superslim-models/releases/download/v2.0.0/superslim_open_v2.npz",
        "sha256": "88dd09321133f4a562b29ae1b631dd63d0f9d5e5bb39a85d3f2361af5f924321",
        "filename": "superslim_open_v2.npz",
        "bytes": 4180253,
        "license": "CC BY-NC-SA 4.0 (non-commercial); see https://github.com/DaikiKumakura/superslim-models",
    },
    "open-v3": {
        "url": "https://github.com/DaikiKumakura/superslim-models/releases/download/v3.0.0/superslim_open_v3.npz",
        "sha256": "a3bf0c575eef4d93d97c58e71b49b296195c25890ee1795236751aed8353c098",
        "filename": "superslim_open_v3.npz",
        "bytes": 4725210,
        "license": "CC BY-NC-SA 4.0 (non-commercial); see https://github.com/DaikiKumakura/superslim-models",
    }
}


def default_dir() -> Path:
    return Path(os.environ.get("SUPERSLIM_HOME", Path.home() / ".cache" / "superslim"))


def _sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for block in iter(lambda: f.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def download_model(name: str = "open-v3", dest: Optional[str] = None, force: bool = False) -> Path:
    """Download a released model file (default: the open-data model) and return its path. The file is verified against its SHA-256."""
    if name not in MODELS:
        raise ValueError(f"Unknown model '{name}'. Available: {', '.join(MODELS)}")
    spec = MODELS[name]
    folder = Path(dest) if dest else default_dir()
    folder.mkdir(parents=True, exist_ok=True)
    target = folder / str(spec["filename"])
    if target.exists() and not force and _sha256(target) == spec["sha256"]:
        return target
    with tempfile.NamedTemporaryFile(delete=False, dir=folder, suffix=".part") as tmp:
        tmp_path = Path(tmp.name)
        with urllib.request.urlopen(str(spec["url"])) as r:  # noqa: S310 (fixed https URL, or file:// in tests)
            shutil.copyfileobj(r, tmp)
    if _sha256(tmp_path) != spec["sha256"]:
        tmp_path.unlink()
        raise RuntimeError("Downloaded file does not match the expected SHA-256; it was discarded.")
    tmp_path.replace(target)
    return target
