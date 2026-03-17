#' Prepare and Validate Spatial Data
#'
#'Loads land cover raster and AOI data, checks coordinate reference systems (CRS),
#' ensures consistency between datasets, and reprojects them to an appropriate
#' projected coordinate system (automatically selecting a UTM zone if needed).
#'
#' @param landcover_path Character. File path to the land cover raster.
#' @param aoi_path Character. File path to the AOI vector (e.g., shapefile).
#'
#' @returns A list containing:
#' \itemize{
#'   \item raster: Processed SpatRaster
#'   \item aoi: Processed SpatVector
#'   \item crs: CRS used for analysis
#' }
#'
#' @details
#' This function ensures that:
#' \itemize{
#'   \item Raster and AOI share the same CRS
#'   \item Data is in a projected CRS (meters)
#'   \item If input is geographic (e.g., WGS84), an appropriate UTM zone is selected automatically
#' }
#'
#' @examples
#' \dontrun{
#' data <- prepare_data("data/landcover.tif", "data/aoi.shp")
#' plot(data$raster)
#' plot(data$aoi, add = TRUE)
#' }
#'
#' @export
#'
#'
prepare_data <- function(landcover_path, aoi_path) {


  # Load data
  raster <- terra::rast(landcover_path)
  aoi <- terra::vect(aoi_path)


  # Check CRS match
  raster_crs <- terra::crs(raster)
  aoi_crs <- terra::crs(aoi)

  if (raster_crs != aoi_crs) {
    message("CRS mismatch detected. Reprojecting AOI to match raster...")
    aoi <- terra::project(aoi, raster_crs)
  }


  # Check if CRS is geographic
  if (terra::is.lonlat(raster)) {

    message("Geographic CRS detected. Determining appropriate UTM zone...")

    # Get AOI centroid
    centroid <- terra::centroids(aoi)
    coords <- terra::crds(centroid)

    lon <- coords[1,1]
    lat <- coords[1,2]

    # Compute UTM zone
    zone <- floor((lon + 180) / 6) + 1

    # Determine EPSG
    if (lat >= 0) {
      epsg <- paste0("EPSG:326", sprintf("%02d", zone))  # Northern hemisphere
    } else {
      epsg <- paste0("EPSG:327", sprintf("%02d", zone))  # Southern hemisphere
    }

    message(paste("Projecting to UTM Zone", zone, "(", epsg, ")"))

    # Reproject both
    raster <- terra::project(raster, epsg)
    aoi <- terra::project(aoi, epsg)

  } else {
    message("Data already in projected CRS. No reprojection needed.")
    epsg <- raster_crs
  }


  # Return clean data
  return(list(
    raster = raster,
    aoi = aoi,
    crs = epsg
  ))
}
