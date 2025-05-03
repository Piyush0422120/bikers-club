# Bikers club
**Objective:**   Sales Analysis at bikers club     
**Tools:**   SQL(MYSQL) , Python (Pandas, Matplotlib)  


Total number of Queries: 18  <br><br>
![image](https://github.com/user-attachments/assets/f82c6732-ffb8-4327-89f2-0f5e218ded39)


-    [Jump to Pandas Section](#pandas)
-    [Jump to SQL Snapshots](#SQL)


---
## PANDAS


1) The project features 18 data queries implemented using Pandas. (refered to as insights in jupyter notebook)
2) Data visualization is handled using Matplotlib and Pandas’ built-in plotting capabilities.

You can check out the jupyter notebook at:    
https://github.com/Piyush0422120/bikers-club/blob/main/Pandas/Bikers_club_Analytics.ipynb
  
  
---

## SQL
#1 Total Revenue, Total orders, AOV <BR>

```

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

```
![image](https://github.com/user-attachments/assets/d5b2ab91-cda5-4751-a7bf-e205dec25171)

<BR>

#2 Yearly Trend Analysis (revenue, orders, AOV) <BR>

```
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

```
![image](https://github.com/user-attachments/assets/9a4fb553-31d4-4fd9-87b3-111c44645330)


<BR>

#3 Top n products in overall revenue mix by years <BR>

```
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
```
![image](https://github.com/user-attachments/assets/6fd9656d-911f-45a0-8076-2ebd94894414)


<BR>

#4 Yearly revenue growth at stores <BR>

```
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

```
![image](https://github.com/user-attachments/assets/e5bce4b2-5838-4cf7-885f-1d0edfa2afa8)


<BR>

#5 Revenue contribution by categories for each year (2016-18)  <BR>

```

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

```
![image](https://github.com/user-attachments/assets/7d6ce1f6-dc62-4097-ae8d-017899fc9234)

<BR>

You can check out the SQL code (queries) at: https://github.com/Piyush0422120/bikers-club/blob/main/SQL/Queries.sql

