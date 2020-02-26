# Is Vacant Dummy -- Redux


import taxlots 


# selects property id's and vacancy variable
vacancy <- taxlots %>%
  select(STATE_ID, PRPCD_DESC, Shape) %>%
  rename(ShapeCapacity = Shape)

# check is STATE_ID in taxlots is more than unique
sum(data.frame(table(taxlots$STATE_ID))$Freq > 1)
multi_state_id <- taxlots %>%
  group_by(STATE_ID) %>%
  mutate(n = n()) %>%
  filter(n > 1)


vacancy_pruned <- vacancy %>%
  group_by(STATE_ID) %>%
  mutate(n = n()) %>%
  filter(n == 1) %>%
  mutate(VACANT = recode(PRPCD_DESC, 
                       "VACANT LAND" = 1,
                       .default = 0)) %>%
  select(-PRPCD_DESC, -n)


# creates a buffer called buffer_dist (measured in meters)
# adds this buffer as an additional geometry to the main dataset
buffer_dist <- 805

buffy <- taxlots_pruned %>%
  rename(ShapeBuffy = Shape) %>%
  st_buffer(buffer_dist)
?
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


