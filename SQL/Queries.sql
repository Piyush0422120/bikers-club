USE Bikers_club;
-- ---------------

# Query 1
# Total Revenue, Total orders, AOV

SELECT 'Total_revenue' AS insight,
       ROUND(SUM(revenue),2) AS total_Revenue
FROM order_items
UNION
SELECT 'Total_orders',
        COUNT(DISTINCT order_id) AS total_orders
FROM order_items
UNION
SELECT 'AOV',
        ROUND(SUM(revenue)/COUNT(DISTINCT order_id),2) AS AOV
FROM order_items;

-- --------------------------------------------------

# Query 2
# Biggest orders

SELECT o.order_id,
       c.customer_id,
       CONCAT(first_name,' ',last_name) AS customer_name,
       ROUND(SUM(revenue),2) AS total_order_value
FROM orders AS o
INNER JOIN order_items AS oi
ON o.order_id=oi.order_id
INNER JOIN customers AS c
ON o.customer_id=c.customer_id
GROUP BY o.order_id
ORDER BY total_order_value DESC
LIMIT 10;

-- --------------------------------------------------

# Query 3
# Yearly Trend Analysis (revenue, orders, AOV)

WITH C1 AS
			(SELECT YEAR(order_date) AS years,
                    ROUND(SUM(revenue),2) AS total_revenue,
                    COUNT(DISTINCT o.order_id) AS total_orders,
                    ROUND(SUM(revenue)/COUNT(DISTINCT o.order_id),2) AS AOV
			        FROM orders AS o
			        INNER JOIN  order_items AS oi
			        ON o.order_id=oi.order_id
                    GROUP BY years),
	 C2 AS
			(SELECT years,
					total_revenue,
                    total_orders,
                    AOV,
					LAG(total_revenue) OVER(ORDER BY years) AS previous_year_revenue,
                    LAG(total_orders)  OVER(ORDER BY years) AS previous_year_orders,
                    LAG(AOV) OVER(ORDER BY years) AS previous_year_AOV
					FROM C1)
SELECT years,
       total_revenue,
       COALESCE(ROUND((total_revenue-previous_year_revenue)/previous_year_revenue*100,2),0) AS 'change%',
       total_orders,
	   COALESCE(ROUND((total_orders-previous_year_orders)/previous_year_orders*100,2),0) AS 'change_in_orders%',
       AOV,
       COALESCE(ROUND((AOV-previous_year_AOV)/previous_year_AOV*100,2),0) AS 'change_in_AOV%'
FROM C2;

-- --------------------------------------------------

# Query 4
# Monthly Trend Analysis (Revenue, orders, AOV)

WITH C1 AS
			(SELECT YEAR(order_date) AS years,
					MONTH(order_date) AS months,
                    ROUND(SUM(revenue),2) AS total_revenue,
                    COUNT(DISTINCT o.order_id) AS total_orders,
                    ROUND(SUM(revenue)/COUNT(DISTINCT o.order_id),2) AS AOV
			        FROM orders AS o
			        INNER JOIN  order_items AS oi
			        ON o.order_id=oi.order_id
                    GROUP BY years,months),
	 C2 AS
			(SELECT years,
                    months,
					total_revenue,
                    total_orders,
                    AOV,
					LAG(total_revenue) OVER(ORDER BY years,months) AS previous_revenue,
                    LAG(total_orders)  OVER(ORDER BY years,months) AS previous_orders,
                    LAG(AOV) OVER(ORDER BY years,months) AS previous_AOV
					FROM C1)
SELECT years,
       months,
       total_revenue,
       COALESCE(ROUND((total_revenue-previous_revenue)/previous_revenue*100,2),0) AS 'change%',
       total_orders,
	   COALESCE(ROUND((total_orders-previous_orders)/previous_orders*100,2),0) AS 'change_in_orders%',
       AOV,
       COALESCE(ROUND((AOV-previous_AOV)/previous_AOV*100,2),0) AS 'change_in_AOV%'
FROM C2;

-- --------------------------------------------------

# Query 5
# Top 10 products (According to total revenue)

SELECT product_name,
       ROUND(SUM(revenue),2) AS total_revenue
FROM products AS p
JOIN order_items AS o
ON p.product_id=o.product_id
GROUP BY product_name
ORDER BY total_revenue DESC
LIMIT 10;

-- --------------------------------------------------
# Query 6
# Top n products in overall revenue mix by years
# 2 functions are used here- Revenue_by_n_products & Revenue_by_year

SELECT 'Top 1' AS contribution_of,
        ROUND(Revenue_by_n_products(1,2016)/Revenue_by_year(2016)*100,2) AS '2016',
        ROUND(Revenue_by_n_products(1,2017)/Revenue_by_year(2017)*100,2) AS '2017',
        ROUND(Revenue_by_n_products(1,2018)/Revenue_by_year(2018)*100,2) AS '2018'
