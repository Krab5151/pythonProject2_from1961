import numpy as np
import pandas as pd
import matplotlib.pyplot as plt










df = pd.DataFrame({
    "A": [1, 2, pd.NA],
    "B": [4, None, pd.NA],
    "C": [7, 8, 9]
})
df1 = pd.DataFrame({"A": [1, 2, 3, 4, 5], "B": [10, 20, 30, 40, 50], "C": [100, 200, 300, 400, 500]})
df2 = pd.DataFrame({"A": ["yes", "no", "no"], "B": [10, "20" , "30"], "C": ["0", 0, 1]})
df3 = pd.DataFrame({"A": [2, 2, 3, 2, 3], "B": [10, 20, 30, 40, 50], "C": [100, 200, 300, 400, 500]})
df33 = pd.DataFrame({"A": ["F", "F", "W","F", "W"], "B": [10, 20, 30, 40, 50], "C": [100, 200, 300, 400, 500]})
df4 = pd.DataFrame({"A": [5, 2, 2, 4, 5], "B": [50, 20, 50, 40, 50], "C": [300, 300, 300, 400, 300]})
df5 = pd.DataFrame({"A": [50, 20, 2, 4, 5], "B": [50, 20, 300, 40, 5], "C": [50, 300, 300, 400, 5]})
df55 = pd.DataFrame({"A": ["F", "F", "G", "G", "W"], "B": [20, 20, 300, 20, 5], "C": [5, 300, 300, 400, 5]})
df333 = pd.DataFrame({"A": ["F", "F", "W","F", "W"],
                      "B": [20, 20, 30, 40, 50],
                      "C": [300, 200, 300, 300, 500]})
df7 = pd.DataFrame({
    'Age': [23, 45, 31, 22, 34, 40, 50, 28, 33, 42, 38, 25],
    'Sex': ['Male', 'Female', 'Male', 'Female', 'Male', 'Female',
            'Male', 'Female', 'Male', 'Female', 'Male', 'Female']
})
df77 = pd.DataFrame({
    'A': [1, 9, 5, 5, 2, 6, 2, 3, 10, 6, 7, 1, 9, 2],
    'B': [11, 6, 8, 10, 15, 11, 8, 8, 12, 7, 50, 50, 50, 50]
})
df777 = pd.DataFrame({
    'A': [34, 44, 40, 20, 32, 32, 49, 44, 34, 30, 45, 48, 36, 38, 47, 27, 24, 28, 25, 46],
    'B': ['M', 'F', 'F', 'F', 'M', 'F', 'F', 'F', 'F', 'M', 'M', 'M', 'M', 'F', 'F', 'F', 'M', 'M', 'F', 'F']
})

df44 = pd.DataFrame({"A": [5, 2, 2, 4, 5],
                     "B": [50, 20, 50, 40, 50],
                     "C": [300, 300, 300, 400, 300]},
                    index=["Avrg", "Bin", "Cnt", "Foo", "Dt"]
                    )

df22 = pd.DataFrame({"A": [0, "no", "no"], "B": [0, 0 , 0], "C": [0, 0, 1]})


df11 = pd.DataFrame({
    "A": [2, 2, 3, 2, 3],
    "B": [10, 20, pd.NA, 40, 50],
    "C": [pd.NA, 200, 300, 400, pd.NA]
})


# Долевое распределение столбцов А и В
grouped = df333.groupby(["A", "B"]).size()
percent = grouped.groupby(level=0).apply(lambda x: x * 100 / float(x.sum()))
print(grouped)
print(percent)

#  one-hot encoding
encod_categor = pd.get_dummies(df333, columns=["A"])  # Выйдет False и True
encod_zero_one = encod_categor.astype(int)  # Преобразование False и True в 0 и 1
print(encod_categor)
print(encod_zero_one)


# Сравнение Индекса Группировки и Средного
mean_a = df11.groupby(['A']).mean()
print(mean_a)
df11_cop = df11.copy()
for col in df11.columns[1:]:
    df11_cop['NEW'+'_' + col] = df11[col] != df11['A'].map(mean_a[col])
    print(df11_cop)