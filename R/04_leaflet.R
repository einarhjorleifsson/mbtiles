library(raster)
library(sf)
library(tidyverse)
library(leaflet)
library(htmlwidgets)
library(viridis)

# read in data -----------------------------------------------------------------
smb.sf <- st_read("/u3/haf/einarhj/raster/smb.shp")
smh.sf <- st_read("/u3/haf/einarhj/raster/smh.shp")
fishtrawl <- raster("/u3/haf/einarhj/raster/fishtrawl.tif")
nephrops  <- raster("/u3/haf/einarhj/raster/nephrops.tif")
shrimp    <- raster("/u3/haf/einarhj/raster/shrimp.tif")
dredge    <- raster("/u3/haf/einarhj/raster/dredge.tif")

# create colour scheme ---------------------------------------------------------
inf <- inferno(12, alpha = 1, begin = 0, end = 1, direction = -1)
pal.fishtrawl <- colorNumeric(inf, values(fishtrawl), na.color = "transparent")
pal.nephrops <- colorNumeric(inf, values(nephrops), na.color = "transparent")
pal.shrimp <- colorNumeric(inf, values(shrimp), na.color = "transparent")
pal.dredge <- colorNumeric(inf, values(dredge), na.color = "transparent")

# create footer text -----------------------------------------------------------
s1 <- paste0('Topography: ',
             'Multibeam from <a href="https://www.hafogvatn.is">Marine & Freshwater Rearch Institute</a>',
             ', LHG',
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

saveWidget(l, file = "/net/www/export/home/hafri/einarhj/public_html/mbtiles.html", selfcontained = FALSE)
system("chmod -R a+rx /net/www/export/home/hafri/einarhj/public_html/mbtiles.html")
system("chmod -R a+rx /net/www/export/home/hafri/einarhj/public_html/mbtiles_files")
