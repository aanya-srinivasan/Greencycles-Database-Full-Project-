-- Create the 'director' table with various columns, including a foreign key reference to the 'address' table --
CREATE TABLE director (
    director_id SERIAL PRIMARY KEY,  -- Auto-incrementing primary key for 'director' table
    director_account_name VARCHAR(20) UNIQUE,  -- Unique account name for each director
    first_name VARCHAR(50),  -- First name of the director
    last_name VARCHAR(50) DEFAULT 'Not Specified',  -- Last name with a default value if not provided
    date_of_birth DATE,  -- Director's date of birth
    address_id INT REFERENCES address(address_id)  -- Foreign key referencing 'address' table (address_id)
);

-- Display all records from the 'director' table
SELECT * FROM director;

-- Create the 'online_sales' table with foreign key references to 'customer' and 'film' tables --
CREATE TABLE online_sales (
    transaction_id SERIAL PRIMARY KEY,  -- Auto-incrementing primary key for each transaction
    customer_id INT REFERENCES customer(customer_id),  -- Foreign key referencing 'customer' table
    film_id INT REFERENCES film(film_id),  -- Foreign key referencing 'film' table
    AMOUNT SMALLINT NOT NULL,  -- Sale amount (small integer value)
    promotion_code VARCHAR(10) DEFAULT 'None'  -- Default promotion code if none is provided
);

-- Display all records from the 'online_sales' table
SELECT * FROM online_sales;

-- Cast the 'amount' column to a numeric type with two decimal places for proper formatting --
SELECT CAST(amount AS numeric(5,2)) FROM online_sales;

-- Alter the 'amount' column to have a numeric data type with two decimal places --
ALTER TABLE online_sales
ALTER COLUMN amount
SET DATA TYPE numeric(5,2);

-- Insert records into the 'online_sales' table for different transactions --
INSERT INTO online_sales 
(customer_id, film_id, amount, promotion_code)
VALUES 
    (124, 65, 14.99, 'PROMO2022'), 
    (225, 231, 12.99, 'JULYPROMO'), 
    (119, 53, 15.99, 'SUMMERDEAL');

-- Create the 'customer_feedback' table to store feedback on customer experiences --
CREATE TABLE customer_feedback (
    feedback_id SERIAL PRIMARY KEY,  -- Auto-incrementing primary key for feedback records
    customer_id INT REFERENCES customer(customer_id),  -- Foreign key referencing 'customer' table
    numeric_review INT,  -- Numeric review score (e.g., rating out of 10)
    text_review VARCHAR(100) DEFAULT 'None',  -- Optional text review with a default value
    repurchased BOOL NOT NULL,  -- Whether the customer repurchased a product (TRUE/FALSE)
    feedback_date DATE  -- Date when the feedback was provided
);

-- Display all feedback records (should be empty initially)
SELECT * FROM customer_feedback;

-- Insert records into the 'customer_feedback' table for different customers' reviews --
INSERT INTO customer_feedback 
(customer_id, numeric_review, text_review, repurchased, feedback_date)
VALUES 
    (266, 8, 'Very good', TRUE, '2024-12-21'), 
    (269, 2, 'Did not like', FALSE, '2024-12-21');

-- Alter the 'customer_feedback' table by changing column types and adding new columns --
ALTER TABLE customer_feedback 
ALTER COLUMN numeric_review TYPE VARCHAR(10),  -- Change the 'numeric_review' column to type VARCHAR(10)
ADD COLUMN questions VARCHAR(50) DEFAULT 'None';  -- Add a new column 'questions' with a default value

-- Alter the 'customer_feedback' table to drop the 'repurchased' column --
ALTER TABLE customer_feedback
DROP COLUMN repurchased;  -- Remove the 'repurchased' column from the table

-- Rename the 'customer_feedback' table to 'feedback' --
ALTER TABLE customer_feedback
RENAME TO feedback;

-- Rename the 'numeric_review' column to 'rating' in the 'feedback' table --
ALTER TABLE feedback
RENAME COLUMN numeric_review TO rating;

-- Add a new column 'repurchased' to the 'feedback' table if it doesn't already exist --
ALTER TABLE feedback
ADD COLUMN IF NOT EXISTS repurchased BOOL NULL;

-- Alter multiple columns in the 'feedback' table --
ALTER TABLE feedback
ALTER COLUMN feedback_date SET DEFAULT NULL,  -- Set the default value of 'feedback_date' to NULL
ALTER COLUMN questions DROP DEFAULT,  -- Drop the default value of the 'questions' column
ALTER COLUMN customer_id SET NOT NULL;  -- Set 'customer_id' column to NOT NULL

-- Display all records from the 'feedback' table
SELECT * FROM feedback;

-- Forcefully change the 'rating' column type to INT (integer) --
ALTER TABLE feedback
ALTER COLUMN rating TYPE INT USING rating::INTEGER;  -- Use the 'USING' clause to cast the existing values

-- Alter the 'director' table by making changes to columns and adding a new one --
ALTER TABLE director 
ALTER COLUMN director_account_name TYPE VARCHAR(30),  -- Change the length of the 'director_account_name' column
ALTER COLUMN last_name DROP DEFAULT,  -- Remove the default value of the 'last_name' column
ALTER COLUMN last_name SET NOT NULL,  -- Set 'last_name' to NOT NULL
ADD COLUMN email VARCHAR(40);  -- Add a new 'email' column

-- Rename 'director_account_name' column to 'account_name' in the 'director' table --
ALTER TABLE director 
RENAME COLUMN director_account_name TO account_name;

-- Rename the 'director' table to 'directors' --
ALTER TABLE director 
RENAME TO directors;

-- Display all records from the 'directors' table
SELECT * FROM directors;

-- Truncate the 'feedback' table (removes all data but keeps the structure) --
TRUNCATE feedback;

-- Drop the 'feedback' table (removes both the structure and data) --
DROP TABLE feedback;

-- Create the 'songs' table with various constraints and checks --
CREATE TABLE songs (
    song_id SERIAL PRIMARY KEY,  -- Auto-incrementing primary key for each song
    song_name VARCHAR(30) NOT NULL,  -- Name of the song (cannot be NULL)
    genre VARCHAR(30) DEFAULT 'Not Defined',  -- Genre of the song with a default value
    price numeric(4,2) CHECK(price >= 1.99),  -- Price with a constraint ensuring it is greater than or equal to 1.99
    release_date DATE CONSTRAINT date_check CHECK (release_date BETWEEN '1950-01-01' AND CURRENT_DATE)  -- Release date check
);

-- Display all records from the 'songs' table (should be empty initially)
SELECT * FROM songs;

-- Insert a song with an invalid price (will fail because of the CHECK constraint) --
INSERT INTO songs
(song_id, song_name, price, release_date)
VALUES(4, 'SQL song', 0.99, '2022-01-07');  -- This will fail because the price is less than 1.99

-- Alter the 'songs' table by dropping an existing constraint and adding a new one for 'price' --
ALTER TABLE songs 
DROP CONSTRAINT songs_price_check;  -- Drop the 'songs_price_check' constraint

ALTER TABLE songs 
ADD CONSTRAINT songs_price_check CHECK(price >= 0.99);  -- Add a new 'songs_price_check' constraint (allowing lower price)