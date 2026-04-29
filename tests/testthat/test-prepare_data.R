library(testthat)
library(terra)


test_that("prepare_data works with synthetic SpatRaster and SpatVector", {

  # Create synthetic raster
  r <- rast(nrows = 10, ncols = 10, xmin = 0, xmax = 1, ymin = 0, ymax = 1)
  values(r) <- sample(1:5, ncell(r), replace = TRUE)
  crs(r) <- "EPSG:4326"  # geographic CRS

  # Create synthetic AOI polygon
  # Using terra::ext to get bounding box, then vect() to make polygon
  aoi <- as.polygons(ext(r))
  crs(aoi) <- "EPSG:4326"

  # Run prepare_data function
  result <- prepare_data(r, aoi)

  # Tests
  expect_type(result, "list")                     # returns a list
  expect_s4_class(result$raster, "SpatRaster")    # raster component
  expect_s4_class(result$aoi, "SpatVector")       # AOI component
  expect_false(terra::is.lonlat(result$raster))   # should be projected
  expect_equal(terra::crs(result$raster), terra::crs(result$aoi))  # CRS match

  # Check dimensions remain the same after reprojection
  expect_equal(dim(r)[1:2], dim(result$raster)[1:2])  # rows, cols
})
