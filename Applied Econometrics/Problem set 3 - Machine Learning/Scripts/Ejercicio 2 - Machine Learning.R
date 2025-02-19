# Econometría Aplicada
# Problem Set 3
# Ejercicio 2
# Max Brando Serna Leyva
# 2023-2025

rm(list = ls())

if (dev.cur() > 1) {
  dev.off()  # Cierra el dispositivo gráfico activo
}

setwd("D:/Eco aplicada/Tarea 3")

##### 2.1 Predicción de la inflación subyacente para el mes de octubre 2024 (pública en noviembre). ####
# Usar como máximo desde el periodo 2015.

library(glmnet)
library(siebanxicor)
library(tidyverse)
library(caret)
library(randomForest)
library(haven)
library(readxl)
library(xtable)
library(imputeTS)

# Establecemos el token que solicita banxico (https://www.banxico.org.mx/SieAPIRest/service/v1/token)
setToken("bb8e7e5cb1a45ba269071f53f4a4a130722e573fff78d06e72db45f8786cc9fb")

# Creamos el vector que contenga el ID de cada serie que nos interesa
# Los ID se encuentran en el catalogo de datos del banxico
# https://www.banxico.org.mx/SieAPIRest/service/v1/doc/catalogoSeries

# Tomamos las series y su ID de las variables de interés
# Inflación
# # Inflación subyacente "SP74662"
# # INPC "SP30577"
# # INPC subyacente mercancias "SP74626"
# # INPC subyacente servicios "SP74628"
# # INPC subyacente "SP74625"
# Indicadores relacionados a Choques de oferta (Sectores > Índices de Precios al Consumidor y UDIS > Otros Indicadores de Precios Mensuales)
# # salarios "SP74826"
# # Energeticos "SP74827"
# # Tipo de cambio "SP74828"
# Demanda
# # Cetes a 28 días "SF282"
# # Cetes 91 dias "SF3338"
# # Cetes 128 días "SF3270"
# # Cetes 364 dias "SF3367"
# # Indicador de confianzar del consumidor desestacionalizado "SR16064"
# Tipo de cambio, M1 y TIIE
# # Tipo de cambio "SF17908"
# # M1 "SF1"
# # TIIE a 28 días "SF283"
# Expectativas
# # Inf. subyacente para el mes en curso "SR14313"
# # Inf. subyacente para el siguiente mes "SR17296"


series_banxico <- c("SP74662", "SP30577", "SP74626", "SP74628", "SP74625", "SP74826","SP74827",
                    "SP74828", "SF282", "SF3338", "SF3270", "SF3367", "SR16064",
                    "SF17908", "SF1", "SF283", "SR14313", "SR17296")

# Primero, crearemos un objeto que indique que queremos la fecha disponible más reciente:
hoy <- "2024-10-28"

# Luego, con el comando getSeriesData() crearemos una lista que contenga las series de interés,
# partiendo de los ID y del periodo que nos importa:
series <- getSeriesData(series_banxico, '2015-01-01', hoy)

#Para este paso, partiendo de la lista anterior crearemos los data frames que contenga 
#cada serie de manera independiente:
infl_sub <- getSerieDataFrame(series, "SP74662")
inpc <- getSerieDataFrame(series, "SP30577")
inpc_sub_mer <- getSerieDataFrame(series, "SP74626")
inpc_sub_serv <- getSerieDataFrame(series, "SP74628")
inpc_sub <- getSerieDataFrame(series, "SP74625")
shock_sal <- getSerieDataFrame(series, "SP74826")
shock_energ <- getSerieDataFrame(series, "SP74827")
shock_tc <- getSerieDataFrame(series, "SP74828")
cetes28 <- getSerieDataFrame(series, "SF282")
cetes91 <- getSerieDataFrame(series, "SF3338")
cetes128 <- getSerieDataFrame(series, "SF3270")
cetes364 <- getSerieDataFrame(series, "SF3367")
icco <- getSerieDataFrame(series, "SR16064")
tc_fix <- getSerieDataFrame(series, "SF17908")
m1 <- getSerieDataFrame(series, "SF1")
tasa_int <- getSerieDataFrame(series, "SF283")
expected_inf_t <- getSerieDataFrame(series, "SR14313")

# Combinar las series en un solo dataframe basado en la columna 'date'
# Usamos la función full_join para asegurarnos de que las fechas se alineen correctamente
variables <- c("infl_sub", "inpc", "inpc_sub_mer", "inpc_sub_serv", "inpc_sub", 
               "shock_sal", "shock_energ", "shock_tc", "cetes28", "cetes91", 
               "cetes128", "cetes364", "icco", "tc_fix", "m1", "tasa_int",
               "expected_inf_t")

# Obtener los data frames usando mget
data_frames_list <- mget(variables)

# Usar full_join para combinar todos los data frames
data_combined <- reduce(data_frames_list, full_join, by = "date")

# Renombrar las columnas para mayor claridad
# Asignar nuevos nombres a las columnas directamente
colnames(data_combined) <- c("date", variables)

# Usaremos los rezagos de las variables como predictoras. Por tanto, crearemos un nuevo data frame
# con infl_sub en tiempo t y los rezagos del resto
data_combined_original <- data_combined
data_combined <- cbind(data_combined_original[,c("date", "infl_sub")],
      lag(select(data_combined_original, -one_of(c("date", "infl_sub"))))
      )

# Ajustamos nombres
lagged_names <- paste(names(data_combined)[3:length(data_combined)], "_lag", sep = "")
names(data_combined)[3:length(data_combined)] <- lagged_names

# Creamos 6 rezagos para la inflación
data_combined$infl_sub_lag1 <- lag(data_combined$infl_sub, 1)
data_combined$infl_sub_lag2 <- lag(data_combined$infl_sub, 2)
data_combined$infl_sub_lag3 <- lag(data_combined$infl_sub, 3)
data_combined$infl_sub_lag4 <- lag(data_combined$infl_sub, 4)
data_combined$infl_sub_lag5 <- lag(data_combined$infl_sub, 5)
data_combined$infl_sub_lag6 <- lag(data_combined$infl_sub, 6)


# Eliminar cualquier fila con valores NA
data_combined <- na.omit(data_combined)

