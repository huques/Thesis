library(tidyr)
library(dplyr)
library(sf)
library(stringr)
library(data.table)

# load data
gdb <- "DATA/data2.gdb"
impsegcop <- st_read(gdb, layer = "CoP_OrionImprovementSegment")

# column (267352 obs) with unique PropID and ADU dummy
ADU <- impsegcop %>%
  select(ImpType, PropID) %>%
  count(PropID) %>%
  mutate(ADUdummy = ifelse(n == 1, "0", "1")) %>%
  select(PropID, ADUdummy)
ADU <- ADU[-c(1),]


------------------------------------------------------------------------
# filter houses with ADU's
getADU <- impsegcop %>%
  filter(ImpType == "ADU")

# find PropID of houses with multiple ADU's
multipleADU <- getADU %>%
  group_by(PropID) %>%
  summarise(n = n()) %>%
  filter(n > 1) %>% 
  select(PropID)

# check that these houses have multiple ADU's -- cross referenced on PDX Maps
obsADU <- getADU %>%
  filter(PropID %in% 
           c("R125360", "R205839", "R223702", "R227223", "R281069", "R318113"))

# sleek version (Not Working 2/7)
ADU_column2 <- impsegcop %>%
  select(ImpType, PropID) %>%
  mutate(ADU_dummy = ifelse(freq(PropID) == 1, "0", "1"))











