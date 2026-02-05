# Table Selection Methodology for Customer Analytics

## Purpose

Document which tables to include for customer analytics (RFM, CLV, cohorts, retention, behavior, targeting) and why each was chosen. This file explains the selection criteria, recommended shortlist, mapping to your analytical questions, and quick steps to validate and retrieve the tables using the `sql/metadata-exploration-v2.sql` script.

## Selection Principles

1. **Business relevance**  
   Tables must contain customer identifiers, transactions, or descriptive attributes used directly in the metrics (orders, line items, products, geography, contact).

2. **Temporal coverage**  
   Tables must include date/time fields or link to tables that do; necessary for recency, cohorts, and trend analyses.

3. **Relationship visibility**  
   Tables must be connected via foreign keys (FKs) to allow joining customer → orders → line items → product dimensions.

4. **Data volume & stability**  
   Prioritize tables with measurable row counts; large tables are likely facts, small tables often dimensions/lookups.

5. **Documentation & semantics**  
   Prefer tables with extended properties/descriptions when available.

## How to Use `metadata-exploration-v2.sql` for Selection

1. **Run Query #3 – Customer Analytics-Focused Table Finder**  
   - Gets an initial list of candidate tables based on names like `Customer`, `Sales`, `Order`, `Product`, `Person`, `Address`.

2. **Run Query #7 – One Query to Rule Them All**  
   - Shows, per table:
     - Row counts and size (MB)
     - Incoming/Outgoing FK counts
     - Inferred table role: `Hub (Dimension)`, `Spoke (Fact)`, `Bridge/Lookup`, `Standalone`
     - Date column count and list
     - AnalyticsCategory (Customer / Transaction / Product / Person / Location / Other)
     - Optional description

3. **Run Query #4 and #5 – Relationship Discovery**  
   - Query #4: Hub/Spoke analysis for table roles.  
   - Query #5: Simple FK map with FK density for each table.

4. **Shortlist ~10–15 tables using these filters:**
   - `AnalyticsCategory` IN (`Customer`, `Transaction`, `Product`, `Person`, `Location`)
   - `TableRole` IN (`Hub (Dimension)`, `Spoke (Fact)`)
   - `DateColumnCount > 0` (preferable)
   - `TotalRows` is non-trivial (not tiny reference tables unless needed)

## Core Table Shortlist (Recommended)

These tables are the core for your Task 3 questions (RFM, CLV, cohorts, retention, behavior, targeting):

### Customer & Person

- **`Sales.Customer`**
  - **Why:** Customer master – core customer identifier used in sales.
  - **Links:** To `Sales.SalesOrderHeader` (CustomerID), and often to `Person.Person` (PersonID / BusinessEntityID).
  - **Supports:**
    - RFM and CLV (customer-level aggregation)
    - Pareto (80/20) by revenue
    - High-value segment definitions
    - Targeting and campaign eligibility logic

- **`Person.Person`**
  - **Why:** Holds person-level demographic attributes (name, type, etc.).
  - **Supports:**
    - High-value segments (B2B vs B2C, names, possible personas)
    - Enrichment of customer entity in the ERD and semantic model

- **`Person.EmailAddress`**
  - **Why:** Customer email/contact for outreach and campaign execution.
  - **Supports:**
    - “Which customers should we prioritize for action?” (reachable high-value customers)
    - Building lists for experiments and promotions

### Orders & Line Items

- **`Sales.SalesOrderHeader`**
  - **Why:** Order-level fact table:
    - `OrderDate`, `DueDate`, `ShipDate`
    - `CustomerID`, `TerritoryID`, monetary fields (`SubTotal`, `TaxAmt`, `Freight`, `TotalDue`)
  - **Supports:**
    - RFM (Recency via `OrderDate`, Frequency via count of `SalesOrderID`, Monetary via `TotalDue`)
    - CLV ranking and CLV trends over time
    - Cohorts (first order date as cohort start)
    - Revenue concentration and Pareto analysis
    - CBCV (customer base commercial value) as aggregated CLV base

- **`Sales.SalesOrderDetail`**
  - **Why:** Line-level fact for product-level behavior:
    - `ProductID`, `OrderQty`, `UnitPrice`, `LineTotal`
  - **Supports:**
    - Basket size (average `OrderQty` and number of lines per order)
    - Product/category affinity and cross-sell/upsell signals
    - Revenue contribution by product and category
    - Behavioral drivers behind spend and frequency

### Product & Categories

- **`Production.Product`**
  - **Why:** Product master with price, cost, and product attributes.
  - **Supports:**
    - Product performance analysis
    - High-value product identification
    - Product-level CLV and cross-sell analysis

- **`Production.ProductSubcategory` / `Production.ProductCategory`**
  - **Why:** Product hierarchy (subcategory → category).
  - **Supports:**
    - Category-level revenue concentration
    - Portfolio-level behavior (which categories drive high-value customers)
    - Cross-category affinity

### Geography & Territory

- **`Sales.SalesTerritory`**
  - **Why:** Territory dimension for region and group.
  - **Supports:**
    - CLV and revenue by region
    - Pareto by territory
    - Regional segment performance and value evolution

