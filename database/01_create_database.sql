/*
    Zaryn Data Engineering
    Project: Manufacturing Analytics
    Script: 01_create_database.sql

    Purpose:
      Creates the portfolio database if it does not already exist.

    Run this script first, connected to the master database.
*/

USE [master];
GO

IF DB_ID(N'ZarynManufacturingAnalytics') IS NULL
BEGIN
    CREATE DATABASE [ZarynManufacturingAnalytics];
    PRINT 'Database ZarynManufacturingAnalytics created.';
END
ELSE
BEGIN
    PRINT 'Database ZarynManufacturingAnalytics already exists. No changes made.';
END;
GO
