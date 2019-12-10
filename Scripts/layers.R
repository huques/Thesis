library(sf)

gdb <- "/Users/ryankobler/Desktop/thesis/data/Reed/data.gdb"

layers <- st_layers(gdb)

constraints <- st_read(gdb, layer = "bli_development_capacity")

# create sample of last sold dates in order to immediately trim the # obs we work withimpsegcop <- st_read(gdb, layer = "CoP_OrionImprovementSegment")
gisimpcop <- st_read(gdb, layer = "CoP_GISImprovement")
impsegcop <- st_read(gdb, layer = "CoP_OrionImprovementSegment")
gispropcop <- st_read(gdb, layer = "CoP_GISProperty")
allpropcop <- st_read(gdb, layer = "CoP_AllProperties")
segchar <- st_read(gdb, layer = "Seg_Char")
rollhist <- st_read(gdb, layer = "roll_history")
rollvals <- st_read(gdb, layer = "roll_values")
impseg <- st_read(gdb, layer = "imp_segments")
salescop <- st_read(gdb, layer = "CoP_OrionSalesHistory")
school <- st_read(gdb, layer = "school_attendance_areas")
imp <- st_read(gdb, layer = "improvements")

firelu <- st_read(gdb, layer = "Fireplace_Lookup")
segmentlu <- st_read(gdb, layer = "Segment_Type_Lookup")
imptypelu <- st_read(gdb, layer = "Imp_Type_Lookup")
impcodeslu <- st_read(gdb, layer = "Improvement_Codes_Lookup") 
propcodelu <- st_read(gdb, layer = "Property_Code_Lookup") 
plumblu <- st_read(gdb, layer = "Plumbing_Lookup")


# finding my address
gisimpcop %>% filter(PropID == "R122577")


sales$date <- as.Date(sales$SaleDate)
df <- data.frame(table(impseg$PropertyID))

# Narrows to 93193 observations
trim1 <- salescop %>% filter(date > as.Date("2015-01-01") & date < as.Date("9999-01-01"))
dim(trim1)

# May need to generate our own matching to taxlot for this variable
school <- st_read(gdb, layer = "school_attendance_areas")



