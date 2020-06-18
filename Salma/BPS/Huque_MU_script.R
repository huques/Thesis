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
thesis_data <- read_csv(here::here("DATA","thesis-data.csv"))        #34,661 obs


# Subset Data
MU_raw <- thesis_data %>%
  filter(prop_type == "Mixed Use")                                    #2,041 obs

#-------------------------------------------------------------------------

# Make a string of constraints names called "con_names"
MU_constraints_raw <- MU_raw %>%
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
                conTranCap, conTranInt, conTranSub)

clean_names <- names(MU_constraints_raw)

con_names <- paste(clean_names, collapse = " + ")

# function to switch the NAs in the constraints to 0s
to0 <- function(x){ifelse(is.na(x), 0, x)}

#-------------------------------------------------------------------------

# Format MU Dataframe: 
# Select variables
# No actual filtering done at this point, all MU obs kept. 
MUtest1 <- MU_raw %>%
  dplyr::select(-c(OWNER2, OWNER3, OWNERZIP, 
                   MKTVALYR1, MKTVALYR2,
                   BLDGVAL1, BLDGVAL2,
                   LANDVAL1, LANDVAL2,  
                   TOTALVAL1, TOTALVAL2,
                   MS_GRADE, ES_GRADE,
                   LEGAL_DESC, 
                   LANDUSE, 
                   BEDROOMS, ACC_STATUS, 
                   NAME, COMMPLAN,
                   COALIT, HORZ_VERT, AUDIT_NBRH, 
                   MIDDLE_SCH,  Category, SOURCE, 
                   FRONTAGE, COUNTY, YEARBUILT))                      #2,041 obs

# Format MU Dataframe: 
#set NAs as zero, add in improvements, mutate filtering parameters

#garage sqft
MUgar_sqft_sum <- MUtest1 %>%
  dplyr::select(matches("gar"), matches("car")) %>%
  rowSums()

# basement sqft
MUbsmt_sqft_sum <- MUtest1 %>%
  dplyr::select(matches("bsmt")) %>%
  dplyr::select(-c("BSMT PARKING","BSMT GAR")) %>%
  rowSums()

# creating zone change dummy
MUzone_test <- MUtest1 %>%
  dplyr::select(matches("zone"), -c(ZONE_DESC_aug2016, ZONE_DESC_aug2018, ZONE_DESC_feb2018, `Zone Description`, sale_zone)) %>%
  mutate_all(str_replace, pattern = "R", replacement = "") %>%
  mutate_all(funs(as.numeric)) %>%
  rowSums()

