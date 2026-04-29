#' Prepare and Validate Spatial Data
#'
#' Loads land cover raster and AOI data, checks CRS, reprojects if needed,
#' and clips/masks raster to the AOI.
#'
#' @param raster SpatRaster object (landcover data)
#' @param aoi SpatVector object (area of interest)
#'
#' @returns A list containing:
#' \itemize{
#'   \item raster: Processed and clipped SpatRaster
#'   \item aoi: Processed SpatVector
#'   \item crs: CRS used for analysis
#' }
#'
#' @export

prepare_data <- function(raster, aoi) {

  # Input checks
  if (!inherits(raster, "SpatRaster")) {
    stop("raster must be a SpatRaster.")
  }

  if (!inherits(aoi, "SpatVector")) {
    stop("aoi must be a SpatVector.")
  }

  # CRS check
  if (terra::crs(raster) != terra::crs(aoi)) {
    message("CRS mismatch detected. Reprojecting AOI...")
    aoi <- terra::project(aoi, terra::crs(raster))
  }

  # Project to UTM if geographic
  if (terra::is.lonlat(raster)) {

    message("Geographic CRS detected. Determining appropriate UTM zone...")

    centroid <- terra::centroids(aoi)
    coords <- terra::crds(centroid)

    lon <- coords[1,1]
    lat <- coords[1,2]

    zone <- floor((lon + 180) / 6) + 1

    epsg <- if (lat >= 0) {
      paste0("EPSG:326", sprintf("%02d", zone))
    } else {
      paste0("EPSG:327", sprintf("%02d", zone))
    }

    message("Projecting to ", epsg)

    raster <- terra::project(raster, epsg)
    aoi <- terra::project(aoi, epsg)
  }

  # --- Check spatial overlap ---
  if (!terra::relate(terra::ext(raster), terra::ext(aoi), "intersects")) {
    stop("Raster and AOI do not overlap.")
  }

  # Crop and mask
  raster <- terra::crop(raster, aoi)
  raster <- terra::mask(raster, aoi)

  return(list(
    raster = raster,
    aoi = aoi,
    crs = terra::crs(raster)
  ))
}
