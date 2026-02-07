--------------------------------------------------------------------------------
-- Query #11: Data Dictionary Extraction for 17 Customer Analytics Tables
-- Purpose: Extract complete metadata (schema, table, column, data type, PK, FK, descriptions)
--          for the 17 tables selected for customer analytics
-- Use: This query generates the source data for the comprehensive data dictionary
--      document at docs/adventureworks-customer-analytics-data-dictionary.md
--      Run this query to regenerate or validate the data dictionary content.
--------------------------------------------------------------------------------
SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName,
    TYPE_NAME(c.user_type_id) AS DataType,
    
    -- Primary Key indicator
    CASE WHEN EXISTS (
        SELECT 1 
        FROM sys.indexes AS i
        INNER JOIN sys.index_columns AS ic 
            ON i.object_id = ic.object_id AND i.index_id = ic.index_id
        WHERE i.is_primary_key = 1 
            AND ic.object_id = t.object_id 
            AND ic.column_id = c.column_id
    ) THEN 'PK' ELSE '' END AS IsPK,
    
    -- Foreign Key information
    fk.ReferencedSchema AS FK_ReferencesSchema,
    fk.ReferencedTable AS FK_ReferencesTable,
    fk.ReferencedColumn AS FK_ReferencesColumn,
    
    -- Column description
    CAST(ep.value AS NVARCHAR(500)) AS ColumnDescription

FROM sys.tables AS t
INNER JOIN sys.columns AS c
    ON t.object_id = c.object_id
    
-- Get extended property descriptions
LEFT JOIN sys.extended_properties AS ep 
    ON ep.major_id = t.object_id
    AND ep.minor_id = c.column_id
    AND ep.class = 1
    
-- Get foreign key relationships
LEFT JOIN (
    SELECT 
        fkc.parent_object_id,
        fkc.parent_column_id,
        SCHEMA_NAME(ref_t.schema_id) AS ReferencedSchema,
        ref_t.name AS ReferencedTable,
        ref_c.name AS ReferencedColumn
    FROM sys.foreign_key_columns AS fkc
    INNER JOIN sys.tables AS ref_t 
        ON fkc.referenced_object_id = ref_t.object_id
    INNER JOIN sys.columns AS ref_c 
        ON fkc.referenced_object_id = ref_c.object_id 
        AND fkc.referenced_column_id = ref_c.column_id
) AS fk 
    ON fk.parent_object_id = t.object_id 
    AND fk.parent_column_id = c.column_id

WHERE 
    -- Filter to the 17 customer analytics tables
    (SCHEMA_NAME(t.schema_id) = 'Sales' AND t.name IN ('Customer', 'SalesOrderHeader', 'SalesOrderDetail', 'SalesTerritory', 'SpecialOffer', 'SpecialOfferProduct', 'SalesOrderHeaderSalesReason', 'SalesReason'))
    OR (SCHEMA_NAME(t.schema_id) = 'Person' AND t.name IN ('Person', 'EmailAddress', 'Address', 'StateProvince', 'BusinessEntityAddress', 'AddressType'))
    OR (SCHEMA_NAME(t.schema_id) = 'Production' AND t.name IN ('Product', 'ProductSubcategory', 'ProductCategory'))

ORDER BY 
    SchemaName,
    TableName,
    c.column_id;

-- Keeping Query #10 (Column Details) as is.

-- EXECUTION GUIDE:
-- This query is designed for the data dictionary extraction, replacing Query #12.
