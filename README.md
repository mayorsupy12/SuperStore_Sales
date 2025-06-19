# Superstore Sales Data Normalization and Analysis
This project showcases a full data pipeline from raw CSV data to a normalized SQL database and advanced business analysis using SQL and Power BI.

##  Project Highlights

### 1.  Dataset Preparation
- Cleaned and stored as `Superstore_Sales.csv`.

### 2.  Data Normalization
- Converted flat file into 3NF.
- Documented in `normalization_steps.txt`.
- Built an ERD showing relationships between normalized entities.

### 3.  SQL Development
- `create_tables.sql`: Defines normalized schema with constraints.
- `insert_data.sql`: import data

### 4.  Analysis via SQL
Key insights explored include:
- Top 5 customers by sales
- Year-over-year sales growth
- Most profitable product categories
- Regional sales & discount impact
- RFM analysis and customer segmentation

See all queries in `analysis_queries.sql`.

### 5.  Power BI Dashboard 
- Dynamic visuals showing KPIs, customer value, and regional performance.
- Includes DAX measures for YoY growth, total profit, and top N analysis.



##  Key Insights
- California leads in sales and profit; Texas and Ohio show high sales but deep losses due to over-discounting.
- High-value customers contribute disproportionately—suggests loyalty programs.
- Seasonality visible with Q4 driving annual spikes.
- Profit margins drop steeply when discounts exceed 25%.
