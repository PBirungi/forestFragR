library(testthat)
library(forestFragR)

test_that("load_landcover returns a SpatRaster", {
  raster_path <- "C:/Birungi/MSc_EAGLE/Introduction to programming in Earth Observation/Project/2025-08-18-00_00_2025-08-18-23_59_Sentinel-2_L2A_True_Color.tiff"  # use a small test raster
  lc <- load_landcover(raster_path)
  expect_s4_class(lc, "SpatRaster")
  expect_true(!is.null(lc))
})
