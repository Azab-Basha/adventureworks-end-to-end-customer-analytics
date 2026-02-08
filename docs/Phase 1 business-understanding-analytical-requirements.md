# 📊 Phase 1 – Business Understanding

## Task 1: Define Customer-Centric KPIs
**_(Wharton-aligned, project-ready)_**

---

### 🎯 Task Objective

This task establishes customer-centric success metrics that:

✅ Replace product/revenue-only thinking with **customer as an asset**  
✅ Align directly with Wharton frameworks:
- Customer Lifetime Value (CLV)
- Heterogeneity (customers are not equal)
- Forward-looking analytics
- Customer-based corporate valuation (CBCV)

✅ Drive **managerial decisions**, not just dashboards

> **This is the strategic foundation of the entire project.**

---

### ✅ What "DONE" looks like (completion criteria)

Having a **documented KPI framework** where:

✅ KPIs are grouped by business question, not vanity metrics  
✅ Each KPI:
1. Has a business meaning
2. Supports a decision
3. Is measurable from AdventureWorks
4. Is future-oriented where possible

**Flow**: Wharton frameworks → Business questions → KPIs

---

## 📐 Wharton Frameworks → KPIs Mapping

---

### 🔶 Framework 1: Customers are profit centers

**Business question**: Which customers create value vs destroy value?

**KPIs:**
1. Customer Lifetime Value (CLV)
2. Net CLV (CLV – acquisition/service cost)
3. % of customers with negative CLV
4. Revenue concentration (Top 10% CLV share)

**Managerial decisions enabled:**
1. Who to retain
2. Who to stop over-serving
3. Budget allocation

---

### 🔶 Framework 2: Customer heterogeneity

**Business question**: How different are our customers really?

**KPIs:**
1. RFM scores (Recency, Frequency, Monetary)
2. CLV distribution (long tail vs spike)
3. Segment-level retention rate
4. Segment-level profitability

**Managerial decisions enabled:**
1. Segment-specific pricing
2. Targeted offers
3. Customer prioritization

---

### 🔶 Framework 3: Acquisition vs retention economics

**Business question**: Are we buying the right customers?

**KPIs:**
1. CLV by acquisition channel
2. Payback period
3. Early churn rate (first X months)
4. Cohort quality decay

**Managerial decisions enabled:**
1. Acquisition spend optimization
2. Channel shutdown decisions
3. Look-alike targeting logic

---

### 🔶 Framework 4: Forward-looking analytics

**Business question**: What will customers do next?

**KPIs:**
1. Predicted transactions (BTYD-style)
2. Expected future revenue
3. Survival/retention curve
4. Churn probability

**Managerial decisions enabled:**
1. Proactive retention
2. Demand forecasting
3. Capacity planning

---

### 🔶 Framework 5: Prescriptive analytics

**Business question**: What action should we take now?

**KPIs:**
1. Incremental profit per action
2. Uplift vs control
3. Marginal revenue vs marginal cost
4. Optimal price/discount thresholds

**Managerial decisions enabled:**
1. Discount eligibility
2. Pricing strategy
3. Offer personalization

---

### 🔶 Framework 6: Customer centricity as enterprise strategy

**Business question**: How healthy is our customer base overall?

**KPIs:**
1. Customer equity (sum of CLVs)
2. New vs existing customer value ratio
3. Cohort-level CLV trends
4. Customer asset growth rate

**Managerial decisions enabled:**
1. Strategic investment
2. Long-term planning
3. Executive alignment (CEO/CFO/CMO)

---

## Task 2: Map Course Frameworks → Business Questions

---

### 🎯 Task Objective

Translate Wharton theory into answerable business questions.

This task ensures:

✅ The project is **decision-driven**, not tool-driven  
✅ Every model we build later exists to answer a **real managerial question**  
✅ You avoid the classic mistake: _"great analytics, unclear value"_

> Think of this as bridging **academia → industry → SQL tables**.

---

### ✅ What "DONE" looks like

Each Wharton framework is mapped to:

1. A business question
2. A managerial decision

Questions are:
1. Customer-centric
2. Forward-looking where possible
3. Feasible with AdventureWorks data

---

## 🗺️ Framework → Business Questions Mapping

---

### 🔷 Framework 1: Customers are the profit centers

**Core idea:**  
Profit comes from customers, not products.

**Business questions:**
1. Which customers generate the most long-term value?
2. Which customers are unprofitable?
3. How concentrated is our profit across customers?

**Managerial decisions:**
1. Who to retain vs deprioritize
2. Where to focus our service and investment
3. Risk exposure to losing top customers

---

### 🔷 Framework 2: Customer heterogeneity

**Core idea:**  
Not all customers are created equal.

**Business questions:**
1. How different are customers in behavior and value?
2. Can we group customers meaningfully?
3. What distinguishes high-value customers from low-value ones?

**Managerial decisions:**
1. Segment-specific marketing
2. Personalized pricing or offers
3. Resource prioritization

---

### 🔷 Framework 3: Cohort analysis & customer evolution

**Core idea:**  
Customer quality changes over time.

**Business questions:**
1. Are newer customer cohorts better or worse than older ones?
2. Do acquisition strategies degrade customer quality?
3. How long does it take customers to become valuable?

**Managerial decisions:**
1. Fix acquisition strategy
2. Adjust onboarding and early experience
3. Decide whether growth is "healthy"

---

