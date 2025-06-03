# R Script to Merge Testing Data with COVID-GDP Dataset
# Merges "Cumulative total per 1,000 people" from test_per_population.csv
# with covid_gdp_merged_improved.csv, handling country name differences

# Load required libraries
library(dplyr)
library(readr)

# Read the datasets
print("Reading existing COVID-GDP merged data...")
covid_gdp_data <- read_csv("covid_gdp_merged_improved.csv")

print("Reading testing data...")
testing_data <- read_csv("test_per_population.csv")

# Clean and prepare testing data
print("Preparing testing data...")
testing_clean <- testing_data %>%
  select(Entity, `Cumulative total per 1,000 people`) %>%
  rename(
    Country = Entity,
    Tests_per_1000_people = `Cumulative total per 1,000 people`
  ) %>%
  # Remove rows with missing data
  filter(!is.na(Tests_per_1000_people) & Tests_per_1000_people != "")

print(paste("Testing data countries:", nrow(testing_clean)))

# Create a mapping for country name differences between testing data and COVID-GDP data
print("Creating country name mapping...")
country_mapping <- data.frame(
  testing_name = c(
    "United States",
    "South Korea", 
    "Czechia",
    "Cote d'Ivoire",
    "Democratic Republic of Congo",
    "United States Virgin Islands",
    "Puerto Rico",
    "Guam",
    "Taiwan",
    "Kosovo",
    "Palestine",
    "West Bank and Gaza",
    "Brunei",
    "Laos",
    "Tanzania",
    "Micronesia",
    "Saint Vincent and the Grenadines",
    "Trinidad and Tobago",
    "Saint Kitts and Nevis",
    "Saint Lucia",
    "Antigua and Barbuda",
    "Bosnia and Herzegovina",
    "North Macedonia",
    "Moldova",
    "Cabo Verde",
    "Sao Tome and Principe",
    "Gambia",
    "Guinea-Bissau",
    "Bahamas",
    "Turks and Caicos Islands",
    "British Virgin Islands",
    "Cayman Islands",
    "Sint Maarten (Dutch part)",
    "Saint Martin (French part)",
    "Bonaire, Saint Eustatius and Saba",
    "Curacao",
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
    "Tonga"
  ),
  covid_gdp_name = c(
    "United States of America",
    "Republic of Korea",
    "Czechia",
    "C\u00f4te d'Ivoire",
    "Democratic Republic of the Congo",
    "United States Virgin Islands",
    "Puerto Rico",
    "Guam",
    "Taiwan",
    "Kosovo (in accordance with UN Security Council resolution 1244 (1999))",
    "occupied Palestinian territory, including east Jerusalem",
    "occupied Palestinian territory, including east Jerusalem",
    "Brunei Darussalam",
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
    "Cayman Islands",
    "Sint Maarten (Dutch part)",
    "Saint Martin (French part)",
    "Bonaire, Saint Eustatius and Saba",
    "Cura\u00e7ao",
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
    "Tonga"
  ),
  stringsAsFactors = FALSE
)

# Apply country name mapping to testing data
print("Applying country name mapping...")
testing_mapped <- testing_clean %>%
  left_join(country_mapping, by = c("Country" = "testing_name")) %>%
  mutate(Country_for_merge = ifelse(is.na(covid_gdp_name), Country, covid_gdp_name)) %>%
  select(-covid_gdp_name)

# Perform the merge
print("Merging datasets...")
merged_data <- covid_gdp_data %>%
  left_join(testing_mapped %>% select(Country_for_merge, Tests_per_1000_people), 
            by = c("Country" = "Country_for_merge"))

# Check merge results
print("Merge summary:")
print(paste("Total COVID-GDP records:", nrow(covid_gdp_data)))
print(paste("Records with testing data:", sum(!is.na(merged_data$Tests_per_1000_people))))
print(paste("Records without testing data:", sum(is.na(merged_data$Tests_per_1000_people))))

# Show countries without testing data matches
countries_without_testing <- merged_data %>%
  filter(is.na(Tests_per_1000_people)) %>%
  select(Country) %>%
  distinct() %>%
  arrange(Country)

print("Countries without testing data matches:")
print(countries_without_testing)

# Show countries with testing data matches
countries_with_testing <- merged_data %>%
  filter(!is.na(Tests_per_1000_people)) %>%
  select(Country, Tests_per_1000_people) %>%
  arrange(desc(Tests_per_1000_people)) %>%
  head(10)

