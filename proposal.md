# Project Proposal: Interactive COVID-19 Shiny Application

---

## High-Level Goal

The objective of this project is to develop an interactive Shiny web application that visualizes COVID-19 epidemiological trends, with comparative global analyses, to enhance understanding of localized versus worldwide pandemic dynamics.

---

## Project Description

This project proposes the design and implementation of an interactive, data-driven web application for visualizing the spatiotemporal progression of the COVID-19 pandemic in New York City, supplemented by global comparative data. The platform will feature dynamic dashboards incorporating time series analysis, spatially explicit choropleth mapping, and interactive filtering functionalities. The application will empower users to explore COVID-19 case counts, mortality rates, hospitalization trends, testing efforts, and vaccination rollouts across NYC boroughs and juxtapose these local patterns with national and international trajectories. Built with R Shiny and utilizing advanced visualization libraries such as `leaflet`, `plotly`, and `ggplot2`, this application will serve as an accessible yet powerful analytical tool for researchers, public health officials, and the general public. The final deliverable will be an open-source, web-deployed application, accompanied by a reproducible GitHub repository containing all source code, documentation, and data processing scripts.

---

## Goals and Motivation

The primary objective of this project is to develop an interactive, city-level epidemiological analysis tool that can visualize and compare COVID-19 data trends across New York City’s boroughs, with an integrated global context. This Shiny-based web application will provide a granular understanding of COVID-19 transmission, hospitalization, mortality, and recovery patterns at a spatially detailed level, with particular attention to local disparities. By offering a comprehensive visualization platform that enables users to perform comparative analyses between local, national, and international datasets, the application aims to address key questions about the heterogeneous impacts of the pandemic in urban settings.

Despite the wealth of data on COVID-19 available globally, the complexities of urban public health dynamics—particularly in densely populated cities like New York—are often obscured in existing dashboard tools. These tools predominantly focus on global or national trends, leaving a critical gap in understanding localized epidemiological patterns, which are essential for effective public health decision-making. Furthermore, there is a lack of tools that allow for real-time comparison between local and global data trends, which could aid policymakers in adapting interventions to context-specific needs.

This project is motivated by the need for accessible, interactive, and data-driven resources that can help answer pressing research questions and inform pandemic response strategies. It aims to support public health officials, researchers, and the general public in their understanding of pandemic trends and to highlight disparities across New York City’s diverse demographic groups. By addressing this gap, the project seeks to contribute to more equitable pandemic preparedness and response, particularly by enabling decision-makers to make informed choices based on city-specific epidemiological insights.

---

## Data Sources and Collection Methodology

The application will integrate two authoritative and continually updated datasets:

