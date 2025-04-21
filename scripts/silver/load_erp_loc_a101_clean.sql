/*===================================
Insert Cleaned Location Data into Silver Layer
===================================
Purpose:
Transform and insert standardized location data from `bronze.erp_loc_a101` into `silver.erp_loc_a101`.

Reason:
- `cid` values had inconsistent formats (e.g., dashes) and were cleaned to ensure compatibility with CRM table keys.
- Country names were normalized to remove redundancy (e.g., "US", "USA" → "United States"; "DE" → "Germany").
- Empty or null country fields were replaced with "n/a" to maintain data integrity.

Any other useful info:
- This cleaned data enables more reliable joins, foreign key relationships, and geographic analytics across the silver layer.
--------------------------------------------------------------*/
INSERT INTO silver.erp_loc_a101 (
	cid,
	cntry
)

SELECT
	REPLACE(cid, '-', '') AS cid,
	CASE WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United States'
		 WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		 WHEN cntry = '' OR cntry IS NULL THEN 'n/a'
		 ELSE TRIM(cntry)
	END AS cntry
FROM bronze.erp_loc_a101
