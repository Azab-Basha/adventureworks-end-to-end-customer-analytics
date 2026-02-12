/*
- This script creates the DataWarehouse database only if it doesn't already exist.
- Creates bronze / silver / gold schemas only if they don't already exist.
- Safe for use in dev: no drops, no roles, no advanced settings
Run this on a SQL Server instance with a login that can create databases.
*/

USE master;
GO

-- Create the DataWarehouse database if it doesn't exist
IF DB_ID(N'DataWarehouse') IS NULL
BEGIN
    PRINT 'Creating database [DataWarehouse]...';
    CREATE DATABASE [DataWarehouse];
    PRINT 'Database created.';
END
ELSE
BEGIN
    PRINT 'Database [DataWarehouse] already exists. Skipping creation.';
END
GO

USE [DataWarehouse];
GO

-- Create schemas if they do not exist
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'bronze')
BEGIN
    EXEC('CREATE SCHEMA [bronze];');
    PRINT 'Created schema [bronze].';
END
ELSE
    PRINT 'Schema [bronze] already exists; skipping.';

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'silver')
BEGIN
    EXEC('CREATE SCHEMA [silver];');
    PRINT 'Created schema [silver].';
END
ELSE
    PRINT 'Schema [silver] already exists; skipping.';

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'gold')
BEGIN
    EXEC('CREATE SCHEMA [gold];');
    PRINT 'Created schema [gold].';
END
ELSE
    PRINT 'Schema [gold] already exists; skipping.';

GO

PRINT 'Done. Your DataWarehouse database with bronze/silver/gold schemas is ready.';
