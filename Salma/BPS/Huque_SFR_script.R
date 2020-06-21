# Import Packages
library(tidyverse)
library(magrittr)
library(here)
library(data.table)
library(MASS)
library(knitr)
library(stargazer)
library(lubridate)

#-------------------------------------------------------------------------

# Read in Data
thesis_data <- read_csv(here::here("DATA","thesis-data.csv")) #34,661 obs
  

# Subset Data
SFR_raw <- thesis_data %>%
  filter(PRPCD_DESC == "RESIDENTIAL IMPROVED", prop_type == "Single-family") #25,266 obs

#-------------------------------------------------------------------------

# Make a string of constraints names called "con_names"
SFR_constraints_raw <- SFR_raw %>%
  dplyr::select(conECSI, conLUST, 
                conHist, conHistLdm, conNatAm,
                conCovrly, conPovrly,
                conAirHgt, conHeliprt, conNoise,
                conGW,
                conLSHA, conSLIDO, conFld100, conSlp25, 
                conSewer, conStorm, conWater,
                conWetland,
                conInstit, conPrvCom, conPubOwn,
                conView,
                conTranCap, conTranInt, conTranSub) #25,266 obs

clean_names <- names(SFR_constraints_raw)

con_names <- paste(clean_names, collapse = " + ")

# function to switch the NAs in the constraints to 0s
to0 <- function(x){ifelse(is.na(x), 0, x)}

#-------------------------------------------------------------------------

# Format SFR Dataframe: 
# Select variables
# No actual filtering done at this point, all SFR obs kept. 
test1 <- SFR_raw %>%
  dplyr::select(-c(OWNER2, OWNER3, OWNERZIP, 
                   MKTVALYR1, MKTVALYR2,
                   BLDGVAL1, BLDGVAL2,
                   LANDVAL1, LANDVAL2,  
                   TOTALVAL1, TOTALVAL2,
                   MS_GRADE, ES_GRADE,
                   LEGAL_DESC, TAXCODE, 
                   PROP_CODE, LANDUSE, 
                   BEDROOMS, ACC_STATUS, 
                   NAME, COMMPLAN, 
                   COALIT, HORZ_VERT, AUDIT_NBRH, 
                   MIDDLE_SCH,  Category, SOURCE, 
                   FRONTAGE, COUNTY, YEARBUILT)) #25,266 obs

#garage sqft
gar_sqft_sum <- test1 %>%
  dplyr::select(matches("gar"), matches("car")) %>%
  rowSums()

#deck/patio/porch sqft
deck_sqft_sum <- test1 %>%
  dplyr::select(matches("deck"), matches("patio"), matches("porch")) %>%
  rowSums()

# attic sqft
attic_sqft_sum <- test1 %>%
  dplyr::select(matches("attic")) %>%
  rowSums()

# basement sqft
bsmt_sqft_sum <- test1 %>%
  dplyr::select(matches("bsmt")) %>%
  dplyr::select(-c("BSMT PARKING","BSMT GAR")) %>%
  rowSums()

# creating zone change dummy
zone_test <- test1 %>%
  dplyr::select(matches("zone"), -c(ZONE_DESC_aug2016, ZONE_DESC_aug2018, ZONE_DESC_feb2018, `Zone Description`, sale_zone)) %>%
  mutate_all(str_replace, pattern = "R", replacement = "") %>%
  mutate_all(funs(as.numeric)) %>%
  rowSums()

# Format SFR Dataframe: 
#set NAs as zero, add in improvements, mutate filtering parameters
test1 %<>%
  mutate_at(vars(all_of(clean_names)), to0) %>%
  mutate(
         price_diff = SALEPRICE - LANDVAL3, 
         price_ratio = SALEPRICE/LANDVAL3 * 100,
         vacant_dummy = as.numeric(PRPCD_DESC == "VACANT LAND"),
         llc_flag = grepl("LLC", OWNER1),
         proud_flag =  grepl("PROUD", OWNER1),
         trust_flag = grepl("TRUST", OWNER1) & 
           !grepl("FAMILY", OWNER1) & 
           !grepl("LIVING", OWNER1),
         garage_sqft = gar_sqft_sum,
         garage_dum = as.numeric(garage_sqft > 0),
         deck_sqft = deck_sqft_sum,
         deck_dum = as.numeric(deck_sqft > 0),
         attic_sqft = attic_sqft_sum,
         attic_dum = as.numeric(attic_sqft > 0),
         bsmt_sqft = bsmt_sqft_sum,
         bsmt_dum = as.numeric(bsmt_sqft > 0),
         n_fireplaces = replace_na(n_fireplaces, 0),
         fireplace_dum = as.numeric(n_fireplaces > 0),
         ADUdummy = as.numeric(ADUdummy > 0),
         total_canopy_cov = replace_na(total_canopy_cov, 0),
         canopy_dum = as.numeric(total_canopy_cov > 0),
         sum_z = zone_test,
         avg_z = sum_z/9,
         z_change = case_when(avg_z == 5 ~ 0,
                              TRUE ~ 1),
         totalsqft_sqd = totalsqft*totalsqft,
         taxlot_area_sqd = taxlot_area*taxlot_area,
         arms_length = price_ratio > 20,
         yearbuilt = na_if(yearbuilt, 0),
         saledate = mdy(SALEDATE), 
         year_sold = year(saledate),
         age_sold = year_sold - yearbuilt,
         pct_canopy_cov = pct_canopy_cov*100,
         SALEPRICElog = log(SALEPRICE),
         top_1 =  SALEPRICE > quantile(SALEPRICE, .99),
         MKTVALYR3 = case_when(MKTVALYR3 != 2018 ~ 2017, 
                               TRUE ~ 2018),) #25,266 obs

