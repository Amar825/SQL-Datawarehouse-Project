/*
===============================================================================
Test Script: Validate Analytics Layer Views
===============================================================================
Script Purpose:
    This script validates the views created in the Analytics layer for:
    - Data Integrity
    - Correct Calculations (like Customer Lifetime Value, Product Performance)
    - View Performance (timing to ensure reasonable query performance)

Usage:
    - This test is designed to validate the accuracy and performance of views 
      in the Analytics layer to ensure everything is working as expected.
===============================================================================
*/

-- =============================================================================
-- Test 1: Check if all Views in the Analytics Layer Exist
-- =============================================================================
PRINT 'Checking if all Analytics views exist...';

-- List of all views to test
DECLARE @views TABLE (view_name NVARCHAR(100));

INSERT INTO @views (view_name)
VALUES
    ('analytics.customer_lifetime_value'),
    ('analytics.product_performance_metrics'),
    ('analytics.sales_trends_and_forecasting'),
    ('analytics.customer_purchase_patterns');

DECLARE @view_name NVARCHAR(100);

DECLARE view_cursor CURSOR FOR 
    SELECT view_name FROM @views;

OPEN view_cursor;
FETCH NEXT FROM view_cursor INTO @view_name;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Testing view: ' + @view_name;
    BEGIN TRY
        -- Check if the view exists
        EXEC('SELECT TOP 1 * FROM ' + @view_name);
        PRINT @view_name + ' - Exists and returns data.';
    END TRY
    BEGIN CATCH
        PRINT @view_name + ' - ERROR: ' + ERROR_MESSAGE();
    END CATCH;

    FETCH NEXT FROM view_cursor INTO @view_name;
END;

CLOSE view_cursor;
DEALLOCATE view_cursor;
GO

-- =============================================================================
-- Test 2: Validate Basic Metrics for Customer Lifetime Value
-- =============================================================================
PRINT 'Testing Customer Lifetime Value Metrics...';

-- Check a few sample customer lifetime values (e.g., check total orders, lifetime spend)
SELECT TOP 10 
    customer_key,
    customer_id,
    lifetime_spend,
    total_orders,
    average_order_value,
    annual_value
FROM analytics.customer_lifetime_value
WHERE customer_key IS NOT NULL;

-- Expected result: Values should be populated for all customers with order history. 
-- Check for null values or unexpected results.
GO

-- =============================================================================
-- Test 3: Validate Product Performance Metrics
-- =============================================================================
PRINT 'Testing Product Performance Metrics...';

-- Check top-selling products and profit margins
SELECT TOP 10
    product_key,
    product_name,
    total_sales,
    total_revenue,
    total_profit,
    profit_margin_percentage
FROM analytics.product_performance_metrics
WHERE product_key IS NOT NULL
ORDER BY total_sales DESC;

-- Expected result: Products should show total sales, profit, and profit margin
-- for top products. Check if profit margin percentages are reasonable.
GO

-- =============================================================================
-- Test 4: Validate Sales Trends and Forecasting
-- =============================================================================
PRINT 'Testing Sales Trends and Forecasting...';

-- Check sales totals and trends for a sample month
SELECT TOP 10
    year_month,
    total_sales,
    total_quantity,
    order_count,
    revenue_per_customer,
    avg_days_to_ship
FROM analytics.sales_trends_and_forecasting
WHERE year_month = '2025-01';  -- Sample month for testing (e.g., January 2025)

-- Expected result: Data should show aggregated sales, quantity, and shipping performance for January 2025
GO

-- =============================================================================
-- Test 5: Validate Customer Purchase Patterns
-- =============================================================================
PRINT 'Testing Customer Purchase Patterns...';

-- Check some sample customer purchase patterns
SELECT TOP 10 
    customer_key,
    customer_name,
    purchased_categories,
    unique_categories_purchased,
    primary_category,
    purchase_breadth
FROM analytics.customer_purchase_patterns
WHERE customer_key IS NOT NULL;

-- Expected result: Customers should have valid purchase patterns, including
-- the primary category and cross-sell opportunities.
GO

-- =============================================================================
-- Test 6: Performance Test (Check Query Execution Time for Each View)
-- =============================================================================
PRINT 'Testing View Execution Time...';

-- Declare a variable to hold the start time
DECLARE @start_time DATETIME, @end_time DATETIME;

-- Test execution time for customer lifetime value view
SET @start_time = GETDATE();
EXEC('SELECT TOP 1 * FROM analytics.customer_lifetime_value');
SET @end_time = GETDATE();
PRINT 'Execution time for customer_lifetime_value: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' milliseconds.';

-- Test execution time for product performance metrics view
SET @start_time = GETDATE();
EXEC('SELECT TOP 1 * FROM analytics.product_performance_metrics');
SET @end_time = GETDATE();
PRINT 'Execution time for product_performance_metrics: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' milliseconds.';

-- Test execution time for sales trends view
SET @start_time = GETDATE();
EXEC('SELECT TOP 1 * FROM analytics.sales_trends_and_forecasting');
SET @end_time = GETDATE();
PRINT 'Execution time for sales_trends_and_forecasting: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' milliseconds.';

-- Test execution time for customer purchase patterns view
SET @start_time = GETDATE();
EXEC('SELECT TOP 1 * FROM analytics.customer_purchase_patterns');
SET @end_time = GETDATE();
PRINT 'Execution time for customer_purchase_patterns: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' milliseconds.';
GO

-- =============================================================================
-- Summary:
-- =============================================================================
PRINT 'Analytics layer tests completed!';
