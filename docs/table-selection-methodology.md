This document provides a **complete step-by-step guide** for anyone new to the AdventureWorks database or customer analytics projects. It shows you exactly how tables were identified, selected, and organized into the final Entity-Relationship Diagram (ERD) used to answer 7 key customer analytics questions.

---

## 📋 Overview

**Goal**: Build a focused ERD for customer analytics that answers 7 strategic questions about customer value, behavior, and lifetime value (CLV).

**Data Source**: AdventureWorks 2025 (SQL Server)

**Methodology**: 4-phase discovery process using `sql/metadata-exploration-v2.sql`

**Final Output**: Enhanced ERD (`docs/erd-customer-analytics-enhanced.dbml`) with 17 carefully selected tables

---

## 🎯 The 7 Strategic Questions

Before diving into table selection, we defined **7 core questions** that drive all analytics requirements:

### Q1: Who are our most valuable customers?
- **Metrics**: Total revenue, order count, average order value, gross margin, CLV proxy, Pareto concentration
- **Data Grain**: Customer × Order
- **Time Windows**: Full history, Last 12 months, Last 24 months
- **Key Entities**: Customer, SalesOrderHeader, SalesOrderDetail

### Q2: Which customers are unprofitable or risky?
- **Metrics**: Revenue per customer, cost proxies (returns, discounts), recency, frequency
- **Data Grain**: Customer × Time (monthly)
- **Time Windows**: Rolling windows (3, 6, 12 months)
- **Key Entities**: Customer, Orders, Returns (if available)

### Q3: How do customers differ in behavior (heterogeneity)?
- **Metrics**: RFM (Recency, Frequency, Monetary), basket size, category diversity
- **Data Grain**: Customer level
- **Time Windows**: Calibration window, Observation window
- **Key Entities**: Customer, Orders, Products

### Q4: Are newer customer cohorts better or worse?
- **Metrics**: Cohort size, retention rate, revenue per cohort, orders per cohort
- **Data Grain**: Cohort × Period
- **Time Windows**: Cohort month, Months since acquisition
- **Key Entities**: Customer, First purchase date, Orders

### Q5: Who is likely still active vs "dead"?
- **Metrics**: Last purchase date, purchase count, inter-purchase time, BTYD inputs
- **Data Grain**: Customer level
- **Time Windows**: Calibration vs holdout
- **Key Entities**: Customer, Orders

### Q6: What actions should we take (prescriptive)?
- **Metrics**: Predicted CLV, discount cost, incremental lift assumptions
- **Data Grain**: Customer × Action scenario
- **Time Windows**: Forward-looking (12–36 months)
- **Key Entities**: Customer, Orders, Promotions

### Q7: What is the value of our overall customer base? (CBCV)
- **Metrics**: Aggregated CLV projections, retention metrics, cohort performance
- **Data Grain**: Customer-level aggregated to portfolio
- **Time Windows**: Future projections (1–5 years)
- **Key Entities**: Customers, Transactions, Cohorts, Spend metrics

---

## 🚀 4-Phase Discovery Process

### **PHASE 1: High-Level Discovery (10 minutes)**
**Objective**: Understand the database structure and identify candidate tables for customer analytics.

#### Step 1: Run Query #1 - Schema Overview
**Purpose**: See how tables are organized across schemas.

```sql
-- Query #1: Schema Overview (lines 33-41 in metadata-exploration-v2.sql)
SELECT
    s.name AS SchemaName,
    COUNT(t.object_id) AS TableCount
FROM sys.schemas AS s
LEFT JOIN sys.tables AS t ON t.schema_id = s.schema_id
GROUP BY s.name
HAVING COUNT(t.object_id) > 0
ORDER BY TableCount DESC;
```

**Expected Results**:
- **Sales**: ~17 tables (order, customer, territory tables)
- **Person**: ~13 tables (customer demographics, addresses, contacts)
- **Production**: ~26 tables (product catalog, inventory)
- **Purchasing**: ~8 tables (vendor, purchase orders)
- **HumanResources**: ~6 tables (employees)

**Interpretation**: Focus on **Sales**, **Person**, and **Production** schemas for customer analytics.

---

#### Step 2: Run Query #3 - Customer Analytics-Focused Table Finder
**Purpose**: Auto-identify tables relevant to customer analytics using pattern matching.