### 🔷 Framework 4: Retention & BTYD logic

**Core idea:**  
Buying is probabilistic; churn is unobserved.

**Business questions:**
1. How long will customers stay active?
2. How many future purchases should we expect?
3. Which customers are likely already "dead"?

**Managerial decisions:**
1. Proactive retention
2. Forecast demand and revenue
3. Reduce wasteful reactivation spending

---

### 🔷 Framework 5: Predictive → prescriptive analytics

**Core idea:**  
Prediction is useless without action.

**Business questions:**
1. Who should receive a discount?
2. When does a discount destroy value?
3. What action maximizes incremental profit?

**Managerial decisions:**
1. Offer eligibility
2. Pricing and promotion strategy
3. A/B test design

---

### 🔷 Framework 6: Customer equity & CBCV

**Core idea:**  
Customer base = financial asset.

**Business questions:**
1. What is the total value of our customer base?
2. Is customer equity growing or shrinking?
3. Are we building long-term enterprise value?

**Managerial decisions:**
1. Strategic investment
2. Executive reporting
3. Long-term planning

---

## Task 3: Translate Business Questions into Analytical Requirements

---

### 🎯 Task Objective

Convert managerial questions into precise analytical requirements so that:

✅ Every SQL table has a purpose  
✅ Every metric has a definition  
✅ Every model has clear inputs & outputs

This prevents:
- ❌ Random exploration
- ❌ Over-engineering
- ❌ "Nice dashboards, unclear value"

---

### ✅ What "DONE" looks like

Each business question has:

- Required metrics
- Required data grain
- Required time window
- Required entities

Requirements are **tool-agnostic** (what we need, not how yet)

Documented in Git, linked in Notion (All three tasks)

---

## 📋 Business Question → Analytical Requirements

---

### ❓ Q1: Who are our most valuable customers?

**Metrics required:**
1. Total revenue per customer
2. Order count
3. Average order value
4. Gross margin (if available)
5. Customer lifetime value (proxy)
6. Revenue/Profit Concentration (Pareto Principle)

**Data grain:**
- Customer × Order

**Time windows:**
1. Full history
2. Last 12 months
3. Last 24 months

**Entities needed:**
1. Customer
2. Sales Order Header
3. Sales Order Detail

---

### ❓ Q2: Which customers are unprofitable or risky?

**Metrics required:**
1. Revenue per customer
2. Cost proxy (returns, discounts, low frequency)
3. Time since last purchase
4. Purchase frequency

**Data grain:**
- Customer × Time (monthly)

**Time windows:**
- Rolling windows (3, 6, 12 months)

**Entities needed:**
1. Customer
2. Orders
3. Returns (if available)

---

### ❓ Q3: How do customers differ in behavior (heterogeneity)?

**Metrics required:**
1. Recency
2. Frequency
3. Monetary value (RFM)
4. Basket size
5. Category diversity

**Data grain:**
- Customer level

**Time windows:**
1. Fixed calibration window
2. Observation window

**Entities needed:**
1. Customer
2. Orders
3. Products

---

### ❓ Q4: Are newer customer cohorts better or worse?

**Metrics required:**
1. Cohort size
2. Retention rate by period
3. Revenue per cohort
4. Orders per cohort

**Data grain:**
- Cohort × Period

**Time windows:**
1. Cohort month
2. Months since acquisition

**Entities needed:**
1. Customer
2. First purchase date
3. Orders

---

### ❓ Q5: Who is likely still active vs "dead"?

**Metrics required:**
1. Last purchase date
2. Purchase count
3. Inter-purchase time
4. Expected future purchases (BTYD inputs)

**Data grain:**
- Customer level

**Time windows:**
- Calibration vs holdout

**Entities needed:**
1. Customer
2. Orders

---

### ❓ Q6: What actions should we take (prescriptive)?

**Metrics required:**
1. Predicted CLV
2. Discount cost
3. Incremental lift assumptions

**Data grain:**
- Customer × Action scenario

**Time windows:**
- Forward-looking (12–36 months)

**Entities needed:**
1. Customer
2. Orders
3. Promotions (if simulated)

---

### ❓ Q7: What is the value of our overall customer base? (CBCV)

**Metrics required:**
1. Sum of all customer CLVs
2. Customer equity growth rate
3. New customer acquisition value
4. Existing customer retention value

**Data grain:**
- Customer-level aggregated to enterprise

**Time windows:**
- Future projections (e.g., next 1–5 years)

**Entities needed:**
- Customers
- Transactions
- Cohorts
- Purchase frequency
- Spend
- Retention metrics

---

## 📚 Related Documentation

- **[Data Dictionary](./adventureworks-customer-analytics-data-dictionary.md)** - Complete 17-table reference
- **[Table Selection Methodology](./table-selection-methodology.md)** - How tables were chosen
- **[ERD Diagram (DBML)](./erd-customer-analytics-enhanced.dbml)** - Visual entity-relationship diagram

---

**📅 Document Created**: Feb 2026  
**👤 Author**: Azab Basha  
**🏢 Project**: AdventureWorks End-to-End Customer Analytics  
**📂 Phase**: Phase 1 – Business Understanding

---

**🎯 This document serves as:**
- ✅ Strategic foundation for the entire analytics project
- ✅ Bridge between Wharton theory and SQL implementation
- ✅ Decision-making framework for stakeholders
- ✅ Scope definition for data engineering and modeling work
