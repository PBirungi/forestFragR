library(testthat)
library(terra)

test_that("visualize_patch_isolation returns a valid SpatRaster and maps values correctly", {

  # Create raster with patch IDs
  r <- terra::rast(nrows = 5, ncols = 5)
  terra::values(r) <- rep(1:5, each = 5)

  # Mock input (must match patch IDs)
  patches_list <- list(
    patches = r,
    patch_sizes = data.frame(
      patch_id = 1:5,
      area = c(10, 20, 15, 25, 30)
    ),
    nn_distance = setNames(
      c(100, 150, 200, 50, 120),
      1:5
    )
  )

  # Run function (suppress plot output)
  nn_raster <- suppressWarnings(
    visualize_patch_isolation(patches_list)
  )


  # Structure checks
  expect_s4_class(nn_raster, "SpatRaster")
  expect_equal(terra::ncell(nn_raster), terra::ncell(r))



  # Value mapping check
  expected_values <- patches_list$nn_distance[terra::values(r)]

  expect_equal(
    as.vector(terra::values(nn_raster)),
    as.vector(expected_values)
  )


  # NA handling check
  expect_false(any(is.na(terra::values(nn_raster))))

})