```sql
-- Query #3: Customer Analytics-Focused Table Finder (lines 71-107)
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
    END AS AnalyticsCategory
FROM sys.tables AS t
JOIN sys.partitions AS p ON t.object_id = p.object_id
JOIN sys.allocation_units AS a ON p.partition_id = a.container_id
WHERE p.index_id IN (0,1)
    AND (t.name LIKE '%Customer%' OR t.name LIKE '%Person%' OR t.name LIKE '%Order%' 
         OR t.name LIKE '%Sales%' OR t.name LIKE '%Product%' OR t.name LIKE '%Address%')
GROUP BY t.schema_id, t.name
ORDER BY AnalyticsCategory, TotalRows DESC;
```

**Expected Results** (sample):

| SchemaName | TableName | TotalRows | AnalyticsCategory |
|------------|-----------|-----------|-------------------|
| Sales | Customer | 19,820 | Customer |
| Person | Person | 19,972 | Person |
| Sales | SalesOrderDetail | 121,317 | Transaction |
| Sales | SalesOrderHeader | 31,465 | Transaction |
| Production | Product | 504 | Product |
| Person | Address | 19,614 | Location |

**Key Takeaway**: These are your **candidate tables**. Next, you'll validate their relationships and roles.

---

#### Step 3: Run Query #7 - One Query to Rule Them All
**Purpose**: Get a comprehensive dashboard view combining size, relationships, date columns, and table roles.

```sql
-- Query #7: Comprehensive Table Discovery (lines 220-310)
-- This query uses CTEs to combine:
-- - Table sizes
-- - Foreign key relationships (incoming/outgoing)
-- - Date/time columns
-- - Table descriptions
```

**Expected Results** (sample):

| TableName | TotalRows | OutgoingFKs | IncomingFKs | TableRole | DateColumnCount | AnalyticsCategory |
|-----------|-----------|-------------|-------------|-----------|-----------------|-------------------|
| Customer | 19,820 | 2 | 1 | Hub (Dimension) | 1 | Customer |
| SalesOrderHeader | 31,465 | 6 | 2 | Spoke (Fact) | 4 | Transaction |
| Person | 19,972 | 0 | 3 | Hub (Dimension) | 1 | Person |
| Product | 504 | 2 | 2 | Bridge/Lookup | 4 | Product |

**Interpretation**:
- **Hub (Dimension)**: Tables with many **incoming** FKs → referenced by other tables (e.g., Customer, Person)
- **Spoke (Fact)**: Tables with many **outgoing** FKs → reference dimension tables (e.g., SalesOrderHeader, SalesOrderDetail)
- **Bridge/Lookup**: Connector tables or small reference tables

---

### **PHASE 2: Relationship Discovery (10 minutes)**
**Objective**: Understand how tables connect and identify dimension vs fact tables.

#### Step 4: Run Query #4 - Hub and Spoke Analysis
**Purpose**: Classify tables by their role in the data model.

```sql
-- Query #4: Table Relationship Summary (lines 121-149)
-- Uses CTE to count incoming and outgoing foreign keys per table
```

**Expected Results**:

| SchemaName | TableName | OutgoingFKs | IncomingFKs | TableRole | TotalRelationships |
|------------|-----------|-------------|-------------|-----------|-------------------|
| Sales | Customer | 2 | 1 | Hub (Dimension) | 3 |
| Sales | SalesOrderHeader | 6 | 2 | Spoke (Fact) | 8 |
| Person | Person | 0 | 3 | Hub (Dimension) | 3 |

**Key Insight**: Start your ERD with **Hub tables** (dimensions like Customer, Person) and connect them to **Spoke tables** (facts like SalesOrderHeader).

---

#### Step 5: Run Query #5 - Foreign Key Relationship Map
**Purpose**: See parent → child relationships to understand data flow.

```sql
-- Query #5: Simplified Foreign Key Relationship Map (lines 158-171)
SELECT
    SCHEMA_NAME(r.schema_id) AS ReferencedSchema,
    r.name AS ReferencedTable,
    SCHEMA_NAME(p.schema_id) AS ParentSchema,
    p.name AS ParentTable,
    fk.name AS ForeignKeyName
FROM sys.foreign_keys AS fk
INNER JOIN sys.tables AS p ON p.object_id = fk.parent_object_id
INNER JOIN sys.tables AS r ON r.object_id = fk.referenced_object_id
ORDER BY ReferencedTable, ParentTable;
```

