-- GROUPING SETS: Used to see multiple groupings in one query.
-- This is an efficient alternative to using UNION for custom data sets.

-- Query to see all records from 'customer' table
SELECT * FROM customer;

-- Query to see all records from 'payment' table
SELECT * FROM payment;

-- Example using GROUPING SETS:
-- This query calculates the total revenue by grouping first by customer name,
-- then by customer name and staff member.
SELECT first_name, last_name, p.staff_id, SUM(amount) AS revenue
FROM payment p
LEFT JOIN customer c ON p.customer_id = c.customer_id
GROUP BY 
    GROUPING SETS ((first_name, last_name), (first_name, last_name, staff_id));

-- Example using GROUPING SETS with Window Functions:
-- Here, we calculate total revenue, find the highest revenue, and calculate the revenue percentage 
-- relative to the highest revenue for each customer.
SELECT first_name, last_name, p.staff_id, SUM(amount) AS revenue, 
       FIRST_VALUE(SUM(amount)) OVER(PARTITION BY first_name, last_name ORDER BY SUM(amount) DESC) AS total_revenue,
       ROUND(((SUM(amount))/(FIRST_VALUE(SUM(amount)) OVER(PARTITION BY first_name, last_name ORDER BY SUM(amount) DESC)))*100, 2) AS percent_revenue
FROM payment p
LEFT JOIN customer c ON p.customer_id = c.customer_id
GROUP BY 
    GROUPING SETS ((first_name, last_name), (first_name, last_name, staff_id));

-- ROLLUP: A type of GROUPING SET that creates a hierarchy of groupings.
-- Example: Group by quarter, month, and day, and progressively aggregate to higher levels.

-- Query to calculate revenue by quarter, month, and day, showing grouped totals at each level.
SELECT 'Q' || TO_CHAR(payment_date, 'Q') as quarter, 
       TO_CHAR(payment_date, 'Month') as month, 
       TO_CHAR(payment_date, 'Day') as day_of_week, 
       SUM(amount) as revenue 
FROM payment
GROUP BY
    ROLLUP('Q' || TO_CHAR(payment_date, 'Q'), TO_CHAR(payment_date, 'Month'), TO_CHAR(payment_date, 'Day'))
ORDER BY 1, 2, 3;

-- Another example of ROLLUP: Group by quarter, month, and exact date
SELECT 'Q' || TO_CHAR(payment_date, 'Q') as quarter, 
       EXTRACT(month from payment_date) as month, 
       DATE(payment_date) as date, 
       SUM(amount) as revenue 
FROM payment
GROUP BY
    ROLLUP('Q' || TO_CHAR(payment_date, 'Q'), EXTRACT(month from payment_date), DATE(payment_date))
ORDER BY 1, 2, 3;

-- CUBE: A GROUPING SET that creates combinations of all the columns you select.
-- This is useful for generating all possible combinations of the data dimensions.

-- Example: Combining payment, rental, inventory, and film data with GROUPING SETS (CUBE)
SELECT p.customer_id, DATE(payment_date) AS date, title, SUM(amount) AS total_amount
FROM payment p
LEFT JOIN rental r ON r.customer_id = p.customer_id 
LEFT JOIN inventory i ON i.inventory_id = r.inventory_id 
LEFT JOIN film f ON f.film_id = i.film_id 
GROUP BY
    CUBE(p.customer_id, DATE(payment_date), title)
ORDER BY 1, 2, 3;