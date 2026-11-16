 Hospital Billing Analytics Platform | Databricks End-to-End Data Engineering Project

📌 Project Overview

The **Hospital Billing Analytics Platform** is an end-to-end data engineering and analytics project built using Databricks.

The main goal of this project is to process hospital billing data, clean and transform raw records, identify data quality issues, and generate meaningful business insights through analytical tables and interactive dashboards.

The project follows the **Medallion Architecture (Bronze, Silver, and Gold)** to organize data processing into three layers.

It uses Databricks SQL and Lakeflow Spark Declarative Pipelines to build the data pipeline and Databricks AI/BI Dashboards to present the final insights.



## 🎯 Project Objectives

- Build an end-to-end data pipeline using Databricks.
- Store raw hospital billing data in the Bronze layer.
- Clean and validate data in the Silver layer.
- Remove duplicate billing records.
- Identify invalid records and data quality issues.
- Create business-level summary tables in the Gold layer.
- Perform data reconciliation across all layers.
- Build an interactive dashboard for hospital billing analysis.


## 🛠️ Technologies Used

| Databricks | Data engineering and analytics platform |
| Unity Catalog | Data organization and governance |
| Databricks SQL | Data transformation and analysis |
| Lakeflow Spark Declarative Pipelines | Building ETL pipelines |
| Delta Tables | Reliable data storage |
| Medallion Architecture | Bronze, Silver and Gold data processing |
| Databricks AI/BI Dashboards | Data visualization and reporting |


## 🏗️ Project Architecture

The project follows the Medallion Architecture.

### Overall Data Flow

Raw CSV Data → Bronze Layer → Silver Layer → Gold Layer → AI/BI Dashboard

### 1. Bronze Layer – Raw Data Ingestion

**Objective:** Store the original hospital billing data without losing the source records.

- Imported the hospital billing CSV file into Databricks.
- Created a Unity Catalog catalog named `healthcare_catalog`.
- Created a schema named `billing`.
- Created a volume named `raw_files`.
- Loaded raw billing records into a Bronze table.

**Bronze Table:**

`healthcare_catalog.billing.bronze_hospital_billing`

**Initial Dataset:**
- Total records: 1,010
- Unique bill IDs: 990
- Duplicate extra records: 20

The Bronze layer preserves the original records for further processing and validation.

### 2. Silver Layer – Data Cleaning and Transformation

**Objective:** Clean the raw data, remove duplicates, and separate valid records from invalid records.

The Silver layer performs the following operations:

- Identified duplicate bill IDs.
- Used `ROW_NUMBER()` with `PARTITION BY` to identify duplicate records.
- Retained one record per bill ID.
- Identified records with zero or negative quantities.
- Identified records with negative unit prices.
- Separated valid and rejected records.
- Handled missing values in selected business columns.
- Preserved records with missing patient IDs because the billing information could still be valid.

**Silver Tables:**

**Clean Table:**
`workspace.default.silver_billing_clean`

**Rejected Table:**
`workspace.default.silver_billing_rejected`

**Silver Processing Results:**

| Description | Records |
|---|---:|
| Bronze records | 1,010 |
| Duplicate records removed | 20 |
| Unique records after deduplication | 990 |
| Clean records | 968 |
| Rejected records | 22 |
| Missing patient IDs retained | 8 |

**Rejected Record Details:**

| Issue | Records |
|---|---:|
| Invalid quantity (zero or negative) | 14 |
| Negative unit price | 8 |
| Total rejected records | 22 |

The Silver layer ensures that only valid billing records are used for business-level analysis.

### 3. Gold Layer – Business-Level Aggregation

**Objective:** Transform the cleaned data into business-ready summary tables for reporting and decision-making.

Created five Gold materialized views using Databricks SQL.

**1. Monthly Revenue Summary**

Table: `gold_monthly_revenue_final`

Metrics:
- Total bills
- Total visits
- Total revenue
- Insurance revenue
- Patient payable amount