print("Top 10 countries by testing rate (tests per 1000 people):")
print(countries_with_testing)

# Clean up the final dataset
final_data <- merged_data %>%
  # Reorder columns to put testing data after GDP data
  relocate(Tests_per_1000_people, .after = GDP_per_capita_2022)

# Save the merged dataset
print("Saving merged dataset...")
write_csv(final_data, "covid_gdp_testing_merged.csv")

print("Merge completed successfully!")
print(paste("Final dataset saved as 'covid_gdp_testing_merged.csv' with", nrow(final_data), "records"))

# Display first few rows of the merged data
print("First 5 rows of merged data (selected columns):")
preview_data <- final_data %>%
  select(Country, `WHO Region`, GDP_per_capita_2022, Tests_per_1000_people, 
         `Cases - cumulative total per 100000 population`,
         `Deaths - cumulative total per 100000 population`) %>%
  head(5)
print(preview_data)

# Summary statistics for testing data
print("Summary of testing data in merged dataset:")
testing_stats <- final_data %>%
  filter(!is.na(Tests_per_1000_people)) %>%
  summarise(
    Countries = n(),
    Mean_Tests_per_1000 = round(mean(Tests_per_1000_people), 1),
    Median_Tests_per_1000 = round(median(Tests_per_1000_people), 1),
    Min_Tests_per_1000 = round(min(Tests_per_1000_people), 1),
    Max_Tests_per_1000 = round(max(Tests_per_1000_people), 1),
    Std_Dev = round(sd(Tests_per_1000_people), 1)
  )
print(testing_stats)

# Regional analysis of testing rates
print("Testing rates by WHO Region:")
regional_testing <- final_data %>%
  filter(!is.na(Tests_per_1000_people) & !is.na(`WHO Region`)) %>%
  group_by(`WHO Region`) %>%
  summarise(
    Countries = n(),
    Avg_Tests_per_1000 = round(mean(Tests_per_1000_people), 1),
    Median_Tests_per_1000 = round(median(Tests_per_1000_people), 1),
    .groups = 'drop'
  ) %>%
  arrange(desc(Avg_Tests_per_1000))

print(regional_testing)

# Countries with highest and lowest testing rates
print("Top 10 countries by testing rate:")
top_testing <- final_data %>%
  filter(!is.na(Tests_per_1000_people)) %>%
  arrange(desc(Tests_per_1000_people)) %>%
  select(Country, `WHO Region`, Tests_per_1000_people, GDP_per_capita_2022,
         `Cases - cumulative total per 100000 population`,
         `Deaths - cumulative total per 100000 population`) %>%
  head(10)
print(top_testing)

print("Bottom 10 countries by testing rate:")
bottom_testing <- final_data %>%
  filter(!is.na(Tests_per_1000_people)) %>%
  arrange(Tests_per_1000_people) %>%
  select(Country, `WHO Region`, Tests_per_1000_people, GDP_per_capita_2022,
         `Cases - cumulative total per 100000 population`,
         `Deaths - cumulative total per 100000 population`) %>%
  head(10)
print(bottom_testing)

# Correlation analysis
print("Correlation analysis:")
correlation_data <- final_data %>%
  filter(!is.na(Tests_per_1000_people) & 
         !is.na(GDP_per_capita_2022) & 
         !is.na(`Cases - cumulative total per 100000 population`) & 
         !is.na(`Deaths - cumulative total per 100000 population`))

if(nrow(correlation_data) > 0) {
  testing_gdp_cor <- cor(correlation_data$Tests_per_1000_people, 
                         correlation_data$GDP_per_capita_2022, 
                         use = "complete.obs")
  testing_cases_cor <- cor(correlation_data$Tests_per_1000_people, 
                           correlation_data$`Cases - cumulative total per 100000 population`, 
                           use = "complete.obs")
  testing_deaths_cor <- cor(correlation_data$Tests_per_1000_people, 
                            correlation_data$`Deaths - cumulative total per 100000 population`, 
                            use = "complete.obs")
  
  print(paste("Correlation between testing rate and GDP per capita:", round(testing_gdp_cor, 3)))
  print(paste("Correlation between testing rate and COVID cases per 100k:", round(testing_cases_cor, 3)))
  print(paste("Correlation between testing rate and COVID deaths per 100k:", round(testing_deaths_cor, 3)))
}

print("Analysis completed!")
