CTRL_SCALE <- 1 / 4096

split_names <- function(blob) strsplit(rawToChar(as.raw(blob)), "\n", fixed = TRUE)[[1]]

unpack_q4 <- function(packed, scale, nrow, ncol) {
  hi <- bitwShiftR(packed, 4L) - 8L
  lo <- bitwAnd(packed, 15L) - 8L
  q <- integer(length(packed) * 2L)
  q[seq(1L, length(q), by = 2L)] <- hi
  q[seq(2L, length(q), by = 2L)] <- lo
  m <- t(matrix(q, nrow = ncol, ncol = nrow))
  sweep(m, 2L, scale, "*")
}

#' Load a SuperSLIM model file
#'
#' Reads a SuperSLIM model file ('.npz', format 'superslim-open-v1') into memory. A file holds one or more learned systems
#' (cell lines or conditions); each has a small head that predicts the mean transcriptome response to knocking down a gene.
#' Only the systems in the file can be predicted; there is no transfer to unseen cell lines.
#'
#' @param path Path to a model file, for example the result of [ss_download()].
#' @return An object of class `superslim_model`.
#' @examples
#' \dontrun{
#' m <- ss_load(ss_download("open-v4"))
#' m
#' }
#' @export
ss_load <- function(path) {
  z <- read_npz(path)
  if (is.null(z[["format"]]) || !startsWith(z[["format"]], "superslim-open")) {
    stop("Not a SuperSLIM model file (expected format 'superslim-open-v*').", call. = FALSE)
  }
  catalog <- split_names(z[["catalog_b"]])
  systems <- split_names(z[["systems_b"]])
  sources <- split_names(z[["sources_b"]])
  X <- unpack_q4(z[["x_q4"]], z[["x_scale4"]], length(catalog), as.integer(z[["x_dim"]]))
  cx <- lapply(stats::setNames(sources, sources), function(n) {
    list(idx = z[[paste0("cx/", n, "/idx")]],
         codes = sweep(z[[paste0("cx/", n, "/codes")]] * as.numeric(z[[paste0("cx/", n, "/scale")]]), 2L, z[[paste0("cx/", n, "/std")]], "/"))
  })
  out <- lapply(stats::setNames(systems, systems), function(n) split_names(z[[paste0("sys/", n, "/genes_b")]]))
  structure(list(z = z, catalog = catalog, X = X, systems = systems, sources = sources, cx = cx, output = out), class = "superslim_model")
}

#' @export
print.superslim_model <- function(x, ...) {
  cat("<superslim_model> ", length(x$systems), " systems (", paste(x$systems, collapse = ", "), "), ", length(x$catalog), " input genes\n", sep = "")
  invisible(x)
}

#' Systems, genes and summary of a model
#'
#' `ss_lines()` lists the learned systems, `ss_genes()` the input genes (catalog) that can be perturbed,
#' `ss_output_genes()` the genes predicted in one system, and `ss_info()` a summary.
#'
#' @param model A model from [ss_load()].
#' @param line A system name from `ss_lines(model)`.
#' @return A character vector (`ss_lines()`, `ss_genes()`, `ss_output_genes()`) or a list (`ss_info()`).
#' @name ss_info
NULL

#' @rdname ss_info
#' @export
ss_lines <- function(model) model$systems

#' @rdname ss_info
#' @export
ss_genes <- function(model) model$catalog

#' @rdname ss_info
#' @export
ss_output_genes <- function(model, line) {
  check_line(model, line)
  model$output[[line]]
}

#' @rdname ss_info
#' @export
ss_info <- function(model) {
  list(systems = model$systems, n_input_genes = length(model$catalog),
       n_output_genes = vapply(model$output, length, integer(1)))
}

check_line <- function(model, line) {
  if (!is.character(line) || length(line) != 1L || !(line %in% model$systems)) {
    stop("Unknown system '", paste(line, collapse = ","), "'. Available: ", paste(model$systems, collapse = ", "), call. = FALSE)
  }
}

mlp_forward <- function(z, line, Xs) {
  p <- paste0("sys/", line, "_")
  nets <- lapply(seq_len(as.integer(z[[paste0(p, "mlp_n")]])) - 1L, function(s) {
    x <- Xs
    for (layer in 0:2) {
      W <- z[[sprintf("%smlp%d_w%d", p, s, layer)]] * z[[sprintf("%smlp%d_s%d", p, s, layer)]]
      b <- z[[sprintf("%smlp%d_b%d", p, s, layer)]]
      x <- sweep(x %*% t(W), 2L, b, "+")
      if (layer < 2L) x[x < 0] <- 0
    }
    x
  })
  Reduce(`+`, nets) / length(nets)
}

