/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
    Run this script to re-define the DDL structure of 'silver' Tables, which
    contain cleaned and transformed data.
===============================================================================
*/

-- Check if the 'crm_cust_info' table exists in the silver schema and drop it if it does
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO

-- Create the 'crm_cust_info' table in the silver schema with cleaned and standardized data
CREATE TABLE silver.crm_cust_info (
    cst_id             INT,  -- Customer ID
    cst_key            NVARCHAR(50),  -- Customer key
    cst_firstname      NVARCHAR(50),  -- Customer first name
    cst_lastname       NVARCHAR(50),  -- Customer last name
    cst_marital_status NVARCHAR(50),  -- Marital status
    cst_gndr           NVARCHAR(50),  -- Gender
    cst_create_date    DATE,  -- Original creation date
    dwh_create_date    DATETIME2 DEFAULT GETDATE()  -- Data warehouse creation date (automatically populated)
);
GO

-- Check if the 'crm_prd_info' table exists in the silver schema and drop it if it does
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

-- Create the 'crm_prd_info' table in the silver schema with cleaned and transformed product data
CREATE TABLE silver.crm_prd_info (
    prd_id          INT,  -- Product ID
    cat_id          NVARCHAR(50),  -- Category ID
    prd_key         NVARCHAR(50),  -- Product key
    prd_nm          NVARCHAR(50),  -- Product name
    prd_cost        INT,  -- Product cost
    prd_line        NVARCHAR(50),  -- Product line
    prd_start_dt    DATE,  -- Product start date
    prd_end_dt      DATE,  -- Product end date
    dwh_create_date DATETIME2 DEFAULT GETDATE()  -- Data warehouse creation date (automatically populated)
);
GO

-- Check if the 'crm_sales_details' table exists in the silver schema and drop it if it does
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

-- Create the 'crm_sales_details' table in the silver schema with cleaned and standardized sales data
CREATE TABLE silver.crm_sales_details (
    sls_ord_num     NVARCHAR(50),  -- Sales order number
    sls_prd_key     NVARCHAR(50),  -- Sales product key
    sls_cust_id     INT,  -- Sales customer ID
    sls_order_dt    DATE,  -- Sales order date
    sls_ship_dt     DATE,  -- Sales ship date
    sls_due_dt      DATE,  -- Sales due date
    sls_sales       INT,  -- Sales amount
    sls_quantity    INT,  -- Sales quantity
    sls_price       INT,  -- Sales price
    dwh_create_date DATETIME2 DEFAULT GETDATE()  -- Data warehouse creation date (automatically populated)
);
GO

-- Check if the 'erp_loc_a101' table exists in the silver schema and drop it if it does
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

-- Create the 'erp_loc_a101' table in the silver schema with cleaned location data
CREATE TABLE silver.erp_loc_a101 (
    cid             NVARCHAR(50),  -- Location ID
    cntry           NVARCHAR(50),  -- Country
    dwh_create_date DATETIME2 DEFAULT GETDATE()  -- Data warehouse creation date (automatically populated)
);
GO

-- Check if the 'erp_cust_az12' table exists in the silver schema and drop it if it does
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

-- Create the 'erp_cust_az12' table in the silver schema with cleaned customer data
CREATE TABLE silver.erp_cust_az12 (
    cid             NVARCHAR(50),  -- Customer ID
    bdate           DATE,  -- Birthdate
    gen             NVARCHAR(50),  -- Gender
    dwh_create_date DATETIME2 DEFAULT GETDATE()  -- Data warehouse creation date (automatically populated)
);
GO

-- Check if the 'erp_px_cat_g1v2' table exists in the silver schema and drop it if it does
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

-- Create the 'erp_px_cat_g1v2' table in the silver schema with cleaned product category data
CREATE TABLE silver.erp_px_cat_g1v2 (
    id              NVARCHAR(50),  -- Category ID
    cat             NVARCHAR(50),  -- Category name
    subcat          NVARCHAR(50),  -- Subcategory name
    maintenance     NVARCHAR(50),  -- Maintenance status
    dwh_create_date DATETIME2 DEFAULT GETDATE()  -- Data warehouse creation date (automatically populated)
);
GO
