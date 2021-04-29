# This function downloads a .tar file from a url, saves it as file and unpacks the .tar 
# data in the dir directory. All tiff files are selected, and returned as a raster stack

downloadPrepare <- function(url, file, dir){
  
  # Download file from url and save as file argument
  download.file(url, file, method = 'auto')
  
  # Unpack the data in specified directory
  untar(file , exdir = dir)
  
  # Create and return raster stacks from the tif files of the unpacked data
  tifs <- list.files(dir, pattern = glob2rx('*.tif'), full.names = TRUE)
  return(stack(tifs))
}