**Expected Results** (sample):

| ReferencedTable | ParentTable | ForeignKeyName |
|-----------------|-------------|----------------|
| Customer | SalesOrderHeader | FK_SalesOrderHeader_Customer |
| Person | Customer | FK_Customer_Person |
| Product | SalesOrderDetail | FK_SalesOrderDetail_Product |

**Key Insight**: This tells you:
- `SalesOrderHeader` references `Customer` → Many orders per customer
- `Customer` references `Person` → One-to-one or optional relationship
- `SalesOrderDetail` references `Product` → Many line items per product

---

#### Step 6: Run Query #6 - Date/Time Columns Finder
**Purpose**: Identify temporal columns for RFM, cohorts, and retention analysis.

```sql
-- Query #6: Date/Time Columns Finder (lines 180-205)
-- Finds all date/datetime/datetime2 columns and categorizes them
```

**Expected Results** (sample):

| SchemaName | TableName | ColumnName | DateCategory | TableRowCount |
|------------|-----------|------------|--------------|---------------|
| Sales | SalesOrderHeader | OrderDate | Transaction Date | 31,465 |
| Sales | SalesOrderHeader | ShipDate | Ship Date | 31,465 |
| Sales | SalesOrderHeader | DueDate | End/Due Date | 31,465 |
| Person | Person | ModifiedDate | Modified Date | 19,972 |

**Critical Finding**: `SalesOrderHeader.OrderDate` is the **primary temporal anchor** for:
- **Recency** (time since last order)
- **Cohorts** (first order month)
- **Trends** (order patterns over time)

---

### **PHASE 3: Table Shortlisting (5 minutes)**
**Objective**: Narrow down to 10-15 most relevant tables based on discovery results.

#### Step 7: Review Query #3 and Query #7 Results Side by Side
Create a **shortlist scorecard** using these criteria:

| Criterion | Weight | How to Evaluate |
|-----------|--------|-----------------|
| **Analytics Category Match** | High | Must be Customer, Transaction, or Product category |
| **Table Role** | High | Prefer Hubs (dimensions) and Spokes (facts) |
| **Row Count** | Medium | Larger tables = more analytical value |
| **Date Column Presence** | High | Required for temporal analysis (RFM, cohorts) |
| **Relationship Density** | Medium | Tables with 2+ relationships are well-connected |

#### Step 8: Apply Scorecard to Candidate Tables

**Example Evaluation**:

| Table | Category | Role | Rows | Date Cols | Relationships | Include? |
|-------|----------|------|------|-----------|---------------|----------|
| Sales.Customer | Customer | Hub | 19,820 | 1 | 3 | ✅ YES |
| Sales.SalesOrderHeader | Transaction | Spoke | 31,465 | 4 | 8 | ✅ YES |
| Sales.SalesOrderDetail | Transaction | Spoke | 121,317 | 1 | 3 | ✅ YES |
| Person.Person | Person | Hub | 19,972 | 1 | 3 | ✅ YES |
| Production.Product | Product | Bridge | 504 | 4 | 4 | ✅ YES |
| Person.Address | Location | Hub | 19,614 | 1 | 2 | ✅ YES |
| Sales.SpecialOffer | Other | Standalone | 16 | 2 | 1 | ⚠️ MAYBE |
| HumanResources.Employee | Other | Hub | 290 | 2 | 4 | ❌ NO (out of scope) |

**Final Shortlist** (17 tables selected):

**Dimensions / Hub Tables** (9):
1. Sales.Customer
2. Person.Person
3. Person.EmailAddress
4. Person.Address
5. Person.StateProvince
6. Sales.SalesTerritory
7. Production.Product
8. Production.ProductSubcategory
9. Production.ProductCategory

**Facts / Transaction Tables** (2):
10. Sales.SalesOrderHeader
11. Sales.SalesOrderDetail

