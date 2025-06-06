## 📄 Dataset Metadata

### 1. Dataset Overview  
**Title:** JHU CSSE COVID-19 Time Series Dataset  
**Description:**  
The core dataset used in this project is the **Johns Hopkins University Center for Systems Science and Engineering (JHU CSSE) COVID-19 time series dataset**, which spans from **January 22, 2020** to **March 7, 2023**. This dataset tracks the global progression of COVID-19 by recording daily statistics at the country and regional levels.  

The full dataset is publicly available at:  
🔗 [https://github.com/CSSEGISandData/COVID-19](https://github.com/CSSEGISandData/COVID-19)

---

### 2. Provenance  
**Source:** [JHU CSSE GitHub Repository](https://github.com/CSSEGISandData/COVID-19)  
**Original Publisher:** Johns Hopkins University CSSE  
**Data Collection:** Compiled from multiple national and international public health authorities.

---

### 3. Dataset Structure  
The dataset includes the following key attributes:

| **Variable**        | **Description**                                                                 |
|---------------------|---------------------------------------------------------------------------------|
| `Date`              | Daily timestamps indicating when data was recorded.                             |
| `Country/Region`    | The name of the reporting country or territory.                                 |
| `Province/State`    | Subnational administrative divisions (when applicable).                         |
| `Latitude` & `Longitude` | Geographic coordinates for mapping purposes.                             |
| `Confirmed`         | Cumulative number of confirmed COVID-19 cases.                                  |
| `Deaths`            | Cumulative number of reported deaths.                                           |
| `Recovered`         | Cumulative number of recoveries (though this field is missing in some regions). |

---

### 4. Usage  
This dataset is useful for:

- Analyzing the temporal and spatial spread of COVID-19.
- Studying patterns of infection, mortality, and recovery over time.
- Powering dashboards and interactive visualizations.
- Epidemiological modeling and academic research.

### 🔧 Generate the Dataset

To generate the dataset, run the following R script located in the `data/` directory:

```r
source("data/generate-data.R")

---

### 5. Licensing  
**License Type:** Not explicitly stated in the repository.  
**Notes:** Usage of this dataset should comply with the terms provided by the JHU CSSE and the original data sources. Refer to [JHU CSSE Licensing Info](https://github.com/CSSEGISandData/COVID-19#license) for more.

---

### 6. Acknowledgments  
Thanks to the **Johns Hopkins University Center for Systems Science and Engineering** for making this data publicly available and maintaining it throughout the pandemic.
