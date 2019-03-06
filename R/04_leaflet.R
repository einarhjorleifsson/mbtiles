library(raster)
library(tidyverse)
library(leaflet)
library(mapview)
library(viridis)
library(sf)


smh <-
  read_csv("/net/hafkaldi.hafro.is/export/home/haf/einarhj/cronjobs/skip/older/smh2016.csv") %>%
  mutate(lon1 = -gisland::geo_convert(lon1),
         lon2 = -gisland::geo_convert(lon2),
         lat1 =  gisland::geo_convert(lat1),
         lat2 =  gisland::geo_convert(lat2),
         index = 1:n()) %>%
  mutate(lon2 = ifelse(square == 424 & townumber == 3, -24.7583, lon2))
smh.sf <-
  smh %>%
  dplyr::select(index, x = lon1, y = lat1) %>%
  bind_rows(smh %>%
              dplyr::select(index, x = lon2, y = lat2)) %>%
  st_as_sf(coords = c("x", "y"),
           crs = 4326) %>%
  group_by(index) %>%
  summarise(do_union = FALSE) %>%
  st_cast('LINESTRING')
#st_write(smh.sf, "/u3/haf/einarhj/raster/smh.shp")
fishtrawl <- read_rds("~/prj2/vms2/data/raster/fishtrawl.rds")
nephrops <- read_rds("~/prj2/vms2/data/raster/nephrops.rds")
shrimp <- read_rds("~/prj2/vms2/data/raster/shrimp.rds")
dredge <- read_rds("~/prj2/vms2/data/raster/dredge.rds")
#writeRaster(fishtrawl, filename = "/u3/haf/einarhj/raster/fishtrawl.tif")
#writeRaster(nephrops, filename = "/u3/haf/einarhj/raster/nephrops.tif")
#writeRaster(shrimp, filename = "/u3/haf/einarhj/raster/shrimp.tif")
#writeRaster(dredge, filename = "/u3/haf/einarhj/raster/dredge.tif")


inf <- inferno(12, alpha = 1, begin = 0, end = 1, direction = -1)
pal.fishtrawl <- colorNumeric(inf, values(fishtrawl), na.color = "transparent")
pal.nephrops <- colorNumeric(inf, values(nephrops), na.color = "transparent")
pal.shrimp <- colorNumeric(inf, values(shrimp), na.color = "transparent")
pal.dredge <- colorNumeric(inf, values(dredge), na.color = "transparent")


smb <-
  read_delim("/net/hafkaldi.hafro.is/export/home/haf/einarhj/cronjobs/skip/smb2018.tab",
             delim = "\t") %>%
  mutate(lon1 = -gisland::geo_convert(lon1),
         lon2 = -gisland::geo_convert(lon2),
         lat1 =  gisland::geo_convert(lat1),
         lat2 =  gisland::geo_convert(lat2))
smb.sf <-
  smb %>%
  dplyr::select(index, x = lon1, y = lat1) %>%
  bind_rows(smb %>%
              dplyr::select(index, x = lon2, y = lat2)) %>%
  st_as_sf(coords = c("x", "y"),
           crs = 4326) %>%
  group_by(index) %>%
  summarise(do_union = FALSE) %>%
  st_cast('LINESTRING')
#st_write(smb.sf, "/u3/haf/einarhj/raster/smb.shp")
fil <- "~/stasi/gis/sjomaelingar/data_spatial_polygons/z0500m_polygons.shp"
z500 <-
  read_sf(fil) %>%
  st_transform(crs = 4326)

s1 <- paste0('Topography: ',
             'Multibeam from <a href="https://www.hafogvatn.is">Marine & Freshwater Rearch Institute</a>',
             ' and depth from <a href="http://www.olex.no">Olex AS</a>. ')
s2 <- paste0('Trawl: Logbook data and VMS/AIS data. ')
s3 <- paste0(' Processing <a href="https://heima.hafro.is/~einarhj/gagnakvorn">details</a>.')
s0 <- paste0('DATA: ',
             s1,
             s2,
             s3)

l <-
  leaflet() %>%
  setView(lng = -19, lat = 65, zoom = 6) %>%
  addTiles(urlTemplate = "http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
           group = "Gervihnöttur",
           options = tileOptions(minZoom = 5, maxZoom = 12),
           attribution = s0) %>%
  addTiles(urlTemplate = "http://www.hafro.is/~einarhj/tiles2/olex-rayshaded/{z}/{x}/{y}.png",
           group = "Topography",
           options = tileOptions(minZoom = 5, maxZoom = 10)) %>%
  addTiles(urlTemplate = "http://www.hafro.is/~einarhj/tiles2/mb-rayshaded/{z}/{x}/{y}.png",
           group = "Topography",
           options = tileOptions(minZoom = 5, maxZoom = 12)) %>%
  addTiles(urlTemplate = "http://www.hafro.is/~einarhj/tiles2/mb2-rayshaded/{z}/{x}/{y}.png",
           group = "Topography",
           options = tileOptions(minZoom = 5, maxZoom = 12)) %>%
  #addTiles(urlTemplate = "http://www.hafro.is/~einarhj/tiles2/trial-sudurstrond/{z}/{x}/{y}.png",
  #         group = "s",
  #         options = tileOptions(minZoom = 5, maxZoom = 12)) %>%
  addPolylines(data = smb.sf,
               group = "SMB",
               weight = 2,
               col = "red",
               opacity = 0.8,
               fillOpacity = 0.5) %>%
  addPolylines(data = smh.sf,
               group = "SMH",
               weight = 2,
               col = "cyan",
               opacity = 0.8,
               fillOpacity = 0.5) %>%
  addRasterImage(nephrops, colors = pal.nephrops, opacity = 1, group = "Nephrops trawl",
                 maxBytes = Inf) %>%
  addRasterImage(shrimp, colors = pal.shrimp, opacity = 1, group = "Shrimp trawl",
               maxBytes = Inf) %>%
  addRasterImage(fishtrawl, colors = pal.fishtrawl, opacity = 1, group = "Fish trawl",
                 maxBytes = Inf) %>%
  addRasterImage(dredge, colors = pal.dredge, opacity = 1, group = "Dredge",
                 maxBytes = Inf) %>%
  addLayersControl(overlayGroups = c("Topography", "SMB", "SMH", "Fish trawl", "Nephrops trawl", "Shrimp trawl", "Dredge"),
                   options = layersControlOptions(collapsed = FALSE)) %>%
  hideGroup(c("SMH", "Fish trawl", "Nephrops trawl", "Shrimp trawl", "Dredge")) %>%
  addScaleBar(position = "bottomleft")

library(htmlwidgets)
saveWidget(l, file = "/net/www/export/home/hafri/einarhj/public_html/mbtiles.html", selfcontained = FALSE)
system("chmod -R a+rx /net/www/export/home/hafri/einarhj/public_html/mbtiles.html")
system("chmod -R a+rx /net/www/export/home/hafri/einarhj/public_html/mbtiles_files")
