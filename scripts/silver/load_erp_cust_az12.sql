/*===================================
Transform and Insert Cleaned Customer Data
===================================
Purpose:
Insert standardized and cleaned customer data from `bronze.erp_cust_az12` into the `silver.erp_cust_az12` table.

Reason:
To ensure consistent formatting and valid values before progressing to the silver (refined) layer of the data pipeline.

Any other useful info:
- Removes the "NAS" prefix from customer IDs to ensure ID consistency across systems.
- Nullifies birthdates that are greater than the current date to handle invalid future dates.
- Standardizes gender entries to "Male", "Female", or "n/a" for easier reporting and analysis.
- This step promotes data integrity and prepares the dataset for downstream CRM or analytics use.
--------------------------------------------------------------*/

INSERT INTO silver.erp_cust_az12 (
	cid,
	bdate,
	gen
)
SELECT
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		 ELSE cid
	END cid,
	CASE WHEN bdate > GETDATE() THEN NULL
		ELSE bdate
	END as bdate,
	CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		 ELSE 'n/a'
	END as gen
FROM bronze.erp_cust_az12;

SELECT * FROM silver.erp_cust_az12;
