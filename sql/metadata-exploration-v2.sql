/*
================================================================================
METADATA EXPLORATION V2 - Enhanced Discovery & Customer Analytics Focus
================================================================================

PURPOSE:
This script provides enhanced metadata exploration queries optimized for 
initial database discovery and customer analytics table identification.
Use this for fast discovery of relevant tables when you're new to the database.

USAGE GUIDE - 4 PHASES:
1. High-Level Discovery (Queries 1-3): Get the lay of the land in 10 minutes
2. Relationship Discovery (Queries 4-6): Understand how tables connect
3. Comprehensive Discovery View (Query 7): One-stop dashboard view
4. Detailed Analysis (Queries 8-12): Deep dive into specific tables

TARGET DATABASE: SQL Server (AdventureWorks 2025)
AUTHOR: Analytics Team
DATE: 2025
*/

--------------------------------------------------------------------------------
-- PHASE 1: HIGH-LEVEL DISCOVERY
-- Run these first to understand database structure and identify key tables
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Query #1: Schema Overview
-- Purpose: List all schemas with the number of user tables in each schema
-- Use: Fast query using catalog views only. Helps identify which schemas 
--      are relevant for ERD or reporting.
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
-- Query #2: ALL Tables with Row Counts and Size
-- Purpose: Show ALL tables (not limited to top 10) with row counts and size
-- Use: Enhanced version that includes size in KB for complete database view.
--      Helps identify large/frequently used tables and understand database scale.
--------------------------------------------------------------------------------
SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    SUM(p.rows) AS TotalRows,
    SUM(a.total_pages) * 8 AS TotalSizeKB,
    CAST(ROUND(SUM(a.total_pages) * 8.0 / 1024, 2) AS DECIMAL(18,2)) AS TotalSizeMB
FROM sys.tables AS t
JOIN sys.partitions AS p 
    ON t.object_id = p.object_id
JOIN sys.allocation_units AS a
    ON p.partition_id = a.container_id
WHERE p.index_id IN (0,1)  -- 0: heap, 1: clustered index
GROUP BY t.schema_id, t.name
ORDER BY TotalRows DESC, TotalSizeKB DESC;

--------------------------------------------------------------------------------
-- Query #3: Customer Analytics-Focused Table Finder
-- Purpose: Automatically find tables relevant to customer analytics
-- Use: NEW query that identifies tables with Customer, Order, Sales, Person, 
--      Product patterns. Perfect for quickly identifying the 10-15 most 
--      relevant tables for RFM, CLV, cohort, and retention analysis.
--------------------------------------------------------------------------------
SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    SUM(p.rows) AS TotalRows,
    CAST(ROUND(SUM(a.total_pages) * 8.0 / 1024, 2) AS DECIMAL(18,2)) AS TotalSizeMB,
    CASE 
        WHEN t.name LIKE '%Customer%' THEN 'Customer'
        WHEN t.name LIKE '%Person%' THEN 'Person'
        WHEN t.name LIKE '%Order%' OR t.name LIKE '%Sales%' THEN 'Transaction'
        WHEN t.name LIKE '%Product%' THEN 'Product'
        WHEN t.name LIKE '%Address%' THEN 'Location'
        ELSE 'Other'
    END AS AnalyticsCategory,
    CASE 
        WHEN t.name LIKE '%Customer%' THEN 1
        WHEN t.name LIKE '%Order%' OR t.name LIKE '%Sales%' THEN 2
        WHEN t.name LIKE '%Person%' THEN 3
        WHEN t.name LIKE '%Product%' THEN 4
        WHEN t.name LIKE '%Address%' THEN 5
        ELSE 99
    END AS CategoryPriority
FROM sys.tables AS t
JOIN sys.partitions AS p 
    ON t.object_id = p.object_id
JOIN sys.allocation_units AS a
    ON p.partition_id = a.container_id
WHERE p.index_id IN (0,1)
    AND (
        t.name LIKE '%Customer%'
        OR t.name LIKE '%Person%'
        OR t.name LIKE '%Order%'
        OR t.name LIKE '%Sales%'
        OR t.name LIKE '%Product%'
        OR t.name LIKE '%Address%'
    )
