library(testthat)
library(terra)

test_that("connectivity_analysis works correctly with synthetic raster", {


  # Create synthetic raster
  r <- rast(nrows = 10, ncols = 10, xmin = 0, xmax = 10, ymin = 0, ymax = 10)

  # Create 2–3 simple patches
  values(r) <- c(
    rep(1, 10),
    rep(0, 40),
    rep(1, 10),
    rep(0, 40)
  )

  # Run patch analysis
  patch_data <- analyze_patches(r)

  # Run connectivity analysis
  conn <- connectivity_analysis(patch_data)


  # Structure tests
  expect_true(is.list(conn))

  expect_true(all(c("patches",
                    "patch_sizes",
                    "nn_distance",
                    "connectivity_table") %in% names(conn)))


  # nn_distance checks
  expect_true(is.numeric(conn$nn_distance))
  expect_true(!is.null(names(conn$nn_distance)))

  # Distances should be positive
  expect_true(all(conn$nn_distance > 0))



  # connectivity_table checks
  ct <- conn$connectivity_table

  expect_s3_class(ct, "data.frame")

  expect_true(all(c("patch_id",
                    "nearest_neighbor_distance",
                    "status") %in% names(ct)))

  # Status values must be valid
  expect_true(all(ct$status %in% c("isolated", "connected")))

  # Distances must match nn_distance
  expect_equal(
    sort(ct$nearest_neighbor_distance),
    sort(as.numeric(conn$nn_distance))
  )


  # Logical checks
  # At least 2 patches required
  expect_gte(nrow(ct), 2)

  # Mean-based classification check
  mean_dist <- mean(ct$nearest_neighbor_distance)

  expected_status <- ifelse(
    ct$nearest_neighbor_distance > mean_dist,
    "isolated",
    "connected"
  )

  expect_equal(ct$status, expected_status)

})
