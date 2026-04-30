#' Load a Classified Land Cover Raster
#'
#'Imports a classified land cover raster into R as a \code{SpatRaster} object.
#' This function is typically the first step in the forest fragmentation
#' analysis workflow. The raster should contain categorical land cover classes
#' (e.g., forest, agriculture, built-up, water) encoded as integer values.
#'
#'
#' @param filepath Character string specifying the file path to the
#' classified land cover raster (e.g., GeoTIFF).
#'
#' @returns A \code{SpatRaster} object representing the imported land cover data.
#'
#' @details
#' The function uses \code{terra::rast()} to read the raster file.
#' Supported formats include GeoTIFF and other raster formats compatible with
#' the \pkg{terra} package.
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#' landcover <- load_landcover("data/landcover.tif")
#' plot(landcover)
#' }
#'
load_landcover <- function(filepath){
  terra::rast(filepath)
}
