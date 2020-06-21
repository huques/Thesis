library(sf)
library(here)#----------------------
# Load zoning shape files
# zoningaug2014 <- st_read(here::here("DATA", "Zoning_History",
#                                     "Zoning_2014_Aug_pdx.shp"))
# zoningfeb2014 <- st_read(here::here("DATA", "Zoning_History",
#                                     "Zoning_2014_Feb_pdx.shp"))
# zoningaug2015 <- st_read(here::here("DATA", "Zoning_History",
#                                     "Zoning_2015_Aug_pdx.shp"))
# zoningfeb2015 <- st_read(here::here("DATA", "Zoning_History",
#                                     "Zoning_2015_Feb_pdx.shp"))
# zoningaug2016 <- st_read(here::here("DATA", "Zoning_History",
#                                     "Zoning_2016_Aug_pdx.shp"))
# zoningfeb2016 <- st_read(here::here("DATA", "Zoning_History",
#                                     "Zoning_2015_Feb_pdx.shp"))
# zoningaug2017 <- st_read(here::here("DATA", "Zoning_History",
#                                     "Zoning_2017_Aug_metro.shp"))
# zoningaug2018 <- st_read(here::here("DATA", "Zoning_History",
#                                     "Zoning_2018_Aug_pdx.shp"))
# zoningfeb2018 <- st_read(here::here("DATA", "Zoning_History",
#                                     "Zoning_2018_Feb_pdx.shp"))


# Load crosswalk from Nick sent via email 02/04
# crosswalk <- read_xlsx(here::here("DATA", "zoning_crosswalk.xlsx"))
# crosswalk %<>%
#   rename(sale_zone = `Base Zone`)

i <- zoningaug2014
j <- "zoningaug2014"
k <- str_replace(j, "zoning", "_")

zonelist <- list(zoningaug2014 = zoningaug2014,
                 zoningaug2015 = zoningaug2015,
                 zoningaug2016 = zoningaug2016,
                 zoningaug2017 = zoningaug2017,
                 zoningaug2018 = zoningaug2018,
                 zoningfeb2014 = zoningfeb2014, 
                 zoningfeb2015 = zoningfeb2015,
                 zoningfeb2016 = zoningfeb2016,
                 zoningfeb2018 = zoningfeb2018)

# creates a list `zonelist` with colnames modified
for(i in 1:length(zonelist)){
  name <- names(zonelist)[[i]]
  print(name)
  
  dat <- (zonelist)[[i]]
  print(class(dat))
  
  string <- str_replace(name, "zoning", "_")
  print(string)
  
  colnames(dat) <- paste0(colnames(dat), string)
  print(colnames(dat))
  
  st_geometry(dat) <- paste0("geometry", string)
  
  zonelist[[i]] <- dat
}

# using st_join instead: much faster! Note this should not use the fugly df.
# creates a data frame 
df <- st_join(st_centroid(taxlots_pruned), zoningfeb2018)

for(i in 1:(length(zonelist)-1)){
  print(class(zonelist[[i]]))
  df <- st_join(df, zonelist[[i]])
}

# Create new df with just the shorthand zoning variables across time
zones_over_time <- df %>%
  dplyr::select(contains("ZONE_"), STATE_ID, saledate)%>%
  dplyr::select(-contains("TMP")) %>%
  dplyr::select(-contains("DESC_aug")) %>%
  dplyr::select(-contains("CLASS"))

zones_over_time %<>%
  dplyr::mutate(sale_zone = case_when(saledate >= as.Date("2014-02-01") & saledate < as.Date("2014-08-01") ~ ZONE_feb2014,
                                      saledate >= as.Date("2014-08-01") & saledate < as.Date("2015-02-01") ~ ZONE_aug2014,
                                      saledate >= as.Date("2015-02-01") & saledate < as.Date("2015-08-01") ~ ZONE_feb2015,
                                      saledate >= as.Date("2015-08-01") & saledate < as.Date("2016-02-01") ~ ZONE_aug2015,
                                      saledate >= as.Date("2016-02-01") & saledate < as.Date("2016-08-01") ~ ZONE_feb2016,
                                      saledate >= as.Date("2016-08-01") & saledate < as.Date("2017-08-01") ~ ZONE_aug2016,
                                      saledate >= as.Date("2017-08-01") & saledate < as.Date("2018-02-01") ~ ZONE_aug2017,
                                      saledate >= as.Date("2018-02-01") & saledate < as.Date("2018-08-01") ~ ZONE_feb2018,
                                      saledate >= as.Date("2018-08-01") ~ ZONE_aug2018)) %>%
  dplyr::mutate(sale_zone = as.character(sale_zone)) %>%
  dplyr::mutate(sale_zone = ifelse(is.na(sale_zone), 
                                   as.character(ZONE_aug2018), 
                                   sale_zone))

# Join use crosswalk to generate  prop_type variable: MFR, SFR, mixed use
zones_over_time %<>%
  dplyr::left_join(crosswalk, by = "sale_zone") %>%
  st_drop_geometry() %>%
  dplyr::rename(prop_type = Simplified) %>%
  # below are older zones not matched with the crosswalk but clarified
  # in email from Nick, Al, and Barry
  dplyr::mutate(prop_type = case_when(sale_zone == "CM"| 
                                        sale_zone == "CG"|
                                        sale_zone == "CN1"|
                                        sale_zone == "CN2"|
                                        sale_zone == "CS"|
                                        sale_zone == "CO1"|
                                        sale_zone == "CO2" ~ "Mixed Use",
                                        TRUE ~ prop_type)) %>%
  dplyr::select(-saledate)

fugly <- left_join(fugly, zones_over_time, by = "STATE_ID")
print(paste0("zone Join: ", as.character(sum(data.frame(table(fugly$STATE_ID))$Freq > 1))))



