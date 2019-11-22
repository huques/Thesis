# We need the columns PlumbingCode and Fire_place_Lookup from the impseg df
glimpse(impseg)
levels(impseg$Plumbing_Code)
levels(impseg$Fire_Place_Code)
levels(impseg$Seg_Type)
impseg$Perimeter_feet <- as.numeric(impseg$Perimeter_feet)
impseg$Neighborhood_Market_Value_Percent <- as.numeric(impseg$Neighborhood_Market_Value_Percent)

is_pruned <- impseg %>%
  filter(PropertyID %in% propids)
dim(is_pruned) #took about 1% of the properties in impseg
dim(impseg)

is_pruned$PropertyID <- droplevels(is_pruned$PropertyID)

# there are 6901 multi observations
multi_is <- is_pruned %>%
  group_by(PropertyID, Seg_Type) %>%
  mutate(n = n()) %>%
  filter(n > 1)

save$PropertyID <- droplevels(save$PropertyID)
save <- multi_is %>%
  group_by(PropertyID, Seg_Type) %>%
  filter(!is.na(Plumbing_Code)) %>%
  select(Seg_Type, Plumbing_Code)

save %>%
  group_by(PropertyID) %>%
  mutate(n = n()) %>%
  filter(n > 1)

save$Seg_Type <- droplevels(save$Seg_Type) # drops extra levels
table(save$Seg_Type) # most of the information on plumbing code is
# stored in the segment type: "MA"

# ceiling height, number of rooms, condition code,
# length, height is useless

# Q: what is interior_component_code?

#--------------------------------------------
# Using base r because dplyr code above taking too long
bath <- is_pruned[!is.na(is_pruned$Plumbing_Code),]
bath <- bath %>% dplyr::select(PropertyID, Plumbing_Code, Seg_Type)

bath$Seg_Type <- droplevels(bath$Seg_Type)
table(bath$Seg_Type) # again, most of the bathrooms are in MA

# There are 1657 properties with more than one MA
is_pruned %>%
  filter(Seg_Type == "MA") %>%
  group_by(PropertyID, Seg_Type) %>%
  mutate(n = n()) %>%
  filter(n > 1) %>%
  select(Fire_Place_Code, PropertyID, Plumbing_Code)

# ---------------------------------
# Which segment types contain the fireplace code?

fire <- is_pruned[!is.na(is_pruned$Fire_Place_Code),]
fire <- fire %>% dplyr::select(PropertyID, Fire_Place_Code, Seg_Type)

fire$Seg_Type <- droplevels(fire$Seg_Type)
table(fire$Seg_Type) # again, most of the fire info is in MA
# ---------------------------------
is_pruned$Perimeter_feet <- as.numeric(is_pruned$Perimeter_feet)
is_pruned$Neighborhood_Market_Value_Percent <- as.numeric(is_pruned$Neighborhood_Market_Value_Percent)

all.is <- is_pruned %>% 
  group_by(PropertyID) %>%
  summarise(totalarea = sum(Total_Area, na.rm = T),
            mktval = mean(Market_Value, na.rm = T),
            totalAdjPct = mean(Total_Adjustment_Percent, na.rm = T),
            nbhdMktVal = mean(Neighborhood_Market_Value_Percent, na.rm = T),
            Perimeter_feet = sum(Perimeter_feet, na.rm = T),
            effarea = sum(Effective_Area, na.rm = T))
dim(all.is) # dropped to 33290 properties

# ------------Add bath & fire columns separately--------------------- 

# Bath is a data frame of all non-missing Plumbing_Code obs
baths <- bath %>% group_by(PropertyID) %>%
  summarise(bath = paste0(unique(Plumbing_Code), collapse = "|"))

fires <- fire %>% group_by(PropertyID) %>%
  summarise(fireplace = paste0(unique(Fire_Place_Code), collapse = "|"))

all.is <- left_join(all.is, baths, by = "PropertyID")
all.is <- left_join(all.is, fires, by = "PropertyID") 



