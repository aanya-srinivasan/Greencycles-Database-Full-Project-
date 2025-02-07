/* 
Greencycles - Movie Rental Database: 
This series of SQL queries demonstrates various advanced SQL techniques like using window functions, aggregation, and ranking 
to analyze data within the context of a movie rental system.
*/

/* 
1. OVER(PARTITION BY ________) 
   - The PARTITION BY clause allows us to break data into groups (partitions) and then perform calculations 
     on those groups without changing the level of detail of the results.
*/

/* Example 1: Calculate total amount spent by each customer */
SELECT payment_id, customer_id, staff_id, 
       SUM(amount) OVER(PARTITION BY customer_id) AS total_spent_by_customer 
FROM payment
-- This will display the payment_id, customer_id, staff_id, and the total amount spent by each customer, 
-- repeating the total amount for each row corresponding to that customer.

/* Example 2: Count number of transactions by each customer */
SELECT payment_id, customer_id, staff_id, 
       COUNT(amount) OVER(PARTITION BY customer_id) AS transaction_count 
FROM payment
-- This will show the total number of transactions per customer, repeated across all rows for that customer.

/* Example 3: Count number of transactions per unique combination of customer and staff */
SELECT *, COUNT(*) OVER(PARTITION BY customer_id, staff_id) AS transaction_count 
FROM payment
-- This counts the number of transactions for each unique customer-staff pair and displays it across all rows for that pair.

/* Example 4: Count the number of transactions per payment type */
SELECT transaction_id, payment_type, customer_id, cost, 
       COUNT(cost) OVER(PARTITION BY payment_type) AS transaction_count_by_type 
FROM sales
-- This will show how many transactions were made for each payment type. The count is calculated for each payment type, 
-- and the result is displayed across all rows for that type.

/* Example 5: Calculate the average cost across all transactions */
SELECT *, ROUND(AVG(cost) OVER(), 2) AS average_cost
FROM sales
-- This calculates the overall average cost of all transactions and displays it for each row, rounded to 2 decimal places.
-- The AVG() function is applied across all rows since no PARTITION BY is specified, so the average is the same for every row.
-- ROUND() is used to format the result to 2 decimal places.

/* 
2. OVER(ORDER BY ________) 
   - The ORDER BY clause is used to calculate running totals or perform calculations based on the order of the data. 
     This is especially useful for time-series data or financial reports.
*/

/* Example 1: Running total for each customer ordered by payment date */
SELECT *, 
       SUM(amount) OVER(PARTITION BY customer_id ORDER BY payment_date) AS running_total 
FROM payment
-- This will calculate the running total of the amount spent by each customer, ordered by payment_date.
-- The running total is computed by summing amounts for each customer, adding up the amounts as you move through the rows ordered by payment_date.

/* Example 2: Running total with tiebreaker using payment_id */
SELECT *, 
       SUM(amount) OVER(PARTITION BY customer_id ORDER BY payment_date, payment_id) AS running_total 
FROM payment
-- In case multiple transactions happened on the same day, this query orders the data by payment_id 
-- to ensure each transaction is correctly accounted for in the running total for each customer. */

/* Example 3: Running total for daily sales */
SELECT payment_date, total_amount,
       SUM(total_amount) OVER (ORDER BY payment_date) AS running_total
FROM (
    SELECT DATE(payment_date) AS payment_date, SUM(amount) AS total_amount
    FROM payment
    GROUP BY DATE(payment_date)
) AS daily_totals
ORDER BY payment_date;
-- This calculates a running total of daily sales. First, it aggregates the amount by payment_date, 
-- then it calculates the running total of the aggregated daily sales in chronological order.

-- 3. RANK() 
-- The RANK() function assigns a rank to each row within a partition of the result set, based on the ORDER BY condition. 
-- It is useful for ranking data, like top performers or best-selling movies.
-- NOTE: We use DENSE_RANK() instead of RANK() to ensure no gaps in ranking numbers (i.e., if two items have the same value, they will both have the same rank, and the next rank will be consecutive).

/* Example: Rank films within each category based on length */
SELECT f.title, length, name AS category, 
       DENSE_RANK() OVER(PARTITION BY name ORDER BY length DESC) AS rank 
FROM film f
LEFT JOIN film_category fc ON f.film_id = fc.film_id 
LEFT JOIN category c ON c.category_id = fc.category_id
-- This ranks films within each category based on their length, with the longest films receiving the highest rank.

-- Filtering ranks to show only the top-ranked films in each category:
SELECT * FROM
(SELECT f.title, length, name AS category, 
        DENSE_RANK() OVER(PARTITION BY name ORDER BY length DESC) AS rank 
 FROM film f
 LEFT JOIN film_category fc ON f.film_id = fc.film_id 
 LEFT JOIN category c ON c.category_id = fc.category_id) subquery
WHERE rank = 1;
-- This will show only the top-ranked (longest) films in each category by filtering for rank = 1.

-- Challenge: Find the top 3 ranked customers by number of payments in each country
SELECT * FROM
(SELECT name, country, 
        DENSE_RANK() OVER(PARTITION BY country ORDER BY ranked DESC) AS ranked
 FROM (SELECT name, country, COUNT(*) AS ranked
       FROM customer_list c
       LEFT JOIN payment p ON c.id = p.customer_id
       GROUP BY name, country) subquery) subquery2
WHERE ranked IN (1,2,3);
-- This query first ranks customers within each country by the number of payments they made, 
-- and then selects the top 3 customers from each country based on this ranking.

-- 4. FIRST_VALUE()
-- The FIRST_VALUE() function returns the first value in a partition, based on the order specified in the ORDER BY clause.

SELECT name, country, COUNT(*), 
       FIRST_VALUE(COUNT(*)) OVER(PARTITION BY country ORDER BY COUNT(*) DESC) AS ranked
FROM customer_list c
LEFT JOIN payment p ON c.id = p.customer_id
GROUP BY name, country
-- This shows the number of payments made by each customer and also displays the highest number of payments in the same country using the FIRST_VALUE() function.

-- 5. LEAD() and LAG()
-- LEAD() and LAG() allow you to access the value of a column from the next (LEAD) or previous (LAG) row in the result set.
-- These are useful for comparing values between rows.

SELECT 
    DATE(payment_date) AS payment_date,
    SUM(amount) AS total_amount,
    LAG(SUM(amount)) OVER(ORDER BY DATE(payment_date)) AS previous_day,
    SUM(amount) - LAG(SUM(amount)) OVER(ORDER BY DATE(payment_date)) AS difference,
    ROUND((SUM(amount) - LAG(SUM(amount)) OVER(ORDER BY DATE(payment_date))) / 
          LAG(SUM(amount)) OVER(ORDER BY DATE(payment_date)) * 100, 2) AS percent_growth
FROM payment
GROUP BY DATE(payment_date)
ORDER BY payment_date;
-- This query calculates the daily total payments, the previous day's total, the difference between the current and previous day, 
-- and the percentage growth in payments compared to the previous day.
-- The LAG() function is used to get the previous day's total to compare it with the current day’s total.
*/