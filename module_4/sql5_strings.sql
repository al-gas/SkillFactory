--Конструкции с оператором соединения строк записываются следующим образом:
--строка1 || строка2 || ... || строкаN
--Напишем запрос, который позволит подготовить простые select-запросы для всех таблиц из схемы.
select 'select * from '||t.table_schema||'.'||t.table_name||';' query
from information_schema.tables t
where table_schema = 'shipping'

--Составим текстовый шаблон сообщения о доставке по конкретному водителю для наших клиентов.
--Напишите SQL-запрос, который выведет следующее сообщение для каждого водителя по форме:
--Ваш заказ доставит водитель #Имя Фамилия#. Его контактный номер: #Номер#, где #Имя Фамилия# и #Номер# взяты из справочника водителей.
--Если номер не указан, то выведите прочерк (-). Для номеров рекомендуем использовать coalesce.
--Пример из таблицы для наглядности:
--Ваш заказ доставит водитель Adel Al-Alawi. Его контактный номер: (901) 947-4433
--Столбец к выдаче — msg (текст сообщения).
select
    'Ваш заказ доставит водитель '||d.first_name||' '||d.last_name||'. Его контактный номер: '||d.phone msg
from sql.driver d
where d.phone is not null
union
select
    'Ваш заказ доставит водитель ' ||
    d.first_name || ' ' ||
    d.last_name ||'. Его контактный номер: -' msg
from sql.driver d
where d.phone is null
order by msg asc

select
        'Ваш заказ доставит водитель '||d.first_name||' '||d.last_name||'. '||'Его контактный номер: '||coalesce(d.phone,'-') msg
from shipping.driver d
order by msg asc

--Cоставим справочник названий клиентов, у которых более десяти доставок. Данные сохраним в нижнем регистре,
--чтобы передавать их в другие системы (например, для обзвона), которые не чувствительны к регистру.
--Напишите запрос, который выводит все id названий клиентов, у которых более десяти доставок, в нижнем регистре.
--Отсортируйте результат по cust_id в порядке возрастания.
--Столбцы в выдаче: cust_id (id клиента) и cust_name (название клиента в нижнем регистре).
select * from shipping.customer c
select
    c.cust_id,
    lower(c.cust_name) cust_name
from shipping.customer c
join shipping.shipment s on s.cust_id = c.cust_id
group by c.cust_id, cust_name
having count(s.ship_id) > 10
order by cust_id

select replace('малако','а','о')
--Сделаем из слова «машина» слово «матрас».
select replace('машина','шина','трас')
--Например, сделаем из строки "Hello, world!" строку "Hello!".
select replace('Hello, world!',', world','')

--Составим справочник utm-меток, для того чтобы передавать город и штат прямо в адресной строке.
--(Если вы не знаете, что такое utm-метка, почитайте статью на Вики. К программе курса это не относится, но знать полезно.)
--Напишите SQL-запрос, который выведет список сочетаний из справочника следующего вида: название_штата__название_города,
--где названия штата и города взяты из справочника городов и переведены в нижний регистр.
--Столбец к выдаче — utm (форматированный штат-город).
--Отсортируйте полученный справочник по алфавиту.
--Обратите внимание! Все пробелы в названиях городов и штатов замените символом '_' (одно нижнее подчёркивание),
--а для разделения названий города и штата используйте '__' (два последовательных нижних подчёркивания).
--Пример из таблицы для наглядности: new_jersey__union_city
select
    lower(replace(c.state, ' ', '_'))||'__'||lower(replace(c.city_name, ' ', '_')) utm
from shipping.city c
order by utm asc

--Функции left(string,n) и right(string,n) отрезают n левых или правых символов от строки, поданной на вход.
--Давайте разобьём строку 'Один два три' на слова, используя эти функции.
with t as
(
select 'Один два три'::text sample_string
)
select
 left(t.sample_string,4) one, /*берём 4 левых символа строки*/
 right(left(t.sample_string,8),3) two, /*берём 8 левых символов строки, потом 3 правых от результата*/
 right(t.sample_string,3) three /*берём 3 правых символа от строки*/
from t

--Пример:
select left('0123456789', - 2), right('0123456789', - 2)
--Результат: 01234567 и 23456789 (в первом случае — восемь символов с «отрезанными» 89 и во втором случае — восемь символов с «отрезанными» 01)

--Представим, что к вам пришёл разработчик, который хочет сократить поле state в таблице city до четырёх символов,
--и попросил проверить, останутся ли значения в нём уникальными.
--Чтобы ответить на этот вопрос, напишите SQL-запрос, который выведет первые четыре символа названия штата,
--и количество уникальных названий штатов, которому они соответствуют. Оставьте только те, которые относятся к двум и более штатам.
--Добавьте сортировку по первому столбцу.
--Столбцы в выдаче: code (четыре первых буквы штата), qty (количество уникальных названий штата, начинаюшихся на эти буквы).
with d_state as (select distinct c.state state from shipping.city c)
select
    left(d_state.state, 4) as code,
    count(d_state.state) qty
from d_state
group by code
having count(d_state.state) > 1
order by 1

--Provided by Skillfactory
select
    left(c.state,4) code,
    count(distinct c.state) qty
from shipping.city c
group by 1
having count(distinct state)>1
order by code

--Допустим, у нас есть шаблон "Hello, #Имя пользователя#!" и таблица водителей, которым нужно вывести приветствие.
--Через конкатенацию это можно сделать следующим образом:
select 'Hello, ' || d.first_name || '!' hello from shipping.driver d
--Но если нужно подставить и имя, и фамилию, то соединений становится слишком много и сам шаблон становится трудночитаемым.
--Вот тут и приходит на помощь функция format().
--Синтаксис функции выглядит следующим образом:
--format(formatstr text [, argument1 text,argument2 text...])
--где formatstr — это шаблон, который мы передаём. Это обычная строка, в которой указаны места для подстановки аргумента.
--Вернёмся к задаче с приветствием водителя.
select format('Hello, %s %s!', d.first_name, d.last_name) hello from shipping.driver d

--Напишем запрос, который описывает содержимое каждой строки в таблице в виде текста.
select format('driver_id = %s, first_name = %s, last_name = %s, address = %s, zip_code = %s, phone = %s, city_id = %s',
              driver_id, first_name, last_name, address, zip_code, phone, city_id)
from shipping.driver d
--Мы перечислили в строке семь пропусков (плэйсхолдеров, или мест для подстановки, — %s),
--передали семь параметров (все столбцы таблицы) и получили шаблон, заполненный значениями для каждой строки.
--Если в вашем шаблоне присутствует одинарная кавычка, то для удобства можно вместо одинарных кавычек использовать $$ (два знака доллара):
select $$ some_string with quotes ' $$

';
--Давайте подготовим географическую сводку для каждого города.
--Напишите SQL-запрос, который выведет описание региона в следующем формате: [city_name] is located in [state].
--There's [population] people living there. Its area is [area] (обратите внимание, точку в конце ставить не нужно).
--Отсортируйте по названию города в алфавитном порядке.
--Столбец к выдаче — str (сводка).
--Пример: Abilene is located in Texas. There's 115930 people living there. Its area is 105.10
select
    format($$%s is located in %s. There's %s people living there. Its area is %s$$,
    c.city_name, c.state, c.population, c.area)
from shipping.city c
order by c.city_name asc