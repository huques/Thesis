# Found that constraints are not 1:1 with Property or State ID.
# Goal: find out how each shape has been divided.

multi_con <- constraints %>%
  #st_cast("GEOMETRY") %>%
  filter(STATE_ID %in% stateids) %>%
  lwgeom::st_make_valid() %>%
  group_by(STATE_ID) %>%
  dplyr::summarise(n = n()) %>%
  dplyr::filter(n > 1) %>% 
  dplyr::pull(STATE_ID)

constraints %>%
  filter(STATE_ID %in% multi_con) %>%
  mapview()

