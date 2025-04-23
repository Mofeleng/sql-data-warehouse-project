/*===================================
Standardized Data Insertion into Silver Layer
===================================
Purpose: 
Insert cleaned and standardized data from the `bronze.erp_px_cat_g1v2` table into the `silver.erp_px_cat_g1v2` table.

Reason: 
Ensure that all string values in `cat`, `subcat`, and `maintenance` fields are free from leading or trailing whitespaces before storing in the curated silver layer.

Any other useful info:
- `TRIM()` is applied during selection to guarantee consistency and prevent future data quality issues.
- Supports downstream processes by maintaining clean, reliable, and standardized data across layers.

--------------------------------------------------------------*/

INSERT INTO silver.erp_px_cat_g1v2 (
	id,
	cat,
	subcat,
	maintenance
)

SELECT
	id,
	TRIM(cat) AS cat,
	TRIM(subcat) AS subcat,
	TRIM(maintenance) AS maintenance
FROM bronze.erp_px_cat_g1v2
