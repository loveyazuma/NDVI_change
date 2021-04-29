## NDVI change over time

The [Normalized Difference Vegetation Index](https://en.wikipedia.org/wiki/Normalized_difference_vegetation_index) serves as a good indicator for greenes. A *bi-temporal comparison* of two NDVI images is usually conducted. Simply subtracting the two images should work, but unfortunately these haven't been pre-processed yet. Two Landsat raw surface reflectance products covering the area were utilized. They were acquired around the same period of the year, but about 30 years apart from each other.


### Details
- The Landsat data can be found [here](https://www.dropbox.com/sh/3lz5vylc7tzpiup/AAB3HCFHdJFa8lV_PMRlV5Wda?dl=1)
- Beware of the different product details and bands of [Landsat 8](https://landsat.gsfc.nasa.gov/landsat-8/) and [Landsat 5](https://landsat.gsfc.nasa.gov/landsat-5/)
- A cloud mask from the fmask algorithm is contained in both archives


### Processes
- The data was downloaded from the dropbox into the script
- 2 functions were written and used for pre-processing the data
- The two Landsat products were visualized as RGB images and saved as a `.png` files
- The resulting NDVI comparison map was visualized, conclusions were drawn, and saved as a `.png` fil
