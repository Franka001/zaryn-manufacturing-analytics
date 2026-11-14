# Zaryn Manufacturing Analytics — SQL Database Scripts

Run the scripts in this order in SQL Server Management Studio (SSMS):

1. `01_create_database.sql`
2. `02_create_tables.sql`
3. `03_insert_sample_data.sql`
4. `04_inventory_turnover.sql`

## Database
`ZarynManufacturingAnalytics`

## Schemas
- `core`: customers, suppliers, product categories, products, warehouses
- `sales`: sales orders and lines
- `purchasing`: purchase orders and lines
- `mfg`: production orders
- `dist`: shipments and shipment lines
- `inv`: inventory transactions

## Notes
- The sample records are synthetic and for portfolio demonstration only.
- The seed script checks business keys and transaction references before inserting, so it can be rerun without duplicating the supplied sample records.
- Inventory receipts are positive movements; issues are negative movements.
- The turnover query uses `SALE_ISSUE` inventory value movements as cost of goods sold.
- The turnover query uses an exclusive end date. For Q1 2026, set the end date to `2026-04-01`.
- This is a starter portfolio model, not a complete production ERP schema. A production implementation would need additional controls for costing policy, returns, transfers, inventory snapshots, audit history, and source-system reconciliation.
