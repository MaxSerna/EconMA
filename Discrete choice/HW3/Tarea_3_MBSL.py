# -*- coding: utf-8 -*-
"""
Created on Thu Mar 20 18:50:26 2025

@author: max_s
"""

import numpy as np
import pandas as pd
from scipy.optimize import minimize
from joblib import Parallel, delayed  # Para boostrap. El código del boot está comentado (tarda mucho en correr)
from tqdm import tqdm                 # Para boostrap. El código del boot está comentado (tarda mucho en correr
import numdifftools as nd

# Cargamos los datos de yogurt
df = pd.read_csv("C:/Users/max_s/Desktop/Colmex/4to semestre/Discrete choice/Tareas/Tarea 2/Data/yogurt.csv")

#############################################################################
############################ Nested logit ###################################
#############################################################################

# Número de alternativas
A = 4

# Nidos
nests = {0: [0, 1], 1: [2, 3]}

# Características x_j: precio de j y aparición en comercial de j
## Por el momento generaremos M matrices de 4x2
features = ['price1', 'price2', 'price3', 'price4', 'feat1', 'feat2', 'feat3', 'feat4']
x = np.stack([df[[features[i], features[i + A]]].values for i in range(A)], axis=1)

# Vector de alternativas elegidas
j_star = df[['brand1', 'brand2', 'brand3', 'brand4']].values.argmax(axis=1)

# Vector donde a cada alternativa (fila) se le asigna su correspondiente nido
alternativa_nido = np.zeros(A, dtype=int)
for r, nest in nests.items():
    alternativa_nido[nest] = r

# Vector de nidos elegidos
r_star = alternativa_nido[j_star]

M, A, K = x.shape # Número de individuos M, alternativas A, y características K
R = len(nests) # Número de nidos
P = K + (A - 1) + R # Número total de parámetros: beta + alpha + gamma (omitimos un alpha, dado que alpha_4=0)
arange_M = np.arange(M) # saco esto de la LL para no perder tiempo en la estimación. Tan sólo crea un vector 1:M

# Definamos ahora la función de log-verosimilitud que usaremos para obtener los estimadores MLE
def log_likelihood_joint(params, x, j_star, nests, r_star):
    """
    Con esta función obtenemos la log-verosimilitud negativa del modelo nested logit,
    tomando como argumentos un vector de parámetros (a estimar más adelante) alpha, beta y gamma.
    Normalizaremos alpha_4 a cero para obtener un modelo identificado, y con los gammas podremos obtener
    en su lugar los lambdas (acotamos los lambdas entre cero y uno como se sugirió en clase)
    """
    beta = params[:K] # Extraemos los gammas
    alphas = np.append(params[K:P - R], 0) # Extraemos los gammas
    gamma = params[P - R:P] # Extraemos los gammas
    
    lambdas = np.exp(gamma) / (1 + np.exp(gamma)) # Obtenemos los lambdas a partir de los gammas tal que lambda_r \in (0,1)
#    lambdas = np.ones_like(gamma) #PRUEBA: haciendo lambda=1 obtenemos los estimados de logit condicional

    #v_jn = alphas.reshape(1, A) + np.dot(x, beta).reshape(M, A)  # Calculamos una matriz de utilidades observadas. Dim MxA
    v_jn = alphas + (x @ beta) # más rápido

    # Para cada nido, calculemos exp(v_im  /lambda_l) (no es ni j_star ni r_star, es para toda i y toda l)
    exp_v_lambda = np.zeros((M, A, len(nests)))
    for r, nest in nests.items():
        exp_v_lambda[:, nest, r] = np.exp(v_jn[:, nest] / lambdas[r]) # "Tensor" en 3D, MxAxR

    # Suma exp(v_jm\lambda_r) sobre i \in B_l
    sum_in_nest = np.sum(exp_v_lambda, axis=1)  # Dim MxR

    # Obtenemos el denominador: suma sim_in_nest sobre todo l=1 a R
    denom = np.sum(sum_in_nest ** lambdas, axis=1)  # Vector dim M

    # Obtengamos lambda_r* y exp(v_j*/lambda_r*)
    lambda_r_star = lambdas[r_star]  # Vector dim M
    v_j_star = v_jn[arange_M, j_star]  # Vector dim M
    exp_v_j_star = np.exp(v_j_star / lambda_r_star)  # # Vector dim M

    # Obtenemos exp (v_im / lambda_r*) y sumamos sobre i \in B_{r*(m)}
    sum_in_nest_r_star = sum_in_nest[arange_M, r_star]  # shape (M,)
    
    # Obtenemos el numerador
    numerator = (sum_in_nest_r_star ** (lambda_r_star - 1)) * exp_v_j_star

    # Calculamos la log-likelihood
    log_likelihood = np.log(numerator / denom)
    return -np.sum(log_likelihood)


