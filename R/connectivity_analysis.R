#' Analyze connectivity between forest patches
#'
#' Calculates distances between forest patch centroids and identifies
#' isolated versus connected patches.
#'
#' @param patch_data A list output from \code{analyze_patches()}, containing:
#' \describe{
#'   \item{patches}{A SpatRaster of labeled forest patches}
#'   \item{patch_sizes}{A data.frame with patch areas}
#' }
#'
#' @returns A list containing:
#' \describe{
#'   \item{patches}{SpatRaster of patch IDs}
#'   \item{patch_sizes}{Data frame of patch areas}
#'   \item{nn_distance}{Named numeric vector of nearest neighbor distances}
#'   \item{connectivity_table}{Data.frame with patch_id, distance, and status}
#' }
#'
#'
#' @details
#' Assumes input raster is projected (units in meters). Patches with
#' nearest neighbor distance above the mean are classified as "isolated",
#' otherwise "connected".
#'
#'
#' @examples
#' \dontrun{
#' data <- prepare_data("landcover.tif", "aoi.gpkg")
#' forest <- preprocess_forest(data$raster)
#' patches <- analyze_patches(forest)
#' conn <- connectivity_analysis(patches)
#' head(conn)
#' }
#'
#' @importFrom stats setNames
#' @export
#'
connectivity_analysis <- function(patch_data) {

  # Validate input
  if (!is.list(patch_data) ||
      is.null(patch_data$patches) ||
      is.null(patch_data$patch_sizes)) {
    stop("patch_data must be a list containing 'patches' and 'patch_sizes'.")
  }

  patches <- patch_data$patches
  patch_sizes <- patch_data$patch_sizes

  # Ensure at least 2 patches
  patch_sizes <- patch_sizes[!is.na(patch_sizes$patch_id), ]
  if (nrow(patch_sizes) < 2) {

    n <- nrow(patch_sizes)

    return(list(
      patches = patches,
      patch_sizes = patch_sizes,
      nn_distance = setNames(rep(0, n), patch_sizes$patch_id),
      connectivity_table = data.frame(
        patch_id = patch_sizes$patch_id,
        nearest_neighbor_distance = rep(0, n),
        status = rep("isolated", n),
        stringsAsFactors = FALSE
      )
    ))
  }

  # Convert raster patches to polygons
  patch_polygons <- terra::as.polygons(patches, dissolve = TRUE)

  # Assign patch IDs safely
  if (nrow(patch_polygons) != nrow(patch_sizes)) {
    stop("Number of polygons does not match number of patch sizes.")
  }
  patch_polygons$patch_id <- patch_sizes$patch_id

  # Compute centroids
  centroids <- terra::centroids(patch_polygons)
  coords <- terra::crds(centroids)

  # Distance matrix & nearest neighbor distances
  dist_matrix <- as.matrix(stats::dist(coords))
  nearest_dist <- apply(dist_matrix, 1, function(x) {
    x <- x[x > 0]  # remove self-distance
    min(x)
  })

  # Create connectivity table
  mean_dist <- mean(nearest_dist)

  connectivity_table <- data.frame(
    patch_id = patch_polygons$patch_id,
    nearest_neighbor_distance = nearest_dist,
    status = ifelse(nearest_dist > mean_dist, "isolated", "connected")
  )

  # Return structured output
  return(list(
    patches = patches,
    patch_sizes = patch_sizes,
    nn_distance = setNames(nearest_dist, patch_polygons$patch_id),
    connectivity_table = connectivity_table
  ))
}
