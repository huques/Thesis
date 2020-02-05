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

ˆ


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
# `shp` refers to loaded sf object, `time` is a string of the date associated with the zoning file
# and will help with the naming convention
addZone <- function(shp, time){
  require("dplyr")
  require("sf")
  require("magrittr")
  
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
  intersect <- st_intersection(taxlots_pruned, z) 
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
df <- left_join(taxlots_pruned, addZone(zoningaug2016, "8.2016"), by = "STATE_ID")
df <- left_join(df, addZone(zoningfeb2014, "2.2014"), by = "STATE_ID")
df <- left_join(df, addZone(zoningaug2014, "8.2014"), by = "STATE_ID")
df <- left_join(df, addZone(zoningfeb2015, "2.2015"), by = "STATE_ID")
df <- left_join(df, addZone(zoningaug2015, "8.2015"), by = "STATE_ID")
df <- left_join(df, addZone(zoningfeb2016, "2.2016"), by = "STATE_ID")
df <- left_join(df, addZone(zoningfeb2018, "2.2018"), by = "STATE_ID")
df <- left_join(df, addZone(zoningaug2017, "8.2017"), by = "STATE_ID")
df <- left_join(df, addZone(zoningaug2018, "8.2018"), by = "STATE_ID")
# -----------------------------------------------
# Generate zoning change dummies

factorzones <- df %>%
  dplyr::select(contains("zone"), STATE_ID) %>%
  dplyr::select(STATE_ID, zone.2.2014, zone.8.2014, zone.2.2015, zone.8.2015, zone.2.2016,
                zone.8.2016, zone.8.2017, zone.2.2018, zone.8.2018) 

# Check if any changes occur (does not account for up/down zoning)
isDifferent <- function(row){
  r <- factorzones[row,] %>%
    st_drop_geometry()
  r <- as.character(unlist(as.matrix(r)))
  print(r)
  rle <- rle(r)
  output <- rep(F, length(r))
  names(output) <- names(r)
  output[1] <- r[1]
  
  for(i in rle$values[-c(1,2)]){
    change <- min(which(r == i))
    output[change] <- TRUE
  }
  output
}

list <- lapply(1:nrow(factorzones), isDifferent)
# 4:45 - 4:48 


# Get names of all the zone map times to create boolean change variables
names <- colnames(factorzones)
chg_names <- gsub("zone", "zonechg", names)
chg_names <- dplyr::setdiff(chg_names, "Shape")

df1 <- data.frame(matrix(unlist(list), nrow=length(list), byrow=T))
colnames(df1) <- chg_names

df1 <- df1 %>%
  select(-STATE_ID) %>%
  mutate_all(as.logical) 

rsums <- df1 %>% rowSums()

df1$STATE_ID <- factorzones$STATE_ID

# Final zoning variables join
x <- left_join(factorzones, df1, by = "STATE_ID")

                   