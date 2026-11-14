/*
    Zaryn Data Engineering
    Project: Manufacturing Analytics
    Script: 02_create_tables.sql

    Purpose:
      Creates schemas, tables, constraints, and indexes.

    Run after 01_create_database.sql.
*/

USE [ZarynManufacturingAnalytics];
GO

/* Create logical schemas */
IF SCHEMA_ID(N'core') IS NULL EXEC(N'CREATE SCHEMA core');
IF SCHEMA_ID(N'sales') IS NULL EXEC(N'CREATE SCHEMA sales');
IF SCHEMA_ID(N'purchasing') IS NULL EXEC(N'CREATE SCHEMA purchasing');
IF SCHEMA_ID(N'mfg') IS NULL EXEC(N'CREATE SCHEMA mfg');
IF SCHEMA_ID(N'dist') IS NULL EXEC(N'CREATE SCHEMA dist');
IF SCHEMA_ID(N'inv') IS NULL EXEC(N'CREATE SCHEMA inv');
GO

/* Core reference data */
IF OBJECT_ID(N'core.Customers', N'U') IS NULL
BEGIN
    CREATE TABLE core.Customers
    (
        CustomerID       INT IDENTITY(1,1) CONSTRAINT PK_Customers PRIMARY KEY,
        CustomerCode     NVARCHAR(30) NOT NULL CONSTRAINT UQ_Customers_CustomerCode UNIQUE,
        CustomerName     NVARCHAR(200) NOT NULL,
        City             NVARCHAR(100) NULL,
        StateProvince    NVARCHAR(100) NULL,
        Country          NVARCHAR(100) NOT NULL CONSTRAINT DF_Customers_Country DEFAULT N'USA',
        IsActive         BIT NOT NULL CONSTRAINT DF_Customers_IsActive DEFAULT (1),
        CreatedAt        DATETIME2(0) NOT NULL CONSTRAINT DF_Customers_CreatedAt DEFAULT SYSUTCDATETIME()
    );
END;
GO

IF OBJECT_ID(N'core.Suppliers', N'U') IS NULL
BEGIN
    CREATE TABLE core.Suppliers
    (
        SupplierID       INT IDENTITY(1,1) CONSTRAINT PK_Suppliers PRIMARY KEY,
        SupplierCode     NVARCHAR(30) NOT NULL CONSTRAINT UQ_Suppliers_SupplierCode UNIQUE,
        SupplierName     NVARCHAR(200) NOT NULL,
        City             NVARCHAR(100) NULL,
        StateProvince    NVARCHAR(100) NULL,
        Country          NVARCHAR(100) NOT NULL CONSTRAINT DF_Suppliers_Country DEFAULT N'USA',
        IsActive         BIT NOT NULL CONSTRAINT DF_Suppliers_IsActive DEFAULT (1),
        CreatedAt        DATETIME2(0) NOT NULL CONSTRAINT DF_Suppliers_CreatedAt DEFAULT SYSUTCDATETIME()
    );
END;
GO

IF OBJECT_ID(N'core.ProductCategories', N'U') IS NULL
BEGIN
    CREATE TABLE core.ProductCategories
    (
        ProductCategoryID INT IDENTITY(1,1) CONSTRAINT PK_ProductCategories PRIMARY KEY,
        CategoryCode      NVARCHAR(30) NOT NULL CONSTRAINT UQ_ProductCategories_Code UNIQUE,
        CategoryName      NVARCHAR(100) NOT NULL
    );
END;
GO

