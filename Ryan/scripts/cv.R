# K-fold cross validation for best SFR and MFR models...
   # SFR: neighborhood FE
   # MFR: quadrant FE

#-------------------------- OVERVIEW -----------------------------
# The idea with this script is to give another metric of fit to assess the 6 models for each
# property type using  test mean squared error (MSE). Tegression diagnostics - R squared adjusted,
# AIC, BIC, df, etc, are different flavors that get at training error, which tells us how well
# the model performs on the given data. Training MSE necessarily decreases with the number
# of variables used to fit the model, but at some point extra, uninformative variables
# are harmful and the model performs worse (there is increased variance). 

# To approximate test MSE, which is a measure of how well the model predicts house prices 
# of observations that were not used to fit it, I use 5-fold cross validation. This shuffles the data,
# splits it into 5 groups. Then for each group, use the 4 other groups
# to fit the model (ie. to generate coefficients/best fit parameters), 
# then use the remaining group (test set) to evaluate the MSE. 
#------------------------------------------------------------------

# load the cv library
library(caret)
library(nlme)


sfr.dat <- read.csv(here("DATA", "sfr-cleaned.csv"))
mfr.dat <- read.csv(here("DATA", "mfr-cleaned.csv"))
n <- colnames(sfr.dat)[colnames(sfr.dat) %in% colnames(m$model)]

# define training control
train_control <- trainControl(method="cv", number=10)
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

# define training control
train_control <- trainControl(method="cv", number=5)

model1 <- train(genFormula(mfr_vars, constraints), 
                data=mfr.dat, trControl=train_control, method="lm")
model2 <- train(genFormula(mfr_vars, constraints, "nbhd"), 
                data=mfr.dat, trControl=train_control, method="lm")
model3 <- train(genFormula(mfr_vars, constraints, "sextant"), 
                data=mfr.dat, trControl=train_control, method="lm")


print(model1)
print(model2)
print(model3)

# -------------------- 4/30 update----------------------------
# bring in formula function and constants from big-clean and generate-figures:

#=========================================================================
constraints <- c("conAirHgt",
                 "conCovrly", "conPovrly",
                 "conHist", "conHistLdm", 
                 "conLSHA", "conLUST",
                 "conNoise", "conSewer", "conSLIDO",
                 "conSlp25", "conStorm", "conTranCap", "conTranSub",
                 "conTranInt", "conTranSub", "conWater", 
                 "conPubOwn", "conFld100_ft", "conECSI",
                 "conGW")
collinearity.mfr <- c("conWetland", "conPrvCom", "conPovrly", "conSewer", "conLUST")
collinearity.sfr <- c("conWetland", "conPrvCom")
sfr_vars <- c("dist_cityhall", "dist_ugb", "h_baths",
              "f_baths", "AREA", "maxheight", "totalsqft", "garage_dum","bsmt_dum",
              "pct_canopy_cov", "YEARBUILT", "n_fireplaces", "CN_score", "attic_dum", "year_sold", 
              "percent_vacant", "I(AREA^2)", "I(totalsqft^2)", "I(CN_score^2)")
mfr_vars <- c("dist_cityhall", "dist_ugb", "h_baths",
              "f_baths", "AREA", "maxheight", "garage_dum","bsmt_dum", 
              "pct_canopy_cov", "YEARBUILT", "CN_score", "attic_dum", "year_sold", "n_fireplaces",
              "percent_vacant", "n_units", "n_buildings", "totalsqft", "I(totalsqft)", "I(AREA^2)", "I(f_baths^2)")
genFormula <- function(...){
  string <- paste(c(...), collapse = " + ")
  paste0("lnprice ~", string) %>% as.formula
}
#=========================================================================

cv.mfr.quad <- train(genFormula(mfr_vars, "sextant", setdiff(constraints, collinearity.mfr)), 
                data=mfr.dat, trControl=train_control, method="lm")

cv.mfr.nbhd <- train(genFormula(mfr_vars, "nbhd", setdiff(constraints, collinearity.mfr)), 
                     data=mfr.dat, trControl=train_control, method="lm")

cv.mfr.nofe <- train(genFormula(mfr_vars, setdiff(constraints, collinearity.mfr)), 
                data=mfr.dat, trControl=train_control, method="lm")

cv.mfr.nofe  # RMSE: 0.264 
cv.mfr.quad  # RMSE: 0.2430933
cv.mfr.nbhd  # RMSE: 0.2323195


cv.sfr.quad <- train(genFormula(sfr_vars, "sextant", setdiff(constraints, collinearity.sfr)), 
                     data=sfr.dat, trControl=train_control, method="lm")

cv.sfr.nbhd <- train(genFormula(sfr_vars, "nbhd", setdiff(constraints, collinearity.sfr)), 
                     data=sfr.dat, trControl=train_control, method="lm")

cv.sfr.nofe <- train(genFormula(sfr_vars, setdiff(constraints, collinearity.sfr)), 
                     data=sfr.dat, trControl=train_control, method="lm")


cv.sfr.nofe   # RMSE: 0.2036476
cv.sfr.quad   # RMSE: 0.2019262
cv.sfr.nbhd   # RMSE: 0.1858925


