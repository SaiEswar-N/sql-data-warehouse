# 🏗️ Modern SQL Data Warehouse — Medallion Architecture on SQL Server

Built an end-to-end data warehouse in **SQL Server** that consolidates sales data from two disconnected source systems (**CRM** and **ERP**) into a single, clean, analytics-ready **star schema**, using the **Medallion Architecture (Bronze → Silver → Gold)**.

Think of it like a kitchen. The source systems are the suppliers dropping off raw ingredients. The Bronze, Silver and Gold layers are the prep stations where the ingredients are stored, cleaned and plated. The final star schema is the dish, ready to serve the moment a report or query orders it.

---

## 📌 Project Overview

| | |
|---|---|
| **Goal** | Consolidate CRM + ERP sales data, fix poor source data quality, and expose one user-friendly model for analytics |
| **Platform** | Microsoft SQL Server Express + SQL Server Management Studio (SSMS) |
| **Sources** | 6 CSV flat files (3 CRM, 3 ERP) |
| **Architecture** | Medallion (Bronze → Silver → Gold) |
| **Data Model** | Star Schema (1 fact + 2 dimensions) |
| **Load Strategy** | Full load (truncate & insert) through stored procedures |
| **Scope** | Latest-state data only (SCD Type 1), no historization in Gold |

---

## 🧱 Architecture

```
 SOURCES              BRONZE                SILVER                  GOLD
 (CSV files)          (Raw)                 (Clean)                 (Business-ready)

 CRM  ───────►  Physical tables  ───►  Physical tables  ───►  Virtual views
 ERP  ───────►  as-is, no changes      cleansed + standardized  star schema (dim / fact)
                Full load              Full load                No load needed
```

| Attribute | 🥉 Bronze | 🥈 Silver | 🥇 Gold |
|---|---|---|---|
| **Objective** | Store raw data exactly as-is for traceability and debugging | Clean, standardized, enriched data | Business-ready, integrated data for BI |
| **Object type** | Tables | Tables | Views |
| **Load method** | Truncate & insert | Truncate & insert | None (views run dynamically) |
| **Transformations** | None | Cleansing, trimming, type casting, normalization, derived columns | Business rules, integration, aggregation |
| **Data model** | Mirrors source 1:1 | Mirrors source 1:1 | Star schema |
| **Audience** | Data Engineers | Data Engineers, Analysts | Analysts, Business users, BI tools |

### Separation of Concerns
Each layer does one job and nothing else:
- Ingestion never skips a layer (no raw data straight into Silver or Gold).
- Silver cleans and standardizes but does not apply business rules.
- Gold applies business rules and integration but does not redo basic cleansing.

---

## 📂 Source Systems

| System | Files |
|---|---|
| **CRM** | `cust_info.csv`, `prd_info.csv`, `sales_details.csv` |
| **ERP** | `cust_az12.csv`, `loc_a101.csv`, `px_cat_g1v2.csv` |

---

## ⚙️ What Each Layer Does

### 🥉 Bronze: Ingestion
- `bronze.load_bronze` stored procedure truncates each table and runs `BULK INSERT` from the CSVs.
- Wrapped in `TRY...CATCH` with error number, message and state logging.
- Tracks load duration per table and for the whole batch.
- Validated by comparing source CSV row counts against table counts, and checking for column misalignment.

### 🥈 Silver: Cleansing and Standardization
Data quality issues found in the sources and how they were fixed:

| Source | Issue | Fix |
|---|---|---|
| CRM `cust_info` | Duplicate customer IDs, extra spaces, coded values (`M`/`F`, `S`/`M`) | `ROW_NUMBER()` to keep the latest record, `TRIM()`, map codes to readable values, nulls to `n/a` |
| CRM `prd_info` | Composite keys, missing costs, abbreviated product lines, overlapping dates | `SUBSTRING()` to split category ID and product key, `ISNULL()`, product line mapping, `LEAD()` to rebuild end dates |
| CRM `sales_details` | Dates stored as integers (`YYYYMMDD`), zero or invalid dates, sales ≠ quantity × price | Safe date casting, invalid dates to `NULL`, recalculate sales and price |
| ERP `cust_az12` | `NAS` key prefix, future birthdates, inconsistent gender values | Strip the prefix, future birthdates to `NULL`, standardize gender |
| ERP `loc_a101` | Hyphens in keys, inconsistent country codes (`DE`, `US`, `USA`) | `REPLACE()`, map to full country names, nulls to `n/a` |
| ERP `px_cat_g1v2` | No quality issues | Straight pass-through |

