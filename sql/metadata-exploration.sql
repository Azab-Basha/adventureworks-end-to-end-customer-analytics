/*
Purpose: Small, focused metadata queries to explore AdventureWorks2025.
These queries list schemas, tables, primary/foreign keys, indexes, row counts,
column details, and table descriptions.
Use results as a blueprint for ERD design, data modeling, or warehouse planning.
*/

--------------------------------------------------------------------------------
-- 1) List all schemas with the number of user tables in each schema
--    - Fast query using catalog views only.
--    - Helps identify which schemas are relevant for ERD or reporting.
--------------------------------------------------------------------------------
SELECT
    s.name AS SchemaName,
    COUNT(t.object_id) AS TableCount
FROM sys.schemas AS s
LEFT JOIN sys.tables AS t 
    ON t.schema_id = s.schema_id
GROUP BY s.name
HAVING COUNT(t.object_id) > 0
ORDER BY TableCount DESC;

--------------------------------------------------------------------------------
-- 2) Top 10 tables by approximate row count
--    - Uses sys.partitions for fast row estimates.
--    - Helps identify large/frequently used tables (fact tables for BI or warehouse).
--------------------------------------------------------------------------------
SELECT TOP (10)
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    SUM(p.rows) AS TotalRows
FROM sys.tables AS t
JOIN sys.partitions AS p 
    ON t.object_id = p.object_id
WHERE p.index_id IN (0,1)  -- 0: heap, 1: clustered index
GROUP BY t.schema_id, t.name
ORDER BY TotalRows DESC;

--------------------------------------------------------------------------------
-- 3) List primary keys and their ordered key columns
--    - Shows PK constraint name and column order.
--    - Useful for identifying natural vs surrogate keys for ERD.
--------------------------------------------------------------------------------
SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    kc.name AS PrimaryKeyName,
    c.name AS ColumnName
FROM sys.key_constraints AS kc
INNER JOIN sys.indexes AS i
    ON kc.parent_object_id = i.object_id
    AND kc.unique_index_id = i.index_id
INNER JOIN sys.index_columns AS ic
    ON i.object_id = ic.object_id
    AND i.index_id = ic.index_id
INNER JOIN sys.columns AS c
    ON ic.object_id = c.object_id
    AND ic.column_id = c.column_id
INNER JOIN sys.tables AS t
    ON t.object_id = kc.parent_object_id
WHERE kc.type = 'PK'
ORDER BY SchemaName, TableName, PrimaryKeyName, ic.key_ordinal;

--------------------------------------------------------------------------------
-- 4) List foreign key relationships (one row per FK column)
--    - Shows parent/child tables and columns, and referential actions (ON DELETE/UPDATE).
--    - Useful for defining ERD relationships and constraints.
--------------------------------------------------------------------------------
SELECT
    fk.name AS ForeignKeyName,
    SCHEMA_NAME(p.schema_id) AS ParentSchema,
    p.name AS ParentTable,
    pc.name AS ParentColumn,
    SCHEMA_NAME(r.schema_id) AS ReferencedSchema,
    r.name AS ReferencedTable,
    rc.name AS ReferencedColumn,
    fk.delete_referential_action_desc AS OnDelete,
    fk.update_referential_action_desc AS OnUpdate
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fkc
    ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.tables AS p
    ON p.object_id = fkc.parent_object_id
INNER JOIN sys.columns AS pc
    ON pc.object_id = p.object_id
    AND pc.column_id = fkc.parent_column_id
INNER JOIN sys.tables AS r
    ON r.object_id = fkc.referenced_object_id
INNER JOIN sys.columns AS rc
    ON rc.object_id = r.object_id
    AND rc.column_id = fkc.referenced_column_id
ORDER BY ParentSchema, ParentTable, ForeignKeyName, fkc.constraint_column_id;

--------------------------------------------------------------------------------
-- 5) List all columns with data types and nullability
--    - Provides detailed column info for ERD and data modeling.
--    - Includes data type, max length, precision, scale, and whether NULL is allowed.
--------------------------------------------------------------------------------
SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.max_length AS MaxLength,
    c.precision AS Precision,
    c.scale AS Scale,
    c.is_nullable AS IsNullable
FROM sys.tables AS t
JOIN sys.columns AS c
    ON t.object_id = c.object_id
JOIN sys.types AS ty
    ON c.user_type_id = ty.user_type_id
ORDER BY SchemaName, TableName, c.column_id;

--------------------------------------------------------------------------------
-- 6) List table descriptions (extended properties)
--    - Useful for documentation in ERD or Power BI.
--    - Not all tables may have descriptions.
--------------------------------------------------------------------------------
SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    ep.value AS TableDescription
FROM sys.tables AS t
LEFT JOIN sys.extended_properties AS ep
    ON t.object_id = ep.major_id
    AND ep.minor_id = 0
    AND ep.name = 'MS_Description'
ORDER BY SchemaName, TableName;

--------------------------------------------------------------------------------
-- 7) List column definitions (extended properties)
--    - Shows user-added column descriptions for documentation.
--    - Useful for ERD annotations or BI data dictionary.
--------------------------------------------------------------------------------
SELECT 
    S.name AS SchemaName,
    T.name AS TableName,
    C.name AS ColumnName,
    EP.value AS [Definition]
FROM sys.extended_properties EP
INNER JOIN sys.tables T 
    ON EP.major_id = T.object_id
INNER JOIN sys.schemas S 
    ON T.schema_id = S.schema_id
INNER JOIN sys.columns C 
    ON EP.major_id = C.object_id
    AND EP.minor_id = C.column_id
WHERE EP.class = 1
ORDER BY SchemaName, TableName, ColumnName;

--------------------------------------------------------------------------------
-- 8) List indexes and their columns, including included columns
--    - Shows index type, uniqueness, PK/constraint status, and included columns.
--    - Useful for performance planning and technical ERD annotations.
--------------------------------------------------------------------------------
SELECT 
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    ind.name AS IndexName,
    col.name AS ColumnName,
    ind.type_desc AS IndexType,
    ind.is_unique AS IsUnique,
    ind.is_primary_key AS IsPrimaryKey,
    ind.is_unique_constraint AS IsUniqueConstraint,
    ic.is_included_column AS IsIncludedColumn,
    ic.key_ordinal AS KeyOrdinal
FROM sys.indexes AS ind
INNER JOIN sys.index_columns AS ic
    ON ind.object_id = ic.object_id
    AND ind.index_id = ic.index_id
INNER JOIN sys.columns AS col
    ON ic.object_id = col.object_id
    AND ic.column_id = col.column_id
INNER JOIN sys.tables AS t
    ON ind.object_id = t.object_id
ORDER BY SchemaName, TableName, IndexName, ind.index_id, ic.is_included_column, ic.key_ordinal;
