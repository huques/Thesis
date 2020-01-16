library(magrittr)

# USES BLI_CAPACITY_V2 located in gdb4

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

gdb4 <- "./DATA/tree_canopy.gdb"
capacity <- st_read(gdb4, layer = "bli_capacity_v2")

# Check if this is a new capacity layer or the same as capacity0

capacity %<>%
  arrange(STATE_ID)

capacity0 %<>%
  arrange(STATE_ID)

#---------------------
# Prune stateIDs outside our timeframe
ids2 <- testjoint5$STATE_ID

capacity %<>% 
  filter(STATE_ID %in% ids2)

# We have 481 repeated state_id observations and 3147 single state_id observations
sum(data.frame(table(capacity$STATE_ID))$Freq > 1)
sum(data.frame(table(capacity$STATE_ID))$Freq == 1)

const_map <- capacity %>%
  dplyr::group_by(STATE_ID) %>% 
  dplyr::mutate(n = n()) 

t <- const_map %>%
  filter(n > 1) %>%
  pull(STATE_ID)

mapview(capacity)

# Collapse constraints
# Goal: get constraints as percent of lot in constraint

# But first, check if the sum of the constraint layers are actually the sum total
# of each taxlot
tax.prints <- testjoint5 %>%
  arrange(STATE_ID) %>%
  mutate(tlarea = Shape_Area) %>%
  select(STATE_ID, tlarea) %>%
  st_drop_geometry()

con.prints <- const_map %>%
  group_by(STATE_ID) %>%
  summarise(area = sum(Shape_Area, na.rm = T)) %>%
  select(STATE_ID, area) %>%
  st_drop_geometry()

prints <- left_join(as.data.frame(con.prints),
                    as.data.frame(tax.prints), 
                    by = "STATE_ID")

abs(prints$area - prints$Shape_Area) < 100
prints$area > prints$Shape_Area

# There does not appear to be consistency in which side, the summed constraints 
# or the total shape area, is larger. So we'll add the taxlot area as a column
# to the capacity data frame in order to calculate the percentage of lot within constraint

# For floodway, we may want to calculate percent buildling footprint within constraint, 
# rather than the percentage of lot within constraint

const <- const_map %>%
  st_drop_geometry()

witharea <- left_join(const, tax.prints, by = "STATE_ID")

# Test collapsing constraint --------------
test <- witharea %>%
  filter(STATE_ID %in% t)

isnt.na <- function(x){
  !is.na(x)
}


# code below works to... 
test %<>%
  # 1) transform the "True" NA into TRUE/FALSE
  mutate_at(vars(conECSI:conFld100), isnt.na) %>%
  group_by(STATE_ID) %>%
  
  # 2) Selects the constraints, & if true, calculate percent of lot within constraint
  mutate_at(vars(conECSI:conFld100), 
            funs(ifelse(., Shape_Area / tlarea, 0))) %>%
  
  # 3) Sum the percent of lot within constraint
  summarise_at(vars(conECSI:conFld100), sum) 

# This function checks if there are any constraints for which the percentage of lot
# is different. For instance for row 1, conAirHgt = .724, conNoise = .724, etc, 
# Assumes that this function is fed a row of a data frame with columns STATE_ID and constraints
nonZeros <- function(x){ # x is a row of df
  ind <- which(x > 0) # check which columns the row has value larger than zero
  ind <- dplyr::setdiff(ind, 1) # remove index 1, STATE_ID
  ind <- as.numeric(ind) 
  if(length(ind) == 0){ # if there are none, we return 0
    0
  }
  else{ # count number of times that the first value in the row is not equal to the subsequent values
    sum(rep(x[ind[1]], length(ind)) != x[ind])
  } 
}
# -------------------------------
test %<>%
  mutate_at(vars(conECSI:conFld100), isnt.na) %>%
  group_by(STATE_ID) %>%
    mutate_at(vars(conECSI:conFld100), 
            funs(ifelse(., Shape_Area / tlarea, 0))) %>%
  select(STATE_ID, conECSI:conFld100)

