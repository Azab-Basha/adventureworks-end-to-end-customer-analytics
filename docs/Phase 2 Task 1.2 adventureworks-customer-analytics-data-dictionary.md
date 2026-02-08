# 📘 AdventureWorks Customer Analytics Data Dictionary

> **Single Source of Truth** for the 17-table customer analytics data model

---

## 📋 Table of Contents

- [Overview](#-overview)
- [How to Use This Dictionary](#-how-to-use-this-dictionary)
- [Quick Reference: Table Summary](#-quick-reference-table-summary)
- [Dimension Tables (Hubs)](#-dimension-tables-hubs) 🟦
  - [Sales.Customer](#salescustomer)
  - [Person.Person](#personperson)
  - [Person.EmailAddress](#personemailaddress)
  - [Person.Address](#personaddress)
  - [Person.StateProvince](#personstateprovince)
  - [Sales.SalesTerritory](#salessalesterritory)
  - [Production.Product](#productionproduct)
  - [Production.ProductSubcategory](#productionproductsubcategory)
  - [Production.ProductCategory](#productionproductcategory)
- [Fact Tables (Transactions)](#-fact-tables-transactions) 🟩
  - [Sales.SalesOrderHeader](#salessalesorderheader)
  - [Sales.SalesOrderDetail](#salessalesorderdetail)
- [Bridge/Lookup Tables](#-bridgelookup-tables) 🟨
  - [Person.BusinessEntityAddress](#personbusinessentityaddress)
  - [Person.AddressType](#personaddresstype)
  - [Sales.SpecialOffer](#salesspecialoffer)
  - [Sales.SpecialOfferProduct](#salesspecialofferproduct)
  - [Sales.SalesOrderHeaderSalesReason](#salessalesorderheadersalesreason)
  - [Sales.SalesReason](#salessalesreason)
- [SQL Query Source](#-sql-query-source)

---

## 🎯 Overview

This data dictionary documents the **17 core tables** selected for customer analytics in the AdventureWorks database. These tables support:

✅ **RFM Analysis** (Recency, Frequency, Monetary)  
✅ **Customer Lifetime Value (CLV)** modeling  
✅ **Cohort Analysis** and retention tracking  
✅ **Product affinity** and cross-sell analysis  
✅ **Geographic segmentation**  
✅ **Promotional effectiveness** analysis

**Database**: AdventureWorks 2025 (SQL Server)  
**Last Updated**: Feb 2026  
**Project**: End-to-End Customer Analytics

---

## 📖 How to Use This Dictionary

### Legend:
- 🔑 **Primary Key** - Uniquely identifies each row
- 🔗 **Foreign Key** - References another table
- 📊 **Analytics Key Field** - Critical for customer analytics use cases
- 🟦 **Dimension Table** - Descriptive/contextual data (Who, What, Where)
- 🟩 **Fact Table** - Transactional/measurable data (metrics, events)
- 🟨 **Bridge Table** - Many-to-many relationships or small lookups

### Reading FK Relationships:
```
🔗 FK → Schema.Table.Column
```
Example: `🔗 FK → Person.StateProvince.StateProvinceID` means this column references the `StateProvinceID` in the `Person.StateProvince` table.

---

## 📊 Quick Reference: Table Summary

| # | Schema | Table Name | Type | Row Count | Key Use Case |
|---|--------|-----------|------|-----------|--------------|
| 1 | Sales | Customer | 🟦 Dimension | 19,820 | Customer master record |
| 2 | Person | Person | 🟦 Dimension | 19,972 | Demographics & contact info |
| 3 | Person | EmailAddress | 🟦 Dimension | 19,972 | Email for campaigns |
| 4 | Person | Address | 🟦 Dimension | 58,842 | Geographic segmentation |
| 5 | Person | StateProvince | 🟦 Dimension | 181 | State/region lookup |
| 6 | Sales | SalesTerritory | 🟦 Dimension | 10 | Territory performance |
| 7 | Production | Product | 🟦 Dimension | 504 | Product catalog |
| 8 | Production | ProductSubcategory | 🟦 Dimension | 37 | Product hierarchy |
| 9 | Production | ProductCategory | 🟦 Dimension | 4 | Top-level categories |
| 10 | Sales | SalesOrderHeader | 🟩 Fact | 31,465 | Order-level transactions |
| 11 | Sales | SalesOrderDetail | 🟩 Fact | 121,317 | Line-item details |
| 12 | Person | BusinessEntityAddress | 🟨 Bridge | 19,614 | Links entities to addresses |
| 13 | Person | AddressType | 🟨 Bridge | 6 | Address type lookup |
| 14 | Sales | SpecialOffer | 🟨 Bridge | 16 | Promotions/discounts |
| 15 | Sales | SpecialOfferProduct | 🟨 Bridge | 538 | Products on promotion |
| 16 | Sales | SalesOrderHeaderSalesReason | 🟨 Bridge | 27,647 | Order purchase reasons |
| 17 | Sales | SalesReason | 🟨 Bridge | 10 | Reason code lookup |

---

## 🟦 Dimension Tables (Hubs)

Dimension tables provide **descriptive context** for analysis. They answer "Who?", "What?", "Where?" questions.

---

### Sales.Customer

**Purpose**: Customer master table. One row per customer. Core entity for all customer analytics.

**Primary Use Cases**: 
- Customer segmentation (Individual vs Store)
- Territory-based analysis
- Linking orders to people

| Column | Data Type | Keys | Description |
|--------|-----------|------|-------------|
| **CustomerID** | `int` | 🔑 PK 📊 | Primary key. Unique customer identifier. |
| **PersonID** | `int` | 🔗 FK → Person.Person.BusinessEntityID | Links to individual customer demographics. NULL for store customers. |
| **StoreID** | `int` | 🔗 FK → Sales.Store.BusinessEntityID | Links to store/business customers. NULL for individual customers. |
| **TerritoryID** | `int` | 🔗 FK → Sales.SalesTerritory.TerritoryID 📊 | Sales territory assignment. Used for geographic CLV analysis. |
| **AccountNumber** | `varchar` | | System-generated account number (computed). |
| **rowguid** | `uniqueidentifier` | | Unique GUID for merge replication. |
| **ModifiedDate** | `datetime` | | Last update timestamp. |

**Relationship Pattern**: **1:N** → Many orders per customer via `SalesOrderHeader.CustomerID`

---

### Person.Person

**Purpose**: Core person/individual information. Contains demographics and contact preferences.

**Primary Use Cases**: 
- Demographic segmentation
- Email marketing opt-ins (EmailPromotion)
- XML-based demographic analysis

| Column | Data Type | Keys | Description |
|--------|-----------|------|-------------|
| **BusinessEntityID** | `int` | 🔑 PK 🔗 FK → Person.BusinessEntity.BusinessEntityID | Primary key. Unique person identifier. |
| **PersonType** | `nchar(2)` | 📊 | Person type: **SC**=Store Contact, **IN**=Individual (retail), **SP**=Sales person, **EM**=Employee, **VC**=Vendor, **GC**=General contact |
| **NameStyle** | `bit` | | 0=Western (First Last), 1=Eastern (Last First) |
| **Title** | `nvarchar(8)` | | Courtesy title (Mr., Ms., Dr., etc.) |
| **FirstName** | `nvarchar(50)` | 📊 | First name. |
| **MiddleName** | `nvarchar(50)` | | Middle name or initial. |
| **LastName** | `nvarchar(50)` | 📊 | Last name. |
| **Suffix** | `nvarchar(10)` | | Name suffix (Jr., Sr., III, etc.) |
| **EmailPromotion** | `int` | 📊 | Email opt-in: **0**=No promotions, **1**=AdventureWorks only, **2**=AdventureWorks + partners |
| **AdditionalContactInfo** | `xml` | | XML-formatted additional contact data. |
| **Demographics** | `xml` | 📊 | XML-formatted demographics: hobbies, income, etc. (from online shoppers) |
| **rowguid** | `uniqueidentifier` | | Unique GUID for merge replication. |
| **ModifiedDate** | `datetime` | | Last update timestamp. |

**Relationship Pattern**: **1:1 or NULL** with `Sales.Customer.PersonID`

---

### Person.EmailAddress

**Purpose**: Email addresses for people. Supports email marketing campaigns.

**Primary Use Cases**: 
- Email campaign targeting
- Customer communication

| Column | Data Type | Keys | Description |
|--------|-----------|------|-------------|
| **BusinessEntityID** | `int` | 🔑 PK 🔗 FK → Person.Person.BusinessEntityID 📊 | Person owning this email address. |
| **EmailAddressID** | `int` | 🔑 PK | Unique email address ID. |
| **EmailAddress** | `nvarchar(50)` | 📊 | Actual email address. |
| **rowguid** | `uniqueidentifier` | | Unique GUID for merge replication. |
| **ModifiedDate** | `datetime` | | Last update timestamp. |

**Relationship Pattern**: **1:1** with `Person.Person.BusinessEntityID`

---

### Person.Address

**Purpose**: Physical addresses for customers, stores, and vendors. Geographic dimension.

**Primary Use Cases**: 
- Geographic segmentation (city, state, postal code)
- Shipping analysis
- Territory mapping

| Column | Data Type | Keys | Description |
|--------|-----------|------|-------------|
| **AddressID** | `int` | 🔑 PK | Primary key. Unique address identifier. |
| **AddressLine1** | `nvarchar(60)` | | First line of street address. |
| **AddressLine2** | `nvarchar(60)` | | Second line of street address (apt, suite, etc.) |
| **City** | `nvarchar(30)` | 📊 | City name. |
| **StateProvinceID** | `int` | 🔗 FK → Person.StateProvince.StateProvinceID 📊 | State/province lookup. |
| **PostalCode** | `nvarchar(15)` | 📊 | Postal/ZIP code. |
| **SpatialLocation** | `geography` | | Latitude/longitude coordinates (geospatial type). |
| **rowguid** | `uniqueidentifier` | | Unique GUID for merge replication. |
| **ModifiedDate** | `datetime` | | Last update timestamp. |

**Relationship Pattern**: **M:N** with entities via `Person.BusinessEntityAddress` bridge table

---

### Person.StateProvince

**Purpose**: State/province lookup dimension. Part of geographic hierarchy.

**Primary Use Cases**: 
- State/region-level aggregation
- Country/region rollups

| Column | Data Type | Keys | Description |
|--------|-----------|------|-------------|
| **StateProvinceID** | `int` | 🔑 PK | Primary key. Unique state/province identifier. |
| **StateProvinceCode** | `nchar(3)` | 📊 | ISO standard state/province code (e.g., "CA", "NY"). |
| **CountryRegionCode** | `nvarchar(3)` | 🔗 FK → Person.CountryRegion.CountryRegionCode 📊 | ISO country/region code (e.g., "US", "CA"). |
| **IsOnlyStateProvinceFlag** | `bit` | | 0=StateProvinceCode exists, 1=Use CountryRegionCode instead |
| **Name** | `nvarchar(50)` | 📊 | Full state/province name. |
| **TerritoryID** | `int` | 🔗 FK → Sales.SalesTerritory.TerritoryID | Sales territory assignment. |
| **rowguid** | `uniqueidentifier` | | Unique GUID for merge replication. |
| **ModifiedDate** | `datetime` | | Last update timestamp. |

**Relationship Pattern**: **1:N** → Many addresses per state

---

### Sales.SalesTerritory

**Purpose**: Sales territory dimension. Geographic sales regions.

**Primary Use Cases**: 
- Territory performance analysis
- Regional CLV comparison
- Sales quota tracking

| Column | Data Type | Keys | Description |
|--------|-----------|------|-------------|
| **TerritoryID** | `int` | 🔑 PK | Primary key. Unique territory identifier. |
| **Name** | `nvarchar(50)` | 📊 | Territory name (e.g., "Northwest", "Canada", "France"). |
| **CountryRegionCode** | `nvarchar(3)` | 🔗 FK → Person.CountryRegion.CountryRegionCode | ISO country/region code. |
| **Group** | `nvarchar(50)` | 📊 | Geographic group (e.g., "North America", "Europe", "Pacific"). |
| **SalesYTD** | `money` | 📊 | Year-to-date sales for territory. |
| **SalesLastYear** | `money` | 📊 | Previous year sales for territory. |
| **CostYTD** | `money` | | Year-to-date costs for territory. |
| **CostLastYear** | `money` | | Previous year costs for territory. |
| **rowguid** | `uniqueidentifier` | | Unique GUID for merge replication. |
| **ModifiedDate** | `datetime` | | Last update timestamp. |

**Relationship Pattern**: **1:N** → Many customers/orders per territory

---

### Production.Product

**Purpose**: Product catalog/master. Contains pricing, cost, and product attributes.

**Primary Use Cases**: 
- Product affinity analysis
- Margin analysis (ListPrice vs StandardCost)
- Category/subcategory hierarchies

| Column | Data Type | Keys | Description |
|--------|-----------|------|-------------|
| **ProductID** | `int` | 🔑 PK | Primary key. Unique product identifier. |
| **Name** | `nvarchar(50)` | 📊 | Product name. |
| **ProductNumber** | `nvarchar(25)` | | Unique product number (SKU). |
| **MakeFlag** | `bit` | | 0=Purchased, 1=Manufactured in-house |
| **FinishedGoodsFlag** | `bit` | 📊 | 0=Not salable (component), 1=Salable item |
| **Color** | `nvarchar(15)` | | Product color. |
| **SafetyStockLevel** | `smallint` | | Minimum inventory level. |
| **ReorderPoint** | `smallint` | | Reorder trigger level. |
| **StandardCost** | `money` | 📊 | Product cost (for margin calculation). |
| **ListPrice** | `money` | 📊 | Selling price. |
| **Size** | `nvarchar(5)` | | Product size (XS, S, M, L, XL, etc.) |
| **SizeUnitMeasureCode** | `nchar(3)` | 🔗 FK → Production.UnitMeasure.UnitMeasureCode | Unit of measure for Size. |
| **WeightUnitMeasureCode** | `nchar(3)` | 🔗 FK → Production.UnitMeasure.UnitMeasureCode | Unit of measure for Weight. |
| **Weight** | `decimal(8,2)` | | Product weight. |
| **DaysToManufacture** | `int` | | Manufacturing lead time. |
| **ProductLine** | `nchar(2)` | 📊 | **R**=Road, **M**=Mountain, **T**=Touring, **S**=Standard |
| **Class** | `nchar(2)` | 📊 | **H**=High, **M**=Medium, **L**=Low |
| **Style** | `nchar(2)` | 📊 | **W**=Womens, **M**=Mens, **U**=Universal |
| **ProductSubcategoryID** | `int` | 🔗 FK → Production.ProductSubcategory.ProductSubcategoryID 📊 | Product subcategory (hierarchy level 2). |
| **ProductModelID** | `int` | 🔗 FK → Production.ProductModel.ProductModelID | Product model grouping. |
| **SellStartDate** | `datetime` | 📊 | Date product became available for sale. |
| **SellEndDate** | `datetime` | | Date product was no longer available. |
| **DiscontinuedDate** | `datetime` | | Date product was discontinued. |
| **rowguid** | `uniqueidentifier` | | Unique GUID for merge replication. |
| **ModifiedDate** | `datetime` | | Last update timestamp. |

**Relationship Pattern**: **1:N** → Many order line items per product

---

### Production.ProductSubcategory

**Purpose**: Product subcategory dimension (middle level of hierarchy).

**Primary Use Cases**: 
- Product hierarchy navigation
- Category-level sales analysis

| Column | Data Type | Keys | Description |
|--------|-----------|------|-------------|
| **ProductSubcategoryID** | `int` | 🔑 PK | Primary key. Unique subcategory identifier. |
| **ProductCategoryID** | `int` | 🔗 FK → Production.ProductCategory.ProductCategoryID 📊 | Parent category. |
| **Name** | `nvarchar(50)` | 📊 | Subcategory name (e.g., "Mountain Bikes", "Road Bikes"). |
| **rowguid** | `uniqueidentifier` | | Unique GUID for merge replication. |
| **ModifiedDate** | `datetime` | | Last update timestamp. |

**Relationship Pattern**: **1:N** → Many products per subcategory

---

### Production.ProductCategory

**Purpose**: Top-level product category dimension.

**Primary Use Cases**: 
- High-level category analysis
- Product hierarchy root

| Column | Data Type | Keys | Description |
|--------|-----------|------|-------------|
| **ProductCategoryID** | `int` | 🔑 PK | Primary key. Unique category identifier. |
| **Name** | `nvarchar(50)` | 📊 | Category name (e.g., "Bikes", "Clothing", "Accessories", "Components"). |
| **rowguid** | `uniqueidentifier` | | Unique GUID for merge replication. |
| **ModifiedDate** | `datetime` | | Last update timestamp. |

**Relationship Pattern**: **1:N** → Many subcategories per category

---

## 🟩 Fact Tables (Transactions)

Fact tables contain **measurable events** and **metrics**. They answer "How much?", "How many?", "When?" questions.

---

### Sales.SalesOrderHeader

**Purpose**: Order-level transaction fact table. Contains order totals, dates, and customer references.

**Primary Use Cases**: 
- RFM analysis (Recency via OrderDate, Frequency via COUNT, Monetary via TotalDue)
- Cohort analysis (first OrderDate = cohort assignment)
- Revenue trends over time

| Column | Data Type | Keys | Description |
|--------|-----------|------|-------------|
| **SalesOrderID** | `int` | 🔑 PK 📊 | Primary key. Unique order identifier. |
| **RevisionNumber** | `tinyint` | | Order revision tracking. |
| **OrderDate** | `datetime` | 📊 | **CRITICAL**: Order creation date. Used for recency, cohorts, trends. |
| **DueDate** | `datetime` | | Expected delivery date. |
| **ShipDate** | `datetime` | 📊 | Actual ship date. |
| **Status** | `tinyint` | 📊 | **1**=In process, **2**=Approved, **3**=Backordered, **4**=Rejected, **5**=Shipped, **6**=Cancelled |
| **OnlineOrderFlag** | `bit` | 📊 | 0=Sales person order, 1=Online customer order |
| **SalesOrderNumber** | `nvarchar(25)` | | Human-readable order number. |
| **PurchaseOrderNumber** | `nvarchar(25)` | | Customer's PO number. |
| **AccountNumber** | `nvarchar(15)` | | Financial accounting reference. |
| **CustomerID** | `int` | 🔗 FK → Sales.Customer.CustomerID 📊 | **CRITICAL**: Customer who placed the order. |
| **SalesPersonID** | `int` | 🔗 FK → Sales.SalesPerson.BusinessEntityID | Sales rep assigned to order. |
| **TerritoryID** | `int` | 🔗 FK → Sales.SalesTerritory.TerritoryID 📊 | Territory where sale occurred. |
| **BillToAddressID** | `int` | 🔗 FK → Person.Address.AddressID | Billing address. |
| **ShipToAddressID** | `int` | 🔗 FK → Person.Address.AddressID | Shipping address. |
| **ShipMethodID** | `int` | 🔗 FK → Purchasing.ShipMethod.ShipMethodID | Shipping method used. |
| **CreditCardID** | `int` | 🔗 FK → Sales.CreditCard.CreditCardID | Payment method. |
| **CreditCardApprovalCode** | `varchar(15)` | | Credit card approval code. |
| **CurrencyRateID** | `int` | 🔗 FK → Sales.CurrencyRate.CurrencyRateID | Exchange rate applied. |
| **SubTotal** | `money` | 📊 | Order subtotal (SUM of line items). |
| **TaxAmt** | `money` | 📊 | Tax amount. |
| **Freight** | `money` | 📊 | Shipping cost. |
| **TotalDue** | `money` | 📊 | **CRITICAL**: Total order value = SubTotal + TaxAmt + Freight. Used for Monetary (RFM). |
| **Comment** | `nvarchar(128)` | | Sales rep comments. |
| **rowguid** | `uniqueidentifier` | | Unique GUID for merge replication. |
| **ModifiedDate** | `datetime` | | Last update timestamp. |

**Relationship Pattern**: **N:1** → Many orders per customer

---

### Sales.SalesOrderDetail

**Purpose**: Line-item transaction fact table. One row per product per order.

**Primary Use Cases**: 
- Product-level revenue analysis
- Basket analysis (products bought together)
- Discount effectiveness (UnitPriceDiscount)
- Gross margin calculation (UnitPrice vs Product.StandardCost)

| Column | Data Type | Keys | Description |
|--------|-----------|------|-------------|
| **SalesOrderID** | `int` | 🔑 PK 🔗 FK → Sales.SalesOrderHeader.SalesOrderID 📊 | Order this line item belongs to. |
| **SalesOrderDetailID** | `int` | 🔑 PK | Unique line item ID within order. |
| **CarrierTrackingNumber** | `nvarchar(25)` | | Shipment tracking number. |
| **OrderQty** | `smallint` | 📊 | Quantity ordered. |
| **ProductID** | `int` | 🔗 FK → Sales.SpecialOfferProduct.ProductID 📊 | Product sold (via bridge to Product table). |
| **SpecialOfferID** | `int` | 🔗 FK → Sales.SpecialOfferProduct.SpecialOfferID 📊 | Promotion applied to this line item. |
| **UnitPrice** | `money` | 📊 | Price per unit (may differ from Product.ListPrice). |
| **UnitPriceDiscount** | `money` | 📊 | Discount amount per unit. |
| **LineTotal** | `numeric(38,6)` | 📊 | **Computed**: UnitPrice × (1 - UnitPriceDiscount) × OrderQty |
| **rowguid** | `uniqueidentifier` | | Unique GUID for merge replication. |
| **ModifiedDate** | `datetime` | | Last update timestamp. |

**Relationship Pattern**: **N:1** → Many line items per order

---

## 🟨 Bridge/Lookup Tables

Bridge tables enable **many-to-many relationships** or provide small **reference datasets**.

---

### Person.BusinessEntityAddress

**Purpose**: Many-to-many bridge between entities (Person, Store, Vendor) and addresses.

**Primary Use Cases**: 
- Linking customers to billing/shipping addresses
- Handling multiple addresses per customer

| Column | Data Type | Keys | Description |
|--------|-----------|------|-------------|
| **BusinessEntityID** | `int` | 🔑 PK 🔗 FK → Person.BusinessEntity.BusinessEntityID | Entity (Person/Store/Vendor) ID. |
| **AddressID** | `int` | 🔑 PK 🔗 FK → Person.Address.AddressID | Address ID. |
| **AddressTypeID** | `int` | 🔑 PK 🔗 FK → Person.AddressType.AddressTypeID | Type of address (Billing, Home, Shipping, etc.) |
| **rowguid** | `uniqueidentifier` | | Unique GUID for merge replication. |
| **ModifiedDate** | `datetime` | | Last update timestamp. |

**Relationship Pattern**: **M:N** → Many entities can have many addresses

---

### Person.AddressType

**Purpose**: Lookup table for address types.

**Primary Use Cases**: 
- Filtering to billing vs shipping addresses
- Address categorization

| Column | Data Type | Keys | Description |
|--------|-----------|------|-------------|
| **AddressTypeID** | `int` | 🔑 PK | Primary key. Unique address type ID. |
| **Name** | `nvarchar(50)` | 📊 | Address type name (e.g., "Billing", "Home", "Shipping", "Main Office"). |
| **rowguid** | `uniqueidentifier` | | Unique GUID for merge replication. |
| **ModifiedDate** | `datetime` | | Last update timestamp. |

**Relationship Pattern**: **1:N** → Many addresses per type

---

### Sales.SpecialOffer

**Purpose**: Promotional offer/discount metadata.

**Primary Use Cases**: 
- Discount/promotion analysis
- Campaign effectiveness tracking
- Incremental revenue attribution

| Column | Data Type | Keys | Description |
|--------|-----------|------|-------------|
| **SpecialOfferID** | `int` | 🔑 PK | Primary key. Unique offer ID. |
| **Description** | `nvarchar(255)` | 📊 | Offer description (e.g., "No Discount", "Volume Discount 11 to 14"). |
| **DiscountPct** | `smallmoney` | 📊 | Discount percentage (0.00 to 1.00). |
| **Type** | `nvarchar(50)` | 📊 | Discount type (e.g., "Seasonal Discount", "Volume Discount"). |
| **Category** | `nvarchar(50)` | 📊 | Target category (e.g., "Reseller", "Customer"). |
| **StartDate** | `datetime` | 📊 | Promotion start date. |
| **EndDate** | `datetime` | 📊 | Promotion end date. |
| **MinQty** | `int` | | Minimum quantity to qualify. |
| **MaxQty** | `int` | | Maximum quantity eligible for discount. |
| **rowguid** | `uniqueidentifier` | | Unique GUID for merge replication. |
| **ModifiedDate** | `datetime` | | Last update timestamp. |

**Relationship Pattern**: **M:N** with products via `SpecialOfferProduct` bridge

---

### Sales.SpecialOfferProduct

**Purpose**: Many-to-many bridge between special offers and products.

**Primary Use Cases**: 
- Identifying which products are on promotion
- Linking discounts to specific products in `SalesOrderDetail`

| Column | Data Type | Keys | Description |
|--------|-----------|------|-------------|
| **SpecialOfferID** | `int` | 🔑 PK 🔗 FK → Sales.SpecialOffer.SpecialOfferID 📊 | Promotion/offer ID. |
| **ProductID** | `int` | 🔑 PK 🔗 FK → Production.Product.ProductID 📊 | Product ID eligible for this offer. |
| **rowguid** | `uniqueidentifier` | | Unique GUID for merge replication. |
| **ModifiedDate** | `datetime` | | Last update timestamp. |

**Relationship Pattern**: **M:N** → Many offers can apply to many products

---

### Sales.SalesOrderHeaderSalesReason

**Purpose**: Many-to-many bridge between orders and purchase reasons.

**Primary Use Cases**: 
- Understanding why customers buy (marketing attribution)
- Segmenting orders by motivation

| Column | Data Type | Keys | Description |
|--------|-----------|------|-------------|
| **SalesOrderID** | `int` | 🔑 PK 🔗 FK → Sales.SalesOrderHeader.SalesOrderID 📊 | Order ID. |
| **SalesReasonID** | `int` | 🔑 PK 🔗 FK → Sales.SalesReason.SalesReasonID 📊 | Reason code. |
| **ModifiedDate** | `datetime` | | Last update timestamp. |

**Relationship Pattern**: **M:N** → One order can have multiple reasons

---

### Sales.SalesReason

**Purpose**: Lookup table for purchase motivations/reasons.

**Primary Use Cases**: 
- Marketing attribution
- Customer motivation analysis

| Column | Data Type | Keys | Description |
|--------|-----------|------|-------------|
| **SalesReasonID** | `int` | 🔑 PK | Primary key. Unique reason ID. |
| **Name** | `nvarchar(50)` | 📊 | Reason name (e.g., "Price", "Quality", "Review", "Manufacturer"). |
| **ReasonType** | `nvarchar(50)` | 📊 | Category (e.g., "Marketing", "Promotion", "Other"). |
| **ModifiedDate** | `datetime` | | Last update timestamp. |

**Relationship Pattern**: **1:N** → Many orders can reference the same reason

---

## 🛠️ SQL Query Source

This data dictionary was generated using the following SQL query against the AdventureWorks database:

**📂 Location**: `sql/metadata-exploration-v2.sql` (Query #11)

```sql
-- Extract column descriptions with schema, PK, and FK information for the 17 tables
SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName,
    TYPE_NAME(c.user_type_id) AS DataType,
    CASE WHEN EXISTS (
        SELECT 1 FROM sys.indexes AS i
        INNER JOIN sys.index_columns AS ic 
            ON i.object_id = ic.object_id AND i.index_id = ic.index_id
        WHERE i.is_primary_key = 1 
            AND ic.object_id = t.object_id 
            AND ic.column_id = c.column_id
    ) THEN 'PK' ELSE '' END AS IsPK,
    fk.ReferencedSchema AS FK_ReferencesSchema,
    fk.ReferencedTable AS FK_ReferencesTable,
    fk.ReferencedColumn AS FK_ReferencesColumn,
    CAST(ep.value AS NVARCHAR(500)) AS ColumnDescription
FROM sys.tables AS t
INNER JOIN sys.columns AS c ON t.object_id = c.object_id
LEFT JOIN sys.extended_properties AS ep 
    ON ep.major_id = t.object_id AND ep.minor_id = c.column_id AND ep.class = 1
LEFT JOIN (
    SELECT fkc.parent_object_id, fkc.parent_column_id,
           SCHEMA_NAME(ref_t.schema_id) AS ReferencedSchema,
           ref_t.name AS ReferencedTable,
           ref_c.name AS ReferencedColumn
    FROM sys.foreign_key_columns AS fkc
    INNER JOIN sys.tables AS ref_t ON fkc.referenced_object_id = ref_t.object_id
    INNER JOIN sys.columns AS ref_c 
        ON fkc.referenced_object_id = ref_c.object_id 
        AND fkc.referenced_column_id = ref_c.column_id
) AS fk ON fk.parent_object_id = t.object_id AND fk.parent_column_id = c.column_id
WHERE 
    (SCHEMA_NAME(t.schema_id) = 'Sales' AND t.name IN ('Customer', 'SalesOrderHeader', 'SalesOrderDetail', 'SalesTerritory', 'SpecialOffer', 'SpecialOfferProduct', 'SalesOrderHeaderSalesReason', 'SalesReason'))
    OR (SCHEMA_NAME(t.schema_id) = 'Person' AND t.name IN ('Person', 'EmailAddress', 'Address', 'StateProvince', 'BusinessEntityAddress', 'AddressType'))
    OR (SCHEMA_NAME(t.schema_id) = 'Production' AND t.name IN ('Product', 'ProductSubcategory', 'ProductCategory'))
ORDER BY SchemaName, TableName, c.column_id;
```

**To regenerate or extend**: Run the query in SQL Server Management Studio (SSMS) or Azure Data Studio, export results, and update this document.

---

## 📚 Related Documentation

- **[Table Selection Methodology](./table-selection-methodology.md)** - How these 17 tables were chosen
- **[ERD Diagram (DBML)](./erd-customer-analytics-enhanced.dbml)** - Visual entity-relationship diagram
- **[Metadata Exploration Scripts](../sql/metadata-exploration-v2.sql)** - Complete discovery queries

---

**📅 Last Updated**: Feb 2026  
**👤 Author**: Azab Basha  
**🏢 Project**: AdventureWorks End-to-End Customer Analytics

---

**🎯 Ready to use this as your single source of truth for:**
- ✅ Building the ERD in dbdiagram.io
- ✅ Creating SQL analysis queries (RFM, CLV, cohorts)
- ✅ Designing the gold layer star schema
- ✅ Onboarding new team members to the data model