# Nos quedamos con las variables predictoras al tiempo t, que servirán para realizar la predicción de infl_sub
# al tiempo t + 1
names(data_combined_original)[3:length(data_combined_original)] <- lagged_names
data_combined_original$infl_sub_lag1 <- lag(data_combined_original$infl_sub, 1)
data_combined_original$infl_sub_lag2 <- lag(data_combined_original$infl_sub, 2)
data_combined_original$infl_sub_lag3 <- lag(data_combined_original$infl_sub, 3)
data_combined_original$infl_sub_lag4 <- lag(data_combined_original$infl_sub, 4)
data_combined_original$infl_sub_lag5 <- lag(data_combined_original$infl_sub, 5)
data_combined_original$infl_sub_lag6 <- lag(data_combined_original$infl_sub, 6)
data_combined_original <- data_combined_original[nrow(data_combined_original),]

rm(list=setdiff(ls(), c("data_combined", "data_combined_original")))

###### LASSO ####

# Dividir los datos en entrenamiento (75%) y prueba (25%)

training_share <- .85
n <- nrow(data_combined)
set_entrenamiento <- data_combined[1:round(n*training_share),]
set_test <- data_combined[(round(n*training_share)+1):n,]

# Preparar la matriz de diseño y el vector de respuesta
x <- as.matrix(as.ts(set_entrenamiento)[, -c(1, 2)]) # todas las columnas menos la primera
y <- as.numeric(as.ts(set_entrenamiento)[, 2])              # la primera columna como respuesta
# Ajustar el modelo LASSO
set.seed(1)  # Para reproducibilidad
cv_model <- cv.glmnet(x, y, alpha = 1)  # alpha = 1 para LASSO

# Mostrar el valor óptimo de lambda
best_lambda <- cv_model$lambda.min
print(best_lambda)

# Extraer coeficientes del modelo en el mejor lambda
coefficients <- coef(cv_model, s = "lambda.min")
round(coefficients, 2)

#LASSO nos dice que las variables relevantes son: infl_sub_lag, shock_sal_lag e infl_sub_lag6. No obstante, usaremos todas por el momento.

formula <- infl_sub ~ inpc_lag + inpc_sub_mer_lag + inpc_sub_serv_lag + 
  inpc_sub_lag + shock_sal_lag + shock_energ_lag + shock_tc_lag + 
  cetes28_lag + cetes91_lag + cetes128_lag + cetes364_lag + 
  icco_lag + tc_fix_lag + m1_lag + tasa_int_lag + 
  expected_inf_t_lag + infl_sub_lag1 + infl_sub_lag2 + infl_sub_lag3 + 
  infl_sub_lag4 + infl_sub_lag5 + infl_sub_lag6

###### SVM ####

# Entrenar el modelo SVM usando las variables adicionales
set.seed(1)
# Utilizamos cross validation para hallar el parámetro C óptimo
modelo_svm <- train(formula,
              data = as.ts(set_entrenamiento),
              method = "svmLinear",
              preProcess = c("center","scale"),
              tuneGrid = expand.grid(C = seq(0.1, 2, length = 20)))
#View the model
modelo_svm
cat("El valor de C usado en el mejor modelo es C =", modelo_svm$bestTune$C)
# Hacer predicciones con los datos de prueba
y_pred_svm = predict(modelo_svm, newdata = as.ts(set_test))

# Evaluar el rendimiento (RMSE)
rmse_svm <- sqrt(mean((y_pred_svm - set_test$infl_sub)^2))
cat("RMSE del modelo SVM: ", rmse_svm, "\n")

#### Pronóstico octubre 2024 con SVM
prediccion_octubre_svm <- predict(modelo_svm, newdata = as.ts(data_combined_original))
prediccion_octubre_svm

###### Random forest ####

# Utilizamos cross validation para determinar el número de variables que mejor
# rendimiento tiene
set.seed(1)
cv_randomF <- rfcv(trainx = as.ts(set_entrenamiento)[,-2],
                   trainy = as.ts(set_entrenamiento)[,2],
                   step = 0.9,
                   cv.fold = 5)

# nos dice cuál es el número óptimo
mtry_CV <- cv_randomF$error.cv[which.min(cv_randomF$error.cv)]
mtry_CV <- as.numeric(names(mtry_CV))

# Entrenar el modelo Random Forest usando el regularizador indicado
set.seed(1)
modelo_rf = randomForest(formula = formula,
                         data = set_entrenamiento,
                         ntree = 500,
                         mtry = mtry_CV)

# Hacer predicciones
predRF_1 <- predict(modelo_rf, newdata = as.ts(set_test))

# Utilizamos otra función que ya arroja el modelo con el regularizador óptimo mediante CV
set.seed(1)
modelo_rf2 <- 
  train(
    formula,
    data = as.ts(set_entrenamiento),
    method = 'rf',
    tuneLength = 10,
    prox = TRUE       # Extra information
  )
modelo_rf2
modelo_rf2$finalModel # el modelo elegido

# predicciones
predRF_2 <- 
  predict(
    modelo_rf2,
    as.ts(set_test)
  )

# Evaluar el rendimiento (RMSE)
rmse_rf1 <- sqrt(mean((predRF_1 - set_test$infl_sub)^2))
cat("RMSE del modelo Random Forest 1: ", rmse_rf1, "\n")

rmse_rf2 <- sqrt(mean((predRF_2 - set_test$infl_sub)^2))
cat("RMSE del modelo Random Forest 2: ", rmse_rf2, "\n")

if (rmse_rf2 < rmse_rf1) {
  modelo_rf <- modelo_rf2
  rmse_rf <- rmse_rf2
  cat("El mejor modelo de RF es el modelo 2")
} else {
  cat("El mejor modelo de RF es el modelo 1")
  rmse_rf <- rmse_rf1
}

### Pronostico para RF
prediccion_octubre_rf <- predict(modelo_rf, newdata = as.ts(data_combined_original))
prediccion_octubre_rf

###### Redes neuronales ####

# Ahora entrenaremos una red neuronal únicamente utilizando las variables seleccionadas por LASSO
# Control de entrenamiento con validación cruzada repetida
control <- trainControl(method = "boot", number = 10)

