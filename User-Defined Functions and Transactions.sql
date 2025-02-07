-- User Defined Functions --

CREATE FUNCTION first_func(c1 INT, c2 INT)  -- can also use CREATE OR REPLACE FUNCTION --
	RETURNS INT -- datatype--
	LANGUAGE plpgsql 
AS
$$
DECLARE c3 INT;
BEGIN
SELECT c1 + c2 + 3
INTO c3;
RETURN c3;
END;
$$

SELECT first_func(3,5)

-- so now we want to create a function that counts all movies between a min and max rental rate that the user can define --

CREATE FUNCTION count_movies(min_r decimal(4,2), max_r decimal (4,2))
	RETURNS INT 
	LANGUAGE plpgsql 
AS 
$$
DECLARE count_movies INT;
BEGIN 
SELECT COUNT(*) INTO count_movies FROM film 
WHERE rental_rate BETWEEN min_r AND max_r ; 
RETURN count_movies;
END;
$$

SELECT * FROM film

SELECT count_movies(0,6)

CREATE FUNCTION name_search(first_n VARCHAR(20), last_n VARCHAR(20)) 
	RETURNS NUMERIC(5,2)
	LANGUAGE plpgsql
AS
$$
DECLARE sum_amount NUMERIC(5,2);
BEGIN 
SELECT SUM(amount) INTO sum_amount FROM customer c
LEFT JOIN payment p 
ON c.customer_id = p.customer_id 
WHERE first_name = first_n AND last_name = last_n
GROUP BY first_name, last_name;
RETURN sum_amount;
END;
$$

DROP FUNCTION name_search -- made a mistake so deleted and tried again --

SELECT name_search('MARIA', 'MILLER')

SELECT first_name, last_name, name_search(first_name, last_name) FROM customer 

-- Transactions --

CREATE TABLE acc_balance (
    id SERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
	last_name TEXT NOT NULL,
    amount DEC(9,2) NOT NULL    
);

INSERT INTO acc_balance
VALUES 
(1,'Tim','Brown',2500),
(2,'Sandra','Miller',1600)

SELECT * FROM acc_balance;

-- also BEGIN;--
BEGIN TRANSACTION; -- Use this when you want to achieve connected activities in one session of work--
UPDATE acc_balance 
SET amount = amount - 100
WHERE id = 1;
UPDATE acc_balance
SET amount = amount + 100 
WHERE id = 2; 
COMMIT; -- must commit to make permanent --

-- Challenge --

CREATE TABLE employees (
emp_id SERIAL PRIMARY KEY,
first_name TEXT NOT NULL,
last_name TEXT NOT NULL,
job_position TEXT NOT NULL,
salary decimal(8,2),
start_date DATE NOT NULL,
birth_date DATE NOT NULL,
store_id INT REFERENCES store(store_id),
department_id INT,
manager_id INT
);

ALTER TABLE employees 
ALTER COLUMN department_id SET NOT NULL,
ALTER COLUMN start_date SET DEFAULT CURRENT_DATE,
ADD COLUMN end_date DATE,
ADD CONSTRAINT birth_check CHECK(birth_date < CURRENT_DATE);

ALTER TABLE employees
RENAME job_position TO position_title;

