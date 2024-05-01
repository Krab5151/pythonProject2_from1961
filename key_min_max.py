a = [1, 2, 3, 0.5]
b = [0, 2, 7]

# параметр key=  -  для ф-ции  min / max указывает по какому признаку определять min / max
print(min(a, b, key=sum), ' выбор из 2x списков наименьшей суммы', "\n")  #
print(max(a, b, key=sum), ' выбор из 2x списков наибольшей суммы', "\n")  #
print(min(a, key=None),"min значение в списке ", "\n")
print(max(a, b, key=len),"список с мах длинной", "\n")  # определяет max по длинне списка

# min значение в списке
a = [1, 2, 3, 0.5]
print(min(range(len(a)), key=lambda i: a[i]), "min значение в списке, проверка поиндексно", "\n")