Silver tables also carry a technical metadata column (`dw_create_date`) for audit.

### 🥇 Gold: Dimensional Modeling (Star Schema)

```
 gold.dim_customers ──┐
                      ├──►  gold.fact_sales
 gold.dim_products  ──┘
```

- **`gold.dim_customers`** integrates CRM customer data with ERP birthdate and location. CRM is treated as the master source for gender, and ERP is used as the fallback.
- **`gold.dim_products`** joins CRM products with ERP categories and keeps only the active records.
- **`gold.fact_sales`** looks up the surrogate keys from both dimensions and carries order, shipping and due dates plus sales, quantity and price.
- Surrogate keys are generated with `ROW_NUMBER()` so the model stays independent of source system key changes.
- Star schema chosen over snowflake for fewer joins and simpler querying.

---

## ✅ Data Quality and Testing

Quality checks live in the `tests/` folder and cover:
- Primary key uniqueness in the Silver and Gold dimensions
- Foreign key integrity between `fact_sales` and both dimensions (no orphan records)
- Business rule consistency (`sales = quantity × price`, no null or negative sales)

---

## 📖 Governance and Standards

- **Naming conventions:** `snake_case` throughout, English only, no reserved words.
  - Bronze and Silver tables: `<source_system>_<entity>` (e.g. `crm_cust_info`)
  - Gold views: `<category>_<entity>` (e.g. `dim_customers`, `fact_sales`)
  - Surrogate keys: `<entity>_key`
  - Technical columns: `dw_<name>`
  - Stored procedures: `load_<layer>`
- **Script headers:** every SQL script starts with a standard header (name, purpose, layer, parameters, warnings).
- **Data catalog:** column-level documentation for all Gold objects is in `documents/`.
- **Data lineage:** traced from source file to Bronze, Silver and Gold view.
- **Project planning:** work was split into Epics (Requirements, Architecture, Setup, Bronze, Silver, Gold) and then into tasks.

---

## 🗂️ Repository Structure

```
sql-data-warehouse-project/
├── data_sets/                  # Raw CSV source files (CRM / ERP)
├── documents/                  # Architecture diagrams, data catalog, data models
├── scripts/
│   ├── bronze/                 # ddl_bronze.sql, proc_load_bronze.sql
│   ├── silver/                 # ddl_silver.sql, proc_load_silver.sql
│   └── gold/                   # ddl_gold.sql
├── tests/
│   ├── quality_checks_silver.sql
│   └── quality_checks_gold.sql
└── README.md
```

---

## 🚀 How to Run

1. Install **SQL Server Express** and **SSMS**.
2. Clone this repo and place the CSV files from `data_sets/` at the path used in the Bronze load script (update the `BULK INSERT` file paths if yours differ).
3. Run the database setup script to create the `data_warehouse` database and the `bronze`, `silver` and `gold` schemas. **It drops and recreates the database if it already exists.**
4. Run the Bronze DDL, then `EXEC bronze.load_bronze;`
5. Run the Silver DDL, then `EXEC silver.load_silver;`
6. Create the Gold views from `scripts/gold/ddl_gold.sql`.
7. Run the scripts in `tests/` to validate the data.

---

## 🧰 Skills Demonstrated

`SQL Server` · `T-SQL` · `Data Warehousing` · `Medallion Architecture` · `ETL / ELT` · `Data Modeling (Star Schema)` · `Data Cleansing` · `Window Functions` · `Stored Procedures` · `Error Handling` · `Data Quality Testing` · `Data Lineage` · `Data Cataloging` · `Git`

---

## 🔭 Possible Next Steps

- Add incremental loads (merge/upsert) in place of full loads
- Add SCD Type 2 historization on the dimensions
- Orchestrate the Bronze → Silver → Gold runs with a scheduler
- Connect Power BI to the Gold layer for dashboards

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
