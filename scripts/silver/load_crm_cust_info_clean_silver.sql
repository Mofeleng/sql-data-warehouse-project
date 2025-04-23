-- =============================================
-- SCRIPT: Load Cleaned CRM Customer Data into Silver Layer
-- PURPOSE:
--   This script inserts standardized and deduplicated customer records
--   into the silver.crm_cust_info table from the bronze layer.
--
-- TRANSFORMATIONS:
--   - Trim whitespace from first and last names
--   - Standardize gender (F → Female, M → Male, else → n/a)
--   - Standardize marital status (M → Married, S → Single, else → n/a)
--   - Deduplicate by cst_id, keeping the most recent record
--   - Exclude records with NULL customer IDs
-- =============================================
---Truncate data before load
TRUNCATE TABLE silver.crm_cust_info;
---Standardized and cleaned data
INSERT INTO silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	 cst_create_date
)
SELECT
	   cst_id,
	   cst_key,
       TRIM(cst_firstname) AS firstname,
       TRIM(cst_lastname) AS lastname,
	   CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			ELSE 'n/a'
		END AS cst_gndr,
		CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			 WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			 ELSE 'n/a'
		END AS cst_marital_status,
       cst_create_date
FROM (
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM bronze.crm_cust_info
) AS t
WHERE flag_last = 1 AND cst_id IS NOT NULL
