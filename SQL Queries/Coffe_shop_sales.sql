CREATE DATABASE coffe_shop_sales_db;


-- DATA cleaning
USE coffe_shop_sales_db;

SELECT *
FROM coffee_shop_sales;

-- changing date and time columsn to the right formats

UPDATE coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date, '%d/%m/%Y');

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;

UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;

DESCRIBE coffee_shop_sales;

-- CHANGE COLUMN NAME `ï»¿transaction_id` to transaction_id

ALTER TABLE coffee_shop_sales
CHANGE COLUMN `ï»¿transaction_id` transaction_id INT;

-- CALCULATIONS

SELECT SUM(unit_price * transaction_qty) AS Total_Sales
FROM coffee_shop_sales
WHERE 
MONTH(transaction_date) = 5; -- May Month


-- Selected Month / CM - May = 5
-- PM - April = 4

-- TOTAL SALES KPI  MOM (month non month) DIFFERENCE AND MOM GROWTH

SELECT MONTH(transaction_date) AS month,  -- Number of the month
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales,  -- Total Sales Column
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1)  -- current month - previous month sales
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) -- partition function per month devided by previous month sales 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage  -- converted into %
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

-- Total Orders 
SELECT COUNT(transaction_id) AS Total_Orders
FROM coffee_shop_sales
WHERE
MONTH(transaction_date) = 3;


-- Total Orders KPI mom increase and decrese
SELECT MONTH(transaction_date) AS month,  -- Number of the month
	ROUND(COUNT(transaction_id)) AS Total_Orders,  -- Total Orders Column
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1)  -- current month - previous month sales
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1) -- partition function per month devided by previous month sales 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage  -- converted into %
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

-- Total quantity sold
SELECT SUM(transaction_qty) AS Total_Quantity_Sold
FROM coffee_shop_sales
WHERE 
MONTH(transaction_date) = 5; -- May Month

-- Total Quantity KPI mom increase and decrese

SELECT MONTH(transaction_date) AS month,  -- Number of the month
	ROUND(SUM(transaction_qty)) AS Total_Quantity_Sold,  -- Total_Quantity_Sold
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1)  -- current month - previous month sales
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) -- partition function per month devided by previous month sales 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage  -- converted into %
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

-- CALENDAR HEAT MAP preparation

SELECT
	CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS Total_Sales,
    CONCAT(ROUND(SUM(transaction_qty)/1000,1), 'K') AS Total_Qty_Sold,
    CONCAT(ROUND(COUNT(transaction_id)/1000, 1), 'K') AS Total_Orders
FROM coffee_shop_sales
WHERE 
	transaction_date = '2023-05-18';
    

-- Sales analysis for weekends (Sat, Sun) and weekdays (Mon- Fri), Sun = 1, Mon =2 etc.alter

SELECT
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
    ELSE 'Weekdays'
    END AS day_type,
    SUM(unit_price * transaction_qty) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 -- May month
GROUP BY 
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
    ELSE 'Weekdays'
    END ;


-- Lacation analysis

SELECT 
	store_location,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 -- May
GROUP BY store_location
ORDER BY Total_Sales DESC;

-- Sales Trend over a period of time

-- below query is wrong as it gives us average sales for a single transaction in May
-- SELECT AVG(unit_price * transaction_qty) as avg_sales
-- FROM coffee_shop_sales
-- WHERE MONTH(transaction_date) = 5;

-- below query is right as it gives us average DAILY sales in May 
SELECT 
	AVG(total_sales) AS Avg_Sales
FROM
	(
    SELECT SUM(unit_price * transaction_qty) AS total_sales
    FROM coffee_shop_sales
    WHERE MONTH (transaction_date) = 5
    GROUP BY transaction_date 
    ) AS Internal_query
    
    
    





