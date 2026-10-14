
/*
===============================================================
DDL Script: Create Bronze Tables
===============================================================
Script Purpose:
This script creates tables in the 'bronze' schema, dropping existing tables if they already exist.
Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================
*/
IF OBJECT_ID('bronze.crm_cust_info','U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info(
cst_id INT,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(50),
cst_lastname NVARCHAR(50),
cst_marital_status NVARCHAR(50),
cst_gndr NVARCHAR(50),
cst_create_date DATE
);

CREATE TABLE bronze.crm_prd_info(
prd_id INT,
prd_key NVARCHAR(20),
prd_nm NVARCHAR(20),
prd_cost INT,
prd_line NVARCHAR(10),
prd_start_dt DATETIME,
prd_end_dt DATETIME
);


CREATE TABLE bronze.crm_sales_details(
sls_ord_num NVARCHAR(10),
sls_prd_key NVARCHAR(10),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT,
sls_due_dt INT,
sls_sales INT,
sls_quantity INT,
sls_price INT
);


CREATE TABLE bronze.erp_cust_az12(
cid NVARCHAR(10),
bdate DATE,
gen NVARCHAR(10)
);

CREATE TABLE bronze.erp_loc_a101(
cid NVARCHAR(10),
cntry NVARCHAR(10)
);

CREATE TABLE bronze.erp_px(
id NVARCHAR(10),
cat NVARCHAR(10),
subcat NVARCHAR(10),
maintenance NVARCHAR(10)
);

ALTER TABLE bronze.crm_prd_info
ALTER COLUMN prd_nm NVARCHAR(50);

ALTER TABLE bronze.erp_cust_az12
ALTER COLUMN cid NVARCHAR(20);

ALTER TABLE bronze.erp_loc_a101
ALTER COLUMN cntry NVARCHAR(20);

EXEC sp_rename 'bronze.[bronze.erp_px_cat_g1v2]', 'erp_px_cat_g1v2';

ALTER TABLE bronze.erp_px_cat_g1v2
ALTER COLUMN subcat NVARCHAR(20);


