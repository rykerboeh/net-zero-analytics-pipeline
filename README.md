# Net-Zero Analytics Pipeline: Executive Emissions Forecasting

[![Tableau](https://img.shields.io/badge/Tableau-View_Interactive_Dashboard-E97627?style=for-the-badge&logo=tableau&logoColor=white)](https://public.tableau.com/app/profile/ryker.boeh/viz/ExecutiveEmissionsOverview/ExecutiveEmissionsOverview)
[![Python](https://img.shields.io/badge/Python-3.9+-3776AB?style=for-the-badge&logo=python&logoColor=white)](notebooks/carbon_footprint_net_zero.ipynb)
![Jupyter Notebook](https://img.shields.io/badge/jupyter-%23FA0F00.svg?style=for-the-badge&logo=jupyter&logoColor=white)
[![SQL](https://img.shields.io/badge/SQL-PostgreSQL%20/%20MySQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](sql/)

An end-to-end data engineering and analytics pipeline that ingests raw, multi-source building utility consumption data, implements a tiered SQL cleaning and aggregation workflow, constructs a 2030 net-zero forcast model in Python, and produces an executive-ready emissions dashboard in Tableau.

---

### 📊 Executive Dashboard Preview
<img width="1360" height="1400" alt="Executive Emissions Overview | Tableau Public" src="https://github.com/user-attachments/assets/4c15c247-c020-4b3c-97f2-bb817fec07a3" />
> **[👉 Click here to access the live interactive dashboard on Tableau Public](https://public.tableau.com/app/profile/ryker.boeh/viz/ExecutiveEmissionsOverview/ExecutiveEmissionsOverview?publish=yes)**

---

## 🎯 Business Case & Objectives
The organization in question aims to acheive a net-zero carbon footprint, but lacks visibility into what business activities and real estate assets are driving environmental liabilities. The raw data is fragmented across multiple databases.

This project aims to centralize the fragmented data into a unified consumption database, calculate a functional weighted carbon intensity metric, and craft a "business-as-usual" projection to track consumption against 2030 net-zero milestones.

---

## 🛠 Tech Stack & Tools
* **Data Ingestion & Extraction:** SQL (DBCreation, CTEs, Joins, Window Functions)
* **Data Pipeline & Analytics:** Python (Pandas, NumPy, Jupyter Notebooks)
* **Business Intelligence:** Tableau Desktop (Calculated Fields, Fixed Container UI Design, Executive KPI Tracking)

---

## 📁 Repository Structure
```text
├── data/
│   ├── raw/                        # Source Kaggle data (Git-ignored)
│   └── processed/                  # Final output layers consumed by Tableau
│       ├── building_emissions_master.csv
│       └── 2030_forecast_timeline.csv
├── sql/                            # Relational pipeline steps
│   ├── 01_database_creation.sql    
│   ├── 02_data_cleaning.sql
│   └── 03_data_aggregation.sql
├── notebooks/                      # Data modeling & analytical forecasting
│   └── carbon_footprint_net_zero.ipynb
├── dashboard/                      # Production BI assets
│   ├── executive_emissions_overview.twbx
│   └── dashboard_preview.png       
├── .gitignore                      # Prevents local cache & heavy datasets from staging
├── requirements.txt                # Enforces reproducible Python execution environment
└── README.md                       # Master project documentation
```
---

## ⚙️ Data Pipeline Architecture & Lineage

### Phase 1: Database Setup, Cleaning & Aggregation (SQL)
Raw telemetry streams (`building_consumption.csv`, `gas_consumption.csv`, etc.) were structured and cleaned using relational logic to remove data gaps and prepare structural metadata:
* **`01_database_creation.sql`**: Defines schemas, constraint rules, and primary/foreign key mappings across consumption logs and campus metadata tables.
* **`02_data_cleaning.sql`**: Isolates and handles null values, drops duplicate entries, handles unit mismatches, and applies timestamp standardization.
* **`03_data_aggregation.sql`**: Uses Window Functions and Common Table Expressions (CTEs) to consolidate daily meter reads into monthly, building-level profiles.

### Phase 2: Granularity Engineering & 2030 Predictive Modeling (Python)
Using the consolidated SQL views, the pipeline moves to Python (`notebooks/carbon_footprint_net_zero.ipynb`) to build out carbon accounting fields and time-series projections:
* **Scope Classification:** Dynamically maps utility types to Greenhouse Gas (GHG) accounting classifications (Scope 1 for on-site gas combustion vs. Scope 2 for purchased electricity grid consumption).
* **Forecasting Pipeline:** Projects operational emissions data forward to 2026-2030 utilizing time-series business-as-usual (BAU) trend assumptions to model true gaps against carbon reduction targets.
* **Outputs:** Generates two streamlined tables in `data/processed/` that drastically decrease Tableau's rendering latency.

### Phase 3: Enterprise Analytics Design (Tableau)
The front-end design avoids generic chart-dump layouts, using an executive-first layout focused on action-oriented analytics:
* **Target Variance KPI:** Tracks current performance explicitly (`+26.0% Above Target`), prompting immediate corporate resource allocation.
* **Portfolio-Weighted Carbon Intensity:** Engineered as a calculated field `SUM([Total Emissions]) / SUM([Gross Floor Area]) * 1000000` to prevent unweighted averages from skewing strategic planning. Normalized as **MTCO2e / Million sq. ft.** for enterprise consistency.
* **Portfolio Efficiency Audit (Scatterplot):** Intentionally maps total emissions against total square footage to immediately isolate high-emissions structural outliers.
* **Intensity Trends by Property Type (Heatmap):** Maps continuous historical change across differing asset classes to monitor real estate segment progress over time.
* **2030 Climate Path (Timeline):** Placed as a full-width foundational visual chart tracking current historical trajectory directly against the target glidepath.

---

## 🚀 How to Reproduce & Run Locally

### 1. Clone the Repository
```bash
git clone [https://github.com/rykerboeh/net-zero-analytics-pipeline.git](https://github.com/rykerboeh/net-zero-analytics-pipeline.git)
cd net-zero-analytics-pipeline
cd net-zero-analytics-pipeline
```

### 2. Set Up the Python Environment
Install dependencies using the provided environment specifications:

```bash
pip install -r requirements.txt
```

### 3. Source the Raw Data
* Download the raw building and telemetry datasets directly from https://www.kaggle.com/datasets/cdaclab/unicon/data.

* Place the raw files into your local data/raw/ directory (Note: This directory is blocked by .gitignore to protect storage boundaries).

### 4. Execute the SQL Pipeline & Analytical Notebook
* Run files 01_ through 03_ in your preferred SQL relational database management engine to build the underlying target structures.

* Run notebooks/carbon_footprint_net_zero.ipynb to generate the processed CSV data output files.

* Open dashboard/executive_emissions_overview.twbx using Tableau Desktop or Tableau Public to explore the user interface.


Developed by Ryker Boeh — Connect with me on https://www.linkedin.com/in/rboeh
