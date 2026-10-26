/* =====================================================================
   03_MiniStoreDW_Create.sql
   Step 3 - Create the Data Warehouse (Star Schema)
   FactSales grain: ONE ROW = ONE ORDER LINE (one OrderItem).
   ===================================================================== */

USE master;
GO

IF DB_ID(N'MiniStoreDW') IS NOT NULL
BEGIN
    ALTER DATABASE MiniStoreDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE MiniStoreDW;
END
GO

CREATE DATABASE MiniStoreDW;
GO

USE MiniStoreDW;
GO

/* ------------------------- DIMENSIONS ------------------------------ */

CREATE TABLE dbo.DimCustomer
(
    CustomerKey  INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DimCustomer PRIMARY KEY,
    CustomerID   INT           NOT NULL,          -- business key from source
    CustomerName NVARCHAR(100) NOT NULL,
    City         NVARCHAR(50)  NULL,
    CONSTRAINT UQ_DimCustomer_CustomerID UNIQUE (CustomerID)
);

CREATE TABLE dbo.DimProduct
(
    ProductKey  INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DimProduct PRIMARY KEY,
    ProductID   INT           NOT NULL,           -- business key from source
    ProductName NVARCHAR(100) NOT NULL,
    Category    NVARCHAR(50)  NULL,
    CONSTRAINT UQ_DimProduct_ProductID UNIQUE (ProductID)
);

CREATE TABLE dbo.DimDate
(
    DateKey   INT          NOT NULL CONSTRAINT PK_DimDate PRIMARY KEY,  -- YYYYMMDD
    FullDate  DATE         NOT NULL,
    [Year]    INT          NOT NULL,
    [Month]   INT          NOT NULL,
    MonthName NVARCHAR(20) NOT NULL,
    CONSTRAINT UQ_DimDate_FullDate UNIQUE (FullDate)
);

/* --------------------------- FACT TABLE ---------------------------- */

CREATE TABLE dbo.FactSales
(
    SalesKey    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_FactSales PRIMARY KEY,
    OrderItemID INT            NOT NULL,          -- source order-line id
    OrderID     INT            NOT NULL,
    DateKey     INT            NOT NULL,
    CustomerKey INT            NOT NULL,
    ProductKey  INT            NOT NULL,
    Quantity    INT            NOT NULL,
    UnitPrice   DECIMAL(10,2)  NOT NULL,
    SalesAmount DECIMAL(12,2)  NOT NULL,
    CONSTRAINT UQ_FactSales_OrderItemID UNIQUE (OrderItemID),
    CONSTRAINT FK_FactSales_DimDate     FOREIGN KEY (DateKey)     REFERENCES dbo.DimDate     (DateKey),
    CONSTRAINT FK_FactSales_DimCustomer FOREIGN KEY (CustomerKey) REFERENCES dbo.DimCustomer (CustomerKey),
    CONSTRAINT FK_FactSales_DimProduct  FOREIGN KEY (ProductKey)  REFERENCES dbo.DimProduct  (ProductKey)
);
GO

-- Helpful indexes on the foreign keys (typical for star schemas)
CREATE INDEX IX_FactSales_DateKey     ON dbo.FactSales (DateKey);
CREATE INDEX IX_FactSales_CustomerKey ON dbo.FactSales (CustomerKey);
CREATE INDEX IX_FactSales_ProductKey  ON dbo.FactSales (ProductKey);
GO
