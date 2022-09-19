SELECT * FROM hh.candidate
SELECT * FROM hh.city
SELECT * FROM hh.candidate_timetable_type;
SELECT * FROM hh.timetable_type

--2.1
--Рассчитайте максимальный возраст (max_age) кандидата в таблице.
SELECT max(cnd.age) max_age FROM hh.candidate cnd;
--ответ: 100

--2.2
--Теперь давайте рассчитаем минимальный возраст (min_age) кандидата в таблице.
SELECT min(cnd.age) min_age FROM hh.candidate cnd;
--ответ: 14

--2.3
--Попробуем «почистить» данные.
--Напишите запрос, который позволит посчитать для каждого возраста (age) сколько (cnt) человек этого возраста у нас есть.
--Отсортируйте результат по возрасту в обратном порядке.
SELECT
    cnd.age age,
    count(cnd.age) cnt
FROM hh.candidate cnd
GROUP BY cnd.age
ORDER BY cnd.age DESC;

--2.4
--По данным Росстата, средний возраст занятых в экономике России составляет 39.7 лет. Мы округлим это значение до 40.
--Найдите количество кандидатов, которые старше данного возраста. Не забудьте отфильтровать «ошибочный» возраст 100.
SELECT
    count(cnd.gender) total
FROM hh.candidate cnd
WHERE cnd.age > 40 AND cnd.age < 100;
--ответ: 6263

--3.1
--Для начала напишите запрос, который позволит узнать, сколько (cnt) у нас кандидатов из каждого города (city).
--Формат выборки: city, cnt.
--Группировку таблицы необходимо провести по столбцу title, результат отсортируйте по количеству в обратном порядке.
SELECT
    ct.title city,           /* Добываем название города из таблицы Городов */
    count(cnd.city_id) cnt   /* Считаем количество кандидатов в каждой группировке (не баднитской) */
FROM hh.candidate cnd        /* Работаем с таблицей кандидатов... */
JOIN hh.city ct ON ct.id = cnd.city_id /* .. соединённой с таблицей городов по ID города */
GROUP BY city                /* группируем результат выборки по городу */
ORDER BY cnt DESC;           /* сортируем по количеству в обратном порядке */
--ответ:

--3.2
--Москва бросается в глаза как, пожалуй, самый активный рынок труда.
--Напишите запрос, который позволит понять, каких кандидатов из Москвы устроит «проектная работа».
--Формат выборки: gender, age, desirable_occupation, city, employment_type.
--Отсортируйте результат по id кандидата.
SELECT
    cnd.gender gender,                  /* Пол кандидата */
    cnd.age age,                        /* Возраст */
    cnd.desirable_occupation desirable_occupation, /* Хотебельная должность */
    ct.title city,                      /* Добываем название города из таблицы Городов */
    cnd.employment_type employment_type /* Вид занятости, которая устраивает кандидита  */
FROM hh.candidate cnd                   /* Работаем с таблицей кандидатов... */
JOIN hh.city ct ON ct.id = cnd.city_id  /* .. соединённой с таблицей городов по ID города */
WHERE                                   /* Условия отбора кандидатов */
    cnd.employment_type like '%проектная работа%'  /* Вид занятости включает в себя «проектную работу» */
    AND
    ct.title = 'Москва'                 /* .. в Москве */
ORDER BY cnd.id ASC;                    /* сортируем по ID кандидата в порядке возрастания */

--3.3
--Данных оказалось многовато. Отфильтруйте только самые популярные IT-профессии — разработчик, аналитик, программист.
--Обратите внимание, что данные названия могут быть написаны как с большой, так и с маленькой буквы.
--Отсортируйте результат по id кандидата.
SELECT
    cnd.gender gender,                  /* Пол кандидата */
    cnd.age age,                        /* Возраст */
    cnd.desirable_occupation desirable_occupation, /* Хотебельная должность */
    ct.title city,                      /* Добываем название города из таблицы Городов */
    cnd.employment_type employment_type /* Вид занятости, которая устраивает кандидита  */
FROM hh.candidate cnd                   /* Работаем с таблицей кандидатов... */
JOIN hh.city ct ON ct.id = cnd.city_id  /* .. соединённой с таблицей городов по ID города */
WHERE                                   /* Условия отбора кандидатов */
    cnd.employment_type like '%проектная работа%'  /* Вид занятости включает в себя «проектную работу» */
    AND
    ct.title = 'Москва'                 /* .. в Москве */
    AND (                               /* .. и желательная должность.. */
        lower(cnd.desirable_occupation) like '%разработчик%' /* .. разработчик */
        OR                                                   /* или */
        lower(cnd.desirable_occupation) like '%аналитик%'    /* .. аналитик */
        OR                                                   /* или */
        lower(cnd.desirable_occupation) like '%программист%' /* .. программист */
    )
ORDER BY cnd.id ASC;                    /* сортируем по ID кандидата в порядке возрастания */

--3.4
--Для общей информации попробуйте выбрать номера и города кандидатов, у которых занимаемая должность совпадает с желаемой.
--Формат выборки: id, city.
--Отсортируйте результат по городу и id кандидата.
SELECT
    cnd.id id,                          /* ID кандидита */
    ct.title city                       /* Добываем название города из таблицы Городов */
FROM hh.candidate cnd                   /* Работаем с таблицей кандидатов... */
JOIN hh.city ct ON ct.id = cnd.city_id  /* .. соединённой с таблицей городов по ID города */
WHERE                                   /* Условия отбора кандидатов */
    cnd.current_occupation = cnd.desirable_occupation /* занимаемая должность совпадает с желаемой */
GROUP BY ct.title, cnd.id;              /* группируем результат выборки по городу и потом по ID кандидита */

