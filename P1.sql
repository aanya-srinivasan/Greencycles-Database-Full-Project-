--1 Create a list of all the different (distinct) replacement costs of the films. What's the lowest replacement cost? --

SELECT DISTINCT replacement_cost FROM film
ORDER BY replacement_cost ASC
LIMIT 1;

--2 Write a query that gives an overview of how many films have replacements costs in the following cost range--
SELECT COUNT(*), 
CASE
WHEN replacement_cost >= 9.99 AND replacement_cost <= 19.99 THEN 'low'
WHEN replacement_cost >= 20.00 AND replacement_cost <= 24.99 THEN 'medium'
WHEN replacement_cost >= 25.00 AND replacement_cost <= 29.99 THEN 'high'
END as replacement
FROM film 
GROUP BY replacement;

/* Create a list of the film titles including their title, length, and category name ordered 
descendingly by length. Filter the results to only the movies in the category 'Drama' or 'Sports'.
Question: In which category is the longest film and how long is it? */
--3
SELECT * FROM film
SELECT * FROM film_category
SELECT * FROM category

SELECT title, length, name as category FROM film f
INNER JOIN film_category fc
ON f.film_id = fc.film_id
INNER JOIN category c
ON fc.category_id = c.category_id
WHERE name = 'Drama' OR name = 'Sports'
ORDER BY length desc;


/* Create an overview of how many movies (titles) there are in each category (name).
Question: Which category (name) is the most common among the films? */
--4

SELECT name, COUNT(*) FROM film f
INNER JOIN film_category fc
ON f.film_id = fc.film_id
INNER JOIN category c
ON fc.category_id = c.category_id
GROUP BY name 
ORDER BY COUNT(*) desc;

--5  Create an overview of the actors' first and last names and in how many movies they appear in.

SELECT * FROM actor 
SELECT * FROM film_actor

SELECT first_name, last_name, COUNT(*) FROM actor a
INNER JOIN film_actor fa
ON a.actor_id = fa.actor_id 
GROUP BY first_name, last_name 
ORDER BY  COUNT(*) desc;

-- 6 Create an overview of the addresses that are not associated to any customer.
SELECT * FROM address 
SELECT * FROM customer

SELECT COUNT(*) FROM address a
LEFT JOIN customer c
ON a.address_id = c.address_id 
WHERE c.address_id is null;

-- 7 which city most sales occur
SELECT * FROM address 
SELECT * FROM customer
SELECT * FROM city 
SELECT * FROM payment
SELECT * FROM film

SELECT city, SUM(amount) FROM payment p
INNER JOIN customer c
ON p.customer_id = c.customer_id 
INNER JOIN address a
ON a.address_id = c.address_id 
INNER JOIN city ci
ON ci.city_id = a.city_id 
GROUP BY city 
ORDER BY SUM(amount) desc;

/*Create an overview of the revenue (sum of amount) grouped by a column in the format "country, city".
Question: Which country, city has the least sales?*/
--8
SELECT * FROM city 
SELECT * FROM country

SELECT  country ||', '|| city as countrycity, SUM(amount) FROM city ci
INNER JOIN country co
ON ci.country_id = co.country_id
INNER JOIN address a
ON ci.city_id = a.city_id 
INNER JOIN customer c
ON a.address_id = c.address_id 
INNER JOIN payment p
ON p.customer_id = c.customer_id 
GROUP BY countrycity
ORDER BY SUM(amount) asc;


/* Create a list with the average of the sales amount each staff_id has per customer.
Question: Which staff_id makes on average more revenue per customer? */
--9
SELECT * FROM customer
SELECT * FROM staff
SELECT * FROM payment
ORDER BY amount desc

SELECT staff_id,ROUND(AVG(total_amount), 2) FROM 
(SELECT staff_id, customer_id, SUM(amount) as total_amount FROM payment 
GROUP BY staff_id, customer_id
ORDER BY AVG(amount) desc) subquery
GROUP BY staff_id;

--10  Create a query that shows average daily revenue of all Sundays.
SELECT * FROM payment
SELECT DATE(payment_date) FROM payment

SELECT ROUND(AVG(total_amount), 2) FROM
(SELECT DATE(payment_date), EXTRACT(dow FROM payment_date), SUM(amount) as total_amount FROM payment 
WHERE EXTRACT(dow FROM payment_date) = 0
GROUP BY DATE(payment_date), EXTRACT(dow FROM payment_date)) subquery;


/*Create a list of movies - with their length and their replacement cost - that are longer than
the average length in each replacement cost group.
Question: Which two movies are the shortest on that list and how long are they? */
-- 11
SELECT * FROM film

SELECT title, length, replacement_cost FROM film f1
WHERE length > (SELECT AVG(length) FROM film f2
					WHERE f1.replacement_cost = f2.replacement_cost)
ORDER BY length asc;

/*Create a list that shows the "average customer lifetime value" grouped by the different districts.*/
--12

SELECT * FROM address
SELECT * FROM customer
SELECT * FROM payment

SELECT district, ROUND(AVG(sum),2) FROM
(SELECT district, payment.customer_id, SUM(amount) as sum FROM payment
INNER JOIN customer 
ON payment.customer_id = customer.customer_id 
INNER JOIN address 
ON customer.address_id = address.address_id 
GROUP BY district, payment.customer_id) subquery 
GROUP BY district
ORDER BY ROUND(AVG(sum),2) desc;


/* Create a list that shows all payments including the payment_id, amount, and the film category 
(name) plus the total amount that was made in this category. Order the results ascendingly by the category 
(name) and as second order criterion by the payment_id ascendingly.
Question: What is the total revenue of the category 'Action' and what is the lowest payment_id in that category 
'Action'? */
--13
SELECT * FROM film
SELECT * FROM category
SELECT * FROM film_category
SELECT * FROM payment
SELECT * FROM customer
SELECT * FROM rental
SELECT * FROM inventory

SELECT
title,
amount,
name,
payment_id,
(SELECT SUM(amount) FROM payment p
LEFT JOIN rental r
ON r.rental_id=p.rental_id
LEFT JOIN inventory i
ON i.inventory_id=r.inventory_id
LEFT JOIN film f
ON f.film_id=i.film_id
LEFT JOIN film_category fc
ON fc.film_id=f.film_id
LEFT JOIN category c1
ON c1.category_id=fc.category_id
WHERE c1.name=c.name)
FROM payment p
LEFT JOIN rental r
ON r.rental_id=p.rental_id
LEFT JOIN inventory i
ON i.inventory_id=r.inventory_id
LEFT JOIN film f
ON f.film_id=i.film_id
LEFT JOIN film_category fc
ON fc.film_id=f.film_id
LEFT JOIN category c
ON c.category_id=fc.category_id
ORDER BY name ASC, payment_id ASC;