# Ajuste del modelo usando `train` de `caret`, con preprocesamiento para normalizar
set.seed(1)
modelo_nn <- train(
  infl_sub ~ infl_sub_lag1 + shock_sal_lag + infl_sub_lag6,
  data = as.ts(set_entrenamiento),     # Datos
  method = "nnet",              # Método para redes neuronales
  trControl = control,          # Configuración de cross-validation
  tuneGrid = expand.grid(size = seq(1, 15), decay = c(0.01, 0.05, 0.1)),  # Hiperparámetros
  preProcess = c("center", "scale"),  # Normalización de los datos
  linout = TRUE,                # Para regresión
  trace = FALSE
)
# Muestra el mejor modelo y los resultados de cross-validation
print(modelo_nn)
cat("El mejor modelo utiliza", modelo_nn$bestTune$size, "nodos en la única capa oculta, y un regularizador 'decay' de", modelo_nn$bestTune$decay)
y_pred_nn <- predict(modelo_nn, newdata = as.ts(set_test))

# Evaluar el rendimiento (RMSE)
rmse_nn <- sqrt(mean((y_pred_nn - set_test$infl_sub)^2))
cat("RMSE del modelo de Redes Neuronales: ", rmse_nn, "\n")


### Pronostico para Redes neuronales
prediccion_octubre_nn <- predict(modelo_nn, newdata = as.ts(data_combined_original))
prediccion_octubre_nn

###### Comparación + ensemble ####
# Gráfico para comparar los valores reales vs predichos por los tres modelos
# Crear y guardar el gráfico en un archivo PDF

# RMSE del modelo emseble
rmse_ensemble <- sqrt(mean((rowMeans(data.frame(y_pred_nn, y_pred_svm)) - set_test$infl_sub)^2))

# Crear un nuevo dataframe que contenga las predicciones y los intervalos
data_plot <- data.frame(
  date = data_combined$date,
  inflacion_real = data_combined$infl_sub,
  pred_svm = predict(modelo_svm, as.ts(data_combined)),
  pred_nn = predict(modelo_nn, as.ts(data_combined)),
  pred_rf = predict(modelo_rf, as.ts(data_combined))
)
data_plot$ensemble <- rowMeans(data_plot[,3:4])
data_plot <- data_plot %>% 
  filter(date>"2020-01-01")

corte <- set_test$date[1]

# Guardar el gráfico en un archivo jpeg
jpeg("Graficas/Comparacion.jpg", width = 2500, height = 1500, res = 300)

# Crear el gráfico con ggplot
ggplot(data_plot, aes(x = date)) +
  
  # Línea de inflación real
  geom_line(aes(y = inflacion_real, color = "Inflación observada"), linewidth = 1) +
  
  # Predicciones del modelo SVM
  geom_line(aes(y = pred_svm, color = "Predicción SVM"), size = 0.7, linetype = "longdash") +
  
  # Predicciones del modelo Redes Neuronales
  geom_line(aes(y = pred_nn, color = "Predicción RN"), size = 0.7, linetype = "F1") +
  
  # Predicciones del modelo Random Forest
  geom_line(aes(y = pred_rf, color = "Predicción RF"), size = 0.7, linetype = "twodash") +
  
  # Predicciones del modelo Ensemble
  geom_line(aes(y = ensemble, color = "Ensemble SVM + RN"), size = .7, linetype = "dotdash") +
  
  # Ajustes generales de la gráfica
  labs(title = "Pronóstico de la inflación subyacente (%)",
       subtitle = "Algoritmos utilizados: SVM, Red neuronal, Random Forest y un Ensemble SVM + RN",
       y = NULL, x = NULL, color = NULL,
       caption = "Fuente: Sistema de información económica del Banxico. El area sombreada representa el sample test") +
  
  theme_minimal() +

  geom_vline(xintercept = as.Date(corte), linetype = "dashed", color = "black", size = 0.7) +
  
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  
  scale_y_continuous(breaks = seq(0, max(data_plot[,2:5]), by = .5)) + # Adjust the interval as needed

  theme(
    axis.title.y = element_text(size = 10),
    legend.position = "bottom",  # Move legend below plot
    plot.caption = element_text(hjust = 0)
  ) +
  
  scale_color_manual(values = c("Inflación observada" = "darkgray", 
                                "Predicción SVM" = "blue", 
                                "Predicción RN" = "red", 
                                "Predicción RF" = "green",
                                "Ensemble SVM + RN" = "black"),
                     guide = guide_legend(nrow = 2)) +
  
  annotate("rect", xmin = corte, xmax = as.Date('2024-09-01'), ymin = min(data_plot[,2:5]), ymax = max(data_plot[,2:5]),
           alpha = .2)


# Cerrar el archivo PDF
dev.off()

# Crear un dataframe con los RMSE reales de los modelos
rmse_data <- data.frame(
  Model = c("SVM", "Random Forest", "Redes Neuronales", "Ensemble"),
  RMSE = c(rmse_svm, rmse_rf, rmse_nn, rmse_ensemble)
)

# Convertir el dataframe de RMSE a LaTeX
latex_table_rmse <- xtable(rmse_data)

# Imprimir la tabla en formato LaTeX
print(latex_table_rmse)

# Mostrar el resultado del pronóstico
cat("Predicción Redes Neuronales / SVM / RF para octubre 2024: ",
    c(prediccion_octubre_nn, prediccion_octubre_svm, prediccion_octubre_rf), "\n")

# Crear el dataframe con las predicciones de octubre 2024 para cada modelo
prediccion_data <- data.frame(
  Model = c("Redes Neuronales", "SVM", "Random Forest", "Ensemble SVM + NN"),
  Prediccion_Octubre_2024 = as.numeric(last(data_plot[,3:6]))
)

# Convertir el dataframe de predicciones a LaTeX
latex_table_pred <- xtable(prediccion_data)

# Imprimir la tabla en formato LaTeX
print(latex_table_pred)


##### 2.2 Predicción del empleo (asegurados totales IMSS) para el mes de octubre 2024 (publica en noviembre). ####
# Usar como máximo desde el periodo 2015.


### Predicción del empleo (aseguradostotalesIMSS) para elmes de octubre 2024(publica en noviembre). 
### Usar como máximodesde el periodo 2015.

