import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.optimize import minimize
import numdifftools as nd

# Cargar datos
df = pd.read_csv("C:/Users/max_s/Desktop/Colmex/4to semestre/Discrete choice/Tareas/Tarea 2/Data/yogurt.csv")

# Configuración inicial
A = 4
features = ['price1', 'price2', 'price3', 'price4',
            'feat1', 'feat2', 'feat3', 'feat4']
x = np.stack([df[[features[i], features[i + A]]].values for i in range(A)], axis=1)  # (M, A, 2)
j_star = df[['brand1', 'brand2', 'brand3', 'brand4']].values.argmax(axis=1)

# Dimensiones
M, A, K = x.shape     # K = 2: price, feat
P = K + (A - 1)       # 5 random coefficients: 2 betas + 3 alphas
R = 50
np.random.seed(0)
omega = np.random.normal(size=(R, P))  # (R, 5)

#############################################################################
############################ Inciso 1 #######################################
#############################################################################

# Contar frecuencia de cada pan.id
pan_counts = df['pan.id'].value_counts().sort_index()

# Graficar histograma
plt.figure(figsize=(10, 5))
plt.bar(pan_counts.index, pan_counts.values, color='skyblue', edgecolor='black')
plt.xlabel("ID del hogar (pan.id)")
plt.ylabel("Número de observaciones")
plt.grid(axis='y', linestyle='--', alpha=0.7)
plt.tight_layout()
plt.show()

#############################################################################
############################ Inciso 4 #######################################
#############################################################################
#############################################################################
#############################################################################
#############################################################################
############################ Mixed logit ####################################
#############################################################################
#############################################################################
#############################################################################

# Log-verosimilitud vectorizada
def SLL(params, x, j_star, omega):
    M, A, K = x.shape               
    P = K + A - 1
    R = omega.shape[0]

    b_bar = params[:P]               # medias: [beta_p, beta_f, alpha_1, alpha_2, alpha_3]
    gammas = params[P:]               # entradas de la matriz Cholesky
    Gamma = np.diag(gammas)           # matriz diagonal 5x5

    b_r = b_bar + omega @ Gamma.T       # (R, 5) betas y alphas más su error
    beta_r = b_r[:, :K]                 # (R, 2) beta_p, beta_f
    alpha_r = np.concatenate([b_r[:, K:], np.zeros((R, 1))], axis=1)  # (R, 4) alphas más sus errores y alpha_4 = 0

    V = np.tensordot(beta_r, x, axes=([1], [2])) + alpha_r[:, None, :]  # (R, M, A)

    exp_V = np.exp(V)
    denom = exp_V.sum(axis=2)                     # (R, M)
    numer = np.take_along_axis(exp_V, j_star[None, :, None], axis=2).squeeze(-1)  # (R, M)
    probs = numer / denom                         # (R, M)

    mean_probs = probs.mean(axis=0)               # (M,)
    return -np.sum(np.log(mean_probs))

# Función de estimación
def estimate_SLL(x, j_star, omega, init_param, method):
    return minimize(SLL,
                    init_param,
                    args=(x, j_star, omega),
                    method=method)

# Condiciones iniciales (3)
init_params = [
    np.concatenate([-np.ones(P), np.ones(P)*0.1]), # 1. valores estándar
    
    np.concatenate([                    # 2. estimados de nested logit
        [-28.196, 0.387],             
        [1.308, 0.734, -1.930],       
        np.ones(P) * 0.1              
    ]),
    np.concatenate([
        [-37.058, 0.487],               # 3. estimados de logit condicional
        [1.388, 0.644, -3.086],       
        np.ones(P) * 0.1              
    ])
]

# Tres métodos
methods = ["BFGS", "L-BFGS-B", "Nelder-Mead"]
results = []

# Estimación para cada combinación
for i, init in enumerate(init_params):
    for method in methods:
        res = estimate_SLL(x, j_star, omega, init, method)
        b_bar_hat = res.x[:P]
        sigma_hat = res.x[P:]
        beta_hat = b_bar_hat[:2]
        alpha_hat = np.append(b_bar_hat[2:], 0.0)
        loglik = -res.fun
        aic = 2 * len(res.x) - 2 * loglik
        results.append({
            "init_id": i+1,
            "method": method,
            "success": res.success,
            "loglik": loglik,
            "aic": aic,
            "beta": beta_hat,
            "alpha": alpha_hat,
            "sigma": sigma_hat,
            "params": res.x,
            "message": res.message
        })

# Modelo óptimo
best_model = min(results, key=lambda r: r["aic"])

# Errores estándar asintóticos
hess_fun = lambda p: SLL(p, x, j_star, omega)
hessian = nd.Hessian(hess_fun)(best_model["params"])
vcov = np.linalg.inv(hessian)
std_errors = np.sqrt(np.diag(vcov))

# Separar errores por tipo
std_beta = std_errors[:2]
std_alpha = np.append(std_errors[2:P], 0.0)
std_sigma = std_errors[P:]

 
# Mostrar todos los modelos
print("\n" + "#"*70)
print("RESULTADOS DE LOS 9 MODELOS MIXED LOGIT ESTIMADOS")
print("#"*70)