GROUP BY t.schema_id, t.name
ORDER BY CategoryPriority, TotalRows DESC;

--------------------------------------------------------------------------------
-- PHASE 2: RELATIONSHIP DISCOVERY
-- Run these to understand how tables connect and identify dimension vs fact tables
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Query #4: Table Relationship Summary with Hub and Spoke Analysis
-- Purpose: Show which tables are hubs (dimensions) vs spokes (facts)
-- Use: NEW query using CTE to analyze foreign key patterns. Tables with many 
--      incoming FKs are typically dimension tables (hubs), while tables with 
--      many outgoing FKs are typically fact tables (spokes).
--------------------------------------------------------------------------------
WITH TableRelationships AS (
    SELECT
        SCHEMA_NAME(t.schema_id) AS SchemaName,
        t.name AS TableName,
        t.object_id AS TableObjectId,
        COUNT(DISTINCT fk_out.object_id) AS OutgoingFKs,
        COUNT(DISTINCT fk_in.object_id) AS IncomingFKs
    FROM sys.tables AS t
    LEFT JOIN sys.foreign_keys AS fk_out
        ON t.object_id = fk_out.parent_object_id
    LEFT JOIN sys.foreign_keys AS fk_in
        ON t.object_id = fk_in.referenced_object_id
    GROUP BY t.schema_id, t.name, t.object_id
)
SELECT
    SchemaName,
    TableName,
    OutgoingFKs,
    IncomingFKs,
    CASE 
        WHEN IncomingFKs > OutgoingFKs AND IncomingFKs >= 2 THEN 'Hub (Dimension)'
        WHEN OutgoingFKs > IncomingFKs AND OutgoingFKs >= 2 THEN 'Spoke (Fact)'
        WHEN IncomingFKs = 0 AND OutgoingFKs = 0 THEN 'Standalone'
        ELSE 'Bridge/Lookup'
    END AS TableRole,
    (IncomingFKs + OutgoingFKs) AS TotalRelationships
FROM TableRelationships
WHERE (IncomingFKs + OutgoingFKs) > 0
ORDER BY TotalRelationships DESC, IncomingFKs DESC;

--------------------------------------------------------------------------------
-- Query #5: Simplified Foreign Key Relationship Map
-- Purpose: Improved version with FK density calculation
-- Use: Shows parent → child relationships with simpler view. FK density helps 
--      identify heavily connected tables. Use this to build your mental model 
--      of the database structure.
--------------------------------------------------------------------------------
SELECT
    SCHEMA_NAME(r.schema_id) AS ReferencedSchema,
    r.name AS ReferencedTable,
    SCHEMA_NAME(p.schema_id) AS ParentSchema,
    p.name AS ParentTable,
    fk.name AS ForeignKeyName,
    COUNT(*) OVER (PARTITION BY r.object_id) AS FKDensityAsReferenced,
    COUNT(*) OVER (PARTITION BY p.object_id) AS FKDensityAsParent
FROM sys.foreign_keys AS fk
INNER JOIN sys.tables AS p
    ON p.object_id = fk.parent_object_id
INNER JOIN sys.tables AS r
    ON r.object_id = fk.referenced_object_id
ORDER BY FKDensityAsReferenced DESC, ReferencedTable, ParentTable;

--------------------------------------------------------------------------------
-- Query #6: Date/Time Columns Finder
-- Purpose: Find all date columns for temporal analysis
-- Use: NEW query critical for RFM, cohorts, retention analysis. Identifies 
--      all date/time columns across the database to help you understand 
--      temporal data availability for customer analytics.
--------------------------------------------------------------------------------
SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    SUM(p.rows) AS TableRowCount,
    CASE 
        WHEN c.name LIKE '%Order%Date%' OR c.name LIKE '%Purchase%Date%' THEN 'Transaction Date'
        WHEN c.name LIKE '%Birth%' THEN 'Birth Date'
        WHEN c.name LIKE '%Modified%' OR c.name LIKE '%Updated%' THEN 'Modified Date'
        WHEN c.name LIKE '%Created%' OR c.name LIKE '%Start%' THEN 'Created Date'
        WHEN c.name LIKE '%End%' OR c.name LIKE '%Due%' THEN 'End/Due Date'
        WHEN c.name LIKE '%Ship%' THEN 'Ship Date'
        ELSE 'Other Date'
    END AS DateCategory
