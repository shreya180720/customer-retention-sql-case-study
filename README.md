# Customer Retention & Revenue Intelligence SQL Case Study

## Goal

Identify key drivers of customer retention, churn, and revenue using normalized raw database tables.

This project is designed for Data Analyst / Business Analyst portfolios and uses PostgreSQL 17.

---

## What This Project Shows

- Advanced SQL analysis
- Cohort analysis
- Customer segmentation
- Revenue trend analysis
- Retention and churn analysis
- CTEs
- Window functions
- Joins
- Aggregations
- Reporting views

---

## Files

```text
sql/
├── 01_schema.sql
├── 02_insert_sample_data.sql
├── 03_revenue_analysis.sql
├── 04_retention_analysis.sql
├── 05_cohort_analysis.sql
├── 06_customer_segmentation.sql
├── 07_support_impact_analysis.sql
└── 08_views_for_reporting.sql
```

---

## How to Run in PostgreSQL 17

### Option 1: Run from pgAdmin

1. Open pgAdmin.
2. Create a new database:

```sql
CREATE DATABASE customer_retention_case_study;
```

3. Connect to that database.
4. Open each SQL file and run in this exact order:

```text
01_schema.sql
02_insert_sample_data.sql
08_views_for_reporting.sql
03_revenue_analysis.sql
04_retention_analysis.sql
05_cohort_analysis.sql
06_customer_segmentation.sql
07_support_impact_analysis.sql
```

---

### Option 2: Run from terminal

```bash
createdb customer_retention_case_study
```

Then run:

```bash
psql -d customer_retention_case_study -f sql/01_schema.sql
psql -d customer_retention_case_study -f sql/02_insert_sample_data.sql
psql -d customer_retention_case_study -f sql/08_views_for_reporting.sql
psql -d customer_retention_case_study -f sql/03_revenue_analysis.sql
psql -d customer_retention_case_study -f sql/04_retention_analysis.sql
psql -d customer_retention_case_study -f sql/05_cohort_analysis.sql
psql -d customer_retention_case_study -f sql/06_customer_segmentation.sql
psql -d customer_retention_case_study -f sql/07_support_impact_analysis.sql
```

If using a username:

```bash
psql -U postgres -d customer_retention_case_study -f sql/01_schema.sql
```

---

## Suggested Output Files

After running queries, export important result tables from pgAdmin as CSV:

```text
results/
├── monthly_revenue.csv
├── acquisition_channel_revenue.csv
├── customer_retention.csv
├── cohort_retention.csv
├── rfm_segmentation.csv
└── support_impact.csv
```

---

## Business Questions Covered

1. What is the monthly revenue trend?
2. Which acquisition channels generate the most revenue?
3. Who are the top customers by lifetime value?
4. Which product categories drive the highest revenue?
5. What is month-over-month revenue growth?
6. Which locations generate the most revenue?
7. What percentage of customers return after first purchase?
8. What is monthly customer retention?
9. Which acquisition channel has the best repeat purchase rate?
10. How many customers churn after one order?
11. Which customers are dormant for 90+ days?
12. What is the average time between purchases?
13. What does cohort activity look like by first purchase month?
14. What is cohort retention percentage?
15. What are 30/60/90-day retention rates?
16. What are customer RFM segments?
17. Which customers are high, medium, or low value?
18. Who are loyal repeat customers?
19. Which product categories are preferred by each segment?
20. Do unresolved support tickets hurt retention or revenue?
21. Does satisfaction score affect repeat purchase behavior?
22. Which issue types are linked to poor satisfaction?

---

## Schema Diagram

You can generate a schema diagram using:

- pgAdmin ERD Tool
- DBeaver ER Diagram
- dbdiagram.io

Suggested ERD relationship structure:

```text
customers 1---many orders
orders 1---many order_items
products 1---many order_items
orders 1---1 payments
customers 1---many customer_activity
customers 1---many support_tickets
```

---

## Resume Line

Built an advanced SQL analytics case study in PostgreSQL to identify customer retention and revenue drivers using cohort analysis, RFM segmentation, churn detection, CTEs, window functions, and normalized transactional tables.

---

## GitHub Description

Advanced PostgreSQL case study analyzing customer retention, revenue trends, churn behavior, cohort performance, RFM segmentation, and support impact using normalized business data and SQL reporting views.
