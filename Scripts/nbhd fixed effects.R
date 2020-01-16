library(sf)
library(dplyr)
library(mapview)

# Bring in neighborhood fixed effects
testjoint5 <- st_intersection(testjoint4, nbhd)
dim(testjoint5)

# Problem: there are 567 observations where STATE_ID is double counted.
nbhd.overlap <- testjoint5 %>%
  arrange(STATE_ID) %>%
  dplyr::group_by(STATE_ID) %>%
  dplyr::mutate(n = n()) %>%
  dplyr::filter(n > 1)

# Calculate intersection areas. 
# Notice that new geometries were generated from the st_intersection() function
# used to create `testjoint5`. These geometries are the intersections between the 99 neighborhoods
# and our 34628 taxlots. A STATE_ID appears in `testjoint5` multiple times when a single taxlot 
# intersects more than one neighborhood. 
nbhd.overlap$area.nbhd <- st_area(st_geometry(nbhd.overlap))

#------------------ FIX MULTI STATE_ID DOUBLE COUNT -----------------------

# I determine which neighborhood to place a double-counted
# taxlot by keeping the observation with the max of the intersected areas. 

nbhd.overlap %<>%
  group_by(STATE_ID) %>%
  mutate(max = max(area.nbhd)) 

nbhd.big <- nbhd.overlap %>% # add containing containing max area by STATE_ID
  filter(as.numeric(max) == as.numeric(area.nbhd)) 

nbhd.small <- nbhd.overlap %>%
  filter(as.numeric(max) != as.numeric(area.nbhd)) 
# since nbhd.small has more rows than nbhd.big, we know that some taxlots
# intersect more than 2 neighborhoods.

nbhd.single <- testjoint5 %>%
  arrange(STATE_ID) %>%
  dplyr::group_by(STATE_ID) %>%
  dplyr::mutate(n = n()) %>%
  dplyr::filter(n == 1)


# This loop combines the geometries from where the STATE_IDs had split & replaces partial geometries
# in nbhd.big with complete geometries.
for(r in 1:nrow(nbhd.big)){
  id <- nbhd.big[r,]$STATE_ID
  tinydf <- nbhd.small %>%
    filter(STATE_ID == id)
  st_geometry(nbhd.big[r,]) <- st_combine(st_geometry(tinydf))
}
#-----------------------------------------
nbhd.single$area.nbhd <- NA # define this column on the observations 
# where it was not necessary to correct the geometries. This ensures rbind() works properly.
nbhd.single$max <- NA

testjoint5 <- rbind(nbhd.single, nbhd.big) # correct  number of dimensions!

dim(testjoint5) # note that the dimension of tj5 is smaller than tj4, meaning there are some
# properties in which there was no corresponding neighborhood. Therefore these are removed from the 
# sample, which is okay.

dim(testjoint4)

#----------- RENAME GEOMETRY FEATURES ------------------------------
colnames(testjoint5)

testjoint5 %<>%
  rename(Shape_Length.school = Shape_Length.1,
         Shape_Leng.school = Shape_Leng,
         Shape_Area.school = Shape_Area.1,
         school.insx.area = area.school,
         Shape_Leng.nbhd = Shape_Leng.1,
         Shape_Length.nbhd = Shape_Length.2,
         Shape_Area.nbhd = Shape_Area.2,
         nbhd.insx.area = area.nbhd)

