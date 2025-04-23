# 📊 Data Warehouse and Analytics Project Using SQL

## 📌 Project Overview
This project combines the concepts of data warehousing and data analytics using SQL. It demonstrates the end-to-end journey of raw data from ingestion to data analytics and reporting using structured SQL scripts. 

## 🎯 Objective
This project involves:
1. **Data Architecture**: Build and set up a data warehouse using MySQL.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating SQL-based reports for actionable insights.

## 📂 Dataset
- **Source**: [Dataset](datasets)
- This project uses CSV files extracted from two simulated source systems (CRM and ERP), which provides data related to customer demographic, product details and sales transactions.

## 🔧 Skills Demonstrated
- Data Warehouse Schema Design
- Data Cleaning & Transformation
- Joins and Aggregations
- Exploratory Data Analysis (EDA)
- Customer and Product Reporting
- Data Quality Checks

## 📦 Repository Structure
```
SQL-Data-Warehouse-Project/
│
├── datasets/                                 # Raw datasets used for the project (ERP and CRM data)
│
├── docs/                                     # Project documentation and architecture details
│   ├── data_flow.png                         # Data flow diagram
│   ├── data_integration.png                  # CRM and ERP key relationship diagram
│   ├── data_scheme_diagram.png               # Data scheme diagram
│
├── scripts/                                  # SQL scripts for ETL, transformations, analytics and reporting
│   ├── 01_database_table_setup.sql           # Scripts for extracting and loading raw data
│   ├── 02_data_transformation_cleaning.sql   # Scripts for cleaning and transforming data
│   ├── 03_data_integration.sql               # Scripts for creating analytical models
│   ├── 04_quality_check.sql                  # Scripts for validating data quality with integrity checks
│   ├── 05_data_analysis.sql                  # Scripts for performing data analyses (e.g. time-based trends, segmentation, etc.)
│   ├── 06_customer_report.sql                # Scripts for consolidating key customer metrics and behaviours
│   ├── 07_product_report.sql                 # Scripts for consolidating key product metrics and segmentation
│
├── LICENSE                                   # License information for the repository
├── README.md                                 # Project overview and information
```

## 📚 References
- [SQL Data Warehouse Project by DataWithBaraa](https://github.com/DataWithBaraa/sql-data-warehouse-project)
- [SQL Data Analytics Project by DataWithBaraa](https://github.com/DataWithBaraa/sql-data-analytics-project)
