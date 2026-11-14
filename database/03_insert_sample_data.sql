/*
    Zaryn Data Engineering
    Project: Manufacturing Analytics
    Script: 03_insert_sample_data.sql

    Purpose:
      Loads a small, repeatable synthetic dataset for portfolio demonstrations.
      The script checks business keys/references before inserting to avoid
      duplicating the seed records when rerun.

    Run after 02_create_tables.sql.
*/

USE [ZarynManufacturingAnalytics];
GO
SET NOCOUNT ON;
GO

/* Reference data */
IF NOT EXISTS (SELECT 1 FROM core.Customers WHERE CustomerCode = N'CUST-001')
    INSERT INTO core.Customers (CustomerCode, CustomerName, City, StateProvince)
    VALUES (N'CUST-001', N'Northstar Equipment Co.', N'Dallas', N'Texas');

IF NOT EXISTS (SELECT 1 FROM core.Customers WHERE CustomerCode = N'CUST-002')
    INSERT INTO core.Customers (CustomerCode, CustomerName, City, StateProvince)
    VALUES (N'CUST-002', N'Pioneer Industrial Supply', N'Austin', N'Texas');

IF NOT EXISTS (SELECT 1 FROM core.Customers WHERE CustomerCode = N'CUST-003')
    INSERT INTO core.Customers (CustomerCode, CustomerName, City, StateProvince)
    VALUES (N'CUST-003', N'Gulf Coast Machinery', N'Houston', N'Texas');

IF NOT EXISTS (SELECT 1 FROM core.Suppliers WHERE SupplierCode = N'SUP-001')
    INSERT INTO core.Suppliers (SupplierCode, SupplierName, City, StateProvince)
    VALUES (N'SUP-001', N'Texas Steel Components', N'Fort Worth', N'Texas');

IF NOT EXISTS (SELECT 1 FROM core.Suppliers WHERE SupplierCode = N'SUP-002')
    INSERT INTO core.Suppliers (SupplierCode, SupplierName, City, StateProvince)
    VALUES (N'SUP-002', N'Precision Motor Works', N'Plano', N'Texas');

IF NOT EXISTS (SELECT 1 FROM core.ProductCategories WHERE CategoryCode = N'COMP')
    INSERT INTO core.ProductCategories (CategoryCode, CategoryName)
    VALUES (N'COMP', N'Components');

IF NOT EXISTS (SELECT 1 FROM core.ProductCategories WHERE CategoryCode = N'FIN')
    INSERT INTO core.ProductCategories (CategoryCode, CategoryName)
    VALUES (N'FIN', N'Finished Goods');

IF NOT EXISTS (SELECT 1 FROM core.Warehouses WHERE WarehouseCode = N'DAL')
    INSERT INTO core.Warehouses (WarehouseCode, WarehouseName, City, StateProvince)
    VALUES (N'DAL', N'Dallas Distribution Center', N'Dallas', N'Texas');

IF NOT EXISTS (SELECT 1 FROM core.Warehouses WHERE WarehouseCode = N'HOU')
    INSERT INTO core.Warehouses (WarehouseCode, WarehouseName, City, StateProvince)
    VALUES (N'HOU', N'Houston Manufacturing Warehouse', N'Houston', N'Texas');

/* Products */
IF NOT EXISTS (SELECT 1 FROM core.Products WHERE ProductCode = N'COMP-100')
    INSERT INTO core.Products
        (ProductCode, ProductName, ProductCategoryID, UnitOfMeasure, StandardUnitCost, ListUnitPrice, IsManufactured)
    SELECT N'COMP-100', N'Industrial Motor Assembly', pc.ProductCategoryID, N'EA', 125.00, 210.00, 0
    FROM core.ProductCategories pc WHERE pc.CategoryCode = N'COMP';

IF NOT EXISTS (SELECT 1 FROM core.Products WHERE ProductCode = N'COMP-200')
    INSERT INTO core.Products
        (ProductCode, ProductName, ProductCategoryID, UnitOfMeasure, StandardUnitCost, ListUnitPrice, IsManufactured)
    SELECT N'COMP-200', N'Steel Drive Shaft', pc.ProductCategoryID, N'EA', 48.00, 85.00, 0
    FROM core.ProductCategories pc WHERE pc.CategoryCode = N'COMP';

