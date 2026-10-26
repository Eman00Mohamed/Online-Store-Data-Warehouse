/* =====================================================================
   01_MiniStoreSource_Create_And_Load.sql
   Project : Online Store Data Warehouse (SQL Server + SSIS)
   Purpose : Create the source database MiniStoreSource, its 4 tables,
             and insert sample data.
   Run on  : SQL Server (SSMS) - run the whole script once.
   ===================================================================== */

USE master;
GO

-- Re-runnable: drop the database if it already exists
IF DB_ID(N'MiniStoreSource') IS NOT NULL
BEGIN
    ALTER DATABASE MiniStoreSource SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE MiniStoreSource;
END
GO

CREATE DATABASE MiniStoreSource;
GO

USE MiniStoreSource;
GO

/* ---------------------------- TABLES ------------------------------- */

CREATE TABLE dbo.Customers
(
    CustomerID   INT           NOT NULL CONSTRAINT PK_Customers PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL,
    City         NVARCHAR(50)  NULL
);

CREATE TABLE dbo.Products
(
    ProductID   INT            NOT NULL CONSTRAINT PK_Products PRIMARY KEY,
    ProductName NVARCHAR(100)  NOT NULL,
    Category    NVARCHAR(50)   NULL,
    Price       DECIMAL(10,2)  NOT NULL
);

CREATE TABLE dbo.Orders
(
    OrderID     INT          NOT NULL CONSTRAINT PK_Orders PRIMARY KEY,
    CustomerID  INT          NOT NULL,
    OrderDate   DATE         NOT NULL,
    OrderStatus NVARCHAR(20) NOT NULL,
    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID) REFERENCES dbo.Customers (CustomerID)
);

CREATE TABLE dbo.OrderItems
(
    OrderItemID INT           NOT NULL CONSTRAINT PK_OrderItems PRIMARY KEY,
    OrderID     INT           NOT NULL,
    ProductID   INT           NOT NULL,
    Quantity    INT           NOT NULL,
    UnitPrice   DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID)   REFERENCES dbo.Orders   (OrderID),
    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductID) REFERENCES dbo.Products (ProductID)
);
GO

/* -------------------------- SAMPLE DATA ---------------------------- */

-- 7 customers.
-- Names intentionally contain extra leading/trailing spaces to prove the
-- ETL "remove unnecessary spaces" step (Derived Column) works.
-- Customer 6 has NO orders; customer 7 has only a CANCELLED order.
INSERT INTO dbo.Customers (CustomerID, CustomerName, City) VALUES
(1, N'  Ahmed Hassan ', N'Cairo'),
(2, N'Sara Mohamed',    N'Alexandria'),
(3, N'Omar Khaled  ',   N'Giza'),
(4, N' Mona Adel',      N'Cairo'),
(5, N'Youssef Ali',     N'Mansoura'),
(6, N'Nour Ibrahim',    N'Alexandria'),
(7, N'Hana Samir  ',    N'Giza');

-- 6 products
INSERT INTO dbo.Products (ProductID, ProductName, Category, Price) VALUES
(1, N'Laptop',              N'Electronics', 15000.00),
(2, N'Wireless Mouse',      N'Accessories',   250.00),
(3, N'Mechanical Keyboard', N'Accessories',   900.00),
(4, N'Smartphone',          N'Electronics',  9000.00),
(5, N'Backpack',            N'Fashion',       600.00),
(6, N'Desk Lamp',           N'Home',          350.00);

-- 10 orders (8 Completed, 2 Cancelled)
INSERT INTO dbo.Orders (OrderID, CustomerID, OrderDate, OrderStatus) VALUES
(1,  1, '2026-01-05', N'Completed'),
(2,  2, '2026-01-12', N'Completed'),
(3,  3, '2026-02-03', N'Completed'),
(4,  1, '2026-02-14', N'Cancelled'),
(5,  4, '2026-02-20', N'Completed'),
(6,  5, '2026-03-02', N'Completed'),
(7,  2, '2026-03-15', N'Completed'),
(8,  7, '2026-03-18', N'Cancelled'),
(9,  3, '2026-04-01', N'Completed'),
(10, 5, '2026-04-10', N'Completed');

-- 18 order items (order 3's item 16 uses a discounted UnitPrice on purpose:
-- UnitPrice is the price actually charged, not necessarily Products.Price)
INSERT INTO dbo.OrderItems (OrderItemID, OrderID, ProductID, Quantity, UnitPrice) VALUES
(1,  1,  1, 1, 15000.00),
(2,  1,  2, 2,   250.00),
(3,  2,  4, 1,  9000.00),
(4,  2,  5, 1,   600.00),
(5,  3,  3, 1,   900.00),
(6,  3,  2, 1,   250.00),
(7,  4,  1, 1, 15000.00),   -- belongs to a CANCELLED order
(8,  5,  5, 2,   600.00),
(9,  5,  6, 1,   350.00),
(10, 6,  2, 3,   250.00),
(11, 6,  3, 1,   900.00),
(12, 7,  1, 1, 15000.00),
(13, 8,  4, 1,  9000.00),   -- belongs to a CANCELLED order
(14, 8,  2, 1,   250.00),   -- belongs to a CANCELLED order
(15, 9,  5, 1,   600.00),
(16, 9,  3, 2,   850.00),   -- discounted price
(17, 10, 4, 1,  9000.00),
(18, 10, 2, 2,   250.00);
GO

-- Quick sanity check
SELECT 'Customers'  AS TableName, COUNT(*) AS Rows FROM dbo.Customers  UNION ALL
SELECT 'Products',               COUNT(*)          FROM dbo.Products   UNION ALL
SELECT 'Orders',                 COUNT(*)          FROM dbo.Orders     UNION ALL
SELECT 'OrderItems',             COUNT(*)          FROM dbo.OrderItems;
GO
