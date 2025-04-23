/*===================================
Data Quality Check and Standardization Summary
===================================
Purpose: 
Verify data cleanliness and confirm consistency in categorical fields within the `bronze.erp_px_cat_g1v2` table.

Reason:
Unwanted whitespace or inconsistent category labels can cause incorrect groupings, misleading aggregations, or failed joins in downstream processes.

Any other useful info:
- The first query checks for leading/trailing spaces in `cat`, `subcat`, and `maintenance`.
- Follow-up queries confirm the distinct values to ensure consistent formatting.
- Conclusion: No extra spaces found and categorical data is standardized.

--------------------------------------------------------------*/

-- Check for unwanted spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);
-- No unwanted spaces

-- Data standardization
SELECT DISTINCT
cat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT
subcat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT
maintenance
FROM bronze.erp_px_cat_g1v2;

-- The data is standardized
