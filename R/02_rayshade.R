# ------------------------------------------------------------------------------
# Input files: tif files in data/from_h2o
# Output files: files in data/rayshaded
#
# Run this as:
#  nohup R < R/02_rayshade.R --vanilla &
#
# To do: read in only tif-files
#        check if output file already exists
# ------------------------------------------------------------------------------

library(fs)
library(raster)
library(rayshader)
library(tidyverse)
source("R/function_mb-rayshade.R")

fil <- dir_ls("data/from_h2o")
fil2 <- dir("data/from_h2o", full.names = FALSE)
for(i in 1:length(fil)) {

  print(fil[[i]])

  if(!file_exists(paste0("data/rayshaded/rayshaded_", fil2[[i]]))) {
    r <-
      raster(fil[[i]]) %>%
      mb_rayshade()
    print("Writing raster")
    writeRaster(r,
                paste0("data/rayshaded/rayshaded_", fil2[[i]]),
                options = "INTERLEAVE=BAND",
                overwrite = TRUE)
  }

}
