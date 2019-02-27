# ------------------------------------------------------------------------------
# Input files: tif files in data/rayshaded
# Output files: in /net/www/..../einarhj/public_html/tiles2
#
# Here first merge all tifs
#
# NOTE: There are both 20 and 30 meter resolutions. This means that the output
#       resolution will be 30 meters
#
# Run this as:
#  nohup R < R/03_tile_mb-rayshaded.R --vanilla &
#
# NOTE: tiler reprojects raster - did not expect that.
#       may need to be more specific in proj4string
# NOTE: Check using align_rasters first
# ------------------------------------------------------------------------------

# Food for thought:
#   https://gis.stackexchange.com/questions/234512/matching-two-rasters-with-different-projections-and-resolution

merge <- TRUE

library(tidyverse)
library(fs)
fil <- dir_ls("data/rayshaded") %>% as.vector()
# 1. Merge 20 meter rasters

if(merge) {
  library(gdalUtils)
  rmerged <-
    gdalUtils::mosaic_rasters(c(fil[2:8], fil[1]),
                              dst_dataset = "tmp.tif")
}

# 2. tile the stuff

#library(fs)
#dir_create("/net/www/export/home/hafri/einarhj/public_html/tiles2/mb-rayshaded")
library(tiler)
tile(file = "tmp.tif",
     tiles = "/net/www/export/home/hafri/einarhj/public_html/tiles2/mb-rayshaded",
     zoom = "4-12")

system("chmod -R a+rx /net/www/export/home/hafri/einarhj/public_html/tiles2/mb-rayshaded")

