# 🗺️ Interactive ERD: Customer Analytics Model

**Purpose**: Visual representation of the 17 core tables used for customer analytics in AdventureWorks 2025.

**Quick Links**:
- 📖 [Data Dictionary](./adventureworks-customer-analytics-data-dictionary.md) - Complete column descriptions
- 📋 [Table Selection Methodology](./table-selection-methodology.md) - How these tables were chosen
- 💾 [DBML Source](./erd-customer-analytics-enhanced.dbml) - Original ERD definition for dbdiagram.io

---

## 📊 Entity Relationship Diagram

```mermaid
erDiagram
    %% =============================
    %% CUSTOMER & PERSON ENTITIES
    %% =============================
    
    Sales_Customer ||--o{ Sales_SalesOrderHeader : "places orders"
    Sales_Customer }o--|| Person_Person : "is a"
    Sales_Customer }o--|| Sales_SalesTerritory : "belongs to"
    
    Person_Person ||--o{ Person_EmailAddress : "has"
    Person_Person ||--o{ Person_BusinessEntityAddress : "has addresses"
    
    Person_BusinessEntityAddress }o--|| Person_Address : "links to"
    Person_BusinessEntityAddress }o--|| Person_AddressType : "is of type"
    
    Person_Address }o--|| Person_StateProvince : "located in"
    Person_StateProvince }o--|| Sales_SalesTerritory : "part of"
    
    %% =============================
    %% ORDER RELATIONSHIPS
    %% =============================
    
    Sales_SalesOrderHeader ||--o{ Sales_SalesOrderDetail : "contains"
    Sales_SalesOrderHeader }o--|| Sales_SalesTerritory : "sold in"
    Sales_SalesOrderHeader }o--|| Person_Address : "bill to"
    Sales_SalesOrderHeader }o--|| Person_Address : "ship to"
    Sales_SalesOrderHeader ||--o{ Sales_SalesOrderHeaderSalesReason : "has reasons"
    
    Sales_SalesOrderHeaderSalesReason }o--|| Sales_SalesReason : "references"
    
    %% =============================
    %% PRODUCT RELATIONSHIPS
    %% =============================
    
    Sales_SalesOrderDetail }o--|| Sales_SpecialOfferProduct : "uses offer"
    
    Sales_SpecialOfferProduct }o--|| Production_Product : "applies to"
    Sales_SpecialOfferProduct }o--|| Sales_SpecialOffer : "is part of"
    
    Production_Product }o--|| Production_ProductSubcategory : "belongs to"
    Production_ProductSubcategory }o--|| Production_ProductCategory : "belongs to"

    %% =============================
    %% TABLE DEFINITIONS - DIMENSIONS
    %% =============================

    Sales_Customer {
        int CustomerID PK "Primary key"
        int PersonID FK "Links to Person"
        int StoreID FK "Store reference"
        int TerritoryID FK "Territory reference"
        varchar AccountNumber "Unique account number"
        datetime ModifiedDate "Last modified"
    }

    Person_Person {
        int BusinessEntityID PK "Primary key"
        nchar PersonType "SC,IN,SP,EM,VC,GC"
        nvarchar FirstName "First name"
        nvarchar LastName "Last name"
        int EmailPromotion "0-2 email preference"
        xml Demographics "Income, hobbies"
        datetime ModifiedDate "Last modified"
    }

    Person_EmailAddress {
        int BusinessEntityID PK,FK "Links to Person"
        int EmailAddressID PK "Email ID"
        nvarchar EmailAddress "Email address"
        datetime ModifiedDate "Last modified"
    }

    Person_Address {
        int AddressID PK "Primary key"
        nvarchar AddressLine1 "Street address"
        nvarchar City "City name"
        int StateProvinceID FK "State/Province"
        nvarchar PostalCode "ZIP/Postal code"
        datetime ModifiedDate "Last modified"
    }

    Person_StateProvince {
        int StateProvinceID PK "Primary key"
        nchar StateProvinceCode "State code"
        nvarchar Name "State name"
        int TerritoryID FK "Territory link"
        datetime ModifiedDate "Last modified"
    }

    Sales_SalesTerritory {
        int TerritoryID PK "Primary key"
        nvarchar Name "Territory name"
        nvarchar Group "Geographic group"
        money SalesYTD "Year-to-date sales"
        money SalesLastYear "Last year sales"
        datetime ModifiedDate "Last modified"
    }

    Person_BusinessEntityAddress {
        int BusinessEntityID PK,FK "Links to Person"
        int AddressID PK,FK "Links to Address"
        int AddressTypeID PK,FK "Address type"
        datetime ModifiedDate "Last modified"
    }

    Person_AddressType {
        int AddressTypeID PK "Primary key"
        nvarchar Name "Billing,Shipping,Home"
        datetime ModifiedDate "Last modified"
    }

    Production_Product {
        int ProductID PK "Primary key"
        nvarchar Name "Product name"
        money StandardCost "Cost price"
        money ListPrice "Selling price"
        int ProductSubcategoryID FK "Subcategory"
        datetime SellStartDate "Start date"
        datetime SellEndDate "End date"
        datetime ModifiedDate "Last modified"
    }

    Production_ProductSubcategory {
        int ProductSubcategoryID PK "Primary key"
        int ProductCategoryID FK "Category"
        nvarchar Name "Subcategory name"
        datetime ModifiedDate "Last modified"
    }

    Production_ProductCategory {
        int ProductCategoryID PK "Primary key"
        nvarchar Name "Category name"
        datetime ModifiedDate "Last modified"
    }

    %% =============================
    %% TABLE DEFINITIONS - FACTS
    %% =============================

    Sales_SalesOrderHeader {
        int SalesOrderID PK "Primary key"
        datetime OrderDate "Order date - RFM KEY"
        int CustomerID FK "Customer reference"
        int TerritoryID FK "Territory reference"
        int BillToAddressID FK "Billing address"
        int ShipToAddressID FK "Shipping address"
        money SubTotal "Pre-tax subtotal"
        money TaxAmt "Tax amount"
        money Freight "Shipping cost"
        money TotalDue "TOTAL ORDER VALUE"
        datetime ModifiedDate "Last modified"
    }

    Sales_SalesOrderDetail {
        int SalesOrderID PK,FK "Order reference"
        int SalesOrderDetailID PK "Line item ID"
        int ProductID FK "Product reference"
        int SpecialOfferID FK "Offer reference"
        smallint OrderQty "Quantity ordered"
        money UnitPrice "Unit price"
        money UnitPriceDiscount "Discount amount"
        numeric LineTotal "Line item revenue"
        datetime ModifiedDate "Last modified"
    }

    %% =============================
    %% TABLE DEFINITIONS - PROMOTIONS
    %% =============================

    Sales_SpecialOffer {
        int SpecialOfferID PK "Primary key"
        nvarchar Description "Offer description"
        smallmoney DiscountPct "Discount percentage"
        nvarchar Type "Offer type"
        datetime StartDate "Start date"
        datetime EndDate "End date"
        datetime ModifiedDate "Last modified"
    }

    Sales_SpecialOfferProduct {
        int SpecialOfferID PK,FK "Offer reference"
        int ProductID PK,FK "Product reference"
        datetime ModifiedDate "Last modified"
    }

    Sales_SalesOrderHeaderSalesReason {
        int SalesOrderID PK,FK "Order reference"
        int SalesReasonID PK,FK "Reason reference"
        datetime ModifiedDate "Last modified"
    }

    Sales_SalesReason {
        int SalesReasonID PK "Primary key"
        nvarchar Name "Reason name"
        nvarchar ReasonType "Reason category"
        datetime ModifiedDate "Last modified"
    }
```

