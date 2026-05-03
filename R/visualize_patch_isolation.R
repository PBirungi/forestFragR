#' Visualize Patch Isolation
#'
#' Creates a ggplot2-based raster plot of patch isolation based on nearest
#' neighbor distances obtained from connectivity analysis.
#'
#' @param patches_list List. Output of `connectivity_analysis()`, containing:
#' \itemize{
#'   \item patches: SpatRaster of patch IDs
#'   \item patch_sizes: data.frame of patch IDs and areas
#'   \item nn_distance: numeric vector of nearest neighbor distances
#' }
#' @param main_title Character. Plot title
#' (default: "Patch Isolation (Nearest Neighbor Distance)")
#'
#' @return A ggplot object (and invisibly the SpatRaster of NN distances)
#'
#' @examples
#' \dontrun{
#' patches <- analyze_patches(forest)
#' conn <- connectivity_analysis(patches)
#' visualize_patch_isolation(conn)
#' }
#'
#' @import terra
#' @import ggplot2
#' @importFrom rlang .data
#' @export

visualize_patch_isolation <- function(patches_list,
                                      main_title = "Patch Isolation (Nearest Neighbor Distance)") {

  # Input validation
  if (!is.list(patches_list)) {
    stop("patches_list must be a list from connectivity_analysis().")
  }

  if (is.null(patches_list$patches) || is.null(patches_list$nn_distance)) {
    stop("patches_list must contain 'patches' and 'nn_distance'.")
  }

  # Extract data
  patch_raster <- patches_list$patches
  nn_distances <- patches_list$nn_distance

  # Create NN raster
  nn_raster <- patch_raster
  terra::values(nn_raster) <- nn_distances[terra::values(patch_raster)]

  # Convert to data frame for ggplot
  df <- as.data.frame(nn_raster, xy = TRUE, na.rm = TRUE)
  colnames(df)[3] <- "nn_distance"

  # Plot
  p <- ggplot(df, aes(x = .data$x, y = .data$y, fill = .data$nn_distance)) +
    geom_tile() +
    scale_fill_viridis_c(name = "NN Distance") +
    coord_equal() +
    labs(title = main_title, x = "X", y = "Y") +
    theme_minimal()

  print(p)

  return(invisible(nn_raster))
}