**Bridge / Lookup Tables** (6):
12. Person.BusinessEntityAddress
13. Person.AddressType
14. Sales.SpecialOffer
15. Sales.SpecialOfferProduct
16. Sales.SalesOrderHeaderSalesReason
17. Sales.SalesReason

---

### **PHASE 4: Detailed Analysis (As Needed)**
**Objective**: Deep dive into shortlisted tables to define the ERD schema.

#### Step 9: Run Phase 4 Queries with Filters
For each shortlisted table, run:

**Query #8 - Primary Keys** (lines 323-345):
```sql
-- Find primary keys for ERD unique identifiers
WHERE SCHEMA_NAME(t.schema_id) = 'Sales' AND t.name = 'Customer';
```

**Query #9 - Foreign Key Relationships** (lines 354-381):
```sql
-- Get FK details for ERD relationship lines
WHERE SCHEMA_NAME(p.schema_id) = 'Sales' OR p.name LIKE '%Customer%';
```

**Query #10 - Column Details** (lines 390-408):
```sql
-- List all columns for ERD table definitions
WHERE SCHEMA_NAME(t.schema_id) = 'Sales' AND t.name = 'SalesOrderHeader';
```

#### Step 10: Document Findings in ERD Format
Use the DBML format to define each table:

```dbml
Table Sales_Customer {
  CustomerID int [pk, not null]
  PersonID int
  TerritoryID int
  AccountNumber varchar(10) [not null]
  ModifiedDate datetime [not null]

  Note: 'Customer master. One row per customer. Links to Person and SalesTerritory; drives customer-level RFM/CLV.'
}
```

---

## 📊 Final ERD Structure

The final ERD (`docs/erd-customer-analytics-enhanced.dbml`) contains **17 tables** organized as:

### **Dimensions / Hub Tables** (Customer Identity & Context)
- **Sales.Customer**: Customer master table (CustomerID, PersonID, TerritoryID)
- **Person.Person**: Demographics (FirstName, LastName, EmailPromotion, Demographics XML)
- **Person.EmailAddress**: Contact information for campaigns
- **Person.Address**: Geographic data (City, PostalCode, StateProvinceID)
- **Person.StateProvince**: State/province/region lookup
- **Sales.SalesTerritory**: Territory/region dimension (for regional CLV)
- **Production.Product**: Product catalog (ProductID, Name, ListPrice, StandardCost)
- **Production.ProductSubcategory**: Product subcategory hierarchy
- **Production.ProductCategory**: Top-level product categories

### **Fact / Transaction Tables** (Behavioral Data)
- **Sales.SalesOrderHeader**: Order-level facts (OrderDate, CustomerID, TotalDue, SubTotal)
- **Sales.SalesOrderDetail**: Line-item facts (ProductID, OrderQty, UnitPrice, LineTotal)

### **Bridge / Lookup Tables** (Relationships & Context)
- **Person.BusinessEntityAddress**: Links Person/Store to Address (many-to-many)
- **Person.AddressType**: Address type lookup (Billing, Shipping, Home)
- **Sales.SpecialOffer**: Promotion/discount metadata
- **Sales.SpecialOfferProduct**: Links offers to products (required bridge)
- **Sales.SalesOrderHeaderSalesReason**: Links orders to purchase reasons
- **Sales.SalesReason**: Purchase motivation lookup

---

## 🔗 How the ERD Answers the 7 Questions

### **Q1: Most Valuable Customers**
**Tables Used**:
- `Sales.Customer` (CustomerID)
- `Sales.SalesOrderHeader` (OrderDate, TotalDue, CustomerID)
- `Sales.SalesOrderDetail` (LineTotal, OrderQty)

**Query Pattern**:
```sql
SELECT 
    c.CustomerID,
    COUNT(DISTINCT soh.SalesOrderID) AS OrderCount,
    SUM(soh.TotalDue) AS TotalRevenue,
    AVG(soh.TotalDue) AS AvgOrderValue
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
WHERE soh.OrderDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY c.CustomerID
ORDER BY TotalRevenue DESC;
```

---

### **Q2: Unprofitable or Risky Customers**
**Tables Used**:
- `Sales.Customer`
- `Sales.SalesOrderHeader` (OrderDate for recency)
- `Sales.SalesOrderDetail` (UnitPriceDiscount for discount proxy)

