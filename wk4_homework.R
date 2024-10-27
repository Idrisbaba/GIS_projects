# Load necessary libraries
library(dplyr)
library(countrycode)
library(sf)

# Read gender inequality data
gender_data <- read.csv("~/GIS/Week_4/CSV/hdr-data.csv")

# Read spatial data
world_spatial <- st_read("~/GIS/Week_4/Shapefile/World_Countries.geojson")

# Ensure country codes match
gender_data <- gender_data %>%
  mutate(iso3 = countrycode(country, 'country.name', 'iso3c'))

# Filter and rename for 2010 data
gender_data_2010 <- gender_data %>%
  filter(year == 2010) %>%
  group_by(iso3) %>%
  summarize(GII_2010 = mean(value, na.rm = TRUE))

# Filter and rename for 2019 data
gender_data_2019 <- gender_data %>%
  filter(year == 2019) %>%
  group_by(iso3) %>%
  summarize(GII_2019 = mean(value, na.rm = TRUE))

# Ensure country codes match for spatial data
world_spatial <- world_spatial %>%
  mutate(iso3 = countrycode(COUNTRY, 'country.name', 'iso3c'))

# Create a custom dictionary for special cases
custom_mapping <- c(
  "Azores" = "PT",
  "Bonaire" = "BQ",
  "Canarias" = "ES",
  "Glorioso Islands" = "FR",
  "Juan De Nova Island" = "FR",
  "Madeira" = "PT",
  "Micronesia" = "FM",
  "Saba" = "BQ",
  "Saint Eustatius" = "BQ",
  "Saint Martin" = "MF"
)

# Apply the custom mapping
world_spatial$iso3 <- ifelse(world_spatial$COUNTRY %in% names(custom_mapping),
                             custom_mapping[world_spatial$COUNTRY],
                             world_spatial$iso3)

# Join datasets
joined_data <- world_spatial %>%
  left_join(gender_data_2010, by = "iso3") %>%
  left_join(gender_data_2019, by = "iso3")

# Calculate the difference in inequality between 2010 and 2019
joined_data <- joined_data %>%
  mutate(diff_inequality = GII_2019 - GII_2010)

# Save the modified data
st_write(joined_data, "~/GIS/Week_4/Shapefile/joined_data.geojson")

# Verify if the join columns are populated correctly
head(joined_data)
# In your R session
installed.packages <- rownames(installed.packages())
writeLines(installed.packages, con = "installed_packages.txt")

