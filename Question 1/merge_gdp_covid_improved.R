# R Script to Merge GDP 2022 Data with COVID Data
# Improved version with better country name handling

# Load required libraries
library(dplyr)
library(readr)

# Read the datasets
print("Reading GDP data...")
gdp_data <- read_csv("GDP.csv", skip = 4)  # Skip the first 4 rows (metadata)

print("Reading COVID data...")
covid_data <- read_csv("covid_case.csv")

# Clean and prepare GDP data
print("Preparing GDP data...")
# Select only Country Name and 2022 GDP data
gdp_2022 <- gdp_data %>%
  select(`Country Name`, `2022`) %>%
  rename(
    Country = `Country Name`,
    GDP_per_capita_2022 = `2022`
  ) %>%
  # Remove rows with missing GDP data
  filter(!is.na(GDP_per_capita_2022) & GDP_per_capita_2022 != "") %>%
  # Convert GDP to numeric (it might be character due to CSV format)
  mutate(GDP_per_capita_2022 = as.numeric(GDP_per_capita_2022))

# Clean COVID data
print("Preparing COVID data...")
covid_clean <- covid_data %>%
  rename(Country = Name) %>%
  # Remove rows with missing country names or special entries
  filter(!is.na(Country) & 
         Country != "" & 
         !grepl("^International", Country) &
         !grepl("^Global$", Country))

# Create a comprehensive mapping for country name differences
print("Creating country name mapping...")
country_mapping <- data.frame(
  covid_name = c(
    "United States of America",
    "United Kingdom of Great Britain and Northern Ireland", 
    "Russian Federation",
    "Republic of Korea",
    "Iran (Islamic Republic of)",
    "Democratic Republic of the Congo",
    "Congo",
    "Cote d'Ivoire",
    "C\u00f4te d'Ivoire",  # Handle encoding issue
    "Korea, Dem. People's Rep.",
    "Democratic People's Republic of Korea",
    "Venezuela (Bolivarian Republic of)",
    "Bolivia (Plurinational State of)",
    "occupied Palestinian territory, including east Jerusalem",
    "Brunei Darussalam",
    "Syrian Arab Republic",
    "Lao People's Democratic Republic",
    "United Republic of Tanzania",
    "Micronesia (Federated States of)",
    "Saint Vincent and the Grenadines",
    "Trinidad and Tobago",
    "Saint Kitts and Nevis",
    "Saint Lucia",
    "Antigua and Barbuda",
    "Bosnia and Herzegovina",
    "North Macedonia",
    "Republic of Moldova",
    "Cabo Verde",
    "Sao Tome and Principe",
    "Gambia",
    "Guinea-Bissau",
    "Bahamas",
    "Turks and Caicos Islands",
    "British Virgin Islands",
    "United States Virgin Islands",
    "Cayman Islands",
    "Sint Maarten (Dutch part)",
    "Saint Martin (French part)",
    "Bonaire, Saint Eustatius and Saba",
    "Curacao",
    "Cura\u00e7ao",  # Handle encoding issue
    "Faroe Islands",
    "Falkland Islands (Malvinas)",
    "Saint Helena",
    "Saint Pierre and Miquelon",
    "Wallis and Futuna",
    "American Samoa",
    "Northern Mariana Islands",
    "Marshall Islands",
    "Palau",
    "Cook Islands",
    "French Polynesia",
    "New Caledonia",
    "Pitcairn",
    "Tokelau",
    "Tuvalu",
    "Niue",
    "Nauru",
    "Kiribati",
    "Solomon Islands",
    "Vanuatu",
    "Fiji",
    "Samoa",
    "Tonga",
    "Egypt",
    "Eritrea",
    "Cuba",
    "T\u00fcrkiye",  # Handle encoding issue
    "Netherlands (Kingdom of the)",
    "Slovakia",
    "South Sudan",
    "Yemen",
    "Kyrgyzstan",
    "Kosovo (in accordance with UN Security Council resolution 1244 (1999))"
  ),
  gdp_name = c(
    "United States",
    "United Kingdom", 
    "Russian Federation",
    "Korea, Rep.",
    "Iran, Islamic Rep.",
    "Congo, Dem. Rep.",
    "Congo, Rep.",
    "Cote d'Ivoire",
    "Cote d'Ivoire",  # Handle encoding issue
    "Korea, Dem. People's Rep.",
    "Korea, Dem. People's Rep.",
    "Venezuela, RB",
    "Bolivia",
    "West Bank and Gaza",
    "Brunei Darussalam",
    "Syrian Arab Republic",
    "Lao PDR",
    "Tanzania",
    "Micronesia, Fed. Sts.",
    "St. Vincent and the Grenadines",
    "Trinidad and Tobago",
    "St. Kitts and Nevis",
    "St. Lucia",
    "Antigua and Barbuda",
    "Bosnia and Herzegovina",
    "North Macedonia",
    "Moldova",
    "Cabo Verde",
    "Sao Tome and Principe",
    "Gambia, The",
    "Guinea-Bissau",
    "Bahamas, The",
    "Turks and Caicos Islands",
    "British Virgin Islands",
    "Virgin Islands (U.S.)",
    "Cayman Islands",
    "Sint Maarten (Dutch part)",
    "St. Martin (French part)",
    "Bonaire, Saint Eustatius and Saba",
    "Curacao",
    "Curacao",  # Handle encoding issue
    "Faroe Islands",
    "Falkland Islands (Malvinas)",
    "St. Helena",
    "St. Pierre and Miquelon",
    "Wallis and Futuna",
    "American Samoa",
    "Northern Mariana Islands",
    "Marshall Islands",
    "Palau",
    "Cook Islands",
    "French Polynesia",
    "New Caledonia",
    "Pitcairn",
    "Tokelau",
    "Tuvalu",
    "Niue",
    "Nauru",
    "Kiribati",
    "Solomon Islands",
    "Vanuatu",
    "Fiji",
    "Samoa",
    "Tonga",
    "Egypt, Arab Rep.",
    "Eritrea",
    "Cuba",
    "Turkiye",  # Handle encoding issue
    "Netherlands",
    "Slovak Republic",
    "South Sudan",
    "Yemen, Rep.",
    "Kyrgyz Republic",
    "Kosovo"
  ),
  stringsAsFactors = FALSE
)

