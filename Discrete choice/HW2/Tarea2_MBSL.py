# -*- coding: utf-8 -*-
"""
Created on Mon Mar  3 14:55:53 2025

@author: max_s
"""

import numpy as np
import pandas as pd
from scipy.optimize import minimize
from joblib import Parallel, delayed
import matplotlib.pyplot as plt
from scipy.stats import gaussian_kde
import numdifftools as nd

# Cargamos los datos de yogurt
df = pd.read_csv("C:/Users/max_s/Desktop/Colmex/4to semestre/Discrete choice/Tareas/Tarea 2/Data/yogurt.csv")

#############################################################################
############################ Problema 2 #####################################
#############################################################################

##############################################################
# Preparemos los datos para la estimación de logit condicional
##############################################################

# Número de alternativas
A = 4

# Conjunto de alternativas disponibles (índices)
B = list(range(A))  

# Características x_j: precio de j y aparición en comercial de j
## Por el momento generaremos M matrices de 4x2
features = ['price1', 'price2', 'price3', 'price4', 'feat1', 'feat2', 'feat3', 'feat4']
x = np.stack([df[[features[i], features[i + A]]].values for i in range(A)], axis=1)

# Vector de alternativas elegidas
j_star = df[['brand1', 'brand2', 'brand3', 'brand4']].values.argmax(axis=1)

# Definamos ahora la función de log-verosimilitud que usaremos para obtener los estimadores MLE
def log_likelihood_joint(params, x, j_star, B):
    """
    Compute the negative log-likelihood function for conditional logit,
    estimating both beta and the first three alpha parameters, with alpha_4 = 0.
    Con esta función obtenemos la log-verosimilitud negativa de logit condicional,
    con la cual obtendremos ambos betas y \alpha_j, j=1, 2, 3. Impondremos \alpha_4 = 0 para identificación del modelo.
    """
    K = x.shape[2]  # Número de características
    beta = params[:K]  # De los parámetros a incluir como condiciones iniciales, los primeros K son betas
    alpha = np.append(params[K:], 0)  # Los últimos parámetros de params son alphas + alpha_4 = 0
    
    M, A, _ = x.shape  # Dimensiones de la matriz de datos
    v_jn = alpha.reshape(1, A) + np.dot(x, beta).reshape(M, A)  # Obtenemos v_jn para M individuos y A alternativas. mat MxA
    exp_v_jn = np.exp(v_jn) # calcula e^v_jn
    choice_probs = exp_v_jn[np.arange(M), j_star] / exp_v_jn.sum(axis=1) # calcula Pr[y_jm = 1]
    
    return -np.sum(np.log(choice_probs))  # Calcula la suma en M de todo Pr[y_jm = 1] y toma el negativo para optimizar.


def estimate_beta_alpha(x, j_star, B):
    """
    Estimamos mediante ML los parámetros alpha y beta
    """
    K = x.shape[2]
    param_init = np.zeros(K + len(B) - 1)  # Vector de tamaño 5 de condiciones iniciales cero (alpha_4 se excluye)

    result = minimize(log_likelihood_joint,
                      param_init,
                      args=(x, j_star, B),
                      method='BFGS') # estimamos numéricamente mediante BFGS
    
    beta_est = result.x[:K]  # Extraemos betas
    alpha_est = np.append(result.x[K:], 0)  # Extraemos alphas y agregamos alpha_4

    return beta_est, alpha_est, result

# Estimamos el modelo de logit condicional
beta_estimates, alpha_estimates, LL = estimate_beta_alpha(x, j_star, B)

# Calculemos el AIC
loglik = -LL.fun
aic = 2 * (A-1 + x.shape[2]) - 2 * loglik


#############################################################################
############################ Problema 3 #####################################
#############################################################################

# Resultados
print("Betas estimados:", np.round(beta_estimates, 3))
print("Alphas estimados:", np.round(alpha_estimates, 3))
print("AIC del modelo:", round(aic, 2))


#############################################################################
############################ Problema 4 #####################################
#############################################################################

