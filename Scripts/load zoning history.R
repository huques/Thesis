#----------------------
# GDB sent 11/22 via Dropbox

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

zoningaug2014 <- st_read("./DATA/Zoning_History/Zoning_2014_Aug_pdx.shp")
zoningfeb2014 <- st_read("./DATA/Zoning_History/Zoning_2014_Feb_pdx.shp")
zoningaug2015 <- st_read("./DATA/Zoning_History/Zoning_2015_Aug_pdx.shp")
zoningfeb2015 <- st_read("./DATA/Zoning_History/Zoning_2015_Feb_pdx.shp")
zoningaug2016 <- st_read("./DATA/Zoning_History/Zoning_2016_Aug_pdx.shp")
zoningfeb2016 <- st_read("./DATA/Zoning_History/Zoning_2015_Feb_pdx.shp")
zoningaug2017 <- st_read("./DATA/Zoning_History/Zoning_2017_Aug_metro.shp")
zoningaug2018 <- st_read("./DATA/Zoning_History/Zoning_2018_Aug_pdx.shp")
zoningfeb2018 <- st_read("./DATA/Zoning_History/Zoning_2018_Feb_pdx.shp")

mapview(zoningaug2014)
dim(zoningaug2014)

# Goal: capture zoning changes
# 1) What do the columns in the zoning history shapefiles mean? i.e. which variable
# will we use to keep track of the zone a taxlot is within? 

# 2) Zoning lookup located here: https://gis-pdx.opendata.arcgis.com/datasets/zoning-lookup/
# so it looks like our variable is "ZONE"

zones <- as.list(zoningfeb2014, zoningaug2014, zoningfeb2015, zoningaug2015, zoningfeb2016, 
                 zoningaug2016, zoningaug2017, zoningfeb2018, zoningaug2018)

sapply(zones, colnames)

# ----------------------------
# Add zero distance buffers so that the st_intersection can be run
zoningaug2014 %<>%
  st_buffer(0)

testjoint.5 <- testjoint5 %>%
  st_buffer(0)
# ----------------------------

zaug2014 <- zoningaug2014 %>%
  rename(zone.aug2014 = ZONE) %>%
  select(zone.aug2014)

test <- st_intersection(testjoint.5, zaug2014) 

# There are 14,659 multiple-state id observations and 5,300 of these have at least 2 zones that 
# intersect the taxlot.
zone.overlap <- test %>%
  arrange(STATE_ID) %>%
  mutate(zone.aug2014 = as.character(zone.aug2014)) %>%
  group_by(STATE_ID) %>%
  mutate(n = n(),
         zone.copy = zone.aug2014[1]) %>%
  filter(n > 1) %>%
  select(n, zone.aug2014, zone.copy, STATE_ID)

zone.overlap$zone.area <- as.numeric(st_area(st_geometry(zone.overlap)))

# dim = 6621 x 7
# Here, I've gone with the zone that comprises the largest area within a split up tax lot. But
# this may be misleading for taxlots with many splits or those with close to even splits (these
# lots are most likely mixed-use). We could create a percentage/threshold value.

# Take only the portions with larger than 1/2 the total zone area. Dim = 6506. 
# There are 115 observations that are equal to the max area but are less than half the total area.
big.zone.overlap <- zone.overlap %>%
  group_by(STATE_ID) %>%
  mutate(sum.zone.area = sum(zone.area),
         max.zone.area = max(zone.area)) %>%
  filter(zone.area > .5*sum.zone.area)

wonky <- zone.overlap %>%
  group_by(STATE_ID) %>%
  mutate(sum.zone.area = sum(zone.area),
         max.zone.area = max(zone.area)) %>%
  filter(zone.area < .5*sum.zone.area & zone.area == max.zone.area)

wonkyids <- wonky %>% pull(STATE_ID) # come back to these in later years to see how much their 
# zones fluctuate. For now, just take the max rather than the 1/2 threshold.

# -----------------------------
# START TO FINISH HISTORICAL ZONES - AUGUST 2014

# Rename loaded shapefile & variable we're interested in
zaug2014 <- zoningaug2014 %>%
  rename(zone.aug2014 = ZONE) %>%
  select(zone.aug2014)

# This intersection has repeated STATE_IDs due to taxlots that intersect with several zone geometries
test <- st_intersection(testjoint5, zaug2014) 

