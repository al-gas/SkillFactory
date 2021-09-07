-- What was given
select *, (actual_arrival - actual_departure) as duration
from dst_project.flights
where departure_airport = 'AAQ'
  and (date_trunc('month', scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01'))
  and status not in ('Cancelled')



-- finall query for the resulting dataset
WITH flight AS (
    SELECT *
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
            count(CASE WHEN tf.fare_conditions = 'Economy' THEN tf.fare_conditions END) as ticket_economy,
            count(CASE WHEN tf.fare_conditions = 'Comfort' THEN tf.fare_conditions END) as ticket_comfort,
            count(CASE WHEN tf.fare_conditions = 'Business' THEN tf.fare_conditions END) as ticket_business
        FROM dst_project.ticket_flights as tf
        GROUP BY 1
    )
    SELECT f.flight_id,
           f.flight_no,
           f.departure_airport,
           f.arrival_airport,
           f.model,
           f.actual_arrival,
           f.actual_departure,
           tc.ticket_economy ticket_economy,
           tc.ticket_comfort ticket_comfort,
           tc.ticket_business ticket_business,
           date_part('hour', f.actual_arrival - f.actual_departure) * 60 +
           date_part('minute', f.actual_arrival - f.actual_departure) flight_duration,
           t.total_amount
    FROM flight f
        LEFT JOIN ticket t on t.flight_id = f.flight_id
        LEFT JOIN ticket_class tc on tc.flight_id = f.flight_id
    where departure_airport = 'AAQ'
      and (date_trunc('month', scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01'))
      and status not in ('Cancelled');
