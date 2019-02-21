library(leaflet)
library(htmlwidgets)
dirtiled <- c("jokulbanki", "kolbeinseyjarhryggur", "kolluall",
              "langanesgrunn", "latragrunn", "nesdjup",
              "reykjaneshryggur", "sunnan_selvogsbanka")
l <-
  leaflet() %>%
  setView(lng=-19, lat=65, zoom = 5) %>%
  addTiles(urlTemplate = "http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
           group = "Gervihnöttur")
for(i in 1:length(dirtiled)) {
  l <-
    l %>%
    addTiles(urlTemplate = paste0("http://www.hafro.is/~einarhj/tiles2/",
                                  dirtiled[[i]],
                                 "/{z}/{x}/{y}.png"),
             group = "mb")
}

saveWidget(l, file = "/net/www/export/home/hafri/einarhj/public_html/mbtiles.html", selfcontained = FALSE)
system("chmod -R a+rx /net/www/export/home/hafri/einarhj/public_html/mbtiles.html")
system("chmod -R a+rx /net/www/export/home/hafri/einarhj/public_html/mbtiles_files")