FROM sys.tables AS t
JOIN sys.columns AS c
    ON t.object_id = c.object_id
JOIN sys.types AS ty
    ON c.user_type_id = ty.user_type_id
JOIN sys.partitions AS p
    ON t.object_id = p.object_id
WHERE ty.name IN ('date', 'datetime', 'datetime2', 'smalldatetime')
    AND p.index_id IN (0,1)
GROUP BY t.schema_id, t.name, c.name, ty.name
ORDER BY TableRowCount DESC, SchemaName, TableName, ColumnName;

--------------------------------------------------------------------------------
-- PHASE 3: COMPREHENSIVE DISCOVERY VIEW
-- Run this single query for a complete dashboard of table information
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Query #7: ONE QUERY TO RULE THEM ALL
-- Purpose: Comprehensive table discovery dashboard
-- Use: NEW comprehensive query combining multiple CTEs (TableSizes, 
--      TableRelationships, DateColumns, DescriptionInfo) to provide complete 
--      table discovery in one result set. Use this to quickly evaluate any 
--      table's role, size, relationships, and temporal data availability.
--------------------------------------------------------------------------------
WITH TableSizes AS (
    SELECT
        t.schema_id,
        t.object_id,
        SCHEMA_NAME(t.schema_id) AS SchemaName,
        t.name AS TableName,
        SUM(p.rows) AS TotalRows,
        CAST(ROUND(SUM(a.total_pages) * 8.0 / 1024, 2) AS DECIMAL(18,2)) AS TotalSizeMB
    FROM sys.tables AS t
    JOIN sys.partitions AS p 
        ON t.object_id = p.object_id
    JOIN sys.allocation_units AS a
        ON p.partition_id = a.container_id
    WHERE p.index_id IN (0,1)
    GROUP BY t.schema_id, t.object_id, t.name
),
TableRelationships AS (
    SELECT
        t.object_id AS TableObjectId,
        COUNT(DISTINCT fk_out.object_id) AS OutgoingFKs,
        COUNT(DISTINCT fk_in.object_id) AS IncomingFKs
    FROM sys.tables AS t
    LEFT JOIN sys.foreign_keys AS fk_out
        ON t.object_id = fk_out.parent_object_id
    LEFT JOIN sys.foreign_keys AS fk_in
        ON t.object_id = fk_in.referenced_object_id
    GROUP BY t.object_id
),
DateColumns AS (
    SELECT
        t.object_id AS TableObjectId,
        COUNT(*) AS DateColumnCount,
        STRING_AGG(c.name, ', ') AS DateColumnList
    FROM sys.tables AS t
    JOIN sys.columns AS c
        ON t.object_id = c.object_id
    JOIN sys.types AS ty
        ON c.user_type_id = ty.user_type_id
    WHERE ty.name IN ('date', 'datetime', 'datetime2', 'smalldatetime')
    GROUP BY t.object_id
),
DescriptionInfo AS (
    SELECT
        t.object_id AS TableObjectId,
        ep.value AS TableDescription
    FROM sys.tables AS t
    LEFT JOIN sys.extended_properties AS ep
        ON t.object_id = ep.major_id
        AND ep.minor_id = 0
        AND ep.name = 'MS_Description'
)
SELECT
    ts.SchemaName,
    ts.TableName,
    ts.TotalRows,
    ts.TotalSizeMB,
    ISNULL(tr.OutgoingFKs, 0) AS OutgoingFKs,
    ISNULL(tr.IncomingFKs, 0) AS IncomingFKs,
    CASE 
        WHEN ISNULL(tr.IncomingFKs, 0) > ISNULL(tr.OutgoingFKs, 0) AND ISNULL(tr.IncomingFKs, 0) >= 2 THEN 'Hub (Dimension)'
        WHEN ISNULL(tr.OutgoingFKs, 0) > ISNULL(tr.IncomingFKs, 0) AND ISNULL(tr.OutgoingFKs, 0) >= 2 THEN 'Spoke (Fact)'
        WHEN ISNULL(tr.IncomingFKs, 0) = 0 AND ISNULL(tr.OutgoingFKs, 0) = 0 THEN 'Standalone'
        ELSE 'Bridge/Lookup'
    END AS TableRole,
    ISNULL(dc.DateColumnCount, 0) AS DateColumnCount,
    dc.DateColumnList,
    CASE 
        WHEN ts.TableName LIKE '%Customer%' THEN 'Customer'
        WHEN ts.TableName LIKE '%Person%' THEN 'Person'
        WHEN ts.TableName LIKE '%Order%' OR ts.TableName LIKE '%Sales%' THEN 'Transaction'
        WHEN ts.TableName LIKE '%Product%' THEN 'Product'
        WHEN ts.TableName LIKE '%Address%' THEN 'Location'
        ELSE 'Other'
    END AS AnalyticsCategory,
    di.TableDescription
