ss_registry <- list(
  "open-v2" = list(
    url = "https://github.com/DaikiKumakura/superslim-models/releases/download/v2.0.0/superslim_open_v2.npz",
    sha256 = "88dd09321133f4a562b29ae1b631dd63d0f9d5e5bb39a85d3f2361af5f924321",
    filename = "superslim_open_v2.npz", bytes = 4180253),
  "open-v3" = list(
    url = "https://github.com/DaikiKumakura/superslim-models/releases/download/v3.0.0/superslim_open_v3.npz",
    sha256 = "a3bf0c575eef4d93d97c58e71b49b296195c25890ee1795236751aed8353c098",
    filename = "superslim_open_v3.npz", bytes = 4725210)
)

file_sha256 <- function(path) {
  if (exists("sha256sum", envir = asNamespace("tools"), inherits = FALSE)) {
    unname(get("sha256sum", envir = asNamespace("tools"))(path))
  } else if (requireNamespace("digest", quietly = TRUE)) {
    digest::digest(file = path, algo = "sha256")
  } else {
    stop("Computing SHA-256 needs R >= 4.5.0 or the 'digest' package.", call. = FALSE)
  }
}

#' Released model files
#'
#' @return A data frame of the model files that [ss_download()] knows: name, size, SHA-256 and URL.
#' @export
ss_models <- function() {
  data.frame(name = names(ss_registry), bytes = vapply(ss_registry, function(x) x$bytes, numeric(1)),
             sha256 = vapply(ss_registry, function(x) x$sha256, character(1)),
             url = vapply(ss_registry, function(x) x$url, character(1)), row.names = NULL, stringsAsFactors = FALSE)
}

#' Download a released model file
#'
#' Downloads a model file from the 'superslim-models' releases and checks its SHA-256. Nothing is downloaded unless this
#' function is called. Model files are licensed CC BY-NC-SA 4.0 (non-commercial, share-alike); see the model repository
#' for the terms of the training data.
#'
#' @param name A name from [ss_models()]. The default is the newest model.
#' @param dest Folder for the file. Default: the folder given by the environment variable `SUPERSLIM_HOME`, otherwise the user cache
#'   directory of this package.
#' @param force Download again even if a valid file exists.
#' @return The path of the verified file.
#' @examples
#' \dontrun{
#' path <- ss_download("open-v3")
#' }
#' @export
ss_download <- function(name = "open-v3", dest = NULL, force = FALSE) {
  if (!name %in% names(ss_registry)) stop("Unknown model '", name, "'. Available: ", paste(names(ss_registry), collapse = ", "), call. = FALSE)
  spec <- ss_registry[[name]]
  if (is.null(dest)) {
    home <- Sys.getenv("SUPERSLIM_HOME", unset = "")
    dest <- if (nzchar(home)) home else tools::R_user_dir("superslim", "cache")
  }
  dir.create(dest, recursive = TRUE, showWarnings = FALSE)
  target <- file.path(dest, spec$filename)
  if (file.exists(target) && !force && identical(file_sha256(target), spec$sha256)) return(target)
  tmp <- tempfile(tmpdir = dest, fileext = ".part")
  on.exit(unlink(tmp), add = TRUE)
  old <- options(timeout = max(600, getOption("timeout")))
  on.exit(options(old), add = TRUE)
  utils::download.file(spec$url, tmp, mode = "wb", quiet = TRUE)
  if (!identical(file_sha256(tmp), spec$sha256)) stop("Checksum mismatch for '", name, "'; the file was not saved.", call. = FALSE)
  file.rename(tmp, target)
  target
}
