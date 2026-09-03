-- ============================================================
-- Fabric Warehouse: Supply Chain Star Schema
-- Source: supply_chain_lakehouse.dbo.clean_orders (Silver layer)
-- ============================================================

-- ------------------------------------------------------------
-- 1. Dimension tables
-- ------------------------------------------------------------

CREATE TABLE dim_customer (
    Customer_Id INT,
    Customer_City VARCHAR(100),
    Customer_State VARCHAR(100),
    Customer_Country VARCHAR(100),
    Latitude FLOAT,
    Longitude FLOAT,
    Market VARCHAR(50)
);

CREATE TABLE dim_product (
    Product_Card_Id INT,
    Product_Name VARCHAR(255),
    Product_Price FLOAT,
    Product_Status INT,
    Category_Id INT,
    Category_Name VARCHAR(100),
    Department_Id INT,
    Department_Name VARCHAR(100)
);

CREATE TABLE dim_geography (
    Order_Region VARCHAR(100),
    Order_Country VARCHAR(100),
    Order_State VARCHAR(100),
    Order_City VARCHAR(100)
);

CREATE TABLE dim_date (
    Date_Key DATE,
    Year INT,
    Quarter INT,
    Month INT,
    MonthName VARCHAR(20),
    Day INT,
    DayOfWeek VARCHAR(20)
);

-- ------------------------------------------------------------
-- 2. Populate dimension tables from the Lakehouse (cross-database query)
-- ------------------------------------------------------------

INSERT INTO dim_customer (Customer_Id, Customer_City, Customer_State, Customer_Country, Latitude, Longitude, Market)
SELECT DISTINCT Customer_Id, Customer_City, Customer_State, Customer_Country, Latitude, Longitude, Market
FROM supply_chain_lakehouse.dbo.clean_orders;

INSERT INTO dim_product (Product_Card_Id, Product_Name, Product_Price, Product_Status, Category_Id, Category_Name, Department_Id, Department_Name)
SELECT DISTINCT Product_Card_Id, Product_Name, Product_Price, Product_Status, Category_Id, Category_Name, Department_Id, Department_Name
FROM supply_chain_lakehouse.dbo.clean_orders;

INSERT INTO dim_geography (Order_Region, Order_Country, Order_State, Order_City)
SELECT DISTINCT Order_Region, Order_Country, Order_State, Order_City
FROM supply_chain_lakehouse.dbo.clean_orders;

INSERT INTO dim_date (Date_Key, Year, Quarter, Month, MonthName, Day, DayOfWeek)
SELECT DISTINCT
    CAST(order_date_DateOrders AS DATE) AS Date_Key,
    YEAR(order_date_DateOrders) AS Year,
    DATEPART(QUARTER, order_date_DateOrders) AS Quarter,
    MONTH(order_date_DateOrders) AS Month,
    DATENAME(MONTH, order_date_DateOrders) AS MonthName,
    DAY(order_date_DateOrders) AS Day,
    DATENAME(WEEKDAY, order_date_DateOrders) AS DayOfWeek
FROM supply_chain_lakehouse.dbo.clean_orders;

-- ------------------------------------------------------------
-- 3. Fact table
-- ------------------------------------------------------------

CREATE TABLE fct_orders (
    Order_Item_Id INT,
    Order_Id INT,
    Customer_Id INT,
    Product_Card_Id INT,
    Order_Region VARCHAR(100),
    Order_Country VARCHAR(100),
    Order_State VARCHAR(100),
    Order_City VARCHAR(100),
    Date_Key DATE,
    Days_for_shipping_real INT,
    Days_for_shipment_scheduled INT,
    Late_delivery_risk INT,
    Delivery_Status VARCHAR(50),
    Shipping_Mode VARCHAR(50),
    Order_Item_Quantity INT,
    Order_Item_Product_Price FLOAT,
    Order_Item_Discount FLOAT,
    Order_Item_Discount_Rate FLOAT,
    Sales FLOAT,
    Order_Item_Total FLOAT,
    Order_Profit_Per_Order FLOAT,
    Benefit_per_order FLOAT,
    Order_Item_Profit_Ratio FLOAT,
    Sales_per_customer FLOAT,
    Type VARCHAR(50),
    Order_Status VARCHAR(50)
);

INSERT INTO fct_orders
SELECT
    Order_Item_Id,
    Order_Id,
    Customer_Id,
    Product_Card_Id,
    Order_Region,
    Order_Country,
    Order_State,
    Order_City,
    CAST(order_date_DateOrders AS DATE) AS Date_Key,
    Days_for_shipping_real,
    Days_for_shipment_scheduled,
    Late_delivery_risk,
    Delivery_Status,
    Shipping_Mode,
    Order_Item_Quantity,
    Order_Item_Product_Price,
    Order_Item_Discount,
    Order_Item_Discount_Rate,
    Sales,
    Order_Item_Total,
    Order_Profit_Per_Order,
    Benefit_per_order,
    Order_Item_Profit_Ratio,
    Sales_per_customer,
    Type,
    Order_Status
FROM supply_chain_lakehouse.dbo.clean_orders;

-- ------------------------------------------------------------
-- 4. Validation query — confirms relationships resolve correctly
-- ------------------------------------------------------------

SELECT TOP 10
    f.Order_Id,
    c.Customer_City,
    p.Product_Name,
    d.MonthName,
    f.Sales,
    f.Order_Profit_Per_Order
FROM fct_orders f
JOIN dim_customer c ON f.Customer_Id = c.Customer_Id
JOIN dim_product p ON f.Product_Card_Id = p.Product_Card_Id
JOIN dim_date d ON f.Date_Key = d.Date_Key
ORDER BY f.Sales DESC;