UNION
SELECT 'Top 3' ,
        ROUND(Revenue_by_n_products(3,2016)/Revenue_by_year(2016)*100,2),
        ROUND(Revenue_by_n_products(3,2017)/Revenue_by_year(2017)*100,2),
        ROUND(Revenue_by_n_products(3,2018)/Revenue_by_year(2018)*100,2)
UNION
SELECT 'Top 5' ,
        ROUND(Revenue_by_n_products(5,2016)/Revenue_by_year(2016)*100,2),
        ROUND(Revenue_by_n_products(5,2017)/Revenue_by_year(2017)*100,2),
        ROUND(Revenue_by_n_products(5,2018)/Revenue_by_year(2018)*100,2)
UNION
SELECT 'Top 10' ,
        ROUND(Revenue_by_n_products(10,2016)/Revenue_by_year(2016)*100,2),
        ROUND(Revenue_by_n_products(10,2017)/Revenue_by_year(2017)*100,2),
        ROUND(Revenue_by_n_products(10,2018)/Revenue_by_year(2018)*100,2)
UNION
SELECT 'Top 20' ,
        ROUND(Revenue_by_n_products(20,2016)/Revenue_by_year(2016)*100,2),
        ROUND(Revenue_by_n_products(20,2017)/Revenue_by_year(2017)*100,2),
        ROUND(Revenue_by_n_products(20,2018)/Revenue_by_year(2018)*100,2);
        
-- --------------------------------------------------

# Query 7
# Biggest brands according to total revenue (with Total orders, AOV)
# Note: total brand orders will be more then total number of order ids (as one order can consit of numerous brands) 

SELECT brand_name,
       ROUND(SUM(revenue),2) AS total_revenue,
	   COUNT(DISTINCT order_id) AS total_brand_orders,
       ROUND(SUM(revenue)/COUNT(DISTINCT order_id),2) AS AOV
FROM order_items AS o
INNER JOIN products AS p
ON o.product_id=p.product_id
INNER JOIN brands AS b
ON p.brand_id=b.brand_id
GROUP BY brand_name
ORDER BY total_revenue DESC;

-- --------------------------------------------------

# Query 8
# Revenue growth of brands by years

WITH C1 AS(
			SELECT  brand_name,
					ROUND(SUM(CASE WHEN YEAR(order_date)=2016 THEN revenue ELSE 0 END),2) AS revenue_2016,
					ROUND(SUM(CASE WHEN YEAR(order_date)=2017 THEN revenue ELSE 0 END),2) AS revenue_2017,
					ROUND(SUM(CASE WHEN YEAR(order_date)=2018 THEN revenue ELSE 0 END),2) AS revenue_2018
			FROM brands AS b
			INNER JOIN products AS p
			ON b.brand_id=p.brand_id
			INNER JOIN order_items AS oi
			on p.product_id=oi.product_id
			INNER JOIN orders AS o
			ON oi.order_id=o.order_id
			GROUP BY brand_name)
SELECT brand_name,
       revenue_2016,
       revenue_2017,
	   ROUND((revenue_2017-revenue_2016)/revenue_2016*100,2) AS "growth%(16-17)",
       revenue_2018,
       ROUND((revenue_2018-revenue_2016)/revenue_2016*100,2) AS "growth%(16-18)",
       ROUND((revenue_2018-revenue_2017)/revenue_2017*100,2) AS "growth%(17-18)"
FROM C1
ORDER BY revenue_2018 DESC;

-- --------------------------------------------------

# Query 9
# Changing Revenue Contribution of Brands Over the Years
# Revenue_by_year function is used here

WITH C1 AS(
			SELECT  brand_name,
					ROUND(SUM(CASE WHEN YEAR(order_date)=2016 THEN revenue ELSE 0 END),2) AS revenue_2016,
					ROUND(SUM(CASE WHEN YEAR(order_date)=2017 THEN revenue ELSE 0 END),2) AS revenue_2017,
					ROUND(SUM(CASE WHEN YEAR(order_date)=2018 THEN revenue ELSE 0 END),2) AS revenue_2018
			FROM brands AS b
			INNER JOIN products AS p
			ON b.brand_id=p.brand_id
			INNER JOIN order_items AS oi
			on p.product_id=oi.product_id
			INNER JOIN orders AS o
			ON oi.order_id=o.order_id
			GROUP BY brand_name)
SELECT brand_name,
	   ROUND(revenue_2016/Revenue_by_year(2016)*100,2) AS Revenue_Mix_2016,
	   ROUND(revenue_2017/Revenue_by_year(2017)*100,2) AS Revenue_Mix_2017,
       ROUND(revenue_2018/Revenue_by_year(2018)*100,2) AS Revenue_Mix_2018
