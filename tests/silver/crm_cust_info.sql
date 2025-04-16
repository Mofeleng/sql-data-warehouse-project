-- =============================================
-- SCRIPT: Silver Layer CRM Data Validation Checks
-- PURPOSE:
--   This script verifies data quality in the silver.crm_cust_info table
--   after the ETL load from the bronze layer.
--
-- CHECKS:
--   - No duplicate or NULL customer IDs (cst_id)
--   - No leading/trailing whitespace in string fields
--   - Gender and marital status are standardized correctly
--
-- EXPECTATIONS:
--   - All queries should return 0 rows (no data quality issues)
-- =============================================

---Check for duplicates
--- Expectations: None
SELECT 
cst_id,
COUNT(*) AS duplicates
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

--- Check for unwanted spaces in strings
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

--- Check for Data Standardization and normalisation
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info
