# -------------------1. JOIN FOOTPRINTS TO TAXLOTS---------------------
dim(taxlots_pruned)
dim(allfeet)
left_join(taxlots_pruned, allfeet, by = "STATE_ID")

testjoint <- st_join(taxlots_pruned, allfeet, left = T)
testjoint2 <- st_intersection(taxlots_pruned, allfeet)
dim(testjoint)
dim(testjoint2)

# -------------------2. LEFT_JOIN IMPSEGCOP_WIDE TO TAXLOTS---------------------
impsegcop_wide$PROPERTYID <- impsegcop_wide$PropID # rename variable to join
# by same id
m <- left_join(taxlots_pruned, impsegcop_wide, 
               by = "PROPERTYID")
m2 <- left_join(testjoint2, impsegcop_wide, 
                by = "PROPERTYID")       

# -------------------3. ST_INTERSECTION SCHOOL TO TAXLOTS---------------------
testjoint3 <- st_intersection(m2, school)


# -------------------4. BATH AND FIREPLACE TO TAXLOTS---------------------
all.is$PROPERTYID <- all.is$PropertyID
testjoint4 <- left_join(testjoint3, all.is, by = "PROPERTYID")
glimpse(testjoint4)

# -------------------5. CONSTRAINTS TO TAXLOTS---------------------