IF NOT EXISTS (SELECT 1 FROM core.Products WHERE ProductCode = N'FIN-100')
    INSERT INTO core.Products
        (ProductCode, ProductName, ProductCategoryID, UnitOfMeasure, StandardUnitCost, ListUnitPrice, IsManufactured)
    SELECT N'FIN-100', N'Conveyor Module A', pc.ProductCategoryID, N'EA', 340.00, 590.00, 1
    FROM core.ProductCategories pc WHERE pc.CategoryCode = N'FIN';

IF NOT EXISTS (SELECT 1 FROM core.Products WHERE ProductCode = N'FIN-200')
    INSERT INTO core.Products
        (ProductCode, ProductName, ProductCategoryID, UnitOfMeasure, StandardUnitCost, ListUnitPrice, IsManufactured)
    SELECT N'FIN-200', N'Packaging Line Module B', pc.ProductCategoryID, N'EA', 510.00, 850.00, 1
    FROM core.ProductCategories pc WHERE pc.CategoryCode = N'FIN';

/* Purchase orders and lines */
IF NOT EXISTS (SELECT 1 FROM purchasing.PurchaseOrders WHERE PurchaseOrderNumber = N'PO-2026-001')
    INSERT INTO purchasing.PurchaseOrders
        (PurchaseOrderNumber, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, ActualDeliveryDate, PurchaseOrderStatus)
    SELECT N'PO-2026-001', s.SupplierID, w.WarehouseID, '2026-01-05', '2026-01-12', '2026-01-11', N'RECEIVED'
    FROM core.Suppliers s CROSS JOIN core.Warehouses w
    WHERE s.SupplierCode = N'SUP-001' AND w.WarehouseCode = N'HOU';

IF NOT EXISTS (SELECT 1 FROM purchasing.PurchaseOrders WHERE PurchaseOrderNumber = N'PO-2026-002')
    INSERT INTO purchasing.PurchaseOrders
        (PurchaseOrderNumber, SupplierID, WarehouseID, OrderDate, ExpectedDeliveryDate, ActualDeliveryDate, PurchaseOrderStatus)
    SELECT N'PO-2026-002', s.SupplierID, w.WarehouseID, '2026-02-03', '2026-02-10', '2026-02-13', N'RECEIVED'
    FROM core.Suppliers s CROSS JOIN core.Warehouses w
    WHERE s.SupplierCode = N'SUP-002' AND w.WarehouseCode = N'DAL';

IF NOT EXISTS
(
    SELECT 1 FROM purchasing.PurchaseOrderLines pol
    JOIN purchasing.PurchaseOrders po ON po.PurchaseOrderID = pol.PurchaseOrderID
    WHERE po.PurchaseOrderNumber = N'PO-2026-001' AND pol.LineNumber = 1
)
    INSERT INTO purchasing.PurchaseOrderLines
        (PurchaseOrderID, LineNumber, ProductID, QuantityOrdered, QuantityReceived, UnitCost)
    SELECT po.PurchaseOrderID, 1, p.ProductID, 100, 100, 120.00
    FROM purchasing.PurchaseOrders po
    JOIN core.Products p ON p.ProductCode = N'COMP-100'
    WHERE po.PurchaseOrderNumber = N'PO-2026-001';

IF NOT EXISTS
(
    SELECT 1 FROM purchasing.PurchaseOrderLines pol
    JOIN purchasing.PurchaseOrders po ON po.PurchaseOrderID = pol.PurchaseOrderID
    WHERE po.PurchaseOrderNumber = N'PO-2026-001' AND pol.LineNumber = 2
)
    INSERT INTO purchasing.PurchaseOrderLines
        (PurchaseOrderID, LineNumber, ProductID, QuantityOrdered, QuantityReceived, UnitCost)
    SELECT po.PurchaseOrderID, 2, p.ProductID, 200, 200, 46.00
    FROM purchasing.PurchaseOrders po
    JOIN core.Products p ON p.ProductCode = N'COMP-200'
    WHERE po.PurchaseOrderNumber = N'PO-2026-001';

IF NOT EXISTS
(
    SELECT 1 FROM purchasing.PurchaseOrderLines pol
    JOIN purchasing.PurchaseOrders po ON po.PurchaseOrderID = pol.PurchaseOrderID
    WHERE po.PurchaseOrderNumber = N'PO-2026-002' AND pol.LineNumber = 1
)
    INSERT INTO purchasing.PurchaseOrderLines
        (PurchaseOrderID, LineNumber, ProductID, QuantityOrdered, QuantityReceived, UnitCost)
    SELECT po.PurchaseOrderID, 1, p.ProductID, 60, 60, 330.00
    FROM purchasing.PurchaseOrders po
    JOIN core.Products p ON p.ProductCode = N'FIN-100'
    WHERE po.PurchaseOrderNumber = N'PO-2026-002';

