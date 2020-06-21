# Restrict to only observations within the 5-year interval
impsegcop$SegmentSqFt <- as.numeric(impsegcop$SegmentSqFt)

isc_pruned <- impsegcop %>%
  filter(PropID %in% propids)
dim(isc_pruned)

sum(data.frame(table(isc_pruned$PropID))$Freq > 1)

# check if these ids uniquely identify the building footprints
multi_isc <- isc_pruned %>%
  group_by(PropID, SegmentType) %>%
  mutate(n = n()) %>%
  filter(n == 1)

multi_isc %>% pull()

nrow(multi_isc)


# first attempt to widen by SegmentType
multi_isc %>%
  pivot_wider(names_from = SegmentType,
              values_from = SegmentSqFt)


# Second attempt using dcast: works perfectly on 1:1 data
library(data.table)
impsegcop_wide <- dcast(setDT(isc_pruned), PropID ~ SegmentType,
              value.var = c("SegmentSqFt"),
              fill = 0,
              fun.aggregate = sum)

# Code below turns 0 meaning PropID uniquely identifies observations
sum(data.frame(table(impsegcop_wide$PropID))$Freq > 1)