--3.5
--Определите количество кандидатов пенсионного возраста.
--Пенсионный возраст для мужчин наступает в 65 лет, для женщин — в 60 лет.
SELECT
    count(cnd.age)                      /* Считаем количество кандидитов (по колонке Возраст) */
FROM hh.candidate cnd                   /* Работаем с таблицей кандидатов... */
WHERE                                   /* Условия отбора кандидатов */
    (cnd.age BETWEEN 65 AND 99 AND cnd.gender = 'M')  /* Если мужчина, то 65 или старше, и младше 100 */
    OR
    (cnd.age BETWEEN 60 AND 99 AND cnd.gender = 'F'); /* Если женщина, то 60 или старше, и младше 100 */

--4.1
--Для добывающей компании нам необходимо подобрать кандидатов из Новосибирска, Омска, Томска и Тюмени, которые готовы работать вахтовым методом.
--Формат выборки: gender, age, desirable_occupation, city, employment_type, timetable_type.
--Отсортируйте результат по городу и номеру кандидата.
with ttt AS ( /* Временная таблица ttt в которой мы соединяем ID кандидита с расщифровкой рабочего графика кандидита */
    SELECT
        ctt.candidate_id c_id, /* ID кандидата */
        ctt.timetable_id t_id, /* ID рабочего графика */
        tt.title               /* Расшифровка (название) рабочего графика */
    FROM hh.candidate_timetable_type ctt
    JOIN hh.timetable_type tt ON tt.id = ctt.timetable_id
)
SELECT
    cnd.gender gender,                   /* Пол кандидата */
    cnd.age age,                         /* Возраст */
    cnd.desirable_occupation desirable_occupation,  /* Желательная должность */
    ct.title city,                       /* Добываем название города из таблицы Городов */
    cnd.employment_type employment_type, /* Вид занятости, которая устраивает кандидита  */
    ttt.title timetable_type             /* Расшифровка (название) рабочего графика из подзапроса ttt*/
FROM hh.candidate cnd                    /* Работаем с таблицей кандидатов... */
RIGHT JOIN hh.city ct ON ct.id = cnd.city_id /* .. соединённой справа с таблицей городов по ID города */
RIGHT JOIN ttt ON ttt.c_id = cnd.id      /* .. соединённой справа с подзапросом ttt с расшифровкой рабочего графика */
WHERE                                    /* отбираем в конечный результат только тех кандидитов которым... */
    lower(ttt.title) like '%вахтовый метод%' /* подходит работать вахтовым методом */
    AND (                                /* и котрые проживают в городах... */
        ct.title = 'Новосибирск'         /* Новосибирск */
        OR                               /* или */
        ct.title = 'Омск'                /* Омск */
        OR                               /* или */
        ct.title = 'Томск'               /* Томск */
        OR                               /* или */
        ct.title = 'Тюмень'              /* Тюмень */
    )
ORDER BY city ASC, cnd.id ASC;           /* сортируем городам и по ID кандидата в порядке возрастания */

--4.2
--Для заказчиков из Санкт-Петербурга нам необходимо собрать список из 10 желаемых профессий кандидатов из того же города от 16 до 21 года
--(в выборку включается 16 и 21, сортировка производится по возрасту) с указанием их возраста,
--а также добавить строку Total с общим количеством таких кандидатов.
with t10 AS
(
    SELECT
        cnd.desirable_occupation desirable_occupation,
        cnd.age age
    FROM hh.candidate cnd
    JOIN hh.city ct ON ct.id = cnd.city_id
    WHERE
        ct.title = 'Санкт-Петербург'
        AND
        cnd.age BETWEEN 16 AND 21
    ORDER BY age ASC
    limit 10
)
SELECT
    t10.desirable_occupation desirable_occupation,
    t10.age age
FROM t10
UNION ALL
SELECT
    'Total' ,
    count(cnd.id)
FROM hh.candidate cnd
    JOIN hh.city ct ON ct.id = cnd.city_id
    WHERE
        ct.title = 'Санкт-Петербург'
        AND
        cnd.age BETWEEN 16 AND 21


(
SELECT
    cnd.desirable_occupation desirable_occupation, /* Желаемая должность */
    cnd.age age                          /* Возраст кандидата */
FROM hh.candidate cnd                    /* Работаем с таблицей кандидатов... */
JOIN hh.city ct ON ct.id = cnd.city_id   /* .. соединённой с таблицей городов по ID города */
WHERE                                    /* при условии, что ... */
    ct.title = 'Санкт-Петербург'         /* города кандидита Санкт-Петербург */
    AND                                  /* и */
    cnd.age BETWEEN 16 AND 21;           /* возраст кадидата между 16 и 21 включительно */
ORDER BY cnd.age                         /* Сортируем по возрасту кандидата по возрастанию (по умолчанию) */
LIMIT 10                                 /* Выводим только первые 10 строчек от полученного результата */
)
UNION ALL                                /* подсоединяем снизу результат (должна быть одна строчка) */
(
SELECT
    'Total',                             /* Столбец 1: 'Total' */
    COUNT(*)                             /* Столбец 2: Количество кандидитов (строчек в результате) */
FROM hh.candidate cnd                    /* Работаем с таблицей кандидатов... */
JOIN hh.city ct ON ct.id = cnd.city_id   /* .. соединённой с таблицей городов по ID города */
WHERE                                    /* при условии, что ... */
    ct.title = 'Санкт-Петербург'         /* города кандидита Санкт-Петербург */
    AND                                  /* и */
    cnd.age BETWEEN 16 AND 21;           /* возраст кадидата между 16 и 21 включительно */
)