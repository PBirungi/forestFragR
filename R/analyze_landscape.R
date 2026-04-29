#' Compute landscape-level fragmentation metrics
#'
#' `analyze_landscape` calculates key landscape-level metrics used to quantify
#' forest fragmentation from a binary raster (forest = 1, non-forest = 0).
#'
#' @param patch_data A list output from \code{analyze_patches()}, containing:
#' \describe{
#'   \item{patches}{A SpatRaster of labeled forest patches}
#'   \item{patch_sizes}{A data.frame with patch-level metrics}
#' }
#'
#' @returns A data.frame containing landscape-level metrics.
#'
#' @import terra
#' @export
analyze_landscape <- function(patch_data) {


  # Validate input
  if (!is.list(patch_data) ||
      !all(c("patches", "patch_sizes") %in% names(patch_data))) {
    stop("Input must be a list from analyze_patches().")
  }

  patches <- patch_data$patches
  patch_sizes <- patch_data$patch_sizes

  if (nrow(patch_sizes) == 0) {
    stop("No patches found in input data.")
  }



  # Core landscape metrics
  # Number of patches
  NP <- nrow(patch_sizes)

  # Total forest area
  TA <- sum(patch_sizes$area, na.rm = TRUE)

  # Mean patch size
  MPS <- mean(patch_sizes$area, na.rm = TRUE)

  # Landscape area (based on raster extent)
  res <- terra::res(patches)
  pixel_area <- res[1] * res[2]
  landscape_area <- terra::ncell(patches) * pixel_area

  # Patch density
  PD <- NP / landscape_area



  # Edge computation
  edge_raster <- terra::boundaries(patches)
  edge_cells <- sum(terra::values(edge_raster) == 1, na.rm = TRUE)

  edge_length <- edge_cells * res[1]
  ED <- edge_length / landscape_area




  # Landscape Metrics
  # Fragmentation Index (higher = more fragmented)
  FI <- NP / sqrt(TA)

  # Largest Patch Index (dominance of largest patch)
  LPI <- max(patch_sizes$area, na.rm = TRUE) / TA

  # Edge-to-Area Ratio (edge pressure intensity)
  EAR <- ED / TA

  # Cohesion proxy (structural connectedness)
  PCI <- 1 - (sum(patch_sizes$perimeter, na.rm = TRUE) / TA)




  # Output
  metrics <- data.frame(
    metric = c("NP", "TA", "MPS", "PD", "ED",
               "FI", "LPI", "EAR", "PCI"),
    value = c(NP, TA, MPS, PD, ED,
              FI, LPI, EAR, PCI)
  )

  return(metrics)
}
