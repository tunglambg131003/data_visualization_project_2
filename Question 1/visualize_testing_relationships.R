# R Code to Visualize Testing Relationships
# 1. Testing rates vs GDP
# 2. Testing rates vs COVID cases per 100k
# 3. COVID cases per test vs GDP

# Load required libraries
library(ggplot2)
library(dplyr)
library(readr)
library(scales)
library(gridExtra)

# Read the merged data
print("Reading merged COVID-GDP-Testing data...")
data <- read_csv("covid_gdp_testing_merged.csv")

# Prepare data for visualization
plot_data <- data %>%
  filter(!is.na(GDP_per_capita_2022) &
         !is.na(Tests_per_1000_people) &
         !is.na(`Cases - cumulative total per 100000 population`) &
         Tests_per_1000_people > 0 &  # Avoid division by zero
         `Cases - cumulative total per 100000 population` > 0) %>%  # Avoid zero cases
  # Calculate cases per test
  mutate(
    Cases_per_test = (`Cases - cumulative total per 100000 population` / 100) / (Tests_per_1000_people / 1000),
    Cases_per_1000_tests = Cases_per_test * 1000
  )

print(paste("Number of countries in visualization:", nrow(plot_data)))

# 1. TESTING RATES vs GDP
print("Creating Testing Rates vs GDP visualization...")
p1 <- ggplot(plot_data, aes(x = GDP_per_capita_2022, y = Tests_per_1000_people)) +
  geom_point(aes(color = `WHO Region`), alpha = 0.7, size = 3) +
  geom_smooth(method = "lm", se = TRUE, color = "red", linetype = "dashed") +
  scale_x_continuous(labels = scales::dollar_format(prefix = "$", suffix = "K", scale = 0.001)) +
  scale_y_continuous(labels = scales::comma_format()) +
  labs(
    title = "Testing Rates vs GDP per Capita",
    subtitle = "Higher GDP countries generally conducted more tests per capita",
    x = "GDP per Capita 2022 (USD)",
    y = "Tests per 1,000 People",
    color = "WHO Region",
    caption = "Data sources: WHO COVID data, World Bank GDP data, Our World in Data testing data"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 12),
    axis.title = element_text(size = 11),
    legend.position = "bottom",
    legend.title = element_text(size = 10),
    panel.grid.minor = element_blank()
  )

print(p1)
ggsave("testing_rates_vs_gdp.png", plot = p1, width = 12, height = 8, dpi = 300)

# 2. TESTING RATES vs COVID CASES per 100k
print("Creating Testing Rates vs COVID Cases visualization...")
p2 <- ggplot(plot_data, aes(x = Tests_per_1000_people, y = `Cases - cumulative total per 100000 population`)) +
  geom_point(aes(color = `WHO Region`), alpha = 0.7, size = 3) +
  geom_smooth(method = "lm", se = TRUE, color = "red", linetype = "dashed") +
  scale_x_continuous(labels = scales::comma_format()) +
  scale_y_continuous(labels = scales::comma_format()) +
  labs(
    title = "Testing Rates vs COVID Cases per 100k Population",
    subtitle = "More testing generally leads to higher reported case rates",
    x = "Tests per 1,000 People",
    y = "COVID Cases per 100,000 Population",
    color = "WHO Region",
    caption = "Data sources: WHO COVID data and Our World in Data testing data"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 12),
    axis.title = element_text(size = 11),
    legend.position = "bottom",
    legend.title = element_text(size = 10),
    panel.grid.minor = element_blank()
  )

print(p2)
ggsave("testing_rates_vs_cases.png", plot = p2, width = 12, height = 8, dpi = 300)

