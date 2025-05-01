# Function 1 - Revenue_top_20 
# Used to call out revenue contribution by top 20 customers (and use it in SELECT statements)
DELIMITER $$

CREATE FUNCTION Revenue_top_n_customers(n INT,year_input INT)
RETURNS DECIMAL(15,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(15,2);

SELECT ROUND(SUM(revenue)/(SELECT SUM(revenue) 
                           FROM order_items as oi
						   INNER JOIN orders as o
                           ON oi.order_id=o.order_Id
                           WHERE YEAR(order_date)=year_input)*100,2) 
INTO total
FROM
(SELECT ROUND(SUM(revenue), 2) AS revenue
FROM customers AS c
LEFT JOIN orders AS o 
ON c.customer_id = o.customer_id
LEFT JOIN order_items AS oi 
ON o.order_id = oi.order_id
WHERE year(order_date)=year_input
GROUP BY c.customer_id
ORDER BY revenue DESC
LIMIT n)SQ;
RETURN total;
END$$

DELIMITER ;
-- ------------------------------------------

# Function 2 - Revenue_by_year
# Used to call out total revenue by year(and use it in SELECT statements)
DELIMITER $$

CREATE FUNCTION Revenue_by_year(year_input INT) 
RETURNS decimal(15,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(15,2);

SELECT SUM(revenue)
INTO Total
FROM order_items AS oi
INNER JOIN orders AS o
ON oi.order_id=o.order_id
WHERE YEAR(order_date)=year_input;
RETURN total;
END$$

DELIMITER ;

-- ------------------------------------------

# Function 3 - Revenue_by_n_products
# Used to call out total revenue contribution by n number of products)
DELIMITER $$

CREATE FUNCTION Revenue_by_n_products(n INT,year_input INT) 
RETURNS decimal(15,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(15,2);

WITH C1 AS(                                    
SELECT product_name,
	   SUM(revenue) AS total_revenue
	FROM products AS p
	INNER JOIN order_items AS oi
	ON p.product_id=oi.product_id
	INNER JOIN orders AS o
	ON o.order_id=oi.order_id
	WHERE YEAR(order_date)=year_input
	GROUP BY p.product_id, product_name
    ORDER BY total_revenue DESC
	LIMIT n)
SELECT ROUND(SUM(total_revenue))
INTO total
FROM C1;
RETURN total;
END$$

DELIMITER ;

-- ------------------------------------------
SELECT product_name,
	   SUM(revenue) AS total_revenue
	FROM products AS p
	INNER JOIN order_items AS oi
	ON p.product_id=oi.product_id
	INNER JOIN orders AS o
	ON o.order_id=oi.order_id
	WHERE YEAR(order_date)=2018
	GROUP BY p.product_id, product_name
    ORDER BY total_revenue DESC
	LIMIT 10;
    
SELECT SUM(revenue)
FROM orders AS o
INNER JOIN order_items AS oi
ON o.order_id=oi.order_id
WHERE YEAR(order_date)=2018

					