- **New York City COVID-19 Data** ([NYC Health GitHub Repository](https://github.com/nychealth/coronavirus-data)): This dataset provides daily citywide and borough-specific metrics on confirmed cases, hospitalizations, deaths, testing rates, and vaccination coverage. Data are disaggregated by demographic variables such as age, race/ethnicity, and neighborhood of residence.

- **Our World in Data COVID-19 Dataset** ([OWID GitHub Repository](https://github.com/owid/covid-19-data/tree/master)): This global dataset includes national-level statistics for cases, deaths, testing, hospitalizations, vaccinations, and governmental response indices for over 200 countries and territories.

Data will be accessed via direct downloads in CSV format. Comprehensive preprocessing will be undertaken, including:
- Standardization of date formats and temporal aggregation
- Harmonization of variable names and data structures
- Geospatial data processing for NYC borough shapefiles to enable interactive mapping
- Calculation of normalized metrics (e.g., per capita rates) to facilitate comparability across spatial units

All data processing scripts will be fully documented and reproducible within the project’s GitHub repository.

---

## Research Questions

The project is structured around the following primary research inquiries:

# **Research Question 1: How did the transmission, hospitalization, mortality, and recovery patterns of COVID-19 differ among NYC boroughs, and how do these local patterns compare to national and global trends over time?**

The COVID-19 pandemic has exhibited significant spatial variation, with urban environments like New York City (NYC) experiencing unique epidemiological patterns due to factors such as population density, socio-economic disparities, and healthcare access. NYC is one of the most populous and diverse cities globally, with boroughs exhibiting varying demographic profiles and public health infrastructure. Thus, understanding how the pandemic unfolded within each of the five boroughs is crucial for effective policy formulation and resource allocation. 

This research question seeks to identify intra-city differences and trends, which can reveal underlying disparities in how different neighborhoods and demographic groups were affected. For example, boroughs like Manhattan may have experienced a different transmission and mortality rate compared to Brooklyn or Queens, due to differences in age, ethnicity, and healthcare accessibility. By comparing these localized trends to national and global patterns, this question will provide critical insights into the unique dynamics of urban outbreaks and how local factors may have contributed to the overall pandemic progression.

This comparative approach will also shed light on whether certain public health interventions or population characteristics (e.g., vaccination rates or ethnic disparities) led to divergent outcomes at the borough level compared to national and international patterns, offering insights that can be used in future pandemic preparedness efforts.

# **Research Question 2: What temporal relationships exist between public health interventions (such as vaccination rollouts) and observable changes in COVID-19 incidence and mortality within NYC and globally?**

One of the most important lessons learned from the COVID-19 pandemic is the role that public health interventions, such as vaccination campaigns and social distancing measures, play in curbing the spread of infectious diseases. Understanding the temporal relationship between the introduction of these interventions and changes in COVID-19 case rates and mortality is essential for evaluating the effectiveness of different strategies.

In the context of New York City, there is a need to assess how interventions, such as vaccination rollouts and public health restrictions (e.g., lockdowns, mask mandates), influenced the trajectory of the pandemic in real time. This question will help evaluate whether certain interventions had a clear and measurable impact on reducing transmission or mortality, and how quickly such effects were observed after implementation. 

By extending the analysis globally, this question also allows for cross-country comparisons, which can provide insights into how different nations responded to the pandemic and what interventions were most effective under varying contexts. For instance, did early vaccination campaigns in countries like Israel or the UK show a rapid decline in cases and deaths? Were there time lags in these effects, and how did this compare to the experience of NYC? This temporal analysis is important for understanding the causality of interventions and for informing future pandemic response plans.


# **Research Question 3: How did the intensity and accessibility of COVID-19 testing efforts vary across different boroughs, and what correlations can be observed with infection and fatality rates?**

Testing plays a critical role in identifying and controlling the spread of infectious diseases. Early and widespread testing allows public health authorities to identify outbreaks, implement containment measures, and track the progress of the pandemic. However, testing capacity, accessibility, and frequency have varied widely, not only across countries but also within urban settings like New York City, which has vast social and economic inequalities.

This research question is essential because it examines the relationship between testing efforts and COVID-19 outcomes, specifically infection rates and mortality. It is important to explore how variations in testing intensity and accessibility across different boroughs in NYC may have influenced the recorded rates of COVID-19 infections and fatalities. For example, boroughs with higher testing coverage may have reported more cases, but this could be due to more testing availability rather than a true increase in cases. On the other hand, areas with less testing may have underestimated the number of infected individuals, potentially resulting in higher fatality rates due to delayed detection.

Furthermore, this question will help identify whether unequal access to testing disproportionately impacted certain populations, particularly marginalized or underserved communities, thus contributing to disparities in health outcomes. By understanding these dynamics, policymakers can identify gaps in testing infrastructure and improve strategies for equitable testing in future public health crises.


By addressing these questions, the project will illuminate disparities in health outcomes, evaluate the impact of public health measures, and identify patterns that may inform more equitable and effective responses to future public health crises.

---

## Project Timeline and Task Allocation

| Week | Tasks | Details |
|:-----|:------|:--------|
| **Week 1 (24/4 - 27/4)** | Repository Initialization and Data Preprocessing | - Set up public GitHub repository<br>- Acquire datasets and conduct initial data cleaning<br>- Perform exploratory data analysis (EDA) to identify data limitations and trends<br>- Process spatial data for NYC borough mapping 
| **Week 2 (28/4 - 7/5)** | Shiny Application Architecture and Static Dashboard Prototyping | - Establish R Shiny app structure (modularized UI and server)<br>- Design initial layout and UI mockups<br>- Implement summary statistics display (key metrics cards)<br>- Build initial static plots (time series of cases, deaths, vaccinations) |
| **Week 3 (8/5 - 16/5)** | Implementation of Interactivity and Global Data Integration | - Integrate user input controls (date range, borough selector, variable selector)<br>- Implement reactive data filtering and dynamic plot updating<br>- Incorporate OWID global dataset and establish comparative visualizations |
| **Week 4 (17/5 - 24/5)** | Advanced Visualization: Interactive Map Development and Linkage | - Develop interactive choropleth map of NYC boroughs using `leaflet`<br>- Enable dynamic linkage between map selections and dashboard outputs<br>- Add hover tooltips and popup summary statistics for boroughs | 
| **Week 5 (25/5 - 30/5)** | Application Optimization, Final Documentation, and Deployment | - Conduct system-wide application testing and debugging<br>- Optimize performance for faster loading and smoother interactions<br>- Complete project report, README documentation, and user guide<br>- Deploy application via [shinyapps.io](https://www.shinyapps.io/) | 

---

## Academic Contribution

By focusing on fine-grained spatial and temporal analyses of the COVID-19 pandemic at the city level, this project addresses critical gaps in the existing landscape of epidemiological visualization tools. It offers methodological innovations through the integration of local and global datasets in a unified, interactive platform, enabling granular public health analysis previously unavailable in many public-facing dashboards. Furthermore, the project provides a reproducible framework that can be adapted for future pandemic responses or other urban public health challenges, thereby contributing to the growing field of open-source public health informatics.

---

## Conclusion

This project endeavors to build a highly interactive and analytically rigorous Shiny application that visualizes the spatial and temporal evolution of COVID-19 in New York City, with comparative global perspectives. By integrating authoritative local and international datasets, applying advanced visualization techniques, and focusing on critical research questions around spatial disparities and vaccination outcomes, the project aims to produce actionable insights for public health research and policy. 

Beyond serving as a retrospective tool for understanding the pandemic's dynamics, this application will offer a reproducible, open-source framework that can be adapted for future epidemiological monitoring and urban health studies. In doing so, the project not only contributes to the growing field of digital public health tools but also promotes transparency, accessibility, and informed decision-making during global health crises.