FROM TableSizes AS ts
LEFT JOIN TableRelationships AS tr
    ON ts.object_id = tr.TableObjectId
LEFT JOIN DateColumns AS dc
    ON ts.object_id = dc.TableObjectId
LEFT JOIN DescriptionInfo AS di
    ON ts.object_id = di.TableObjectId
ORDER BY 
    CASE 
        WHEN ts.TableName LIKE '%Customer%' THEN 1
        WHEN ts.TableName LIKE '%Order%' OR ts.TableName LIKE '%Sales%' THEN 2
        WHEN ts.TableName LIKE '%Person%' THEN 3
        WHEN ts.TableName LIKE '%Product%' THEN 4
        ELSE 99
    END,
    ts.TotalRows DESC;

--------------------------------------------------------------------------------
-- PHASE 4: DETAILED ANALYSIS
-- Use these queries to deep dive into specific tables after initial discovery
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Query #8: Primary Keys
-- Purpose: List primary keys and their ordered key columns
-- Use: Shows PK constraint name and column order. Useful for identifying 
--      natural vs surrogate keys for ERD. Add WHERE clause to filter specific tables.
--------------------------------------------------------------------------------
SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    kc.name AS PrimaryKeyName,
    c.name AS ColumnName,
    ic.key_ordinal AS KeyOrdinal
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
    -- Add filters here, e.g.:
    -- AND SCHEMA_NAME(t.schema_id) = 'Sales'
    -- AND t.name IN ('Customer', 'SalesOrderHeader')
ORDER BY SchemaName, TableName, PrimaryKeyName, ic.key_ordinal;

--------------------------------------------------------------------------------
-- Query #9: Foreign Key Relationships
-- Purpose: List foreign key relationships (one row per FK column)
-- Use: Shows parent/child tables and columns, and referential actions 
--      (ON DELETE/UPDATE). Useful for defining ERD relationships and constraints.
--      Add WHERE clause to filter specific schemas or tables.
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
    -- Add filters here, e.g.:
    -- WHERE SCHEMA_NAME(p.schema_id) = 'Sales'
    -- OR p.name LIKE '%Customer%'
    -- OR r.name LIKE '%Customer%'
ORDER BY ParentSchema, ParentTable, ForeignKeyName, fkc.constraint_column_id;

--------------------------------------------------------------------------------
-- Query #10: Column Details
-- Purpose: List all columns with data types and nullability
-- Use: Provides detailed column info for ERD and data modeling. Includes data 
--      type, max length, precision, scale, and whether NULL is allowed.
--      Add WHERE clause to filter specific tables or schemas.
--------------------------------------------------------------------------------
SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.max_length AS MaxLength,
    c.precision AS Precision,
    c.scale AS Scale,
    c.is_nullable AS IsNullable,
    c.column_id AS ColumnOrder
FROM sys.tables AS t
JOIN sys.columns AS c
    ON t.object_id = c.object_id
