-- =============================================
-- SCRIPT: Bronze Layer Validation - crm_prd_info
-- PURPOSE:
--   This script validates raw product data in bronze.crm_prd_info
--   before it is transformed and loaded into the silver layer.
--
-- CHECKS:
--   - No duplicate or NULL product IDs (prd_id)
--   - Product key transformation aligns with ERP category table
--   - No leading/trailing whitespace in product names
--   - Product costs are not negative or NULL (NULLs to be handled)
--   - Standardization of product lines
--   - Date validation (prd_end_dt should not precede prd_start_dt)
--
-- EXPECTATIONS:
--   - All queries should return 0 rows except known NULL prd_costs
-- =============================================

--- Check for duplicate IDs
--- Expectation: Null

SELECT prd_id,
COUNT(*) AS duplicates
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

--- Product key: While working on the intergration model we noticed that the first 5 chars are a key to the category id, So it would be wise to split it into 2 columns
SELECT REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id FROM bronze.crm_prd_info;
WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN (SELECT distinct id from bronze.erp_px_cat_g1v2);
--- To see if this is working we check to see if any of the modified cat ids are in the erp category table, only 1 is not so it means all the rest are, which means the transformation was a success

--Check for unwated spaces
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- no unwanted spaces
--- Check for - costs or null costs
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- ONLY NULL COSTS(Replace with 0 as per business instructions)

--Check for standardadisation and consistency
SELECT DISTINCT prd_line FROM bronze.crm_prd_info;

--- Check for invalid date orders
-- End dates that are after the start
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