rm(list = ls())

# Establecemos el token que solicita banxico (https://www.banxico.org.mx/SieAPIRest/service/v1/token)
setToken("bb8e7e5cb1a45ba269071f53f4a4a130722e573fff78d06e72db45f8786cc9fb")

# Creamos el vector que contenga el ID de cada serie que nos interesa
# Los ID se encuentran en el catalogo de datos del banxico
# https://www.banxico.org.mx/SieAPIRest/service/v1/doc/catalogoSeries

# Tomamos las series y su ID de las variables de interés
# # INPC "SP30577"
# Indicadores relacionados a Choques de oferta (Sectores > Índices de Precios al Consumidor y UDIS > Otros Indicadores de Precios Mensuales)
# # salarios "SP74826"
# # Energeticos "SP74827"
# # Tipo de cambio "SP74828"
# # Indicador de confianzar del consumidor desestacionalizado "SR16064"
# Remuneraciones medias reales por persona ocupada "SL11439"
# Productividad laboral por persona ocupada "SL11447"
# Tasa de desocupación abierta en áreas urbanas "SL1"
# Salarios Mínimos General Índice Real, Dic2018=100 "SL11297"

series_banxico <- c("SP30577","SP74826","SP74827",
                    "SP74828", "SR16064", "SL11439", "SL11447",
                    "SL1", "SL11297")

# Primero, crearemos un objeto que indique que queremos la fecha disponible más reciente:
hoy <- "2024-10-28"

# Luego, con el comando getSeriesData() crearemos una lista que contenga las series de interés,
# partiendo de los ID y del periodo que nos importa:
series <- getSeriesData(series_banxico, '2015-01-01', hoy)

#Para este paso, partiendo de la lista anterior crearemos los data frames que contenga 
#cada serie de manera independiente:
inpc <- getSerieDataFrame(series, "SP30577")
shock_sal <- getSerieDataFrame(series, "SP74826")
shock_energ <- getSerieDataFrame(series, "SP74827")
shock_tc <- getSerieDataFrame(series, "SP74828")
icco <- getSerieDataFrame(series, "SR16064")
remuneraciones <- getSerieDataFrame(series, "SL11439")
productividad <- getSerieDataFrame(series, "SL11447")
minwage <- getSerieDataFrame(series, "SL11297")

# Combinar las series en un solo dataframe basado en la columna 'date'
# Usamos la función full_join para asegurarnos de que las fechas se alineen correctamente
variables <- c("inpc", "shock_sal", "shock_energ", "shock_tc", "icco", "remuneraciones", 
               "productividad", "minwage")

# Obtener los data frames usando mget
data_frames_list <- mget(variables)

# Usar full_join para combinar todos los data frames
data_combined <- reduce(data_frames_list, full_join, by = "date")

# Renombrar las columnas para mayor claridad
# Asignar nuevos nombres a las columnas directamente
colnames(data_combined) <- c("date", variables)

rm(list=setdiff(ls(), "data_combined"))

trabajadores <- read_dta("datos/trabajadores.dta")

datos <- read_excel("datos/indicadores_2.2.xls")
datos <- datos %>% 
  filter(datos$fecha_dia<as.Date("2024-09-01")) %>%  # removemos los datos imputados. imputaremos mediante arima
  select(fecha_dia, desocup, tasa_informalidad, igae)

# Convertir var3 a formato fecha
trabajadores$var3 <- as.Date(trabajadores$var3, format = "%d/%m/%Y")
datos$fecha_dia <- as.Date(datos$fecha_dia, format = "%d/%m/%Y")

trabajadores <- trabajadores[, -1]

colnames(trabajadores)[colnames(trabajadores) == "var3"] <- "fecha_dia"

# Filtrar los datos a partir de enero de 2015
trabajadores <- trabajadores %>%
  dplyr::filter(fecha_dia >= as.Date("2015-01-01"))

# merge
imss <- merge(trabajadores, datos, by = "fecha_dia", all.x = TRUE)

data_combined <- merge(data_combined, imss, by.x = "date", by.y = "fecha_dia")

rm(datos, trabajadores, imss)

# Function to impute missing values using auto.arima
impute_arima <- function(df) {
  df_imputed <- df  # Copy the original data frame
  
  for (col in names(df)) {
    if (any(is.na(df[[col]]))) {  # Check if column has any NA values
      # Impute missing values in the column with ARIMA-based method
      df_imputed[[col]] <- na_kalman(df[[col]], model = "auto.arima")
    }
  }
  
  return(df_imputed)
}

# Applying the function to your data frame
data_combined <- impute_arima(data_combined)

data_combined_original <- data_combined
data_combined <- cbind(data_combined_original[,c("date", "ta")],
                       lag(select(data_combined_original, -one_of(c("date", "ta"))))
)

# Ajustamos nombres
lagged_names <- paste(names(data_combined)[3:length(data_combined)], "_lag", sep = "")
names(data_combined)[3:length(data_combined)] <- lagged_names

# Creamos 6 rezagos para la variable de trabajadores
data_combined$ta_lag1 <- lag(data_combined$ta, 1)
data_combined$ta_lag2 <- lag(data_combined$ta, 2)
data_combined$ta_lag3 <- lag(data_combined$ta, 3)
data_combined$ta_lag4 <- lag(data_combined$ta, 4)
data_combined$ta_lag5 <- lag(data_combined$ta, 5)
data_combined$ta_lag6 <- lag(data_combined$ta, 6)

# Eliminar cualquier fila con valores NA
data_combined <- na.omit(data_combined)

# Nos quedamos con las variables predictoras al tiempo t, que servirán para realizar la predicción de infl_sub
# al tiempo t + 1
data_combined_original <- data_combined_original %>% 
  select(date, ta, everything())
names(data_combined_original)[3:length(data_combined_original)] <- lagged_names
data_combined_original$ta_lag1 <- lag(data_combined_original$ta, 1)
data_combined_original$ta_lag2 <- lag(data_combined_original$ta, 2)
data_combined_original$ta_lag3 <- lag(data_combined_original$ta, 3)
data_combined_original$ta_lag4 <- lag(data_combined_original$ta, 4)
data_combined_original$ta_lag5 <- lag(data_combined_original$ta, 5)
data_combined_original$ta_lag6 <- lag(data_combined_original$ta, 6)
data_combined_original <- data_combined_original[nrow(data_combined_original),]

