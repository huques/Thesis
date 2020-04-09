# make spatial dependency maps

m <- FEmodel(sfr.dat)
length(m$residuals) # how to connect residuals back in order to map??
sm <- summary(m)
sm
fe.estimates <- sm$coefficients[,1]
#cooks.distance(m) %>% sort(decreasing = T)

# detecting leverage using fitted values vs ys
yhat <- m$fitted.values
dim(sfr.dat)

n <- colnames(sfr.dat)[colnames(sfr.dat) %in% colnames(m$model)]

# get the ys 
ys <- sfr.dat %>%
  select(STATE_ID, n) %>%
  na.omit() %>%
  select(STATE_ID, lnprice) 

ys$lnprice - yhat - m$residuals < 0.0001 # yay the resids are same as ys - yhat

# join state_id geometries to ys df

st_geometry(ys) <- taxlots_pruned %>% # add buffer to visualize color better
  filter(STATE_ID %in% ys$STATE_ID) %>%
  st_buffer(dist = 400) %>%
  st_geometry()

N <- length(m$residuals)
ys %<>%
  mutate(resid = m$residuals,
         price = taxlots_pruned %>% 
           filter(STATE_ID %in% ys$STATE_ID) %>%
           pull(SALEPRICE),
         norm = rnorm(n = N, mean = mean(m$residuals),
                      sd = sd(m$residuals)))

my.palette <- brewer.pal(n = 5, name = "PuOr")

#1
ys %>% mapview(zcol = "resid", col.regions = my.palette)
#2
ys %>% mapview(zcol = "lnprice")
#3
ys %>% mapview(zcol = "norm", col.regions = my.palette)

#4
ys %>% mapview(zcol = "resid")
#5
ys %>% mapview(zcol = "lnprice")


# --------------- no fixed effects model ----------

n <- colnames(sfr.dat)[colnames(sfr.dat) %in% colnames(no_fe_c$model)]

# get the ys 
ys_m1 <- sfr.dat %>%
  select(STATE_ID, n) %>%
  na.omit() %>%
  select(STATE_ID, lnprice) 
yhat <- no_fe_c$fitted.values
ys_m1$lnprice - yhat - no_fe_c$residuals < 0.0001 # yay the resids are same as ys - yhat


N <- length(no_fe_c$residuals)
ys_m1 %<>%
  mutate(resid = no_fe_c$residuals,
         price = taxlots_pruned %>% 
           filter(STATE_ID %in% ys_m1$STATE_ID) %>%
           pull(SALEPRICE),
         norm = rnorm(n = N, mean = mean(no_fe_c$residuals),
                      sd = sd(no_fe_c$residuals)))

st_geometry(ys_m1) <- taxlots_pruned %>% # add buffer to visualize color better
  filter(STATE_ID %in% ys_m1$STATE_ID) %>%
  st_buffer(dist = 400) %>%
  st_geometry()

# check if errors in m1, no FE exhibit pattern: they seem to! So the FE help
#6
ys_m1 %>% mapview(zcol = "resid")


# see if aligns with neighbors
nbhd.prices <- sfr.dat.na %>%
  mutate(resid.fe = m$residuals,
         resid.nofe = no_fe_c$residuals[which(sfr.dat.na$STATE_ID %in% ys_m1$STATE_ID)]) %>%
  group_by(nbhd) %>%
  summarize(price = mean(lnprice, na.rm = T),
            resid.fe = mean(resid.fe, na.rm = T),
            resid.nofe = mean(resid.nofe, na.rm = T))


nbhd.copy <- left_join(nbhd, nbhd.prices, by = c("NAME" = "nbhd")) 


#map both layers
props.map <- ys %>% mapview(zcol = "lnprice")
nbhd.boundaries <- nbhd.copy %>% mapview(alpha.regions = 0.1)
nbhd.map.price <- nbhd.copy %>% mapview(alpha.regions = 0.5, zcol = "price")
nbhd.map.resid.fe <- nbhd.copy %>% mapview(alpha.regions = 0.5, zcol = "resid.fe")
nbhd.map.resid.nofe <- nbhd.copy %>% mapview(alpha.regions = 0.5, zcol = "resid.nofe")

fe.prices <- ys %>% sample_n(1000) %>% mapview(zcol = "lnprice")

nbhd.map.resid.fe
nbhd.map.resid.nofe # can see more spatial clusterin in this map than in the FE one

nbhd.boundaries + fe.prices



