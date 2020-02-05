library(dplyr)
library(sf)


non_id_constraints <- bli_constraints_v2 %>%
  select(contains("con"))

df <- st_join(st_centroid(taxlots_pruned), non_id_constraints)

glimpse(df)

#idless_constraints <- !is.na(idless_constraints)
#rowSums(idless_constraints)
# Shows that we have all 2015 taxlots within Portland