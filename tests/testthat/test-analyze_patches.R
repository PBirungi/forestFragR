library(testthat)
library(terra)

test_that("analyze_patches identifies patches and computes metrics correctly", {

  # Create binary raster
  r <- rast(nrows = 10, ncols = 10, xmin = 0, xmax = 10, ymin = 0, ymax = 10)
  values(r) <- sample(c(0, 1), ncell(r), replace = TRUE)
  crs(r) <- "EPSG:32632"

  result <- analyze_patches(r)


  # Structure checks
  expect_type(result, "list")
  expect_s4_class(result$patches, "SpatRaster")
  expect_s3_class(result$patch_sizes, "data.frame")


  # Column checks
  expected_cols <- c(
    "patch_id",
    "area",
    "perimeter",
    "shape_index",
    "core_area",
    "core_area_index"
  )

  expect_true(all(expected_cols %in% names(result$patch_sizes)))


  # Basic validity checks
  if (nrow(result$patch_sizes) > 0) {

    # Areas should be positive
    expect_true(all(result$patch_sizes$area > 0))

    # Perimeter should be positive
    expect_true(all(result$patch_sizes$perimeter > 0))

    # Shape index >= 1 (by definition)
    expect_true(all(result$patch_sizes$shape_index >= 1))

    # Core area >= 0
    expect_true(all(result$patch_sizes$core_area >= 0))

    # Core area index between 0 and 1
    expect_true(all(result$patch_sizes$core_area_index >= 0))
    expect_true(all(result$patch_sizes$core_area_index <= 1))
  }

})
