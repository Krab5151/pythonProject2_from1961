-- Найти ID с самым большим количеством заказов по годам
'1 Создаём подзапрос sq_1 ( derived table )  ->  year / an_id / cnt' ||
'2 Макс значения an_id фильтруем WHERE cnt ' ||
'3 В фильтре WHERE cnt, извлекаем сгруппированные года из подзапроса sq_1 -> HAVING to_char(ord_datetime, ''YYYY'') = sq_1.year '
SELECT *
FROM
  (SELECT to_char(ord_datetime, 'YYYY') as year, an_id, COUNT(ord_an) as cnt
  FROM analysis a
  RIGHT JOIN orders o
  ON an_id = ord_an
  GROUP BY an_id, year
  ORDER BY year) as sq_1
  WHERE cnt =
    (
      SELECT MAX(cnt)
      FROM (
        SELECT to_char(ord_datetime, 'YYYY') as year, COUNT(ord_an) as cnt
        FROM analysis a
        RIGHT JOIN orders o
        ON an_id = ord_an
        GROUP BY an_id, to_char(ord_datetime, 'YYYY')
        HAVING to_char(ord_datetime, 'YYYY') = sq_1.year
           ) as sq_2
    )
;

'/////////////////////////////////////////////'

--Рабочий
--С использованием оконной функции
'
Объяснение:
RANK() - Ранжирует Только аргумент из ORDER BY и Выполняется в Последнюю очередь
--Используется для ранжирования строк в каждой группе (по годам).
--Параметр PARTITION BY to_char(ord_datetime, ''YYYY'') делит данные на группы по годам.
--ORDER BY COUNT(ord_an) DESC упорядочивает строки по убыванию cnt в каждой группе.
WHERE rnk = 1: Так Сортировка по Убыванию, то ранжир № 1 соответствует максимальному значению COUNT(ord_an)' ||
'Оставляет только строки с максимальным значением cnt в каждом году.
ORDER BY year: Упорядочивает итоговые строки по годам.
'
SELECT year, an_id, cnt
FROM (
    SELECT
        to_char(ord_datetime, 'YYYY') AS year,
        an_id,
        COUNT(ord_an) AS cnt,
        RANK() OVER (PARTITION BY to_char(ord_datetime, 'YYYY') ORDER BY COUNT(ord_an) DESC) AS rnk
    FROM analysis a
    RIGHT JOIN orders o
    ON an_id = ord_an
    GROUP BY an_id, to_char(ord_datetime, 'YYYY')
) ranked
WHERE rnk = 1
ORDER BY year;

-- Рабочий
-- С использованием подзапроса
SELECT year, an_id, cnt
FROM (
    SELECT
        to_char(ord_datetime, 'YYYY') AS year,
        an_id,
        COUNT(ord_an) AS cnt
    FROM analysis a
    RIGHT JOIN orders o
    ON an_id = ord_an
    GROUP BY an_id, to_char(ord_datetime, 'YYYY')
) grouped
WHERE cnt = (
    SELECT MAX(cnt)
    FROM (
        SELECT
            to_char(ord_datetime, 'YYYY') AS year,
            COUNT(ord_an) AS cnt
        FROM analysis a
        RIGHT JOIN orders o
        ON an_id = ord_an
        GROUP BY to_char(ord_datetime, 'YYYY'), an_id
        HAVING to_char(ord_datetime, 'YYYY') = grouped.year
    ) yearly_max
)
ORDER BY year;



-- Исправленный вариант
WITH
  sq_1 AS (
    SELECT to_char(ord_datetime, 'YYYY') as year, an_id, COUNT(ord_an) as cnt
    FROM analysis a
    RIGHT JOIN orders o
    ON an_id = ord_an
    GROUP BY an_id, to_char(ord_datetime, 'YYYY')
  ),
  sq_2 AS (
    SELECT year, MAX(cnt) AS max_cnt
    FROM sq_1
    GROUP BY year
  )
SELECT sq_1.year, sq_1.an_id, sq_1.cnt
FROM sq_1
JOIN sq_2
ON sq_1.year = sq_2.year AND sq_1.cnt = sq_2.max_cnt
ORDER BY sq_1.year;

--////////////////////////////////////////////////////////////////////

WITH ranked_orders AS (
    SELECT
        to_char(ord_datetime, 'YYYY') as year,
        ord_an,
        RANK() OVER(PARTITION BY to_char(ord_datetime, 'YYYY')
        ORDER BY COUNT(ord_id) DESC ) as rnk
    FROM orders
    GROUP BY to_char(ord_datetime, 'YYYY'), ord_an
)
SELECT ranked_orders.year, ranked_orders.rnk
FROM  ranked_orders
WHERE rnk = 1;

--/////////////////////////////////////////////////////////////////////////////////////////

WITH
table_work as
(SELECT
   to_char(ac.date, 'MM')::FLOAT as month,
  COUNT(to_char(ac.date, 'MM')::FLOAT) as working
  FROM tinkoff.account_statuses ac
  WHERE ac.acount_status IN ('новый', 'активирован', 'утилизирован')
  GROUP BY month
ORDER BY month),
table_non_work AS
(SELECT
   to_char(ac.date, 'MM')::FLOAT as month,
  COUNT (to_char(ac.date, 'MM')::FLOAT) as non_working
  FROM tinkoff.account_statuses ac
  WHERE ac.acount_status IN ('заблокирован', 'закрыт')
  GROUP BY month
ORDER BY month)
SELECT table_work.month,
      table_work.working,
      table_non_work.non_working
FROM table_work
JOIN table_non_work
ON table_work.month = table_non_work.month
;

--////////////////////////////////////////////////////////////////////////////////////

--Нарастающим итогом рассчитать,
-- как увеличивалось количество проданных тестов каждый месяц каждого года
-- с разбивкой по группе.
-- По требованию последний столбец sum переопределён в INT
with t1 as
    (SELECT
        to_char(ord_datetime, 'YYYY') AS year,
        to_char(ord_datetime, 'MM') AS month,
        an_group,
        COUNT(ord_an)
        OVER (PARTITION BY an_group, to_char(ord_datetime, 'YYYY-MM') ORDER BY ord_datetime) AS smu_ord_an
    FROM orders
    JOIN analysis
    ON orders.ord_an = analysis.an_id),
  t2 as
    (SELECT year, month, an_group, MAX(smu_ord_an) as max_sum
      FROM t1
      GROUP BY year, month, an_group
      ORDER BY an_group, year, month)
SELECT year, month, an_group as group,
    sum(max_sum) OVER(PARTITION BY an_group, year ORDER BY month) :: int as sum
FROM t2
;

WITH t1 as(
  SELECT name,
         seat,
         LEAD(name) OVER() as ld
  FROM students
  where seat % 2 != 0
),
t2 as (
       SELECT name,
         seat,
         LAG(name) OVER() as lg
  FROM students
  where seat % 2 = 0
)


SELECT  t1.name as odd,
        t2.name as even
FROM t1
CROSS JOIN t2
WHERE t1.seat + 1 = t2.seat
;




WITH t1 as(
  SELECT name,
         seat,
         LEAD(name) OVER() as ld
  FROM students
  where seat % 2 != 0
),
t2 as (
       SELECT name,
         seat,
         LAG(name) OVER() as lg
  FROM students
  where seat % 2 = 0
)
SELECT
t1.seat as st1,
t1.name as odd,
t2.seat as st2,
        t2.name as even
FROM t1
CROSS JOIN t2
WHERE t1.seat + 1 = t2.seat
;