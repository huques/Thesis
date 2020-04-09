# k-fold cross validating m1 and m2

# load the library
library(caret)

n <- colnames(sfr.dat)[colnames(sfr.dat) %in% colnames(m$model)]

# define new df with nas removed
sfr.dat.na <- sfr.dat %>%
  select(STATE_ID, n) %>%
  na.omit()

# define training control
train_control <- trainControl(method="cv", number=5)
# train the model

# rewrite the formulas for each model
formula1 <- as.formula(paste0(base_controls, paste0("+ sale_zone + nbhd + I(BLDGSQFT^2) + I(AREA^2) +", constraints.sum)))
formula2 <- paste0(base_controls, paste0(" + sale_zone + I(BLDGSQFT^2) + I(AREA^2) + ",
                                       constraints.sum)) %>% as.formula()
model1 <- train(formula1, data=sfr.dat.na, trControl=train_control, method="lm")
model2 <- train(formula2, data=sfr.dat.na, trControl=train_control, method="lm")

# summarize results
print(model1) 
print(model2)

sfr.dat %>% ggplot(aes(x = SALEPRICE)) + geom_histogram()
sfr.dat.na %>% ggplot(aes(x = lnprice)) + geom_histogram() + 
  stat_function(fun = dnorm(seq(12, 16, by = .2)), 
                args = list(mean = mean(sfr.dat$lnprice), 
                            d = sd(sfr.dat$lnprice)))


#------------------------ MFR CV ------------------------------
control_vars <- c("dist_cityhall", "dist_ugb", 
                  "f_baths", "totalsqft", "AREA", "avgheight", "garage_sqft","bsmt_dum",
                  "pct_canopy_cov", "YEARBUILT", "CN_score", "BLDGSQFT", "h_baths", 
                  "percent_vacant", "attic_dum", "year_sold", "UNITS" )
# quad terms + imputed sqft
control_vars <- c(control_vars, 
                 "bldgsqft_imp", "I(bldgsqft_imp^2)", "I(AREA^2)", "I(f_baths^2)")

# grab models generated from eda-mfr.Rmd m3 and m4 had constraints
n <- colnames(mfr.dat)[colnames(mfr.dat) %in% colnames(m3$model)]

# define new df with nas removed
mfr.dat.na1 <- mfr.dat %>%
  select(STATE_ID, n) %>%
  na.omit()
mfr.dat.na2 <- mfr.dat %>%
  select(STATE_ID, n, nbhd) %>%
  na.omit()

f1 <- genFormula(control_vars, constraints)
f2 <- genFormula(control_vars, constraints, "nbhd")


model1 <- train(f1, data=mfr.dat.na1, trControl=train_control, method="lm")
model2 <- train(f2, data=mfr.dat.na2, trControl=train_control, method="lm")

print(model1)
print(model2)