IF OBJECT_ID(N'core.Products', N'U') IS NULL
BEGIN
    CREATE TABLE core.Products
    (
        ProductID          INT IDENTITY(1,1) CONSTRAINT PK_Products PRIMARY KEY,
        ProductCode        NVARCHAR(40) NOT NULL CONSTRAINT UQ_Products_ProductCode UNIQUE,
        ProductName        NVARCHAR(200) NOT NULL,
        ProductCategoryID  INT NOT NULL,
        UnitOfMeasure      NVARCHAR(20) NOT NULL CONSTRAINT DF_Products_UOM DEFAULT N'EA',
        StandardUnitCost   DECIMAL(19,4) NOT NULL,
        ListUnitPrice      DECIMAL(19,4) NOT NULL,
        IsManufactured     BIT NOT NULL CONSTRAINT DF_Products_IsManufactured DEFAULT (0),
        IsActive           BIT NOT NULL CONSTRAINT DF_Products_IsActive DEFAULT (1),
        CONSTRAINT FK_Products_ProductCategories
            FOREIGN KEY (ProductCategoryID) REFERENCES core.ProductCategories(ProductCategoryID),
        CONSTRAINT CK_Products_StandardUnitCost CHECK (StandardUnitCost >= 0),
        CONSTRAINT CK_Products_ListUnitPrice CHECK (ListUnitPrice >= 0)
    );
END;
GO

IF OBJECT_ID(N'core.Warehouses', N'U') IS NULL
BEGIN
    CREATE TABLE core.Warehouses
    (
        WarehouseID     INT IDENTITY(1,1) CONSTRAINT PK_Warehouses PRIMARY KEY,
        WarehouseCode   NVARCHAR(30) NOT NULL CONSTRAINT UQ_Warehouses_WarehouseCode UNIQUE,
        WarehouseName   NVARCHAR(150) NOT NULL,
        City            NVARCHAR(100) NULL,
        StateProvince   NVARCHAR(100) NULL,
        IsActive        BIT NOT NULL CONSTRAINT DF_Warehouses_IsActive DEFAULT (1)
    );
END;
GO

/* Sales */
IF OBJECT_ID(N'sales.SalesOrders', N'U') IS NULL
BEGIN
    CREATE TABLE sales.SalesOrders
    (
        SalesOrderID    INT IDENTITY(1,1) CONSTRAINT PK_SalesOrders PRIMARY KEY,
        SalesOrderNumber NVARCHAR(30) NOT NULL CONSTRAINT UQ_SalesOrders_Number UNIQUE,
        CustomerID      INT NOT NULL,
        OrderDate       DATE NOT NULL,
        RequestedShipDate DATE NULL,
        OrderStatus     NVARCHAR(20) NOT NULL,
        CONSTRAINT FK_SalesOrders_Customers
            FOREIGN KEY (CustomerID) REFERENCES core.Customers(CustomerID),
        CONSTRAINT CK_SalesOrders_Status
            CHECK (OrderStatus IN (N'OPEN', N'IN_PROGRESS', N'SHIPPED', N'CANCELLED', N'CLOSED'))
    );
END;
GO

IF OBJECT_ID(N'sales.SalesOrderLines', N'U') IS NULL
BEGIN
    CREATE TABLE sales.SalesOrderLines
    (
        SalesOrderLineID INT IDENTITY(1,1) CONSTRAINT PK_SalesOrderLines PRIMARY KEY,
        SalesOrderID     INT NOT NULL,
        LineNumber       INT NOT NULL,
        ProductID        INT NOT NULL,
        QuantityOrdered  DECIMAL(18,4) NOT NULL,
        UnitPrice        DECIMAL(19,4) NOT NULL,
        UnitCostAtSale   DECIMAL(19,4) NOT NULL,
        CONSTRAINT FK_SalesOrderLines_SalesOrders
            FOREIGN KEY (SalesOrderID) REFERENCES sales.SalesOrders(SalesOrderID),
        CONSTRAINT FK_SalesOrderLines_Products
            FOREIGN KEY (ProductID) REFERENCES core.Products(ProductID),
        CONSTRAINT UQ_SalesOrderLines_Order_Line UNIQUE (SalesOrderID, LineNumber),
        CONSTRAINT CK_SalesOrderLines_Quantity CHECK (QuantityOrdered > 0),
        CONSTRAINT CK_SalesOrderLines_Prices CHECK (UnitPrice >= 0 AND UnitCostAtSale >= 0)
    );
END;
GO

