# Analysis of Merged COVID and GDP Data
# This script provides insights into the relationship between GDP and COVID outcomes

library(dplyr)
library(readr)
library(ggplot2)

# Read the merged data
print("Reading merged COVID-GDP data...")
merged_data <- read_csv("covid_gdp_merged_improved.csv")

# Basic statistics
print("=== BASIC STATISTICS ===")
print(paste("Total countries in dataset:", nrow(merged_data)))
print(paste("Countries with GDP data:", sum(!is.na(merged_data$GDP_per_capita_2022))))
print(paste("Countries without GDP data:", sum(is.na(merged_data$GDP_per_capita_2022))))

# GDP statistics
print("\n=== GDP PER CAPITA 2022 STATISTICS ===")
gdp_stats <- merged_data %>%
  filter(!is.na(GDP_per_capita_2022)) %>%
  summarise(
    Count = n(),
    Mean = round(mean(GDP_per_capita_2022), 2),
    Median = round(median(GDP_per_capita_2022), 2),
    Min = round(min(GDP_per_capita_2022), 2),
    Max = round(max(GDP_per_capita_2022), 2),
    Std_Dev = round(sd(GDP_per_capita_2022), 2)
  )
print(gdp_stats)

# COVID statistics by GDP quartiles
print("\n=== COVID OUTCOMES BY GDP QUARTILES ===")
covid_gdp_analysis <- merged_data %>%
  filter(!is.na(GDP_per_capita_2022) & 
         !is.na(`Cases - cumulative total`) & 
         !is.na(`Deaths - cumulative total`)) %>%
  mutate(
    GDP_quartile = ntile(GDP_per_capita_2022, 4),
    Cases_per_100k = `Cases - cumulative total per 100000 population`,
    Deaths_per_100k = `Deaths - cumulative total per 100000 population`
  ) %>%
  group_by(GDP_quartile) %>%
  summarise(
    Countries = n(),
    Avg_GDP = round(mean(GDP_per_capita_2022), 2),
    Avg_Cases_per_100k = round(mean(Cases_per_100k, na.rm = TRUE), 2),
    Avg_Deaths_per_100k = round(mean(Deaths_per_100k, na.rm = TRUE), 2),
    .groups = 'drop'
  ) %>%
  mutate(
    GDP_quartile_label = case_when(
      GDP_quartile == 1 ~ "Q1 (Lowest GDP)",
      GDP_quartile == 2 ~ "Q2 (Low-Mid GDP)",
      GDP_quartile == 3 ~ "Q3 (Mid-High GDP)",
      GDP_quartile == 4 ~ "Q4 (Highest GDP)"
    )
  )

print(covid_gdp_analysis)

# Regional analysis
print("\n=== COVID OUTCOMES BY WHO REGION ===")
regional_analysis <- merged_data %>%
  filter(!is.na(GDP_per_capita_2022) & 
         !is.na(`WHO Region`) &
         !is.na(`Cases - cumulative total`) & 
         !is.na(`Deaths - cumulative total`)) %>%
  group_by(`WHO Region`) %>%
  summarise(
    Countries = n(),
    Avg_GDP = round(mean(GDP_per_capita_2022), 2),
    Avg_Cases_per_100k = round(mean(`Cases - cumulative total per 100000 population`, na.rm = TRUE), 2),
    Avg_Deaths_per_100k = round(mean(`Deaths - cumulative total per 100000 population`, na.rm = TRUE), 2),
    .groups = 'drop'
  ) %>%
  arrange(desc(Avg_GDP))

print(regional_analysis)

# Countries with extreme values
print("\n=== COUNTRIES WITH EXTREME VALUES ===")

print("Top 5 countries by GDP per capita:")
top_gdp <- merged_data %>%
  filter(!is.na(GDP_per_capita_2022)) %>%
  arrange(desc(GDP_per_capita_2022)) %>%
  select(Country, `WHO Region`, GDP_per_capita_2022, 
         `Cases - cumulative total per 100000 population`,
         `Deaths - cumulative total per 100000 population`) %>%
  head(5)
print(top_gdp)

print("\nBottom 5 countries by GDP per capita:")
bottom_gdp <- merged_data %>%
  filter(!is.na(GDP_per_capita_2022)) %>%
  arrange(GDP_per_capita_2022) %>%
  select(Country, `WHO Region`, GDP_per_capita_2022, 
         `Cases - cumulative total per 100000 population`,
         `Deaths - cumulative total per 100000 population`) %>%
  head(5)
print(bottom_gdp)

print("\nTop 5 countries by COVID cases per 100k population:")
top_cases <- merged_data %>%
  filter(!is.na(`Cases - cumulative total per 100000 population`)) %>%
  arrange(desc(`Cases - cumulative total per 100000 population`)) %>%
  select(Country, `WHO Region`, GDP_per_capita_2022, 
         `Cases - cumulative total per 100000 population`,
         `Deaths - cumulative total per 100000 population`) %>%
  head(5)
print(top_cases)

print("\nTop 5 countries by COVID deaths per 100k population:")
top_deaths <- merged_data %>%
  filter(!is.na(`Deaths - cumulative total per 100000 population`)) %>%
  arrange(desc(`Deaths - cumulative total per 100000 population`)) %>%
  select(Country, `WHO Region`, GDP_per_capita_2022, 
         `Cases - cumulative total per 100000 population`,
         `Deaths - cumulative total per 100000 population`) %>%
  head(5)
print(top_deaths)

# Correlation analysis
print("\n=== CORRELATION ANALYSIS ===")
correlation_data <- merged_data %>%
  filter(!is.na(GDP_per_capita_2022) & 
         !is.na(`Cases - cumulative total per 100000 population`) & 
         !is.na(`Deaths - cumulative total per 100000 population`))

if(nrow(correlation_data) > 0) {
  gdp_cases_cor <- cor(correlation_data$GDP_per_capita_2022, 
                       correlation_data$`Cases - cumulative total per 100000 population`, 
                       use = "complete.obs")
  gdp_deaths_cor <- cor(correlation_data$GDP_per_capita_2022, 
                        correlation_data$`Deaths - cumulative total per 100000 population`, 
                        use = "complete.obs")
  
  print(paste("Correlation between GDP per capita and COVID cases per 100k:", round(gdp_cases_cor, 3)))
  print(paste("Correlation between GDP per capita and COVID deaths per 100k:", round(gdp_deaths_cor, 3)))
}

# Save summary statistics
print("\n=== SAVING ANALYSIS RESULTS ===")
write_csv(covid_gdp_analysis, "covid_gdp_quartile_analysis.csv")
write_csv(regional_analysis, "covid_gdp_regional_analysis.csv")

print("Analysis completed!")
print("Results saved to:")
print("- covid_gdp_quartile_analysis.csv")
print("- covid_gdp_regional_analysis.csv")
