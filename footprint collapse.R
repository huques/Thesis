multi_foot <- ftprints_pruned %>%
  dplyr::group_by(STATE_ID) %>%
  dplyr::mutate(n = n()) %>%
  dplyr::filter(n > 2) %>%
  dplyr::pull(STATE_ID)


tib <- data.frame(table(footprints$STATE_ID))

footprints$STATE_ID <- as.character(footprints$STATE_ID)

# There are observations that do not have STATE_ID (do they actually have
# stateid and we just need to connect somehow?)
ftprints_pruned <- footprints %>%
  filter(!is.na(STATE_ID))

ftprints_pruned$STATE_ID <- as.character(ftprints_pruned$STATE_ID)

# collapsing footprints by STATE_ID
# still need to figure out how to collapse or average the attributes 
# of each building such as roof elevation, etc.
ftprints_pruned %>%
  dplyr::filter(STATE_ID %in% multi_foot) %>%
  dplyr::group_by(STATE_ID) %>% dplyr::select(STATE_ID, n)
  #pivot_wider(names_from = BLDG_USE, values_from = BLDG_NUMB) %>%
  #pivot_wider(names_from = BLDG_TYPE, values_from = BLDG_SQFT) %>%
 summarise(totalsqft = sum(BLDG_SQFT, na.rm = T),
            yearbuilt = mean(YEAR_BUILT, na.rm = T),
            avgheight = mean(AVG_HEIGHT, na.rm = T),
            surfelev = mean(SURF_ELEV, na.rm = T),
            minheight = mean(MIN_HEIGHT, na.rm = T),
            maxheight = mean(MAX_HEIGHT, na.rm = T),
            volume = mean(VOLUME, na.rm = T))


# Reshaping impseg
multi_obs <- impseg %>%
  group_by(PropertyID, SegmentType) %>%
  summarise(n = n()) %>%
  filter(n > 1) %>% 
  pull(PropertyID)

impseg %>%
  group_by(PropertyID) %>%
  summarise()





