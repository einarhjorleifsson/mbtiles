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
# ------------------------------------------------------------------------------

# Food for thought:
#   https://gis.stackexchange.com/questions/234512/matching-two-rasters-with-different-projections-and-resolution

merge <- TRUE

# 1. Merge 20 meter rasters

if(merge) {
  library(gdalUtils)
  rmerged <-
    gdalUtils::mosaic_rasters(c("data/rayshaded/rayshaded_jokulbanki_a2015_30m.tif",
                                "data/rayshaded/rayshaded_kolbeinseyjahryggur_a2002_a2004_20m.tif",
                                "data/rayshaded/rayshaded_kolluall_a2008_a2011_20m.tif",
                                "data/rayshaded/rayshaded_langanesgrunn_a2005_20m.tif",
                                "data/rayshaded/rayshaded_latragrunn_a2011_20m.tif",
                                "data/rayshaded/rayshaded_nesdjup_a2009_20m.tif",
                                "data/rayshaded/rayshaded_reykjaneshryggur_a2003_a2004_a2006_20m.tif",
                                "data/rayshaded/rayshaded_sunnan_selvogsbanka_a2015_30m.tif"),
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

