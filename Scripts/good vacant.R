# Is Vacant Dummy -- Redux
library(tidyverse)
library(sf)
library(mapview)

#import taxlots 

# explicitly define the missing values in a factor level
taxlots_copy <- taxlots
taxlots$STATE_ID <- fct_explicit_na(taxlots$STATE_ID)

# selects variables
vacancy <- taxlots_copy %>%
  select(STATE_ID, PRPCD_DESC, Shape)

# check if STATE_ID in taxlots is more than unique -- 161 repeat ids -- it is
sum(data.frame(table(taxlots$STATE_ID))$Freq > 1)
# df of repeat obs -- n = 586
multi_state_id <- taxlots_copy %>%
  group_by(STATE_ID) %>%
  mutate(n = n()) %>%
  filter(n > 1)

# df of unique obs -- 197,131 obs
vacancy_pruned <- vacancy %>%
  group_by(STATE_ID) %>%
  mutate(n = n()) %>%
  filter(n == 1) 


# create vacant column
vacancy_pruned$VACANT <- vacancy_pruned$PRPCD_DESC == "VACANT LAND"


# creates a buffer called buffer_dist
# adds this buffer as an additional geometry to the main dataset
# 1 ft = 0.3048 meters
conv <- 0.3048
ft <- 200
buffer_dist <- ft * conv

# creates buffer of size `buffer_dist` around buffy
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
  mutate(VACANT = VACANT) %>%
  filter(!is.na(VACANT)) %>% # taking out na's when calcing percent vacant
  summarize(percent_vacant = sum(VACANT)/n[1])






