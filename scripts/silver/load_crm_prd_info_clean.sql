=============================================
-- SCRIPT: Silver Layer Load - crm_prd_info
-- PURPOSE:
--   This script transforms and loads cleaned product data from
--   bronze.crm_prd_info into silver.crm_prd_info.
--
-- TRANSFORMATIONS:
--   - Derives cat_id from first 5 characters of prd_key
--   - Trims product names and standardizes product lines
--   - Sets NULL costs to 0 as per business instruction
--   - Extracts clean product key for linking to sales_details
--   - Ensures date consistency:
--       - prd_start_dt is cast to DATE
--       - prd_end_dt is calculated using LEAD window function
--
-- NOTES:
--   - Transformation is based on category integration model
--   - Only valid, cleaned records are loaded into silver
-- =============================================
  
INSERT INTO silver.crm_prd_info (
	prd_id,
	prd_key,
	cat_id,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)
SELECT 
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key, -- used in sales_details
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,
	CASE UPPER(TRIM(prd_line))
		 WHEN 'M' THEN 'Mountain'
		 WHEN 'R' THEN 'Road'
		 WHEN 'S' THEN 'Other Sales'
		 WHEN 'T' THEN 'Touring'
		 ELSE 'n/a'
	END AS prd_line,
	CAST (prd_start_dt AS DATE) AS prd_start_dt,
	CAST (LEAD (prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info

SELECT * FROM silver.crm_prd_info
