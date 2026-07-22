# 🚚 Logistics Delivery Analytics Platform

> **End-to-End ETL Pipeline and Business Intelligence Reporting using Azure SQL and R**

## 📖 Project Overview

The Logistics Delivery Analytics Platform is an end-to-end data engineering project that demonstrates how raw logistics data can be transformed into meaningful business insights using SQL-based ETL and analytical reporting.

The project simulates a real-world analytics workflow by loading raw logistics datasets into Azure SQL, performing data validation and transformation through an ETL pipeline, enriching delivery records with weather and traffic information, and generating a business intelligence report using R Markdown.

This project highlights practical SQL development, ETL design, data modeling, and business intelligence reporting skills used in logistics and supply chain analytics.

---

# 🎯 Objectives

* Build a SQL-based ETL pipeline
* Validate and transform raw logistics data
* Integrate delivery transactions with weather and traffic datasets
* Create a reporting-ready fact table
* Analyze delivery performance in R
* Produce a professional business intelligence report

---

# 🏗️ Project Architecture

```text
Raw CSV Files
      │
      ▼
Azure SQL Staging Tables
      │
      ▼
SQL ETL Pipeline
      │
      ▼
Clean csv file
      │
      ▼
R Markdown Analytics
      │
      ▼
Business Intelligence Report
```

---

# 🛠️ Technology Stack

| Category        | Technologies        |
| --------------- | ------------------- |
| Database        | Azure SQL Database  |
| Cloud Storage   | Azure Blob Storage  |
| ETL             | SQL                 |
| Analytics       | R                   |
| Visualization   | ggplot2, R Markdown |
| Version Control | Git, GitHub         |

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
├── sql/
│   └── etl.sql
│
├── reports/
│   ├── logistics_delivery_report.Rmd
│   └── logistics_delivery_report.html
│
│
└── README.md
```

---

# 📊 Dataset

The project combines two datasets.

### Delivery Transactions

Contains:

* Delivery ID
* Order Date
* Delivery Date
* Delivery Partner
* City
* Province
* Distance
* Delivery Cost

### Delivery Conditions

Contains:

* Weather
* Traffic Level
* Fuel Price
* Condition Date

---

# ⚙️ ETL Pipeline

The ETL pipeline follows a multi-stage process:

### 1. Load Raw Data

Raw logistics datasets are loaded into Azure SQL staging tables.

### 2. Data Validation

The pipeline validates data by:

* Removing duplicate deliveries
* Removing incomplete records
* Converting data types
* Standardizing delivery partner names
* Validating delivery costs and distances

### 3. Data Enrichment

Delivery transactions are enriched using weather and traffic condition datasets to provide additional operational context for analysis.

### 4. Reporting Layer

The transformed data is loaded into the reporting fact table:

```sql
fact_delivery_performance
```

The fact table includes calculated metrics such as:

* Delivery Time
* Cost per Kilometre
* Average Speed
* Weather
* Traffic Level
* Fuel Price

---

# 📈 Business Questions

The project explores questions such as:

* Which delivery partner has the fastest average delivery time?
* Which delivery partner is the most cost-efficient?
* How does weather affect delivery performance?
* How does traffic impact delivery times?
* Which provinces achieve the strongest delivery performance?
* What relationship exists between delivery distance and delivery cost?

---

# 📊 Business Intelligence Report

The final reporting table is analyzed using R Markdown.

The report includes:

* Executive Summary
* Delivery Partner Performance
* Weather Analysis
* Traffic Analysis
* Provincial Performance
* City Performance
* Distance vs Delivery Time
* Distance vs Cost
* Delivery Speed Analysis
* Business Recommendations

---

# 💡 Key Insights

The analysis demonstrates that logistics performance is influenced by both operational and environmental factors.

Key findings include:

* Delivery performance varies across delivery partners.
* Weather conditions can increase delivery times.
* Heavy traffic is associated with slower deliveries.
* Delivery cost efficiency differs between carriers.
* Longer delivery distances generally result in higher delivery costs and longer delivery times.

---

# 🚀 Future Improvements

Potential enhancements include:

* Azure Data Factory pipeline orchestration
* Automated ETL scheduling
* Power BI dashboard development
* Predictive delivery-time modeling
* Route optimization using machine learning

---
