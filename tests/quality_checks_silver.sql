/*
Quality Checks in silver Layer
This script performs quality checks for data consistency, accuracy and
standardization across the silver schemas.
checks include:
- Null or duplicate primary keys
- unwanted spaces in string fields
- data standardization and consistency
- invalid date ranges and orders
- data consistency between related fields
*/


-- ## 1) Checking crm_cust_info 
-- checking nulls or duplicates in primary key
SELECT 
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*)>1 OR cst_id IS NULL;

--check for unwanted spaces
SELECT cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Data Standardization & Consistency 
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;


-- ## 2) Checking crm_prd_info 
-- checking nulls or duplicates in primary key
SELECT
prd_id,
Count(*)                              
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*)>1 OR prd_id IS NULL;

-- check for unwanted spaces
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm!=TRIM(prd_nm);

-- check for nulls or negative numbers
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost<0 OR prd_cost IS NULL;

-- data standardization & consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- check for invalid date orders
select *
from silver.crm_prd_info
where prd_end_dt<prd_start_dt;


-- ## 3) Checking crm_sales_details
--checking unwanted spaces in col1
SELECT
sls_ord_num
FROM silver.crm_sales_details
WHERE (sls_ord_num)!=TRIM(sls_ord_num);

-- check for invalid dates(zeros, invalid lengths,outliers)
SELECT
NULLIF(sls_order_dt,0) AS sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt<=0
OR LEN(sls_order_dt)!=8
OR sls_order_dt>20200101
OR sls_order_dt<19000101;


SELECT *
FROM silver.crm_sales_details
WHERE sls_ship_dt<sls_order_dt OR sls_due_dt<sls_order_dt;

-- checking data consistency: between sales, quantity, and price
-- sales=quantity*price
-- values must not be null, zero or negative
select distinct
sls_sales,
sls_quantity,
sls_price,
FROM bronze.crm_sales_details
WHERE sls_sales!=sls_quantity*sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales,sls_quantity,sls_price;

-- ## 4) Checking erp_cust_az12
-- identify out of range dates
SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE bdate<'1924-01-01' OR bdate> GETDATE();

-- data standardization & Consistency
SELECT DISTINCT gen
FROM silver.erp_cust_az12;


-- ## 5) Checking bronze.erp_loc_a101
-- data standardization & Consistency
select distinct
cntry
from silver.erp_loc_a101
order by cntry;

-- ## 6) Checking bronze.erp_px_cat_g1v2
-- check for unwanted spaces
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat!=TRIM(cat) OR subcat!=TRIM(subcat) OR maintenance!=TRIM(maintenance);

-- data standardization & Consistency
SELECT DISTINCT
maintenance
FROM silver.erp_px_cat_g1v2;
