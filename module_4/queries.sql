--====================================================================================
-- Задание 4.1
-- База данных содержит список аэропортов практически всех крупных городов России. В большинстве городов есть только один аэропорт. 
-- Исключение составляет: Moscow, Ulyanovsk верно
SELECT city
FROM dst_project.airports
GROUP BY city
HAVING count(airport_name)>1
ORDER BY city ASC;
--====================================================================================


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
SELECT count(distinct flight_id)
FROM dst_project.flights
WHERE actual_arrival BETWEEN '2017-04-01' and '2017-09-01'
  AND status = 'Arrived'
  AND arrival_airport IS NOT NULL;
--====================================================================================


--Задание 4.3
--Вопрос 1. Сколько всего рейсов было отменено по данным базы?
SELECT count(distinct flight_id)
FROM dst_project.flights
WHERE status = 'Cancelled'


--Вопрос 2. Сколько самолетов моделей типа Boeing, Sukhoi Superjet, Airbus находится в базе авиаперевозок?
--Boeing:
--SELECT count(distinct dst_project.flights.flight_no)
--FROM dst_project.flights
--RIGHT JOIN dst_project.aircrafts ON dst_project.flights.aircraft_code = dst_project.aircrafts.aircraft_code
--WHERE dst_project.aircrafts.model LIKE 'Boeing%';
SELECT count(a.model)
FROM dst_project.aircrafts a
WHERE a.model LIKE 'Boeing%';

--Sukhoi Superjet:
SELECT count(a.model)
FROM dst_project.aircrafts a
WHERE a.model LIKE 'Sukhoi Superjet%';

--Airbus:
SELECT count(a.model)
FROM dst_project.aircrafts a
WHERE a.model LIKE 'Airbus%';

--Вопрос 3. В какой части (частях) света находится больше аэропортов?
SELECT
    count(CASE WHEN dst_project.airports.timezone like 'Asia%' THEN dst_project.airports.timezone END) as Asia,
    count(CASE WHEN dst_project.airports.timezone like 'Europe%' THEN dst_project.airports.timezone END) as Europe,
    count(CASE WHEN dst_project.airports.timezone like 'Australia%' THEN dst_project.airports.timezone END) as Australia
FROM dst_project.airports

--Вопрос 4. У какого рейса была самая большая задержка прибытия за все время сбора данных?
--Введите id рейса (flight_id).
SELECT f.flight_id, (f.actual_arrival - f.scheduled_arrival) as delay
FROM dst_project.flights f
WHERE f.actual_arrival IS NOT NULL
ORDER BY delay DESC
LIMIT 1
--====================================================================================


--Задание 4.4
--Вопрос 1. Когда был запланирован самый первый вылет, сохраненный в базе данных?
SELECT f.scheduled_departure FROM dst_project.flights f
ORDER BY f.scheduled_departure ASC
LIMIT 1;

--Вопрос 2. Сколько минут составляет запланированное время полета в самом длительном рейсе?
SELECT date_part('hour', f.scheduled_arrival - f.scheduled_departure) * 60 +
       date_part('minute', f.scheduled_arrival - f.scheduled_departure) AS flight_time
FROM dst_project.flights f
WHERE f.scheduled_arrival IS NOT NULL
AND f.actual_arrival IS NOT NULL
ORDER BY flight_time DESC
LIMIT 1

--Вопрос 3. Между какими аэропортами пролегает самый длительный по времени запланированный рейс?
SELECT date_part('hour', f.scheduled_arrival - f.scheduled_departure) * 60 +
       date_part('minute', f.scheduled_arrival - f.scheduled_departure) AS flight_time,
	   departure_airport,
	   arrival_airport
FROM dst_project.flights f
WHERE f.scheduled_arrival IS NOT NULL
AND f.actual_arrival IS NOT NULL
ORDER BY flight_time DESC
LIMIT 1

--Вопрос 4. Сколько составляет средняя дальность полета среди всех самолетов в минутах?
--Секунды округляются в меньшую сторону (отбрасываются до минут).
SELECT avg(date_part('hour', f.scheduled_arrival - f.scheduled_departure) * 60 +
       date_part('minute', f.scheduled_arrival - f.scheduled_departure)) AS avg_flight_time
FROM dst_project.flights f;
--====================================================================================


--Задание 4.5
--Вопрос 1. Мест какого класса у SU9 больше всего?
SELECT DISTINCT fare_conditions, count(fare_conditions)
FROM dst_project.seats
WHERE aircraft_code='SU9'
GROUP BY fare_conditions
ORDER BY fare_conditions DESC;

--Вопрос 2. Какую самую минимальную стоимость составило бронирование за всю историю?
SELECT min(b.total_amount)
FROM dst_project.bookings b

--Вопрос 3. Какой номер места был у пассажира с id = 4313 788533?
SELECT bp.seat_no
FROM dst_project.boarding_passes bp
    LEFT JOIN dst_project.tickets t
    ON t.ticket_no=bp.ticket_no
WHERE t.passenger_id='4313 788533'
--====================================================================================


--Задание 5.1
--Вопрос 1. Анапа — курортный город на юге России. Сколько рейсов прибыло в Анапу за 2017 год?
SELECT count(f.flight_id)
FROM dst_project.flights f
WHERE f.actual_arrival IS NOT NULL
AND f.arrival_airport = 'AAQ'
AND f.status = 'Arrived'
AND date_part('year', f.actual_arrival) = 2017

--Вопрос 2. Сколько рейсов из Анапы вылетело зимой 2017 года?
SELECT count(f.flight_id)
FROM dst_project.flights f
WHERE f.actual_departure IS NOT NULL
AND f.departure_airport = 'AAQ'
AND (date_trunc('month', f.scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01'))

--Вопрос 3. Посчитайте количество отмененных рейсов из Анапы за все время.
SELECT count(f.flight_id)
FROM dst_project.flights f
WHERE f.departure_airport = 'AAQ'
AND f.status = 'Cancelled'

--Вопрос 4. Сколько рейсов из Анапы не летают в Москву?
SELECT count(f.flight_id)
FROM dst_project.flights f
LEFT JOIN dst_project.airports a ON f.arrival_airport = a.airport_code
WHERE f.departure_airport = 'AAQ'
AND a.city != 'Moscow'

--Вопрос 5. Какая модель самолета летящего на рейсах из Анапы имеет больше всего мест?
SELECT a.model, count(DISTINCT s.seat_no) AS seats
FROM dst_project.aircrafts a
    LEFT JOIN dst_project.seats s
    ON a.aircraft_code=s.aircraft_code
    LEFT JOIN dst_project.flights f
    ON f.aircraft_code=a.aircraft_code
WHERE departure_airport='AAQ'
GROUP BY a.model
ORDER BY seats DESC
