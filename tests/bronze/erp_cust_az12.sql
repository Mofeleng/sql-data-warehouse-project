/*===================================
Customer Data Validation & Cleanup
===================================
Purpose:
Perform data validation and cleanup on customer-related fields in the `bronze.erp_cust_az12` table, focusing on ID consistency, date range validation, and gender standardization.

Reason:
To ensure that the customer data can be reliably used for further processing, analytics, and CRM systems, while addressing specific issues such as incorrect date ranges and inconsistent gender formatting.

Any other useful info:
- Checked that customer IDs could function as primary keys in `crm_cust_info`, and identified the need to remove "NAS" prefixes from certain records.
- Validated birthdates to ensure they are within reasonable bounds (e.g., no future dates).
- Standardized gender values, ensuring consistent categorization of "Female" and "Male" entries, while handling unspecified or inconsistent values as "n/a".
- Birthdates over 100 years old will be retained for now, pending further business rules.
--------------------------------------------------------------*/

--- Check that ids work as real primary keys for the crm_cust_table
SELECT * FROM silver.crm_cust_info;
SELECT cid FROM bronze.erp_cust_az12;

-- some of the er[_cust info have "NAS" as a prefix, we need to remove them


--- Check for dates that are out of bounds
SELECT bdate
FROM bronze.erp_cust_az12
WHERE bdate > GETDATE();
-- We will keep users over a 100 as we have not been told how to handle them
-- Dates > current date will be nullified

--Check all possible gender values
SELECT DISTINCT gen FROM bronze.erp_cust_az12;
-- 6 different types

SELECT DISTINCT gen,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		 ELSE 'n/a'
	END as gen
FROM bronze.erp_cust_az12;