# 3. COVID CASES per TEST vs GDP
print("Creating Cases per Test vs GDP visualization...")
p3 <- ggplot(plot_data, aes(x = GDP_per_capita_2022, y = Cases_per_1000_tests)) +
  geom_point(aes(color = `WHO Region`), alpha = 0.7, size = 3) +
  geom_smooth(method = "lm", se = TRUE, color = "red", linetype = "dashed") +
  scale_x_continuous(labels = scales::dollar_format(prefix = "$", suffix = "K", scale = 0.001)) +
  scale_y_continuous(labels = scales::comma_format()) +
  labs(
    title = "COVID Cases per 1,000 Tests vs GDP per Capita",
    subtitle = "Testing efficiency: Lower values indicate more comprehensive testing",
    x = "GDP per Capita 2022 (USD)",
    y = "COVID Cases per 1,000 Tests",
    color = "WHO Region",
    caption = "Data sources: WHO COVID data, World Bank GDP data, Our World in Data testing data"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 12),
    axis.title = element_text(size = 11),
    legend.position = "bottom",
    legend.title = element_text(size = 10),
    panel.grid.minor = element_blank()
  )

print(p3)
ggsave("cases_per_test_vs_gdp.png", plot = p3, width = 12, height = 8, dpi = 300)

# 4. LOG SCALE VERSION of Testing vs GDP for better visualization
print("Creating log-scale version of Testing vs GDP...")
p4 <- ggplot(plot_data, aes(x = GDP_per_capita_2022, y = Tests_per_1000_people)) +
  geom_point(aes(color = `WHO Region`), alpha = 0.7, size = 3) +
  geom_smooth(method = "lm", se = TRUE, color = "red", linetype = "dashed") +
  scale_x_log10(labels = scales::dollar_format(prefix = "$", suffix = "K", scale = 0.001)) +
  scale_y_log10(labels = scales::comma_format()) +
  labs(
    title = "Testing Rates vs GDP per Capita (Log Scale)",
    subtitle = "Both axes on logarithmic scale for better visualization",
    x = "GDP per Capita 2022 (USD, Log Scale)",
    y = "Tests per 1,000 People (Log Scale)",
    color = "WHO Region",
    caption = "Data sources: WHO COVID data, World Bank GDP data, Our World in Data testing data"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 12),
    axis.title = element_text(size = 11),
    legend.position = "bottom",
    legend.title = element_text(size = 10),
    panel.grid.minor = element_blank()
  )

print(p4)
ggsave("testing_rates_vs_gdp_log.png", plot = p4, width = 12, height = 8, dpi = 300)

# 5. COMBINED PLOT - All three relationships in one figure
print("Creating combined visualization...")
p_combined <- grid.arrange(p1, p2, p3, ncol = 2, nrow = 2)
ggsave("testing_relationships_combined.png", plot = p_combined, width = 16, height = 12, dpi = 300)

# Calculate and display correlations
print("=== CORRELATION ANALYSIS ===")
cor_testing_gdp <- cor(plot_data$Tests_per_1000_people, plot_data$GDP_per_capita_2022, use = "complete.obs")
cor_testing_cases <- cor(plot_data$Tests_per_1000_people, plot_data$`Cases - cumulative total per 100000 population`, use = "complete.obs")
cor_cases_per_test_gdp <- cor(plot_data$Cases_per_1000_tests, plot_data$GDP_per_capita_2022, use = "complete.obs")

print(paste("Correlation - Testing rates vs GDP per capita:", round(cor_testing_gdp, 3)))
print(paste("Correlation - Testing rates vs COVID cases per 100k:", round(cor_testing_cases, 3)))
print(paste("Correlation - Cases per 1000 tests vs GDP per capita:", round(cor_cases_per_test_gdp, 3)))

# Summary statistics
print("\n=== SUMMARY STATISTICS ===")
summary_stats <- plot_data %>%
  summarise(
    Countries = n(),
    Mean_Tests_per_1000 = round(mean(Tests_per_1000_people), 1),
    Median_Tests_per_1000 = round(median(Tests_per_1000_people), 1),
    Mean_Cases_per_1000_tests = round(mean(Cases_per_1000_tests), 1),
    Median_Cases_per_1000_tests = round(median(Cases_per_1000_tests), 1),
    Mean_GDP = round(mean(GDP_per_capita_2022), 0)
  )