**Key Metrics**:
- **Recency**: `DATEDIFF(DAY, MAX(OrderDate), GETDATE())`
- **Frequency**: `COUNT(DISTINCT SalesOrderID)`
- **Discount Rate**: `SUM(UnitPriceDiscount) / SUM(UnitPrice)`

---

### **Q3: Customer Behavior Heterogeneity (RFM)**
**Tables Used**:
- `Sales.Customer`
- `Sales.SalesOrderHeader` (OrderDate, TotalDue)
- `Production.Product` (for category diversity via SalesOrderDetail)

**RFM Calculation**:
- **Recency**: Days since last order
- **Frequency**: Total order count
- **Monetary**: Total spend (SUM of TotalDue)

---

### **Q4: Cohort Analysis**
**Tables Used**:
- `Sales.Customer`
- `Sales.SalesOrderHeader` (OrderDate for cohort assignment)

**Query Pattern**:
```sql
WITH FirstPurchase AS (
    SELECT CustomerID, MIN(OrderDate) AS FirstOrderDate
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
)
SELECT 
    YEAR(FirstOrderDate) AS CohortYear,
    MONTH(FirstOrderDate) AS CohortMonth,
    COUNT(DISTINCT CustomerID) AS CohortSize
FROM FirstPurchase
GROUP BY YEAR(FirstOrderDate), MONTH(FirstOrderDate);
```

---

### **Q5: Active vs "Dead" Customers**
**Tables Used**:
- `Sales.Customer`
- `Sales.SalesOrderHeader` (OrderDate)

**Key Metrics**:
- Last purchase date
- Inter-purchase time (average days between orders)
- Expected next purchase (BTYD model inputs)

---

### **Q6: Prescriptive Actions**
**Tables Used**:
- `Sales.Customer`
- `Sales.SalesOrderHeader`
- `Sales.SpecialOffer` (promotion history)
- `Sales.SpecialOfferProduct` (bridge to link offers to products)

**Use Case**: Simulate discount campaigns for high-CLV customers based on historical promotion response.

---

### **Q7: Customer Base Current Value (CBCV)**
**Tables Used**:
- All tables from Q1-Q5 (aggregated)

**Approach**: Aggregate individual CLV predictions to portfolio level, segment by cohort, and project future retention curves.

---

## 🛠️ Tools & Resources

**SQL Script**: [`sql/metadata-exploration-v2.sql`](../sql/metadata-exploration-v2.sql)
- 12 queries organized into 4 phases
- Fully commented with usage instructions
- Execution guide at the bottom (lines 486-523)

**ERD File**: [`docs/erd-customer-analytics-enhanced.dbml`](./erd-customer-analytics-enhanced.dbml)
- DBML format (visualize at [dbdiagram.io](https://dbdiagram.io))
- 17 tables with full column definitions
- Relationship cardinalities documented

**Database**: AdventureWorks 2025 (SQL Server)

---

## 📝 Summary: Methodology at a Glance

| Phase | Time | Queries | Output |
|-------|------|---------|--------|
| **1. High-Level Discovery** | 10 min | #1, #3, #7 | Candidate tables + analytics categories |
| **2. Relationship Discovery** | 10 min | #4, #5, #6 | Table roles (Hub/Spoke) + FK map + temporal columns |
| **3. Table Shortlisting** | 5 min | Manual review | 17 final tables |
| **4. Detailed Analysis** | As needed | #8, #9, #10 | Column details + PK/FK definitions for ERD |

**Total Time to Shortlist**: ~25 minutes

**Final Deliverable**: Enhanced ERD with 17 tables optimized for customer analytics (Q1-Q7)

---

## 🚦 Next Steps for New Users

1. **Run Phase 1 queries** on your AdventureWorks database
2. **Compare your results** to the expected outputs in this document
3. **Review the final ERD** at [docs/erd-customer-analytics-enhanced.dbml](./erd-customer-analytics-enhanced.dbml)
4. **Start with Q1** (Most Valuable Customers) using the query patterns above
5. **Iterate**: Use Phase 4 queries to explore additional columns or relationships as needed

---

**Questions or Issues?** Refer to the inline comments in [`sql/metadata-exploration-v2.sql`](../sql/metadata-exploration-v2.sql) or review the execution guide at the end of that file (lines 486-523).
