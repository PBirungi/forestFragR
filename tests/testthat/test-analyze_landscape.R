library(testthat)
library(terra)

test_that("analyze_landscape computes metrics correctly", {



  # Create synthetic binary raster
  r <- rast(nrows = 10, ncols = 10, xmin = 0, xmax = 10, ymin = 0, ymax = 10)

  # Create simple pattern: 2 patches
  values(r) <- c(
    rep(1, 20),   # patch 1
    rep(0, 30),
    rep(1, 10),   # patch 2
    rep(0, 40)
  )

  # Run patch analysis
  patch_data <- analyze_patches(r)

  # IMPORTANT: ensure perimeter exists (needed for PCI)
  patch_data$patch_sizes$perimeter <- rep(4, nrow(patch_data$patch_sizes))

  # Run landscape analysis
  metrics <- analyze_landscape(patch_data)


  # Structure tests
  expect_s3_class(metrics, "data.frame")
  expect_true(all(c("metric", "value") %in% names(metrics)))


  # Metric presence
  expected_metrics <- c("NP", "TA", "MPS", "PD", "ED",
                        "FI", "LPI", "EAR", "PCI")

  expect_true(all(expected_metrics %in% metrics$metric))


  # Value sanity checks
  expect_true(all(is.finite(metrics$value)))
  expect_true(all(metrics$value >= 0))


  # Logical correctness checks
  NP <- metrics$value[metrics$metric == "NP"]
  TA <- metrics$value[metrics$metric == "TA"]
  LPI <- metrics$value[metrics$metric == "LPI"]

  # At least 2 patches expected
  expect_gte(NP, 2)

  # Total area should be positive
  expect_gt(TA, 0)

  # Largest Patch Index must be between 0 and 1
  expect_true(LPI > 0 && LPI <= 1)

})
