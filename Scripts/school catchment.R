# SCHOOL CATCHMENT AREAS
library(dplyr)
library(magrittr)

gdb <- "./DATA/data2.gdb"
school <- st_read(gdb, layer = "school_attendance_areas")

# Naive st_intersection 
df <- st_intersection(taxlots_pruned, school)

# Save multiple STATE_ID obs in `mult`
mult <- df %>%
  dplyr::group_by(STATE_ID) %>%
  dplyr::mutate(n = n()) %>%
  dplyr::filter(n > 1)

# We can see that adding the number of unique stateIDs that are observed more than once
# to the old dimensions is equal to the number of rows in df.
nrow(taxlots_pruned) + length(unique(mult$STATE_ID)) == nrow(df)

# Fix: choose a catchment area for all multiple STATE_ID lots depicted below. 
#mult %>%
#  arrange(STATE_ID) %>%
#  select(contains("SCH"), Shape_Area, Shape_Area.1) 
#  st_drop_geometry() %>%
#  head() %>%
#  kable() %>% 
#  kable_styling(full_width = F)


# Choose catchment area based on ratio of lot within that school area
mult$area.school <- st_area(st_geometry(mult))
df$area.school <- st_area(st_geometry(df))

mult %<>%
  group_by(STATE_ID) %>%
  mutate(max = max(area.school)) 

mult.big <- mult %>% 
  filter(as.numeric(max) == as.numeric(area.school)) 

#mult.small <- mult %>%
#  filter(as.numeric(max) != as.numeric(area.school)) 

#mult.big$STATE_ID == mult.small$STATE_ID # this vector should all be true

# Use st_combine to meld the broken boundaries from mult.small and mult.big geometry sets.
# note: I did not use st_union(st_geometry(mult.small), st_geometry(mult.big)) because
# st_union() takes the cartesian union of both giving a much larger feature set than neccessary, 
# we only want the diagonals

#for(r in 1:nrow(mult.big)){
#  st_geometry(mult.big[r,]) <- st_combine(c(st_geometry(mult.big)[r], 
#                                               st_geometry(mult.small)[r]))
#}

# Now, combine the fixed geometries and catchment areas with the single-observation
# subset of `df`
single.school <- df %>%
  group_by(STATE_ID) %>%
  mutate(n = n(),
         max = NA) %>%
  filter(n == 1) # This is the right number of rows, 34426

# Row number check (if TRUE, we haven't lost any observations in the join)
nrow(mult.big) + nrow(single.school) == nrow(taxlots_pruned)

df <- rbind(mult.big, single.school)

# Rename joined columns
df %<>%
  arrange(STATE_ID) %>%
  rename(Shape_Length_school = Shape_Length.1,
         Shape_Leng_school = Shape_Leng,
         Shape_Area_school = Shape_Area.1,
         area_school_insx = area.school)

# sanity check
taxlots_pruned  %<>% arrange(STATE_ID)
sum(df$STATE_ID != taxlots_pruned$STATE_ID) # note: if larger than 0, can't set geometry

# reset geometry to original taxlots level
st_geometry(df) <- st_geometry(taxlots_pruned)