# Apply country name mapping to COVID data
print("Applying country name mapping...")
covid_mapped <- covid_clean %>%
  left_join(country_mapping, by = c("Country" = "covid_name")) %>%
  mutate(Country_for_merge = ifelse(is.na(gdp_name), Country, gdp_name)) %>%
  select(-gdp_name)

# Perform the merge
print("Merging datasets...")
merged_data <- covid_mapped %>%
  left_join(gdp_2022, by = c("Country_for_merge" = "Country"))

# Check merge results
print("Merge summary:")
print(paste("Total COVID records:", nrow(covid_mapped)))
print(paste("Records with GDP data:", sum(!is.na(merged_data$GDP_per_capita_2022))))
print(paste("Records without GDP data:", sum(is.na(merged_data$GDP_per_capita_2022))))

# Show countries without GDP matches
countries_without_gdp <- merged_data %>%
  filter(is.na(GDP_per_capita_2022)) %>%
  select(Country, Country_for_merge) %>%
  distinct() %>%
  arrange(Country)

print("Countries without GDP matches:")
print(countries_without_gdp)

# Clean up the final dataset
final_data <- merged_data %>%
  select(-Country_for_merge) %>%
  # Reorder columns to put GDP data after country info
  relocate(GDP_per_capita_2022, .after = `WHO Region`)

# Save the merged dataset
print("Saving merged dataset...")
write_csv(final_data, "covid_gdp_merged_improved.csv")

print("Merge completed successfully!")
print(paste("Final dataset saved as 'covid_gdp_merged_improved.csv' with", nrow(final_data), "records"))

# Display first few rows of the merged data
print("First 10 rows of merged data:")
print(head(final_data, 10))

# Summary statistics
print("Summary of GDP per capita 2022 in merged dataset:")
print(summary(final_data$GDP_per_capita_2022))

# Additional analysis: Countries with highest and lowest GDP per capita
print("\nTop 10 countries by GDP per capita 2022:")
top_gdp <- final_data %>%
  filter(!is.na(GDP_per_capita_2022)) %>%
  arrange(desc(GDP_per_capita_2022)) %>%
  select(Country, `WHO Region`, GDP_per_capita_2022, `Cases - cumulative total`, `Deaths - cumulative total`) %>%
  head(10)
print(top_gdp)

print("\nBottom 10 countries by GDP per capita 2022:")
bottom_gdp <- final_data %>%
  filter(!is.na(GDP_per_capita_2022)) %>%
  arrange(GDP_per_capita_2022) %>%
  select(Country, `WHO Region`, GDP_per_capita_2022, `Cases - cumulative total`, `Deaths - cumulative total`) %>%
  head(10)
print(bottom_gdp)
