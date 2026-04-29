#' Preprocess Forest Raster
#'
#' Clips land cover raster to AOI and creates a binary forest/non-forest raster.
#'
#' @param raster SpatRaster. Land cover raster.
#'
#' @param forest_class Integer. Value representing forest class.
#'
#' @returns SpatRaster (binary: 1 = forest, 0 = non-forest)
#'
#' @examples
#' \dontrun{
#' binary <- preprocess_forest(raster, aoi, forest_class = 10)
#' }
#'
#' @import terra
#' @export

preprocess_forest <- function(raster, forest_class = "trees") {


  # Input check
  if (missing(raster)) {
    stop("Please provide a raster.")
  }

  if (!inherits(raster, "SpatRaster")) {
    stop("raster must be a SpatRaster.")
  }


  # Handle forest class
  if (is.character(forest_class)) {
    forest_class <- switch(
      forest_class,
      "trees" = 10,
      "shrubland" = 20,
      stop("Invalid forest_class. Use 'trees', 'shrubland', or a numeric value.")
    )
  }


  # Create binary raster
  binary <- terra::ifel(raster == forest_class, 1, 0)

  return(binary)
}