list <- vector("list", nrow(test))
for(i in 1:nrow(test)){
 list[i] <- firstNonZero(test[i,])
}

# Sum below is 0, indicating that there are no observations for which row i has percentages
# that are different for different constraints (id = 1N3E400, conLUST = 0.05, conNoise = 0.75)
# *this means that the constraints are split into geometries by a metric other than the constraints*
sum(unlist(list))
# -------------------------------

# Capacity collapsed df, with geometries removed
capacity.col <- capacity %>%
  st_drop_geometry() %>%
  # transform the "True" NA into TRUE/FALSE
  mutate_at(vars(conECSI:conFld100), isnt.na) %>%
  group_by(STATE_ID) %>%
  
  # Selects the constraints, & if true, calculate percent of lot within constraint
  mutate_at(vars(conECSI:conFld100), 
            funs(ifelse(., 1, 0))) %>%
  summarise_at(vars(conECSI:conFld100), sum)

View(capacity.col)

# Check if any constraints are greater than 1
check <- capacity.col %>%
  #select(-STATE_ID) %>%
  filter_all(., any_vars(is.numeric(.) & . > 1)) %>%
  pull(STATE_ID)

# Turns out there are constraints whose entry
# is larger than 1. And the lots with double counted constraints are industrial, given below:

capacity %>% # we go back to the "capacity" data frame/sf because it still has its geometry attributes
  filter(STATE_ID %in% check) %>%
  mapview()

# --------- Modify capacity.col ---------
capacity.col <- capacity %>%
  st_drop_geometry() %>%
  mutate_at(vars(conECSI:conFld100), isnt.na) %>%
  group_by(STATE_ID) %>%
  mutate_at(vars(conECSI:conFld100), 
            funs(ifelse(., 1, 0))) %>%
  summarise_at(vars(conECSI:conFld100), sum) %>%
  mutate_at(vars(conECSI:conFld100), 
            funs(ifelse(. > 1, 1, .))) # modification from sum to ifelse

# Now the constraints are collapsed and return 1/0 for T/F 
capacity.col %>%
  filter(STATE_ID %in% check)
# ---------------------------------------


# Before checking the accuracy of the percentage lot calculations,
# let us first see how many observations there are for each constraint.

total.con <- capacity.col %>%
  select(-STATE_ID) %>%
  colSums()

# Some constraints--LUST, HistLdm, Heiprt, Wetland, have very few
# matched properties in our specified time frame. So let's calculate
# an upper bound # of obs by using the full "capacity" data frame (before pruning
# out certain taxlots).

capacity.full <- st_read(gdb4, layer = "bli_capacity_v2")
capacity.full %<>%
  arrange(STATE_ID)
dim(capacity.full) # Dim: 32498 x 146, non-collapsed

# Collapse full data frame
cap.full.col <- capacity.full %>%
  st_drop_geometry() %>%
  mutate_at(vars(conECSI:conFld100), isnt.na) %>%
  group_by(STATE_ID) %>%
  mutate_at(vars(conECSI:conFld100), 
            funs(ifelse(., 1, 0))) %>%
  summarise_at(vars(conECSI:conFld100), sum) %>%
  mutate_at(vars(conECSI:conFld100), 
            funs(ifelse(. > 1, 1, .)))

dim(cap.full.col) # collapsed df dim = 24344 x 28

# 
upper.bd <- cap.full.col %>%
  select(-STATE_ID) %>%
  colSums()

check.full <- cap.full.col %>%
  #select(-STATE_ID) %>%
  filter_all(., any_vars(is.numeric(.) & . > 1)) %>%
  pull(STATE_ID)

capacity.full %>%
  filter(STATE_ID %in% check.full) %>%
  mapview()

