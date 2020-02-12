library(tidyr)
library(dplyr)
library(sf)
library(stringr)
library(data.table)
library(stringr)
library(sf)
library(mapview)
library(forcats)

# load data
gdb <- "./DATA/data2.gdb"
capacity <- st_read(gdb, layer = "bli_development_capacity")

# load taxlots_pruned too!!

# selects property id's and vacancy variable
vacancy <- capacity %>%
  select(STATE_ID, IS_VACANT, Shape) %>%
  rename(ShapeCapacity = Shape)

vacancy_pruned <- vacancy %>%
  group_by(STATE_ID) %>%
  slice(1) %>%
  mutate(VACANT=recode(IS_VACANT, 
                       "True" = 1,
                       ` `= 0)) %>%
  select(-IS_VACANT)


# creates a buffer called buffer_dist (measured in meters)
# adds this buffer as an additional geometry to the main dataset
buffer_dist <- 805

buffy <- taxlots_pruned %>%
  rename(ShapeBuffy = Shape) %>%
  st_buffer(buffer_dist)

# join buffy and vacancy_pruned 
vacant_join_buffy <- st_join(buffy, vacancy_pruned, left = TRUE) # returns all buffy

# calculates percent vacant houses in buffer
vacant_var <- vacant_join_buffy %>%
  arrange(STATE_ID.x) %>%
  group_by(STATE_ID.x) %>%
  mutate(n = n()) %>%
  mutate(VACANT = recode(VACANT, 
                       "1" = 1,
                       "0" = 0)) %>%
  summarize(percent_vacant = sum(VACANT)/n[1])
  