INSERT INTO employees 
VALUES
(1,'Morrie','Conaboy','CTO',21268.94,'2005-04-30','1983-07-10',1,1,NULL,NULL),
(2,'Miller','McQuarter','Head of BI',14614.00,'2019-07-23','1978-11-09',1,1,1,NULL),
(3,'Christalle','McKenny','Head of Sales',12587.00,'1999-02-05','1973-01-09',2,3,1,NULL),
(4,'Sumner','Seares','SQL Analyst',9515.00,'2006-05-31','1976-08-03',2,1,6,NULL),
(5,'Romain','Hacard','BI Consultant',7107.00,'2012-09-24','1984-07-14',1,1,6,NULL),
(6,'Ely','Luscombe','Team Lead Analytics',12564.00,'2002-06-12','1974-08-01',1,1,2,NULL),
(7,'Clywd','Filyashin','Senior SQL Analyst',10510.00,'2010-04-05','1989-07-23',2,1,2,NULL),
(8,'Christopher','Blague','SQL Analyst',9428.00,'2007-09-30','1990-12-07',2,2,6,NULL),
(9,'Roddie','Izen','Software Engineer',4937.00,'2019-03-22','2008-08-30',1,4,6,NULL),
(10,'Ammamaria','Izhak','Customer Support',2355.00,'2005-03-17','1974-07-27',2,5,3,'2013-04-14'),
(11,'Carlyn','Stripp','Customer Support',3060.00,'2013-09-06','1981-09-05',1,5,3,NULL),
(12,'Reuben','McRorie','Software Engineer',7119.00,'1995-12-31','1958-08-15',1,5,6,NULL),
(13,'Gates','Raison','Marketing Specialist',3910.00,'2013-07-18','1986-06-24',1,3,3,NULL),
(14,'Jordanna','Raitt','Marketing Specialist',5844.00,'2011-10-23','1993-03-16',2,3,3,NULL),
(15,'Guendolen','Motton','BI Consultant',8330.00,'2011-01-10','1980-10-22',2,3,6,NULL),
(16,'Doria','Turbat','Senior SQL Analyst',9278.00,'2010-08-15','1983-01-11',1,1,6,NULL),
(17,'Cort','Bewlie','Project Manager',5463.00,'2013-05-26','1986-10-05',1,5,3,NULL),
(18,'Margarita','Eaden','SQL Analyst',5977.00,'2014-09-24','1978-10-08',2,1,6,'2020-03-16'),
(19,'Hetty','Kingaby','SQL Analyst',7541.00,'2009-08-17','1999-04-25',1,2,6,NULL),
(20,'Lief','Robardley','SQL Analyst',8981.00,'2002-10-23','1971-01-25',2,3,6,'2016-07-01'),
(21,'Zaneta','Carlozzi','Working Student',1525.00,'2006-08-29','1995-04-16',1,3,6,'2012-02-19'),
(22,'Giana','Matz','Working Student',1036.00,'2016-03-18','1987-09-25',1,3,6,NULL),
(23,'Hamil','Evershed','Web Developper',3088.00,'2022-02-03','2012-03-30',1,4,2,NULL),
(24,'Lowe','Diamant','Web Developper',6418.00,'2018-12-31','2002-09-07',1,4,2,NULL),
(25,'Jack','Franklin','SQL Analyst',6771.00,'2013-05-18','2005-10-04',1,2,2,NULL),
(26,'Jessica','Brown','SQL Analyst',8566.00,'2003-10-23','1965-01-29',1,1,2,NULL);

SELECT * FROM employees

BEGIN;
UPDATE employees 
SET position_title = 'Head of Sales', salary = 12587.00
WHERE emp_id = 2;
UPDATE employees 
SET position_title = 'Head of Bi', salary = 14614.00
WHERE emp_id = 3;
COMMIT;

BEGIN; -- This doesn't work because they both become the same thing --
UPDATE employees 
SET position_title = (SELECT position_title FROM employees WHERE emp_id = 3), 
salary = (SELECT salary FROM employees WHERE emp_id = 3)
WHERE emp_id = 2;
UPDATE employees 
SET position_title = (SELECT position_title FROM employees WHERE emp_id = 2), 
salary = (SELECT salary FROM employees WHERE emp_id = 2)
WHERE emp_id = 3;
COMMIT;

DROP TABLE employees

-- Rollbacks --

/* 

BEGIN TRANSACTION; 
UPDATE acc_balance 
SET amount = amount - 100
WHERE id = 1;
DELETE FROM acc_balance
SET amount = amount + 100 
WHERE id = 2; 
ROLLBACK;
COMMIT;

- Rollback closes the transaction and gets rid of all the actions taken

BEGIN TRANSACTION; 
UPDATE acc_balance 
SET amount = amount - 100
WHERE id = 1;
SAVEPOINT s1;
DELETE FROM acc_balance
SET amount = amount + 100 
WHERE id = 2; 
ROLLBACK TO SAVEPOINT s1;
COMMIT;

- Rollback to savepoint does not close trannsaction it just gets rid of progress after savepoint 


RELEASE SAVEPOINT s1; to delete savepoint

NOTE: this only works if COMMIT hasn't been applied */

-- Stored procedures, same as function without return statement  --

SELECT * FROM employees

CREATE OR REPLACE PROCEDURE emp_swap (id1 INT, id2 INT)
LANGUAGE plpgsql
AS
$$
DECLARE -- variables --
position1 TEXT;
position2 TEXT;
salary1 numeric(8,2);
salary2 numeric(8,2);
BEGIN
SELECT position_title INTO position1 FROM employees
WHERE emp_id = id1;
SELECT position_title INTO position2 FROM employees
WHERE emp_id = id2;
SELECT salary INTO salary1 FROM employees
WHERE emp_id = id1;
SELECT salary INTO salary2 FROM employees
WHERE emp_id = id2;
UPDATE employees
SET position_title = position1 
WHERE emp_id = id2;
UPDATE employees
SET position_title = position2
WHERE emp_id = id1;
UPDATE employees
SET salary = salary1
WHERE emp_id = id2;
UPDATE employees
SET salary = salary2
WHERE emp_id = id1;
COMMIT;
END;
$$

CALL emp_swap(1,2) -- Use call function instead of select --

SELECT * FROM employees