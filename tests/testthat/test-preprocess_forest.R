library(testthat)
library(terra)

test_that("preprocess_forest creates binary raster", {

  # Create raster
  r <- rast(nrows=10, ncols=10, xmin=0, xmax=1, ymin=0, ymax=1)
  values(r) <- sample(c(10, 20), ncell(r), replace=TRUE)
  crs(r) <- "EPSG:4326"

  # AOI
  aoi <- as.polygons(ext(r))


  # Run
  binary <- preprocess_forest(r, forest_class = 2)

  # Tests
  expect_s4_class(binary, "SpatRaster")
  expect_true(all(values(binary) %in% c(0,1, NA)))
})
