# Project Proposal: Interactive COVID-19 Shiny Application
**Team Members:** Nguyen Tung Lam, Chau Minh Khai, Dang Duc Dat

## **1. High-Level Goal**

This project aims to develop an **interactive, web-based Shiny application** that visualizes global COVID-19 trends using dynamic dashboards. The application will help users explore the evolution of the pandemic across different countries, evaluate public health responses, and analyze how national economic capacity affected pandemic outcomes.

## 2. Project Description

We will build an interactive dashboard using **R Shiny** that allows users to:

- Explore time series data of confirmed cases, deaths, and recoveries  
- Compare pandemic trajectories across countries and continents  
- Visualize global trends with choropleth maps, line plots, and data tables  
- Analyze pandemic progression in relation to socio-economic indicators like GDP per capita and health expenditure  

The app will incorporate libraries such as `ggplot2`, `plotly`, and `leaflet`. Filters will allow customization by country, region, time range, and metric. The final product will be deployed online and fully documented for reproducibility.

## 3. Goals and Motivation

While many COVID-19 dashboards exist, few offer:

- Cross-country comparisons integrating both health and economic data  
- Interactive visualizations for exploratory, data-driven insights  
- A platform that is equally useful for researchers, educators, and general users  

Our motivation is to create an educational and analytical tool that shows how **economic resilience** impacted **public health outcomes** and **crisis response** during the COVID-19 pandemic.

## 4. Data Sources and Collection Methodology

We will use the following data sources:

### 1. [Johns Hopkins University (JHU) CSSE COVID-19 Dataset](https://github.com/CSSEGISandData/COVID-19)  
- Daily time series data of confirmed cases, deaths, and recoveries  
- Global coverage, updated until March 2023  
- Country-level granularity  

### 2. [Our World in Data (OWID)](https://ourworldindata.org/coronavirus)  
- Global COVID-19 metrics: testing, vaccination, ICU usage  
- Socio-economic indicators: GDP per capita, healthcare spending, life expectancy  
- Integrates multiple authoritative sources (WHO, World Bank, etc.)

Data will be preprocessed using `dplyr` and `tidyr` for analysis, and spatial components will be mapped via `leaflet`.


## 5. Research Questions

### 1. How does a nation's economic capacity influence its ability to respond to and recover from the COVID-19 pandemic across different continents?

We explore whether countries with higher GDP per capita, stronger healthcare systems, or greater fiscal capacity achieved better health outcomes—such as lower case fatality rates, faster vaccination rollouts, and shorter wave durations.

### 2. What patterns can be observed in the rise, peak, and decline of COVID-19 cases across nations, and how can visualizations of these trends help identify commonalities in effective public health responses that contributed to minimizing outbreaks?

We examine global case timelines to identify consistent features across countries and relate these to the timing of public health interventions, enabling insights into what worked (and when).

## 6. Project Timeline and Task Allocation

| Week | Tasks | Details | Assigned Team Member(s) |
|:-----|:------|:--------|:-------------------------|
| **Week 1 (25/4 - 4/5)** | Repository Initialization and Data Preprocessing | - Set up public GitHub repository<br>- Acquire datasets and conduct initial data cleaning<br>- Perform exploratory data analysis (EDA) to identify data limitations and trends<br>- Process spatial data borough mapping | Nguyen Tung Lam (data acquisition, cleaning), Chau Minh Khai (EDA, shapefiles preparation) |
| **Week 2 (4/5 - 11/5)** | Shiny Application Architecture and Static Dashboard Prototyping | - Establish R Shiny app structure (modularized UI and server)<br>- Design initial layout and UI mockups<br>- Implement summary statistics display (key metrics cards)<br>- Build initial static plots (time series of cases, deaths, vaccinations) | Nguyen Tung Lam (UI/UX development), Dang Duc Dat (initial data visualizations) |
| **Week 3 (12/5 - 19/5)** | Implementation of Interactivity and Global Data Integration | - Integrate user input controls (date range, borough selector, variable selector)<br>- Implement reactive data filtering and dynamic plot updating<br>- Incorporate OWID global dataset and establish comparative visualizations | Chau Minh Khai (global data integration, reactive programming), Nguyen Tung Lam (user interface enhancements) |
| **Week 4 (19/5 - 25/5)** | Advanced Visualization: Interactive Map Development and Linkage | - Develop interactive choropleth map boroughs using `leaflet`<br>- Enable dynamic linkage between map selections and dashboard outputs<br>- Add hover tooltips and popup summary statistics for boroughs | Dang Duc Dat (map development and interactivity), Chau Minh Khai (data linkage and reactivity) |
| **Week 5 (26/5 - 30/5)** | Application Optimization, Final Documentation, and Deployment | - Conduct system-wide application testing and debugging<br>- Optimize performance for faster loading and smoother interactions<br>- Complete project report, README documentation, and user guide<br>- Deploy application via [shinyapps.io](https://www.shinyapps.io/) | Nguyen Tung Lam (application optimization), Chau Minh Khai & Dang Duc Dat (documentation, deployment) |

**Key Responsibilities:**

- **Nguyen Tung Lam**: Project Manager, Data Scientist, Front-End Developer 

- **Chau Minh Khai**: Data Engineer, Backend Developer

- **Dang Duc Dat**: Visualization Specialist, UI Developer
  
## 7. Academic Contribution

By focusing on fine-grained spatial and temporal analyses of the COVID-19 pandemic at the city level, this project addresses critical gaps in the existing landscape of epidemiological visualization tools. It offers methodological innovations through the integration of local and global datasets in a unified, interactive platform, enabling granular public health analysis previously unavailable in many public-facing dashboards. Furthermore, the project provides a reproducible framework that can be adapted for future pandemic responses or other urban public health challenges, thereby contributing to the growing field of open-source public health informatics.


## 8. Conclusion

This interactive global COVID-19 dashboard bridges a critical gap between health data and socio-economic context. By providing intuitive tools and actionable visual insights, our application supports **evidence-based decision-making**, **educational outreach**, and **policy development**.

The project will not only serve as a retrospective analytical tool but also as a **reusable framework** for monitoring future global health events.
