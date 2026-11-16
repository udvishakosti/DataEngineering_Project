During this project, I faced a few data quality and pipeline challenges. I solved them step by step.

| Challenge | Solution |
|---|---|
| Duplicate bill records | Used `ROW_NUMBER()` with `PARTITION BY bill_id` to identify duplicates and retain only one record per bill. |
| Invalid quantity values | Identified records where quantity was zero or negative and moved them to the rejected table. |
| Negative unit prices | Filtered records with negative unit prices and stored them in the rejected table. |
| Missing patient IDs | Retained these records because patient ID was not required for calculating billing revenue. |
| Missing department and payer details | Replaced missing or blank values with `Unknown` to maintain consistent reporting. |
| Missing total amounts | Used `COALESCE()` to calculate the amount from quantity and unit price when the original amount was missing. |
| Pipeline table update errors | Learned to use `CREATE OR REFRESH MATERIALIZED VIEW` for pipeline-managed materialized views instead of replacing them through SQL. |
| Data reconciliation | Compared Bronze, Clean, Rejected, and duplicate counts to verify that no unique bill records were lost. |

### Key Learning

This project helped me understand how to handle real-world data quality issues, build ETL workflows, work with pipeline-managed tables, and validate data before creating business dashboards.
