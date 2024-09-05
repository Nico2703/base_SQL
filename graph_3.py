import pandas as pd
from sqlalchemy import create_engine
import matplotlib.pyplot as plt

engine = create_engine('mysql+pymysql://root:nicopass+2703@localhost:3306/elevadores_model')

query = """
SELECT r.ID_Cliente, c.Denominacion, SUM(r.Costo) AS deuda_total
FROM Reparaciones r
JOIN clientes c ON r.ID_cliente = c.ID_cliente
GROUP BY r.ID_cliente
ORDER BY deuda_total DESC LIMIT 10;
"""

df = pd.read_sql(query, engine)

plt.figure(figsize=(12, 8))
plt.fill_between(df['Denominacion'], df['deuda_total'], color='#c72c48', alpha=0.4)
plt.plot(df['Denominacion'], df['deuda_total'], color='red', alpha=0.6, linewidth=2)

plt.xlabel('Cliente')
plt.ylabel('deuda_total')
plt.title('Gráfico de deuda total por cliente')
plt.xticks(rotation=45, ha='right')

for i, txt in enumerate(df['deuda_total'].apply(lambda x: "${:,.2f}".format(x))):
    plt.annotate(txt, (df['Denominacion'][i], df['deuda_total'][i]), textcoords="offset points", xytext=(0,10), ha='center')


plt.tight_layout()

plt.savefig('graph_deuda.png')

plt.show()