/* Purchasing */
IF OBJECT_ID(N'purchasing.PurchaseOrders', N'U') IS NULL
BEGIN
    CREATE TABLE purchasing.PurchaseOrders
    (
        PurchaseOrderID     INT IDENTITY(1,1) CONSTRAINT PK_PurchaseOrders PRIMARY KEY,
        PurchaseOrderNumber NVARCHAR(30) NOT NULL CONSTRAINT UQ_PurchaseOrders_Number UNIQUE,
        SupplierID          INT NOT NULL,
        WarehouseID         INT NOT NULL,
        OrderDate           DATE NOT NULL,
        ExpectedDeliveryDate DATE NULL,
        ActualDeliveryDate  DATE NULL,
        PurchaseOrderStatus NVARCHAR(20) NOT NULL,
        CONSTRAINT FK_PurchaseOrders_Suppliers
            FOREIGN KEY (SupplierID) REFERENCES core.Suppliers(SupplierID),
        CONSTRAINT FK_PurchaseOrders_Warehouses
            FOREIGN KEY (WarehouseID) REFERENCES core.Warehouses(WarehouseID),
        CONSTRAINT CK_PurchaseOrders_Status
            CHECK (PurchaseOrderStatus IN (N'OPEN', N'PARTIALLY_RECEIVED', N'RECEIVED', N'CANCELLED'))
    );
END;
GO

IF OBJECT_ID(N'purchasing.PurchaseOrderLines', N'U') IS NULL
BEGIN
    CREATE TABLE purchasing.PurchaseOrderLines
    (
        PurchaseOrderLineID INT IDENTITY(1,1) CONSTRAINT PK_PurchaseOrderLines PRIMARY KEY,
        PurchaseOrderID     INT NOT NULL,
        LineNumber          INT NOT NULL,
        ProductID           INT NOT NULL,
        QuantityOrdered     DECIMAL(18,4) NOT NULL,
        QuantityReceived    DECIMAL(18,4) NOT NULL CONSTRAINT DF_POL_QuantityReceived DEFAULT (0),
        UnitCost            DECIMAL(19,4) NOT NULL,
        CONSTRAINT FK_PurchaseOrderLines_PurchaseOrders
            FOREIGN KEY (PurchaseOrderID) REFERENCES purchasing.PurchaseOrders(PurchaseOrderID),
        CONSTRAINT FK_PurchaseOrderLines_Products
            FOREIGN KEY (ProductID) REFERENCES core.Products(ProductID),
        CONSTRAINT UQ_PurchaseOrderLines_Order_Line UNIQUE (PurchaseOrderID, LineNumber),
        CONSTRAINT CK_PurchaseOrderLines_Quantities
            CHECK (QuantityOrdered > 0 AND QuantityReceived >= 0 AND QuantityReceived <= QuantityOrdered),
        CONSTRAINT CK_PurchaseOrderLines_UnitCost CHECK (UnitCost >= 0)
    );
END;
GO

/* Manufacturing */
IF OBJECT_ID(N'mfg.ProductionOrders', N'U') IS NULL
BEGIN
    CREATE TABLE mfg.ProductionOrders
    (
        ProductionOrderID   INT IDENTITY(1,1) CONSTRAINT PK_ProductionOrders PRIMARY KEY,
        ProductionOrderNumber NVARCHAR(30) NOT NULL CONSTRAINT UQ_ProductionOrders_Number UNIQUE,
        ProductID           INT NOT NULL,
        WarehouseID         INT NOT NULL,
        PlannedQuantity     DECIMAL(18,4) NOT NULL,
        CompletedQuantity   DECIMAL(18,4) NOT NULL CONSTRAINT DF_ProductionOrders_Completed DEFAULT (0),
        PlannedStartDate    DATE NOT NULL,
        ActualStartDate     DATE NULL,
        PlannedEndDate      DATE NOT NULL,
        ActualEndDate       DATE NULL,
        ProductionStatus    NVARCHAR(20) NOT NULL,
        CONSTRAINT FK_ProductionOrders_Products
            FOREIGN KEY (ProductID) REFERENCES core.Products(ProductID),
        CONSTRAINT FK_ProductionOrders_Warehouses
            FOREIGN KEY (WarehouseID) REFERENCES core.Warehouses(WarehouseID),
        CONSTRAINT CK_ProductionOrders_Quantities
            CHECK (PlannedQuantity > 0 AND CompletedQuantity >= 0),
        CONSTRAINT CK_ProductionOrders_Dates CHECK (PlannedEndDate >= PlannedStartDate),
        CONSTRAINT CK_ProductionOrders_Status
            CHECK (ProductionStatus IN (N'PLANNED', N'RELEASED', N'IN_PROGRESS', N'COMPLETED', N'CANCELLED'))
    );
