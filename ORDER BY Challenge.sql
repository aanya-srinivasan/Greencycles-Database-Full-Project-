SELECT * FROM flights

SELECT departure_airport, flight_id,
actual_arrival - scheduled_arrival AS lateness, SUM(actual_arrival - scheduled_arrival) 
OVER(ORDER BY flight_id) FROM flights

SELECT departure_airport, flight_id,
actual_arrival - scheduled_arrival AS lateness, SUM(actual_arrival - scheduled_arrival) 
OVER(PARTITION BY departure_airport ORDER BY flight_id) FROM flights