/* Sales orders and lines */
IF NOT EXISTS (SELECT 1 FROM sales.SalesOrders WHERE SalesOrderNumber = N'SO-2026-001')
    INSERT INTO sales.SalesOrders
        (SalesOrderNumber, CustomerID, OrderDate, RequestedShipDate, OrderStatus)
    SELECT N'SO-2026-001', c.CustomerID, '2026-01-15', '2026-01-22', N'SHIPPED'
    FROM core.Customers c WHERE c.CustomerCode = N'CUST-001';

IF NOT EXISTS (SELECT 1 FROM sales.SalesOrders WHERE SalesOrderNumber = N'SO-2026-002')
    INSERT INTO sales.SalesOrders
        (SalesOrderNumber, CustomerID, OrderDate, RequestedShipDate, OrderStatus)
    SELECT N'SO-2026-002', c.CustomerID, '2026-02-12', '2026-02-20', N'SHIPPED'
    FROM core.Customers c WHERE c.CustomerCode = N'CUST-002';

IF NOT EXISTS (SELECT 1 FROM sales.SalesOrders WHERE SalesOrderNumber = N'SO-2026-003')
    INSERT INTO sales.SalesOrders
        (SalesOrderNumber, CustomerID, OrderDate, RequestedShipDate, OrderStatus)
    SELECT N'SO-2026-003', c.CustomerID, '2026-03-10', '2026-03-18', N'IN_PROGRESS'
    FROM core.Customers c WHERE c.CustomerCode = N'CUST-003';

IF NOT EXISTS
(
    SELECT 1 FROM sales.SalesOrderLines sol
    JOIN sales.SalesOrders so ON so.SalesOrderID = sol.SalesOrderID
    WHERE so.SalesOrderNumber = N'SO-2026-001' AND sol.LineNumber = 1
)
    INSERT INTO sales.SalesOrderLines
        (SalesOrderID, LineNumber, ProductID, QuantityOrdered, UnitPrice, UnitCostAtSale)
    SELECT so.SalesOrderID, 1, p.ProductID, 10, 210.00, 120.00
    FROM sales.SalesOrders so CROSS JOIN core.Products p
    WHERE so.SalesOrderNumber = N'SO-2026-001' AND p.ProductCode = N'COMP-100';

IF NOT EXISTS
(
    SELECT 1 FROM sales.SalesOrderLines sol
    JOIN sales.SalesOrders so ON so.SalesOrderID = sol.SalesOrderID
    WHERE so.SalesOrderNumber = N'SO-2026-002' AND sol.LineNumber = 1
)
    INSERT INTO sales.SalesOrderLines
        (SalesOrderID, LineNumber, ProductID, QuantityOrdered, UnitPrice, UnitCostAtSale)
    SELECT so.SalesOrderID, 1, p.ProductID, 5, 590.00, 330.00
    FROM sales.SalesOrders so CROSS JOIN core.Products p
    WHERE so.SalesOrderNumber = N'SO-2026-002' AND p.ProductCode = N'FIN-100';

IF NOT EXISTS
(
    SELECT 1 FROM sales.SalesOrderLines sol
    JOIN sales.SalesOrders so ON so.SalesOrderID = sol.SalesOrderID
    WHERE so.SalesOrderNumber = N'SO-2026-003' AND sol.LineNumber = 1
)
    INSERT INTO sales.SalesOrderLines
        (SalesOrderID, LineNumber, ProductID, QuantityOrdered, UnitPrice, UnitCostAtSale)
    SELECT so.SalesOrderID, 1, p.ProductID, 8, 85.00, 46.00
    FROM sales.SalesOrders so CROSS JOIN core.Products p
    WHERE so.SalesOrderNumber = N'SO-2026-003' AND p.ProductCode = N'COMP-200';