def estimate_nested_logit(x, j_star, nests, r_star, method, init_param):
    """
    Estimamos mediante ML los parámetros alpha, beta y lambda para el modelo de logit anidado.
    """

    result = minimize(log_likelihood_joint,
                      init_param,
                      args=(x, j_star, nests, r_star),
                      method=method)

    beta_est = result.x[:K]
    alpha_est = np.append(result.x[K:K + A - 1], 0)  # alpha_4 = 0
    gamma_est = result.x[K + A - 1:]
    lambda_est = np.exp(gamma_est) / (1 + np.exp(gamma_est))

    return beta_est, alpha_est, lambda_est, result

# Estimamos el modelo de nested logit. 
# Usaremos cinco 4 vectores de distintas condiciones iniciales,
# y 3 métodos de estimación numérica distintos. Uno de estos 4 vectores
# incluirá los estimados de logit condicional de la tarea 2.

# Estimados de logit condicional (tarea 2)
beta_LC = np.array([-37.058, 0.487])
alpha_LC = np.array([1.388, 0.644, -3.086])  # \alpha_4 = 0 para identificación

# Otro vector de iniciales arbitrarias
beta_init_2 = np.array([20, 10])
alpha_init_2 = np.array([-10, 20, 10])  # \alpha_4 = 0 para identificación
gamma_init_2 = np.array([.4,.9])
init_2 = np.concatenate([beta_init_2,
                         alpha_init_2,
                         gamma_init_2])

# Condiciones iniciales: matriz de 4 filas (distintas condiciones), cada una de dimensión P
R = len(nests) # Número de nidos
P = K + (A - 1) + R # Número total de parámetros: beta + alpha + gamma (omitimos un alpha, dado que alpha_4=0)

init_params = np.vstack([
    np.zeros(P),                                  # 1. Todos ceros
    init_2,                                       # 2. Condiciones iniciales arbitrarias
    np.linspace(5, 0.1, P),                        # 3. Valores crecientes de -1 a 1
    np.concatenate([                              # 4. Estimados del logit condicional
        beta_LC, 
        alpha_LC, 
        np.array([-0.5,-0.5])
        ])
    ])

# Vector de tres métodos distintos
methods = methods = ["BFGS", "L-BFGS-B", "Nelder-Mead", "Powell"]

# Para correr la estimación en bucle (esto es solo base, puedes expandirlo):
results = []

# Estimación usando el grid de condiciones iniciales y los tres métodos
for i, init in enumerate(init_params):
    for method in methods:
        print(f"Estimando con método {method}, y vector de cond. iniciales {i+1}")
        beta_est, alpha_est, lambda_est, result = estimate_nested_logit(x, j_star, nests, r_star, method, init)
        
        # Calculemos el AIC para cada estimación
        loglik = -result.fun
        aic = 2 * P - 2 * loglik
        
        # Generemos una lista con los resultados relevantes
        results.append({
            "method": method,
            "init_id": i + 1,
            "loglik": loglik,
            "aic": aic,
            "beta": beta_est,
            "alpha": alpha_est,
            "lambda": lambda_est,
            "success": result.success,
            "message": result.message,
            "parámetros": result.x
        })
        
print("\n" + "#"*70)
print("RESULTADOS DE LAS ESTIMACIONES DEL MODELO NESTED LOGIT")
print("#"*70)

for res in results:
    print(f"\nMétodo: {res['method']} | Condición inicial #{res['init_id']}")
    print(f"Log-verosimilitud: {res['loglik']:.3f}")
    print(f"AIC: {res['aic']:.2f}")
    print(f"¿Convergió?: {'Sí' if res['success'] else 'No'}")
    print("Betas:")
    for i, b in enumerate(res["beta"], start=1):
        print(f"  β_{i} = {b:.3f}")
    print("Alphas:")
    for i, a in enumerate(res["alpha"], start=1):
        print(f"  α_{i} = {a:.3f}")
    print("Lambdas:")
    for i, lam in enumerate(res["lambda"], start=1):
        print(f"  λ_{i} = {lam:.3f}")
    print("-" * 50)

# Seleccionamos los 3 mejores modelos según el AIC
top_models = sorted(results, key=lambda r: r["aic"])[:3]

