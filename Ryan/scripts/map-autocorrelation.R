library(sf)
library(tidyverse)
library(here)
library(magrittr)

#------ NBHD RESIDUAL MAPS FROM FINAL MODELS --------

# load neighborhood geometries & cleaned data frames
nbhd <- st_read(here::here("DATA", "data_20191112.gdb"), 
                "neighborhoods_no_overlap")
sfr.dat <- read.csv(here("DATA", "altered", "sfr-cleaned.csv"))
mfr.dat <- read.csv(here("DATA", "altered", "mfr-cleaned.csv"))

# join geometry to sfr data frame
sfr.dat.geom <- left_join(nbhd, sfr.dat, by = c("NAME" = "nbhd")) %>%
  group_by(STATE_ID) %>%
  slice(1) %>%
  filter(!is.na(STATE_ID)) %>%
  ungroup()

mfr.dat.geom <- left_join(nbhd, mfr.dat, by = c("NAME" = "nbhd")) %>%
  group_by(STATE_ID) %>%
  slice(1) %>%
  filter(!is.na(STATE_ID)) %>%
  ungroup()

# make data frame with mean residuals across nbhd, quadrant and no fixed effects model
sfr.nbhd.resid <- sfr.dat.geom %>%
  mutate(fe = sfr_mods[[6]]$residuals,
         quad = sfr_mods[[4]]$residuals,
         nofe = sfr_mods[[2]]$residuals) %>%
  group_by(NAME) %>%
  summarize(mean.fe = mean(fe, na.rm = T),
            mean.quad = mean(quad, na.rm = T),
            mean.nofe = mean(nofe, na.rm = T))

mfr.nbhd.resid <- mfr.dat.geom %>%
  mutate(fe = mfr_mods[[6]]$residuals,
         quad = mfr_mods[[4]]$residuals,
         nofe = mfr_mods[[2]]$residuals) %>%
  group_by(NAME) %>%
  summarize(mean.fe = mean(fe, na.rm = T),
            mean.quad = mean(quad, na.rm = T),
            mean.nofe = mean(nofe, na.rm = T))

# make sfr residual maps - FE v. no FE
mapview::mapview(sfr.nbhd.resid, alpha.regions = 0.5, zcol = "mean.fe") # fig 13
mapview::mapview(sfr.nbhd.resid, alpha.regions = 0.5, zcol = "mean.nofe") # fig 13

# mfr residual maps
mapview::mapview(mfr.nbhd.resid, alpha.regions = 0.5, zcol = "mean.fe")
mapview::mapview(mfr.nbhd.resid, alpha.regions = 0.5, zcol = "mean.quad")
mapview::mapview(mfr.nbhd.resid, alpha.regions = 0.5, zcol = "mean.nofe")


#----------------------- CONSTRAINT MAPS -------------------
# First, reattach taxlot geometries 

# 1. load taxlot geometries and non-spatial cleaned data frames
taxlots <- st_read(here::here("DATA", "data1.gdb"), "taxlots_20191010")
sfr.dat <- read.csv(here("DATA", "altered", "sfr-cleaned.csv"))
mfr.dat <- read.csv(here("DATA", "altered", "mfr-cleaned.csv"))

# 2. pivot constraints longer to use contraint as a color/fill aspect with ggplot2
sfr.trim <- sfr.dat %>% 
  select(constraints, STATE_ID, nbhd) %>%
  filter_if(is.numeric, any_vars(. == 1)) %>% 
  pivot_longer(cols = c(1:22), names_to = "Constraint") %>%
  filter(value == 1) 

# 3. trim taxlot geometries down to those from the cleaned data frame
taxlots_sfr <- taxlots %>%
  filter(STATE_ID %in% unique(sfr.trim$STATE_ID)) %>%
  select(STATE_ID)

# 4. join geometries to the SFR data frame & add buffer for visibility
sfr.dat.geom <- left_join(taxlots_sfr, sfr.trim, by = "STATE_ID") %>% 
  st_centroid() %>%
  st_buffer(dist = 200) 

# 5. RINSE & REPEAT STEPS 1-4 FOR MFR
mfr.trim <- mfr.dat %>% 
  select(constraints, STATE_ID) %>%
  filter_if(is.numeric, any_vars(. == 1)) %>% 
  pivot_longer(cols = c(1:22), names_to = "Constraint") %>%
  filter(value == 1) 

taxlots_mfr <- taxlots %>%
  filter(STATE_ID %in% unique(mfr.trim$STATE_ID)) %>%
  select(STATE_ID)

