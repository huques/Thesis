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
vacant_join_buffy2 <- vacant_join_buffy %>%
  arrange(STATE_ID.x) %>%
  group_by(STATE_ID.x) %>%
  mutate(n = n()) %>%
  mutate(VACANT = recode(VACANT, 
                       "1" = 1,
                       "0" = 0)) %>%
  summarize(percent_vacant = sum(VACANT)/n[1])
  

##add "per_vac" to column "percent_vacant" in is_vacant 
##that corresponds to that property's RNO




















## NA for missing variables!!!!!!!!!!

fuck <- vacant_join_buffy %>%
  filter(RNO == "R034700650")
mapview(fuck)


#bigdata = capacity
#bufferdist = 805
#propertyid = RNO

get_percent_vacant <- function(bigdata, property_id, buffer_dist) {
  
  # reads in bigdata to create prelimiary dataset with variables of use
  vacancy <- bigdata %>%
    select(STATE_ID, RNO, TLID, IS_VACANT, Shape) %>%
    rename(ShapeOriginal = Shape)
  
  # creates a buffer of distance buffer_dist (measured in meters)
  buffy <- vacancy %>%
    st_buffer(buffer_dist)
  
  # adds this buffer as an additional geometry to the main dataset
  is_vacant <- vacancy %>%
    mutate(ShapeBuffy = buffy$ShapeOriginal)
  
  # creates empty new column in dataset
  data["percent_vacant"] <- NA 
  
  for (property in is_vacant)
  {
    
    intersection <- st_intersection(property, )
    
    
    # calculates percent vacant houses in buffer
    vacant_n <- ###
    total_n <- sum() ###
    per_vac <- vacant_n/total_n
    
    ##add "per_vac" to column "percent_vacant" in is_vacant 
    ##that corresponds to that property's RNO
  }
}

baby_vacant <- is_vacant %>%
  filter(RNO == "R667121600")

baby_vacant_tax <- taxlots_pruned %>%
  filter(RNO == "R667121600")

practice_intersect <- st_intersection(is_vacant, capacity)

mapview(babybuffy)
mapview(babyvacancy)


max <- st_join(taxlots_pruned, capacity)


