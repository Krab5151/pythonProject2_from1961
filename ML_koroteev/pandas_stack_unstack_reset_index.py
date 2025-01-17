import numpy as np
import pandas as pd
import matplotlib.pyplot as plt






df = pd.DataFrame({
    "A": [1, 2, np.nan],
    "B": [4, None, np.nan],
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