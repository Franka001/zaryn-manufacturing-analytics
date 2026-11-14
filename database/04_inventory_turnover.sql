/*
    Zaryn Data Engineering
    Project: Manufacturing Analytics
    Script: 04_inventory_turnover.sql

    Purpose:
      Calculates inventory turnover by warehouse for a selected reporting period.

    Definition:
      Inventory Turnover = Cost of Goods Sold / Average Inventory Value

      Average Inventory Value in this starter query:
      (Opening Inventory Value + Closing Inventory Value) / 2

    Important:
      - @EndDate is exclusive. For Q1 2026, use 2026-04-01.
      - InventoryValueChange must be consistently valued and signed:
          receipts positive; issues negative.
      - COGS is derived from SALE_ISSUE transactions only.
      - This is a period turnover ratio, not annualized.
      - For highly seasonal businesses, use daily/monthly average inventory
        rather than only opening and closing balances.
*/

USE [ZarynManufacturingAnalytics];
GO

DECLARE @StartDate       DATE = '2026-01-01';
DECLARE @EndDate         DATE = '2026-04-01'; -- exclusive: includes through 2026-03-31

IF @EndDate <= @StartDate
BEGIN
    THROW 50001, 'End date must be later than start date.', 1;
END;

;WITH WarehouseBalances AS
(
    SELECT
        w.WarehouseID,
        w.WarehouseCode,
        w.WarehouseName,

        /* Inventory value immediately before the reporting period */
        COALESCE(SUM(CASE
            WHEN it.TransactionDate < @StartDate
            THEN it.InventoryValueChange
            ELSE 0
        END), 0) AS OpeningInventoryValue,

        /* Inventory value through the day before @EndDate */
        COALESCE(SUM(CASE
            WHEN it.TransactionDate < @EndDate
            THEN it.InventoryValueChange
            ELSE 0
        END), 0) AS ClosingInventoryValue,

        /* COGS during the selected period: reverse the negative issue value */
        COALESCE(SUM(CASE
            WHEN it.TransactionDate >= @StartDate
             AND it.TransactionDate < @EndDate
             AND it.TransactionType = N'SALE_ISSUE'
            THEN -it.InventoryValueChange
            ELSE 0
        END), 0) AS PeriodCOGS
    FROM core.Warehouses AS w
    LEFT JOIN inv.InventoryTransactions AS it
        ON it.WarehouseID = w.WarehouseID
    GROUP BY
        w.WarehouseID,
        w.WarehouseCode,
        w.WarehouseName
),
Turnover AS
(
    SELECT
        WarehouseID,
        WarehouseCode,
        WarehouseName,
        OpeningInventoryValue,
        ClosingInventoryValue,
        (OpeningInventoryValue + ClosingInventoryValue) / 2.0 AS AverageInventoryValue,
        PeriodCOGS
    FROM WarehouseBalances
)
SELECT
    WarehouseCode,
    WarehouseName,
    @StartDate AS PeriodStartDate,
    DATEADD(DAY, -1, @EndDate) AS PeriodEndDate,
    CAST(OpeningInventoryValue AS DECIMAL(19,2)) AS OpeningInventoryValue,
    CAST(ClosingInventoryValue AS DECIMAL(19,2)) AS ClosingInventoryValue,
    CAST(AverageInventoryValue AS DECIMAL(19,2)) AS AverageInventoryValue,
    CAST(PeriodCOGS AS DECIMAL(19,2)) AS PeriodCOGS,
    CAST
    (
        CASE
            WHEN AverageInventoryValue > 0
            THEN PeriodCOGS / AverageInventoryValue
            ELSE NULL
        END
        AS DECIMAL(18,4)
    ) AS InventoryTurnoverRatio,
    CASE
        WHEN AverageInventoryValue <= 0 THEN N'CHECK INVENTORY BALANCE'
        WHEN PeriodCOGS = 0 THEN N'NO SALES COGS IN PERIOD'
        ELSE N'CALCULATED'
    END AS CalculationStatus
FROM Turnover
ORDER BY WarehouseCode;
GO

/*
    Optional detail query:
    View inventory movement by warehouse and product for the same period.
*/
DECLARE @DetailStartDate DATE = '2026-01-01';
DECLARE @DetailEndDate   DATE = '2026-04-01';

SELECT
    w.WarehouseCode,
    w.WarehouseName,
    p.ProductCode,
    p.ProductName,
    SUM(it.QuantityChange) AS NetQuantityChange,
    SUM(it.InventoryValueChange) AS NetInventoryValueChange,
    SUM(CASE WHEN it.TransactionType = N'SALE_ISSUE'
             THEN -it.InventoryValueChange ELSE 0 END) AS SalesCOGS
FROM inv.InventoryTransactions AS it
JOIN core.Warehouses AS w
    ON w.WarehouseID = it.WarehouseID
JOIN core.Products AS p
    ON p.ProductID = it.ProductID
WHERE it.TransactionDate >= @DetailStartDate
  AND it.TransactionDate < @DetailEndDate
GROUP BY
    w.WarehouseCode,
    w.WarehouseName,
    p.ProductCode,
    p.ProductName
ORDER BY
    w.WarehouseCode,
    p.ProductCode;
GO
