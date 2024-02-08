# Data Warehouse

A **Data Warehouse** is an OLAP solution that is used for reporting and data analysis. Data warehouses can provide access to raw data, summary data or data marts.

![data warehouse](res/data-warehouse.png)

# OLAP vs OLTP

| | OLTP | OLAP |
|---|---|---|
| Meaning | Online Transaction Processing | Online Analytical Processing |
| Purpose | Control and run essential business operations in real time | Plan, solve problems, support decisions, discover hidden insights|
| Data updates | Short, fast updates initiated by user | Data periodically refreshed with scheduled, long-running batch jobs |
| Database design | Normalized databases for efficiency | Denormalized databases for analysis |
| Space requirements | Generally small if historical data is archived | Generally large due to aggregating large datasets |
| Backup and recovery | Regular backups required to ensure business continuity and meet legal and governance requirements | Lost data can be reloaded from OLTP database as needed in lieu of regular backups |
| Productivity | Increases productivity of end users | Increases productivity of business managers, data analysts, and executives |
| Data view | Lists day-to-day business transactions | Multi-dimensional view of enterprise data |
| User examples | Customer-facing personnel, clerks, online shoppers | Knowledge workers such as data analysts, business analysts, and executives |