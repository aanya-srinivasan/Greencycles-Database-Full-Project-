-- CREATE TABLE AS, when you need to create a table based on an already existing table --
-- Example: Create a table with customer information along with their address and city --

SELECT first_name, last_name, email, address, city FROM customer c
LEFT JOIN address a
ON c.address_id = a.address_id
LEFT JOIN city ci 
ON ci.city_id = a.city_id

-- Create a new table 'customer_address' with the query results --
CREATE TABLE customer_address 
AS 
SELECT first_name, last_name, email, address, city FROM customer c
LEFT JOIN address a
ON c.address_id = a.address_id
LEFT JOIN city ci 
ON ci.city_id = a.city_id

-- Verify the contents of the 'customer_address' table --
SELECT * FROM customer_address

-- CHALLENGE: Create a table showing total spending by each customer --

-- Display payment details --
SELECT * FROM payment

-- Create a summary of each customer's total payment amount --
SELECT first_name ||' '|| last_name AS name, SUM(amount) AS total_amount FROM customer c
LEFT JOIN payment p
ON p.customer_id = c.customer_id 
GROUP BY first_name ||' '|| last_name  

-- Create a new table 'customer_spendings' to store the total spendings per customer --
CREATE TABLE customer_spendings
AS 
SELECT first_name ||' '|| last_name AS name, SUM(amount) AS total_amount FROM customer c
LEFT JOIN payment p
ON p.customer_id = c.customer_id 
GROUP BY first_name ||' '|| last_name  
ORDER BY SUM(amount)

-- Verify the contents of the 'customer_spendings' table --
SELECT * FROM customer_spendings

-- CREATE TABLE AS vs. CREATE VIEW AS --
/* Instead of storing the data as a table (which takes up physical storage space), 
   a view only saves the query definition. A view is dynamic, depending on the data, 
   while a table will not change if more data is added to the original table. 
   Tables are faster since they don't require re-running the original code. */

-- Drop the 'customer_spendings' table --
DROP TABLE customer_spendings

-- Create a view 'customer_spendings' that dynamically shows the total spending per customer --
CREATE VIEW customer_spendings
AS 
SELECT first_name ||' '|| last_name AS name, SUM(amount) AS total_amount FROM customer c
LEFT JOIN payment p
ON p.customer_id = c.customer_id 
GROUP BY first_name ||' '|| last_name  
ORDER BY SUM(amount)

-- View the contents of the 'customer_spendings' view --
SELECT * FROM customer_spendings

-- Example: Query films categorized as 'Action' or 'Comedy' --
SELECT * FROM category

-- Join the 'film', 'film_category', and 'category' tables to get films of specific categories --
SELECT title, length, name AS category_name FROM film f
LEFT JOIN film_category fc
ON f.film_id = fc.film_id 
LEFT JOIN category c 
ON c.category_id = fc.category_id 
WHERE name = 'Action' OR name = 'Comedy'
ORDER BY length desc

-- Create a view 'films_category' that shows films in the 'Action' or 'Comedy' categories --
CREATE VIEW films_category
AS 
SELECT title, length, name AS category_name FROM film f
LEFT JOIN film_category fc
ON f.film_id = fc.film_id 
LEFT JOIN category c 
ON c.category_id = fc.category_id 
WHERE name = 'Action' OR name = 'Comedy'
ORDER BY length desc

-- View the results of the 'films_category' view --
SELECT * FROM films_category

/* CREATE TABLE AS takes up more storage space and doesn't update when the data changes, 
   while CREATE VIEW AS is dynamic, but it can be slower for complex queries. 
   SOLUTION: USE CREATE MATERIALIZED VIEW */

-- Create a materialized view 'mv_films_category' for more efficient querying of films in 'Action' and 'Comedy' categories --
CREATE MATERIALIZED VIEW mv_films_category
AS 
SELECT title, length, name AS category_name FROM film f
LEFT JOIN film_category fc
ON f.film_id = fc.film_id 
LEFT JOIN category c 
ON c.category_id = fc.category_id 
WHERE name = 'Action' OR name = 'Comedy'
ORDER BY length desc

-- View the contents of the 'mv_films_category' materialized view --
SELECT * FROM mv_films_category 

-- Update the 'film' table and refresh the materialized view to reflect the changes --
UPDATE film -- Update the original table --
SET length = 192
WHERE title = 'SATURN NAME'

-- Refresh the materialized view 'mv_films_category' to update it with the latest data --
REFRESH MATERIALIZED VIEW mv_films_category 

/* NOTE: MANAGING VIEWS --

1. ALTER VIEW
   - To rename a view:
     ALTER VIEW name RENAME TO new_name
   - To rename a column in a view:
     ALTER VIEW name RENAME COLUMN column_name TO new_name

2. DROP VIEW
   - To drop a standard view:
     DROP VIEW name
   - To drop a materialized view:
     DROP MATERIALIZED VIEW name

3. CREATE OR REPLACE VIEW
   - This can replace an existing view with a new query:
     CREATE OR REPLACE VIEW name AS new_query_name
*/

-- Challenge: Creating and managing views --

-- Create a view showing customer information with address and country details --
CREATE VIEW v_customer_info
AS
SELECT cu.customer_id,
    cu.first_name || ' ' || cu.last_name AS name,
    a.address,
    a.postal_code,
    a.phone,
    city.city,
    country.country
     FROM customer cu
     JOIN address a ON cu.address_id = a.address_id
     JOIN city ON a.city_id = city.city_id
     JOIN country ON city.country_id = country.country_id
ORDER BY customer_id

-- Rename the view 'v_customer_info' to 'v_customer_information' --
ALTER VIEW v_customer_info
RENAME TO v_customer_information

-- Rename the column 'customer_id' to 'c_id' in the view --
ALTER VIEW v_customer_information
RENAME COLUMN customer_id TO c_id

-- View the updated 'v_customer_information' view --
SELECT * FROM v_customer_information

-- Create a new 'v_customer_info' view with updated query --
CREATE VIEW v_customer_info
AS
SELECT 
    cu.first_name || ' ' || cu.last_name AS name,
    a.address,
    a.postal_code,
    a.phone,
    city.city,
    country.country,
    cu.customer_id
     FROM customer cu
     JOIN address a ON cu.address_id = a.address_id
     JOIN city ON a.city_id = city.city_id
     JOIN country ON city.country_id = country.country_id
ORDER BY customer_id

-- View the results of the 'v_customer_info' view --
SELECT * FROM v_customer_info

-- Replace the existing 'v_customer_information' view with a new query --
CREATE OR REPLACE VIEW v_customer_information
AS 
SELECT 
    cu.customer_id as c_id,
    cu.first_name || ' ' || cu.last_name AS name,
    a.address,
    a.postal_code,
    a.phone,
    city.city,
    country.country,
    CONCAT(LEFT(cu.first_name,1),LEFT(cu.last_name,1)) as initials
FROM customer cu
JOIN address a ON cu.address_id = a.address_id
JOIN city ON a.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
ORDER BY c_id -- Replace initial query --

-- Drop the old 'v_customer_info' view --
DROP VIEW v_customer_info