# This function calculates the Normalized Differeencial Vegetation Index (NDVI)
# Input raster bands are Red and NIR
# Output is an NDVI raster


calculateNDVI <- function (red, nir){

  ndvi <- (nir - red)/(nir + red)
  return(ndvi)

}
