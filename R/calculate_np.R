
#' Calculate Number of Patches (NP) in a Raster
#'
#'This function calculates the **number of patches (NP)** in a landscape raster
#' using 8-neighbor connectivity. It wraps the `lsm_c_np` function from the
#' `landscapemetrics` package for easier use.
#'
#' @param raster A `SpatRaster` object (from the `terra` package) representing
#'   the landscape. Each unique value corresponds to a land-cover class.
#'
#' @returns tibble (data frame) containing the number of patches for each class.
#' @export
#'
#' @examples
#' library(terra)
#'  # create a small example raster
#' r <- rast(nrows = 10, ncols = 10)
#' values(r) <- sample(1:3, 100, replace = TRUE)
#' calculate_np(r)
#'
calculate_np <- function(raster) {

  # check input
  if (!inherits(raster, "SpatRaster")) {
    stop("Input must be a terra SpatRaster object.")
  }

  landscapemetrics::lsm_c_np(raster, directions = 8)
}
