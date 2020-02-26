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