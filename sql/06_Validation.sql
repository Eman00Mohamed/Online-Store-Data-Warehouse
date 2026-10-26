/* =====================================================================
   06_Validation.sql
   Step 6 - Compare MiniStoreSource with MiniStoreDW.
   Both databases must be on the same SQL Server instance.
   Every check returns Expected, Actual and PASS / FAIL.
   ===================================================================== */
USE MiniStoreDW;
GO

SELECT CheckName, Expected, Actual,
       CASE WHEN Expected = Actual THEN 'PASS' ELSE 'FAIL' END AS Result
FROM
(
    -- 1. All customers loaded
    SELECT 'All customers loaded' AS CheckName,
           CAST((SELECT COUNT(*) FROM MiniStoreSource.dbo.Customers) AS DECIMAL(18,2)) AS Expected,
           CAST((SELECT COUNT(*) FROM dbo.DimCustomer)               AS DECIMAL(18,2)) AS Actual
    UNION ALL
    -- 2. All products loaded
    SELECT 'All products loaded',
           (SELECT COUNT(*) FROM MiniStoreSource.dbo.Products),
           (SELECT COUNT(*) FROM dbo.DimProduct)
    UNION ALL
    -- 3. DimDate = distinct source order dates
    SELECT 'DimDate = distinct order dates',
           (SELECT COUNT(DISTINCT OrderDate) FROM MiniStoreSource.dbo.Orders),
           (SELECT COUNT(*) FROM dbo.DimDate)
    UNION ALL
    -- 4. FactSales row count = completed order lines in source
    SELECT 'FactSales rows = completed order lines',
           (SELECT COUNT(*)
            FROM   MiniStoreSource.dbo.OrderItems oi
            JOIN   MiniStoreSource.dbo.Orders o ON o.OrderID = oi.OrderID
            WHERE  o.OrderStatus = N'Completed'),
           (SELECT COUNT(*) FROM dbo.FactSales)
    UNION ALL
    -- 5. No cancelled (non-completed) order in FactSales
    SELECT 'Cancelled order lines in FactSales (must be 0)',
           0,
           (SELECT COUNT(*)
            FROM   dbo.FactSales f
            JOIN   MiniStoreSource.dbo.Orders o ON o.OrderID = f.OrderID
            WHERE  o.OrderStatus <> N'Completed')
    UNION ALL
    -- 6. No fact row with a missing customer / product / date dimension row
    SELECT 'Orphan fact rows (must be 0)',
           0,
           (SELECT COUNT(*)
            FROM   dbo.FactSales f
            LEFT   JOIN dbo.DimCustomer c ON c.CustomerKey = f.CustomerKey
            LEFT   JOIN dbo.DimProduct  p ON p.ProductKey  = f.ProductKey
            LEFT   JOIN dbo.DimDate     d ON d.DateKey     = f.DateKey
            WHERE  c.CustomerKey IS NULL OR p.ProductKey IS NULL OR d.DateKey IS NULL)
    UNION ALL
    -- 7. SalesAmount = Quantity * UnitPrice for every row
    SELECT 'Rows where SalesAmount <> Quantity*UnitPrice (must be 0)',
           0,
           (SELECT COUNT(*) FROM dbo.FactSales
            WHERE  SalesAmount <> Quantity * UnitPrice)
    UNION ALL
    -- 8. Total completed sales: source = DW
    SELECT 'Total completed sales (source = DW)',
           (SELECT SUM(oi.Quantity * oi.UnitPrice)
            FROM   MiniStoreSource.dbo.OrderItems oi
            JOIN   MiniStoreSource.dbo.Orders o ON o.OrderID = oi.OrderID
            WHERE  o.OrderStatus = N'Completed'),
           (SELECT SUM(SalesAmount) FROM dbo.FactSales)
    UNION ALL
    -- 9. Customer names trimmed
    SELECT 'Customer names with extra spaces (must be 0)',
           0,
           (SELECT COUNT(*) FROM dbo.DimCustomer
            WHERE  CustomerName <> LTRIM(RTRIM(CustomerName)))
    UNION ALL
    -- 10. No duplicated order lines in the fact table
    SELECT 'Duplicated OrderItemID in FactSales (must be 0)',
           0,
           (SELECT COUNT(*) FROM
               (SELECT OrderItemID FROM dbo.FactSales
                GROUP BY OrderItemID HAVING COUNT(*) > 1) x)
) AS checks
ORDER BY CheckName;
GO

/* Optional detail: lists any source customer/product missing from the DW
   (empty result = good). */
SELECT sc.CustomerID, sc.CustomerName AS MissingCustomer
FROM   MiniStoreSource.dbo.Customers sc
LEFT   JOIN dbo.DimCustomer dc ON dc.CustomerID = sc.CustomerID
WHERE  dc.CustomerID IS NULL;

SELECT sp.ProductID, sp.ProductName AS MissingProduct
FROM   MiniStoreSource.dbo.Products sp
LEFT   JOIN dbo.DimProduct dp ON dp.ProductID = sp.ProductID
WHERE  dp.ProductID IS NULL;
GO
