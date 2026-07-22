# 🚚 Logistics Delivery Analytics Platform

> **End-to-End Data Engineering & Business Intelligence Pipeline using Python, Azure SQL, and R**

## 📖 Project Overview

The Logistics Delivery Analytics Platform is an end-to-end data engineering project that demonstrates how raw logistics data can be transformed into actionable business insights.

The project simulates a real-world analytics workflow by cleaning raw delivery datasets with Python, loading them into Azure SQL, performing ETL transformations, enriching records with weather and traffic data, and producing a business intelligence report using R Markdown.

This project showcases practical data engineering, ETL development, SQL querying, and analytical reporting skills commonly used in logistics and supply chain operations.

---

## 🎯 Objectives

* Clean and validate raw logistics datasets
* Build a SQL-based ETL pipeline
* Integrate delivery transactions with environmental conditions
* Create a reporting-ready fact table
* Analyze delivery performance using R
* Produce a professional business intelligence report

---

# 🏗️ Project Architecture

```text
Raw CSV Files
      │
      ▼
Python Data Cleaning
      │
      ▼
Azure Blob Storage
      │
      ▼
Azure SQL Database
      │
      ▼
SQL ETL Pipeline
      │
      ▼
fact_delivery_performance
      │
      ▼
R Markdown Analysis
      │
      ▼
Business Intelligence Report
```

---

# 🛠️ Technology Stack

| Category         | Technologies                           |
| ---------------- | -------------------------------------- |
| Programming      | Python, SQL, R                         |
| Data Processing  | Pandas                                 |
| Cloud            | Azure Blob Storage, Azure SQL Database |
| Data Engineering | SQL ETL Pipeline                       |
| Visualization    | ggplot2, R Markdown                    |
| Version Control  | Git, GitHub                            |

---

# 📂 Repository Structure

```text
logistics-delivery-analytics-platform/
│
├── data/
│   ├── raw/
│   │   ├── logistics_delivery_transactions_v3.csv
│   │   └── logistics_delivery_conditions_v3.csv
│   │
│   └── processed/
│       └── fact_delivery_performance.csv
│
├── python/
│   └── logistics_cleaning.py
│
├── sql/
│   └── etl.sql
│
├── reports/
│   ├── logistics_delivery_report.Rmd
│   └── logistics_delivery_report.html
│
├── images/
│
└── README.md
```

---

# 📊 Dataset

The project combines two datasets.

### Delivery Transactions

Contains shipment information including:

* Delivery ID
* Order Date
* Delivery Date
* Delivery Partner
* City
* Province
* Distance
* Delivery Cost

### Delivery Conditions

Contains operational conditions including:

* Weather
* Traffic Level
* Fuel Price
* Condition Date

---

# ⚙️ ETL Pipeline

## Extract

* Imported raw CSV datasets
* Loaded data into Azure SQL staging tables

## Transform

The SQL ETL pipeline performs several transformations:

* Removed duplicate deliveries
* Removed incomplete records
* Standardized delivery partner names
* Converted data types
* Validated missing values
* Joined transactions with weather and traffic conditions
* Calculated derived business metrics

Derived metrics include:

* Delivery Time (Hours)
* Cost per Kilometre
* Average Speed (KM/H)

## Load

The cleaned and enriched data is loaded into the reporting fact table:

```sql
fact_delivery_performance
```

This table serves as the primary source for business reporting and analysis.

---

# 📈 Business Questions

This project answers key operational questions such as:

* Which delivery partner has the fastest average delivery time?
* Which delivery partner is the most cost-efficient?
* How do weather conditions affect delivery performance?
* How does traffic influence delivery times?
* Which provinces achieve the best delivery performance?
* What relationship exists between delivery distance and delivery cost?

---

# ✅ Data Quality Validation

The ETL pipeline validates data by:

* Removing duplicate records
* Removing incomplete deliveries
* Standardizing categorical values
* Validating delivery costs
* Validating delivery distances
* Enriching missing operational context using weather and traffic data

---

# 📊 Business Intelligence Report

The final reporting table is analyzed in R Markdown to evaluate:

* Delivery Partner Performance
* Weather Impact
* Traffic Impact
* Provincial Performance
* City Performance
* Cost Analysis
* Distance vs Delivery Time
* Distance vs Cost
* Delivery Speed

The report includes summary tables, business insights, and data visualizations to support operational decision-making.

---

# 📸 Sample Visualizations

Add screenshots from your report to the **images** folder and reference them below.

## Executive Summary

```markdown
![Executive Summary](images/executive_summary.png)
```

## Delivery Partner Performance

```markdown
![Partner Performance](images/partner_performance.png)
```

## Weather Impact

```markdown
![Weather Impact](images/weather.png)
```

## Traffic Impact

```markdown
![Traffic Impact](images/traffic.png)
```

## Provincial Performance

```markdown
![Province Performance](images/province.png)
```

---

# 💡 Key Insights

The analysis demonstrates how environmental and operational factors influence logistics performance.

Key findings include:

* Delivery performance varies across delivery partners.
* Weather conditions can increase delivery times and reduce average delivery speed.
* Heavy traffic is associated with longer delivery durations.
* Cost efficiency differs across delivery providers.
* Delivery distance has a positive relationship with both delivery time and delivery cost.

---

# 🚀 Future Improvements

Potential enhancements include:

* Azure Data Factory orchestration
* Scheduled ETL pipelines
* Power BI dashboards
* Predictive delivery-time modeling
* Route optimization using machine learning
* Real-time logistics monitoring

---

# 🎓 Skills Demonstrated

* Python
* SQL
* Azure SQL Database
* Azure Blob Storage
* ETL Pipeline Development
* Data Cleaning
* Data Validation
* Business Intelligence
* R Programming
* Data Visualization
* Git
* GitHub

---

# 👤 Author

**Fasiha Fajar**

Honours Bachelor of Mathematics (Computational Mathematics)
University of Waterloo

LinkedIn: *(Add your LinkedIn URL here)*

GitHub: *(Add your GitHub profile URL here)*