---

## 📋 Table Categories

### 🟦 **Dimension Tables (9)**

Customer & demographic attributes that answer "WHO":

| Schema | Table | Purpose |
|--------|-------|---------|
| Sales | Customer | Customer master - RFM/CLV driver |
| Person | Person | Demographics (name, email promo preference) |
| Person | EmailAddress | Contact information for campaigns |
| Person | Address | Geographic analysis |
| Person | StateProvince | State/province dimension |
| Sales | SalesTerritory | Regional CLV and segmentation |
| Production | Product | Product catalog |
| Production | ProductSubcategory | Product hierarchy |
| Production | ProductCategory | Top-level categories |

### 🟩 **Fact Tables (2)**

Transactional data that answers "WHAT happened":

| Schema | Table | Grain | Key Metrics |
|--------|-------|-------|-------------|
| Sales | SalesOrderHeader | Order | OrderDate (RFM), TotalDue (Monetary), CustomerID (Frequency) |
| Sales | SalesOrderDetail | Line item | OrderQty, UnitPrice, LineTotal |

### 🟨 **Bridge Tables (6)**

Many-to-many relationship resolvers:

| Schema | Table | Purpose |
|--------|-------|---------|
| Person | BusinessEntityAddress | Links persons to addresses |
| Person | AddressType | Address type lookup |
| Sales | SpecialOffer | Promotion metadata |
| Sales | SpecialOfferProduct | Links offers to products |
| Sales | SalesOrderHeaderSalesReason | Links orders to reasons |
| Sales | SalesReason | Purchase motivation lookup |

