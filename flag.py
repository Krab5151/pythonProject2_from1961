"""Флаги в программировании — это переменные
, которые используются для управления логикой выполнения кода. """

""" Управления циклом или логикой выполнения:
флаг может использоваться для выхода из цикла или пропуска выполнения определённого участка кода."""
flag = False  # Стартовый флаг False, сохраняем в переменную flag
for i in range(10):
    if i == 5:
        flag = True  # Устанавливаем флаг, если i равно 5,
    if flag:  # Проверка на истинность, как только переменная flag переопределится в True, выполнится печать
        print(f"Флаг установлен на {i}")

"""Указания состояния программы:
,выполнен какой-то процесс или произошла ли ошибка."""
error_occurred = False

some_condition_fails = 5 ** 2  # Выполнение какого-то кода
if some_condition_fails:
    error_occurred = True

# Проверка флага позже в коде
if error_occurred:
    print("Произошла ошибка!")


"""Активации или деактивации функциональности:
Флаги могут использоваться для включения или выключения каких-то функций."""

debug_mode = True

if debug_mode:
    print("Отладочная информация")

"""Управления последовательностью выполнения:
Флаги могут использоваться для управления тем, когда и как должны выполняться определённые блоки кода."""

finished = False
while not finished:
    some_condition_met = 5 ** 2   # Выполняем какую-то работу
    if some_condition_met:
        finished = True  # Завершаем цикл, устанавливая флаг
