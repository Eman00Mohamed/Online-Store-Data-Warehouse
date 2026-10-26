/* =====================================================================
   02_Source_Queries.sql
   Step 2 - SQL queries on MiniStoreSource
   Rule: SalesAmount = Quantity * UnitPrice
         Sales reports count ONLY OrderStatus = 'Completed'.
   ===================================================================== */
USE MiniStoreSource;
GO

-- Q1. All customers and their cities
SELECT CustomerID, CustomerName, City
FROM   dbo.Customers
ORDER  BY CustomerID;

-- Q2. Each order with customer name and order date
SELECT o.OrderID,
       c.CustomerName,
       o.OrderDate,
       o.OrderStatus
FROM   dbo.Orders    AS o
JOIN   dbo.Customers AS c ON c.CustomerID = o.CustomerID
ORDER  BY o.OrderID;

-- Q3. Total sales amount for each order (Completed orders only)
SELECT o.OrderID,
       o.OrderDate,
       SUM(oi.Quantity * oi.UnitPrice) AS OrderSalesAmount
FROM   dbo.Orders     AS o
JOIN   dbo.OrderItems AS oi ON oi.OrderID = o.OrderID
WHERE  o.OrderStatus = N'Completed'
GROUP  BY o.OrderID, o.OrderDate
ORDER  BY o.OrderID;

-- Q4. Total sales for each product (Completed only)
--     Completed sales are aggregated in a derived table first, so products
--     with no completed sales still appear with 0.
SELECT p.ProductID,
       p.ProductName,
       COALESCE(s.TotalSales, 0) AS TotalSales
FROM   dbo.Products AS p
LEFT   JOIN (SELECT oi.ProductID,
                    SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
             FROM   dbo.OrderItems AS oi
             JOIN   dbo.Orders     AS o ON o.OrderID = oi.OrderID
             WHERE  o.OrderStatus = N'Completed'
             GROUP  BY oi.ProductID) AS s ON s.ProductID = p.ProductID
ORDER  BY TotalSales DESC;

-- Q5. Total sales for each customer (Completed only; customers with no
--     completed orders show 0)
SELECT c.CustomerID,
       LTRIM(RTRIM(c.CustomerName)) AS CustomerName,
       COALESCE(SUM(oi.Quantity * oi.UnitPrice), 0) AS TotalSales
FROM   dbo.Customers AS c
LEFT   JOIN dbo.Orders     AS o  ON o.CustomerID = c.CustomerID
                                AND o.OrderStatus = N'Completed'
LEFT   JOIN dbo.OrderItems AS oi ON oi.OrderID   = o.OrderID
GROUP  BY c.CustomerID, c.CustomerName
ORDER  BY TotalSales DESC;

-- Q6. Product with the highest sales (Completed only)
--     TOP 1 WITH TIES returns all products if there is a tie.
SELECT TOP (1) WITH TIES
       p.ProductID,
       p.ProductName,
       SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
FROM   dbo.OrderItems AS oi
JOIN   dbo.Orders     AS o ON o.OrderID   = oi.OrderID
JOIN   dbo.Products   AS p ON p.ProductID = oi.ProductID
WHERE  o.OrderStatus = N'Completed'
GROUP  BY p.ProductID, p.ProductName
ORDER  BY TotalSales DESC;

-- Q7. Number of orders in each status
SELECT OrderStatus,
       COUNT(*) AS NumberOfOrders
FROM   dbo.Orders
GROUP  BY OrderStatus
ORDER  BY NumberOfOrders DESC;

-- Bonus (HAVING): customers whose completed sales exceed 10,000
SELECT c.CustomerID,
       LTRIM(RTRIM(c.CustomerName)) AS CustomerName,
       SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
FROM   dbo.Customers  AS c
JOIN   dbo.Orders     AS o  ON o.CustomerID = c.CustomerID
JOIN   dbo.OrderItems AS oi ON oi.OrderID   = o.OrderID
WHERE  o.OrderStatus = N'Completed'
GROUP  BY c.CustomerID, c.CustomerName
HAVING SUM(oi.Quantity * oi.UnitPrice) > 10000
ORDER  BY TotalSales DESC;
GO