rm(list=setdiff(ls(), c("data_combined", "data_combined_original")))


# Dividir los datos en entrenamiento (75%) y prueba (25%)

training_share <- 0.8
n <- nrow(data_combined)
set_entrenamiento <- data_combined[1:round(n*training_share),]
set_test <- data_combined[(round(n*training_share)+1):n,]

formula <- ta ~ inpc_lag + shock_sal_lag + shock_energ_lag + shock_tc_lag + 
  icco_lag + remuneraciones_lag + productividad_lag + minwage_lag + 
  desocup_lag + tasa_informalidad_lag + igae_lag + ta_lag1 + 
  ta_lag2 + ta_lag3 + ta_lag4 + ta_lag5 + ta_lag6

###### SVM ####

# Entrenar el modelo SVM usando las variables adicionales
set.seed(1)
modelo_svm <- train(formula,
                    data = as.ts(set_entrenamiento),
                    method = "svmLinear",
                    preProcess = c("center","scale"),
                    tuneGrid = expand.grid(C = seq(0.1, 2, length = 20)))
#View the model
modelo_svm
cat("El valor de C usado en el mejor modelo es C =", modelo_svm$bestTune$C)
# Hacer predicciones con los datos de prueba
y_pred_svm = predict(modelo_svm, newdata = as.ts(set_test))

# Evaluar el rendimiento (RMSE)
rmse_svm <- sqrt(mean((y_pred_svm - set_test$ta)^2))
cat("RMSE del modelo SVM: ", rmse_svm, "\n")

#### Pronóstico octubre 2024 con SVM
prediccion_octubre_svm <- predict(modelo_svm, newdata = as.ts(data_combined_original))
prediccion_octubre_svm

###### Random forest ####

# Utilizamos cross validation para determinar el número de variables que mejor
# rendimiento tiene
set.seed(1)
cv_randomF <- rfcv(trainx = as.ts(set_entrenamiento)[,-2],
                   trainy = as.ts(set_entrenamiento)[,2],
                   step = 0.9,
                   cv.fold = 4)

# nos dice cuál es el número óptimo
mtry_CV <- cv_randomF$error.cv[which.min(cv_randomF$error.cv)]
mtry_CV <- as.numeric(names(mtry_CV))
cat("El mejor modelo de RF utiliza", mtry_CV, "variables según CV")

# Entrenar el modelo Random Forest usando el regularizador indicado
set.seed(1)
modelo_rf = randomForest(formula = formula,
                         data = set_entrenamiento,
                         ntree = 500,
                         mtry = mtry_CV)

# Hacer predicciones
predRF_1 <- predict(modelo_rf, newdata = as.ts(set_test))

# Utilizamos otra función que ya arroja el modelo con el regularizador óptimo mediante CV
set.seed(1)
modelo_rf2 <- 
  train(
    formula,
    data = as.ts(set_entrenamiento),
    method = 'rf',
    tuneLength = 10,
    prox = TRUE       # Extra information
  )
modelo_rf2
modelo_rf2$finalModel # el modelo elegido
modelo_rf2$finalModel$tuneValue

# predicciones
predRF_2 <- 
  predict(
    modelo_rf2,
    as.ts(set_test)
  )

# Evaluar el rendimiento (RMSE)
rmse_rf1 <- sqrt(mean((predRF_1 - set_test$ta)^2))
cat("RMSE del modelo Random Forest 1: ", rmse_rf1, "\n")

rmse_rf2 <- sqrt(mean((predRF_2 - set_test$ta)^2))
cat("RMSE del modelo Random Forest 2: ", rmse_rf2, "\n")

if (rmse_rf2 < rmse_rf1) {
  modelo_rf <- modelo_rf2
  rmse_rf <- rmse_rf2
  y_pred_RF <- predRF_2
  cat("El mejor modelo de RF es el modelo 2")
} else {
  cat("El mejor modelo de RF es el modelo 1")
  rmse_rf <- rmse_rf1
  y_pred_RF <- predRF_1
}

### Pronostico para RF
prediccion_octubre_rf <- predict(modelo_rf, newdata = as.ts(data_combined_original))
prediccion_octubre_rf

###### Redes neuronales ####

# # Ahora entrenaremos una red neuronal únicamente utilizando las variables seleccionadas por LASSO
# set.seed(1)
# # Control de entrenamiento con validación cruzada repetida
# control <- trainControl(method = "repeatedcv", number = 10, repeats = 5)
# 
# # Ajuste del modelo usando `train` de `caret`, con preprocesamiento para normalizar
# modelo_nn <- train(
#   ta ~ shock_energ_lag + igae_lag + ta_lag1,
#   data = as.ts(set_entrenamiento),     # Datos
#   method = "nnet",              # Método para redes neuronales
#   trControl = control,          # Configuración de cross-validation
#   tuneGrid = expand.grid(size = seq(1, 15), decay = c(0.01, 0.05, 0.1)),  # Hiperparámetros
#   preProcess = c("center", "scale"),  # Normalización de los datos
#   linout = TRUE,                # Para regresión
#   trace = FALSE
# )
# # Muestra el mejor modelo y los resultados de cross-validation
# print(modelo_nn)
# cat("El mejor modelo utiliza", modelo_nn$bestTune$size, "nodos en la única capa oculta, y un regularizador 'decay' de", modelo_nn$bestTune$decay)
# y_pred_nn <- predict(modelo_nn, newdata = as.ts(set_test))
# 
# # Evaluar el rendimiento (RMSE)
# rmse_nn <- sqrt(mean((y_pred_nn - set_test$ta)^2))
# cat("RMSE del modelo de Redes Neuronales: ", rmse_nn, "\n")

### Pronostico para Redes neuronales
# prediccion_octubre_nn <- predict(modelo_nn, newdata = as.ts(data_combined_original))
# prediccion_octubre_nn


