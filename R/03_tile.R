# ------------------------------------------------------------------------------
# Input files: tif files in data/rayshaded
# Output files: in /net/www/..../einarhj/public_html/tiles2
#
# Run this as:
#  nohup R < R/03_tile.R --vanilla &
#
# To do: check if output files already exists
# ------------------------------------------------------------------------------

library(fs)
library(tiler)
library(tidyverse)


fil <- dir_ls("data/rayshaded")
dirnames <-
  paste0("/net/www/export/home/hafri/einarhj/public_html/tiles2/",
         c("jokulbanki", "kolbeinseyjarhryggur", "kolluall",
           "langanesgrunn", "latragrunn", "nesdjup",
           "reykjaneshryggur", "sunnan_selvogsbanka"))


for(i in 1:length(fil)) {

  print(dirnames[[i]])
  if(!dir_exists(dirnames[[i]])[[1]]) {
    dir_create(dirnames[[i]])
  }
  tile(file = fil[[i]], tiles = dirnames[[i]], zoom = "4-12")

}

system("chmod -R a+rx /net/www/export/home/hafri/einarhj/public_html/tiles2")
