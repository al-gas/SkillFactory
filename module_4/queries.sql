# Задание 4.1
# База данных содержит список аэропортов практически всех крупных городов России. В большинстве городов есть только один аэропорт. 
# Исключение составляет: Moscow, Ulyanovsk верно
SELECT city
FROM dst_project.airports
GROUP BY city
HAVING count(airport_name)>1
ORDER BY city ASC;

# Задание 4.2
# Вопрос 1. Таблица рейсов содержит всю информацию о прошлых, текущих и запланированных рейсах.
# Сколько всего статусов для рейсов определено в таблице? - 6
SELECT count(distinct status)
FROM dst_project.flights;
