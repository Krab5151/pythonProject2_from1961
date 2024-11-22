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




--Пример с подзапросом
    SELECT *
FROM (
    SELECT to_char(ord_datetime, 'YYYY') AS year, an_id, COUNT(ord_an) AS cnt
    FROM analysis a
    RIGHT JOIN orders o
    ON an_id = ord_an
    GROUP BY an_id, year
    ORDER BY year
) subquery
WHERE cnt = 50;


--Пример с СТЕ
--WITH (Common Table Expressions, CTE)
WITH analysis_results AS (
    SELECT to_char(ord_datetime, 'YYYY') AS year, an_id, COUNT(ord_an) AS cnt
    FROM analysis a
    RIGHT JOIN orders o
    ON an_id = ord_an
    GROUP BY an_id, year
    ORDER BY year
)
SELECT *
FROM analysis_results
WHERE cnt = 10; -- Замените 10 на нужное значение

--------------------------------
 WITH  sq_1 AS(
   SELECT to_char(ord_datetime, 'YYYY') as year, an_id, COUNT(ord_an) as cnt
    FROM analysis a
    RIGHT JOIN orders o
    ON an_id = ord_an
    GROUP BY an_id, year
    ORDER BY year
 ),
 sq_2 AS(
 SELECT MAX(cnt)
      FROM  (
        SELECT to_char(ord_datetime, 'YYYY') as year, COUNT(ord_an) as cnt
        FROM analysis a
        RIGHT JOIN orders o
        ON an_id = ord_an
        GROUP BY an_id, to_char(ord_datetime, 'YYYY')
        HAVING to_char(ord_datetime, 'YYYY') = sq_1.year )
 ) AS sq_3
 SELECT *
   FROM sq_2
 ;
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
'////////////////////////////////////'

 WITH  sq_1 AS(
   SELECT to_char(ord_datetime, 'YYYY') as year, an_id, COUNT(ord_an) as cnt
    FROM analysis a
    RIGHT JOIN orders o
    ON an_id = ord_an
    GROUP BY an_id, year
    ORDER BY year
 ),
 sq_2 AS(
      SELECT MAX(cnt)
      FROM sq_1
 )
 SELECT *
 FROM sq_2
;

--//////////////////////////////////////////////////////
--/////////////////////////////////////////////////////
SELECT res.year, res.an_id, res.cnt, RANK() OVER(PARTITION BY res.year ORDER BY res.cnt DESC) as rnk
FROM
  (SELECT to_char(ord_datetime, 'YYYY') as year,
        an_id,
        COUNT(an_id) as cnt
  from orders o
  left JOIN analysis a
  ON an_id = ord_an
  GROUP BY to_char(ord_datetime, 'YYYY'), an_id
  ORDER BY to_char(ord_datetime, 'YYYY')
  ) as res
;

SELECT res.year, res.an_id, res.cnt, RANK() OVER(PARTITION BY res.year ORDER BY res.cnt DESC) as rnk
FROM
  (SELECT to_char(ord_datetime, 'YYYY') as year,
        an_id,
        COUNT(an_id) as cnt
  from orders o
  left JOIN analysis a
  ON an_id = ord_an
  GROUP BY to_char(ord_datetime, 'YYYY'), an_id
  ORDER BY to_char(ord_datetime, 'YYYY')
  ) as res
;

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