print(summary_stats)

# Top and bottom performers
print("\n=== TOP 10 COUNTRIES BY TESTING EFFICIENCY (Lowest cases per 1000 tests) ===")
top_efficiency <- plot_data %>%
  arrange(Cases_per_1000_tests) %>%
  select(Country, `WHO Region`, GDP_per_capita_2022, Tests_per_1000_people, 
         `Cases - cumulative total per 100000 population`, Cases_per_1000_tests) %>%
  head(10)
print(top_efficiency)

print("\n=== BOTTOM 10 COUNTRIES BY TESTING EFFICIENCY (Highest cases per 1000 tests) ===")
bottom_efficiency <- plot_data %>%
  arrange(desc(Cases_per_1000_tests)) %>%
  select(Country, `WHO Region`, GDP_per_capita_2022, Tests_per_1000_people, 
         `Cases - cumulative total per 100000 population`, Cases_per_1000_tests) %>%
  head(10)
print(bottom_efficiency)

# Regional analysis
print("\n=== REGIONAL ANALYSIS ===")
regional_analysis <- plot_data %>%
  group_by(`WHO Region`) %>%
  summarise(
    Countries = n(),
    Avg_Tests_per_1000 = round(mean(Tests_per_1000_people), 1),
    Avg_Cases_per_100k = round(mean(`Cases - cumulative total per 100000 population`), 0),
    Avg_Cases_per_1000_tests = round(mean(Cases_per_1000_tests), 1),
    Avg_GDP = round(mean(GDP_per_capita_2022), 0),
    .groups = 'drop'
  ) %>%
  arrange(desc(Avg_GDP))

print(regional_analysis)

# Create a scatter plot with country labels for extreme cases
extreme_countries <- plot_data %>%
  filter(
    (Cases_per_1000_tests > 500) |  # Very high cases per test
    (Cases_per_1000_tests < 20) |   # Very low cases per test
    (Tests_per_1000_people > 15000) |  # Very high testing
    (GDP_per_capita_2022 > 80000)   # Very high GDP
  )

p5 <- ggplot(plot_data, aes(x = GDP_per_capita_2022, y = Cases_per_1000_tests)) +
  geom_point(aes(color = `WHO Region`), alpha = 0.6, size = 2.5) +
  geom_smooth(method = "lm", se = TRUE, color = "red", linetype = "dashed", alpha = 0.3) +
  geom_text(data = extreme_countries, 
            aes(label = Country), 
            size = 3, 
            hjust = 0, 
            vjust = 0, 
            nudge_x = 2000, 
            nudge_y = 10,
            check_overlap = TRUE) +
  scale_x_continuous(labels = scales::dollar_format(prefix = "$", suffix = "K", scale = 0.001)) +
  scale_y_continuous(labels = scales::comma_format()) +
  labs(
    title = "Testing Efficiency vs GDP with Country Labels",
    subtitle = "Countries with extreme testing efficiency values are labeled",
    x = "GDP per Capita 2022 (USD)",
    y = "COVID Cases per 1,000 Tests",
    color = "WHO Region",
    caption = "Lower values indicate more comprehensive testing strategies"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 12),
    axis.title = element_text(size = 11),
    legend.position = "bottom",
    legend.title = element_text(size = 10),
    panel.grid.minor = element_blank()
  )

print(p5)
ggsave("testing_efficiency_labeled.png", plot = p5, width = 14, height = 10, dpi = 300)

print("Visualization completed!")
print("Generated plots:")
print("1. testing_rates_vs_gdp.png - Testing rates vs GDP")
print("2. testing_rates_vs_cases.png - Testing rates vs COVID cases")
print("3. cases_per_test_vs_gdp.png - Cases per test vs GDP")
print("4. testing_rates_vs_gdp_log.png - Log scale version")
print("5. testing_efficiency_labeled.png - With country labels")
print("6. testing_relationships_combined.png - Combined view")
