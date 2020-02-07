library(dplyr)
library(sf)


non_id_constraints <- bli_constraints_v2 %>%
  select(contains("con"))

df <- st_join(st_centroid(taxlots_pruned), non_id_constraints)

glimpse(df)

count_constraints <- !is.na(non_id_constraints %>% st_drop_geometry())
sum(rowSums(count_constraints) < 1, na.rm = T)
# includes only those taxlots that have a constraint

sum(df$conWetland, na.rm = T)

df.1 <- df %>% select(contains("con"))
df.1 <- !is.na(df.1 %>% st_drop_geometry())
sum(rowSums(df.1) < 1, na.rm = T)
colSums(df.1)

# There are 12975 observations with no constraints, yay!

# Next want to reconstruct the original constraints layers in order to get
# percentage of lot within constraint geometries for the 4 partial taxlot
# constraints: pzone, czone, floodplain, floodway

floodway <- bli_constraints_v2 %>%
  dplyr::filter(conFldway == "True")

floodplain <- bli_constraints_v2 %>%
  dplyr::filter(conFld100 == "True")

pzone <- bli_constraints_v2 %>%
  dplyr::filter(conPovrly == "True")

czone <- bli_constraints_v2 %>%
  dplyr::filter(conCovrly == "True")


floodway_geom <- st_combine(st_geometry(floodway))
floodplain_geom <- st_combine(st_geometry(floodplain))
pzone_geom <- st_combine(st_geometry(pzone))
czone_geom <- st_combine(st_geometry(czone))



st_geometry(df) <- st_geometry(taxlots_pruned)
x <- st_join(df, floodplain_geom)


