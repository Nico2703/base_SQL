import pandas as pd
from sqlalchemy import create_engine
import matplotlib.pyplot as plt


engine = create_engine('mysql+pymysql://root:nicopass+2703@localhost:3306/elevadores_model')

query = """
SELECT t.Nombre_tec, COUNT(r.Legajo_tec) AS cantidad_reclamos FROM Reclamos r 
JOIN tecnicos t ON r.Legajo_tec = t.Legajo_tec GROUP BY r.Legajo_tec 
ORDER BY cantidad_reclamos DESC;
"""

df = pd.read_sql(query, engine)

df['Nombre_tec'] = df['Nombre_tec'].astype(str)
labels = df['Nombre_tec'].tolist()
sizes = df['cantidad_reclamos'].tolist()

plt.figure(figsize=(8, 8))

plt.pie(
    sizes,                             
    labels=labels,                    
    autopct='%1.1f%%',                 
    colors=['#ff9999', '#66b3ff', '#99ff99', '#ffcc99'], 
    explode=[0] * len(df),            
    shadow=True,                      
    startangle=140,                    
    wedgeprops=dict(width=0.3)         
)

plt.title('Gráfico de reclamos por técnico')

plt.savefig('graph_tecnicos.png')

plt.show()

