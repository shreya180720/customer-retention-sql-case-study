# Customer Retention & Revenue Intelligence SQL Case Study

## Goal

Identify key drivers of customer retention, churn, and revenue using normalized raw database tables.

This project uses PostgreSQL 17.

---

## What I Built

- End to ennd SQL analysis on customer and transaction data
- Cohort analysis to track retention over time
- Customer segmentation using RFM logic
- Revenue trend and growth analysis
- Retention and churn identification
- Support impact analysis on customer behavior
- Reusable reporting views for business insights

##  Technical Architecture & Features
I engineered a series of analytical pipelines using **PostgreSQL 17** that automate:

* **📈 Revenue Growth Modeling:** Calculation of MoM growth and category-specific performance.
* **👥 Cohort Retention:** Matrix-style analysis tracking users from their acquisition month.
* **💎 RFM Segmentation:** (Recency, Frequency, Monetary) logic to rank customer value.
* **📉 Churn Diagnostics:** Identifying dormant 90+ day users and the "single-order" drop-off.
* **  Support Sentiment Analysis:** Correlating ticket resolution times with long-term LTV.

### Advanced SQL Techniques Used:
* **CTEs & Window Functions:** For running totals, MoM growth percentages, and ranking.
* **Self-Joins:** Used specifically to calculate time-to-next-purchase intervals.
* **Complex Aggregations:** Pivot-style queries for cohort heatmaps.
* **Materialized View Logic:** To optimize reporting for business users.

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
schema.sql
insert_sample_data.sql
views_for_reporting.sql
revenue_analysis.sql
retention_analysis.sql
cohort_analysis.sql
customer_segmentation.sql
support_impact_analysis.sql
```

---

### Option 2: Run from terminal

```bash
createdb customer_retention_case_study
```

Then run:

```bash
psql -d customer_retention_case_study -f sql/schema.sql
psql -d customer_retention_case_study -f sql/insert_sample_data.sql
psql -d customer_retention_case_study -f sql/views_for_reporting.sql
psql -d customer_retention_case_study -f sql/revenue_analysis.sql
psql -d customer_retention_case_study -f sql/retention_analysis.sql
psql -d customer_retention_case_study -f sql/cohort_analysis.sql
psql -d customer_retention_case_study -f sql/customer_segmentation.sql
psql -d customer_retention_case_study -f sql/support_impact_analysis.sql
```

If using a username:

```bash
psql -U postgres -d customer_retention_case_study -f sql/schema.sql
```

---

## Output Files

After running queries, export important result tables from pgAdmin as CSV files.

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

I generated a schema diagram using: dbdiagram.io

ERD relationship structure:

```text
customers 1---many orders
orders 1---many order_items
products 1---many order_items
orders 1---1 payments
customers 1---many customer_activity
customers 1---many support_tickets
```

---