# adding new vars to MUtest1
MUtest1 %<>%
  mutate_at(vars(clean_names), to0) %>%
  mutate(garage_sqft = MUgar_sqft_sum,
         garage_dum = as.numeric(garage_sqft > 0),
         bsmt_sqft = MUbsmt_sqft_sum,
         bsmt_dum = as.numeric(bsmt_sqft > 0),
         sum_z = MUzone_test,
         avg_z = sum_z/9,
         z_change = case_when(avg_z == 5 ~ 0,
                              TRUE ~ 1),
         top_1 =  SALEPRICE > quantile(SALEPRICE, .99),
         MKTVALYR3 = case_when(MKTVALYR3 != 2018 ~ 2017, 
                               TRUE ~ 2018),
         price_diff = SALEPRICE - LANDVAL3, 
         price_ratio = SALEPRICE/LANDVAL3 * 100,
         vacant_dummy = as.numeric(PRPCD_DESC == "VACANT LAND"),
         sale_z_old = case_when(sale_zone == "EX" ~ "Central Employment",
                                sale_zone == "CS" ~ "Storefront Commercial",
                                sale_zone == "CM" ~ "Mixed Commercial/Residential",
                                sale_zone == "CG" ~ "General Commercial",
                                sale_zone == "CO1" | sale_zone == "CO2" ~ "Office Commercial",
                                sale_zone == "CN1" | sale_zone == "CN2" ~ "Neighborhood Commercial",                                 
                                sale_zone == "CM1" ~ "Mixed Use 1",
                                sale_zone == "CM2" ~ "Mixed Use 2",
                                sale_zone == "CM3" ~ "Mixed Use 3",
                                sale_zone == "CX" ~ "Central Commercial",
                                TRUE ~ "Mixed Use"),
         sale_z_new = case_when(sale_zone == "EX" ~ "Mixed Use 3", #unclear, depends on location
                                sale_zone == "CS" ~ "Mixed Use 2",
                                sale_zone == "CM" ~ "Mixed Use 2", 
                                sale_zone == "CG" ~ "Commercial Employment", #corridor vs center CM2 vs CE
                                sale_zone == "CO1" ~ "Mixed Use 1",
                                sale_zone == "CO2" ~ "Mixed Use 2",
                                sale_zone == "CN1" | sale_zone == "CN2" ~ "Mixed Use 1",                                 
                                sale_zone == "CM1" ~ "Mixed Use 1",
                                sale_zone == "CM2" ~ "Mixed Use 2",
                                sale_zone == "CM3" ~ "Mixed Use 3",
                                sale_zone == "CX" ~ "Mixed Use 3",
                                TRUE ~ "Mixed Use 2"),
         owner_state_dummy = case_when(OWNERSTATE == "OR" ~ "1",
                                       TRUE ~ "0"),
         totalsqft_sqd = totalsqft*totalsqft,
         taxlot_area_sqd = taxlot_area*taxlot_area,
         n_fireplaces = replace_na(n_fireplaces, 0),
         fireplace_dum = as.numeric(n_fireplaces > 0),
         ADUdummy = as.numeric(ADUdummy > 0),
         total_canopy_cov = replace_na(total_canopy_cov, 0),
         canopy_dum = as.numeric(total_canopy_cov > 0),
         arms_length100 = case_when(price_ratio > 100 ~ TRUE,
                                    TRUE ~ FALSE),
         arms_length20 = case_when(price_ratio > 20 ~ TRUE,
                                   TRUE ~ FALSE),
         yearbuilt = na_if(yearbuilt, 0),
         saleprice_zero = case_when(SALEPRICE == 0 ~ TRUE,
                                    TRUE ~ FALSE),
         saledate = mdy(SALEDATE), 
         year_sold = year(saledate),
         age_sold = year_sold - yearbuilt,
         percent_vacant = percent_vacant*100,
         SALEPRICElog = log(SALEPRICE),
         FLOORS = replace_na(FLOORS, 1),
         FLOORS = case_when(FLOORS == 0 ~ 1,
                            TRUE ~ FLOORS),
         totalsqft_imp = case_when(is.na(totalsqft) ~ BLDGSQFT,
                                   TRUE ~ totalsqft),
         totalsqft_sqd_imp = totalsqft_imp*totalsqft_imp,
         totalsqft_na = case_when(is.na(totalsqft) ~ FALSE,
                                  TRUE ~ TRUE),
         age_sold_na = is.na(age_sold),
         maxheight = na_if(maxheight, 0),
         volume = na_if(volume, 0)) %>%
  dplyr::select(-c(matches("zone")))                                  #2,041 obs
#-------------------------------------------------------------------------

# Clean MU dataframe: 
# remove based on filtering parameters
MUtest2 <- MUtest1 %>%
  filter(totalsqft != 0,                    #1,544 obs -- 497 cases, 497 removed
         age_sold >= 0,                     #1,417 obs -- 616 cases, 127 removed   
         vacant_dummy == FALSE,             #1403 obs -- 137 cases, 14 removed  
         SALEPRICE > 30000,                 #1361 obs -- 60 cases, 42 removed   
         yearbuilt > 1500,                  #1361 obs -- 596 cases, 0 removed   
         arms_length20 == TRUE,             #1357 obs -- 67 cases, 4 removed    
         BLDGVAL3 > 50000,                  #1325 obs -- 371 cases, 32 removed    
         f_baths > 0 | h_baths > 0,         #694 obs -- 1,164 cases, 631 removed   
         totalsqft > 600)                   #687 obs -- 515 cases, 7 removed                        


#-------------------------------------------------------------------------

