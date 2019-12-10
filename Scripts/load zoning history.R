#----------------------
# GDB sent 11/22 via Dropbox

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

zoningaug2014 <- st_read("./DATA/Zoning_History/Zoning_2014_Aug_pdx.shp")
zoningfeb2014 <- st_read("./DATA/Zoning_History/Zoning_2014_Feb_pdx.shp")
zoningaug2015 <- st_read("./DATA/Zoning_History/Zoning_2015_Aug_pdx.shp")
zoningfeb2015 <- st_read("./DATA/Zoning_History/Zoning_2015_Feb_pdx.shp")
zoningaug2016 <- st_read("./DATA/Zoning_History/Zoning_2016_Aug_pdx.shp")
zoningfeb2016 <- st_read("./DATA/Zoning_History/Zoning_2015_Feb_pdx.shp")
zoningaug2017 <- st_read("./DATA/Zoning_History/Zoning_2017_Aug_metro.shp")
zoningaug2018 <- st_read("./DATA/Zoning_History/Zoning_2018_Aug_pdx.shp")
zoningfeb2018 <- st_read("./DATA/Zoning_History/Zoning_2018_Feb_pdx.shp")