###### LASSO ####
# Preparar los datos para el modelo Lasso
x_train <- model.matrix(ta ~ ., as.ts(set_entrenamiento))[, -1]
y_train <- set_entrenamiento$ta
x_test <- model.matrix(ta ~ ., as.ts(set_test))[, -1]

# Ajustar el modelo Lasso
set.seed(1)
modelo_lasso <- cv.glmnet(x_train, y_train, alpha = 1)
modelo_lasso$lambda.min
# variables seleccionadas por LASSO
round(coef(modelo_lasso, s = "lambda.min"), 2)

# LASSO sugiere que las mejores variables son shock_energ_lag + igae_lag + ta_lag1

# Hacer predicciones con el mejor modelo Lasso según CV 
pred_lasso <- predict(modelo_lasso, s = "lambda.min", newx = x_test)

# Evaluar el rendimiento (RMSE)
rmse_lasso <- sqrt(mean((pred_lasso - set_test$ta)^2))
cat("RMSE del modelo Lasso: ", rmse_lasso, "\n")

prediccion_octubre_LASSO <- predict(modelo_lasso, s = "lambda.min",
                     newx = model.matrix(ta ~ ., as.ts(data_combined_original))[, -1])
prediccion_octubre_LASSO

###### Comparación + ensemble ####

# RMSE del modelo emseble
rmse_ensemble <- sqrt(mean((rowMeans(data.frame(y_pred_svm, pred_lasso)) - set_test$ta)^2))

# Crear un nuevo dataframe que contenga las predicciones
data_plot <- data.frame(
  date = data_combined$date,
  ta_observados = data_combined$ta,
  pred_svm = predict(modelo_svm, as.ts(data_combined)),
  pred_lasso = predict(modelo_lasso, s = "lambda.min",
                       newx = model.matrix(ta ~ ., as.ts(data_combined))[, -1]),
  pred_rf = predict(modelo_rf, as.ts(data_combined))
)
data_plot$ensemble <- rowMeans(data_plot[,3:4])
data_plot <- data_plot %>% 
  filter(date>"2020-01-01")

corte <- set_test$date[1]

# Guardar el gráfico en un archivo PDF
jpeg("Graficas/Comparacion2.jpg", width = 2500, height = 1500, res = 300)

# Crear el gráfico con ggplot
ggplot(data_plot, aes(x = date)) +
  
  # Línea de inflación real
  geom_line(aes(y = ta_observados, color = "Trabajadores formales observados"), size = 1) +
  
  # Predicciones del modelo SVM
  geom_line(aes(y = pred_svm, color = "Predicción SVM"), size = 0.7, linetype = "longdash") +
  
  # Predicciones del modelo LASSO
  geom_line(aes(y = lambda.min, color = "Predicción LASSO"), size = 0.7, linetype = "F1") +
  
  # Predicciones del modelo Random Forest
  geom_line(aes(y = pred_rf, color = "Predicción RF"), size = 0.7, linetype = "twodash") +
  
  # Predicciones del modelo Ensemble
  geom_line(aes(y = ensemble, color = "Ensemble SVM + LASSO"), size = .7, linetype = "dotdash") +
  
  # Ajustes generales de la gráfica
  labs(title = "Pronóstico del empleo formal (en miles)",
       subtitle = "Algoritmos utilizados: SVM, LASSO y Random Forest",
       y = NULL, x = NULL, color = NULL,
       caption = "Fuente: IMSS y sistema de información económica del Banxico. El area sombreada representa el sample test") +
  
  theme_minimal() +
  
  geom_vline(xintercept = as.Date(corte), linetype = "dashed", color = "black", size = 0.7) +
  
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  
  scale_y_continuous(breaks = seq(0, max(data_plot[,2:5]), by = 500)) +
  
  theme(
    axis.title.y = element_text(size = 10),
    legend.position = "bottom",  # Move legend below plot
    plot.caption = element_text(hjust = 0)
  ) +
  
  scale_color_manual(values = c("Trabajadores formales observados" = "darkgray", 
                                "Predicción SVM" = "blue", 
                                "Predicción LASSO" = "red", 
                                "Predicción RF" = "green",
                                "Ensemble SVM + LASSO" = "black")) +
  annotate("rect", xmin = corte, xmax = as.Date('2024-09-01'), ymin = min(data_plot[,2:5]), ymax = max(data_plot[,2:5]),
           alpha = .2)

# Cerrar el archivo PDF
dev.off()

# Crear un dataframe con los RMSE reales de los modelos
rmse_data <- data.frame(
  Model = c("SVM", "Random Forest", "LASSO"),
  RMSE = c(rmse_svm, rmse_rf, rmse_lasso)
)

# Convertir el dataframe de RMSE a LaTeX
latex_table_rmse <- xtable(rmse_data)

# Imprimir la tabla en formato LaTeX
print(latex_table_rmse)

# Mostrar el resultado del pronóstico
cat("Predicción LASSO / SVM / RF para octubre 2024: ", c(prediccion_octubre_LASSO, prediccion_octubre_svm, prediccion_octubre_rf), "\n")

# Crear el dataframe con las predicciones de octubre 2024 para cada modelo
prediccion_data <- data.frame(
  Model = c("LASSO", "SVM", "Random Forest"),
  Prediccion_Octubre_2024 = c(prediccion_octubre_LASSO, prediccion_octubre_svm, prediccion_octubre_rf)
)

# Convertir el dataframe de predicciones a LaTeX
latex_table_pred <- xtable(prediccion_data)

# Imprimir la tabla en formato LaTeX
print(latex_table_pred)

#


##### 2.3 Predicción de la pobreza laboral para el Tercer Trimestre 2024 (publica en noviembre). ####
rm(list = ls())
data3 <- read_excel("Datos/base2.3.xlsx")

data3$Pobreza_laboral <- as.numeric(data3$Pobreza_laboral)
data3$date <- zoo::as.yearqtr(data3$date, format = "%Y Q%q")

impute_arima <- function(df) {
  df_imputed <- df  # Copy the original data frame
  
  for (col in names(df)) {
    if (any(is.na(df[[col]]))) {  # Check if column has any NA values
      # Impute missing values in the column with ARIMA-based method
      df_imputed[[col]] <- na_kalman(df[[col]], model = "auto.arima")
    }
  }
  
  return(df_imputed)
}

