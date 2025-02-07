SELECT * FROM bookings

SELECT 'Q' || TO_CHAR(book_date, 'Q') AS quarter, 
EXTRACT(month FROM book_date) AS month, 
TO_CHAR(book_date, 'W') AS week_in_month,
DATE(book_date) AS date, 
SUM(total_amount) AS booking_amount FROM bookings
GROUP BY ROLLUP 
('Q' || TO_CHAR(book_date, 'Q'),  EXTRACT(month FROM book_date), TO_CHAR(book_date, 'W'), DATE(book_date))
ORDER BY 1,2,3,4

SELECT TO_CHAR(book_date, 'W') FROM bookings -- shows number in the month --
SELECT EXTRACT(week FROM book_date) FROM bookings -- shows number in the year --