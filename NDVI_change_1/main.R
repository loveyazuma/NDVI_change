#Import libraries
library(raster)

# Source functions
source('R/downloadPrepare.R')
source('R/cleanCloud.R')
source('R/ndviCalc.R')

# Create 'data' and 'output' folders if they don't already exist
if(!dir.exists(path = 'data')) {
  dir.create(path = 'data')
}

if(!dir.exists(path = 'output')) {
  dir.create(path = 'output')
}

# Use function to download and prepare the data
LS5_stack <- downloadPrepare('https://www.dropbox.com/sh/3lz5vylc7tzpiup/AAA7nDYZoq2l7qORZkSVaxfga/LT51980241990098-SC20150107121947.tar.gz?dl=1', 
                'data/landsat5.tar.gz', 'data/LS5')

LS8_stack <- downloadPrepare('https://www.dropbox.com/sh/3lz5vylc7tzpiup/AABw-7siirlcQoZGeyuVtFaNa/LC81970242014109-SC20141230042441.tar.gz?dl=1', 
                'data/landsat8.tar.gz', 'data/LS8')

# Select the cloud masks in both raster stacks
LS5_cfmask <- LS5_stack[[1]]
LS8_cfmask <- LS8_stack[[1]]

# Remove the mask layer from the original stacks
LS5_bands <- dropLayer(LS5_stack, 1)
LS8_bands <- dropLayer(LS8_stack, 1)

# Use overlay to apply the cleanCloud function to the rasters
LS5_masked <- overlay(LS5_bands, LS5_cfmask, fun = cleanCloud)
LS8_masked <- overlay(LS8_bands, LS8_cfmask, fun = cleanCloud)

# Set any negative values to NA, accounting for sensor inconsistencies
LS5_masked[LS5_masked < 0] <- NA
LS8_masked[LS8_masked < 0] <- NA

# Plot and save the RGB image of LS5
png('output/RGB_1990.png')
plotRGB(LS5_masked, 5,4,3, stretch = 'hist', axes = TRUE, main = 'RGB image of AOI 1990')
dev.off()

# Plot and save the RGB image of LS8
png('output/RGB_2014.png')
plotRGB(LS8_masked, 4,3,2, stretch = 'hist', axes = TRUE, main = 'RGB image of AOI 2014')
dev.off()

# Intersect both raster stacks to match their extents for both years
LS5_crop <- intersect(LS5_masked, LS8_masked)
LS8_crop <- intersect(LS8_masked ,LS5_masked)

# Use overlay to apply the ndviCalc function to both rasters
LS5_ndvi <- overlay(LS5_crop[[5]], LS5_crop[[6]], fun = ndviCalc)
LS8_ndvi <- overlay(LS8_crop[[4]], LS8_crop[[5]], fun = ndviCalc)

# Remove any values below 0 and above 1
LS5_ndvi[LS5_ndvi < 0 | LS5_ndvi > 1] <- NA
LS8_ndvi[LS8_ndvi < 0 | LS8_ndvi > 1] <- NA

# Plot the two NDVI rasters
plot(LS5_ndvi, main = 'NDVI for Landsat 5, 1990')
plot(LS8_ndvi, main = 'NDVI for Landsat 8, 2014')

# Subtract the two NDVI rasters for bitemporal comparison
NDVI_dif = LS8_ndvi - LS5_ndvi

# Save difference raster as png to disk
png('output/NDVI_difference.png')
plot(NDVI_dif, main='Difference between NDVI in 2014 and 1990')
dev.off()

# Save the raster file to disk
writeRaster(x = NDVI_dif, filename='output/NDVI_difference.tif', datatype='FLT4S', overwrite= TRUE)

