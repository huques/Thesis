library(sf)
library(magrittr)
library(tidyverse)

# GDB5 was created in ArcMap by intersecting the entire tree_canopy.gdb with the rlis_2019
# taxlots layer

gdb5 <- "./DATA/canopy_20200210.gdb"
st_layers(gdb5) # there are two intersection layers in here because i accidentially made a copy
# they are exactly the same though!

canopy <- st_read(gdb5, "canopy_taxlot_intersect") # note: this line takes ~4 mins to run

# grab the ids we're using in the analysis (from taxlot layer)
ids <- taxlots_pruned %>%
  pull(STATE_ID)

# create new data frame in order to calculate total taxlot area for our "percentage of lot 
# covered by canopy" variable
taxlot_areas <- taxlots_pruned %>%
  rename(taxlot_area = Shape_Area) %>%
  select(STATE_ID, taxlot_area) %>% 
  st_drop_geometry()

# This chunk collapses canopy by STATE_ID and generates canopy coverage ratios
canopy2 <- canopy %>%
  filter(STATE_ID %in% ids) %>% # filter for just those STATE_IDs in the taxlots pruned data set
  rename(canopy_area = Shape_Area) %>%
  left_join(taxlot_areas, by = "STATE_ID") %>% # join the taxlot areas by state_id (for the denominator)
  st_drop_geometry() %>% # dropped because we had many self-intersections when trying to summarize
  group_by(STATE_ID) %>% 
  summarise(pct_canopy_cov = sum(canopy_area) / taxlot_area[1], # take the first element in taxlot_area
            total_canopy_cov = sum(canopy_area), # save numerator and denominator separately
            taxlot_area = taxlot_area[1]) 

# should end up with 33387 observations

# Join the newly created variable to the data frame
df$pct_canopy_cov <- NA

can_cov_var <- canopy2 %>%
  select(STATE_ID, pct_canopy_cov)

df <- left_join(df, can_cov_var, by = "STATE_ID")



  









