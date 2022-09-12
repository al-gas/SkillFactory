select
    matches.id,
    home_teams.short_name home_short,
    away_teams.short_name away_short
from
    sql.matches matches
    join sql.teams home_teams on matches.home_team_api_id = home_teams.api_id
    join sql.teams away_teams on matches.away_team_api_id = away_teams.api_id
order by matches.id asc

select * from city
select * from customer
select * from driver
select * from shipment
select * from truck

select d.first_name, count(s.cust_id) as cc from driver as d
join shipment as s on d.driver_id = s.driver_id
group by d.first_name
order by cc desc

-- укажите имя клиента, получившего наибольшее количество доставок за 2017 год.
select c.cust_name, count(s.ship_id) from customer as c
join shipment as s on c.cust_id=s.cust_id
where extract(YEAR FROM s.ship_date) = 2017
GROUP BY c.cust_id
ORDER BY 2 DESC

-- Допустим, мы хотим собрать из справочников по книгам и фильмам один,
-- так чтобы в нём содержались названия произведений, а также их описание — книга или фильм.
select book_name object_name, 'книга' object_description
from public.books
union all
select movie_title, 'фильм'
from sql.kinopoisk

--как сформировать справочник с ID всех таблиц и указанием объекта, к которому он относится.
select c.city_id object_name,  'id города' object_type /*выбираем колонку city_id и задаём ей алиас object_name, сами задаём объект 'id города' и название столбца object_type*/
from sql.city c /*из схемы sql и таблицы city, задаём алиас таблице — с*/
union all /*оператор присоединения*/
select d.driver_id other_name,  'id водителя' other_type /*выбираем колонку driver_id и задаём ей алиас other_name, сами задаём объект 'id водителя' и название столбца other_type*/
from sql.driver d  /*из схемы sql и таблицы driver, задаём алиас таблице — d*/
union all /*оператор присоединения*/
select s.ship_id,  'id доставки' /*выбираем колонку ship_id, сами задаём объект 'id доставки'*/
from sql.shipment s /*из схемы sql и таблицы shipment, задаём алиас таблице — s*/
union all /*оператор присоединения*/
select c.cust_id,  'id клиента' /*выбираем колонку cust_id, сами задаём объект 'id клиента'*/
from sql.customer c /*из схемы sql и таблицы customer, задаём алиас таблице — c*/
union all /*оператор присоединения*/
select t.truck_id,  'id грузовика' /*выбираем колонку truck_id, сами задаём объект 'id грузовика'*/
from sql.truck t /*из схемы sql и таблицы truck, задаём алиас таблице — t*/
order by 1 /*сортировка по первому столбцу*/

--Вместо результата вы получите сообщение об ошибке: "ERROR: UNION types integer and text cannot be matched".
--Дело в том, что мы попытались объединить числовой и строковый типы в одной колонке, а это невозможно.
--To fix: city_id::text.
select c.city_id /*выбираем столбец city_id*/
from sql.city c /*из схемы sql  и таблицы city, задаём таблице алиас с*/
union all /*оператор присоединения*/
select cc.city_name /*выбираем столбец city_name*/
from sql.city cc /*из схемы sql и таблицы city, задаём таблице алиас сс*/

select c.city_id::text /*выбираем столбец city_id, переводим city_id из числового в текстовый формат*/
from sql.city c /*из схемы sql  и таблицы city, задаём таблице алиас с*/
union all /*оператор присоединения*/
select cc.city_name /*выбираем столбец city_name*/
from sql.city cc /*из схемы sql и таблицы city, задаём таблице алиас сс*/

select d.phone::text contact, d.first_name, 'phone' contact_type from sql.driver as d
union
select d.zip_code::text, d.first_name, 'zip' from sql.driver as d
order by 1, 2 asc

--Попробуем вывести обобщённые данные о населении по всем городам, с детализацией до конкретного города.
select c.city_name,
       c.population /*выбираем столбцы city_name, population*/
from sql.city c /*из схемы sql и таблицы city, задаём таблице алиас с*/
union all /*оператор присоединения*/
select 'Total',
       sum(c.population) /*сами задаём объект ‘total’, суммируем все значения столбца population*/
from sql.city c /*из схемы sql и таблицы city, задаём таблице алиас с*/
order by 2 desc /*сортируем по второму столбцу в убывающем порядке (чтобы итоговая сумма была в начале)*/

--Напишите запрос, который выводит общее число доставок total_shipments, а также количество доставок в каждый день.
--Необходимые столбцы: date_period, cnt_shipping.
--Не забывайте о единой типизации.
--Упорядочьте по убыванию столбца date_period.
select s.ship_date::text date_period, count(s.ship_id) cnt_shipping
from sql.shipment s
group by s.ship_date
union all
select 'total_shipments', count(s.ship_id)
from sql.shipment s
order by date_period desc

--Например, с помощью UNION можно отобразить, у кого из водителей заполнен столбец с номером телефона.
select d.first_name,
       d.last_name,
       'телефон заполнен' phone_info /*выбираем столбцы first_name, last_name, сами выводим объект ‘телефон заполнен’*/
from sql.driver d /*из схемы sql и таблицы driver, задаём алиас d*/
where d.phone is not null /*условие, что телефон заполнен*/
union /*оператор присоединения (уникальные значения)*/
select d.first_name,
       d.last_name,
       'телефон не заполнен' phone_info /*выбираем столбцы first_name, last_name, сами выводим объект ‘телефон не заполнен’*/
from sql.driver d /*из схемы sql и таблицы driver, задаём алиас d*/
where d.phone is null /*условие, что телефон не заполнен*/

