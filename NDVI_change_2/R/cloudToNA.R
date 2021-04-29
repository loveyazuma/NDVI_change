# This function performs a value replacement
# Input RaskerBrick or RasterStack and cloud mask layer
# Output is a raster that has values NA for cloud free areas

cloud2NA <- function(raster_stack, cloud_mask){
  raster_stack[cloud_mask != 0] <- NA
  return(raster_stack)
}
