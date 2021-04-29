# This function calculates the bi-temporal comparison
# Input raster bands are NDVIimages1 and NDVIimages2
# Output is an NDVI temporal change raster


bitemporalComparison <- function(img1, img2) {

  temporalDiff <- img2 - img1
  return(temporalDiff)

}
