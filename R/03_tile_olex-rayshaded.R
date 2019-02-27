# ------------------------------------------------------------------------------
# Input files: olex data (from 2016)
# Output files: in /net/www/..../einarhj/public_html/tiles2
#
# Mail from Ole Benjamin Hestvik <oleb@olex.no> on 2016-06-26:
#
# Hi Haraldur et al,
# Here is an export of all our Olex data in the region 60N -31E to 70N -4E.
# Resolution is 112 meters, which is the next step up from 45 meters.
#
# Some of your own data is also included. That is data that has been donated some years ago.
#
# The format is a compressed text file. Lines starting with # are comments.
# The format is latitude longitude depth; positions in degrees, depths in meters.
#
# Best regards, Ole B.
#
#
# Run this as:
#  nohup R < R/03_tile_olex-rayshaded.R --vanilla &
#
# ------------------------------------------------------------------------------

library(raster)
library(rayshader)
library(sf)
library(tiler)
library(fs)
library(tidyverse)

createtif <- FALSE
tile.dir <- "/net/www/export/home/hafri/einarhj/public_html/tiles2/olex-rayshaded"

if(createtif) {

  # crop and mask at 500 m

  fil <- "~/stasi/gis/sjomaelingar/data_spatial_polygons/z0500m_polygons.shp"
  z500 <-
    read_sf(fil) %>%
    st_buffer(dist = 12000) %>%
    st_transform(crs = 4326)

  dy <- 0.002 # decimal degrees, NS equal to ~222 m

  # olex
  #  seems to be ~0.001 units lat and ~0.002 degree units lon
  d <-
    read_table("data/olex/island2016-112m.txt", skip = 3, col_names = c("y", "x", "z")) %>%
    filter(x < -10) %>%
    dplyr::select(x, y, z) %>%
    mutate(z = -z)

  #d2 <-
  #  d %>%
  #  filter(between(x, -20.3, -20.275),
  #         between(y, 63.5, 63.51)) %>%
  #  distinct()
  #d2 %>%
  #  ggplot(aes(x, y)) +
  #  geom_point(size = 0.01) +
  #  coord_map()

  d2 <-
    d %>%
    #approx 222 meters (0.002 degress north-south)
    mutate(x = gisland::grade(x, dy*2),
           y = gisland::grade(y, dy)) %>%
    # Try this instead of above
    group_by(x, y) %>%
    summarise(z = mean(z, na.rm = TRUE)) %>%
    ungroup()
  r <- rasterFromXYZ(d2)
  proj4string(r) <- "+proj=longlat"
  r <- crop(r, z500)
  r <- mask(r, z500)
  plot(r)

  m <- matrix(raster::extract(r, raster::extent(r), buffer = 1000),
              nrow = ncol(r), ncol = nrow(r))
  print("Rayshading")
  # add a raytraced layer from sun direction

  rayshaded <-
    m %>%
    sphere_shade(zscale = 5)


  print("Reconstructing raster brick")
  rb <- raster::brick(rayshaded,
                      xmn = 0.5, xmx = dim(rayshaded)[2] + 0.5, ymn = 0.5,
                      ymx = dim(rayshaded)[1] + 0.5)
  proj4string(rb) <- proj4string(r)
  extent(rb) <- extent(r)
  values(rb[[1]]) <- scales::rescale(values(rb[[1]]), from = c(0, 1), to = c(0, 255))
  values(rb[[2]]) <- scales::rescale(values(rb[[2]]), from = c(0, 1), to = c(0, 255))
  values(rb[[3]]) <- scales::rescale(values(rb[[3]]), from = c(0, 1), to = c(0, 255))
  j <- is.na(values(r))
  values(rb[[1]])[j] <- NA
  values(rb[[2]])[j] <- NA
  values(rb[[3]])[j] <- NA

  print("Writing raster")
  writeRaster(rb,
              "data/olex/olex-rayshaded.tif",
              options = "INTERLEAVE=BAND",
              overwrite = TRUE)
}

# no cards up my sleeve
if(dir_exists(tile.dir)) dir_delete(tile.dir)
dir_create(tile.dir)

tile(file = "data/olex/olex-rayshaded.tif",
     tiles = "/net/www/export/home/hafri/einarhj/public_html/tiles2/olex-rayshaded",
     zoom = "4-12")

system(paste0("chmod -R a+rx ", tile.dir))