mfr.dat.geom <- left_join(taxlots_mfr, mfr.trim, by = "STATE_ID") %>% 
  st_centroid() %>%
  st_buffer(dist = 400) 

#------------------------ SET A: CONSTRAINT COUNTS -----------------------------------
# Define mapping function to plot locations/points of constrained properties

# Inputs - 
    # index: restrict index of constraints (because 27 is too many for 1 map)
    # option: choose color scheme
map_this <- function(option = "D", index, data = sfr.dat.geom){
  ggplot() +  geom_sf(data = nbhd, alpha = 0, lwd = .3) +
    geom_sf(data = data %>% filter(Constraint %in% constraints[index]), 
            aes(fill = Constraint), lwd = 0, alpha = .8) + 
  scale_fill_viridis_d(option = option) +
  theme(axis.ticks.y = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_blank(),
        panel.background = element_rect(fill = "white"),
        panel.grid.major = element_line(colour = "grey92")) 
}

# make the SFR maps
conmap1 <- map_this("inferno", 1:5)
conmap2 <- map_this("magma", 6:10) 
conmap3 <- map_this("cividis", index = 11:15)
conmap4 <- map_this("inferno", index = 16:20)

# call and save the maps
conmap1
ggsave(here("Ryan", "figs", "maps", "conmap1.png")) # fig A.1
conmap2
ggsave(here("Ryan", "figs", "maps", "conmap2.png")) # fig A.2
conmap3
ggsave(here("Ryan", "figs", "maps", "conmap3.png")) # fig A.3
conmap4
ggsave(here("Ryan", "figs", "maps", "conmap4.png")) # fig A.4


conmap1.mfr <- map_this("D", 1:5, data = mfr.dat.geom)
conmap1.mfr
conmap2.mfr <- map_this("magma", 6:10, mfr.dat.geom) 
conmap3.mfr <- map_this("cividis", index = 11:15, mfr.dat.geom)
conmapfull.mfr <- map_this("inferno", index = 1:20, mfr.dat.geom)
conmap2.mfr
conmapfull.mfr


#----------------------- SET B: CONSTRAINT PROPORTIONS -------------------------------
# Make proportion of properties constrained in a NEIGHBORHOOD and in a QUADRANT

# what proportion of properties are constrained in each neighborhood?
props = left_join(nbhd %>% select(NAME), 
                  sfr.dat %>% 
  select(constraints, STATE_ID, nbhd) %>%
  group_by(nbhd) %>%
  summarize_if(is.numeric, mean), by = c("NAME" = "nbhd")) 

# bring in quadrants geometry
sex <- here("DATA", "Portland_Administrative_Sextants",
            "Portland_Administrative_Sextants.shp") %>% 
  sf::st_read() %>%
  st_transform(2913)

# join sextant geometries and the sfr data frame, save in new df 
props_sex = left_join(sex %>% select(PREFIX), 
                  sfr.dat %>% 
                    select(constraints, STATE_ID, sextant) %>%
                    group_by(sextant) %>%
                    summarize_if(is.numeric, mean), by = c("PREFIX" = "sextant")) 

# write function that takes either props or props_sex dfs and plots the 
# proportion of each neighborhood or quadrant that are constrained
# Input - 
     # constraint: choose constraint to plot (can do only one at a time)
     # props: choose reshaped data frame (neighborhoods = props, or sextants = props_sex)
propConstrainedMap <- function(constraint, props = props){
  constraint <- enquo(constraint)
  ggplot() + 
    geom_sf(data = props, aes(fill = !!constraint), lwd = .4, alpha = .8) + 
    scale_fill_viridis_c() + theme_bw()
}

# call and save maps
propConstrainedMap(conAirHgt)
ggsave(here("Ryan", "figs", "maps", "prop-AirHgt.png"))

propConstrainedMap(conHist)
ggsave(here("Ryan", "figs", "maps", "prop-Hist.png"))

propConstrainedMap(conSLIDO)
ggsave(here("Ryan", "figs", "maps", "prop-SLIDO.png"))

propConstrainedMap(conTranCap)
ggsave(here("Ryan", "figs", "maps", "prop-trancap.png"))

propConstrainedMap(conStorm)
ggsave(here("Ryan", "figs", "maps", "prop-storm.png"))

propConstrainedMap(conLSHA)
ggsave(here("Ryan", "figs", "maps", "prop-LSHA.png")) # fig 9

propConstrainedMap(conLSHA, props = props_sex)
ggsave(here("Ryan", "figs", "maps", "prop-LSHA-quad.png")) # fig 9