# a) Recargándonos en teoría asintótica, obtenemos los errores estándar de los estimadores de MLE:
hessiana_inversa = LL.hess_inv
var_estims = np.diag(hessiana_inversa)
sd_estims = np.sqrt(var_estims)

sd_betas = sd_estims[:2]
sd_alphas = np.append(sd_estims[2:], 0)

# Resultados
#print("Errores estándar de beta_j:", np.round(sd_betas, 3))
#print("Errores estándar de alpha_j:", np.round(sd_alphas, 3))

# b) Con teoría asintótica usando numdifftools
loglike_wrapper = lambda params: log_likelihood_joint(params, x, j_star, B)
hessian_nd = nd.Hessian(loglike_wrapper)(LL.x)
vcov_asintotica = np.linalg.inv(hessian_nd)
std_errors_nd = np.sqrt(np.diag(vcov_asintotica))

std_betas_nd = std_errors_nd[:2]
std_alphas_nd = np.append(std_errors_nd[2:], 0)

print("Errores estándar (numdifftools) de beta_j:", np.round(std_betas_nd, 3))
print("Errores estándar (numdifftools) de alpha_j:", np.round(std_alphas_nd, 3))

# c) Boostrap

# Número de iteraciones bootstrap
n_bootstraps = 3211

# Tamaño del data frame
M = len(df)

# Función para hacer bootstrap "eficiente"
def bootstrap_iteration(resample_idx):
    """Se ejecuta una sola iteración de boostrap con índices de resampling dados"""
    x_boot = x[resample_idx, :, :]
    j_star_boot = j_star[resample_idx]

    # Estimamos con la misma función de estimación
    beta_boot, alpha_boot, _ = estimate_beta_alpha(x_boot, j_star_boot, B)

    return beta_boot, alpha_boot

# Generamos todos los índices de resampling con anticipación (evitamos hacerlo dentro de un loop del parallel)
resample_indices = [np.random.choice(
    M,
    size=M,
    replace=True
    ) for _ in range(n_bootstraps)]

# Corremos el boostrap paralelizado usando índices de resampleo generados previamente
results = Parallel(n_jobs=-1,
                   backend="loky",
                   prefer="threads")(
    delayed(bootstrap_iteration)(resample_idx) for resample_idx in resample_indices
)

# Separamos los estimadores de BS de beta y alpha
bootstrap_betas = np.array([res[0] for res in results])
bootstrap_alphas = np.array([res[1] for res in results])

# Calculamos errores estándar
boot_se_betas = bootstrap_betas.std(axis=0)
boot_se_alphas = bootstrap_alphas.std(axis=0)

# Resultados
print("Errores estándar (Bootstrap) de beta_j:", np.round(boot_se_betas, 3))
print("Errores estándar (Bootstrap) de alpha_j:", np.round(boot_se_alphas, 3))

##############################################################
# Gráficas ###################################################
##############################################################

# Definimos colores para plotear
beta_colors = ["tab:blue", "tab:orange"]  # 2 colores para 2 beta
alpha_colors = ["tab:green", "tab:red", "tab:purple"]  # 3 colores para 3 alpha

# Figuras separadas, una de 2x1 y otra de 3x1
fig_betas, axes_betas = plt.subplots(2, 1, figsize=(14, 10))
fig_alphas, axes_alphas = plt.subplots(3, 1, figsize=(14, 16))

# Distribución marginal empírica de beta_j
for i in range(bootstrap_betas.shape[1]):
    # Histograma
    axes_betas[i].hist(bootstrap_betas[:, i],
                       bins=30,
                       density=True,
                       alpha=0.5,
                       color=beta_colors[i],
                       edgecolor='black')
    
    # Kernel Density Estimation (KDE)
    kde = gaussian_kde(bootstrap_betas[:, i])
    x_vals = np.linspace(min(bootstrap_betas[:, i]),
                         max(bootstrap_betas[:, i]),
                         100)
    axes_betas[i].plot(x_vals,
                       kde(x_vals),
                       color=beta_colors[i],
                       linestyle='solid',
                       linewidth=1.5)

    axes_betas[i].set_title(f"Distribución marginal empírica de beta_{i+1}",
                            fontsize = 15)
    axes_betas[i].set_ylabel("Densidad",
                             fontsize = 14)