/* Production orders */
IF NOT EXISTS (SELECT 1 FROM mfg.ProductionOrders WHERE ProductionOrderNumber = N'PROD-2026-001')
    INSERT INTO mfg.ProductionOrders
        (ProductionOrderNumber, ProductID, WarehouseID, PlannedQuantity, CompletedQuantity,
         PlannedStartDate, ActualStartDate, PlannedEndDate, ActualEndDate, ProductionStatus)
    SELECT N'PROD-2026-001', p.ProductID, w.WarehouseID, 30, 30,
           '2026-01-08', '2026-01-08', '2026-01-20', '2026-01-19', N'COMPLETED'
    FROM core.Products p CROSS JOIN core.Warehouses w
    WHERE p.ProductCode = N'FIN-100' AND w.WarehouseCode = N'HOU';

IF NOT EXISTS (SELECT 1 FROM mfg.ProductionOrders WHERE ProductionOrderNumber = N'PROD-2026-002')
    INSERT INTO mfg.ProductionOrders
        (ProductionOrderNumber, ProductID, WarehouseID, PlannedQuantity, CompletedQuantity,
         PlannedStartDate, ActualStartDate, PlannedEndDate, ActualEndDate, ProductionStatus)
    SELECT N'PROD-2026-002', p.ProductID, w.WarehouseID, 20, 12,
           '2026-02-15', '2026-02-16', '2026-03-01', NULL, N'IN_PROGRESS'
    FROM core.Products p CROSS JOIN core.Warehouses w
    WHERE p.ProductCode = N'FIN-200' AND w.WarehouseCode = N'HOU';

/* Shipments */
IF NOT EXISTS (SELECT 1 FROM dist.Shipments WHERE ShipmentNumber = N'SHP-2026-001')
    INSERT INTO dist.Shipments
        (ShipmentNumber, SalesOrderID, WarehouseID, ShipDate, DeliveryDate, CarrierName, ShipmentStatus)
    SELECT N'SHP-2026-001', so.SalesOrderID, w.WarehouseID, '2026-01-21', '2026-01-23',
           N' Lone Star Freight', N'DELIVERED'
    FROM sales.SalesOrders so CROSS JOIN core.Warehouses w
    WHERE so.SalesOrderNumber = N'SO-2026-001' AND w.WarehouseCode = N'DAL';

IF NOT EXISTS (SELECT 1 FROM dist.Shipments WHERE ShipmentNumber = N'SHP-2026-002')
    INSERT INTO dist.Shipments
        (ShipmentNumber, SalesOrderID, WarehouseID, ShipDate, DeliveryDate, CarrierName, ShipmentStatus)
    SELECT N'SHP-2026-002', so.SalesOrderID, w.WarehouseID, '2026-02-19', '2026-02-24',
           N'Texas Regional Logistics', N'DELIVERED'
    FROM sales.SalesOrders so CROSS JOIN core.Warehouses w
    WHERE so.SalesOrderNumber = N'SO-2026-002' AND w.WarehouseCode = N'DAL';

IF NOT EXISTS
(
    SELECT 1 FROM dist.ShipmentLines sl
    JOIN dist.Shipments sh ON sh.ShipmentID = sl.ShipmentID
    WHERE sh.ShipmentNumber = N'SHP-2026-001'
)
    INSERT INTO dist.ShipmentLines (ShipmentID, SalesOrderLineID, QuantityShipped)
    SELECT sh.ShipmentID, sol.SalesOrderLineID, 10
    FROM dist.Shipments sh
    JOIN sales.SalesOrders so ON so.SalesOrderID = sh.SalesOrderID
    JOIN sales.SalesOrderLines sol ON sol.SalesOrderID = so.SalesOrderID
    WHERE sh.ShipmentNumber = N'SHP-2026-001';

IF NOT EXISTS
(
    SELECT 1 FROM dist.ShipmentLines sl
    JOIN dist.Shipments sh ON sh.ShipmentID = sl.ShipmentID
    WHERE sh.ShipmentNumber = N'SHP-2026-002'
)
    INSERT INTO dist.ShipmentLines (ShipmentID, SalesOrderLineID, QuantityShipped)
    SELECT sh.ShipmentID, sol.SalesOrderLineID, 5
    FROM dist.Shipments sh
    JOIN sales.SalesOrders so ON so.SalesOrderID = sh.SalesOrderID
    JOIN sales.SalesOrderLines sol ON sol.SalesOrderID = so.SalesOrderID
    WHERE sh.ShipmentNumber = N'SHP-2026-002';

