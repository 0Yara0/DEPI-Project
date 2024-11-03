--What is the repeat purchase rate by customer segment?--
WITH CustomerOrders AS (
    SELECT [Customer_ID], [Segment], COUNT(DISTINCT [Order_ID]) AS Total_Orders
    FROM sales_cleaned
    GROUP BY [Customer_ID], [Segment]
),
RepeatCustomers AS (
    SELECT Segment, COUNT([Customer_ID]) AS Repeat_Customers
    FROM CustomerOrders
    WHERE Total_Orders > 1
    GROUP BY Segment
),
TotalCustomers AS (
    SELECT Segment, COUNT([Customer_ID]) AS Total_Customers
    FROM CustomerOrders
    GROUP BY Segment
)
SELECT 
    tc.Segment, 
    rc.Repeat_Customers, 
    tc.Total_Customers, 
    (CAST(rc.Repeat_Customers AS FLOAT) / tc.Total_Customers) * 100 AS Repeat_Purchase_Rate_Percentage
FROM TotalCustomers tc
LEFT JOIN RepeatCustomers rc
ON tc.Segment = rc.Segment;

--Which states or cities have the highest sales growth?--

SELECT State, City, YEAR([Order_Date]) AS Years, SUM(Sales) AS Total_Sales
FROM sales_cleaned
GROUP BY State, City, YEAR([Order_Date])
ORDER BY Years, Total_Sales DESC;

--Which regions generate the most sales?--

SELECT Region, SUM(Sales) AS Total_Sales
FROM sales_cleaned
GROUP BY Region
ORDER BY Total_Sales DESC;

--What is the profitability of different product categories?--

SELECT Category, SUM(Sales) AS Total_Sales
FROM sales_cleaned
GROUP BY Category
ORDER BY Total_Sales DESC;

--How do sales differ across cities and states?--

SELECT State, City, SUM(Sales) AS Total_Sales
FROM sales_cleaned
GROUP BY State, City
ORDER BY Total_Sales DESC;

--What are the key products sold in each region?--
SELECT Region, Product_Name, SUM(Sales) AS Total_Sales
FROM sales_cleaned
GROUP BY Region, Product_Name
ORDER BY Region, Total_Sales DESC;

--Which product categories have the highest sales growth?--
WITH SalesByCategory AS (
    SELECT Category, YEAR([Order_Date]) AS Year, SUM(Sales) AS Total_Sales
    FROM sales_cleaned
    GROUP BY Category, YEAR([Order_Date])
),
SalesGrowth AS (
    SELECT Category, Year, Total_Sales, LAG(Total_Sales) OVER (PARTITION BY Category ORDER BY Year) AS Previous_Year_Sales
    FROM SalesByCategory
)
SELECT Category, Year, Total_Sales, Previous_Year_Sales,
    CASE 
        WHEN Previous_Year_Sales IS NULL THEN 0
        ELSE ((Total_Sales - Previous_Year_Sales) / Previous_Year_Sales) * 100 
    END AS Sales_Growth_Percentage
FROM SalesGrowth
ORDER BY Sales_Growth_Percentage DESC;


--What is the overall sales trend over time?--
	SELECT 
		YEAR([Order_Date]) AS Year, 
		MONTH([Order_Date]) AS Month, 
		SUM(Sales) AS Total_Sales
	FROM sales_cleaned
	GROUP BY YEAR([Order_Date]), MONTH([Order_Date])
	ORDER BY Year, Month


--Which product categories and subcategories generate the most revenue?--
	select sum (sales) as 'Total Sales', Sub_Category, category
		from sales_cleaned
		group by Sub_Category, category
		order by 'Total Sales' desc

--What is the average order value per customer--
	select avg (sales) 'Average order value', customer_ID
	from sales_cleaned
	group by customer_ID
	order by customer_id

--What percentage of total revenue comes from each segment--
	SELECT Segment, SUM(Sales) AS Segment_Revenue 
	FROM sales_cleaned
	GROUP BY Segment

--Which products have the highest sales volume and revenue--
SELECT TOP 1 sales, product_name
FROM sales_cleaned

--Are there any trends between shipping delays and specific regions or customer segments?--
SELECT region, segment, AVG(DATEDIFF(day, "Order_Date", "Ship_Date")) AS average_delivery_time
FROM sales_cleaned
GROUP BY region, segment
ORDER BY average_delivery_time DESC;


--What is the correlation between shipping mode and customer satisfaction (using repeat orders)?--
SELECT Ship_Mode, COUNT(DISTINCT Customer_ID) AS Unique_Customers, COUNT(Order_ID) AS Repeat_Orders
FROM sales_cleaned
GROUP BY Ship_Mode
ORDER BY Repeat_Orders DESC;

--What are the peak sales periods (days, months, or seasons)?--
SELECT MONTH([Order_Date]) AS Sales_Month, SUM(Sales) AS Total_Sales
FROM sales_cleaned
WHERE sales IS NOT NULL  
GROUP BY MONTH([Order_Date])
ORDER BY Total_Sales desc;

--Who are the top 10 customers in terms of total sales and order frequency?--
select top 10 Customer_ID , sum(Sales) as total_sales, count(Order_ID) as order_frequency
from sales_cleaned
GROUP BY  Customer_ID
order by total_sales desc, order_frequency desc


--Which customer segments (Consumer, Corporate, Home Office) contribute most to sales?--
select Segment, sum(Sales) AS total_sales, COUNT(*) AS order_count
from sales_cleaned
group by Segment
order by total_sales desc

--What are the average sales per order for different customer segments?--
select Segment, sum(Sales) AS total_sales, COUNT(Order_ID) as #of_orders, 
sum(Sales)/COUNT(Order_ID) AS AVG_sales_per_order
from sales_cleaned
group by Segment


