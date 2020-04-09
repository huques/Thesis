# plots to be put in body of thesis
library(tidyverse)
library(cowplot)

cn.m <- plotCts("CN_score", sfr.dat)
cn.s <- plotCts("CN_score", mfr.dat)
cowplot::plot_grid(plotlist = list(cn.m, cn.s))


# SFR MFR dif in cn score
# cn.m <- plotCts("CN_score", sfr.dat, tit = "SFR")
# cn.s <- plotCts("CN_score", mfr.dat, tit = "MFR")
# cowplot::plot_grid(plotlist = list(cn.m, cn.s))

# sfr - y histogram
sfr.y.hist <- sfr.dat %>% ggplot(aes(x = lnprice)) + geom_histogram() + 
  labs(title = "SFR distribution of log sale price",
       y = "",
       x = "") +
  theme_minimal()

# mfr - y histogram (check math-392 lab to see how you generated before...)
mfr.y.hist <- mfr.dat %>% 
  mutate(xs = seq(min(lnprice), max(lnprice), length.out = nrow(.))) %>%
  ggplot(aes(x = lnprice)) + 
  geom_histogram(aes(x = lnprice)) + 
  labs(title = "MFR distribution of log sale price",
       y = "",
       x = "") +
  
  theme_minimal()

# scatterplot of imputed buildingsqft
mfr.dat %>%
  #  filter(imputed == F) %>%
  ggplot(aes(x = bldgsqft_imp, y = lnprice, color = imputed)) +
  geom_point(alpha = 0.5) +
  xlim(0, 5000) + 
  labs(title = "", 
       x = "Imputed Building Square Footage",
       y = "Log of sale price") +
  theme_minimal()

cowplot::plot_grid(plotlist = list(sfr.y.hist, mfr.y.hist))


# map of study area

mmapdf <- inner_join(taxlots_pruned %>% select(STATE_ID), mfr.dat, by = "STATE_ID")
smapdf <- inner_join(taxlots_pruned %>% select(STATE_ID), sfr.dat, by = "STATE_ID")

st_geometry(mmapdf) <- mmapdf %>% st_buffer(200) %>% st_geometry
st_geometry(smapdf) <- smapdf %>% st_buffer(200) %>% st_geometry

mapview(mmapdf[1:500,], col.regions = "blue", alpha = .5) + 
  mapview(smapdf[1:5000,], col.regions = "red", alpha = .5) 



