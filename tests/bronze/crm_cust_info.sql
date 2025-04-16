-- =============================================
-- SCRIPT: Bronze Layer Data Profiling (CRM Customer Info)
-- PURPOSE:
--   Perform basic data quality checks and profiling on the CRM customer data 
--   in the Bronze Layer. This includes:
--     - Detecting nulls or duplicates in the primary key (cst_id)
--     - Identifying leading/trailing spaces in string fields
--     - Reviewing values in categorical columns for standardization
--
-- EXPECTATION:
--   - No duplicate or null cst_id values
--   - No string fields with extra spaces
--   - Controlled and standardized values for gender and marital status
-- =============================================

--- Check for nulls or duplicates in the primary key
-- Expectations: no results
SELECT 
cst_id,
COUNT(*) AS duplicates
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

--- Check for unwanted spaces in strings
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

--- Data Standardization and normalisation
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info

SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info
