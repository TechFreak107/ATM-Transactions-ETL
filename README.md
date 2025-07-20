# 🏦 Transaction Data ETL Pipeline with AWS RDS Integration

This project implements a complete **ETL (Extract, Transform, Load)** pipeline for a large transaction dataset. It transforms the data into a star schema, generates SQL files for schema creation and data population, and finally loads the transformed data into **AWS RDS (MySQL)**. Post-loading, several **analytical queries** are executed to derive business insights.

---

## 📁 Project Structure

```bash
transaction-etl-project/
│
├── notebooks/                            # Jupyter Notebooks
│   └── Transaction-ETL.ipynb             # Main ETL pipeline notebook
│
├── raw_data/                             # Raw unprocessed data
│   ├── raw-data1.tar.gz
│   └── raw-data2.tar.gz
│
├── transformed_data/                     # Post-ETL transformed datasets
│   ├── transformed-data-part1.tar.gz
│   ├── transformed-data-part2.tar.gz
│   └── transformed-data-part3.tar.gz
│
├── load_sql_files/                       # Auto-generated DDL + DML SQL files
│   ├── load-files-part1.tar.gz
│   ├── load-files-part2.tar.gz
│   └── load-files-part3.tar.gz
│
├── metadata/                             # Data definitions and documentation
│   └── data_dictionary.xlsx
│
├── analysis/                             # Post-load analytical SQL queries
│   └── analysis.sql
│
├── README.md                             # Project documentation
└── requirements.txt                      # Python dependencies
```
## 📌 Objective

To build a robust, automated ETL pipeline that:

- 📥 Processes a large-scale financial transactions dataset  
- 🔄 Converts it into a normalized **star schema** with **1 fact** and **4 dimension tables**  
- 🧾 Generates **SQL files** for database schema creation and data insertion  
- ☁️ Loads the schema and data into **AWS RDS (MySQL)**  
- 📊 Executes **post-load analytics** to extract actionable insights  

## 🛠 Technologies Used

- 🐍 **Python** (`pandas`, `numpy`) – for data processing and transformation  
- 📓 **Jupyter Notebook** – to develop and document the ETL pipeline  
- 💾 **SQL** (DDL + DML) – for schema creation and data insertion  
- 🗄️ **AWS RDS (MySQL)** – as the cloud-based relational database  
- ☁️ **AWS CLI** – to automate data loading into RDS  

## 📊 Data Model

### ✅ Fact Table
- **transactions**: Core financial data with foreign keys referencing the dimension tables

### 🧩 Dimension Tables
- **location**: ATM and branch location information  
- **atm**: ATM device metadata (e.g., machine ID, type)  
- **card_type**: Details about credit/debit card types  
- **date**: Temporal attributes such as year, month, day, and weekday  

## 🔗 Relationship Management

- **`relationship.sql`**: Defines and applies all necessary foreign key constraints to establish relationships between the fact and dimension tables.

## 🔄 ETL Flow

### 1. Extract
- Load raw `transactions.csv` dataset

### 2. Transform
- Clean and validate data (handle nulls, duplicates)
- Engineer features (e.g., card categories, parsed dates)
- Normalize data into 5 tables: 1 fact and 4 dimensions

### 3. SQL File Generation (Automated)
- Auto-generate all DDL and DML SQL files using Python
- One SQL file per dimension table (`location.sql`, `atm.sql`, etc.)
- Fact table data split across multiple files (`transactions_part1.sql`, `transactions_part2.sql`, ...)
- All files saved in the `output_sql/` directory
- `relationship.sql` is manually created to define foreign key constraints

## #4. Import into AWS RDS
Use the AWS CLI to run SQL files sequentially:
``` bash
# Create and populate dimension tables
aws rds-data execute-statement \
  --resource-arn <DB-ARN> \
  --secret-arn <SECRET-ARN> \
  --database <DB-NAME> \
  --sql file://output_sql/location.sql
# Repeat for atm.sql, card_type.sql, date.sql

# Populate fact table (multiple chunks)
for file in output_sql/transactions_part*.sql; do
  aws rds-data execute-statement \
    --resource-arn <DB-ARN> \
    --secret-arn <SECRET-ARN> \
    --database <DB-NAME> \
    --sql file://$file;
done

# Add relationships
aws rds-data execute-statement \
  --resource-arn <DB-ARN> \
  --secret-arn <SECRET-ARN> \
  --database <DB-NAME> \
  --sql file://output_sql/relationship.sql
```
## 📈 Post-Load Analytical Queries
After successful load, the following queries (from analysis.sql) were executed on AWS RDS for insights:

### Example Queries:
- Total transactions per ATM
``` SQL
SELECT
  atm_id, COUNT(*) AS total_txns
FROM t
  ransactions
GROUP BY
  atm_id;
```

### Top 5 cities by transaction volume
``` SQL
SELECT
  l.city, SUM(t.amount) AS total_amount
FROM
  transactions t
JOIN
  location l
ON
  t.location_id = l.location_id
GROUP BY
  l.city
ORDER BY
  total_amount DESC
LIMIT
  5;
```

### Monthly spending trend
``` SQL
SELECT
  d.month, SUM(t.amount) AS total_spent
FROM
  transactions t
JOIN
  date d
ON
  t.date_id = d.date_id
GROUP BY
  d.month
ORDER BY
  d.month;
```

### Card type usage distribution
``` SQL
SELECT
  c.card_type, COUNT(*) AS usage_count
FROM
  transactions t
JOIN
  card_type c
ON
  t.card_type_id = c.card_type_id
GROUP BY
  c.card_type;
```
### Daily transaction counts by weekday
``` SQL
SELECT
  d.weekday, COUNT(*) AS txn_count
FROM
  transactions t
JOIN
  date d
ON
  t.date_id = d.date_id
GROUP BY
  d.weekday
ORDER BY
  txn_count DESC;
```


## 📬 Contact
For questions, improvements, or collaboration, feel free to raise an issue or open a pull request.

