# ------------------------------------------------------------------------------
# Input files: olex data (from 2016)
# Output files: in /net/www/..../einarhj/public_html/tiles2
#
#
# Run this as:
#  nohup R < R/03_tile_mb2-rayshaded.R --vanilla &
#
# ------------------------------------------------------------------------------


dy <- 0.002 # decimal degrees, 0.001 equal to ~111 m

createtif <- TRUE

library(raster)
library(rayshader)
library(tiler)
library(rio)
library(tidyverse)

# ------------------------------------------------------------------------------
# Get files --------------------------------------------------------------------
# A bit of a messy file structure on the homepage, hence the lengthy code

res <- list()

#
# ------------------------------------------------------------------------------
# 01 Arnarfjordur

counter <- 1

fil <- "https://www.hafogvatn.is/static/files/Gamli_vefur/arn20m.zip"
download.file(fil, destfile = "tmp/tmp.zip")
unzip("tmp/tmp.zip", exdir = "tmp")

res[[counter]] <-
  read_delim("tmp/af20m.xyz", col_names = c("x", "y", "z"), delim = "\t") %>%
  select(x,y,z) %>%
  mutate(z = -z)

# ------------------------------------------------------------------------------
# 02 Drekasvæðið

counter <- counter + 1

fil <- "https://www.hafogvatn.is/static/files/Gamli_vefur/dreki_100m.zip"
download.file(fil, destfile = "tmp/tmp.zip")
unzip("tmp/tmp.zip", exdir = "tmp")

res[[counter]] <-
  read_delim("tmp/Dreki_100m.txt", col_names = c("y", "x", "z"), delim = "\t") %>%
  select(x,y,z) %>%
  mutate(z = -z)

# ------------------------------------------------------------------------------
# 03 Hali Dohrn

counter <- counter + 1

fil <- "https://www.hafogvatn.is/static/files/Gamli_vefur/hali.dohrn.dat.zip"
download.file(fil, destfile = "tmp/tmp.zip")
unzip("tmp/tmp.zip", exdir = "tmp")

res[[counter]] <-
  read_table("tmp/hali.dohrn.dat", col_names = c("y","x","z")) %>%
  select(x,y,z) %>%
  mutate(z = -z)

# ------------------------------------------------------------------------------
# 04 Isafjarðardjúp

counter <- counter + 1

fil <- "https://www.hafogvatn.is/static/files/Gamli_vefur/isaf_nytt_20m.zip"
download.file(fil, destfile = "tmp/tmp.zip")
unzip("tmp/tmp.zip", exdir = "tmp")

res[[counter]] <-
  read_table("tmp/isaf_nytt_20m.dat", col_names = c("y","x","z")) %>%
  select(x,y,z) %>%
  mutate(z = -z)

# ------------------------------------------------------------------------------
# 08 Kötluhryggir

counter <- counter + 1

fil <- "https://www.hafogvatn.is/static/files/Gamli_vefur/kotluhr_100m.zip"
download.file(fil, destfile = "tmp/tmp.zip")
unzip("tmp/tmp.zip", exdir = "tmp")

res[[counter]] <-
  read_table("tmp/kotluhr_100m.dat", col_names = c("y","x","z")) %>%
  select(x,y,z) %>%
  mutate(z = -z)


# ------------------------------------------------------------------------------
# 11 Lónsdjúp

counter <- counter + 1

fil <- "https://www.hafogvatn.is/static/files/Gamli_vefur/lonsdjup.zip"
download.file(fil, destfile = "tmp/tmp.zip")
unzip("tmp/tmp.zip", exdir = "tmp")

res[[counter]] <-
  read_delim("tmp/lonsdj_30m.xyz", col_names = c("x","y","z"), delim = "\t") %>%
  select(x,y,z) %>%
  mutate(z = -z)


# ------------------------------------------------------------------------------
# 15 Skerjadjúp

counter <- counter + 1

fil <- "https://www.hafogvatn.is/static/files/Gamli_vefur/skerjadjup.txt"
res[[counter]] <-
  import(fil) %>%
  as_tibble() %>%
  select(x = V2, y = V1, z = V3) %>%
  mutate(z = -z)

# ------------------------------------------------------------------------------
# 15 Vesturdjúp

counter <- counter + 1

fil <- "https://www.hafogvatn.is/static/files/Gamli_vefur/tot_2012_2009_100m.zip"
download.file(fil, destfile = "tmp/tmp.zip")
unzip("tmp/tmp.zip", exdir = "tmp")

res[[counter]] <-
  read_delim("tmp/tot_2012_2009_100m.txt", col_names = c("y","x","z"), delim = "\t") %>%
  select(x,y,z) %>%
  mutate(z = -z)
# ------------------------------------------------------------------------------
# 16 Víkuráll

counter <- counter + 1

fil <- "https://www.hafogvatn.is/static/files/Gamli_vefur/vikurall.zip"
download.file(fil, destfile = "tmp/tmp.zip")
unzip("tmp/tmp.zip", exdir = "tmp")

res[[counter]] <-
  read_delim("tmp/vikurall2a.xyz", col_names = c("x","y","z"), delim = "\t") %>%
  select(x,y,z) %>%
  mutate(z = -z)

if(createtif) {


  d <-
    res %>%
    bind_rows() %>%
    mutate(x = gisland::grade(x, 2 * dy),
           y = gisland::grade(y, dy)) %>%
    group_by(x, y) %>%
    summarise(z = mean(z, na.rm = TRUE))
  r <- rasterFromXYZ(d)
  proj4string(r) <- "+proj=longlat"

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
              "data/mb-xyz.tif",
              options = "INTERLEAVE=BAND",
              overwrite = TRUE)
}

tile(file = "data/mb-xyz.tif",
     tiles = "/net/www/export/home/hafri/einarhj/public_html/tiles2/mb2-rayshaded",
     zoom = "4-12")