mb_rayshade <- function(r) {

  m <- matrix(raster::extract(r, raster::extent(r), buffer = 1000),
              nrow = ncol(r), ncol = nrow(r))

  print("Rayshading")
  #   add a raytraced layer from sun direction
  #raymat = ray_shade(m)


  #   Add an ambient occlusion shadow layer, which models
  #     lighting from atmospheric scattering
  #ambmat = ambient_shade(m)

  rayshaded <-
    sphere_shade(m, texture = "imhof1") #%>%
    #add_shadow(raymat, max_darken = 0.9) %>%
    #add_shadow(ambmat, max_darken = 0.9)

  print("Reconstructing raster brick")
  rb <- raster::brick(rayshaded,
                      xmn = 0.5, xmx = dim(rayshaded)[2] + 0.5, ymn = 0.5,
                      ymx = dim(rayshaded)[1] + 0.5)
  #raster::plotRGB(rb, scale = 1)
  proj4string(rb) <- proj4string(r)
  extent(rb) <- extent(r)
  values(rb[[1]]) <- scales::rescale(values(rb[[1]]), from = c(0, 1), to = c(0, 255))
  values(rb[[2]]) <- scales::rescale(values(rb[[2]]), from = c(0, 1), to = c(0, 255))
  values(rb[[3]]) <- scales::rescale(values(rb[[3]]), from = c(0, 1), to = c(0, 255))
  j <- is.na(values(r))
  values(rb[[1]])[j] <- NA
  values(rb[[2]])[j] <- NA
  values(rb[[3]])[j] <- NA

  return(rb)
}

