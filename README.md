# adventureworks-end-to-end-customer-analytics
End-to-end customer analytics project using AdventureWorks OLTP 2025. Covers business understanding, analytical requirements, data warehousing with SQL Server &amp; SSIS, semantic modeling with SSAS, statistical modeling in Excel, and insights delivery via Power BI and SSRS.

## Project Purpose

This project demonstrates an end-to-end, customer-centric analytics solution built on the Microsoft BI ecosystem using the AdventureWorks 2025 OLTP database.

The goal is to translate business questions into analytical requirements, engineer a scalable data warehouse, and deliver actionable customer insights through structured analytics, statistical modeling, and enterprise reporting.

## Business Context

Modern organizations gain competitive advantage by understanding customers at the individual level rather than relying on aggregate reporting.

This project focuses on customer analytics frameworks such as:
- Customer value and profitability
- Retention and churn behavior
- Purchase frequency and recency
- Cohort dynamics over time

The AdventureWorks dataset is used as a realistic OLTP source to simulate how customer analytics is implemented in a real enterprise environment.

## Analytical Philosophy

This project follows a SQL-first, analytics-driven design:

- SQL is used for heavy analytical lifting, transformations, and metric computation.
- Business logic is centralized upstream to ensure consistency and performance.
- Semantic and visualization layers focus on interpretation, storytelling, and decision support.

This approach mirrors real-world enterprise analytics architectures.

## Architecture Overview

The solution follows a layered architecture:

- OLTP Source: AdventureWorks 2025
- Bronze Layer: Raw extracted data
- Silver Layer: Cleaned and conformed data
- Gold Layer: Analytics-ready tables (RFM, cohorts, CLV proxies)
- OLAP Layer: Tabular semantic model
- Analytics & Reporting: Power BI, Excel, SSRS

## Technology Stack

- SQL Server: OLTP source, data warehouse, analytics tables
- SSIS: ETL and data orchestration
- SSAS (Tabular): Semantic modeling and business definitions
- Excel: Statistical and probabilistic modeling
- Power BI: Interactive analytics and dashboards
- SSRS: Paginated and operational reports
- Git & GitHub: Version control and documentation

## Project Phases

1. Business Understanding  
   Define customer-centric KPIs, frameworks, and business questions.

2. Data Architecture  
   Analyze OLTP schema, identify analytical tables, design ERD and star schema.

3. Data Engineering  
   Build ETL pipelines and data warehouse layers using SSIS and SQL.

4. Analytics Modeling  
   Implement customer analytics metrics, cohorts, and value models.

5. Visualization & Reporting  
   Deliver insights via Power BI, Excel, and SSRS.

6. Optimization & Insights  
   Translate analytics into business decisions and recommendations.

## Repository Structure

- docs/            → Architecture, ERDs, data dictionary, decisions
- sql/             → SQL scripts (ETL, analytics, metadata)
- etl/ssis/        → SSIS packages
- models/ssas/     → Tabular models
- reports/powerbi/ → Power BI reports
- reports/ssrs/    → Paginated reports
- notebooks/       → Excel-based modeling references

## Dataset

Source: AdventureWorks 2025 OLTP Database

The dataset simulates a manufacturing and retail business and includes customers, orders, products, and sales transactions. Only customer-relevant subsets of the schema are used for analytics.

## Project Status

The project is developed incrementally following a documented roadmap in Notion.
Each phase is tracked with clear deliverables and progress indicators.



