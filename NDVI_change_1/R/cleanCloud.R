# This function masks a raster stack using a cloud mask

cleanCloud <- function(raster, mask){
  # Set raster values to NA where cloud mask is nonzero
  raster[mask != 0] <- NA
  
  # Return the masked raster stack
  return(raster)
}