for res in results:
    print(f"\nMétodo: {res['method']} | Condición inicial #{res['init_id']}")
    print(f"Convergencia: {'Sí' if res['success'] else 'No'}")
    print(f"Log-verosimilitud: {res['loglik']:.3f}")
    print(f"AIC: {res['aic']:.2f}")
    
    print("Betas (medias):")
    for i, b in enumerate(res["beta"], 1):
        print(f"  β_{i} = {b:.4f}")
    
    print("Alphas (medias):")
    for i, a in enumerate(res["alpha"], 1):
        print(f"  α_{i} = {a:.4f}")
    
    print("Componentes de error (sigmas):")
    for i, s in enumerate(res["sigma"], 1):
        print(f"  σ_{i} = {s:.4f}")
    
    print("-" * 50)
    
# Mostrar el mejor modelo
print("\nMEJOR MODELO SEGÚN AIC")
print(f"Método: {best_model['method']} | Inicial #{best_model['init_id']}")
print(f"Log-Likelihood: {best_model['loglik']:.3f}")
print(f"AIC: {best_model['aic']:.2f}\n")

for i, b in enumerate(best_model["beta"], 1):
    print(f"beta_{i} = {b:.4f} ± {std_beta[i-1]:.4f}")
for i, a in enumerate(best_model["alpha"], 1):
    print(f"alpha_{i} = {a:.4f} ± {std_alpha[i-1]:.4f}")
for i, s in enumerate(best_model["sigma"], 1):
    print(f"sigma_{i} = {s:.4f} ± {std_sigma[i-1]:.4f}")
    
# Ordenar modelos por AIC
sorted_models = sorted(results, key=lambda r: r["aic"])

###################################################################
########################### TABLAS LATEX ##########################
###################################################################

# # Diccionario con nombres de parámetros en LaTeX
# rows = {
#     r"$\bar{\alpha}_1$": [],
#     r"$\bar{\alpha}_2$": [],
#     r"$\bar{\alpha}_3$": [],
#     r"$\bar{\alpha}_4$": [],
#     r"$\bar{\beta}_1$": [],
#     r"$\bar{\beta}_2$": [],
#     r"$\sigma_p$": [],
#     r"$\sigma_f$": [],
#     r"$\sigma_1$": [],
#     r"$\sigma_2$": [],
#     r"$\sigma_3$": [],
#     r"\textbf{LL}": [],
#     r"\textbf{AIC}": [],
# }

# methods_row = []
# inits_row = []

# for m in sorted_models:
#     a = m["alpha"]
#     b = m["beta"]
#     s = m["sigma"]

#     rows[r"$\bar{\alpha}_1$"].append(a[0])
#     rows[r"$\bar{\alpha}_2$"].append(a[1])
#     rows[r"$\bar{\alpha}_3$"].append(a[2])
#     rows[r"$\bar{\alpha}_4$"].append(a[3])
#     rows[r"$\bar{\beta}_p$"].append(b[0])
#     rows[r"$\bar{\beta}_f$"].append(b[1])
#     rows[r"$\sigma_p$"].append(s[0])
#     rows[r"$\sigma_f$"].append(s[1])
#     rows[r"$\sigma_1$"].append(s[2])
#     rows[r"$\sigma_2$"].append(s[3])
#     rows[r"$\sigma_3$"].append(s[4])
#     rows[r"\textbf{LL}"].append(m["loglik"])
#     rows[r"\textbf{AIC}"].append(m["aic"])

#     methods_row.append(m["method"])
#     inits_row.append(f"CI {m['init_id']}")

# # Construir tabla LaTeX
# latex_table = r"""\begin{table}[H]
# \centering
# \caption{Comparación de modelos Mixed Logit: parámetros estimados}
# \label{tab:comparacion_mixed}
# \scriptsize
# \renewcommand{\arraystretch}{1.1}
# \setlength{\tabcolsep}{3pt}
# \begin{tabular}{c""" + "c" * len(sorted_models) + r"""}
# \toprule
# \textbf{Método} & """ + " & ".join(methods_row) + r""" \\
# \textbf{Cond. inic.} & """ + " & ".join(inits_row) + r""" \\
# \midrule
# """

# for param, values in rows.items():
#     latex_table += f"{param} & " + " & ".join(f"{v:.2f}" for v in values) + r" \\" + "\n"

# latex_table += r"""\bottomrule
# \end{tabular}
# \end{table}
# """

# print(latex_table)


# # Crear tabla LaTeX transpuesta con las condiciones iniciales
# param_names = [
#     r"$\bar{\alpha}_1$", r"$\bar{\alpha}_2$", r"$\bar{\alpha}_3$", r"$\bar{\alpha}_4$",
#     r"$\bar{\beta}_p$", r"$\bar{\beta}_f$",
#     r"$\sigma_p$", r"$\sigma_f$", r"$\sigma_1$",
#     r"$\sigma_2$", r"$\sigma_3$"
# ]
# ci_labels = ["1. Estándar", "2. Nested logit", "3. Logit condicional"]