---

## 🎯 How This ERD Answers the 7 Strategic Questions

### Q1: Who are our most valuable customers?
**Tables**: `Customer` → `SalesOrderHeader` → `SalesOrderDetail`  
**Metrics**: TotalDue (Monetary), COUNT(SalesOrderID) (Frequency), OrderDate (Recency)

### Q2: Which customers are unprofitable or risky?
**Tables**: `Customer` + `SalesOrderHeader` + `SalesOrderDetail`  
**Metrics**: Recency (DATEDIFF), Frequency (COUNT), Discount rate (UnitPriceDiscount)

### Q3: How do customers differ in behavior?
**Tables**: `Customer` + `SalesOrderHeader` + `Product` + `ProductCategory`  
**Metrics**: RFM scores, Basket size (AVG OrderQty), Category diversity

### Q4: Are newer customer cohorts better or worse?
**Tables**: `Customer` + `SalesOrderHeader`  
**Metrics**: Cohort (MIN OrderDate), Retention rate, Revenue per cohort

### Q5: Who is likely still active vs "dead"?
**Tables**: `Customer` + `SalesOrderHeader`  
**Metrics**: Last purchase date, Inter-purchase time, BTYD inputs

### Q6: What actions should we take?
**Tables**: `Customer` + `SalesOrderHeader` + `SpecialOffer` + `SpecialOfferProduct`  
**Metrics**: Predicted CLV, Discount response, Incremental lift

### Q7: What is the value of our customer base (CBCV)?
**Tables**: All tables (aggregated)  
**Metrics**: Aggregated CLV, Retention curves, Cohort performance

---

## 🔗 Relationship Cardinalities

| Relationship | Type | Description |
|-------------|------|-------------|
| Customer → Person | Many-to-One | Each customer links to one person |
| Customer → SalesOrderHeader | One-to-Many | Each customer has multiple orders |
| SalesOrderHeader → SalesOrderDetail | One-to-Many | Each order has multiple line items |
| SalesOrderDetail → SpecialOfferProduct | Many-to-One | Line items reference offer+product combo |
| Product → ProductSubcategory | Many-to-One | Products belong to subcategories |
| Person → EmailAddress | One-to-Many | Persons can have multiple emails |
| Address → StateProvince | Many-to-One | Addresses are in one state/province |

---

## 💡 Usage Tips

1. **Click any table** in the diagram to focus on it
2. **Zoom in/out** using browser controls (Ctrl/Cmd + Mouse wheel)
3. **View DBML source** at [erd-customer-analytics-enhanced.dbml](./erd-customer-analytics-enhanced.dbml) for detailed field definitions
4. **Check data dictionary** at [adventureworks-customer-analytics-data-dictionary.md](./adventureworks-customer-analytics-data-dictionary.md) for column descriptions

---

## 📝 Notes

- **PK** = Primary Key
- **FK** = Foreign Key
- **Composite PKs** marked as `PK,FK` when column is both
- **Key date column**: `SalesOrderHeader.OrderDate` drives all temporal analysis
- **Key monetary column**: `SalesOrderHeader.TotalDue` drives CLV calculations

---

**Last Updated**: 2026-02-07  
**Source**: AdventureWorks 2025 Database  
**Scope**: 17 tables optimized for Q1-Q7 customer analytics
