-- UPDATE --

-- Select all customers ordered by their customer_id in ascending order --
SELECT * FROM customer 
ORDER BY customer_id ASC

-- Update the 'last_name' of the customer with customer_id = 1 to 'BROWN' --
UPDATE customer 
SET last_name = 'BROWN'
WHERE customer_id = 1;

-- Update the 'email' column to lowercase (dynamic update) --
UPDATE customer 
SET email = lower(email);  -- The 'lower()' function converts email to lowercase

-- CHALLENGE --

-- Select all films where the rental_rate is 1.99 --
SELECT * FROM film
WHERE rental_rate = 1.99

-- Update the 'rental_rate' of films from 0.99 to 1.99 --
UPDATE film 
SET rental_rate = 1.99
WHERE rental_rate = 0.99

-- Select all customers after the rental_rate update --
SELECT * FROM customer

-- Add a new column 'initials' of type VARCHAR(10) to the 'customer' table --
ALTER TABLE customer 
ADD COLUMN initials VARCHAR(10)

-- Update the 'initials' column with the first letter of the first name and the last letter of the last name, followed by a period --
UPDATE customer 
SET initials = LEFT(first_name, 1) || '.' || RIGHT(last_name, 1) || '.';

-- DELETE, can get rid of specific rows based on WHERE clause --

-- CHALLENGE --

-- Select all payment records --
SELECT * FROM payment 

-- Delete payment records with payment_id 17064 and 17067 --
DELETE FROM payment 
WHERE payment_id IN (17064, 17067)
RETURNING *;  -- The RETURNING clause allows us to see the rows that were deleted

-- NOTE:
-- The 'RETURNING *' clause returns all columns of the rows that were deleted. You can also specify particular columns to return.
-- For example, if you only want to see the 'payment_id' of the deleted records, you can write:
-- RETURNING payment_id;