test$zone.area.aug2014 <- as.numeric(st_area(st_geometry(test)))

# Collapse test so STATE_ID is 1:1
test %<>%
  arrange(STATE_ID) %>%
  mutate(zone.aug2014 = as.character(zone.aug2014)) %>%
  group_by(STATE_ID) %>%
  mutate(n.zonesaug2014 = n(),
         sum.zone.area.aug2014 = sum(zone.area.aug2014),
         max.zone.area = max(zone.area.aug2014)) %>%
  filter(zone.area.aug2014 == max.zone.area) %>%
  select(STATE_ID, zone.aug2014, zone.area.aug2014, sum.zone.area.aug2014) %>%
  st_drop_geometry()

# Join the zones
testjoint7 <- left_join(testjoint5, test, by = "STATE_ID")
# -----------------------------------------------

# TURN ZONE WORKFLOW ABOVE INTO FUNCTION

# we may be able to turn the above into a workflow for all zones. First let's check if our variable
# ZONE is present in all of the loaded shapefiles. Yep, ZONE shows up all 9 times.  

colnames(zoningaug2014)
colnames(zoningfeb2014)
colnames(zoningfeb2015)
colnames(zoningaug2015)
colnames(zoningfeb2016)
colnames(zoningaug2016)
colnames(zoningfeb2018)
colnames(zoningaug2018)
colnames(zoningaug2017)

# Rename loaded shapefile & variable we're interested in

joinZones <- function(shp, time){
  require("dplyr")
  require("sf")
  
  z <- shp #**** input can be fed here
  zone_name <- paste0("zone.", time)
  print(zone_name)
  area_name <- paste0("zone.area.", time)
  sum_area_name <- paste0("sum.zone.area.", time)

  z %<>%
    rename(!! zone_name := ZONE) %>%
    select(!! zone_name) %>%
    st_buffer(0)
  
  area <- sym(area_name)
  area <- enquo(area)
  sum_area <- sym(sum_area_name)
  sum_area <- enquo(sum_area)

  # This intersection has repeated STATE_IDs due to taxlots that intersect with several zone geometries
  intersect <- st_intersection(testjoint5, z) 
  intersect[area_name] <- as.numeric(st_area(st_geometry(intersect)))

    # Collapse test so STATE_ID is 1:1
  intersect %<>%
    arrange(STATE_ID) %>%
    group_by(STATE_ID) %>%
    mutate(!! sum_area_name := sum(!! area),
           max_area := max(!! area)) %>%
    filter(!! area == max_area) %>%
    select(STATE_ID, !! zone_name, !! area_name, !! sum_area_name) %>%
    st_drop_geometry()
  
  # Join the zones
  #testjoint7 <- left_join(testjoint5, test, by = "STATE_ID")
  intersect
}

# Call the function to join each zoning history & do a left_join
df <- left_join(testjoint5, joinZones(zoningaug2016, "aug2016"), by = "STATE_ID")
df <- left_join(df, joinZones(zoningfeb2014, "feb2014"), by = "STATE_ID")
df <- left_join(df, joinZones(zoningaug2014, "aug2014"), by = "STATE_ID")
df <- left_join(df, joinZones(zoningfeb2015, "feb2015"), by = "STATE_ID")
df <- left_join(df, joinZones(zoningaug2015, "aug2015"), by = "STATE_ID")
df <- left_join(df, joinZones(zoningfeb2016, "feb2016"), by = "STATE_ID")
df <- left_join(df, joinZones(zoningfeb2018, "feb2018"), by = "STATE_ID")
df <- left_join(df, joinZones(zoningaug2017, "aug2017"), by = "STATE_ID")
df <- left_join(df, joinZones(zoningaug2018, "aug2018"), by = "STATE_ID")
# -----------------------------------------------
# Generate zoning change dummies

factorzones <- df %>%
  dplyr::select(contains("zone")) %>%
  dplyr::select_if(is.factor)

# Check if any changes occur
isDifferent <- function(row){
  zone1 <- factorzones[row, 2]
  zone1 <- as.character(zone1[[1]])
  
  r <- factorzones[row,] %>%
    st_drop_geometry()
  r <- unlist(as.matrix(r))
  
  bool <- zone1 != r
  sum(bool[-1])
}