#' Predict the response to knocking down genes
#'
#' Predicts, for each gene in `genes`, the change of the mean expression of every output gene of the system `line`
#' (log1p counts per 10,000 for most systems; the unit is system-specific). The result equals the Python package.
#' Predictions for genes that were training targets are fitted values, not accuracy estimates; for genes never
#' measured in a system they are hypotheses.
#'
#' @param model A model from [ss_load()].
#' @param genes Character vector of input gene symbols (see [ss_genes()]).
#' @param line A system name from [ss_lines()].
#' @return An object of class `superslim_prediction`: a list with `line`, `genes`, `output_genes` and `values`
#'   (a matrix with one row per gene and one column per output gene).
#' @examples
#' \dontrun{
#' m <- ss_load(ss_download("open-v4"))
#' p <- ss_predict(m, c("TP53", "EGFR"), "cd4_rest")
#' ss_top(p, "EGFR", n = 10)
#' }
#' @export
ss_predict <- function(model, genes, line) {
  check_line(model, line)
  genes <- as.character(genes)
  pos <- match(genes, model$catalog)
  if (anyNA(pos)) stop("Unsupported input gene (no feature row): ", paste(utils::head(genes[is.na(pos)], 5L), collapse = ", "), call. = FALSE)
  z <- model$z; p <- paste0("sys/", line, "/")
  F <- model$X[pos, , drop = FALSE]
  for (s in split_names(z[[paste0(p, "sources_b")]])) {
    cx <- model$cx[[s]]
    j <- match(pos - 1L, cx$idx)
    C <- matrix(0, length(genes), ncol(cx$codes)); av <- matrix(0, length(genes), 1L)
    ok <- !is.na(j)
    if (any(ok)) { C[ok, ] <- cx$codes[j[ok], , drop = FALSE]; av[ok, 1L] <- 1 }
    F <- cbind(F, C, av)
  }
  Xs <- sweep(sweep(F, 2L, z[[paste0(p, "x_mean")]], "-"), 2L, z[[paste0(p, "x_sd")]], "/")
  Xs <- sweep(Xs, 2L, z[[paste0(p, "x_scale")]], "*")
  a <- as.numeric(z[[paste0(p, "alpha")]])
  Z <- (1 - a) * (Xs %*% z[[paste0(p, "W")]]) + a * mlp_forward(z, line, Xs)
  B <- z[[paste0(p, "basis_q")]] * z[[paste0(p, "basis_scale")]]
  raw <- sweep(as.numeric(z[[paste0(p, "s")]]) * (Z %*% B), 2L, z[[paste0(p, "base16")]], "+")
  if (isTRUE(z[[paste0(p, "has_control")]])) {
    ctrl <- z[[paste0(p, "control16")]] * CTRL_SCALE
    raw <- pmax(sweep(raw, 2L, ctrl, "+"), 0)
    raw <- sweep(raw, 2L, ctrl, "-")
  }
  og <- model$output[[line]]
  own <- as.numeric(z[[paste0(p, "own_value")]])
  for (i in seq_along(genes)) {
    j <- match(genes[i], og)
    if (!is.na(j)) raw[i, j] <- own
  }
  dimnames(raw) <- list(genes, og)
  structure(list(line = line, genes = genes, output_genes = og, values = raw), class = "superslim_prediction")
}

#' @export
print.superslim_prediction <- function(x, ...) {
  cat("<superslim_prediction> system ", x$line, ": ", nrow(x$values), " gene(s) x ", ncol(x$values), " output genes\n", sep = "")
  invisible(x)
}

#' Strongest predicted changes for one gene
#'
#' @param prediction A result of [ss_predict()].
#' @param gene One of the perturbed genes in `prediction`.
#' @param n Number of output genes to return.
#' @param direction `"down"` for the strongest predicted decreases, `"up"` for increases.
#' @return A data frame with columns `gene` and `change`.
#' @export
ss_top <- function(prediction, gene, n = 20L, direction = c("down", "up")) {
  direction <- match.arg(direction)
  i <- match(gene, prediction$genes)
  if (is.na(i)) stop("Gene '", gene, "' is not in this prediction.", call. = FALSE)
  v <- prediction$values[i, ]
  o <- order(if (direction == "down") v else -v)[seq_len(min(n, length(v)))]
  data.frame(gene = prediction$output_genes[o], change = unname(v[o]), stringsAsFactors = FALSE)
}

#' The same gene in several systems
#'
#' @param model A model from [ss_load()].
#' @param gene One input gene.
#' @param lines Systems to use (default: all). Each is predicted in its own output genes and units.
#' @return A named list of `superslim_prediction` objects.
#' @export
ss_compare <- function(model, gene, lines = NULL) {
  if (is.null(lines)) lines <- model$systems
  stats::setNames(lapply(lines, function(l) ss_predict(model, gene, l)), lines)
}
