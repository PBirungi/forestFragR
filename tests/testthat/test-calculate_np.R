library(testthat)
library(forestFragR)

test_that("calculate_np works on a small raster", {
  library(terra)

  # create a small test raster
  r <- rast(nrows = 10, ncols = 10)
  values(r) <- sample(1:3, 100, replace = TRUE)

  result <- calculate_np(r)

  # check result is a tibble/data frame
  expect_s3_class(result, "tbl_df")

  # check the number of rows matches number of classes
  expect_equal(nrow(result), 3)

  # check metric column exists
  expect_true("metric" %in% colnames(result))
})
