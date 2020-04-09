library(rspatial)
library(raster)
library(spdep)
library(tidyverse)
library(spatialreg)


nn <- taxlots_pruned %>%
  filter(STATE_ID %in% sfr.dat$STATE_ID) %>% 
  arrange(STATE_ID) %>%
  poly2nb(queen=TRUE)

knn <- taxlots_pruned %>%
  filter(STATE_ID %in% sfr.dat$STATE_ID) %>% 
  arrange(STATE_ID) %>%
  as_Spatial %>%
  knearneigh(k = 4)

W <- nb2listw(nn, style="W", zero.policy = T)

sm1 <- lagsarlm(genFormula(sfr_vars), data = sfr.dat, listw = W, zero.policy = T)


plot(W, coords = taxlots_pruned %>% as_Spatial %>% coordinates)

moran.mc(hh$residuals, lw, 999)