**2. Department-Wise Summary**

Table: `gold_department_summary_final`

Metrics:
- Department
- Total bills
- Total visits
- Total revenue
- Average revenue per visit
- Insurance revenue

**3. Hospital Branch Summary**

Table: `gold_branch_summary_final`

Metrics:
- Hospital branch
- City
- Region
- Total bills
- Total visits
- Total revenue
- Average bill amount

**4. Payer-Wise Summary**

Table: `gold_payer_summary_final`

Metrics:
- Payer type
- Total bills
- Total visits
- Total revenue
- Insurance amount
- Pending amount

**5. Data Quality and Reconciliation Summary**

Table: `gold_data_quality_final`

Metrics:
- Total Bronze records
- Unique bill IDs
- Duplicate records
- Missing patient IDs
- Invalid quantity records
- Negative price records
- Missing department records
- Missing payer records
- Missing amount records
- Clean records
- Rejected records
- Total Silver records
- Reconciliation difference

---

## 📊 Data Reconciliation

Data reconciliation was performed to verify that all unique billing records were accounted for after deduplication and validation.

**Reconciliation Formula:**

`Unique Bill IDs = Clean Records + Rejected Records`

Including the duplicate records removed:

`Bronze Records = Clean Records + Rejected Records + Duplicate Records Removed`

**Final Reconciliation:**

`1010 = 968 + 22 + 20`

| Metric | Result |
|---|---:|
| Bronze records | 1,010 |
| Unique bill IDs | 990 |
| Duplicate records removed | 20 |
| Clean records | 968 |
| Rejected records | 22 |
| Total Silver records | 990 |
| Reconciliation difference | 0 |

**Result:** Reconciliation successfully passed with a difference of zero.

---

## Dashboard Development

The Gold layer provides the datasets for an interactive Hospital Billing Analytics Dashboard using Databricks AI/BI.

The dashboard is organized into three main sections.

### Page 1: Overview

- Total Revenue
- Total Visits
- Total Bills
- Insurance Revenue
- Patient Payable Amount
- Monthly Revenue Trend
- Department-Wise Revenue
- Insurance vs Patient Payable Amount

### Page 2: Branch and Payer Analysis

- Revenue by Hospital Branch
- Revenue by City and Region
- Payer-Wise Total Revenue
- Insurance Amount by Payer
- Pending Amount by Payer

### Page 3: Data Quality

- Bronze Records
- Unique Bill IDs
- Duplicate Records
- Clean Records
- Rejected Records
- Reconciliation Difference
- Invalid Quantity Records
- Negative Price Records
- Missing Patient IDs
- Missing Department and Payer Records
- Missing Amount Records

The dashboard helps users understand hospital revenue, branch performance, payer contributions, and data quality.


## Project Structure


Hospital-Billing-Analytics/
│
├── README.md
│
├── data: hospital_billing.csv
│
├── bronze:  bronze_transformation.sql
│
├── silver: silver_transformation.sql
│
├── gold: G_transformation.sql
│
├── dashboard: dashboard_pdf



## Key Learnings

Through this project, I gained practical experience in:

- Understanding Medallion Architecture.
- Working with Unity Catalog, catalogs, schemas, and volumes.
- Loading raw CSV data into Databricks.
- Building ETL pipelines using Lakeflow Spark Declarative Pipelines.
- Writing SQL transformations using CTEs and window functions.
- Handling duplicate records and missing values.
- Separating clean and rejected records.
- Creating materialized views for analytical reporting.
- Performing data reconciliation.
- Building business-focused dashboards.


## Conclusion

This project demonstrates an end-to-end hospital billing data pipeline, starting from raw data ingestion and continuing through data cleaning, transformation, aggregation, and visualization.

By implementing the Bronze, Silver, and Gold layers, I gained hands-on experience in building structured data pipelines and converting raw billing records into meaningful business insights.

It also helped me understand how data engineering pipelines support business intelligence and data-driven decision-making.
