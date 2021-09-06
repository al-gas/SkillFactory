-- Задание 4.1
-- База данных содержит список аэропортов практически всех крупных городов России. В большинстве городов есть только один аэропорт. 
-- Исключение составляет: Moscow, Ulyanovsk верно
SELECT city
FROM dst_project.airports
GROUP BY city
HAVING count(airport_name)>1
ORDER BY city ASC;

-- Задание 4.2
-- Вопрос 1. Таблица рейсов содержит всю информацию о прошлых, текущих и запланированных рейсах.
-- Сколько всего статусов для рейсов определено в таблице? - 6
SELECT count(distinct status)
FROM dst_project.flights;

-- Вопрос 2. Какое количество самолетов находятся в воздухе на момент среза в базе 
-- (статус рейса «самолёт уже вылетел и находится в воздухе»).
SELECT count(flight_id) FROM dst_project.flights
WHERE dst_project.flights.status = 'Departed';
 
-- Вопрос 3. Места определяют схему салона каждой модели. Сколько мест имеет самолет модели  (Boeing 777-300)?
SELECT count(dst_project.aircrafts.aircraft_code)
--       dst_project.aircrafts.model,
--       dst_project.seats.aircraft_code
FROM dst_project.aircrafts LEFT JOIN dst_project.seats
ON dst_project.aircrafts.aircraft_code = dst_project.seats.aircraft_code
WHERE dst_project.aircrafts.model = 'Boeing 777-300';
 
-- Вопрос 4. Сколько состоявшихся (фактических) рейсов было совершено между 1 апреля 2017 года и 1 сентября 2017 года?
SELECT *, (actual_arrival - actual_departure) AS duration
FROM dst_project.flights
WHERE (date_trunc('month', scheduled_departure) IN ('2017-04-01','2017-05-01', '2017-06-01', '2017-07-01', '2017-08-01', '2017-09-01'))
  AND status NOT IN ('Cancelled')
  AND dst_project.flights.departure_airport IS NOT NULL;

select distinct status from dst_project.flights;
select * from dst_project.seats;

select a.model
from dst_project.aircrafts a
where a.model like 'Boeing%'

select *
from dst_project.flights
where (date_part('year', actual_departure) = 2016) and
(date_part('month', actual_departure) in (8))

select *, (actual_arrival - actual_departure) as duration
from dst_project.flights
where departure_airport = 'AAQ'
  and (date_trunc('month', scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01'))
  and status not in ('Cancelled')




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