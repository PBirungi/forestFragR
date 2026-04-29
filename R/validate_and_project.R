#' Validate and Project Spatial Data
#'
#' Ensures that the input raster and AOI share the same coordinate reference
#' system (CRS) and are in a projected CRS suitable for spatial analysis.
#' If the CRS is geographic (e.g., WGS84), the data will be reprojected.
#'
#' @param raster A SpatRaster object
#' @param aoi A SpatVector (polygon) representing the study area.
#'
#'
#' @returns A list containing:
#' \itemize{
#'   \item raster: Projected raster
#'   \item aoi: Projected AOI
#' }
#'
#' @examples
#' \dontrun{
#' result <- validate_and_project(raster, aoi)
#' }
#'
#'
#' @export

validate_and_project <- function(raster, aoi) {

  # Get CRS
  raster_crs <- terra::crs(raster)
  aoi_crs <- terra::crs(aoi)

  # Align CRS
  if (raster_crs != aoi_crs) {
    message("CRS mismatch detected. Reprojecting AOI to match raster...")
    aoi <- terra::project(aoi, raster_crs)
  }

  # Check if CRS is geographic
  if (terra::is.lonlat(raster)) {

    message("Geographic CRS detected. Determining UTM zone...")

    # Get centroid of AOI
    centroid <- terra::centroids(aoi)
    coords <- terra::crds(centroid)

    lon <- coords[1,1]
    lat <- coords[1,2]

    # Compute UTM zone
    zone <- floor((lon + 180) / 6) + 1

    # Determine hemisphere
    if (lat >= 0) {
      epsg <- paste0("EPSG:326", sprintf("%02d", zone))  # Northern
    } else {
      epsg <- paste0("EPSG:327", sprintf("%02d", zone))  # Southern
    }

    message(paste("Projecting to UTM Zone:", zone, "CRS:", epsg))

    # Reproject
    raster <- terra::project(raster, epsg)
    aoi <- terra::project(aoi, epsg)

    return(list(raster = raster, aoi = aoi, crs = epsg))
  }

  # If already projected
  message("Data already in projected CRS. No reprojection needed.")

  return(list(raster = raster, aoi = aoi, crs = raster_crs))
}
