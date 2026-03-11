
calculate_np <- function(raster) {

  # check input
  if (!inherits(raster, "SpatRaster")) {
    stop("Input must be a terra SpatRaster object.")
  }

  landscapemetrics::lsm_c_np(raster, directions = 8)
}
