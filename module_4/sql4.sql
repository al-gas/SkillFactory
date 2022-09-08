SELECT
    matches.id,
    home_teams.short_name home_short,
    away_teams.short_name away_short
FROM
    sql.matches matches
    JOIN sql.teams home_teams ON matches.home_team_api_id = home_teams.api_id
    JOIN sql.teams away_teams ON matches.away_team_api_id = away_teams.api_id
ORDER BY matches.id ASC

SELECT * from city
SELECT * from customer
SELECT * from driver
SELECT * from shipment
SELECT * from truck

SELECT d.first_name, COUNT(s.cust_id) as cc FROM driver as d
JOIN shipment as s on d.driver_id = s.driver_id
GROUP BY d.first_name
order by cc DESC

-- укажите имя клиента, получившего наибольшее количество доставок за 2017 год.
SELECT c.cust_name, COUNT(s.ship_id) from customer as c
JOIN shipment as s on c.cust_id=s.cust_id
WHERE EXTRACT(YEAR FROM s.ship_date) = 2017
GROUP BY c.cust_id
ORDER BY 2 DESC

-- Допустим, мы хотим собрать из справочников по книгам и фильмам один,
-- так чтобы в нём содержались названия произведений, а также их описание — книга или фильм.
SELECT book_name object_name, 'книга' object_description
FROM public.books
UNION ALL
SELECT movie_title, 'фильм'
FROM sql.kinopoisk