END;
GO

/* Distribution */
IF OBJECT_ID(N'dist.Shipments', N'U') IS NULL
BEGIN
    CREATE TABLE dist.Shipments
    (
        ShipmentID       INT IDENTITY(1,1) CONSTRAINT PK_Shipments PRIMARY KEY,
        ShipmentNumber   NVARCHAR(30) NOT NULL CONSTRAINT UQ_Shipments_Number UNIQUE,
        SalesOrderID     INT NOT NULL,
        WarehouseID      INT NOT NULL,
        ShipDate         DATE NULL,
        DeliveryDate     DATE NULL,
        CarrierName      NVARCHAR(100) NULL,
        ShipmentStatus   NVARCHAR(20) NOT NULL,
        CONSTRAINT FK_Shipments_SalesOrders
            FOREIGN KEY (SalesOrderID) REFERENCES sales.SalesOrders(SalesOrderID),
        CONSTRAINT FK_Shipments_Warehouses
            FOREIGN KEY (WarehouseID) REFERENCES core.Warehouses(WarehouseID),
        CONSTRAINT CK_Shipments_Dates CHECK (DeliveryDate IS NULL OR ShipDate IS NULL OR DeliveryDate >= ShipDate),
        CONSTRAINT CK_Shipments_Status
            CHECK (ShipmentStatus IN (N'PENDING', N'SHIPPED', N'DELIVERED', N'DELAYED', N'CANCELLED'))
    );
END;
GO

IF OBJECT_ID(N'dist.ShipmentLines', N'U') IS NULL
BEGIN
    CREATE TABLE dist.ShipmentLines
    (
        ShipmentLineID   INT IDENTITY(1,1) CONSTRAINT PK_ShipmentLines PRIMARY KEY,
        ShipmentID       INT NOT NULL,
        SalesOrderLineID INT NOT NULL,
        QuantityShipped  DECIMAL(18,4) NOT NULL,
        CONSTRAINT FK_ShipmentLines_Shipments
            FOREIGN KEY (ShipmentID) REFERENCES dist.Shipments(ShipmentID),
        CONSTRAINT FK_ShipmentLines_SalesOrderLines
            FOREIGN KEY (SalesOrderLineID) REFERENCES sales.SalesOrderLines(SalesOrderLineID),
        CONSTRAINT CK_ShipmentLines_Quantity CHECK (QuantityShipped > 0)
    );
END;
GO