FROM C1
ORDER BY revenue_2018 DESC;

-- --------------------------------------------------

# Query 10
# Top 20 customers

SELECT c.customer_id,
	   c.first_name,
       c.last_name,
	   COALESCE(ROUND(SUM(revenue),2),0) AS total_revenue_generated,
       COALESCE(COUNT(DISTINCT o.order_id),0) AS total_orders,
       COALESCE(ROUND(SUM(revenue)/COUNT(DISTINCT o.order_id),2),0) AS AOV
FROM customers AS c
LEFT JOIN orders AS o
ON c.customer_id=o.customer_id
LEFT JOIN order_items AS oi
ON o.order_id=oi.order_id
GROUP BY c.customer_id,
	     c.first_name,
         c.last_name
ORDER BY total_revenue_generated DESC
LIMIT 20;

-- --------------------------------------------------

# Query 11
# Top n customer%
# A function is created to simplify the process (called Revenue_top_n_customers) - its code is in functions sheet

SELECT 'Top 1' AS contribution_of,
        ROUND(Revenue_top_n_customers(1,2016),2) AS '2016',
        ROUND(Revenue_top_n_customers(1,2017),2) AS '2017',
        ROUND(Revenue_top_n_customers(1,2018),2) AS '2018'
UNION
SELECT 'Top 5' ,
		ROUND(Revenue_top_n_customers(5,2016),2), 
        ROUND(Revenue_top_n_customers(5,2017),2),
        ROUND(Revenue_top_n_customers(5,2018),2)
UNION
SELECT 'Top 10' ,
		ROUND(Revenue_top_n_customers(10,2016),2), 
        ROUND(Revenue_top_n_customers(10,2017),2),
        ROUND(Revenue_top_n_customers(10,2018),2)
UNION
SELECT 'Top 20' ,
		ROUND(Revenue_top_n_customers(20,2016),2), 
        ROUND(Revenue_top_n_customers(20,2017),2),
        ROUND(Revenue_top_n_customers(20,2018),2)
UNION
SELECT 'Top 50' ,
		ROUND(Revenue_top_n_customers(50,2016),2), 
        ROUND(Revenue_top_n_customers(50,2017),2),
        ROUND(Revenue_top_n_customers(50,2018),2);
        
-- --------------------------------------------------

# Query 12
# Biggest stores according to revenue (with total orders & AOV)

SELECT store_name,
       ROUND(SUM(revenue),2) AS total_revenue,
	   COUNT(DISTINCT o.order_id) AS total_brand_orders,
       ROUND(SUM(revenue)/COUNT(DISTINCT o.order_id),2) AS AOV
FROM stores AS s
INNER JOIN orders AS o
ON s.store_id=o.store_id
INNER JOIN order_items AS oi
ON o.order_id=oi.order_id
GROUP BY store_name
ORDER BY total_revenue DESC;

-- --------------------------------------------------

# Query 13
# Yearly revenue growth at stores

WITH C1 AS(
			SELECT store_name,
				   ROUND(SUM(CASE WHEN YEAR(order_date)=2016 THEN revenue ELSE 0 END),2) AS revenue_2016,
				   ROUND(SUM(CASE WHEN YEAR(order_date)=2017 THEN revenue ELSE 0 END),2) AS revenue_2017,
                   ROUND(SUM(CASE WHEN YEAR(order_date)=2018 THEN revenue ELSE 0 END),2) AS revenue_2018
			FROM stores AS s
			INNER JOIN orders AS o
            ON s.store_id=o.store_id
            INNER JOIN order_items AS oi
            ON oi.order_id=o.order_id
            GROUP BY store_name)
SELECT store_name,
	   revenue_2016,
	   revenue_2017,
       ROUND((revenue_2017-revenue_2016)/revenue_2016*100,2) AS "growth%(16-17)",
       revenue_2018,
       ROUND((revenue_2018-revenue_2016)/revenue_2016*100,2) AS "growth%(16-18)",
       ROUND((revenue_2018-revenue_2017)/revenue_2017*100,2) AS "growth%(17-18)"
FROM C1
ORDER BY revenue_2018 DESC;

-- --------------------------------------------------

# Query 14
# Revenue contribution by stores each year (2016-18)
# Revenue by year function is used

WITH C1 AS(
			SELECT store_name,
				   ROUND(SUM(CASE WHEN YEAR(order_date)=2016 THEN revenue ELSE 0 END),2) AS revenue_2016,
				   ROUND(SUM(CASE WHEN YEAR(order_date)=2017 THEN revenue ELSE 0 END),2) AS revenue_2017,
                   ROUND(SUM(CASE WHEN YEAR(order_date)=2018 THEN revenue ELSE 0 END),2) AS revenue_2018
			FROM stores AS s
			INNER JOIN orders AS o
            ON s.store_id=o.store_id
            INNER JOIN order_items AS oi
            ON oi.order_id=o.order_id
            GROUP BY store_name)
