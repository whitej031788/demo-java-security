-- =============================================
-- Author:      AI Assistant
-- Create Date: 2025-05-29
-- Description: Sample SQL script for SonarQube violation scanning.
--              Includes common keywords and potential issues.
-- =============================================

-- --- Potential SonarQube Issues to look for ---
-- 1.  Missing 'N' prefix for Unicode strings (e.g., 'Some text' instead of N'Some text')
-- 2.  Using SELECT * instead of explicit column names.
-- 3.  Lack of SET NOCOUNT ON in stored procedures.
-- 4.  Hardcoded sensitive data (simulated).
-- 5.  Dynamic SQL without proper parameterization (simulated).
-- 6.  Lack of comments for complex logic (intentional omission in some parts).

-- Section 1: CREATE Statements
-------------------------------------------------------------------------------

-- Create a sample database if it doesn't exist (commented out for safety)
-- USE master;
-- GO
-- IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'SonarQubeTestDB')
-- BEGIN
--     CREATE DATABASE SonarQubeTestDB;
-- END;
-- GO

-- Use the target database
USE SonarQubeTestDB; -- Replace with your actual database name if running
GO

-- Create a sample table
CREATE TABLE dbo.SampleData (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100),
    Description NVARCHAR(MAX),
    Value DECIMAL(18, 2),
    CreationDate DATETIME DEFAULT GETDATE(),
    IsActive BIT
);
GO

-- Create another sample table
CREATE TABLE dbo.AuditLog (
    LogId INT IDENTITY(1,1) PRIMARY KEY,
    ActionType VARCHAR(50),
    ActionDescription NVARCHAR(MAX),
    ActionTimestamp DATETIME DEFAULT GETDATE(),
    PerformedBy VARCHAR(50)
);
GO

-- Section 2: Stored Procedure with DECLARE and BEGIN...END
-------------------------------------------------------------------------------

-- Stored Procedure to insert data into SampleData and log an audit entry
CREATE PROCEDURE dbo.InsertAndLogSampleData
    @p_Name VARCHAR(100),
    @p_Description NVARCHAR(MAX),
    @p_Value DECIMAL(18, 2),
    @p_IsActive BIT,
    @p_PerformedBy VARCHAR(50)
AS
BEGIN
    -- SonarQube issue: Missing SET NOCOUNT ON for stored procedures
    -- SET NOCOUNT ON;

    -- Declare variables
    DECLARE @NewId INT;
    DECLARE @LogMessage NVARCHAR(MAX);
    DECLARE @DynamicSQL NVARCHAR(MAX);
    DECLARE @TableName VARCHAR(50) = 'SampleData'; -- Hardcoded table name for dynamic query example

    -- Begin transaction (optional, but good practice for multiple operations)
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insert data into SampleData table
        INSERT INTO dbo.SampleData (Name, Description, Value, IsActive)
        VALUES (@p_Name, @p_Description, @p_Value, @p_IsActive);

        -- Get the ID of the newly inserted row
        SET @NewId = SCOPE_IDENTITY();

        -- Prepare log message
        -- SonarQube issue: String literal without 'N' prefix for Unicode
        SET @LogMessage = 'New record inserted with ID: ' + CAST(@NewId AS VARCHAR(10)) + ' and Name: ' + @p_Name + '. Value: ' + CAST(@p_Value AS VARCHAR(20));

        -- Insert into AuditLog
        INSERT INTO dbo.AuditLog (ActionType, ActionDescription, PerformedBy)
        VALUES (N'Data Insert', @LogMessage, @p_PerformedBy);

        -- SonarQube issue: Using SELECT * (consider specifying columns)
        -- Also, this SELECT is just for demonstration, usually you'd return something specific
        SELECT * FROM dbo.SampleData WHERE Id = @NewId;

        -- SonarQube issue: Example of dynamic SQL that *could* be prone to injection
        -- In a real scenario, this should be parameterized using sp_executesql
        SET @DynamicSQL = 'SELECT * FROM dbo.' + @TableName + ' WHERE Name = ''' + @p_Name + '''';
        EXEC sp_executesql @DynamicSQL;

        -- SonarQube issue: Hardcoded sensitive value (simulated)
        -- This could be a password, API key, etc., if it were real.
        DECLARE @HardcodedConfig VARCHAR(50) = 'API_KEY_12345'; -- SonarQube might flag this

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback transaction on error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Log error (simplified for example)
        INSERT INTO dbo.AuditLog (ActionType, ActionDescription, PerformedBy)
        VALUES (N'Error', ERROR_MESSAGE(), 'SYSTEM_ERROR');

        -- Re-throw the error
        THROW;
    END CATCH;
END;
GO

-- Section 3: Example of a simple script using BEGIN...END for a batch
-------------------------------------------------------------------------------

-- This is a simple batch script
BEGIN
    PRINT 'Starting batch process...';

    -- Update some data
    UPDATE dbo.SampleData
    SET Value = Value * 1.05,
        Description = N'Updated on ' + CONVERT(NVARCHAR(20), GETDATE(), 120)
    WHERE IsActive = 1;

    -- Delete old audit logs
    DELETE FROM dbo.AuditLog
    WHERE ActionTimestamp < DATEADD(month, -6, GETDATE());

    PRINT 'Batch process completed.';
END;
GO

-- --- End of Sample SQL File ---
