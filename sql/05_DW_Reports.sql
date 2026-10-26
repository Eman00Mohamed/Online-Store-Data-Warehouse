/* =====================================================================
   05_DW_Reports.sql
   Step 5 - Reports on MiniStoreDW (FactSales already holds Completed only)
   ===================================================================== */
USE MiniStoreDW;
GO

-- R1. Total completed sales revenue
SELECT SUM(SalesAmount) AS TotalCompletedRevenue
FROM   dbo.FactSales;

-- R2. Total sales amount by product
SELECT p.ProductName,
       SUM(f.SalesAmount) AS TotalSales
FROM   dbo.FactSales AS f
JOIN   dbo.DimProduct AS p ON p.ProductKey = f.ProductKey
GROUP  BY p.ProductName
ORDER  BY TotalSales DESC;

-- R3. Total sales amount by customer
SELECT c.CustomerName,
       SUM(f.SalesAmount) AS TotalSales
FROM   dbo.FactSales AS f
JOIN   dbo.DimCustomer AS c ON c.CustomerKey = f.CustomerKey
GROUP  BY c.CustomerName
ORDER  BY TotalSales DESC;

-- R4. Total sales amount by city
SELECT c.City,
       SUM(f.SalesAmount) AS TotalSales
FROM   dbo.FactSales AS f
JOIN   dbo.DimCustomer AS c ON c.CustomerKey = f.CustomerKey
GROUP  BY c.City
ORDER  BY TotalSales DESC;

-- R5. Total sales amount by month
SELECT d.[Year],
       d.[Month],
       d.MonthName,
       SUM(f.SalesAmount) AS TotalSales
FROM   dbo.FactSales AS f
JOIN   dbo.DimDate   AS d ON d.DateKey = f.DateKey
GROUP  BY d.[Year], d.[Month], d.MonthName
ORDER  BY d.[Year], d.[Month];

-- R6. Product with the highest revenue
SELECT TOP (1) WITH TIES
       p.ProductName,
       SUM(f.SalesAmount) AS TotalSales
FROM   dbo.FactSales AS f
JOIN   dbo.DimProduct AS p ON p.ProductKey = f.ProductKey
GROUP  BY p.ProductName
ORDER  BY TotalSales DESC;
GO
