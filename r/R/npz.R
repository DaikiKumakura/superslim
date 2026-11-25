# Reader for NumPy .npz archives (zip of .npy arrays). Only the dtypes used by SuperSLIM model files are supported.
# The archive is opened with the 'archive' package because SuperSLIM model files use LZMA compression, which base R cannot read.

npy_half <- function(h) {
  s <- ifelse(bitwAnd(h, 0x8000L) != 0L, -1, 1)
  e <- bitwAnd(bitwShiftR(h, 10L), 0x1fL)
  m <- bitwAnd(h, 0x3ffL)
  v <- ifelse(e == 0L, m * 2^-24, ifelse(e == 31L, ifelse(m == 0L, Inf, NaN), (1 + m / 1024) * 2^(e - 15)))
  s * v
}

npy_parse <- function(b, name = "array") {
  if (length(b) < 12L || !identical(b[1:6], as.raw(c(0x93, 0x4e, 0x55, 0x4d, 0x50, 0x59)))) {
    stop("'", name, "' is not a .npy array.", call. = FALSE)
  }
  major <- as.integer(b[7])
  if (major == 1L) {
    hl <- as.integer(b[9]) + 256L * as.integer(b[10]); start <- 10L
  } else {
    hl <- sum(as.integer(b[9:12]) * 256^(0:3)); start <- 12L
  }
  hdr <- rawToChar(b[(start + 1L):(start + hl)])
  descr <- sub(".*'descr':\\s*'([^']+)'.*", "\\1", hdr)
  fortran <- grepl("'fortran_order':\\s*True", hdr)
  if (fortran) stop("Fortran-ordered arrays are not supported.", call. = FALSE)
  shp <- sub(".*'shape':\\s*\\(([^)]*)\\).*", "\\1", hdr)
  dims <- as.integer(strsplit(gsub("\\s", "", shp), ",")[[1]])
  dims <- dims[!is.na(dims)]
  n <- if (length(dims)) prod(dims) else 1L
  d <- b[(start + hl + 1L):length(b)]
  if (grepl("^<U", descr)) {
    w <- as.integer(sub("^<U", "", descr))
    cp <- readBin(d, "integer", n * w, size = 4L, endian = "little")
    return(vapply(seq_len(n), function(i) {
      x <- cp[((i - 1L) * w + 1L):(i * w)]; intToUtf8(x[x != 0L])
    }, character(1)))
  }
  v <- switch(descr,
    "<f4" = readBin(d, "numeric", n, size = 4L, endian = "little"),
    "<f8" = readBin(d, "numeric", n, size = 8L, endian = "little"),
    "<f2" = npy_half(readBin(d, "integer", n, size = 2L, signed = FALSE, endian = "little")),
    "|i1" = readBin(d, "integer", n, size = 1L, signed = TRUE),
    "|u1" = readBin(d, "integer", n, size = 1L, signed = FALSE),
    "<i2" = readBin(d, "integer", n, size = 2L, signed = TRUE, endian = "little"),
    "<i4" = readBin(d, "integer", n, size = 4L, signed = TRUE, endian = "little"),
    "|b1" = as.logical(as.integer(d[seq_len(n)])),
    stop("Unsupported array type '", descr, "' in '", name, "'.", call. = FALSE))
  if (length(dims) == 2L) v <- t(matrix(v, nrow = dims[2], ncol = dims[1]))
  v
}

#' Read a NumPy .npz archive
#'
#' Reads every array of an '.npz' file into a named list. Supported types are the ones used by SuperSLIM model files
#' (float16/32/64, int8/16/32, uint8, bool and fixed-length unicode strings; up to two dimensions).
#'
#' @param path Path to an '.npz' file.
#' @return A named list of arrays (vectors, or matrices for two-dimensional arrays); names are the entry names without '.npy'.
#' @examples
#' \dontrun{
#' z <- read_npz("superslim_open_v3.npz")
#' names(z)[1:5]
#' }
#' @export
read_npz <- function(path) {
  if (!file.exists(path)) stop("File not found: ", path, call. = FALSE)
  ents <- archive::archive(path)$path
  out <- vector("list", length(ents))
  for (i in seq_along(ents)) {
    con <- archive::archive_read(path, file = ents[i], mode = "rb")
    b <- readBin(con, "raw", n = 2^28)
    close(con)
    out[[i]] <- npy_parse(b, ents[i])
  }
  names(out) <- sub("\\.npy$", "", ents)
  out
}
