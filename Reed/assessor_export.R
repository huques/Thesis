library(odbc)
library(arcgisbinding)
library(tidyverse)
arc.check_product()

cgis_query <- function(conn, tablename, exception = "", spatial = TRUE) {
  ## Get last element (table name) from explicit table name
  tmp <- strsplit(tablename, "[.]")[[1]]
  tablename_short <- tmp[length(tmp)]
  
  fields <- dbListFields(conn, tablename_short)
  
  if (spatial) {
    fields_to_grab <- fields[!(fields %in% c(exception, "Shape"))]
    qstring <- paste0('select ', paste(fields_to_grab, collapse = ", "), ', Shape.STAsText() as ShapeWKT from ', tablename)
    cat(paste("Grabbing query with following SQL statement:", qstring, "\n", sep = "\n"))
    ret <- dbFetch(dbSendQuery(conn, qstring)) %>%
      mutate(Shape = st_as_sfc(ShapeWKT)) %>%
      select(-ShapeWKT) %>%
      st_as_sf(.)
  } 
  
  else {
    fields_to_grab <- fields[!(fields %in% exception)]
    qstring <- paste0('select ', paste(fields_to_grab, collapse = ", "), ' from ', tablename)
    cat(paste("Grabbing query with following SQL statement:", qstring, "\n", sep = "\n"))
    ret <- dbFetch(dbSendQuery(conn, qstring))
  }
  # dbClearResult()
  return(ret)
}


gdb <- "E:/Reed/data.gdb"

con <- dbConnect(odbc(),
                 Driver = "SQL Server",
                 Server = "GISDB1",
                 Database = "Assessor",
                 UID = rstudioapi::askForPassword("Database user"),
                 PWD = rstudioapi::askForPassword("Database password"),
                 Trusted_Connection = "True")

dbListTables(con)
dbListFields(con, tablename_short)
dbListFields(con, "roll_values")

dbListFields(con, "improvements")

# roll_values_full <- cgis_query(con, tablename = 'Assessor.dbo.roll_values', spatial = FALSE)



roll_values <- dbFetch(dbSendQuery(con, 'select PropertyID, Roll_Num, RollDate, year, RVID, 
                                   OwnerID, M50_Assessed, Land_Value, Special_Market_Value, 
                                   Special_Use_Value, Real_Market_Value, Improvements_Value 
                                   from ASSESSOR.dbo.roll_values')) 



# nchar(names(roll_values)) > 31
# names(roll_values[46]) <- "Exception_Max_Assessed_Value"

roll_history <- dbFetch(dbSendQuery(con, 'select PropertyID, Roll_Num, Roll_Date, year, Assessed_Value, Property_Tax, Total_Tax from ASSESSOR.dbo.roll_history')) 
nchar(names(roll_history)) > 31

roll_history_wide <- roll_history %>%
  select(PropertyID, year, Property_Tax) %>%
  mutate(Property_Tax = Property_Tax / 100) %>% ## Implied decimal place
  group_by(PropertyID, year) %>%
  summarize(Property_Tax = sum(Property_Tax)) %>%
  ungroup() %>%
  spread(year, Property_Tax)

## Same as above, but using the more intuitive "pivot_wider" function instead of "spread"
roll_history_wider <- roll_history %>%
  select(PropertyID, year, Property_Tax) %>%
  mutate(Property_Tax = Property_Tax / 100) %>% ## Implied decimal place
  group_by(PropertyID, year) %>%
  summarize(Property_Tax = sum(Property_Tax)) %>%
  ungroup() %>%
  pivot_wider(names_from = year, values_from = Property_Tax)


improvements <- cgis_query(con, tablename = "Assessor.dbo.improvements", spatial=FALSE)
nchar(names(improvements)) > 31

# imp_segments <- dbFetch(dbSendQuery(con, 'select * from ASSESSOR.dbo.imp_segments'))
imp_segments <- cgis_query(con, tablename = 'Assessor.dbo.imp_segments', spatial = FALSE)
nchar(names(imp_segments)) > 31
names(imp_segments[28]) <- "Neighborhood_Market_Value_Pct"

Seg_Char <- cgis_query(con, tablename = 'ASSESSOR.dbo.Seg_Char', spatial = FALSE)
nchar(names(Seg_Char)) > 31

Plumbing_Lookup <- cgis_query(con, 'ASSESSOR.dbo.Plumbing_Lookup', spatial = FALSE)
Fireplace_Lookup <- cgis_query(con, 'ASSESSOR.dbo.Fireplace_Lookup', spatial = FALSE)
Imp_Type_Lookup <- cgis_query(con, 'ASSESSOR.dbo.Imp_Type_Lookup', spatial = FALSE)
Improvement_Codes_Lookup <- cgis_query(con, 'ASSESSOR.dbo.Improvement_Codes_Lookup', spatial = FALSE)
Segment_Type_Lookup <- cgis_query(con, 'ASSESSOR.dbo.Segment_Type_Lookup', spatial = FALSE)
Property_Code_Lookup <- cgis_query(con, 'ASSESSOR.dbo.Property_Code_Lookup', spatial = FALSE)


# arc.write("E:/Reed/data.gdb/roll_values", roll_values)

arc.write("E:/Reed/data.gdb/roll_values", roll_values)
arc.write("E:/Reed/data.gdb/roll_history_wide", roll_history_wide)
arc.write("E:/Reed/data.gdb/roll_history", roll_history)
arc.write("E:/Reed/data.gdb/imp_segments", imp_segments)
arc.write("E:/Reed/data.gdb/Seg_Char", Seg_Char)
arc.write("E:/Reed/data.gdb/Plumbing_Lookup", Plumbing_Lookup)
arc.write("E:/Reed/data.gdb/Fireplace_Lookup", Fireplace_Lookup)
arc.write("E:/Reed/data.gdb/Imp_Type_Lookup", Imp_Type_Lookup)
arc.write("E:/Reed/data.gdb/Improvement_Codes_Lookup", Improvement_Codes_Lookup)
arc.write("E:/Reed/data.gdb/Segment_Type_Lookup", Segment_Type_Lookup)
arc.write("E:/Reed/data.gdb/Property_Code_Lookup", Property_Code_Lookup)
arc.write("E:/Reed/data.gdb/improvements", improvements)


