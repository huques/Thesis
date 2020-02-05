library(sf)
library(dplyr)
library(mapview)

gdb3 <- "./DATA/data_20191112.gdb"
nbhd <- st_read(gdb3, "neighborhoods_no_overlap")

# Bring in neighborhood fixed effects
df <- st_intersection(taxlots_pruned, nbhd)

# Problem: there are 567 observations where STATE_IDs are double counted.
nbhd.overlap <- df %>%
  arrange(STATE_ID) %>%
  dplyr::group_by(STATE_ID) %>%
  dplyr::mutate(n = n()) %>%
  dplyr::filter(n > 1 )

# Calculate intersection areas. 
# Notice that new geometries were generated from the st_intersection() function
# used to create `df`. These geometries are the intersections between the 99 neighborhoods
# and our 34628 taxlots. A STATE_ID appears in `df` multiple times when a single taxlot 
# intersects more than one neighborhood. 

#------------------ FIX MULTI STATE_ID DOUBLE COUNT -----------------------

# I place  a double-counted taxlot in the neighborhood that intersects a plurality of 
# its total area.

# Add area variable
nbhd.overlap$area.nbhd <- st_area(st_geometry(nbhd.overlap))

# Groupby STATE_ID and add a variable that is the maximum of the double counted taxlots' areas
nbhd.overlap %<>%
  group_by(STATE_ID) %>%
  mutate(max = max(area.nbhd)) 

nbhd.big <- nbhd.overlap %>%
  filter(as.numeric(max) == as.numeric(area.nbhd)) 

# DO NOT NEED TO DEFINE UNLESS WE NEED THE GEOMETRIES FOR SOME REASON
nbhd.small <- nbhd.overlap %>%
  filter(as.numeric(max) != as.numeric(area.nbhd)) 
# since nbhd.small has more rows than nbhd.big, we know that some taxlots
# intersect more than 2 neighborhoods.

nbhd.single <- df %>%
  arrange(STATE_ID) %>%
  dplyr::group_by(STATE_ID) %>%
  dplyr::mutate(n = n()) %>%
  dplyr::filter(n == 1)

#-----------------------------------------
# NOT NECESSARY!
# This loop combines the geometries from where the STATE_IDs had split & replaces partial geometries
# in nbhd.big with complete geometries.
#for(r in 1:nrow(nbhd.big)){
#  id <- nbhd.big[r,]$STATE_ID
#  tinydf <- nbhd.small %>%
#    filter(STATE_ID == id)
#  st_geometry(nbhd.big[r,]) <- st_combine(st_geometry(tinydf))
#}
#-----------------------------------------

nbhd.single$area.nbhd <- NA # define these columns to ensure rbind() works properly.
nbhd.single$max <- NA
df <- rbind(nbhd.single, nbhd.big) # correct  number of dimensions!

dim(df) # note that the dimension of the newly created df is smaller than the taxlots, meaning there 
# are some properties in which there was no corresponding neighborhood (this introduces selection
# bias). 

# RESOLVE SELECTION BIAS:
# list of STATE_IDS that were dropped
diff <- setdiff(unique(taxlots_pruned$STATE_ID), unique(df$STATE_ID))

# Rename ambiguous nbhd geometry columns 
df %<>%
  rename(Shape_Leng.nbhd = Shape_Leng,
         Shape_Length.nbhd = Shape_Length.1,
         Shape_Area.nbhd = Shape_Area.1,
         area.nbhd.insx = area.nbhd,
         NBHD_NAME = NAME)

# grab the lots for which no nbhd was recorded (those that went missing in the intersection)
# initialize vars that were added in the intersection (so rbind can join properly)
removed_lots <- taxlots_pruned %>%
  filter(STATE_ID %in% diff) %>%
  mutate(Shape_Leng.nbhd = NA,
         Shape_Length.nbhd = NA,
         Shape_Area.nbhd = NA,
         area.nbhd.insx = NA, 
         NBHD_NAME = NA,
         MapLabel = NA,
         COMMPLAN = NA,
         SHARED = NA,
         COALIT = NA,
         HORZ_VERT = NA,
         NBRNUM = NA,
         AUDIT_NBRH = NA,
         OBJECTID = NA,
         n = NA,
         max = NA)
         
# binding retains the lots that had dropped out!
df <- rbind(df, removed_lots)





