/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script defines the Gold layer views in our data warehouse. 
    - The Gold layer is where we transform raw data into a business-friendly format.
    - It simplifies reporting and makes data easier for analysts to work with.
    - We take cleaned and structured data from the Silver layer and turn it into
      dimensions and fact tables, following a Star Schema.

Usage:
    - These views will be used directly for dashboards, reports, and analytics.
===============================================================================
*/

-- =============================================================================
-- Creating the Customer Dimension Table (gold.dim_customers)
-- This view provides a clean, structured representation of customer data. 
-- A view is like a virtual table that doesn’t store data itself but organizes and presents data 
-- from multiple tables in a structured way, making it easier to query and analyze.
-- It assigns a surrogate key for easy joins and enriches data by combining 
-- information from multiple Silver tables.
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers; -- Drop the existing view to ensure a fresh creation
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, -- Generate a surrogate key for easier joins
    ci.cst_id                          AS customer_id, -- Retaining the original CRM customer ID
    ci.cst_key                         AS customer_number, -- Business-friendly identifier
    ci.cst_firstname                   AS first_name,
    ci.cst_lastname                    AS last_name,
    la.cntry                           AS country, -- Enriching customer data with location details
    ci.cst_marital_status              AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- Prioritize gender from CRM if available
        ELSE COALESCE(ca.gen, 'n/a')  			   -- Otherwise, fallback to ERP data
    END                                AS gender,
    ca.bdate                           AS birthdate, -- Capturing birthdate from ERP for analytics
    ci.cst_create_date                 AS create_date -- Tracking when the customer was created in CRM
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid -- Bringing in additional customer attributes from ERP
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid; -- Adding country information for geographic analysis
GO

-- =============================================================================
-- Creating the Product Dimension Table (gold.dim_products)
-- This view structures product information in a way that makes it easy to analyze.
-- It assigns a surrogate key and enriches data by incorporating product category 
-- and other useful attributes from Silver tables.
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products; -- Drop the existing view before creating a new one
GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- Assign a unique key for each product
    pn.prd_id       AS product_id, -- Retaining the original product ID
    pn.prd_key      AS product_number, -- Business-friendly identifier for the product
    pn.prd_nm       AS product_name, -- Readable product name
    pn.cat_id       AS category_id, -- Reference to product category
    pc.cat          AS category, -- Enriching with category details from ERP
    pc.subcat       AS subcategory, -- Including subcategory for better classification
    pc.maintenance  AS maintenance, -- Maintenance flag (business-specific attribute)
    pn.prd_cost     AS cost, -- Storing product cost for cost analysis
    pn.prd_line     AS product_line, -- Categorizing products into business-defined product lines
    pn.prd_start_dt AS start_date -- Tracking when the product became available
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id -- Joining category details for additional context
WHERE pn.prd_end_dt IS NULL; -- Filtering out historical/inactive products
GO

-- =============================================================================
-- Creating the Sales Fact Table (gold.fact_sales)
-- This fact table consolidates sales transactions, linking them to products 
-- and customers via surrogate keys. It enables easy revenue, quantity, and 
-- pricing analysis while ensuring fast, optimized queries.
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales; -- Drop the existing fact table view before recreating
GO

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number, -- Storing the unique order number for tracking
    pr.product_key  AS product_key, -- Linking each sale to a product in dim_products
    cu.customer_key AS customer_key, -- Linking each sale to a customer in dim_customers
    sd.sls_order_dt AS order_date, -- Tracking when the order was placed
    sd.sls_ship_dt  AS shipping_date, -- Tracking when the order was shipped
    sd.sls_due_dt   AS due_date, -- Storing the expected delivery date for analysis
    sd.sls_sales    AS sales_amount, -- Recording revenue generated from each sale
    sd.sls_quantity AS quantity, -- Storing the number of products sold
    sd.sls_price    AS price -- Storing the price per unit at the time of sale
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number -- Ensuring each sale is linked to a valid product
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id; -- Ensuring each sale is linked to a valid customer
GO
