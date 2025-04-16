-- =======================================================
-- Load Cleaned Sales Data into Silver Layer (crm_sales_details)
-- This script transforms and loads validated CRM sales data.
-- Transformations applied:
-- 1. Date columns: Convert 8-digit integers (YYYYMMDD) to DATE, replace 0s or malformed with NULL
-- 2. Price correction: Replace missing or invalid prices with derived price (sales ÷ quantity)
-- 3. Sales correction: Ensure sales = quantity × price if original value is null, <= 0, or incorrect
-- 4. No changes made to quantity or keys (assumed validated in bronze checks)
-- =======================================================

INSERT INTO silver.crm_sales_details (
sls_ord_num,
	sls_prd_key ,
	sls_cust_id ,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_price,
	sls_quantity,
	sls_sales

)
	SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
		 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,
	CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS sls_ship_dt,
	CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
		 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
	CASE WHEN sls_price IS NULL OR sls_price <= 0
		 THEN (sls_sales/NULLIF(sls_quantity, 0))
	ELSE sls_price
	END AS sls_price,
	sls_quantity,
	CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
		 THEN (sls_quantity * sls_price)
	ELSE sls_sales
	END as sls_sales
FROM bronze.crm_sales_details;