# # Inicializa el diccionario con cada parámetro como fila
# param_rows = {name: [] for name in param_names}

# for init in init_params:
#     alpha = np.append(init[:3], 0.0)
#     beta = init[3:5]
#     sigma = init[5:]
#     values = np.concatenate([alpha, beta, sigma])
#     for name, v in zip(param_names, values):
#         param_rows[name].append(v)

# # Construir tabla LaTeX
# latex_inits_transposed = r"""\begin{table}[H]
# \centering
# \caption{Vectores de condiciones iniciales usados en la estimación del modelo Mixed Logit}
# \label{tab:init_mixed_transposed}
# \scriptsize
# \renewcommand{\arraystretch}{1.1}
# \setlength{\tabcolsep}{5pt}
# \begin{tabular}{lccc}
# \toprule
# \textbf{CI} & \textbf{1. Estándar} & \textbf{2. Nested logit} & \textbf{3. Logit condicional} \\
# \midrule
# """

# for name in param_names:
#     latex_inits_transposed += f"{name} & " + " & ".join(f"{v:.3f}" for v in param_rows[name]) + r" \\" + "\n"

# latex_inits_transposed += r"""\bottomrule
# \end{tabular}
# \end{table}
# """

# print(latex_inits_transposed)


# # Tabla comparativa de modelos Logit condicional, Nested Logit y Mixed Logit

# # Parámetros logit condicional
# beta_logit = [-37.058, 0.487]
# se_beta_logit = [2.399, 0.120]
# alpha_logit = [1.388, 0.644, -3.086, 0.0]
# se_alpha_logit = [0.088, 0.054, 0.145, 0.0]
# aic_logit = 5327.11

# # Parámetros nested logit
# beta_nested = [-28.196, 0.387]
# se_beta_nested = [3.780, 0.102]
# alpha_nested = [1.308, 0.734, -1.930, 0.0]
# se_alpha_nested = [0.079, 0.070, 0.316, 0.0]
# lambda_nested = [0.702, 0.525]
# se_lambda_nested = [0.106, 0.120]
# aic_nested = 5322.20

# # Tabla LaTeX
# latex_comparacion_modelos = r"""\begin{table}[H]
# \centering
# \caption{Comparación de modelos Logit Condicional, Nested Logit y Mixed Logit}
# \label{tab:comparacion_tres_modelos}
# \scriptsize
# \renewcommand{\arraystretch}{1.2}
# \begin{tabular}{lcccccc}
# \toprule
# \textbf{Parámetro} & \textbf{Mixed logit} & \textbf{EE} & \textbf{Nested logit} & \textbf{EE} & \textbf{Logit condicional} & \textbf{EE} \\
# \midrule
# """

# param_names = [r"\beta_p", r"\beta_f"]
# for i in range(2):
#     latex_comparacion_modelos += (
#         f"${param_names[i]}$ & {best_model['beta'][i]:.3f} & {std_beta[i]:.3f} & "
#         f"{beta_nested[i]:.3f} & {se_beta_nested[i]:.3f} & "
#         f"{beta_logit[i]:.3f} & {se_beta_logit[i]:.3f} \\\\\n"
#     )

# latex_comparacion_modelos += "\\midrule\n"

# for i in range(4):
#     latex_comparacion_modelos += (
#         f"$\\alpha_{{{i+1}}}$ & {best_model['alpha'][i]:.3f} & {std_alpha[i]:.3f} & "
#         f"{alpha_nested[i]:.3f} & {se_alpha_nested[i]:.3f} & "
#         f"{alpha_logit[i]:.3f} & {se_alpha_logit[i]:.3f} \\\\\n"
#     )

# latex_comparacion_modelos += "\\midrule\n"

# for i in range(2):
#     latex_comparacion_modelos += (
#         f"$\\lambda_{{{i+1}}}$ & -- & -- & "
#         f"{lambda_nested[i]:.3f} & {se_lambda_nested[i]:.3f} & -- & -- \\\\\n"
#     )

# latex_comparacion_modelos += "\\midrule\n"

# for i in range(5):
#     latex_comparacion_modelos += (
#         f"$\\sigma_{{{i+1}}}$ & {best_model['sigma'][i]:.3f} & {std_sigma[i]:.3f} & -- & -- & -- & -- \\\\\n"
#     )

# latex_comparacion_modelos += "\\midrule\n"
# latex_comparacion_modelos += (
#     f"\\textbf{{AIC}} & {best_model['aic']:.2f} & & "
#     f"{aic_nested:.2f} & & {aic_logit:.2f} & \\\\\n"
# )

# latex_comparacion_modelos += r"""\bottomrule
# \end{tabular}
# \begin{minipage}{0.8\linewidth}
# \ \newline
# \small \textit{Nota:} Los errores estándar (EE) fueron calculados mediante la teoría asintótica utilizando el hessiano numérico aproximado con \texttt{numdifftools}. En el caso del modelo Nested Logit, los parámetros $\lambda_r$ fueron transformados usando el método delta.
# \end{minipage}
# \end{table}
# """


# print(latex_comparacion_modelos)