/* Inventory transactions.
   Receipts are positive; issues are negative.
   Values are signed inventory-value movements at the illustrative unit cost.
*/
IF NOT EXISTS (SELECT 1 FROM inv.InventoryTransactions WHERE TransactionReference = N'OPEN-DAL-COMP100')
    INSERT INTO inv.InventoryTransactions
        (ProductID, WarehouseID, TransactionDate, TransactionType, QuantityChange, InventoryValueChange, TransactionReference)
    SELECT p.ProductID, w.WarehouseID, '2025-12-31', N'OPENING', 20, 2400.00, N'OPEN-DAL-COMP100'
    FROM core.Products p CROSS JOIN core.Warehouses w
    WHERE p.ProductCode = N'COMP-100' AND w.WarehouseCode = N'DAL';

IF NOT EXISTS (SELECT 1 FROM inv.InventoryTransactions WHERE TransactionReference = N'OPEN-HOU-COMP200')
    INSERT INTO inv.InventoryTransactions
        (ProductID, WarehouseID, TransactionDate, TransactionType, QuantityChange, InventoryValueChange, TransactionReference)
    SELECT p.ProductID, w.WarehouseID, '2025-12-31', N'OPENING', 50, 2300.00, N'OPEN-HOU-COMP200'
    FROM core.Products p CROSS JOIN core.Warehouses w
    WHERE p.ProductCode = N'COMP-200' AND w.WarehouseCode = N'HOU';

IF NOT EXISTS (SELECT 1 FROM inv.InventoryTransactions WHERE TransactionReference = N'OPEN-DAL-FIN100')
    INSERT INTO inv.InventoryTransactions
        (ProductID, WarehouseID, TransactionDate, TransactionType, QuantityChange, InventoryValueChange, TransactionReference)
    SELECT p.ProductID, w.WarehouseID, '2025-12-31', N'OPENING', 8, 2640.00, N'OPEN-DAL-FIN100'
    FROM core.Products p CROSS JOIN core.Warehouses w
    WHERE p.ProductCode = N'FIN-100' AND w.WarehouseCode = N'DAL';

IF NOT EXISTS (SELECT 1 FROM inv.InventoryTransactions WHERE TransactionReference = N'RCPT-PO001-L1')
    INSERT INTO inv.InventoryTransactions
        (ProductID, WarehouseID, TransactionDate, TransactionType, QuantityChange, InventoryValueChange,
         PurchaseOrderLineID, TransactionReference)
    SELECT p.ProductID, w.WarehouseID, '2026-01-11', N'PURCHASE_RECEIPT', 100, 12000.00,
           pol.PurchaseOrderLineID, N'RCPT-PO001-L1'
    FROM core.Products p
    CROSS JOIN core.Warehouses w
    JOIN purchasing.PurchaseOrders po ON po.PurchaseOrderNumber = N'PO-2026-001'
    JOIN purchasing.PurchaseOrderLines pol ON pol.PurchaseOrderID = po.PurchaseOrderID AND pol.LineNumber = 1
    WHERE p.ProductCode = N'COMP-100' AND w.WarehouseCode = N'HOU';

IF NOT EXISTS (SELECT 1 FROM inv.InventoryTransactions WHERE TransactionReference = N'RCPT-PO001-L2')
    INSERT INTO inv.InventoryTransactions
        (ProductID, WarehouseID, TransactionDate, TransactionType, QuantityChange, InventoryValueChange,
         PurchaseOrderLineID, TransactionReference)
    SELECT p.ProductID, w.WarehouseID, '2026-01-11', N'PURCHASE_RECEIPT', 200, 9200.00,
           pol.PurchaseOrderLineID, N'RCPT-PO001-L2'
    FROM core.Products p
    CROSS JOIN core.Warehouses w
    JOIN purchasing.PurchaseOrders po ON po.PurchaseOrderNumber = N'PO-2026-001'
    JOIN purchasing.PurchaseOrderLines pol ON pol.PurchaseOrderID = po.PurchaseOrderID AND pol.LineNumber = 2
    WHERE p.ProductCode = N'COMP-200' AND w.WarehouseCode = N'HOU';