# Applying the function to your data frame
data3 <- impute_arima(data3)

data_combined_original <- data3
data_combined <- cbind(data_combined_original[,c("date", "Pobreza_laboral")],
                       lag(select(data_combined_original, -one_of(c("date", "Pobreza_laboral"))))
)

# Ajustamos nombres
lagged_names <- paste(names(data_combined)[3:length(data_combined)], "_lag", sep = "")
names(data_combined)[3:length(data_combined)] <- lagged_names

# mediante un autocorrelograma observamos que al menos tres rezagos influyen en la variable
# de pobreza laboral. Entonces:
data_combined$Pobreza_laboral_lag1 <- lag(data_combined$Pobreza_laboral, 1)
data_combined$Pobreza_laboral_lag2 <- lag(data_combined$Pobreza_laboral, 2)
data_combined$Pobreza_laboral_lag3 <- lag(data_combined$Pobreza_laboral, 3)


# Eliminar cualquier fila con valores NA
data_combined <- na.omit(data_combined)

# Nos quedamos con las variables predictoras al tiempo t, que servirán para realizar la predicción de infl_sub
# al tiempo t + 1
names(data_combined_original)[3:length(data_combined_original)] <- lagged_names
data_combined_original$Pobreza_laboral_lag1 <- lag(data_combined_original$Pobreza_laboral, 1)
data_combined_original$Pobreza_laboral_lag2 <- lag(data_combined_original$Pobreza_laboral, 2)
data_combined_original$Pobreza_laboral_lag3 <- lag(data_combined_original$Pobreza_laboral, 3)
data_combined_original <- data_combined_original[nrow(data_combined_original),]

rm(list=setdiff(ls(), c("data_combined", "data_combined_original")))

# Dividir los datos en entrenamiento (75%) y prueba (25%)

training_share <- .8
n <- nrow(data_combined)
set_entrenamiento <- data_combined[1:round(n*training_share),]
set_test <- data_combined[(round(n*training_share)+1):n,]

formula <- Pobreza_laboral ~ tasa_deso_lag + tasa_ocup_inf_lag + 
  pib_real_lag + infl_sub_lag + tc_fix_lag + tiie_28_lag + 
  w_min_lag + inflacion_lag + Pobreza_laboral_lag1 + Pobreza_laboral_lag2 + 
  Pobreza_laboral_lag3

###### SVM ####

# Entrenar el modelo SVM usando las variables adicionales
set.seed(1)

modelo_svm <- train(formula,
                    data = as.ts(set_entrenamiento),
                    method = "svmLinear",
                    preProcess = c("center","scale"),
                    tuneGrid = expand.grid(C = seq(0.1, 2, length = 20)))
#View the model
modelo_svm
cat("El valor de C usado en el mejor modelo es C =", modelo_svm$bestTune$C)
# Hacer predicciones con los datos de prueba
y_pred_svm = predict(modelo_svm, newdata = as.ts(set_test))

# Evaluar el rendimiento (RMSE)
rmse_svm <- sqrt(mean((y_pred_svm - set_test$Pobreza_laboral)^2))
cat("RMSE del modelo SVM: ", rmse_svm, "\n")

#### Pronóstico octubre 2024 con SVM
prediccion_octubre_svm <- predict(modelo_svm, newdata = as.ts(data_combined_original))
prediccion_octubre_svm

###### Random forest ####

# Utilizamos cross validation para determinar el número de variables que mejor
# rendimiento tiene
set.seed(1)
cv_randomF <- rfcv(trainx = as.ts(set_entrenamiento)[,-2],
                   trainy = as.ts(set_entrenamiento)[,2],
                   step = 0.9,
                   cv.fold = 4)

# nos dice cuál es el número óptimo
mtry_CV <- cv_randomF$error.cv[which.min(cv_randomF$error.cv)]
mtry_CV <- as.numeric(names(mtry_CV))
cat("El mejor modelo de RF utiliza", mtry_CV, "variables según CV")

# Entrenar el modelo Random Forest usando el regularizador indicado
set.seed(1)
modelo_rf = randomForest(formula = formula,
                         data = set_entrenamiento,
                         ntree = 500,
                         mtry = mtry_CV)

# Hacer predicciones
predRF_1 <- predict(modelo_rf, newdata = as.ts(set_test))

# Utilizamos otra función que ya arroja el modelo con el regularizador óptimo mediante CV
set.seed(1)
modelo_rf2 <- 
  train(
    formula,
    data = as.ts(set_entrenamiento),
    method = 'rf',
    tuneLength = 10,
    prox = TRUE       # Extra information
  )
modelo_rf2
modelo_rf2$finalModel # el modelo elegido

# predicciones
predRF_2 <- 
  predict(
    modelo_rf2,
    as.ts(set_test)
  )

# Evaluar el rendimiento (RMSE)
rmse_rf1 <- sqrt(mean((predRF_1 - set_test$Pobreza_laboral)^2))
cat("RMSE del modelo Random Forest 1: ", rmse_rf1, "\n")

rmse_rf2 <- sqrt(mean((predRF_2 - set_test$Pobreza_laboral)^2))
cat("RMSE del modelo Random Forest 2: ", rmse_rf2, "\n")

if (rmse_rf2 < rmse_rf1) {
  modelo_rf <- modelo_rf2
  rmse_rf <- rmse_rf2
  y_pred_RF <- predRF_2
  cat("El mejor modelo de RF es el modelo 2")
} else {
  cat("El mejor modelo de RF es el modelo 1")
  rmse_rf <- rmse_rf1
  y_pred_RF <- predRF_1
}

### Pronostico para RF
prediccion_octubre_rf <- predict(modelo_rf, newdata = as.ts(data_combined_original))
prediccion_octubre_rf

