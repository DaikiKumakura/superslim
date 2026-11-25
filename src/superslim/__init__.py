"""SuperSLIM: a compact, NumPy-only predictor of mean transcriptome responses to gene perturbations in learned cell systems."""
from .hub import MODELS, download_model
from .model import Prediction, SuperSLIM

__all__ = ["SuperSLIM", "Prediction", "download_model", "MODELS"]
__version__ = "0.6.0"
