/*
=================================================================================
Description:
This script defines three SQL views in the "gold" schema, forming a star schema 
dimensional model for a sales data warehouse. The views are built on top of 
cleansed and enriched data from the "silver" layer and are intended for use in 
analytics and reporting tools such as Power BI or Tableau.

1. gold.dim_customers:
   - Builds a customer dimension view with surrogate keys.
   - Joins CRM and ERP sources to enrich data with demographic details (e.g., gender, birthdate, marital status, country).
   - Applies logic to fill missing gender values using secondary source.

2. gold.dim_products:
   - Constructs a product dimension view, also using surrogate keys.
   - Joins product info with category and subcategory details.
   - Filters out historical (discontinued) products to maintain a clean product catalog.

3. gold.fact_sales:
   - Creates the central fact table to store individual sales transactions.
   - Links each transaction to the corresponding customer and product dimension using business keys.
   - Includes financial and logistical metrics: sales amount, quantity, price, order/due/ship dates.

These views are structured for optimal performance in analytical queries, 
supporting star-schema-based BI dashboards and ad hoc reporting.
=================================================================================
*/

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS 
SELECT 
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
		la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		 ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid;
GO
  
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
DROP VIEW gold.dim_products;
GO
CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
		ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL; -- Filter out all historical data
GO
  
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
DROP VIEW gold.fact_sales;
GO
CREATE VIEW gold.fact_sales AS
SELECT
	sd.sls_ord_num AS order_number,
	pr.product_key,
	cr.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr
	 ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers AS cr
	 ON sd.sls_cust_id = cr.customer_id;
