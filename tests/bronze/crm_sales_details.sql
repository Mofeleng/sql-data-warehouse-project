-- ===========================================
-- Sales Details Data Quality Checks (Bronze Layer)
-- This script validates the integrity of CRM sales data before transformation.
-- Checks performed:
-- 1. Whitespace in order numbers
-- 2. Referential integrity for product and customer keys
-- 3. Valid date formats, ranges, and logical order (order < ship < due)
-- 4. Accurate sales calculations (sales = quantity × price)
-- ===========================================

-- Check for empty spaces in order number
SELECT
	*
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- no empty spaces

--sls prd key and sls cust id are keys we use to connect to cust_info and prd_info tables, we have to validate that all sales exist in the respective customer and product ids
SELECT *
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)

-- All the products sold are in the product table, now customers:
SELECT *
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)

-- all the customers exist too

--Dates are stored numerically, we need to fix this. First we'll check for negative values:
SELECT * FROM bronze.crm_sales_details
WHERE sls_order_dt < 0

-- Now 0s
SELECT * FROM bronze.crm_sales_details
WHERE sls_order_dt BETWEEN -1 AND 100
ORDER BY sls_order_dt DESC
--Seems like we have no other non date numeric values just 0
--Make sure len of every other number is 8 (ddmmyyy) And within bounds (between 1990 and 2050)
SELECT * FROM bronze.crm_sales_details WHERE LEN(NULLIF(sls_order_dt, 0)) != 8 OR NULLIF(sls_order_dt, 0) > 20500101 OR NULLIF(sls_order_dt, 0) < 19900101
-- Only 2 of them

--Check that order date us always before ship date
SELECT * FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_ship_dt > sls_due_dt
--None are

--check if sales = quantity * price
SELECT DISTINCT 
sls_sales AS old_sales,
sls_quantity AS old_q,
sls_price AS old_price,
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
		 THEN (sls_quantity * sls_price)
	ELSE sls_sales
	END as sls_sales,
	CASE WHEN sls_price IS NULL OR sls_price <= 0
		 THEN (sls_sales/NULLIF(sls_quantity, 0))
	ELSE sls_price
	END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != (sls_quantity * sls_price)
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <=0
