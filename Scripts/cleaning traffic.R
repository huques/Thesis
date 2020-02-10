
# set working directory (broken as of 2/4)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# read in csv
raw_traffic <- read.csv(file = "./DATA/traffic_volume.csv")

# select useful variables
traffic <- raw_traffic %>%
  select(LocationDesc, Bound, StartDate, EndDate, ADTVolume, AMVolume, 
         AMPkHrVol, PMVolume, PMPkHrVol, x, y)


ggplot2::


##DATASET INFO
#
#ADTVolume = Average Daily Traffic
#AMVolume = Morning Volume
#AMPkHrVol = Morning Peak Hour Volume
#ExceptType = bike count, lane count, obstruction, normal, weekend, test/tc device?
#
# I have no idea what the comments are indicating





















