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

--/////////////////////////////////////////////////////////////////////////////////////////

SELECT product_nm,
       open_dt
FROM tinkoff.customers c
WHERE open_dt >= '2020-10-05'
;

SELECT *
FROM tinkoff.calls
WHERE start_dttm >= '2020-10-05'
;

WITH customer AS (SELECT customer_id,
    last_nm,
    first_nm,
    middle_nm,
    open_dt,
    product_nm
  FROM tinkoff.customers c
  WHERE open_dt >= '2020-10-05'),

calls AS (
  SELECT start_dttm
  FROM tinkoff.calls
  WHERE start_dttm >= '2020-10-05'
)
SELECT *
FROM customer,
    calls
WHERE open_dt = start_dttm
;

WITH customer AS (SELECT customer_id,
    last_nm,
    first_nm,
    middle_nm,
    open_dt,
    product_nm
  FROM tinkoff.customers c
  WHERE open_dt >= '2020-10-05'),

cal AS (
  SELECT start_dttm,
        customer_id
  FROM tinkoff.calls cl
  WHERE start_dttm >= '2020-10-05'
)
SELECT *
   FROM customer
   LEFT JOIN cal
ON customer.customer_id = cal.customer_id
;

WITH customer AS (SELECT customer_id,
    last_nm,
    first_nm,
    middle_nm,
    open_dt,
    product_nm
  FROM tinkoff.customers c
  WHERE open_dt >= '2020-10-05'),

cal AS (
  SELECT start_dttm,
        customer_id
  FROM tinkoff.calls cl
  WHERE start_dttm >= '2020-10-05'
)
SELECT *
   FROM customer
   LEFT JOIN cal
ON  cal.start_dttm = customer.open_dt
WHERE cal.start_dttm = customer.open_dt
ORDER by customer.open_dt
;


SELECT *,
  ROW_NUMBER() OVER(PARTITION BY open_dt ORDER by customer_id)
FROM tinkoff.customers
WHERE open_dt >= '2020-10-05'
;


WITH cust as
  (SELECT customer_id,
    last_nm,
    first_nm,
    middle_nm,
    open_dt as date,
    product_nm,
    ROW_NUMBER() OVER(PARTITION BY open_dt ORDER by open_dt, customer_id)
    FROM tinkoff.customers
    WHERE open_dt >= '2020-10-05'),
cals AS (
  SELECT start_dttm,
        customer_id
  FROM tinkoff.calls cl
  WHERE start_dttm >= '2020-10-05'
)
SELECT *
FROM cust
LEFT JOIN cals
-- on cals.customer_id = cust.customer_id
on cals.start_dttm = cust.date
-- WHERE cals.start_dttm = cust.date
;


--**********************************************************
WITH cust as
  (SELECT customer_id,
    last_nm,
    first_nm,
    middle_nm,
    open_dt,
    product_nm,
    ROW_NUMBER() OVER(PARTITION BY open_dt ORDER by open_dt, customer_id)
    FROM tinkoff.customers
    WHERE open_dt >= '2020-10-05'),
cals AS (
  SELECT start_dttm as date,
        customer_id
  FROM tinkoff.calls cl
  WHERE start_dttm >= '2020-10-05'
)
SELECT cust.last_nm,
    cust.first_nm,
    cust.middle_nm,
    cals.date,
    cust.open_dt,
    cust.product_nm
FROM cust
LEFT JOIN cals
on cals.customer_id = cust.customer_id
WHERE cals.date = cust.open_dt
ORDER BY cust.open_dt
;


WITH customer AS (SELECT customer_id,
    last_nm,
    first_nm,
    middle_nm,
    open_dt,
    product_nm
  FROM tinkoff.customers c
  WHERE open_dt >= '2020-10-05'),

cal AS (
  SELECT start_dttm,
        customer_id
  FROM tinkoff.calls cl
  WHERE start_dttm >= '2020-10-05'
)
SELECT *
   FROM customer
   LEFT JOIN cal
ON  cal.customer_id = customer.customer_id
WHERE cal.start_dttm = customer.open_dt
ORDER by customer.open_dt
;

SELECT cs.last_nm,
    cs.first_nm,
    cs.middle_nm,
    cl.start_dttm as date,
    cs.open_dt,
   cs.product_nm
FROM tinkoff.calls cl
LEFT JOIN tinkoff.customers cs
on cl.customer_id = cs.customer_id
WHERE cl.start_dttm >= '2020-10-05' and cl.start_dttm = cs.open_dt
ORDER BY date
;



SELECT *
FROM tinkoff.account_statuses ac
;

SELECT to_char(ac.date, 'MM') as month
FROM tinkoff.account_statuses ac
;

SELECT *
FROM tinkoff.account_statuses ac
WHERE ac.acount_status IN ('новый', 'активирован', 'утилизирован') AND to_char(ac.date, 'MM') = '05'
;

SELECT to_char(ac.date, 'MM') as month,
  COUNT(to_char(ac.date, 'MM'))
  FROM tinkoff.account_statuses ac
  WHERE ac.acount_status IN ('новый', 'активирован', 'утилизирован')
  GROUP BY month
ORDER BY month
;

WITH
work as
(SELECT
   to_char(ac.date, 'MM') as month,
  COUNT(to_char(ac.date, 'MM')) as cntw
  FROM tinkoff.account_statuses ac
  WHERE ac.acount_status IN ('новый', 'активирован', 'утилизирован')
  GROUP BY month
ORDER BY month),
non_work AS
(SELECT
   to_char(ac.date, 'MM') as month,
  COUNT(to_char(ac.date, 'MM')) as cntnw
  FROM tinkoff.account_statuses ac
  WHERE ac.acount_status IN ('заблокирован', 'закрыт')
  GROUP BY month
ORDER BY month)
SELECT work.month,
      work.cntw,
      non_work.cntnw
FROM work
JOIN non_work
ON work.month = non_work.month
;