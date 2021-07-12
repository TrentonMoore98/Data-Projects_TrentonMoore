-- Cleansed DIM_Date Table --
-- DIM_Calendar --
SELECT 
  DateKey, 
  Date, 
  Day, 
  Month, 
  LEFT(Month, 3) AS MonthShortened, 
  MonthNo, 
  EXTRACT(
    week 
    FROM 
      Date
  ) + 1 AS WeekNr, 
  Quarter, 
  Year 
FROM 
  `sales-report-dashboard-project.DIM.DIM_DATE` 
WHERE 
  Year < 2021;


-- Cleansed DIM_Customers Table --
-- DIM_Customer --
SELECT 
  customer.CustomerKey, 
  First_Name, 
  Last_Name, 
  CONCAT(First_Name, " ", Last_Name) AS Full_Name, 
  Gender, 
  DateFirstPurchase, 
  Customer_City, 
  Sales.SalesAmount -- Joined in Sales from the Internet Sales table
FROM 
  `sales-report-dashboard-project.DIM.DIM_CUSTOMERS` AS Customer 
  LEFT JOIN `sales-report-dashboard-project.FACT.FACT_InternetSales` AS Sales ON customer.customerkey = sales.customerkey 
WHERE 
  SalesAmount IS NOT NULL 
  AND DateFirstPurchase < '2021-01-01' 
ORDER BY 
  CustomerKey ASC; -- Ordered list by CustomerKey


-- Cleansed DIM_ProductsSold Table --
-- DIM_Product --

SELECT 
  p.ProductKey, 
  p.ProductItemCode, 
  p.Product_Name, 
  p.Sub_Category, 
  p.Product_Category, 
  p.Product_Color, 
  p.Product_Size, 
  p.Product_Line, 
  p.Product_Model_Name, 
  p.Product_Description, 
  p.Product_Status, 
FROM 
  `sales-report-dashboard-project.DIM.DIM_PRODUCTS` AS p 
ORDER BY 
  p.ProductKey ASC;


-- Cleansed FACT_InternetSales --
-- FACT_Sales --

SELECT 
  ProductKey AS Product_Key,
  OrderDateKey,
  DueDateKey,
  ShipDateKey,
  CustomerKey,
  SalesOrderNumber,
  SalesAmount
FROM `sales-report-dashboard-project.FACT.FACT_InternetSales`;




-- Calculating Most Valuable Customers --
SELECT 
  customer.full_name, 
  sum(sales.SalesAmount) as TotalSpent, 
FROM 
  `sales-report-dashboard-project.DIM.DIM_CUSTOMERS` AS Customer 
  LEFT JOIN `sales-report-dashboard-project.FACT.FACT_InternetSales` AS Sales ON customer.customerkey = sales.customerkey 
WHERE 
  DateFirstPurchase < '2021-01-01' 
GROUP BY 
  Customer.Full_Name 
ORDER BY 
  TotalSpent desc;