# Etiqueta de eje x solamente para la última figura
axes_betas[-1].set_xlabel("Valor de β_j", 
                          fontsize = 14)

fig_betas.tight_layout()

# Distribución marginal empírica de alpha_j
for i in range(bootstrap_alphas.shape[1] - 1):  # Excluye alpha_4 = 0
    # Histogram
    axes_alphas[i].hist(bootstrap_alphas[:, i],
                        bins=30,
                        density=True,
                        alpha=0.5,
                        color=alpha_colors[i],
                        edgecolor='black')
    
    # Kernel Density Estimation (KDE)
    kde = gaussian_kde(bootstrap_alphas[:, i])
    x_vals = np.linspace(min(bootstrap_alphas[:, i]), max(bootstrap_alphas[:, i]), 100)
    axes_alphas[i].plot(x_vals,
                        kde(x_vals),
                        color=alpha_colors[i],
                        linestyle='solid',
                        linewidth=1.5)

    axes_alphas[i].set_title(f"Distribución marginal empírica de alpha_{i+1}",
                             fontsize = 16)
    axes_alphas[i].set_ylabel("Densidad",
                              fontsize = 15)

axes_alphas[-1].set_xlabel("Valor de α_j",
                           fontsize = 15)

fig_alphas.tight_layout()

plt.show()

###########################################################################
########### 5. ELASTICIDADES PRECIO CRUZADAS Y PROPIAS #######################
###########################################################################

# Esto se calcula usando lo hallado en la tarea 1.
# A continuación una rutina para implementar esas fórmulas

# Implementación de la derivada de la probabilidad respecto al precio de la alternativa j

# Extraer el coeficiente estimado de precio
beta_price = beta_estimates[0]

# Dimensiones de características
K = 2

# Calcular utilidades v_jn
v_jn = alpha_estimates.reshape(1, A) + np.dot(x, beta_estimates).reshape(M, A)

# Calcular probabilidades de elección P_jm
exp_v_jn = np.exp(v_jn)
P_jm = exp_v_jn / exp_v_jn.sum(axis=1, keepdims=True)  # Matriz MxA de probabilidades

# Extraer la matriz de precios
prices = df[['price1', 'price2', 'price3', 'price4']].values  # Matriz MxA de precios

# Inicializar matriz de derivadas de las probabilidades con respecto a los precios
dP_dX = np.zeros((M, A, A))  # Tensor MxAxA

# Implementación de la fórmula dada
for j in range(A):  # Alternativa j (aquella cuyo precio cambia)
    for i in range(A):  # Alternativa i (afectada por el cambio)
        if i == j:
            dP_dX[:, i, j] = P_jm[:, i] * (1 - P_jm[:, j]) * beta_price
        else:
            dP_dX[:, i, j] = -P_jm[:, i] * P_jm[:, j] * beta_price

# Calcular elasticidades precio propias y cruzadas
# elasticities = dP_dX * prices[:, np.newaxis, :]  # Multiplicar por el precio correspondiente MAAAAALLLL
elasticities = dP_dX * (prices[:, np.newaxis, :] / P_jm[:, :, np.newaxis])  # Multiplicar por el precio/proba

# Calcular elasticidades promedio por alternativa
avg_elasticities = elasticities.mean(axis=0)  # Promedio sobre M individuos

# Crear DataFrame para visualizar
elasticity_df = pd.DataFrame(avg_elasticities,
                             columns=[f"Alt_{i+1}" for i in range(A)],
                             index=[f"Alt_{j+1}" for j in range(A)])

# Mostrar elasticidades
print(elasticity_df)

# =============================================================================
# with open("elasticities.tex", "w") as f:
#     f.write(elasticity_df.to_latex(float_format="%.3f", index=True))
# =============================================================================S

