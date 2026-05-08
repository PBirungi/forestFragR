
<!-- README.md is generated from README.Rmd. Please edit that file -->

## forestFragR

<!-- badges: start -->
<!-- badges: end -->

forestFragR is an R package for analyzing forest fragmentation and landscape connectivity from raster data. It provides a streamlined workflow for preprocessing land cover data, identifying forest patches, computing landscape metrics, and assessing connectivity.

The package builds on the terra ecosystem, making it efficient for handling large spatial datasets.

## Installation

You can install the development version of forestFragR from GitHub with:

``` r
# Install devtools if you haven't yet
install.packages("devtools")

# Then install the package
devtools::install_github("PBirungi/forestFragR")
```

## How it works
The user provides only two inputs:

- A land cover raster (e.g., ESA WorldCover `.tif`)
- An Area of Interest (AOI) as a vector file (`.shp`, `.gpkg`, etc.)


### Workflow Overview

| Function | What it does | Output |
|----------|-------------|--------|
| `prepare_data()` | Validates inputs, checks CRS, reprojects if needed, and clips/masks raster to AOI | List with processed raster, AOI, and CRS |
| `preprocess_forest()` | Converts land cover raster into binary forest/non-forest using specified class | Binary forest raster (1 = forest, 0 = non-forest) |
| `analyze_patches()` | Identifies contiguous forest patches, assigns IDs, and computes patch-level metrics (area, perimeter, shape, core area) | List with patch raster and patch metrics table |
| `analyze_landscape()` | Computes landscape-level metrics (NP, TA, MPS, LPI, fragmentation and edge metrics) | Data frame of landscape metrics |
| `connectivity_analysis()` | Calculates distances between patch centroids, identifies nearest neighbors, and classifies patches as connected or isolated | List with nearest-neighbor distances and connectivity table |
| `visualize_patch_isolation()` | Generates a raster and heatmap visualization of patch isolation (nearest-neighbor distance) | Raster visualization of patch connectivity |
 

## Example 

This example uses ESA WorldCover land cover raster clipped to the University Forest AOI in Würzburg to analyze the forest fragmentation


```{r example}
library(forestFragR)

# Load data
landcover <- load_landcover(raster_path)
aoi <- vect(aoi_path)

# Prepare data (CRS alignment, projection, clipping)
prepared <- prepare_data(landcover, aoi)

# Extract forest (ESA WorldCover: trees = 10)
forest <- preprocess_forest(prepared$raster, forest_class = 10)

# Patch analysis
patch_data <- analyze_patches(forest)
```

### Patch Metrics Summary


| patch_id | area        | perimeter   | shape_index | core_area    | core_area_index |
|----------|------------:|------------:|------------:|-------------:|----------------:|
| 1        | 3.516450e+04 | 1110.1630   | 1.670050    | 11548.38     | 0.3284102       |
| 2        | 8.745267e+04 | 2298.5065   | 2.192574    | 38555.15     | 0.4408688       |
| 3        | 1.974344e+06 | 12884.1454  | 2.586659    | 1643283.28   | 0.8323185       |
| 8        | 3.517014e+06 | 21827.9940  | 3.283385    | 2956354.76   | 0.8405866       |
| 9        | 1.249523e+07 | 83152.7736  | 6.635898    | 10288175.09  | 0.8233682       |
| 11       | 3.057783e+02 | 125.0888    | 2.017949    | 0.00         | 0.0000000       |

The landscape is composed of forest patches that vary greatly in size and shape, ranging from very small fragments (~300 m²) to large continuous areas (>12 million m²). Most patches are irregular in shape, indicating fragmented landscapes with strong edge effects. While larger patches (e.g., Patch 9) retain substantial core habitat (~82%), smaller patches (e.g., Patch 11) have no core area and are highly vulnerable to degradation.

```{r example1}
# Landscape metrics
landscape_metrics <- analyze_landscape(patch_data)
```

### Landscape Metrics Summary with Interpretation


| Metric | Value | Interpretation |
|--------|------------------|-------------------------------|
| NP (Number of Patches) | 47 | Moderate number of distinct landscape patches |
| TA (Total Area) | 2.269839e+07 | Large overall landscape extent |
| MPS (Mean Patch Size) | 4.829446e+05 | Relatively large average patch size |
| PD (Patch Density) | 2.669083e-07 | Very low density, indicating sparse patch distribution |
| ED (Edge Density) | 9.311574e-04 | Low edge complexity in the landscape |
| FI (Fragmentation Index) | 9.865073e-03 | Very low fragmentation overall |
| LPI (Largest Patch Index) | 0.5504896 | One dominant patch covers ~55% of landscape |
| EAR (Edge Area Ratio) | 4.102305e-11 | Negligible edge influence relative to area |
| PCI (Patch Cohesion Index) | 0.9927442 | Very high connectivity and structural cohesion |


```{r example}
# Connectivity analysis
connectivity <- connectivity_analysis(patch_data)

# Visualization
visualize_patch_isolation(connectivity)
```

This is the resulting patch isolation map

<p align="center">
  <img src="man/figures/patch_isolation_map.png" width="500"/>
</p>


The patch isolation map highlights the spatial variation in forest connectivity across the study area. Patches shown in darker colors have shorter nearest-neighbor distances and are therefore more connected to surrounding forest patches. In contrast, patches displayed in lighter colors are more isolated, indicating greater distances to the nearest neighboring forest patch.

The highly isolated patch in the northern section of the study area suggests stronger forest fragmentation in that region. Increased isolation can reduce ecological connectivity, making it more difficult for species to move between habitat patches.

More connected patches, particularly in the central and southern portions of the landscape, may provide better habitat continuity and support higher biodiversity by facilitating species movement and maintaining ecological processes. 

Overall, the results demonstrate how spatial metrics derived from remote sensing can help identify fragmentation hotspots and areas that may require conservation or restoration efforts.
