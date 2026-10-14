/*
===============================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================
Script Purpose:
	This stored procedure loads data into the 'bronze' schema from external CSV files.
	It performs the following actions:
	- Truncates the bronze tables before loading data.
	- Uses the BULK INSERT command to load data from csv Files to bronze tables.

Parameters:
	None.
This stored procedure does not accept any parameters or return any values.
Usage Example:
EXEC bronze.load_bronze;
===============================================================
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	SET @batch_start_time = GETDATE();
	BEGIN TRY
		PRINT '+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-';
		PRINT '				Loading Bronze Layer';
		PRINT '+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-';

		PRINT '======================================';
		PRINT 'Loading CRM Tables';
		PRINT '======================================';

		SET @start_time = GETDATE();
		PRINT '>> truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> inserting Data into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM "E:\DATA ENGINEER\Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv"
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT '>> load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> --------------'
		---------------------------------------
		SET @start_time = GETDATE();
		PRINT '>> truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> inserting Data into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM "E:\DATA ENGINEER\Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv"
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> --------------'
		---------------------------------------
		/*

		The error Maximum length is 128 occurs in SQL Server because the file path string is wrapped in double quotes (") 
		instead of single quotes ('). [1]
		In SQL Server, when the setting QUOTED_IDENTIFIER is turned ON (which is the default),
		text wrapped in double quotes is interpreted as an object identifier (like a table or column name)
		rather than a string literal. Since SQL Server object names are strictly capped at 128 characters, 
		treating a long file path as a table/column name throws this exact erro

		*/
		----------------------------------------------
		SET @start_time = GETDATE();
		PRINT '>> truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> inserting Data into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'E:\DATA ENGINEER\Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> --------------'
		---------------------------------------

		PRINT '======================================';
		PRINT 'Loading ERP Tables';
		PRINT '======================================';
	
		SET @start_time = GETDATE();
		PRINT '>> truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> inserting Data into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'E:\DATA ENGINEER\Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> --------------'
		---------------------------------------
		SET @start_time = GETDATE();
		PRINT '>> truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> inserting Data into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'E:\DATA ENGINEER\Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> --------------'
		---------------------------------------
		SET @start_time = GETDATE();
		PRINT '>> truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> inserting Data into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'E:\DATA ENGINEER\Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> --------------'
		SET @batch_end_time = GETDATE();
		PRINT '==============================================';
		PRINT 'Loading Bronze Layer is Completed';
		PRINT '	- Total Load Duration:' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '==============================================';
	END TRY
	BEGIN CATCH
		PRINT '----------------------------------------------';
		PRINT 'Error Occured During Loading Bronze Layer';
		PRINT 'Error Message:' + ERROR_MESSAGE();
		PRINT 'Error Message:' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message:' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '----------------------------------------------';
	END CATCH
END


exec bronze.load_bronze

