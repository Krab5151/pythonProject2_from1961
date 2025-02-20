import requests


# response = requests.get('https://e-disclosure.ru/portal/company.aspx?id=29792')
# response = requests.get('https://academy-data-science.eduson.tv/ru')
response = requests.get('http://radar.oreilly.com/2010/06/what-is-data-science.html')

print(response.status_code)  # Выводит статус-код ответа
print(response.headers)  # Выводит заголовки ответа
print(response.text)  # Выводит тело ответа в виде текста, если вы хотите получить содержимое веб-страницы, вы можете использовать
