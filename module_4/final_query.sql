-- What was given
select *, (actual_arrival - actual_departure) as duration
from dst_project.flights
where departure_airport = 'AAQ'
  and (date_trunc('month', scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01'))
  and status not in ('Cancelled')



-- finall query for the resulting dataset
WITH flight AS (
    SELECT f.flight_id,
           f.flight_no,
           f.aircraft_code,
           f.departure_airport,
           f.arrival_airport,
           a.model,
           f.scheduled_arrival,
           f.actual_arrival,
           f.actual_departure,
           f.scheduled_departure,
           f.status
    FROM dst_project.flights f
        LEFT JOIN dst_project.aircrafts a ON f.aircraft_code = a.aircraft_code
    ),
    ticket AS (
        SELECT flight_id, sum(amount) total_amount
        FROM dst_project.ticket_flights
        GROUP BY 1
    ),
    ticket_class AS (
        SELECT tf.flight_id,
               count(CASE WHEN tf.fare_conditions = 'Economy' THEN tf.fare_conditions END) as fare_economy,
               count(CASE WHEN tf.fare_conditions = 'Comfort' THEN tf.fare_conditions END) as fare_comfort,
               count(CASE WHEN tf.fare_conditions = 'Business' THEN tf.fare_conditions END) as fare_business
        FROM dst_project.ticket_flights AS tf
        GROUP BY 1
    ),
    carrier_capacity AS (
        SELECT count(a.aircraft_code) AS plane_capacity,
               a.aircraft_code,
               a.model
        FROM dst_project.aircrafts a
        JOIN dst_project.seats s
        ON a.aircraft_code = s.aircraft_code
        GROUP BY a.aircraft_code, a.model
    )
    SELECT f.flight_id,
           f.flight_no,
           f.departure_airport,
           f.arrival_airport,
           f.model,
           f.actual_arrival,
           f.actual_departure,
           tc.fare_economy fare_economy,
           tc.fare_comfort fare_comfort,
           tc.fare_business fare_business,
           cc.plane_capacity,
           date_part('hour', f.actual_arrival - f.actual_departure) * 60 +
           date_part('minute', f.actual_arrival - f.actual_departure) flight_duration,
           t.total_amount
    FROM flight f
        JOIN ticket t ON t.flight_id = f.flight_id
        JOIN ticket_class tc ON tc.flight_id = f.flight_id
        inner JOIN carrier_capacity cc ON cc.aircraft_code = f.aircraft_code
    WHERE departure_airport = 'AAQ'
      AND (date_trunc('month', scheduled_departure) IN ('2017-01-01','2017-02-01', '2017-12-01'))
      AND status NOT IN ('Cancelled');
