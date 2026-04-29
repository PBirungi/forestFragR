#' Analyze Forest Patches
#'
#' Identifies forest patches using connected component labeling and computes
#' patch-level metrics such as area, perimeter, shape index, and core area.
#'
#' @param binary_raster SpatRaster. Binary raster (1 = forest, 0 = non-forest).
#'
#' @returns A list containing:
#' \itemize{
#'   \item patches: SpatRaster with unique patch IDs
#'   \item patch_sizes: data.frame with patch-level metrics
#' }
#'
#' @details
#' Uses 4-neighbour connectivity to define patches.Metrics include:
#' \itemize{
#'   \item area (in map units)
#'   \item perimeter
#'   \item shape index
#'   \item core area
#'   \item core area index
#' }
#'
#' @examples
#' \dontrun{
#' result <- analyze_patches(binary)
#' }
#'
#' @import terra
#' @export
#'
analyze_patches <- function(binary_raster) {


  # Validate input
  if (!inherits(binary_raster, "SpatRaster")) {
    stop("Input must be a terra SpatRaster.")
  }

  vals <- terra::values(binary_raster, mat = FALSE)

  if (!all(na.omit(vals) %in% c(0, 1))) {
    stop("Input raster must be binary (0/1).")
  }



  # Forest only
  forest_only <- binary_raster
  forest_only[forest_only == 0] <- NA


  # Patch raster
  patches <- terra::patches(forest_only, directions = 8)



  # Convert to polygons
  patch_polygons <- terra::as.polygons(patches, dissolve = TRUE)

  if (nrow(patch_polygons) == 0) {
    stop("No patches detected.")
  }

  patch_ids <- as.vector(terra::values(patch_polygons)[,1])




  # Compute metrics
  area <- terra::expanse(patch_polygons, unit = "m")

  perimeter <- terra::perim(patch_polygons)

  # Ensure strictly positive
  if (any(area <= 0) || any(perimeter <= 0)) {
    stop("Invalid geometry: zero or negative area/perimeter detected.")
  }

  shape_index <- perimeter / (2 * sqrt(pi * area))

  # shape index must be >= 1
  shape_index[shape_index < 1] <- 1



  # Core area
  core_polygons <- suppressWarnings(
    terra::buffer(patch_polygons, width = -30)
  )

  core_area <- try(terra::expanse(core_polygons, unit = "m"), silent = TRUE)

  if (inherits(core_area, "try-error") || length(core_area) != length(area)) {
    core_area <- rep(0, length(area))
  }

  core_area_index <- core_area / area




  # Output
  patch_sizes <- data.frame(
    patch_id = as.numeric(patch_ids),
    area = as.numeric(area),
    perimeter = as.numeric(perimeter),
    shape_index = as.numeric(shape_index),
    core_area = as.numeric(core_area),
    core_area_index = as.numeric(core_area_index),
    stringsAsFactors = FALSE
  )

  if (!all(c("patch_id","area","perimeter","shape_index","core_area","core_area_index") %in% names(patch_sizes))) {
    stop("patch_sizes columns are incorrect")
  }

  return(list(
    patches = patches,
    patch_sizes = patch_sizes
  ))
}
