/*
==============================================================
Create Database and Schemas
==============================================================
Script Purpose:
  To create a new database called 'DataWarehouse' after checking if it already exists. 
  If it does exist, it is dropped and recreated, Additionally we set up additional schemas
  within the database named: 'bronze', 'silver', and 'gold'.
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
  BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
  END;
GO
-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
