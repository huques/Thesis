library(sf)
library(sp)
library(mapview)
library(dplyr)

# ---------------------------------------
# This script uses taxlot level data. Could use any data set that includes the original
# 'taxlots_pruned' geometries (since that is our unit of observation). 

# This approach calculates distances using the centroids of MULTIPOLYGON taxlots. 
# So, in the process, the st_geometry() attribute of the taxlot spatial data frame is changed from polygons to points.
# But the geometry can be reset to MULTIPOLYGONS afterward.

# Load UGB shapefile
ugb <- st_read("./DATA/ugb/ugb.shp") %>% 
  st_transform(2913) %>% 
  st_cast(., "MULTILINESTRING")

# Convert to sp object since we use the rgeos::NearestPoints function that requires this
# data type
ugb.sp <- as_Spatial(ugb)


# Pull taxlot polygons & calculate centroids
centroids <- st_centroid(st_geometry(taxlots_pruned))
centroids.sp <- as_Spatial(centroids)

# Add STATE_IDs and save as a data frame
centroids_df <- st_as_sf(data.frame(STATE_ID = taxlots_pruned$STATE_ID,
                           geometry = centroids))



# gNearestPoints returns vector of nearest point on taxlot (the centroid) 
# and the nearest point on the ugb. We take the ugb point, the second item in the list.

# Initialize empty list
nearest_points <- list(NA, nrow(centroids_df))

# call gNearestPoints over all observations in `taxlots` to return list of point geometries
for(i in 1:nrow(centroids_df)){
  nearest_points[i] <- st_as_sf(rgeos::gNearestPoints(centroids.sp[i,], ugb.sp)[2,])
}

# Combine/"unlist" the point geometries
nearest_points <- do.call(c, nearest_points)
# runtime: ~4 mins

# When given two vectors, st_distance(a, b) returns distance between all pairs of points in a and a.
# ex. if a = c(1,2,3) b = c(0, 9, 8). then st_distance(a, b) = (1, 8, 7, 2, 7, 6, 3, 6, 5)
# mapply() loops over nearest_points and centroids simultaneously so usign the above a, b, 
# we end up with (1,7,5)
dist_to_ugb <- mapply(FUN = st_distance, nearest_points, centroids)
# runtime: ~1 min

#taxlots_pruned$dist_ugb <- dist_to_ugb


