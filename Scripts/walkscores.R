library(tidyverse)
library(sf)

# Read walkscores from here: 
walk_gdb <- "./DATA/Complete_Neighborhoods_Scoring_Surface"
walk <- st_read(walk_gdb, 
           layer = "Complete_Neighborhoods_Scoring_Surface")

# Transform crs from 4326 to 2913
walk %<>% st_transform(2913) %>%
  select(CN_score) # dropped all other variables (like shape area) to avoid
# renaming things and later confusion

# Join!
df <- st_join(st_centroid(taxlots_pruned), walk)

