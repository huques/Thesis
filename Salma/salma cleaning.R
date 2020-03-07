library(tidyverse)
library(compareDF)

# read in csv
thesis_data <- read_csv(DATA/thesis-data.csv)


# top 1% of sales prices

# sfr
test_sfr <- thesis_data %>%
  filter(prop_type == "Single-family")

one_percent_sfr <- test_sfr %>%
  arrange(desc(SALEPRICE)) %>%
  top_frac(0.01, SALEPRICE) %>%
  select(SALEPRICE, everything())

ggplot(one_percent_sfr, aes(y = AREA, x = SALEPRICE)) +
  geom_point()

# does owner address different from site addr?
one_percent_sfr <- one_percent_sfr %>%
  mutate(same = ifelse(one_percent_sfr$OWNERADDR == one_percent_sfr$SITEADDR, 1, 0)) %>%
  filter(same == 0)

# mixed use 
test_mu <- thesis_data %>%
  filter(prop_type == "Mixed Use")


one_percent_mu <- test_mu %>%
  arrange(desc(SALEPRICE)) %>%
  top_frac(0.01, SALEPRICE) %>%
  select(SALEPRICE, everything())

ggplot(one_percent_mu, aes(y = AREA, x = SALEPRICE)) +
  geom_point()

# land trusts and proud ground





# buys and sellers : arms length transactions
gdb <- "DATA/data2.gdb"
salescop <- st_read(gdb, layer = "CoP_OrionSalesHistory")

sales <- salescop %>%
  select(PropID, Buyer, Seller)

buy_sell <- left_join(thesis_data, sales, by = c("PROPERTYID" = "PropID")) %>%
  select(SALESPRICE, buyer, seller)


# tedious but necessary
redata <- thesis_data %>%
  select(
    #structural controls
    SALEPRICE,
    YEARBUILT, yearbuilt,
    totalsqft, AREA, BLDGSQFT, taxlot_area, #AREA and toxlot_area are roughly the same
    SALEDATE, saledate,
    f_baths,
    h_baths,
    n_fireplaces,
    ADUdummy,
    
    #neighborhood controls
    OWNERZIP, 
    MapLabel, 
    percent_vacant, 
    ELEM_SCH, 
    HIGH_SCH, 
    dist_cityhall,
    dist_to_ugb,
    COUNTY, 
    
    
    #environmental controls
    pct_canopy_cov,
    total_canopy_cov,
      #finish constraints
  )

heck <- thesis_data %>% 
  select(AREA, taxlot_area)