print("\n" + "#"*70)
print("TOP 3 MODELOS SEGÚN EL CRITERIO DE INFORMACIÓN DE AKAIKE (AIC)")
print("#"*70)

for idx, res in enumerate(top_models, start=1):
    print(f"\n🏆 Modelo #{idx}")
    print(f"Método: {res['method']} | Condición inicial #{res['init_id']}")
    print(f"AIC: {res['aic']:.2f}")
    print(f"Log-verosimilitud: {res['loglik']:.3f}")
    print("Betas:")
    for i, b in enumerate(res["beta"], start=1):
        print(f"  β_{i} = {b:.3f}")
    print("Alphas:")
    for i, a in enumerate(res["alpha"], start=1):
        print(f"  α_{i} = {a:.3f}")
    print("Lambdas:")
    for i, lam in enumerate(res["lambda"], start=1):
        print(f"  λ_{i} = {lam:.3f}")
    print("-" * 50)
    
# Extraemos el mejor modelo según el AIC
best_model = min(results, key=lambda res: res["aic"])

##########################################################################
############## Errores estándar ##########################################
##########################################################################

# A) Con teoría asintótica usando el hessiano (calculado con numdifftools)
loglike_wrapper = lambda params: log_likelihood_joint(params, x, j_star, nests, r_star)
hessian_nd = nd.Hessian(loglike_wrapper)(best_model["parámetros"])
vcov_asintotica = np.linalg.inv(hessian_nd)
std_errors_nd = np.sqrt(np.diag(vcov_asintotica))

# Extraemos los errores estándar por tipo de parámetro
std_beta = std_errors_nd[:K]

# Alphas: hay A-1 estimados, alpha_4 está normalizado y su error estándar es 0
std_alpha = np.append(std_errors_nd[K:P - R], 0)

# Gammas (antes de transformación logística)
std_gamma = std_errors_nd[P - R:]

# Delta method para lambda_r = exp(gamma_r) / (1 + exp(gamma_r))
# Var(lambda_r) = (d lambda / d gamma)^2 * Var(gamma)
lambda_best = best_model["lambda"]
grad_lambda = lambda_best * (1 - lambda_best)  # d lambda / d gamma
std_lambda = grad_lambda * std_gamma

# Imprimimos los resultados
print("\n" + "#"*70)
print("ERRORES ESTÁNDAR DEL MEJOR MODELO SELECCIONADO POR AIC")
print("#"*70)

print("\nErrores estándar de β (betas):")
for i, se in enumerate(std_beta, start=1):
    print(f"  se(β_{i}) = {se:.4f}")

print("\nErrores estándar de α (alphas):")
for i, se in enumerate(std_alpha, start=1):
    print(f"  se(α_{i}) = {se:.4f}")

print("\nErrores estándar de λ (lambdas):")
for i, se in enumerate(std_lambda, start=1):
    print(f"  se(λ_{i}) = {se:.4f}")
    
# =============================================================================
# # c) Boostrap
# 
# # Número de iteraciones bootstrap
# n_bootstraps = 3211
# 
# # Función bootstrap para una iteración
# def bootstrap_iteration(resample_idx):
#     try:
#         x_boot = x[resample_idx, :, :]
#         j_star_boot = j_star[resample_idx]
#         r_star_boot = r_star[resample_idx]
#         beta_boot, alpha_boot, lambda_boot, result = estimate_nested_logit(
#             x_boot, j_star_boot, nests, r_star_boot,
#             method=best_model["method"],
#             init_param=best_model["parámetros"]
#         )
#         return beta_boot, alpha_boot, lambda_boot
#     except Exception as e:
#         print(f"Bootstrap iteration failed: {e}")
#         return np.full((K,), np.nan), np.full((A,), np.nan), np.full((len(nests),), np.nan)
# 
# # 🔒 Establecer semilla para reproducibilidad
# np.random.seed(42)
# 
# # Índices bootstrap pre-generados
# resample_indices = [
#     np.random.choice(M, size=M, replace=True)
#     for _ in range(n_bootstraps)
# ]
# 
# # Ejecutamos en paralelo
# boot_results = Parallel(n_jobs=-1, backend="loky")(
#     delayed(bootstrap_iteration)(resample_idx)
#     for resample_idx in tqdm(resample_indices, desc="Bootstrapping")
# )
# 
# # Separamos los resultados
# boot_betas = np.array([res[0] for res in boot_results])
# boot_alphas = np.array([res[1] for res in boot_results])
# boot_lambdas = np.array([res[2] for res in boot_results])
# 
# # Filtramos resultados válidos (sin NaNs)
# valid_idx = ~np.isnan(boot_betas).any(axis=1)
# boot_betas = boot_betas[valid_idx]
# boot_alphas = boot_alphas[valid_idx]
# boot_lambdas = boot_lambdas[valid_idx]
# 
# # Calculamos errores estándar bootstrap
# boot_se_betas = boot_betas.std(axis=0)
# boot_se_alphas = boot_alphas.std(axis=0)
# boot_se_lambdas = boot_lambdas.std(axis=0)
# 
# # Mostramos resultados
# print("\n" + "#"*70)
# print("ERRORES ESTÁNDAR (BOOTSTRAP) - MODELO NESTED LOGIT")
# print("#"*70)
# 
# print("\nErrores estándar bootstrap de β (betas):")
# for i, se in enumerate(boot_se_betas, start=1):
#     print(f"  se(β_{i}) = {se:.4f}")
# 
# print("\nErrores estándar bootstrap de α (alphas):")
# for i, se in enumerate(boot_se_alphas, start=1):
#     print(f"  se(α_{i}) = {se:.4f}")
# 
# print("\nErrores estándar bootstrap de λ (lambdas):")
# for i, se in enumerate(boot_se_lambdas, start=1):
#     print(f"  se(λ_{i}) = {se:.4f}")
# =============================================================================