SELECT store_name,
	   ROUND(revenue_2016/Revenue_by_year(2016)*100,2) AS Revenue_Mix_2016,
	   ROUND(revenue_2017/Revenue_by_year(2017)*100,2) AS Revenue_Mix_2017,
       ROUND(revenue_2018/Revenue_by_year(2018)*100,2) AS Revenue_Mix_2018
FROM C1
ORDER BY revenue_2018 DESC;

-- --------------------------------------------------

# Query 15
# Best categories according to revenue (with orders and AOV)
# Note: total category orders will be more then total number of order ids (as one order can consit of numerous categories) 

SELECT category_name,
	   ROUND(SUM(revenue),2) AS total_revenue,
	   COUNT(DISTINCT order_id) AS total_category_orders,
       ROUND(SUM(revenue)/COUNT(DISTINCT order_id),2) AS AOV
FROM categories AS c
INNER JOIN products AS p
ON c.category_id=p.category_id
INNER JOIN order_items AS oi
on p.product_id=oi.product_id
GROUP BY category_name
ORDER BY total_revenue DESC;

-- --------------------------------------------------

# Query 16
# Yearly revenue growth according to categories

WITH C1 AS(
			SELECT category_name,
					ROUND(SUM(CASE WHEN YEAR(order_date)=2016 THEN revenue ELSE 0 END),2) AS revenue_2016,
					ROUND(SUM(CASE WHEN YEAR(order_date)=2017 THEN revenue ELSE 0 END),2) AS revenue_2017,
					ROUND(SUM(CASE WHEN YEAR(order_date)=2018 THEN revenue ELSE 0 END),2) AS revenue_2018
			FROM categories AS c
			INNER JOIN products AS p
			ON c.category_id=p.category_id
			INNER JOIN order_items AS oi
			on p.product_id=oi.product_id
			INNER JOIN orders AS o
			ON oi.order_id=o.order_id
			GROUP BY category_name)
SELECT category_name,
       revenue_2016,
       revenue_2017,
	   ROUND((revenue_2017-revenue_2016)/revenue_2016*100,2) AS "growth%(16-17)",
       revenue_2018,
       ROUND((revenue_2018-revenue_2016)/revenue_2016*100,2) AS "growth%(16-18)",
       ROUND((revenue_2018-revenue_2017)/revenue_2017*100,2) AS "growth%(17-18)"
FROM C1;

-- --------------------------------------------------

# Query 17
# Revenue contribution by categories for each year (2016-18)
# Revenue_by_year function is used

WITH C1 AS(
			SELECT category_name,
					ROUND(SUM(CASE WHEN YEAR(order_date)=2016 THEN revenue ELSE 0 END),2) AS revenue_2016,
					ROUND(SUM(CASE WHEN YEAR(order_date)=2017 THEN revenue ELSE 0 END),2) AS revenue_2017,
					ROUND(SUM(CASE WHEN YEAR(order_date)=2018 THEN revenue ELSE 0 END),2) AS revenue_2018
			FROM categories AS c
			INNER JOIN products AS p
			ON c.category_id=p.category_id
			INNER JOIN order_items AS oi
			on p.product_id=oi.product_id
			INNER JOIN orders AS o
			ON oi.order_id=o.order_id
			GROUP BY category_name)
SELECT category_name,
	   ROUND(revenue_2016/Revenue_by_year(2016)*100,2) AS Revenue_Mix_2016,
	   ROUND(revenue_2017/Revenue_by_year(2017)*100,2) AS Revenue_Mix_2017,
       ROUND(revenue_2018/Revenue_by_year(2018)*100,2) AS Revenue_Mix_2018
FROM C1
ORDER BY revenue_2018 DESC;

-- --------------------------------------------------

# Query 18
# Best performers (revenue- generated by staff)

SELECT s.staff_id,
	   s.first_name,
       s.last_name,
	   COALESCE(ROUND(SUM(revenue),2),0) AS total_revenue_generated,
       COALESCE(COUNT(DISTINCT o.order_id),0) AS total_orders,
       COALESCE(ROUND(SUM(revenue)/COUNT(DISTINCT o.order_id),2),0) AS AOV
FROM staffs AS s
LEFT JOIN orders AS o
ON s.staff_id=o.staff_id
LEFT JOIN order_items AS oi
ON o.order_id=oi.order_id
GROUP BY s.staff_id,
	     s.first_name,
         s.last_name
ORDER BY total_revenue_generated DESC;
-- --------------------------------------------------



