# Thesis

# General Overview
### Title: BPS Property Attributes Dataset
#### Non-market Valuation in Portland, OR
This project is part of a year-long thesis in consultation with Noelwah Netusil at Reed College and the Bureau of Planning and Sustainability. 

#### Abstract: 
 Our goal in amassing this data is to provide a quantitative tool that allows us to isolate the influence of environmental constraints (i.e. location within a 100-year floodplain, locating within a historic district, etc.) on the sale price of properties that have transacted within Multnomah county in the last five years. This document lays out the methodology used to develop our data set starting from the source of our raw files to the data frame used to estimate a hedonic price function. 

### Creators: 
Salma Huque - Reed College '20, 

Nick Kobel - Data Analyst at Bureau of Planning and Sustainability, 

Ryan Kobler - Reed College '20

### Identifer: 
PropertyID
StateID

### Date:
- First data grab 10/10/2019 -> DATA/data1.gdb
- Second data grab 10/29/2019 -> DATA/data2.gdb
- Third data grab 11/21/2019 -> DATA/data-20191112.gdb
- Fourth data grab

### Method:
- Shapefile generation:
  - Shapefiles: generated 
  - Queried from relational database at BPS and sent to us via email and USB
  
***
# Raw Data Directory
Each of these databases are saved in a directory called "DATA" on each of our machines.

#### data1.gdb layers (retrieved via USB on 10/10/2019)
- footprints = "footprints_10102019" 
- taxlots = "taxlots_10102019"

#### data2.gdb (retrieved via email on 10/29/2019)
- impsegcop = "CoP_Improvement_Segments"
- impseg = "Improvement_Segments"

#### data_20191112.gdb (retrieved via email on 11/21/2019)
- bli_constraints = "bli_constraints_all"
  - Description: updated constraints layer for accuracy. Contains all 27 of our constraints
- nbhd = "neighborhoods_no_overlap"
  - Description: 
  
#### tree_canopy.gdb
- canopy = "canopy_class_2014_metro"
- "bli_capacity_v2"

  

The above layers were read using the `sf` package in R.

***

# Content Description

### Variable list
See linked excel file for variable and value dictionaries.

***

# Processing
1) Initially the taxlots data frame had all taxlots within the city of Portland
2) Took observations that had transacted within the interval [2015/01/01 - 2019/01/01], format = YYYY/MM/DD.


```{r}
taxlots %>%
filter(saledate > 2015-01-01 & saledate < 2019-01-01)
```
### Variable Transformations
1. Footprints: 
```{r}
footprints %<>% 
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
```
2. Improvement segments (CoP):
These contain our garage, pool, shed, porch, deck dummy variables. Initially the data frame was transformed as in the example below:

| PropID | SegmentType | SegmentSqFt  |
|--------|-------:|:------:|
| R123456    | SHED   | 1000    |
| R123456    | POOL   | 500  |
| R654321    | DECK   | 950 |  
| R654321    | DECK   | 200 |  


| PropID | SHED | POOL  | DECK |
|--------|-------:|:------:|:------:|
| R123456    | 1000   | 500    | 0 |
| R654321    | 0   | 0 |  1150 |

Code used to perform the above transformation using the data.table package and data structure:
```{r}
library(data.table)
impsegcop_wide <- dcast(setDT(isc_pruned), PropID ~ SegmentType,
              value.var = c("SegmentSqFt"),
              fill = 0,
              fun.aggregate = sum)
```

3. Improvement segments (non-CoP):

  - For each segment under property ID X, collapsed string variables `Plumbing_Code` and `Fire_Place_Code` from 

| PropertyID | Plumbing_Code | Fire_Place_Code  |
|--------|-------:|:------:|
| R123456    | FB1   | BK1    |
| R123456    | HB2   | MD1  |
| R654321    | FB3   | BK4 |  

to

| PropertyID | bath | fireplace  |
|--------|-------:|:------:|
| R123456    | FB1~HB2   | BK1~MD1    |
| R654321    | FB3   | BK4  |

Code used to perform the above transformation:
```{r}
is_pruned <- impseg %>%
  filter(PropertyID %in% propids)
  
impseg <- is_pruned %>% 
  group_by(PropertyID) %>%
  summarise(totalarea = sum(Total_Area, na.rm = T),
            mktval = mean(Market_Value, na.rm = T),
            totalAdjPct = mean(Total_Adjustment_Percent, na.rm = T),
            nbhdMktVal = mean(Neighborhood_Market_Value_Percent, na.rm = T),
            Perimeter_feet = sum(Perimeter_feet, na.rm = T),
            effarea = sum(Effective_Area, na.rm = T))
            
baths <- bath %>% group_by(PropertyID) %>%
  summarise(bath = paste0(Plumbing_Code, 
                          collapse = "|"))

fires <- fire %>% group_by(PropertyID) %>%
  summarise(fireplace = paste0(unique(Fire_Place_Code), collapse = "|"))

impseg <- left_join(impseg, baths, by = "PropertyID")
impseg <- left_join(impseg, fires, by = "PropertyID") 

```
4. Distance to Portland City Hall, a proxy for distance to Central Business District (CBD)

This variable measures the Euclidean distance in feet of each property to Portland city hall. We generated this variable using the `st_distance()` function within the `sf` R package. The code is reproduced below:

```{r}
# grab lat long from google maps
cityhall <- data.frame(place = "City Hall",
                       long = -122.679103,
                       lat = 45.515000)
# reformat from df to sf object
cityhall <- st_as_sf(cityhall, coords = c("long", "lat"))

# Set coordinate system
cityhall <- cityhall %>%
  st_set_crs(4326) %>%
  st_transform(2913)

taxlots %<>% 
  mutate(dist_cityhall = st_distance(cityhall, 
                                     taxlots,
                                     which = "Euclidean"))
                                     
```                              
***

# Technical Description

### Necessary software
- R Packages:
  - dplyr
  - mapview
  - sf
  - data.table
  - magrittr

RStudio version 1.2.1335
***

# Access


