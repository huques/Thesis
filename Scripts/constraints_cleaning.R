#----------------------
# GDB sent 2/13 via Dropbox
gdb7 <- "./DATA/Intersectionzzz.gdb"


library(sf)

st_layers(gdb7)

intersections <- st_read(gdb7, "IntersectionzShell")

intersects <- intersections %>%
  select(STATE_ID, starts_with("con"), Shape_Area, AREA) %>%
  filter(STATE_ID %in% stateids) %>%
  group_by(STATE_ID)


cons_area <- intersects %>%
  summarise(case_when(conFld100 == "True" ~ sum(shape_area2),
                      TRUE ~ 0)) # %>%
  # summarise(conWetland_area = ifelse(conFld100 == "True", 
  #                                sum(Shape_Area, na.rm = TRUE), 0)) %>%
  # summarise(conFldway_area = ifelse(conFld100 == "True", 
  #                              sum(Shape_Area, na.rm = TRUE), 0)) %>%
  # summarise(conCovrly_area = ifelse(conFld100 == "True", 
  #                              sum(Shape_Area, na.rm = TRUE), 0)) %>%
  # summarise(conPovrly_area = ifelse(conFld100 == "True", 
  #                              sum(Shape_Area, na.rm = TRUE), 0))

  
cons_percent <- intersects %>%
  mutate(conFld100_per = conFld100_area/AREA) %>%
  mutate(conWetland_per = conFld100_area/Shape_Area) %>%
  mutate(conFldway_per = conFld100_area/Shape_Area) %>%
  mutate(conCovrly_per = conFld100_area/Shape_Area) %>%
  mutate(conPovrly_per = conFld100_area/Shape_Area)


taxlot_areas <- taxlots_pruned %>%
  select(STATE_ID)

taxlot_areas$tl_area <- st_area(st_geometry(taxlot_areas))

taxlot_areas %<>%
  st_drop_geometry()
  
intersections$shape_area2 <- st_area(st_geometry(intersections))

test <- intersections %>%
  left_join(taxlot_areas, by = "STATE_ID")

intersects <- test %>%
  select(STATE_ID, starts_with("con"), Shape_Area, shape_area2, tl_area) %>%
  filter(STATE_ID %in% stateids) %>%
  group_by(STATE_ID) 

dim(intersects)