IF NOT EXISTS (SELECT 1 FROM inv.InventoryTransactions WHERE TransactionReference = N'RCPT-PO002-L1')
    INSERT INTO inv.InventoryTransactions
        (ProductID, WarehouseID, TransactionDate, TransactionType, QuantityChange, InventoryValueChange,
         PurchaseOrderLineID, TransactionReference)
    SELECT p.ProductID, w.WarehouseID, '2026-02-13', N'PURCHASE_RECEIPT', 60, 19800.00,
           pol.PurchaseOrderLineID, N'RCPT-PO002-L1'
    FROM core.Products p
    CROSS JOIN core.Warehouses w
    JOIN purchasing.PurchaseOrders po ON po.PurchaseOrderNumber = N'PO-2026-002'
    JOIN purchasing.PurchaseOrderLines pol ON pol.PurchaseOrderID = po.PurchaseOrderID AND pol.LineNumber = 1
    WHERE p.ProductCode = N'FIN-100' AND w.WarehouseCode = N'DAL';

IF NOT EXISTS (SELECT 1 FROM inv.InventoryTransactions WHERE TransactionReference = N'PROD-REC-001')
    INSERT INTO inv.InventoryTransactions
        (ProductID, WarehouseID, TransactionDate, TransactionType, QuantityChange, InventoryValueChange,
         ProductionOrderID, TransactionReference)
    SELECT p.ProductID, w.WarehouseID, '2026-01-19', N'PRODUCTION_RECEIPT', 30, 9900.00,
           po.ProductionOrderID, N'PROD-REC-001'
    FROM core.Products p
    CROSS JOIN core.Warehouses w
    JOIN mfg.ProductionOrders po ON po.ProductionOrderNumber = N'PROD-2026-001'
    WHERE p.ProductCode = N'FIN-100' AND w.WarehouseCode = N'HOU';

IF NOT EXISTS (SELECT 1 FROM inv.InventoryTransactions WHERE TransactionReference = N'SALE-ISSUE-001')
    INSERT INTO inv.InventoryTransactions
        (ProductID, WarehouseID, TransactionDate, TransactionType, QuantityChange, InventoryValueChange,
         SalesOrderLineID, TransactionReference)
    SELECT p.ProductID, w.WarehouseID, '2026-01-21', N'SALE_ISSUE', -10, -1200.00,
           sol.SalesOrderLineID, N'SALE-ISSUE-001'
    FROM core.Products p
    CROSS JOIN core.Warehouses w
    JOIN sales.SalesOrders so ON so.SalesOrderNumber = N'SO-2026-001'
    JOIN sales.SalesOrderLines sol ON sol.SalesOrderID = so.SalesOrderID AND sol.LineNumber = 1
    WHERE p.ProductCode = N'COMP-100' AND w.WarehouseCode = N'DAL';

IF NOT EXISTS (SELECT 1 FROM inv.InventoryTransactions WHERE TransactionReference = N'SALE-ISSUE-002')
    INSERT INTO inv.InventoryTransactions
        (ProductID, WarehouseID, TransactionDate, TransactionType, QuantityChange, InventoryValueChange,
         SalesOrderLineID, TransactionReference)
    SELECT p.ProductID, w.WarehouseID, '2026-02-19', N'SALE_ISSUE', -5, -1650.00,
           sol.SalesOrderLineID, N'SALE-ISSUE-002'
    FROM core.Products p
    CROSS JOIN core.Warehouses w
    JOIN sales.SalesOrders so ON so.SalesOrderNumber = N'SO-2026-002'
    JOIN sales.SalesOrderLines sol ON sol.SalesOrderID = so.SalesOrderID AND sol.LineNumber = 1
    WHERE p.ProductCode = N'FIN-100' AND w.WarehouseCode = N'DAL';

PRINT 'Synthetic sample data loaded or already present.';
GO

/* Quick validation counts */
SELECT N'Customers' AS EntityName, COUNT_BIG(*) AS RecordCount FROM core.Customers
UNION ALL SELECT N'Suppliers', COUNT_BIG(*) FROM core.Suppliers
UNION ALL SELECT N'Products', COUNT_BIG(*) FROM core.Products
UNION ALL SELECT N'Warehouses', COUNT_BIG(*) FROM core.Warehouses
UNION ALL SELECT N'SalesOrders', COUNT_BIG(*) FROM sales.SalesOrders
UNION ALL SELECT N'PurchaseOrders', COUNT_BIG(*) FROM purchasing.PurchaseOrders
UNION ALL SELECT N'ProductionOrders', COUNT_BIG(*) FROM mfg.ProductionOrders
UNION ALL SELECT N'Shipments', COUNT_BIG(*) FROM dist.Shipments
UNION ALL SELECT N'InventoryTransactions', COUNT_BIG(*) FROM inv.InventoryTransactions;
GO
