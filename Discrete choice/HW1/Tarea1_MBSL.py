# -*- coding: utf-8 -*-
"""
Created on Sat Feb 15 20:49:14 2025

@author: max_s
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import gaussian_kde

##################################################################################################
##################################################################################################
##################################################################################################
########################## PROBLEMA 1 ############################################################
##################################################################################################
##################################################################################################
##################################################################################################


# Definimos los tipos de consumidores
consumidores = np.array(["s_1", "s_2", "s_3"])

# Número de consumidores por tipo
M_n = np.array([50, 50, 50])  # 150 en total

# Alternativas disponibles
B = np.array([1, 2, 3, 4])

# Ingreso de cada tipo de consumidor
ingreso = np.array([500, 4000, 10000])

# Precio de cada alternativa
precio = 100 * B

# Utilidad observada: v_jn
v_jn = np.array([3 + 2 * np.log(y - precio) for y in ingreso])

# Parámetros para la utilidad no observada (Gumbel)
mu = 0
beta = 1

# Número de episodios
n_episodios = 10000

# ==========================
# Inciso (a)
# ==========================

np.random.seed(1)

# Matriz para registrar la demanda de cada alternativa en cada episodio
demanda = np.zeros((n_episodios, len(B)))

# Generamos las elecciones en bloque para optimizar
for episodio in range(n_episodios):
    for n, consumidores_tipo in enumerate(M_n):
        # Generamos errores aleatorios para todos los consumidores del tipo n
        e_jn = np.random.gumbel(loc=mu, scale=beta, size=(consumidores_tipo, len(B)))
        # Calculamos la utilidad total
        u_jn = v_jn[n] + e_jn
        # Elegimos la alternativa con mayor utilidad para cada consumidor
        elecciones = np.argmax(u_jn, axis=1)
        # Contamos cuántos consumidores eligieron cada alternativa
        for j in elecciones:
            demanda[episodio, j] += 1  # Actualizamos la demanda

# Gráficas
fig, axes = plt.subplots(2, 2, figsize=(12, 8))

# Título general
fig.suptitle("Distribución de la demanda por Alternativa (Gumbel)",
             fontsize=14,
             fontweight="bold")

# Graficamos cada distribución de demanda
for i, ax in enumerate(axes.flat):
    # Histograma de la demanda
    counts, bins, _ = ax.hist(demanda[:, i],
                               bins=20,
                               alpha=0.4,
                               color='darkblue',
                               edgecolor='black',
                               density=True)

    # KDE para suavizar la distribución
    kde = gaussian_kde(demanda[:, i])
    x_vals = np.linspace(min(demanda[:, i]), max(demanda[:, i]), 200)
    ax.plot(x_vals, kde(x_vals), color='red', linewidth=2, label="Densidad KDE")

    ax.set_title(f"Alternativa {B[i]}")
    
    # Etiquetas de ejes solo donde corresponde
    if i % 2 == 0:
        ax.set_ylabel("Densidad")
    if i >= 2:
        ax.set_xlabel("Demanda")

    ax.legend()

# Ajustar diseño y mostrar gráfico
plt.tight_layout()
plt.show()

# Media y desviación estándar

# Cálculo de media y desviación estándar por alternativa
media_demanda = np.round(np.mean(demanda, axis=0), 2)
desviacion_demanda = np.round(np.std(demanda, axis=0), 2)

# Tabla
fig, ax = plt.subplots(figsize=(6, 2))
ax.set_title("Demanda por Alternativa: Media y Desviación Estándar (Gumbel)",
             fontsize=12,
             fontweight="bold")

# Ocultar ejes
ax.axis("off")

# Crear tabla
tabla = plt.table(cellText=list(zip(B, media_demanda, desviacion_demanda)),
                  colLabels=["Alternativa", "Demanda Promedio", "Desviación Estándar"],
                  cellLoc="center",
                  loc="center")

# Ajustar diseño y mostrar
plt.tight_layout()
plt.show()

##################################################################################################

# ==========================
# Inciso (b)
# ==========================

# Matriz para registrar la demanda de cada alternativa en cada episodio
demanda_b = np.zeros((n_episodios, len(B)))

# Calculamos las probabilidades logit condicional específicas para cada tipo de consumidor y alternativa
exp_v_jn = np.exp(v_jn)
probabilidades = exp_v_jn / np.sum(exp_v_jn, axis=1, keepdims=True)

for episodio in range(n_episodios):
    for j in range(len(consumidores)):  
        # Generamos elecciones multinomiales para cada tipo de consumidor con sus propias probabilidades
        ## Produce una matriz de elecciones de 10,000x4 en la que 150 consumidores
        elecciones = np.random.choice(len(B),
                                      size=M_n[j],
                                      p=probabilidades[j])        
        # Contamos las elecciones y actualizamos la demanda
        for j in elecciones:
            demanda_b[episodio, j] += 1

# Gráficas
fig, axes = plt.subplots(2, 2, figsize=(12, 8))

# Título general
fig.suptitle("Distribución de la demanda por Alternativa (Multinomial)",
             fontsize=14,
             fontweight="bold")

# Graficamos cada distribución de demanda
for i, ax in enumerate(axes.flat):
    # Histograma de la demanda
    counts, bins, _ = ax.hist(demanda_b[:, i],
                               bins=20,
                               alpha=0.4,
                               color='red',
                               edgecolor='black',
                               density=True)

    # KDE para suavizar la distribución
    kde = gaussian_kde(demanda_b[:, i])
    x_vals = np.linspace(min(demanda_b[:, i]),
                         max(demanda_b[:, i]), 200)
    ax.plot(x_vals,
            kde(x_vals),
            color='blue',
            linewidth=2,
            label="Densidad KDE")

    ax.set_title(f"Alternativa {B[i]}")
    
    # Etiquetas de ejes solo donde corresponde
    if i % 2 == 0:
        ax.set_ylabel("Densidad")
    if i >= 2:
        ax.set_xlabel("Demanda")

    ax.legend()

# Ajustar diseño y mostrar gráfico
plt.tight_layout()
plt.show()

# Media y desviación estándar

# Cálculo de media y desviación estándar por alternativa
media_demanda_b = np.round(np.mean(demanda_b, axis=0), 2)
desviacion_demanda_b = np.round(np.std(demanda_b, axis=0), 2)

# Tabla
fig, ax = plt.subplots(figsize=(6, 2))
ax.set_title("Demanda por Alternativa: Media y Desviación Estándar (Multinomial)",
             fontsize=12,
             fontweight="bold")

# Ocultar ejes
ax.axis("off")

# Crear tabla
tabla = plt.table(cellText=list(zip(B, media_demanda_b, desviacion_demanda_b)),
                  colLabels=["Alternativa", "Demanda Promedio", "Desviación Estándar"],
                  cellLoc="center",
                  loc="center")

# Ajustar diseño y mostrar
plt.tight_layout()
plt.show()

##################################################################################################
##################################################################################################
##################################################################################################
########################## PROBLEMA 2 ############################################################
##################################################################################################
##################################################################################################
##################################################################################################

# ==========================
# Inciso (b)
# ==========================

# Ahora calculemos la demanda teorica de cada alternativa
demanda_esperada = np.sum(probabilidades * M_n[0],
                          axis=0)

# Crear una figura para la tabla de demanda teórica esperada
fig, ax = plt.subplots(figsize=(6, 2))

# Título de la tabla
ax.set_title("Demanda Teórica Esperada por Alternativa", fontsize=12, fontweight="bold")

# Ocultar ejes
ax.axis("off")

# Crear la tabla con los valores calculados
tabla = plt.table(cellText=list(zip(B, np.round(demanda_esperada, 2))),
                  colLabels=["Alternativa", "Demanda Teórica Esperada"],
                  cellLoc="center",
                  loc="center")

# Ajustar diseño y mostrar la tabla
plt.tight_layout()
plt.show()