JOIN sys.types AS ty
    ON c.user_type_id = ty.user_type_id
    -- Add filters here, e.g.:
    -- WHERE SCHEMA_NAME(t.schema_id) = 'Sales'
    -- AND t.name = 'Customer'
ORDER BY SchemaName, TableName, c.column_id;

--------------------------------------------------------------------------------
-- Query #11: Table and Column Descriptions
-- Purpose: Combined view of table and column descriptions from extended properties
-- Use: Shows user-added descriptions for documentation. Useful for ERD 
--      annotations or BI data dictionary. Uses UNION ALL to combine table-level 
--      and column-level descriptions in one result set.
--------------------------------------------------------------------------------
-- Table descriptions
SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    NULL AS ColumnName,
    'Table' AS DescriptionLevel,
    ep.value AS Description
FROM sys.tables AS t
LEFT JOIN sys.extended_properties AS ep
    ON t.object_id = ep.major_id
    AND ep.minor_id = 0
    AND ep.name = 'MS_Description'
WHERE ep.value IS NOT NULL

UNION ALL

-- Column descriptions
SELECT 
    S.name AS SchemaName,
    T.name AS TableName,
    C.name AS ColumnName,
    'Column' AS DescriptionLevel,
    EP.value AS Description
FROM sys.extended_properties EP
INNER JOIN sys.tables T 
    ON EP.major_id = T.object_id
INNER JOIN sys.schemas S 
    ON T.schema_id = S.schema_id
INNER JOIN sys.columns C 
    ON EP.major_id = C.object_id
    AND EP.minor_id = C.column_id
WHERE EP.class = 1
    -- Add filters here, e.g.:
    -- AND S.name = 'Sales'
    -- AND T.name LIKE '%Customer%'
ORDER BY SchemaName, TableName, DescriptionLevel, ColumnName;

--------------------------------------------------------------------------------
-- Query #12: Index Details
-- Purpose: List indexes and their columns, including included columns
-- Use: Shows index type, uniqueness, PK/constraint status, and included columns.
--      Useful for performance planning and technical ERD annotations.
--      Add WHERE clause to filter specific schemas or tables.
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
    -- Add filters here, e.g.:
    -- WHERE SCHEMA_NAME(t.schema_id) = 'Sales'
    -- AND t.name = 'Customer'
ORDER BY SchemaName, TableName, IndexName, ind.index_id, ic.is_included_column, ic.key_ordinal;

/*
================================================================================
EXECUTION GUIDE - Recommended Workflow
================================================================================

FOR SOMEONE NEW TO THE DATABASE (10 minutes):
1. Run Query #1 (Schema Overview) - Understand the database structure
2. Run Query #3 (Customer Analytics Finder) - Identify key tables for your work
3. Run Query #7 (One Query to Rule Them All) - Get complete overview of all tables

FOR UNDERSTANDING RELATIONSHIPS (10 minutes):
4. Run Query #4 (Hub and Spoke Analysis) - Understand table roles
5. Run Query #5 (FK Relationship Map) - See how tables connect
6. Run Query #6 (Date/Time Finder) - Find temporal columns for time-based analysis

FOR SHORTLISTING TABLES (5 minutes):
7. Review Query #3 and Query #7 results side by side
8. Identify 10-15 most relevant tables based on:
   - Analytics category match (Customer, Transaction, Product)
   - Table role (Hub vs Spoke)
   - Row counts and size
   - Presence of date columns
   - Incoming/Outgoing relationships

FOR DETAILED ANALYSIS (as needed):
9. Run Phase 4 queries (8-12) with WHERE clause filters for your shortlisted tables
10. Use Query #11 to understand table/column meanings from descriptions
11. Use Query #12 to understand existing indexes for query optimization

FOR BUILDING ERD:
12. Start with hub tables (dimensions) from Query #4
13. Add spoke tables (facts) that connect to your hubs
14. Use Query #9 (FK Relationships) to draw connections
15. Use Query #8 (Primary Keys) to identify unique identifiers
16. Annotate with descriptions from Query #11

================================================================================
*/