--Напишите запрос, который выведет все города и штаты, в которых они расположены,
--а также информацию о том, была ли осуществлена доставка в этот город:
--если в город была осуществлена доставка, то выводим 'доставка осуществлялась';
--если нет — выводим 'доставка не осуществлялась'.
--Столбцы к выводу: city_name, state, shipping_status.
--Отсортируйте в алфавитном порядке по городу, а затем — по штату.
select c.city_name, c.state, 'доставка не осуществлялась' shipping_status from sql.city c
full outer join sql.shipment s on s.city_id = c.city_id
where s.ship_id is null
union
select c.city_name, c.state, 'доставка осуществлялась' from sql.city c
full outer join sql.shipment s on s.city_id = c.city_id
where s.ship_id is not null
order by 1, 2

--Напишите запрос, который выводит два столбца: city_name и shippings_fake. Выведите города, куда совершались доставки.
--Пусть первый столбец содержит название города, а второй формируется так:
--если в городе было более десяти доставок, вывести количество доставок в этот город как есть;
--иначе — вывести количество доставок, увеличенное на пять.
--Отсортируйте по убыванию получившегося «нечестного» количества доставок, а затем — по имени в алфавитном порядке.
select
    c.city_name as city_name,
    count(s.ship_id) shippings_fake
from
    sql.city c
    join sql.shipment s on s.city_id = c.city_id
group by
    c.city_name
having
    count(s.ship_id) > 10
union
select
    c.city_name as city_name,
    count(s.ship_id)+5 shippings_fake
from
    sql.city c
    join sql.shipment s on s.city_id = c.city_id
group by
    c.city_name
having
    count(s.ship_id) <= 10
order by
    shippings_fake desc,
    city_name asc

--Составим запрос, который позволит вывести первые три буквы алфавита и их порядковые номера.
select  'a' letter,'1' ordinal_position /*сами задаём значение первого столбца ‘a’ и алиас для него letter, значение второго столбца ‘1’ и алиас для него ordinal_position*/
union /*оператор присоединения*/
select 'b','2' /*сами задаём значение первого столбца ‘b’, значение второго столбца ‘2’ */
union /*оператор присоединения*/
select 'c','3' /*сами задаём значение первого столбца ‘с’, значение второго столбца ‘3’*/

--Напишите запрос, который выберет наибольшее из значений:
-- 1000000;
-- 541;
-- -500;
-- 100.
select 1000000 number
union
select 541
union
select -500
union
select 100
order by 1 desc
limit 1

--Предположим, нам нужно узнать, в какие города осуществлялась доставка, за исключением тех, в которых проживают водители.
select c.city_name /*выбираем столбец city_name*/
from sql.shipment s /*из схемы sql и таблицы shipment, задаём таблице алиас s*/
join sql.city c on s.city_id = c.city_id /*внутреннее присоединение из схемы sql таблицы city, задав ей алиас c, по ключам city_id*/
except /*оператор присоединения*/
select cc.city_name  /*выбираем столбец city_name*/
from sql.driver d /*из схемы sql и таблицы driver, задаём таблице алиас d*/
join sql.city cc on d.city_id=cc.city_id /*внутреннее присоединение из схемы sql таблицы city, задав ей алияс cc, по ключам city_id*/
order by 1 /*сортировка по первому столбцу*/

--Выведите список zip-кодов, которые есть в таблице sql.driver, но отсутствуют в таблице sql.customer.
--Отсортируйте по возрастанию, столбец к выводу — zip.
--В поле ниже введите запрос, с помощью которого вы решили эту задачу.
select d.zip_code from sql.driver d
except
select c.zip from sql.customer c
order by 1 asc

--Предположим, нам надо вывести совпадающие по названию города и штаты.
select c.city_name object_name /*выбираем столбец city_name, задаём ему алиас object_name*/
from sql.city c /*из схемы sql и таблицы city, задаём таблице алиас с*/
intersect /*оператор присоединения*/
select cc.state /*выбираем столбец state*/
from sql.city cc /*из схемы sql и таблицы city, задаём таблице алиас с*/
order by 1

--Напишите запрос, который выведет список id городов, в которых есть и клиенты, и доставки, и водители.
select c.city_id from sql.city c
intersect
select cc.city_id from sql.customer cc
intersect
select d.city_id from sql.driver d
intersect
select s.city_id from sql.shipment s

--Выведите zip-код, который есть как в таблице с клиентами, так и в таблице с водителями.
select c.zip from sql.customer c
intersect
select d.zip_code from sql.driver d

--Выведите города с максимальным и минимальным весом единичной доставки.
--Столбцы к выводу — city_name, weight.
(select c.city_name city_name, s.weight weight from sql.city c
join sql.shipment s on s.city_id = c.city_id
order by weight asc
limit 1 )
union
(select c.city_name, s.weight from sql.city c
join sql.shipment s on s.city_id = c.city_id
order by weight desc
limit 1)
order by weight desc

--Выведите идентификационные номера клиентов (cust_id), которые совпадают с идентификационными номерами доставок (ship_id).
--Столбец к выводу — mutual_id.
--Отсортируйте по возрастанию.
select c.cust_id mutual_id from sql.customer c
intersect
select s.ship_id from sql.shipment s
order by mutual_id asc

--Создайте справочник, содержащий уникальные имена клиентов, которые являются производителями
--(cust_type='manufacturer'), и производителей грузовиков, а также описание объекта — 'КЛИЕНТ' или 'ГРУЗОВИК'.
--Столбцы к выводу — object_name, object_description.
--Отсортируйте по названию в алфавитном порядке.
select c.cust_name object_name, 'КЛИЕНТ' object_description from sql.customer c
where c.cust_type='manufacturer'
union
select t.make, 'ГРУЗОВИК' from sql.truck t
order by object_name asc