#-------------------------------------------------------------------------

# Clean SFR dataframe: 
# remove based on filtering parameters
test2 <- test1 %>%
  dplyr::select(-c(matches("zone"))) %>% #25,266 
  filter(between(totalsqft, 1, 7500),           #24,717 -- 549 cases, 549 removed  
         yearbuilt > 1500,                      #24,107 -- 1,114 cases, 610 removed  
         f_baths < 6,                           #24,072 -- 405 cases, 35 removed  
         BLDGSQFT != 0,                         #24,064 -- 49 cases, 8 removed  
         age_sold > 0,                          #23,970 -- 1,213 cases, 94 removed 
         top_1 == FALSE,                        #23,761 -- 253 cases, 209 removed 
         arms_length == TRUE,                   #23,299 -- 518 cases, 462 removed  
         proud_flag == FALSE,                   #23,299 -- 15 cases, 0 removed  
         llc_flag == FALSE,                     #23,001 -- 413 cases, 298 removed  
         trust_flag == FALSE,                   #22,960 -- 52 cases, 41 removed 
         vacant_dummy == FALSE)                 #0 cases

# total removed: 2,306 or 9.13% of raw sfr dataset

#-------------------------------------------------------------------------

# Select final relevant variables
SFR_dat <- test2 %>% #22,960 obs
  dplyr::select(
    STATE_ID, RNO, PROPERTYID, TLID, 
    OWNER1, SITEADDR, SITEZIP, PRPCD_DESC, 
    MKTVALYR3, LANDVAL3, BLDGVAL3, TOTALVAL3, 
    saledate, SALEPRICE, SALEPRICElog, age_sold,
    totalsqft, totalsqft_sqd, taxlot_area, taxlot_area_sqd, volume, 
    f_baths, h_baths, n_fireplaces, fireplace_dum, ADUdummy, 
    garage_sqft, garage_dum, deck_sqft, deck_dum, 
    attic_sqft, attic_dum, bsmt_sqft, bsmt_dum, 
    percent_vacant, vacant_dummy,
    pct_canopy_cov, total_canopy_cov, canopy_dum, zone_change = z_change,
    CN_score, Neighborhood = MapLabel, HIGH_SCH, ELEM_SCH, dist_cityhall, dist_ugb,
    contains("con"), contains("pct")) %>%
  dplyr::select(-c("CONCRETE", "FIN SECOND", "PAVING/CONCRETE ONLY", "UNF SECOND", "conFldway", "pct_conFldway")) 


#========================================================================
#========================================================================
#========================================================================


