# R Code to Visualize Relationship between GDP and COVID Death Rate
# X-axis: Deaths - cumulative total per 100000 population
# Y-axis: GDP per capita 2022

# Load required libraries
library(ggplot2)
library(dplyr)
library(readr)
library(scales)

# Read the merged data
print("Reading merged COVID-GDP data...")
data <- read_csv("covid_gdp_merged_improved.csv")

# Prepare data for visualization
plot_data <- data %>%
  filter(!is.na(GDP_per_capita_2022) & 
         !is.na(`Deaths - cumulative total per 100000 population`)) %>%
  # Remove extreme outliers for better visualization
  filter(`Deaths - cumulative total per 100000 population` < 2000 &
         GDP_per_capita_2022 < 150000)

print(paste("Number of countries in visualization:", nrow(plot_data)))

# Create the main scatter plot
p1 <- ggplot(plot_data, aes(x = `Deaths - cumulative total per 100000 population`, 
                           y = GDP_per_capita_2022)) +
  geom_point(aes(color = `WHO Region`), alpha = 0.7, size = 3) +
  geom_smooth(method = "lm", se = TRUE, color = "red", linetype = "dashed") +
  scale_y_continuous(labels = scales::dollar_format(prefix = "$", suffix = "K", scale = 0.001)) +
  labs(
    title = "Relationship between COVID Death Rate and GDP per Capita (2022)",
    subtitle = "Each point represents a country",
    x = "COVID Deaths per 100,000 Population",
    y = "GDP per Capita 2022 (USD)",
    color = "WHO Region",
    caption = "Data sources: WHO COVID data and World Bank GDP data"
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

# Display the plot
print(p1)

# Save the plot
ggsave("gdp_vs_death_rate.png", plot = p1, width = 12, height = 8, dpi = 300)

# Create a log-scale version for better visualization of the relationship
p2 <- ggplot(plot_data, aes(x = `Deaths - cumulative total per 100000 population`, 
                           y = GDP_per_capita_2022)) +
  geom_point(aes(color = `WHO Region`), alpha = 0.7, size = 3) +
  geom_smooth(method = "lm", se = TRUE, color = "red", linetype = "dashed") +
  scale_y_log10(labels = scales::dollar_format(prefix = "$", suffix = "K", scale = 0.001)) +
  labs(
    title = "Relationship between COVID Death Rate and GDP per Capita (Log Scale)",
    subtitle = "Y-axis on logarithmic scale for better visualization",
    x = "COVID Deaths per 100,000 Population",
    y = "GDP per Capita 2022 (USD, Log Scale)",
    color = "WHO Region",
    caption = "Data sources: WHO COVID data and World Bank GDP data"
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

# Display the log-scale plot
print(p2)

# Save the log-scale plot
ggsave("gdp_vs_death_rate_log.png", plot = p2, width = 12, height = 8, dpi = 300)

# Create a plot with country labels for interesting cases
# Identify countries with extreme values
extreme_countries <- plot_data %>%
  filter(
    (`Deaths - cumulative total per 100000 population` > 400 & GDP_per_capita_2022 > 30000) |
    (`Deaths - cumulative total per 100000 population` > 500) |
    (GDP_per_capita_2022 > 80000) |
    (`Deaths - cumulative total per 100000 population` < 50 & GDP_per_capita_2022 > 50000)
  )

p3 <- ggplot(plot_data, aes(x = `Deaths - cumulative total per 100000 population`, 
                           y = GDP_per_capita_2022)) +
  geom_point(aes(color = `WHO Region`), alpha = 0.6, size = 2.5) +
  geom_smooth(method = "lm", se = TRUE, color = "red", linetype = "dashed", alpha = 0.3) +
  geom_text(data = extreme_countries, 
            aes(label = Country), 
            size = 3, 
            hjust = 0, 
            vjust = 0, 
            nudge_x = 5, 
            nudge_y = 1000,
            check_overlap = TRUE) +
  scale_y_continuous(labels = scales::dollar_format(prefix = "$", suffix = "K", scale = 0.001)) +
  labs(
    title = "GDP vs COVID Death Rate with Country Labels",
    subtitle = "Selected countries with extreme values are labeled",
    x = "COVID Deaths per 100,000 Population",
    y = "GDP per Capita 2022 (USD)",
    color = "WHO Region",
    caption = "Data sources: WHO COVID data and World Bank GDP data"
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

# Display the labeled plot
print(p3)

# Save the labeled plot
ggsave("gdp_vs_death_rate_labeled.png", plot = p3, width = 14, height = 10, dpi = 300)

# Calculate and display correlation
correlation <- cor(plot_data$`Deaths - cumulative total per 100000 population`, 
                   plot_data$GDP_per_capita_2022, 
                   use = "complete.obs")

print(paste("Correlation coefficient:", round(correlation, 3)))

# Create summary statistics by WHO Region
regional_summary <- plot_data %>%
  group_by(`WHO Region`) %>%
  summarise(
    Countries = n(),
    Avg_Death_Rate = round(mean(`Deaths - cumulative total per 100000 population`), 1),
    Avg_GDP = round(mean(GDP_per_capita_2022), 0),
    .groups = 'drop'
  ) %>%
  arrange(desc(Avg_GDP))

print("Summary by WHO Region:")
print(regional_summary)

# Create a boxplot by WHO Region
p4 <- ggplot(plot_data, aes(x = reorder(`WHO Region`, GDP_per_capita_2022, median), 
                           y = `Deaths - cumulative total per 100000 population`)) +
  geom_boxplot(aes(fill = `WHO Region`), alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.5) +
  coord_flip() +
  labs(
    title = "COVID Death Rates by WHO Region",
    subtitle = "Regions ordered by median GDP per capita",
    x = "WHO Region",
    y = "COVID Deaths per 100,000 Population",
    fill = "WHO Region"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 12),
    axis.title = element_text(size = 11),
    legend.position = "none"
  )

print(p4)
ggsave("death_rates_by_region.png", plot = p4, width = 12, height = 8, dpi = 300)

print("Visualization completed!")
print("Generated plots:")
print("1. gdp_vs_death_rate.png - Main scatter plot")
print("2. gdp_vs_death_rate_log.png - Log scale version")
print("3. gdp_vs_death_rate_labeled.png - With country labels")
print("4. death_rates_by_region.png - Boxplot by WHO region")
