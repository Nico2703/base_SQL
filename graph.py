import pandas as pd
from sqlalchemy import create_engine
import matplotlib.pyplot as plt

engine = create_engine('mysql+pymysql://root:nicopass+2703@localhost:3306/elevadores_model')

query = """
SELECT e.Nombre_edif, COUNT(r.ID_edificio) AS cantidad_reclamos FROM Reclamos r 
JOIN edificios e ON r.ID_edificio = e.ID_edificio GROUP BY e.ID_edificio 
ORDER BY cantidad_reclamos DESC LIMIT 10;
"""

df = pd.read_sql(query, engine)


plt.figure(figsize=(10, 6))
x = df['Nombre_edif']
y = df['cantidad_reclamos']
plt.bar(df['Nombre_edif'], df['cantidad_reclamos'], color='skyblue', edgecolor='black', hatch='/', linewidth=1.5)

plt.xlabel('Nombre_edif')
plt.ylabel('cantidad_reclamos')
plt.title('Gráfico de reclamos totales')
plt.xticks(rotation=70)
plt.tight_layout()

plt.savefig('graph_top10.png')

plt.show()
