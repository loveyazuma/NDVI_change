#Load library
library(rgdal)
library(raster)

#Source external functions
source("./R/cloudToNA.R")
source("./R/calculateNDVI.R")
source("./R/bitemporalComparison.R")

#Create data and output folders and download data from URL
data_URL <- "https://www.dropbox.com/sh/3lz5vylc7tzpiup/AAB3HCFHdJFa8lV_PMRlV5Wda?dl=1"
data_folder <- "./data"

if (!dir.exists(data_folder)){
  dir.create(data_folder)
}

if (!dir.exists('output')) {
  dir.create('output')
}

if (!file.exists('./data/data.zip')) {
  download.file(url = data_URL, destfile = './data/data.zip', method = 'auto')
  unzip('./data/data.zip', exdir = './data')
}

#Create floders for landsat5 and landsat8 and unzip images
if (!dir.exists('./data/landsat5') | !dir.exists('./data/landsat8')){
  dir.create('./data/landsat5')
  dir.create('./data/landsat8')
}

if (!dir.exists('output')) {
  dir.create('output')
}

if(file.exists('./data/LC81970242014109-SC20141230042441.tar.gz') | file.exists('./data/LT51980241990098-SC20150107121947.tar.gz')) {
  untar('./data/LC81970242014109-SC20141230042441.tar.gz', exdir = './data/landsat8')
  untar('./data/LT51980241990098-SC20150107121947.tar.gz', exdir = './data/landsat5')
}

#Stack NIR and Red bands layers
L5_stack<- stack('./data/landsat5/LT51980241990098KIS00_sr_band4.tif', './data/landsat5/LT51980241990098KIS00_sr_band3.tif', './data/landsat5/LT51980241990098KIS00_cfmask.tif')
L8_stack <- stack('./data/landsat8/LC81970242014109LGN00_sr_band5.tif', './data/landsat8/LC81970242014109LGN00_sr_band4.tif', './data/landsat8/LC81970242014109LGN00_cfmask.tif')

#Visualize the input data
png(filename="output/LT51980241990098KIS00_sr.png", width=800, height=500)
plotRGB(L5_stack, r = 3, g = 2, b = 1, stretch = "lin")
dev.off()

png(filename="output/LC81970242014109LGN00_sr.png", width=800, height=500)
plotRGB(L8_stack, r = 3, g = 2, b = 1, stretch = "lin")
dev.off()

#Determine aoi extent and crop images
area_extent <- extent(c(677365, 688190, 5757630, 5764179))
L5_aoi <- intersect(L5_stack, aoi_extent)
L8_aoi <- intersect(L8_stack, aoi_extent)

#Visualize the cropped area
png(filename="output/Landsat5_aoi.png", width=800, height=500)
plotRGB(L5_aoi, r = 3, g = 2, b = 1, stretch = "lin")
dev.off()

png(filename="output/Landsat8_aoi.png", width=800, height=500)
plotRGB(L8_aoi, r = 3, g = 2, b = 1, stretch = "lin")
dev.off()

#Extract colud mask raster layer
L5_cloud <- L5_aoi[[3]]
L8_cloud <- L8_aoi[[3]]

# Remove clould mask layer from the Landsat Stack
L5_nir_red <- dropLayer(L5_aoi, 3)
L8_nir_red <- dropLayer(L8_aoi, 3)

# Mask out the values in the pixels where no clouds were detected
L5_cloudfree <- overlay(x = L5_nir_red, y = L5_cloud, fun = cloud2NA)
L8_cloudfree <- overlay(x = L8_nir_red, y = L8_cloud, fun = cloud2NA)

#Visualize the clouds
png(filename="output/Landsat5_clouds.png", width=800, height=500)
plot(L5_cloud, legend = TRUE)
dev.off()

png(filename="output/Landsat8_clouds.png", width=800, height=500)
plot(L8_cloud, legend = TRUE)
dev.off()

# Estimate NDVI
L5NDVI <- overlay(x = L5_cloudfree[[2]], y = L5_cloudfree[[1]], fun = calculateNDVI)
L8NDVI <- overlay(x = L8_cloudfree[[2]], y = L8_cloudfree[[1]], fun = calculateNDVI)


#Visualize the NDVI result
png(filename="output/Landsat5_NDVI.png", width=800, height=500)
plot(L5NDVI, legend = TRUE)
legend("bottomleft", legend = c(">0.8       Very High Vegetation", "0.6-0.8   High Vegetation", "0.4-0.6   Moderate Vegetation", "0.2-0.4   Low Vegetation", "<0.2       Very Low Vegetation"))
title(main = "NDVI of aoi (April 2014)",
      sub = "NDVI classification using Landsat 5")
dev.off()

png(filename="output/Landsat8_NDVI.png", width=800, height=500)
plot(L8NDVI, legend = TRUE)
legend("bottomleft", legend = c(">0.8       Very High Vegetation", "0.6-0.8   High Vegetation", "0.4-0.6   Moderate Vegetation", "0.2-0.4   Low Vegetation", "<0.2       Very Low Vegetation"))
title(main = "NDVI of aoi (April 1990)",
      sub = "NDVI classification using Landsat 8")
dev.off()

#Carry out temporal comparison between 30 years in Wageningen
bitemporal <- overlay(L5NDVI, L8NDVI, fun = bitemporalComparison)

#Visualize the changes of NDVI between 30 years
png(filename="output/NDVIbitemporalchange.png", width=800, height=500)
plot(bitemporal, legend = TRUE)
legend("bottomleft", legend = c(">0.5    Increased Vegetation", "0         No Changes", "<-0.5   Decreased Vegetation"))
title(main = "NDVI temporal changes of AOI between April 1990 and April 2014",
      sub = "NDVI temporal changes using Landsat data")
dev.off()
