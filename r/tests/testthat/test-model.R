fx <- function(f) testthat::test_path("fixtures", f)

test_that("the synthetic model loads and reports its contents", {
  m <- ss_load(fx("synthetic_open.npz"))
  expect_s3_class(m, "superslim_model")
  expect_identical(ss_lines(m), "sysa")
  expect_length(ss_genes(m), 20L)
  expect_identical(ss_info(m)$n_output_genes[["sysa"]], 9L)
  expect_output(print(m), "superslim_model")
})

test_that("predictions equal the Python package (golden values)", {
  m <- ss_load(fx("synthetic_open.npz"))
  g <- utils::read.csv(fx("golden_sysa.csv"), check.names = FALSE, stringsAsFactors = FALSE)
  p <- ss_predict(m, g$gene, "sysa")
  expect_identical(p$output_genes, setdiff(colnames(g), "gene"))
  expect_equal(unname(p$values), unname(as.matrix(g[, -1])), tolerance = 1e-5)
})

test_that("floor, own-gene constant and input checks work", {
  m <- ss_load(fx("synthetic_open.npz"))
  p <- ss_predict(m, c("G1", "G2"), "sysa")
  expect_equal(unname(p$values[1, "G1"]), -0.3, tolerance = 1e-6)
  expect_equal(unname(p$values[2, "G2"]), -0.3, tolerance = 1e-6)
  expect_error(ss_predict(m, "NOPE", "sysa"), "Unsupported input gene")
  expect_error(ss_predict(m, "G0", "nosuch"), "Unknown system")
  expect_identical(ss_predict(m, "G0", "sysa")$values, ss_predict(m, "G0", "sysa")$values)
})

test_that("ss_top and ss_compare return sensible shapes", {
  m <- ss_load(fx("synthetic_open.npz"))
  p <- ss_predict(m, c("G0", "G5"), "sysa")
  tp <- ss_top(p, "G5", n = 3, direction = "up")
  expect_equal(nrow(tp), 3L)
  expect_true(all(diff(tp$change) <= 0))
  expect_named(ss_compare(m, "G0"), "sysa")
})

test_that("non-model files are rejected and the registry is consistent", {
  tf <- tempfile(fileext = ".npz"); writeLines("not an archive", tf)
  expect_error(ss_load(tf))
  expect_error(read_npz(tempfile()), "File not found")
  expect_true(all(nchar(ss_models()$sha256) == 64L))
  expect_error(ss_download("nosuch"), "Unknown model")
})

test_that("the released model matches the Python package (needs SUPERSLIM_MODEL and fixtures/golden_real.npz; run in CI)", {
  path <- Sys.getenv("SUPERSLIM_MODEL", unset = "")
  gold <- fx("golden_real.npz")
  skip_if(!nzchar(path) || !file.exists(path) || !file.exists(gold), "set SUPERSLIM_MODEL and run r/tools/make_real_golden.py to enable this test")
  m <- ss_load(path); g <- read_npz(gold)
  for (line in ss_lines(m)) {
    p <- ss_predict(m, g$genes, line)
    expect_equal(unname(p$values), unname(g[[line]]), tolerance = 1e-5, label = line)
    expect_lt(max(abs(unname(p$values) - unname(g[[line]]))), 1e-6, label = paste(line, "maximum absolute difference"))
  }
})