################################################################################
######################## Tablas para Latex #####################################
################################################################################
################################################################################

# =============================================================================
# # Ordenar modelos por AIC
# sorted_models = sorted(results, key=lambda r: r["aic"])
# 
# # Crear tabla LaTeX
# latex_16_models = r"""\begin{table}[H]
# \centering
# \caption{Comparación de los 16 modelos Nested Logit ordenados por AIC}
# \label{tab:modelos_nested_16}
# \scriptsize
# \renewcommand{\arraystretch}{1.2}
# \begin{tabular}{llcccccccccc}
# \toprule
# \textbf{Método} & \textbf{ID} & $\hat\beta_1$ & $\hat\beta_2$ & $\hat\alpha_1$ & $\hat\alpha_2$ & $\hat\alpha_3$ & $\hat\alpha_4$ & $\hat\lambda_1$ & $\hat\lambda_2$ & \textbf{AIC} \\
# \midrule
# """
# 
# for m in sorted_models:
#     latex_16_models += (
#         f"{m['method']} & {m['init_id']} & "
#         + " & ".join(f"{v:.3f}" for v in m["beta"])
#         + " & "
#         + " & ".join(f"{v:.3f}" for v in m["alpha"])
#         + " & "
#         + " & ".join(f"{v:.3f}" for v in m["lambda"])
#         + f" & {m['aic']:.2f} \\\\\n"
#     )
# 
# latex_16_models += r"""\bottomrule
# \end{tabular}
# \end{table}
# """
# 
# # Mostrar código LaTeX
# print(latex_16_models)
# 
# # Tabla con los 4 vectores de condiciones iniciales
# latex_inits = r"""\begin{table}[H]
# \centering
# \caption{Vectores de condiciones iniciales usados en la estimación}
# \label{tab:cond_iniciales}
# \scriptsize
# \renewcommand{\arraystretch}{1.2}
# \begin{tabular}{lcccccccccc}
# \toprule
# \textbf{ID} & $\beta_1$ & $\beta_2$ & $\alpha_1$ & $\alpha_2$ & $\alpha_3$ & $\alpha_4$ & $\gamma_1$ & $\gamma_2$ \\
# \midrule
# """
# 
# for i, init in enumerate(init_params, start=1):
#     beta = init[:K]
#     alpha = np.append(init[K:K + A - 1], 0)
#     gamma = init[K + A - 1:]
#     latex_inits += (
#         f"{i} & "
#         + " & ".join(f"{v:.3f}" for v in beta)
#         + " & "
#         + " & ".join(f"{v:.3f}" for v in alpha)
#         + " & "
#         + " & ".join(f"{v:.3f}" for v in gamma)
#         + r" \\" + "\n"
#     )
# 
# latex_inits += r"""\bottomrule
# \end{tabular}
# \end{table}
# """
# 
# print(latex_inits)
# =============================================================================



