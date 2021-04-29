# This function takes in a red and nir raster layer and returns
# a raster with NDVI values for each cell

ndviCalc <- function(red, nir) {
  # Formula for NDVI calculation
  ndvi <- (nir - red) / (nir + red)
  
  # Return NDVI raster
  return(ndvi)
}