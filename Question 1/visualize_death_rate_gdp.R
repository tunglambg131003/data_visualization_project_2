# R Code to Visualize Relationship between Death Rate and GDP per Capita
# X-axis: Death Rate (Total Deaths / Total Cases)
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
         !is.na(`Cases - cumulative total`) & 
         !is.na(`Deaths - cumulative total`) &
         `Cases - cumulative total` > 0 &  # Avoid division by zero
         `Deaths - cumulative total` >= 0) %>%
  # Calculate death rate as deaths/cases
  mutate(
    Death_Rate = `Deaths - cumulative total` / `Cases - cumulative total`,
    Death_Rate_Percent = Death_Rate * 100
  ) %>%
  # Remove extreme outliers for better visualization
  filter(Death_Rate <= 0.15 &  # Remove death rates above 15%
         GDP_per_capita_2022 < 150000)  # Remove extreme GDP outliers

print(paste("Number of countries in visualization:", nrow(plot_data)))
print(paste("Death rate range:", round(min(plot_data$Death_Rate_Percent), 2), "% to", round(max(plot_data$Death_Rate_Percent), 2), "%"))

# Create the main scatter plot
p1 <- ggplot(plot_data, aes(x = Death_Rate_Percent, y = GDP_per_capita_2022)) +
  geom_point(aes(color = `WHO Region`), alpha = 0.7, size = 3) +
  geom_smooth(method = "lm", se = TRUE, color = "red", linetype = "dashed") +
  scale_y_continuous(labels = scales::dollar_format(prefix = "$", suffix = "K", scale = 0.001)) +
  scale_x_continuous(labels = scales::percent_format(scale = 1)) +
  labs(
    title = "Relationship between COVID Death Rate and GDP per Capita (2022)",
    subtitle = "Death Rate = Total Deaths / Total Cases",
    x = "COVID Death Rate (%)",
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
ggsave("death_rate_vs_gdp.png", plot = p1, width = 12, height = 8, dpi = 300)

# Create a log-scale version for better visualization
p2 <- ggplot(plot_data, aes(x = Death_Rate_Percent, y = GDP_per_capita_2022)) +
  geom_point(aes(color = `WHO Region`), alpha = 0.7, size = 3) +
  geom_smooth(method = "lm", se = TRUE, color = "red", linetype = "dashed") +
  scale_y_log10(labels = scales::dollar_format(prefix = "$", suffix = "K", scale = 0.001)) +
  scale_x_continuous(labels = scales::percent_format(scale = 1)) +
  labs(
    title = "Death Rate vs GDP per Capita (Log Scale)",
    subtitle = "Y-axis on logarithmic scale for better visualization",
    x = "COVID Death Rate (%)",
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
ggsave("death_rate_vs_gdp_log.png", plot = p2, width = 12, height = 8, dpi = 300)

# Identify countries with extreme death rates or GDP for labeling
extreme_countries <- plot_data %>%
  filter(
    (Death_Rate_Percent > 4 & GDP_per_capita_2022 > 30000) |  # High death rate, high GDP
    (Death_Rate_Percent > 6) |  # Very high death rate
    (Death_Rate_Percent < 0.5 & GDP_per_capita_2022 > 50000) |  # Very low death rate, high GDP
    (GDP_per_capita_2022 > 80000)  # Very high GDP
  )

# Create a plot with country labels
p3 <- ggplot(plot_data, aes(x = Death_Rate_Percent, y = GDP_per_capita_2022)) +
  geom_point(aes(color = `WHO Region`), alpha = 0.6, size = 2.5) +
  geom_smooth(method = "lm", se = TRUE, color = "red", linetype = "dashed", alpha = 0.3) +
  geom_text(data = extreme_countries, 
            aes(label = Country), 
            size = 3, 
            hjust = 0, 
            vjust = 0, 
            nudge_x = 0.1, 
            nudge_y = 2000,
            check_overlap = TRUE) +
  scale_y_continuous(labels = scales::dollar_format(prefix = "$", suffix = "K", scale = 0.001)) +
  scale_x_continuous(labels = scales::percent_format(scale = 1)) +
  labs(
    title = "Death Rate vs GDP with Country Labels",
    subtitle = "Selected countries with extreme values are labeled",
    x = "COVID Death Rate (%)",
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
ggsave("death_rate_vs_gdp_labeled.png", plot = p3, width = 14, height = 10, dpi = 300)

# Calculate and display correlation
correlation <- cor(plot_data$Death_Rate_Percent, 
                   plot_data$GDP_per_capita_2022, 
                   use = "complete.obs")

print(paste("Correlation coefficient between death rate and GDP:", round(correlation, 3)))

# Create summary statistics by WHO Region
regional_summary <- plot_data %>%
  group_by(`WHO Region`) %>%
  summarise(
    Countries = n(),
    Avg_Death_Rate = round(mean(Death_Rate_Percent), 2),
    Median_Death_Rate = round(median(Death_Rate_Percent), 2),
    Avg_GDP = round(mean(GDP_per_capita_2022), 0),
    .groups = 'drop'
  ) %>%
  arrange(desc(Avg_GDP))

print("Summary by WHO Region:")
print(regional_summary)

# Show countries with highest and lowest death rates
print("\nTop 10 countries by death rate:")
top_death_rate <- plot_data %>%
  arrange(desc(Death_Rate_Percent)) %>%
  select(Country, `WHO Region`, Death_Rate_Percent, GDP_per_capita_2022, 
         `Cases - cumulative total`, `Deaths - cumulative total`) %>%
  head(10)
print(top_death_rate)

print("\nBottom 10 countries by death rate:")
bottom_death_rate <- plot_data %>%
  arrange(Death_Rate_Percent) %>%
  select(Country, `WHO Region`, Death_Rate_Percent, GDP_per_capita_2022, 
         `Cases - cumulative total`, `Deaths - cumulative total`) %>%
  head(10)
print(bottom_death_rate)

# Create a boxplot by WHO Region for death rates
p4 <- ggplot(plot_data, aes(x = reorder(`WHO Region`, GDP_per_capita_2022, median), 
                           y = Death_Rate_Percent)) +
  geom_boxplot(aes(fill = `WHO Region`), alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.5) +
  coord_flip() +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  labs(
    title = "COVID Death Rates by WHO Region",
    subtitle = "Regions ordered by median GDP per capita",
    x = "WHO Region",
    y = "COVID Death Rate (%)",
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
ggsave("death_rate_by_region_boxplot.png", plot = p4, width = 12, height = 8, dpi = 300)

# Summary statistics
print("\nOverall Death Rate Statistics:")
death_rate_stats <- plot_data %>%
  summarise(
    Countries = n(),
    Mean_Death_Rate = round(mean(Death_Rate_Percent), 2),
    Median_Death_Rate = round(median(Death_Rate_Percent), 2),
    Min_Death_Rate = round(min(Death_Rate_Percent), 2),
    Max_Death_Rate = round(max(Death_Rate_Percent), 2),
    Std_Dev = round(sd(Death_Rate_Percent), 2)
  )
print(death_rate_stats)

print("Visualization completed!")
print("Generated plots:")
print("1. death_rate_vs_gdp.png - Main scatter plot")
print("2. death_rate_vs_gdp_log.png - Log scale version")
print("3. death_rate_vs_gdp_labeled.png - With country labels")
print("4. death_rate_by_region_boxplot.png - Boxplot by WHO region")