- **`Person.Address` / `Person.StateProvince`**
  - **Why:** Location attributes for customers.
  - **Supports:**
    - Geographic segmentation of high-value customers
    - Context for territory performance

### Experiments, Promotions, Reasons (Optional but Valuable)

- **`Sales.SpecialOffer`**
  - **Why:** Promotions and discounts metadata.
  - **Supports:**
    - Promotion effectiveness
    - A/B and what-if scenarios

- **`Sales.SalesOrderHeaderSalesReason` + `Sales.SalesReason`**
  - **Why:** Stores reasons/motivation for sales orders.
  - **Supports:**
    - Behavior and motivation analysis
    - Which reasons correlate with higher CLV or retention

- **`Sales.CreditCard`** (optional)
  - **Why:** Payment method attributes.
  - **Supports:**
    - Payment behavior segmentation
    - Potential risk/fraud patterns (advanced)

## Mapping Tables to Task 3 Questions

### Q1 – Who are our most valuable customers?

- **Tables:**
  - `Sales.Customer`
  - `Sales.SalesOrderHeader`
  - `Sales.SalesOrderDetail`
  - `Person.Person` (for segment context)
- **Metrics:**
  - RFM scores from orders
  - CLV approximation via historical revenue (TotalDue / LineTotal)
  - Pareto: top 20% of customers by revenue share
  - High-value segments based on spend + frequency

### Q2 – How is customer value distributed and evolving over time?

- **Tables:**
  - `Sales.SalesOrderHeader`
  - `Sales.SalesOrderDetail`
  - `Sales.SalesTerritory`
- **Metrics:**
  - CLV trend by acquisition cohort or region
  - Revenue concentration over time
  - Segment migrations (e.g., high → medium, medium → low)

### Q3 – How well do we retain customers across cohorts?

- **Tables:**
  - `Sales.Customer`
  - `Sales.SalesOrderHeader`
- **Metrics:**
  - Cohorts defined by first `OrderDate`
  - Repeat purchase rate per cohort
  - Churn curves / survival approximations from inter-purchase times

### Q4 – What behaviors drive conversion, frequency, and spend?

- **Tables:**
  - `Sales.SalesOrderDetail`
  - `Sales.SalesOrderHeader`
  - `Production.Product`, `Production.ProductCategory`, `Production.ProductSubcategory`
- **Metrics:**
  - Basket size (items per order, value per basket)
  - Product and category affinity (co-purchases)
  - Cross-sell and upsell patterns

### Q5 – Which customers should we prioritize for action?

- **Tables:**
  - `Sales.Customer`
  - `Person.Person`
  - `Person.EmailAddress`
  - RFM/CLV outputs derived from `Sales.SalesOrderHeader` & `Sales.SalesOrderDetail`
- **Logic:**
  - High CLV + high engagement → “Protect”
  - High CLV + low recency → “Win-back”
  - Medium CLV + rising trend → “Nurture”
  - Combine with contactability (EmailAddress present)

### Q6 – What experiments or scenarios can improve outcomes?

- **Tables:**
  - `Sales.SpecialOffer`
  - `Sales.SalesOrderHeader`
  - `Sales.SalesOrderHeaderSalesReason` / `Sales.SalesReason`
- **Use Cases:**
  - Promo vs non-promo lift in revenue / retention
  - A/B-style comparisons by offer, reason, or territory

### Q7 – What is the value of our overall customer base (CBCV)?

- **Tables:**
  - `Sales.Customer`
  - `Sales.SalesOrderHeader`
  - `Sales.SalesOrderDetail`
- **Approach:**
  - Compute historical CLV proxies per customer
  - Estimate retention / survival from repeat patterns
  - Aggregate to CBCV across all active customers

## Practical Steps to Extract and Validate

1. **Discovery & Shortlist**
   - Run Query #3 and Query #7 from `metadata-exploration-v2.sql`.
   - Filter to `AnalyticsCategory` in (`Customer`, `Transaction`, `Product`, `Person`, `Location`).
   - Note `TableRole`, `TotalRows`, and `DateColumnCount`.

2. **Validate Relationships**
   - Run Query #4 and #5 to confirm hub/spoke roles and FKs between shortlisted tables.

3. **Inspect Structure**
   - Use Query #8 (PKs) and Query #9 (FKs) focused on the shortlisted tables.
   - Use Query #10 for column-level details needed in the warehouse/semantic model.

4. **Document Decisions**
   - Keep this file updated as you add or remove tables from the analytical model.
   - Optionally add notes per table about **inclusions** or **exclusions** (e.g., why a seemingly relevant table was deliberately not used).

## Appendix: Example SQL Snippets

### RFM Skeleton

```sql
SELECT
  c.CustomerID,
  MAX(soh.OrderDate) AS LastOrderDate,
  DATEDIFF(day, MAX(soh.OrderDate), GETDATE()) AS RecencyDays,
  COUNT(DISTINCT soh.SalesOrderID) AS Frequency,
  SUM(sod.LineTotal) AS Monetary
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh 
  ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod 
  ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY c.CustomerID;