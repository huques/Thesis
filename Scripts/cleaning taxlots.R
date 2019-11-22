# This script should be run first because we prune the number of observations
        # by the specified time period [begin, end] below. Therefore we can run
        # subsequent scripts: cleaning impsegcop, impseg, and finally joins to get our
        # final data set.

#----------------TAXLOTS--------------------------
# *Assumes we've already read all of our data sets from the gdbs*


# Reformat SALEDATE column (save as date type so that we can
# do math on it)
taxlots$saledate <- as.Date(as.character(taxlots$SALEDATE), "%m/%d/%Y")

begin <- as.Date("2015-01-01")
end <- as.Date("2019-01-01")

# Take time interval of taxlots we're interested in (5-years)
taxlots_pruned <- taxlots %>%
  filter(saledate > begin & saledate < end)

dim(taxlots_pruned) 

# Here, STATE_ID is the unique identifier
glimpse(taxlots_pruned)

# Grab keys to the lots we want for analysis
stateids <- taxlots_pruned %>%
  pull(STATE_ID)
propids <- taxlots_pruned %>%
  pull(PROPERTYID)

# YAY! They're sums below are both zero, meaning we have 1:1 keys!
sum(data.frame(table(taxlots_pruned$STATE_ID))$Freq > 1)
sum(data.frame(table(taxlots_pruned$PROPERTYID))$Freq > 1)


# --------------------FOOTPRINT COLLAPSE-----------------------------
# Now we will try merging/collapsing footprints on this smaller
# subset of the entire data set, only homes/MFR that have sold in the last
# 5 years.

# grab only the foot prints associated with stateids in our sample
ftprints_pruned <- footprints %>%
  filter(STATE_ID %in% stateids)

# check if these ids uniquely identify the building footprints
multi_foot <- ftprints_pruned %>%
  lwgeom::st_make_valid() %>%
  group_by(STATE_ID) %>%
  mutate(n = n()) %>%
  filter(n > 1)

ids <- multi_foot %>% pull(STATE_ID)

# NOTE: there are some rows whose summarized columns are missing
# because they were missing across all rows with the listed 
# STATE_ID. We can't do anything about this missingness using
# the `footprints` df alone. 
multi_foot %>% 
  filter(STATE_ID %in% ids) %>%
  group_by(STATE_ID) %>%
  summarise(totalsqft = sum(BLDG_SQFT, na.rm = T),
            yearbuilt = mean(YEAR_BUILT, na.rm = T),
            avgheight = mean(AVG_HEIGHT, na.rm = T),
            surfelev = mean(SURF_ELEV, na.rm = T),
            minheight = mean(MIN_HEIGHT, na.rm = T),
            maxheight = mean(MAX_HEIGHT, na.rm = T),
            volume = mean(VOLUME, na.rm = T),
            bldgtype = BLDG_TYPE[1],
            bldguse = BLDG_USE[1]) %>%
  mapview()

# Make collapsed footprints dataset called `allfeet`
allfeet <- ftprints_pruned %>% 
  lwgeom::st_make_valid() %>%
  group_by(STATE_ID) %>%
  summarise(totalsqft = sum(BLDG_SQFT, na.rm = T),
            yearbuilt = mean(YEAR_BUILT, na.rm = T),
            avgheight = mean(AVG_HEIGHT, na.rm = T),
            surfelev = mean(SURF_ELEV, na.rm = T),
            minheight = mean(MIN_HEIGHT, na.rm = T),
            maxheight = mean(MAX_HEIGHT, na.rm = T),
            volume = mean(VOLUME, na.rm = T),
            bldgtype = BLDG_TYPE[1],
            bldguse = BLDG_USE[1]) 
dim(allfeet)

# Look at all footprints in the 5-year interval
allfeet %>%
  mapview()

# CAUTION:`allfeet` will need to be cleaned more because it carries forward
# uses the bldgtype that happened to be listed first 
# for multi observation taxlots

# --------------------------------------------------------------------
# How should we collapse the building uses/types across the multi-building
# taxlots?
isUnique <- function(id, var){ # both inputs are strings
  complex <- footprints %>% filter(STATE_ID == id)
  t <- unique(unlist(complex[var][[1]])) # ugly but necessary to call
  ifelse(length(t) == 1, T, F)
}

#sameuse <- sapply(ids[1:3,], isUnique, var = "BLDG_USE")

# --------------------------------------------------------------------

  


