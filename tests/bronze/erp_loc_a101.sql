/*===================================
Location Data Standardization & Validation
===================================
Purpose:
Ensure customer location data in `bronze.erp_loc_a101` is clean, standardized, and consistent for integration into the `silver.crm_cust_info` table.

Reason:
The `cid` field must align in format and length with the `cst_key` field in the CRM table to function reliably as a foreign key. Additionally, inconsistent country naming can hinder accurate aggregation and analysis.

Any other useful info:
- Validated that `cid` entries differ in length and include dashes that need removal.
- Country values show cardinality issues (e.g., "USA", "United States", "US" all refer to the same country), requiring normalization for accurate geographic analysis.
- Standardization will support cleaner joins and more accurate country-based reporting.
--------------------------------------------------------------*/
--checking if all the ids follow the same format
-- Checking to see if the length for all of them is the same
SELECT DISTINCT LEN(cid) FROM bronze.erp_loc_a101;

--The ids will be used as keys for crm_cust_info so they need to have the same format as cst_key
SELECT cst_key FROM silver.crm_cust_info
SELECT cid FROM bronze.erp_loc_a101;
-- The cids all have a dash which we will need to remove it

-- Cardinarlity of countries
SELECT DISTINCT cntry FROM
bronze.erp_loc_a101;
-- We have redundant countries, United States shows up as USA, United States, US and Germany as DE and Germany, we will need to standardize this.
