select * from sqlprotest.movies bla

select * from sqlprotest.movie_genres
select * from sqlprotest.genres

--4
--Напишите запрос, который выведет количество фильмов в каждом жанре для случаев, когда в жанре представлено три или больше фильмов.
--Столбцы к выводу ― genre_name (имя жанра) и movies_count (количество фильмов).
--Результат отсортируйте по второму полю по убыванию.
select
    g.name genre_name,
    count(mg.movie_id) movies_count
from sqlprotest.genres g
join sqlprotest.movie_genres mg on mg.genre_id = g.id
group by genre_name
having count(mg.movie_id) > 2
order by 2 desc

--5
(select * from A)
union
(select * from B)

--7
with t as (
select
    mg.movie_id id
from sqlprotest.movie_genres mg
join sqlprotest.genres g on mg.genre_id = g.id
where g.name = 'Криминал'
)
select
    distinct m.*
from
    sqlprotest.movies m
join sqlprotest.movie_genres mg on mg.movie_id = m.id
join sqlprotest.genres g on g.id = mg.genre_id
where m.id not in (select t.id from t)
order by m.name asc

--8
select * from sqlprotest.movies m
where m.rating is not null
order by m.year asc
limit 3

--10
--Напишите запрос, с помощью которого можно вычислить средний рейтинг фильмов в каждом жанре.
--Выведите два столбца: genre_name (название жанра) и average_rating (средний рейтинг).
--Результат отсортируйте по второму полю по убыванию.
select
    g.name genre_name,
    avg(m.rating) average_rating
from
    sqlprotest.genres g
join sqlprotest.movie_genres mg on mg.genre_id = g.id
join sqlprotest.movies m on mg.movie_id = m.id
group by g.name
order by 2 desc

--11
--Напишите запрос, чтобы вывести все названия фильмов и их рейтинги.
--Если рейтинга нет, отобразите 0 для такого фильма. Отсортировать по названию фильма по возрастанию.
select
    m.name,
    m.rating
from sqlprotest.movies m
where m.rating is not null
union
select
    m.name,
    0
from sqlprotest.movies m
where m.rating is null
order by name asc