# =============================================================================
# # --- Tabla solo para Nested Logit: comparación de errores estándar ---
# 
# # --- Preparar nombres de parámetros
# param_names = [f"$\\beta_{{{i+1}}}$" for i in range(K)] + \
#               [f"$\\alpha_{{{i+1}}}$" for i in range(A)] + \
#               [f"$\\lambda_{{{i+1}}}$" for i in range(R)]
# 
# # --- Estimadores del mejor modelo
# estimates = np.concatenate([best_model["beta"], best_model["alpha"], best_model["lambda"]])
# 
# # --- Errores estándar
# se_asymptotic = np.concatenate([std_beta, std_alpha, std_lambda])
# se_bootstrap  = np.concatenate([boot_se_betas, boot_se_alphas, boot_se_lambdas])
# 
# # --- Construir tabla LaTeX
# latex = r"""\begin{table}[H]
# \centering
# \caption{Estimaciones y errores estándar del modelo Nested Logit}
# \label{tab:se_nested_logit}
# \begin{tabular}{lccc}
# \toprule
# \textbf{Parámetro} & \textbf{Estimado} & \textbf{EE Asintótico} & \textbf{EE Bootstrap} \\
# \midrule
# """
# 
# for name, est, se_a, se_b in zip(param_names, estimates, se_asymptotic, se_bootstrap):
#     latex += f"{name} & {est:.4f} & {se_a:.4f} & {se_b:.4f} \\\\\n"
# 
# latex += r"""\bottomrule
# \end{tabular}
# \vspace{0.3em}
# \begin{minipage}{0.92\linewidth}
# \small \textit{Nota:} Los errores estándar (EE) asintóticos se calcularon con el hessiano numérico aproximado utilizando \texttt{numdifftools} y el método delta. Los errores estándar bootstrap se obtuvieron con """ + f"{n_bootstraps}" + r""" réplicas.
# \end{minipage}
# \end{table}
# """
# 
# # Mostrar resultado en consola
# print(latex)
# =============================================================================


# =============================================================================
# # --- Valores del modelo logit condicional (proporcionados manualmente)
# beta_logit = [-37.058, 0.487]
# se_beta_logit = [2.399, 0.120]
# 
# alpha_logit = [1.388, 0.644, -3.086, 0.0]
# se_alpha_logit = [0.088, 0.054, 0.145, 0.0]
# 
# aic_logit = 5327.11
# 
# # --- Valores del mejor modelo nested logit (ya definidos en tu código)
# beta_nested = best_model["beta"]
# alpha_nested = best_model["alpha"]
# lambda_nested = best_model["lambda"]
# aic_nested = best_model["aic"]
# 
# # Errores estándar (teoría asintótica)
# se_beta_nested = std_beta
# se_alpha_nested = std_alpha
# se_lambda_nested = std_lambda
# 
# # --- Generación de tabla LaTeX
# latex = r"""\begin{table}[H]
# \centering
# \caption{Comparación de modelos Logit condicional y Nested Logit}
# \label{tab:model_comparison}
# \begin{tabular}{lcccc}
# \toprule
# \textbf{Parámetro} & \textbf{Logit condicional} & \textbf{se} & \textbf{Nested logit} & \textbf{se} \\
# \midrule
# """
# 
# # Betas
# for i in range(len(beta_logit)):
#     latex += f"$\\beta_{{{i+1}}}$ & {beta_logit[i]:.3f} & {se_beta_logit[i]:.3f} & {beta_nested[i]:.3f} & {se_beta_nested[i]:.3f} \\\\\n"
# 
# latex += "\\midrule\n"
# 
# # Alphas
# for i in range(len(alpha_logit)):
#     latex += f"$\\alpha_{{{i+1}}}$ & {alpha_logit[i]:.3f} & {se_alpha_logit[i]:.3f} & {alpha_nested[i]:.3f} & {se_alpha_nested[i]:.3f} \\\\\n"
# 
# latex += "\\midrule\n"
# 
# # Lambdas (solo nested)
# for i in range(len(lambda_nested)):
#     latex += f"$\\lambda_{{{i+1}}}$ & -- & -- & {lambda_nested[i]:.3f} & {se_lambda_nested[i]:.3f} \\\\\n"
# 
# latex += "\\midrule\n"
# 
# # AIC
# latex += f"\\textbf{{AIC}} & {aic_logit:.2f} & & {aic_nested:.2f} & \\\\\n"
# 
# latex += r"""\bottomrule
# \end{tabular}
# 
# \vspace{0.3em}
# \begin{minipage}{0.95\linewidth}
# \small \textit{Nota:} Los errores estándar (EE) fueron calculados mediante la teoría asintótica utilizando el hessiano numérico aproximado con \texttt{numdifftools}. En el caso del modelo nested logit, los parámetros $\lambda_r$ fueron transformados usando el método delta.
# \end{minipage}
# \end{table}
# """
# 
# # Mostrar resultado
# print(latex)
# =============================================================================

