# 📊 COMP4010 - Data Visualization - Project 2 

## Overview

The outbreak of the COVID-19 pandemic in late 2019 marked the beginning of an unprecedented global health crisis. The novel coronavirus (SARS-CoV-2) rapidly spread across countries and continents, severely challenging public health systems, economies, and societal structures. In response to this evolving emergency, accurate and up-to-date data became essential for governments, researchers, healthcare professionals, and the general public to make informed decisions and implement effective containment strategies.

However, the massive volume and complexity of pandemic-related data presented considerable challenges. As case numbers, death rates, and testing metrics surged globally, many stakeholders lacked the tools to efficiently analyze and interpret this rapidly changing information. Traditional tabular reports or static charts often failed to capture the multidimensional, dynamic nature of the pandemic, especially when users sought to understand temporal and geographic trends simultaneously.

To address this issue, our project aims to develop an interactive, user-friendly data visualization tool using the `Shiny` web application framework in `RStudio`. This tool is designed to help users explore the progression of COVID-19 across time and space through a set of intuitive and customizable visualizations. The primary goal is to bridge the gap between raw epidemiological data and actionable insight, enabling users — whether technical or non-technical — to observe patterns, compare regions, and understand the impact of the pandemic over time.

We explore two main research questions:

- Question 1: How does a nation's economic capacity influence its ability to respond to and recover from the COVID-19 pandemic across different continents?
- Question 2: What patterns can be observed in the rise, peak, and decline of COVID-19 cases across nations, and how can visualizations of these trends help identify commonalities in effective public health responses that contributed to minimizing outbreaks?

Through detailed data analysis and visualization, we aim to highlight key findings in a compelling and accessible manner, allowing both public health professionals and general audiences to gain fresh perspectives on the progression and impact of the COVID-19 pandemic.

## Repository Structure

```
.
├── Research Question 1/        # Addition for Research Question 1
├── data/               # Dataset 
│   ├── README.md     
│   ├── generate-data.R
├── www/               # Public images
│   ├── covid-gate.gif    
│   ├── logo.png
│   ├── covid-simulation.gif   
├── presentation.pdf     # Project presentation slides
├── proposal.md          # Project proposal
├── app.R          
├── README.md
├── setup.Rmd  
└── report.pdf            # Detailed project report
```
1. Clone this repository.
 ```bash
   git clone https://github.com/tunglambg131003/data_visualization_project_2.git
   cd data_visualization_project_2
 ```
2. Open the script in the `data/` directory to reproduce the dataset:
- `generate-data.R`
3. Run the Shiny app locally using the following script:
- `app.R`
4. Ensure you have all necessary dependencies installed. 

## Acknowledgement

This project is conducted as part of COMP4010-Data Visualization course at our university. We would like to express our heartfelt appreciation to our course instructor and teaching assistants for their guidance, insightful feedback, and continued support throughout the development of this project.

## Authors and Contact Information

- **Nguyen Tung Lam**  
  *V202100571*  
  Email: [21lam.nt@vinuni.edu.vn](mailto:21lam.nt@vinuni.edu.vn)

- **Dang Duc Dat**  
  *V202100526*  
  Email: [21dat.dd@vinuni.edu.vn](mailto:21dat.dd@vinuni.edu.vn)

- **Chau Minh Khai**  
  *V202100404*  
  Email: [21khai.cm@vinuni.edu.vn](mailto:21khai.cm@vinuni.edu.vn)

Feel free to contact us with any questions, suggestions, or comments related to this project. We welcome any feedback that can help improve this work or contribute to further research in the domain of music data analysis and visualization.