# ###### Redes neuronales ####
# 
# set.seed(1)
# # Control de entrenamiento con validación cruzada repetida
# control <- trainControl(method = "repeatedcv", number = 10, repeats = 5)
# 
# # Ajuste del modelo usando `train` de `caret`, con preprocesamiento para normalizar
# set.seed(1)
# modelo_nn <- train(
#   Pobreza_laboral ~ Pobreza_laboral_lag1 + Pobreza_laboral_lag2 + Pobreza_laboral_lag3,
#   data = as.ts(set_entrenamiento),     # Datos
#   method = "nnet",              # Método para redes neuronales
#   trControl = control,          # Configuración de cross-validation
#   tuneGrid = expand.grid(size = seq(1, 15), decay = c(0.01, 0.05, 0.1)),  # Hiperparámetros
#   preProcess = c("center", "scale"),  # Normalización de los datos
#   linout = TRUE,                # Para regresión
#   trace = FALSE
# )
# # Muestra el mejor modelo y los resultados de cross-validation
# print(modelo_nn)
# cat("El mejor modelo utiliza", modelo_nn$bestTune$size, "nodos en la única capa oculta, y un regularizador 'decay' de", modelo_nn$bestTune$decay)
# y_pred_nn <- predict(modelo_nn, newdata = as.ts(set_test))
# 
# # Evaluar el rendimiento (RMSE)
# rmse_nn <- sqrt(mean((y_pred_nn - set_test$Pobreza_laboral)^2))
# cat("RMSE del modelo de Redes Neuronales: ", rmse_nn, "\n")
# 
# ### Pronostico para Redes neuronales
# prediccion_octubre_nn <- predict(modelo_nn, newdata = as.ts(data_combined_original))
# prediccion_octubre_nn


###### LASSO ####
# Preparar los datos para el modelo Lasso
x_train <- model.matrix(formula, as.ts(set_entrenamiento))[, -1]
y_train <- set_entrenamiento$Pobreza_laboral
x_test <- model.matrix(formula, as.ts(set_test))[, -1]

# Ajustar el modelo Lasso
set.seed(2)
modelo_lasso <- cv.glmnet(x_train, y_train, alpha = 1)

# variables seleccionadas por LASSO
round(coef(modelo_lasso, s = "lambda.min"), 2)

# Hacer predicciones con el mejor modelo Lasso según CV 
pred_lasso <- predict(modelo_lasso, s = "lambda.min", newx = x_test)

# Evaluar el rendimiento (RMSE)
rmse_lasso <- sqrt(mean((pred_lasso - set_test$Pobreza_laboral)^2))
cat("RMSE del modelo Lasso: ", rmse_lasso, "\n")

prediccion_octubre_LASSO <- predict(modelo_lasso, s = "lambda.min",
                                    newx = model.matrix(formula, as.ts(data_combined_original))[, -1])
prediccion_octubre_LASSO

###### Comparación ####

# Crear un nuevo dataframe que contenga las predicciones
data_plot <- data.frame(
  date = as_date(data_combined$date),
  ta_observados = data_combined$Pobreza_laboral,
  pred_svm = predict(modelo_svm, as.ts(data_combined)),
  pred_lasso = predict(modelo_lasso, s = "lambda.min",
                       newx = model.matrix(formula, as.ts(data_combined))[, -1]),
  pred_rf = predict(modelo_rf, as.ts(data_combined))
)
data_plot <- data_plot %>% 
  filter(date>"2019-01-01")

corte <- set_test$date[1]

# Guardar el gráfico en un archivo PDF
jpeg("Graficas/Comparacion3.jpg", width = 2500, height = 1500, res = 300)

# Crear el gráfico con ggplot
ggplot(data_plot, aes(x = date)) +
  
  # Línea de inflación real
  geom_line(aes(y = ta_observados, color = "Pobreza laboral (%)"), size = 1) +
  
  # Predicciones del modelo SVM
  geom_line(aes(y = pred_svm, color = "Predicción SVM"), size = 0.7, linetype = "longdash") +
  
  # Predicciones del modelo Redes Neuronales
  geom_line(aes(y = lambda.min, color = "Predicción LASSO"), size = 0.7, linetype = "F1") +
  
  # Predicciones del modelo Random Forest
  geom_line(aes(y = pred_rf, color = "Predicción RF"), size = 0.7, linetype = "twodash") +
  
  # Ajustes generales de la gráfica
  labs(title = "Pronóstico de la pobreza laboral (%)",
       subtitle = "Algoritmos utilizados: SVM, LASSO y Random Forest",
       y = NULL, x = NULL, color = NULL,
       caption = "Fuente: IMSS y sistema de información económica del Banxico. El area sombreada representa el sample test") +
  
  theme_minimal() +
  
  geom_vline(xintercept = as_date(corte), linetype = "dashed", color = "black", size = 0.7) +
  
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  
  theme(
    axis.title.y = element_text(size = 10),
    legend.position = "bottom",  # Move legend below plot
    plot.caption = element_text(hjust = 0)
  ) +
  
  scale_color_manual(values = c("Pobreza laboral (%)" = "darkgray", 
                                "Predicción SVM" = "blue", 
                                "Predicción LASSO" = "red", 
                                "Predicción RF" = "green")) +
  annotate("rect", xmin = as_date(corte), xmax = as.Date('2024-09-01'), ymin = min(data_plot[,2:5]), ymax = max(data_plot[,2:5]),
           alpha = .2)

# Cerrar el archivo PDF
dev.off()

# Crear un dataframe con los RMSE reales de los modelos
rmse_data <- data.frame(
  Model = c("SVM", "Random Forest", "LASSO"),
  RMSE = c(rmse_svm, rmse_rf, rmse_lasso)
)

# Convertir el dataframe de RMSE a LaTeX
latex_table_rmse <- xtable(rmse_data)

# Imprimir la tabla en formato LaTeX
print(latex_table_rmse)

# Mostrar el resultado del pronóstico
cat("Predicción LASSO / SVM / RF para octubre 2024: ", c(prediccion_octubre_LASSO, prediccion_octubre_svm, prediccion_octubre_rf), "\n")

# Crear el dataframe con las predicciones de octubre 2024 para cada modelo
prediccion_data <- data.frame(
  Model = c("LASSO", "SVM", "Random Forest"),
  Prediccion_Octubre_2024 = c(prediccion_octubre_LASSO, prediccion_octubre_svm, prediccion_octubre_rf)
)

# Convertir el dataframe de predicciones a LaTeX
latex_table_pred <- xtable(prediccion_data)

# Imprimir la tabla en formato LaTeX
print(latex_table_pred)


  