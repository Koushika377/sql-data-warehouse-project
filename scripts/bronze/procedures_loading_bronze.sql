/*
Stored Procedure: Loads the Bronze Layer from Source
  This script loads data into the bronze schema from external CSV files.
  - Truncates the bronze tables before loading data
  - Uses 'BULK INSERT' to load data from the CSV files

Changes to the Data: 
  This procedure first loads the date column in crm_cust_info 
  in NVARCHAR datatype then changes it into 'DATE' format
  and
  loads the date columns in crm_prd_info 
  in NVARCHAR datatype then changes them into 'DATETIME' format
  (The format in the dataset is different from the final goal)

Parameters: None(doesn't accept or return any values)

Usage Example: 
  EXEC bronze.load_bronze;
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
DECLARE @start_time DATETIME,@end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;
BEGIN TRY
    SET @batch_start_time=GETDATE();
    PRINT '=============================================================';
    PRINT 'Loading Bronze Layer';
    PRINT '=============================================================';
    
    PRINT '-------------------------------------------------------------';
    PRINT 'Loading CRM Tables';
    PRINT '-------------------------------------------------------------';
--#1
SET @start_time=GETDATE();
ALTER TABLE bronze.crm_cust_info
ALTER COLUMN cst_create_date NVARCHAR(50);

PRINT '>> Truncating Table: bronze.crm_cust_info';
TRUNCATE TABLE bronze.crm_cust_info;

PRINT '>> Inserting Data Into: bronze.crm_cust_info';
BULK INSERT bronze.crm_cust_info
FROM 'C:\Users\koush\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
WITH (
	FIRSTROW =2,
	FIELDTERMINATOR =',',
	TABLOCK
);

UPDATE bronze.crm_cust_info
SET cst_create_date = 
    CONVERT(VARCHAR(10), TRY_CONVERT(DATE, cst_create_date, 105), 23);

ALTER TABLE bronze.crm_cust_info
ALTER COLUMN cst_create_date DATE;

SET @end_time=GETDATE();
PRINT '>> Load Duration:  '+CAST (DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+' seconds'
PRINT '>> ----------------'
--#2
SET @start_time=GETDATE();

ALTER TABLE bronze.crm_prd_info
ALTER COLUMN prd_start_dt NVARCHAR(50);

ALTER TABLE bronze.crm_prd_info
ALTER COLUMN prd_end_dt NVARCHAR(50);
PRINT '>> Truncating Table: bronze.crm_prd_info';
TRUNCATE TABLE bronze.crm_prd_info;

PRINT '>> Inserting Data Into: bronze.crm_prd_info';
BULK INSERT bronze.crm_prd_info
FROM 'C:\Users\koush\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
WITH (
	FIRSTROW =2,
	FIELDTERMINATOR =',',
	TABLOCK
)

    UPDATE bronze.crm_prd_info
    SET
        prd_start_dt = CONVERT( VARCHAR(10),TRY_CONVERT(DATETIME, prd_start_dt, 105),23),
        prd_end_dt = CONVERT(VARCHAR(10),TRY_CONVERT(DATETIME, prd_end_dt, 105),23 );   
 
    ALTER TABLE bronze.crm_prd_info
    ALTER COLUMN prd_start_dt DATETIME;

    ALTER TABLE bronze.crm_prd_info
    ALTER COLUMN prd_end_dt DATETIME;
SET @end_time=GETDATE();
PRINT '>> Load Duration:  '+CAST (DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+' seconds'
PRINT '>> ----------------'


-- #3
SET @start_time=GETDATE();

PRINT '>> Truncating Table: bronze.crm_sales_details';
TRUNCATE TABLE bronze.crm_sales_details;

PRINT '>> Inserting Data Into: bronze.crm_sales_details';
BULK INSERT bronze.crm_sales_details
FROM 'C:\Users\koush\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
WITH (
	FIRSTROW =2,
	FIELDTERMINATOR =',',
	TABLOCK
)
SET @end_time=GETDATE();
PRINT '>> Load Duration:  '+CAST (DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+' seconds'
PRINT '>> ----------------'

PRINT '-------------------------------------------------------------';
PRINT 'Loading ERP Tables';
PRINT '-------------------------------------------------------------';

-- #4
SET @start_time=GETDATE();

PRINT '>> Truncating Table: bronze.erp_cust_az12';
TRUNCATE TABLE bronze.erp_cust_az12;
PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
BULK INSERT bronze.erp_cust_az12
FROM 'C:\Users\koush\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\cust_az12.csv'
WITH (
	FIRSTROW =2,
	FIELDTERMINATOR =',',
	TABLOCK
)
SET @end_time=GETDATE();
PRINT '>> Load Duration:  '+CAST (DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+' seconds'
PRINT '>> ----------------'


-- #5
SET @start_time=GETDATE();

PRINT '>> Truncating Table: bronze.erp_loc_a101';
TRUNCATE TABLE bronze.erp_loc_a101;
PRINT '>> Inserting Data Into: bronze.erp_loc_a101';

BULK INSERT bronze.erp_loc_a101
FROM 'C:\Users\koush\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\loc_a101.csv'
WITH (
	FIRSTROW =2,
	FIELDTERMINATOR =',',
	TABLOCK
)
SET @end_time=GETDATE();
PRINT '>> Load Duration:  '+CAST (DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+' seconds'
PRINT '>> ----------------'


-- #6
SET @start_time=GETDATE();

PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
TRUNCATE TABLE bronze.erp_px_cat_g1v2;
PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';

BULK INSERT bronze.erp_px_cat_g1v2
FROM 'C:\Users\koush\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\px_cat_g1v2.csv'
WITH (
	FIRSTROW =2,
	FIELDTERMINATOR =',',
	TABLOCK
);
SET @end_time=GETDATE();
PRINT '>> Load Duration:  '+CAST (DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+' seconds'
PRINT '>> ----------------'

SET @batch_end_time=GETDATE();
    PRINT '================================================================'
    PRINT 'Loading Bronze Layer is complete';
    PRINT '    -Total Load Duration:  '+ CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR) +'  seconds';

END TRY
BEGIN CATCH
    PRINT '================================================================'
    PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
    PRINT 'Error Message' + ERROR_MESSAGE();
    PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
    PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
    PRINT '================================================================'
END CATCH
END