# Final Model
SFR_final = formula(paste0("SALEPRICElog ~ 
                             age_sold + totalsqft + taxlot_area + 
                         + volume + f_baths + h_baths + 
                         fireplace_dum + ADUdummy +  
                         garage_dum + attic_dum + bsmt_dum + deck_dum +
                         percent_vacant + pct_canopy_cov + zone_change +
                         CN_score + 
                         dist_cityhall + dist_ugb + ", con_names))
SFR_final.mod <- lm(SFR_final, SFR_dat)


#========================================================================
#========================================================================
#========================================================================


# Create dataframe with Coefficient Percent Effect 
# remember semi-log transformation means you can't directly interpret coefficient!
SFR_final.coef <- data.frame(variable = names(SFR_final.mod[["model"]]),
                             coef = SFR_final.mod[["coefficients"]]) %>%
  mutate(percent_effect = (exp(coef) - 1)*100)

# Create dataframe with Constraints Counts
SFR_constraints_table <- SFR_dat %>%
  dplyr::select(conECSI, conLUST, 
                conHist, conHistLdm, conNatAm,
                conCovrly, conPovrly,
                conAirHgt, conHeliprt, conNoise,
                conGW,
                conLSHA, conSLIDO, conFld100, conSlp25, 
                conSewer, conStorm, conWater,
                conWetland,
                conInstit, conPrvCom, conPubOwn,
                conView,
                conTranCap, conTranInt, conTranSub) %>%
  pivot_longer(cols = starts_with("con"),
               names_to = "Constraint",
               values_to = "Value") %>%
  group_by(Constraint, Value) %>%
  summarize(Count = n()) %>%
  pivot_wider(names_from = Value,
              values_from = Count) %>%
  rename(Yes = `1`,
         No = `0`) %>%
  mutate(Percent_Yes = (Yes/No)*100) 

# Create dataframe with Controls Counts
SFR_controls_dat <- SFR_dat %>%
  dplyr::select(
    `Assessed Land Value (2017)` = LANDVAL3,
    `Assessed Market Value (2017)` = BLDGVAL3,
    `Total Assessed Value (2017)` = TOTALVAL3,
    
    `Sale Price` = SALEPRICE,
    `Log Sale Price` = SALEPRICElog,
    `Age When Sold` = age_sold,
    `Building Footprint (sqft)` = totalsqft,
    `Building Footprint Squared (sqft)` = totalsqft_sqd,
    `Taxlot Area (sqft)` = taxlot_area,
    `Taxlot Area Squared (sqft)` = taxlot_area_sqd,
    `Building Volume` = volume,
    
    `Full Baths` = f_baths,
    `Half Baths` = h_baths,
    `Fireplaces` = n_fireplaces,
    `Fireplaces Dummy` = fireplace_dum,
    `Accessible Dwelling Unit Dummy` = ADUdummy,
    `Garage Dummy` = garage_dum,
    `Garage Area (sqft)` = garage_sqft,
    `Attic Dummy` = attic_dum,
    `Attic Area (sqft)` = attic_sqft,
    `Basement Dummy` = bsmt_dum,
    `Basement Area (sqft)` = bsmt_sqft,
    `Deck Dummy` = deck_dum,
    `Deck Area (sqft)` = deck_sqft,
    
    `Vacant Properties in 200ft Radius (%)` = percent_vacant,
    `Canopy Cover (% of lot)` = pct_canopy_cov,
    `Canopy Cover (sqft)` = total_canopy_cov,
    `Canopy Cover Dummy` = canopy_dum,
    `Zoning Change Dummy` = zone_change,
    `Complete Neighborhoods Score (0-100)` = CN_score,
    `Distance to Central Business District (ft)` = dist_cityhall,
    `Distance to Urban Growth Boundary (ft)` = dist_ugb,
    `Neighborhood Fixed Effects` = Neighborhood)


# note that I removed missing observations and Neighborhood Fixed Effects
SFR_controls_table <- SFR_controls_dat %>%
  dplyr::select(-`Neighborhood Fixed Effects`) %>%
  pivot_longer(everything(),
               names_to = "Constraint_Names",
               values_to = "Values") %>%
  group_by(Constraint_Names) %>%
  summarize(mean = mean(Values, na.rm = TRUE),
            median = median(Values, na.rm = TRUE),
            stdev = sd(Values, na.rm = TRUE),
            min = min(Values, na.rm = TRUE),
            max = max(Values, na.rm = TRUE),
            num_na = sum(is.na(Values)))
  

#========================================================================
#========================================================================
#========================================================================


# Creates an html output of the model results called "SFR_final" 
# can be opened as a word doc
stargazer(
  SFR_final.mod,
  type = "html",
  title = "Single-Family Residential Results",
  style = "io",
  out = "SFR_final.htm",
  column.labels = c("Log Sale Price <br> (standard error)", "Marginal Price (%)"),
  covariate.labels = c(
    "Constant",
    "Age When Sold", 
    "Building Footprint (sqft)", 
    "Taxlot Area (sqft)",
    "Building Volume (cuft)", 
    "Full Baths", 
    "Half Baths", 
    "Fireplace Dummy",
    "Accessible Dwelling Unit Dummy", 
    "Garage Dummy", 
    "Attic Dummy",
    "Basement Dummy", 
    "Deck Dummy",
    "Vacant Properties in 200ft Radius (%)",
    "Canopy Cover (% of lot)", 
    "Zoning Change Dummy",
    "Complete Neighborhoods Score (0-100)",
    "Distance to Central Business District (ft)",
    "Distance to Urban Growth Boundary (ft)",
    
    "DEQ Environmental Cleanup Sites (ECSI)",
    "DEQ Leaking Underground Storage Tank Cleanup Sites (LUST)",
    "Historic and Conservation Districts",
    "Historic and Conservation Landmarks",
    "Areas Requiring Archeological Scan or Consultation with Tribes",
    "Conservation Zones",
    "Preservation Zones",
    "Approach and Departure Cones",
    "Helipad Landing",
    "Airport Noise",
    "Greenway",
    "DOGAMI Landslide Hazard Area",
    "DOGAMI Digital Landslide Database (SLIDO)",
    "FEMA 100-Year Floodplain Map",
    "Slopes Over 25% Incline",
    "Sewer System",
    "Stormwater System",
    "Water System",
    "Wetlands",
    "Institutional Campuses",
    "Private/Common Open Space",
    "Publicly Owned Lots",
    "Scenic Views",
    "Traffic Volume Exceeds Capacity",
    "ODOT Highway Interchanges",
    "Substandard and Unimproved Streets"), # rename labels
  initial.zero = TRUE,
  notes.align = "l",
  single.row = FALSE,
  keep.stat = c("n", "rsq"),
  no.space = TRUE,
  colnames = FALSE,
  digits.extra = 3,
  intercept.bottom = FALSE,
  header = FALSE)

# remove extraneous datasets
rm(test1, test2)


