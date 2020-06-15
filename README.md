# Thesis

# General Overview
### Title: Constructing the BPS Property Attributes Dataset
#### Non-market Valuation in Portland, OR
This project is part of a year-long thesis in consultation with Noelwah Netusil at Reed College and the Bureau of Planning and Sustainability. 

#### Abstract: 
 Our goal is to amassing a single data frame from several separate sources. With this data frame, we will calculate the marginal influence of environmental constraints (i.e. location within a 100-year floodplain, locating within a historic district, etc.) on the sale price of properties that have transacted within Multnomah county in the last five years. This document lays out the methodology used to develop our data set starting from the source of our raw files to the data frame used to estimate a hedonic price function. 

### Creators: 
Salma Huque - Reed College '20, 

Ryan Kobler - Reed College '20

Nick Kobel - Data Analyst at Bureau of Planning and Sustainability, 

### Identifers: 
PROPERTYID
STATE_ID

### Date:
1. [Received 10/10/2019 via USB -> DATA/data1.gdb](#DATA/data1.gdb)
2. Received 10/29/2019 via email -> DATA/data2.gdb
3. Received 11/21/2019 via email -> DATA/data-20191112.gdb
4. Received 11/22/2019 via email -> DATA/tree_canopy.gdb and DATA/Zoning_History
5. Received 11/25/2019 -> DATA/ugb/ugb.shp
6. Received 2/04/2020 -> DATA/zoning_crosswalk.xlsx
7. **Created 2/10/2020 in GIS -> DATA/canopy_20200210.gdb
8. *Retrieved 2/11/2020 via OpenData.com -> DATA/Complete_Neighborhoods_Scoring_Surface
9. **Created 2/13/2020 in GIS -> DATA/constraint_layers.gdb
10. **Created 3/7/2020 in GIS using FEMA map (OpenData, link broken?) and 'building_footprints_20191010' layer (data1.gdb) -> DATA/ft_fld.gdb
11. *Retrieved 4/2/2020 via OpenData.com -> DATA/Portland_Administrative_Sextants/Portland_Administrative_Sextants.shp

### Method:
- Queried from relational database at BPS and sent to us via email and USB
- *Retrieved separately from OpenData.com (not received in consultation with BPS).
- **Created by Ryan Kobler and Salma Huque using GIS Intersect tool, methods given below

To create DATA/canopy_20200210.gdb, "canopy_taxlot_intersect" layer...
    1. Loaded 'taxlots_20191010' layer from data1.gdb into new ArcMap file
    2. Loaded 'canopy_class_2014_metro' layer from tree_canopy.gdb
    3. Used intersect tool to intersect the above layers
    4. Exported intersected layer from ArcGIS to Shapefile

To create DATA/DATA/ft_fld.gdb, "ft_floodplain" layer...
    1. Loaded 'building_footprints_20191010' layer from data1.gdb into new ArcMap file
    2. Loaded 'FEMA' 100 year floodplain layer from OpenData.com, source: 
    3. Used intersect tool to intersect the above layers
    4. Exported intersected layer from ArcGIS to Shapefile
  
***
# Raw Data Directory
Each of these databases are saved in a directory called "DATA" on each of our machines. The bullet points represent layers included in the larger geodatabase. 

#### data1.gdb <a name="DATA/data1.gdb"></a>  
- footprints = "footprints_10102019" 
- taxlots = "taxlots_10102019"
  - Description: This comprises our unit of observation, if an observation is not included in this data frame, then it is not included in the analysis. All other data frames and attributes are left-joined here.
  - Dimensions: 197,717 x 49
  - Geometry: MULTIPOLYGON

#### data2.gdb 
- impsegcop = "CoP_Improvement_Segments"
  - Descripton: data.frame object, interested in the `SegmentType`, `SegmentNbr`, `SegmentSqft` variables
  - Dimensions: 1,173,249 x 7
- impseg = "Improvement_Segments"
  - Description: data.frame object, interested in the `Plumbing_Code` and `Fire_Place_Code` variables
  - Dimensions: 1,567,227 x 57
- school = "school_attendance_areas"
  - Description: sf object, school catchment areas, divided into elementary, middle and high school
  - Dimensions: 113 x 8
  - Geometry: MULTIPOLYGON

#### data_20191112.gdb
- bli_constraints = "bli_constraints_all"
  - Dimensions: 204,375 x 30
  - Geometry: MULTIPOLYGON
  - Description: updated constraints layer, sf object. Contains all 27 of our constraints, missing taxlot identifiers.
  
- nbhd = "neighborhoods_no_overlap"
  - Dimensions: 99 x 13
  - Geometry: MULTIPOLYGON
  - Description: sf layer of 99 non-overlapping Portland neighborhoods whose levels include: 

| -- | -- | -- |
|--------|:-------|:------|
|  LINNTON | FOREST PARK | CATHEDRAL PARK|  
|  FOREST PARK | UNIVERSITY PARK | PIEDMONT|  
|  CATHEDRAL PARK | PIEDMONT | ARBOR LODGE|  
|  UNIVERSITY PARK | CULLY ASSOCIATION OF NEIGHBORS | PARKROSE|  
|  MC UNCLAIMED #14 | OVERLOOK | HUMBOLDT|  
|  PIEDMONT | PARKROSE | WILKES COMMUNITY GROUP|  
|  WOODLAWN | ARGAY TERRACE | ALAMEDA|  
|  CULLY ASSOCIATION OF NEIGHBORS | KING | ROSEWAY|  
|  ARBOR LODGE | WILKES COMMUNITY GROUP | IRVINGTON COMMUNITY ASSOCIATION|  
|  OVERLOOK | SABIN COMMUNITY ASSOCIATION | NORTHWEST DISTRICT ASSOCIATION|  
|  CONCORDIA | BOISE | PEARL DISTRICT|  
|  PARKROSE | ROSEWAY | SULLIVAN'S GULCH|  
|  SUMNER ASSOCIATION OF NEIGHBORS | ELIOT | KERNS|  
|  ARGAY TERRACE | ROSE CITY PARK | HAZELWOOD|  
|  HUMBOLDT | NORTHWEST DISTRICT ASSOCIATION | GOOSE HOLLOW FOOTHILLS LEAGUE|  
|  KING | GRANT PARK | PORTLAND DOWNTOWN|  
|  VERNON | HOLLYWOOD | SOUTHWEST HILLS RESIDENTIAL LEAGUE|  
|  WILKES COMMUNITY GROUP | SULLIVAN'S GULCH | CENTENNIAL COMMUNITY ASSOCIATION|  
|  BEAUMONT-WILSHIRE | LAURELHURST | SOUTH PORTLAND|  
|  SABIN COMMUNITY ASSOCIATION | HILLSIDE | POWELLHURST-GILBERT|  
|  ALAMEDA | HAZELWOOD | CRESTON-KENILWORTH|  
|  BOISE | ARLINGTON HEIGHTS | LENTS|  
|  NORTHWEST HEIGHTS | GLENFAIR | MT. SCOTT-ARLETA|  
|  ROSEWAY | PORTLAND DOWNTOWN | WOODSTOCK|  
|  MADISON SOUTH | MT. TABOR | MULTNOMAH|  
|  ELIOT | SUNNYSIDE | ARDENWALD-JOHNSON CREEK|  
|  IRVINGTON COMMUNITY ASSOCIATION | CENTENNIAL COMMUNITY ASSOCIATION | COLLINS VIEW|  
|  ROSE CITY PARK | RICHMOND | FAR SOUTHWEST|  
|  PARKROSE HEIGHTS ASSOCIATION OF NEIGHBORS | HOMESTEAD | LLOYD DISTRICT COMMUNITY ASSOCIATION|  
|  NORTHWEST DISTRICT ASSOCIATION | POWELLHURST-GILBERT | CRESTWOOD|  
|  RUSSELL | BRIDLEMILE | ST. JOHNS|  
|  GRANT PARK | HILLSDALE | BRIDGETON|  
|  PEARL DISTRICT | LENTS | PORTSMOUTH  |  

#### tree_canopy.gdb 
- canopy = "canopy_class_2014_metro"
- bli_constraints_v2 = "bli_constraints_v2_pts_run4"
  - Dimensions: 204,375 x 42 sf object
  - Geometry: POINT (centroids of the multipolygons)
  - Description: includes STATE_ID
  
#### canopy_20200210.gdb 
- canopy = "canopy_taxlot_intersect"
  - Description: intersected taxlot and canopy boundaries, aka all canopy cover in PDX that        intersect a taxlot
  - Dimensions: 824,307 x 52
  - Geometry: MULTIPOLYGON
  
#### ft_fld.gdb
- ftfld_ids = "ft_floodplain
  - Description: sf object
  - Dimensions: 3,377 x 75
  - Geometry: MULTIPOLYGON

#### ugb.shp
- Description: ugb that separates buildable lands from non-buildable lands
- Dimensions: 1 x 3
- Geometry: MULTIPOLYGON

#### Complete Neighborhoods Scoring Surface
- walk = "Complete_Neighborhoods_Scoring_Surface"
  - Description: normalized accessibility score (0-100)
  - Dimensions: 325,594 x 5
  - Geometry: POLYGON

#### Portland Administrative Sextants 
- sex = "Portland_Administrative_Sextants.shp"
  - Description: sf layer of 6 quadrants in Portland whose levels include
| -- | -- | -- |
|--------|:-------|:------|
|  N | NE | NW |  
|  S | SE | SW | 
  - Dimensions: 6 x 8
  - Geometry: POLYGON


The above layers were read using the `sf` package in R.

***

# Content Description

### Variable list
See [dictionary.md](https://github.com/huques/Thesis/blob/master/dictionary.md "Data Dictionary") for all variable and value dictionaries associated with this project.

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
These contain our garage, pool, shed, porch, deck, etc. square footage variables to possibly(?) be transformed into dummy variables. Currently they're in the full data set as square footages. The data frame was transformed as in the example below:

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

This `dist_cityhall` variable measures the Euclidean distance in feet of each property to Portland city hall. We generated this variable using the `st_distance()` function within the `sf` R package. The code is reproduced below:

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
5. Distance to nearest point of the UGB

This variable measures the Euclidean distance in feet of each property to the UGB. Generated using the `st_distance()` function within the `sf` and `sp` packages. This approach calculates distances using the centroids of MULTIPOLYGON taxlots. So, in the process, the st_geometry() attribute of the taxlot spatial data frame is changed from polygons to points. The geometry can be reset to MULTIPOLYGONS afterward. The code is reproduced below:

```{r}
# Transform UGB shapefile to correct coordinate system
ugb %<>% 
  st_transform(2913) %>% 
  st_cast(., "MULTILINESTRING")

# Convert to sp object since we use the rgeos::NearestPoints function that requires this
# data type, using sp:as_Spatial()
ugb.sp <- as_Spatial(ugb)

# Pull taxlot polygons & calculate centroids
centroids <- st_geometry(fugly)
centroids.sp <- as_Spatial(centroids)

# gNearestPoints returns vector of nearest point on taxlot (the centroid) 
# and the nearest point on the ugb. We take the ugb point, the second item in the list.

# Initialize empty list
nearest_points <- list(NA, nrow(fugly))

# call gNearestPoints over all observations in `taxlots` to return list of point geometries
for(i in 1:nrow(fugly)){
  nearest_points[i] <- st_as_sf(rgeos::gNearestPoints(centroids.sp[i,], ugb.sp)[2,])
}

# Combine/"unlist" the point geometries
nearest_points <- do.call(c, nearest_points)

# When given two vectors, st_distance(a, b) returns distance between all pairs of points in a and a.
# ex. if a = c(1,2,3) b = c(0, 9, 8). then st_distance(a, b) = (1, 8, 7, 2, 7, 6, 3, 6, 5)
# mapply() loops over nearest_points and centroids simultaneously so usign the above a, b, 
# we end up with (1,7,5)
fugly$dist_ugb <- mapply(FUN = st_distance, nearest_points, centroids)
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


