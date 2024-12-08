import psycopg2


# Подключение к базе данных
conn = psycopg2.connect(
    dbname="Eduson",  # имя базы данных
    user="student",  # ваш логин
    # password="qweasd1234567890",  # ваш пароль
    password="QweAsd1234567890",  # ваш пароль
    host="185.86.147.205",  # хост, например, localhost
    port="5432"  # порт, стандартный для PostgreSQL
)

# Создаем курсор для выполнения SQL запросов
cur = conn.cursor()

cur.execute("SELECT * FROM shippers")
print(cur.fetchall())
