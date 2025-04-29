# Full Sales Data Analysis Project (Power BI + PostgreSQL)

This project is a full-stack data analytics and BI solution built using **PostgreSQL**, **Power BI**, and **SQL queries**, simulating a real-world sales environment for a Stenox fictional retail company.

From data modeling to powerful storytelling dashboards, this project demonstrates my ability to analyze business performance, derive insights, and answer key strategic questions that support data-driven decisions.
## About Data
- Full sales data contains demographics information, cities, stores and orders. I modeled data into facts and dimensions tables.

---

## Project structure
full_sales_project - data Cleaned and modeled data - sql_queries SQL scripts for analysis 
Powerbi - Power BI (.pbix) dashboard file

---

## Tools & Skills Used

- **Power BI** – Data visualization and storytelling
- **PostgreSQL** – Data modeling, querying, and transformation
- **SQL** – Deep analysis with aggregate, time-based, and join operations
- **Data Modeling** – Star schema with dimension and fact tables
- **KPI Design & DAX** – Advanced DAX measures and performance metrics
- **Business Problem Solving** – Real-life scenario-based insight generation

---

## Business Questions Answered

This project was built around real-world retail challenges. Below are the key questions addressed:

### Sales Performance

- What are the total sales, profit, and profit margin across all regions?
- Which cities, stores, and product categories generate the most revenue?
- How does discounting impact quantity sold and profitability?
- What is the trend of sales and revenue seasonally (monthly/quarterly)?

### Customer Insights

- What percentage of customers contribute to 80% of revenue (Pareto analysis)?
- Who are the top customers by revenue or order frequency?
- Segment customers by age group and location for targeted promotions.

### Operational Insights

- What is the distribution of order status (Completed vs Cancelled vs Pending)?
- Which stores or product categories have high cancellation rates?
- How fast are orders being fulfilled on average?

### Inventory & Demand

- How should inventory levels be adjusted based on sales trends?
- Which product categories should be promoted more?
- Can we forecast next month’s revenue?

### Market Expansion

- Where should we open new stores based on customer density?
- Which cities have strong growth potential?

---

## Data Modeling

The data was modeled using a **Star Schema**, including:

| Table           | Description                          |
|----------------|--------------------------------------|
| `full_sales_dataset` | Fact table with transactional sales |
| `dim_customers`      | Customer demographics and location |
| `dim_product`        | Product categories and brands     |
| `dim_store`          | Store information                 |
| `dim_date`           | Calendar table (for time analysis) |

**Composite keys**, **foreign key constraints**, and **indexes** were created for optimal querying performance.

---

## Key Metrics & DAX Measures

Here are a few important DAX measures used in Power BI:

```dax
Total Revenue = SUM(full_sales_dataset[revenue])

Total Profit = SUM(full_sales_dataset[profit])

Profit Margin (%) = DIVIDE([Total Profit], [Total Revenue]) * 100

Average Order Value = AVERAGE(full_sales_dataset[revenue])