# Select final relevant variables
MU_dat <- MUtest2 %>%
  dplyr::select(
    STATE_ID, RNO, PROPERTYID, TLID, 
    OWNER1, owner_state_dummy, 
    SITEADDR, SITEZIP, TAXCODE, PRPCD_DESC, 
    MKTVALYR3, LANDVAL3, BLDGVAL3, TOTALVAL3, 
    arms_length100, arms_length20, 
    saledate, SALEPRICE, SALEPRICElog, saleprice_zero,
    age_sold, age_sold_na,
    totalsqft, totalsqft_sqd, totalsqft_imp, totalsqft_sqd_imp, totalsqft_na,
    taxlot_area, taxlot_area_sqd, 
    FLOORS,  
    UNITS, volume,
    maxheight,
    f_baths, h_baths,
    n_fireplaces, fireplace_dum, ADUdummy, 
    garage_sqft, garage_dum, bsmt_sqft, bsmt_dum, 
    percent_vacant, vacant_dummy,
    pct_canopy_cov, total_canopy_cov, canopy_dum, 
    zone_change = z_change, sale_z_old, sale_z_new, 
    CN_score, Neighborhood = MapLabel, HIGH_SCH, ELEM_SCH, dist_cityhall, dist_ugb,
    contains("con"), contains("pct")) %>%
  dplyr::select(-c("CONCRETE", "FIN SECOND", "PAVING/CONCRETE ONLY", "UNF SECOND", "conFldway", "pct_conFldway")) 

#========================================================================
#========================================================================
#========================================================================

# Final Model
MU_final = formula(paste0("SALEPRICElog ~ 
                             age_sold + totalsqft_sqd + taxlot_area_sqd + 
                         FLOORS + 
                         f_baths + h_baths + 
                         vacant_dummy + sale_z_new + 
                         CN_score + dist_cityhall + dist_ugb + ", con_names))
MU_final.mod <- lm(MU_final, MU_dat)

#========================================================================
#========================================================================
#========================================================================


# Create dataframe with Coefficient Percent Effect 
# remember semi-log transformation means you can't directly interpret coefficient!
MU_final.coef <- data.frame(variable = names(MU_final.mod[["model"]]),
                            coef = MU_final.mod[["coefficients"]]) %>%
  filter(is.na(coef) == FALSE) %>%
  mutate(percenteffect = (exp(coef) - 1)*100)

# Create table with Constraints Counts
MU_constraints_table <- MU_dat %>%
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
MU_controls_dat <- MU_dat %>%
  # Select and rename
  dplyr::select(
    `Assessed Land Value (2017)` = LANDVAL3,
    `Assessed Building Value (2017)` = BLDGVAL3,
    `Total Assessed Value (2017)` = TOTALVAL3,
    
    `Sale Price` = SALEPRICE,
    `Log Sale Price` = SALEPRICElog,
    `Age When Sold` = age_sold,
    `Building Footprint (sqft)` = totalsqft,
    `Building Footprint Squared (sqft)` = totalsqft_sqd,
    `Taxlot Area (sqft)` = taxlot_area,
    `Taxlot Area Squared (sqft)` = taxlot_area_sqd,
    `Building Volume` = volume,
    `Number of Floors` = FLOORS,
    `Maximum Building Height (ft)` = maxheight,
    
    `Full Baths` = f_baths,
    `Half Baths` = h_baths,
    
    `Vacant Properties in 200ft Radius (%)` = percent_vacant,
    `Vacant Dummy` = vacant_dummy,
    `Canopy Cover (% of lot)` = pct_canopy_cov,
    `Canopy Cover Dummy` = canopy_dum,
    `Complete Neighborhoods Score (0-100)` = CN_score,
    `Distance to Central Business District (ft)` = dist_cityhall,
    `Distance to Urban Growth Boundary (ft)` = dist_ugb)

# Create table with Controls Counts
# note that I removed missing observations 
MU_controls_table <-  MU_controls_dat %>%
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


# Creates an html output of the model results called "MU_final" 
# can be opened as a word doc
stargazer(
  MU_final.mod, 
  type = "html",
  title = "Mixed-use Residential Results",
  style = "io",
  out = "MU_final.htm",
  column.labels = c("Log Sale Price <br> (standard error)"),
  covariate.labels = c(
    "Constant",
    "Age When Sold", "Building Footprint Squared (sqft)", "Taxlot Area Squared (sqft)",
    "Number of Floors", "Maximum Building Height (ft)", "Buildnig Use Dummy", 
    "Full Baths", "Half Baths", "Vacant Properties in 200ft Radius (%)",
    "Zoning Dummy 1", "Zoning Dummy 2", "Zoning Dummy 3",
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
rm(MUtest1, MUtest2)