/* Inventory movements: one row per inventory transaction */
IF OBJECT_ID(N'inv.InventoryTransactions', N'U') IS NULL
BEGIN
    CREATE TABLE inv.InventoryTransactions
    (
        InventoryTransactionID BIGINT IDENTITY(1,1) CONSTRAINT PK_InventoryTransactions PRIMARY KEY,
        ProductID               INT NOT NULL,
        WarehouseID             INT NOT NULL,
        TransactionDate         DATETIME2(0) NOT NULL,
        TransactionType         NVARCHAR(30) NOT NULL,
        QuantityChange          DECIMAL(18,4) NOT NULL,
        InventoryValueChange    DECIMAL(19,4) NOT NULL,
        SalesOrderLineID         INT NULL,
        PurchaseOrderLineID      INT NULL,
        ProductionOrderID        INT NULL,
        TransferGroupID          UNIQUEIDENTIFIER NULL,
        TransactionReference     NVARCHAR(100) NOT NULL,
        CreatedAt                DATETIME2(0) NOT NULL CONSTRAINT DF_InventoryTransactions_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_InventoryTransactions_Products
            FOREIGN KEY (ProductID) REFERENCES core.Products(ProductID),
        CONSTRAINT FK_InventoryTransactions_Warehouses
            FOREIGN KEY (WarehouseID) REFERENCES core.Warehouses(WarehouseID),
        CONSTRAINT FK_InventoryTransactions_SalesOrderLines
            FOREIGN KEY (SalesOrderLineID) REFERENCES sales.SalesOrderLines(SalesOrderLineID),
        CONSTRAINT FK_InventoryTransactions_PurchaseOrderLines
            FOREIGN KEY (PurchaseOrderLineID) REFERENCES purchasing.PurchaseOrderLines(PurchaseOrderLineID),
        CONSTRAINT FK_InventoryTransactions_ProductionOrders
            FOREIGN KEY (ProductionOrderID) REFERENCES mfg.ProductionOrders(ProductionOrderID),
        CONSTRAINT UQ_InventoryTransactions_Reference UNIQUE (TransactionReference),
        CONSTRAINT CK_InventoryTransactions_Type CHECK
        (
            TransactionType IN
            (N'OPENING', N'PURCHASE_RECEIPT', N'PRODUCTION_RECEIPT',
             N'PRODUCTION_ISSUE', N'SALE_ISSUE', N'TRANSFER_IN',
             N'TRANSFER_OUT', N'ADJUSTMENT')
        ),
        CONSTRAINT CK_InventoryTransactions_Quantity CHECK (QuantityChange <> 0),
        CONSTRAINT CK_InventoryTransactions_Direction CHECK
        (
            (TransactionType IN (N'PURCHASE_RECEIPT', N'PRODUCTION_RECEIPT', N'TRANSFER_IN')
                AND QuantityChange > 0 AND InventoryValueChange >= 0)
            OR
            (TransactionType IN (N'PRODUCTION_ISSUE', N'SALE_ISSUE', N'TRANSFER_OUT')
                AND QuantityChange < 0 AND InventoryValueChange <= 0)
            OR
            (TransactionType IN (N'OPENING', N'ADJUSTMENT'))
        )
    );
END;
GO

/* Useful indexes for common reporting and filtering */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_InventoryTransactions_Warehouse_Date' AND object_id = OBJECT_ID(N'inv.InventoryTransactions'))
    CREATE INDEX IX_InventoryTransactions_Warehouse_Date
        ON inv.InventoryTransactions(WarehouseID, TransactionDate)
        INCLUDE (ProductID, TransactionType, QuantityChange, InventoryValueChange);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_InventoryTransactions_Product_Date' AND object_id = OBJECT_ID(N'inv.InventoryTransactions'))
    CREATE INDEX IX_InventoryTransactions_Product_Date
        ON inv.InventoryTransactions(ProductID, TransactionDate)
        INCLUDE (WarehouseID, TransactionType, QuantityChange, InventoryValueChange);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SalesOrders_Customer_OrderDate' AND object_id = OBJECT_ID(N'sales.SalesOrders'))
    CREATE INDEX IX_SalesOrders_Customer_OrderDate
        ON sales.SalesOrders(CustomerID, OrderDate);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PurchaseOrders_Supplier_OrderDate' AND object_id = OBJECT_ID(N'purchasing.PurchaseOrders'))
    CREATE INDEX IX_PurchaseOrders_Supplier_OrderDate
        ON purchasing.PurchaseOrders(SupplierID, OrderDate);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Shipments_Warehouse_ShipDate' AND object_id = OBJECT_ID(N'dist.Shipments'))
    CREATE INDEX IX_Shipments_Warehouse_ShipDate
        ON dist.Shipments(WarehouseID, ShipDate);
GO

PRINT 'Schemas, tables, constraints, and indexes created or already present.';
GO
