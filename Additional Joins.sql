-- Self Join --
/* A table that is joined with itself to make comparisons between two rows. The idea is to create 
two separate copies of the table using aliases 

So we have a table that has the employee id, the employee name, and the manager id of that employee. What we do is
we create two virtual copies of this table employee emp and employee mng, one representing employee data and 
the other representing the data of the manager.

*/

CREATE TABLE employee (
	employee_id INT,
	name VARCHAR (50),
	manager_id INT
);

INSERT INTO employee 
VALUES
	(1, 'Liam Smith', NULL),
	(2, 'Oliver Brown', 1),
	(3, 'Elijah Jones', 1),
	(4, 'William Miller', 1),
	(5, 'James Davis', 2),
	(6, 'Olivia Hernandez', 2),
	(7, 'Emma Lopez', 2),
	(8, 'Sophia Andersen', 2),
	(9, 'Mia Lee', 3),
	(10, 'Ava Robinson', 3);

SELECT * FROM employee

SELECT emp.employee_id, emp.name AS employee_name, mng.name AS manager_name FROM employee emp
LEFT JOIN employee mng
ON emp.manager_id = mng.employee_id 

-- can even see the manager of a manager --

SELECT emp.employee_id, emp.name AS employee_name, mng.name AS manager_name, mngmng.name AS manager_manager FROM employee emp
LEFT JOIN employee mng
ON emp.manager_id = mng.employee_id 
LEFT JOIN employee mngmng
ON mng.manager_id = mngmng.employee_id 

-- Challenge --

SELECT f1.title, f2.title, f1.length FROM film f1
LEFT JOIN film f2
ON f1.length = f2.length 
WHERE f1.title != f2.title
ORDER BY length desc

-- or --

SELECT f1.title, f2.title, f1.length FROM film f1
LEFT JOIN film f2
ON f1.length = f2.length AND f1.title != f2.title
ORDER BY length desc

-- CROSS JOIN, create combinations of different columns (by column, not value) --

SELECT staff_id, store.store_id, last_name FROM staff
CROSS JOIN store -- you do not even need ON because we are not joining on two rows that are the same --

-- MAJOR NOTE: rows are getting joined, so rows in one table will be kept together --

-- Natural Join, normal join, you do not need to use ON as it joins on the columns that are the same --

SELECT * FROM payment 
NATURAL INNER JOIN customer
