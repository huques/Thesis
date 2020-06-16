# code to gen images for the README.MD

# buffy
idx <- "1S1E15CD  4400" 

idys <- vacant_join_buffy %>% filter(STATE_ID.x == idx) %>% pull(STATE_ID.y)
buffer.layer <- vacant_join_buffy %>% filter(STATE_ID.x == idx) %>% mapview::mapview()
taxlot.layer <- taxlots %>% filter(STATE_ID %in% idys) %>% 
  select(STATE_ID, PRPCD_DESC) %>%
  mapview::mapview(zcol = "PRPCD_DESC")

buffer.layer + taxlot.layer

# canopy intersection


# generic geometric join
nbhds <- c("GRANT PARK", "HOLLYWOOD")
nbhd.layer <- nbhd %>% filter(NAME %in% nbhds) %>% mapview::mapview(zcol = "NAME")
taxlot_grab <- st_join(st_centroid(taxlots_pruned), nbhd) %>%
  filter(NAME %in% nbhds)
taxlot.layer <- taxlot_grab %>% mapview::mapview()

taxlot.layer + nbhd.layer


