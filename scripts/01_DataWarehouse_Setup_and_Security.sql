/*
=============================================================
01_DataWarehouse_Setup_and_Security.sql
=============================================================
Hello readers! This script does a few important things:

First, we're setting up our data warehouse from scratch. Think of it like building
the foundation and framework of a house before we start moving in furniture.

We're using what's called a "medallion architecture" but with our own twist - 
adding a fourth layer specifically for analytics. Here's what each layer does:

- Bronze: This is where we store the raw data exactly as we got it
  It's like having a copy of the original document before we start editing.

- Silver: Here we clean things up - fix errors, standardize formats, remove duplicates.
  Think of it as organizing and sorting everything properly.

- Gold: This is where we reshape the data into a business-friendly format that makes
  reporting easy. Like arranging furniture in a way that makes the house functional.

- Analytics: Our custom layer for data science and advanced analysis needs. Sometimes
  analysts need data arranged differently than regular reports do.

We're also adding some basic security so people can only access what they need.

OBS: This script will COMPLETELY ERASE any existing DataWarehouse database.
Make sure you have backups if you're running this on a database with existing data!
*/

-- First, let's switch to the master database so we can create our new one
USE master;
GO

-- Let's check if our warehouse already exists and if so, wipe it clean to start fresh
-- (The SINGLE_USER thing forces everyone else out of the database - kind of rude but necessary!)
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    PRINT 'Found an existing warehouse - clearing it out to start fresh...';
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
    PRINT 'Old warehouse removed. Ready for the new build!';
END;
GO

-- Now let's create our shiny new database with settings for better performance
-- The default settings are like buying economy - these settings are more business class
PRINT 'Building our new data warehouse with optimized settings...';
CREATE DATABASE DataWarehouse
ON PRIMARY
(
    NAME = 'DataWarehouse_Data',  -- What we'll call this file in the system
    FILENAME = 'C:\SQLData\DataWarehouse_Data.mdf',  -- Where it lives on disk (change this if needed!)
    SIZE = 1GB,  -- Starting bigger than default so we don't have to resize as often
    MAXSIZE = UNLIMITED,  -- Room to grow!
    FILEGROWTH = 512MB  -- When we need more space, grab it in bigger chunks
)
LOG ON
(
    NAME = 'DataWarehouse_Log',  -- The name for our transaction log
    FILENAME = 'C:\SQLData\DataWarehouse_Log.ldf',  -- Its location (adjust if needed)
    SIZE = 512MB,  -- A decent starting size
    MAXSIZE = UNLIMITED,  -- No ceiling
    FILEGROWTH = 256MB  -- Grow in substantial chunks to avoid fragmentation
);
GO

-- Let's step inside our new warehouse to set it up
PRINT 'Stepping into our new warehouse...';
USE DataWarehouse;
GO

-- Time to create our different "zones" in the warehouse
PRINT 'Creating our data zones...';

-- The Bronze Zone - raw data exactly as we received it
CREATE SCHEMA bronze AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty 
    @name = N'Description', 
    @value = N'This is our raw data landing zone. We store the data exactly as it comes in from source systems, 
    without prettying it up. It''s like our digital filing cabinet of original documents. 
    Having this historical record is super helpful if we ever need to go back to square one.',
    @level0type = N'SCHEMA', @level0name = 'bronze';
GO

-- The Silver Zone - cleaned up but not yet reshaped
CREATE SCHEMA silver AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty 
    @name = N'Description', 
    @value = N'This is where we clean things up. We fix errors, standardize formats, merge duplicates, 
    and make sure everything''s consistent. The data''s still structured similar to the source, 
    but now it''s trustworthy. It''s like having all your documents translated to the same language 
    and using the same terminology.',
    @level0type = N'SCHEMA', @level0name = 'silver';
GO

-- The Gold Zone - business-ready data models
CREATE SCHEMA gold AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty 
    @name = N'Description', 
    @value = N'This is our showcase layer where data is reshaped into formats that make sense for business reporting. 
    We''ve got fact tables for measurements and dimension tables for context - all optimized for quick analysis. 
    This is where your BI tools should be pointed. Think of it as the display floor of our data warehouse.',
    @level0type = N'SCHEMA', @level0name = 'gold';
GO

-- The Analytics Zone - our custom addition for data science needs
CREATE SCHEMA analytics AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty 
    @name = N'Description', 
    @value = N'This is our special workshop for data scientists and analysts who need data prepared differently.
    We might denormalize things more, create special aggregations, or add calculated fields specifically for
    machine learning and statistical analysis. It''s like having a test kitchen alongside the main restaurant.',
    @level0type = N'SCHEMA', @level0name = 'analytics';
GO

-- Now let's set up some security so people only access what they need
-- It's like giving different keys to different people based on their role
PRINT 'Setting up security badges...';

-- Role for business users who just need to view reports
CREATE ROLE data_readers;
GRANT SELECT ON SCHEMA::gold TO data_readers;  -- They can read from the gold zone
GRANT SELECT ON SCHEMA::analytics TO data_readers;  -- And from the analytics zone
PRINT 'Created badges for regular business users - they can view but not touch the data';

-- Role for the data engineers who maintain everything
CREATE ROLE data_engineers;
GRANT SELECT, INSERT, UPDATE, ALTER ON SCHEMA::bronze TO data_engineers;
GRANT SELECT, INSERT, UPDATE, ALTER ON SCHEMA::silver TO data_engineers;
GRANT SELECT, INSERT, UPDATE, ALTER ON SCHEMA::gold TO data_engineers; 
GRANT SELECT, INSERT, UPDATE, ALTER ON SCHEMA::analytics TO data_engineers;
PRINT 'Created badges for our data engineers - they have the master key to all zones';

PRINT 'Warehouse setup complete! Ready to start moving data in.';
GO
