library(sf)

st_layers("constraint_layers.gdb")
setwd("/Users/ryankobler/Desktop/thesis/Thesis/DATA")

sex <- st_read("constraint_layers.gdb", "Intersectionz")

pct_const <- sex %>%
  filter(STATE_ID %in% stateids) %>%
  group_by(STATE_ID) %>%
  mutate(pct_conFld100 = ifelse(conFld100 == "True", 
                                sum(Shape_Area, na.rm = T) / AREA[1], 0),
         pct_conFldway = ifelse(conFldway == "True", 
                                sum(Shape_Area, na.rm = T) / AREA[1], 0),
         pct_conWetland = ifelse(conWetland == "True", 
                                 sum(Shape_Area, na.rm = T) / AREA[1], 0),
         pct_conPovrly = ifelse(conPovrly == "True", 
                             sum(Shape_Area, na.rm = T) / AREA[1], 0),
         pct_conCovrly = ifelse(conCovrly == "True", 
                             sum(Shape_Area, na.rm = T) / AREA[1], 0))

pct_const <- pct_const %>%
  group_by(STATE_ID) %>%
  summarise(pct_conFld100 = pct_conFld100[1],
            pct_conPovrly = pct_conPovrly[1],
            pct_conCovrly = pct_conCovrly[1],
            pct_conWetland = pct_conWetland[1],
            pct_conFldway = pct_conFldway[1]) %>%
  mutate(pct_conFld100 = ifelse(pct_conFld100 > 1, 1, pct_conFld100),
         pct_conFldway = ifelse(pct_conFldway > 1, 1, pct_conFldway),
         pct_conCovrly = ifelse(pct_conCovrly > 1, 1, pct_conCovrly),
         pct_conPovrly = ifelse(pct_conPovrly > 1, 1, pct_conPovrly),
         pct_conWetland = ifelse(pct_conWetland > 1, 1, pct_conWetland))

# Replace NA values with 0.
pct_const[is.na(pct_const)] <- 0







