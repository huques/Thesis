library(dplyr)
library(sf)


non_id_constraints <- bli_constraints_v2 %>%
  select(contains("con"))

df <- st_join(st_centroid(taxlots_pruned), non_id_constraints)

glimpse(df)

count_constraints <- !is.na(non_id_constraints %>% 
                              st_drop_geometry())
sum(rowSums(count_constraints) < 1, na.rm = T)

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

wetlands <- bli_constraints_v2 %>%
  dplyr::filter(conWetland == "True")

pzone <- bli_constraints_v2 %>%
  dplyr::filter(conPovrly == "True")

czone <- bli_constraints_v2 %>%
  dplyr::filter(conCovrly == "True")


floodway_geom <- st_combine(st_geometry(floodway))
wetlands_geom <- st_combine(st_geometry(wetlands))
floodplain_geom <- st_combine(st_geometry(floodplain))
pzone_geom <- st_combine(st_geometry(pzone))
czone_geom <- st_combine(st_geometry(czone))


st_geometry(df) <- st_geometry(taxlots_pruned)

# -------------------------------------------
# FLOODWAY

# generate 1 feature data frame that contains the environmental layer
d <- data.frame(pct_conFldway = 1)
st_geometry(d) <- floodway_geom %>% lwgeom::st_make_valid()

# get all lots found within the constraint
lots <- df %>%
  filter(conFldway == "True") 

# create total taxlot area variable
lots$tl_area <- st_area(st_geometry(lots))

# intersect the taxlots with the 1-layer sf object
x <- st_intersection(lots, d)

# generate pct of constraint in lot variable by dividing the area of the geometry returned from
# the st_intersection() by the total taxlot area
x$pct_conFldway <- st_area(st_geometry(x)) / lots$tl_area

# trim the data frame x, in preparation for the join back to full data set
x %<>% select(pct_conFldway, STATE_ID) %>%
  st_drop_geometry()

df <- left_join(df, x, by = "STATE_ID")

# -------------------------------------------
# WETLANDS 
d <- data.frame(pct_conWetland = 1)
st_geometry(d) <- wetlands_geom %>% lwgeom::st_make_valid()

lots <- df %>%
  filter(conWetland == "True") 

lots$tl_area <- st_area(st_geometry(lots))

x <- st_intersection(lots, d)
x$pct_conWetlands <- st_area(st_geometry(x)) / lots$tl_area

x %<>% select(pct_conWetlands, STATE_ID) %>%
  st_drop_geometry()

df <- left_join(df, x, by = "STATE_ID")

# -------------------------------------------
# 100-YEAR FLOODPLAIN
d <- data.frame(pct_conFld100 = 1)
st_geometry(d) <- floodplain_geom %>% lwgeom::st_make_valid()

lots <- df %>%
  filter(conFld100 == "True") 
lots$tl_area <- st_area(st_geometry(lots))

x <- st_intersection(lots, d)
x$pct_conFld100 <- st_area(st_geometry(x)) / lots$tl_area

x %<>% select(pct_conFld100, STATE_ID) %>%
  st_drop_geometry()

df <- left_join(df, x, by = "STATE_ID")

# -------------------------------------------
# C-ZONE
d <- data.frame(pct_conCovrly = 1)
st_geometry(d) <- czone_geom %>% lwgeom::st_make_valid()

lots <- df %>%
  filter(conCovrly == "True") 
lots$tl_area <- st_area(st_geometry(lots))

x <- st_intersection(lots, d)
x$pct_conCovrly <- st_area(st_geometry(x)) / lots$tl_area

x %<>% select(pct_conCovrly, STATE_ID) %>%
  st_drop_geometry()

df <- left_join(df, x, by = "STATE_ID")

# -------------------------------------------
# P-ZONE
d <- data.frame(pct_conPovrly = 1)
st_geometry(d) <- pzone_geom %>% lwgeom::st_make_valid()

lots <- df %>%
  filter(conPovrly == "True") 
lots$tl_area <- st_area(st_geometry(lots))

x <- st_intersection(lots, d)
x$pct_conPovrly <- st_area(st_geometry(x)) / lots$tl_area

x %<>% select(pct_conPovrly, STATE_ID) %>%
  st_drop_geometry()

df <- left_join(df, x, by = "STATE_ID")


# 12:13 - 



