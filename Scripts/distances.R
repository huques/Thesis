library(magrittr)
# Generate distance to city hall distances


# grab lat long from google maps
cityhall <- data.frame(place = "City Hall",
                       long = -122.679103,
                       lat = 45.515000)
# reformat from df to sf object
cityhall <- st_as_sf(cityhall, coords = c("long", "lat"))

# Set coordinate system
cityhall <- cityhall %>%
  st_set_crs(4326) %>%
  st_transform(2913)

taxlots_pruned %<>% 
  mutate(dist_cityhall = st_distance(cityhall, 
                                     taxlots_pruned,
                                     which = "Euclidean"))



