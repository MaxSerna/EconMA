# Econometría Aplicada
# Problem Set 2
# Ejercicio 3
# Max Brando Serna Leyva
# 2023-2025

rm(list = ls())

if (dev.cur() > 1) {
  dev.off()  # Cierra el dispositivo gráfico activo
}

library(sf)
library(ggplot2)
library(RColorBrewer)

#### IMPORTANTE     IMPORTANTE      IMPORTANTE      IMPORTANTE      IMPORTANTE
####
##### Directorio principal ####
####
#### Cambia "directorio" y coloca la dirección donde hayas extraído las carpetas del zip;
#### el directorio debe hacer referencia a una carpeta donde haya otras 4: Datos, Do files, Gráficos y Shapes.

directorio <- "D:/Eco aplicada/Tarea 2/2"

####
####
####
####
#### IMPORTANTE     IMPORTANTE      IMPORTANTE      IMPORTANTE      IMPORTANTE

#### A partir de aquí no hay que hacer nada

#
#
#
#
#
#
#
#

##### 2.8 ####

shapes_dir <- paste(directorio, "/Shapes", sep = "")
datos <- paste(directorio, "/Datos", sep = "")
graficos <- paste(directorio, "/Gráficos", sep = "")

# Cargar el shapefile
shape_entidades_dir <- paste(shapes_dir, "/dest2019gw/dest2019gw.shp", sep = "")
entidades <- st_read(shape_entidades_dir)
entidades$CVE_ENT <- as.numeric(entidades$CVE_ENT)

# Base propia del IMSS
imss_dir <- paste(datos, "/imss8_final_cambios.dta", sep = "")
imss <- haven::read_dta(imss_dir)

# Unir la base de datos con los salarios al shapefile
entidades_salario <- merge(entidades, imss, by.x = "CVE_ENT", by.y = "id", all.x = TRUE)

###### Cambios en salario promedio ####

####### Gráfico 1 ####
# Guardar el primer gráfico: cambios porcentuales en salario promedio 2024-2010
plot_file <- paste(graficos, "/8/cambios_salario_2024_2010.jpg", sep = "")
jpeg(plot_file, width = 3000, height = 2000, res = 300)

# Corro el gráfico
ggplot(entidades_salario) +
  geom_sf(aes(fill = wage_d10_23)) + 
  scale_fill_gradientn(colors = rev(heat.colors(32)),  # Usa la paleta "heat"
                       name = "Cambio porcentual") +
  theme_minimal() +
  labs(title = "Variación porcentual en los salarios promedio por entidad",
       subtitle = "2010 - 2024",
       caption = "Elaboración propia con datos del IMSS. Tomamos julio como el mes de referencia")

dev.off()  # Cierra el archivo JPG

####### Gráfico 2 ####
# Guardar el segundo gráfico: cambios porcentuales en salario promedio 2024-2017
plot_file <- paste(graficos, "/8/cambios_salario_2024_2017.jpg", sep = "")
jpeg(plot_file, width = 3000, height = 2000, res = 300)

ggplot(entidades_salario) +
  geom_sf(aes(fill = wage_d17_23)) + 
  scale_fill_gradientn(colors = rev(heat.colors(32)),  # Usa la paleta "heat"
                       name = "Cambio porcentual") +
  theme_minimal() +
  labs(title = "Variación porcentual en los salarios promedio por entidad",
       subtitle = "2017- 2024",
       caption = "Elaboración propia con datos del IMSS. Tomamos julio como el mes de referencia")
dev.off()  # Cierra el archivo JPG

###### Cambios en trabajadores ####

####### Gráfico 3 ####
# Guardar el tercer gráfico: cambios porcentuales en el número de trabajadores 2024-2010
plot_file <- paste(graficos, "/8/cambios_trabajadores_2024_2010.jpg", sep = "")
jpeg(plot_file, width = 3000, height = 2000, res = 300)

ggplot(entidades_salario) +
  geom_sf(aes(fill = ta_d10_23)) + 
  scale_fill_gradientn(colors = rev(heat.colors(32)),  # Usa la paleta "heat"
                       name = "Cambio porcentual") +
  theme_minimal() +
  labs(title = "Variación porcentual en el número de trabajadores por entidad",
       subtitle = "2010 - 2024",
       caption = "Elaboración propia con datos del IMSS. Tomamos julio como el mes de referencia")
dev.off()  # Cierra el archivo JPG

####### Gráfico 4 ####
# Guardar el cuarto gráfico: cambios porcentuales en el número de trabajadores 2024-2017
plot_file <- paste(graficos, "/8/cambios_trabajadores_2024_2017.jpg", sep = "")
jpeg(plot_file, width = 3000, height = 2000, res = 300)

ggplot(entidades_salario) +
  geom_sf(aes(fill = ta_d17_23)) + 
  scale_fill_gradientn(colors = rev(heat.colors(32)),  # Usa la paleta "heat"
                       name = "Cambio porcentual") +
  theme_minimal() +
  labs(title = "Variación porcentual en el número de trabajadores por entidad",
       subtitle = "2017- 2024",
       caption = "Elaboración propia con datos del IMSS. Tomamos julio como el mes de referencia")
dev.off()  # Cierra el archivo JPG

#
#
#
#
#
#
#
#

##### 2.9 ####

# Base propia del IMSS
imss_dir <- paste(datos, "/imssfinal_01.dta", sep = "")
imss <- haven::read_dta(imss_dir)

# Unir la base de datos con los salarios al shapefile
entidades_salario <- merge(entidades, imss, by.x = "CVE_ENT", by.y = "id", all.x = TRUE)

###### Cambios en salario promedio ####

####### Gráfico 1 ####
# Guardar el primer gráfico: cambios porcentuales en salario promedio Julio vs Feb 2020
plot_file <- paste(graficos, "/9/cambios_salario_Julio2020_Feb2020.jpg", sep = "")
jpeg(plot_file, width = 3000, height = 2000, res = 300)

# Corro el gráfico
ggplot(entidades_salario) +
  geom_sf(aes(fill = prom_20J_20F)) + 
  scale_fill_gradientn(colors = rev(heat.colors(32)),  # Usa la paleta "heat"
                       name = "Cambio porcentual") +
  theme_minimal() +
  labs(title = "Variación porcentual en los salarios promedio por entidad",
       subtitle = "Febrero 2020 - Julio 2020",
       caption = "Elaboración propia con datos del IMSS")

dev.off()  # Cierra el archivo JPG

####### Gráfico 2 ####
# Guardar el segundo gráfico: cambios porcentuales en salario promedio 2024 vs Feb 2020
plot_file <- paste(graficos, "/9/cambios_salario_2024_Feb2020.jpg", sep = "")
jpeg(plot_file, width = 3000, height = 2000, res = 300)

# Corro el gráfico
ggplot(entidades_salario) +
  geom_sf(aes(fill = prom_24_20F)) + 
  scale_fill_gradientn(colors = rev(heat.colors(32)),  # Usa la paleta "heat"
                       name = "Cambio porcentual") +
  theme_minimal() +
  labs(title = "Variación porcentual en los salarios promedio por entidad",
       subtitle = "Febrero 2020 - Julio 2024",
       caption = "Elaboración propia con datos del IMSS")

dev.off()  # Cierra el archivo JPG

###### Cambios en trabajadores ####

####### Gráfico 3 ####
# Guardar el tercer gráfico: cambios porcentuales en el número de trabajadores Julio vs Feb 2020
plot_file <- paste(graficos, "/9/cambios_trabajadores_Julio2020_Feb2020.jpg", sep = "")
jpeg(plot_file, width = 3000, height = 2000, res = 300)

# Corro el gráfico
ggplot(entidades_salario) +
  geom_sf(aes(fill = ta_20J_20F)) + 
  scale_fill_gradientn(colors = rev(heat.colors(32)),  # Usa la paleta "heat"
                       name = "Cambio porcentual") +
  theme_minimal() +
  labs(title = "Variación porcentual en el número de trabajadores por entidad",
       subtitle = "Febrero 2020 - Julio 2020",
       caption = "Elaboración propia con datos del IMSS")

dev.off()  # Cierra el archivo JPG

####### Gráfico 4 ####
# Guardar el cuarto gráfico: cambios porcentuales en el número de trabajadores 2024 vs Feb 2020
plot_file <- paste(graficos, "/9/cambios_trabajadores_2024_Feb2020.jpg", sep = "")
jpeg(plot_file, width = 3000, height = 2000, res = 300)

# Corro el gráfico
ggplot(entidades_salario) +
  geom_sf(aes(fill = ta_24_20F)) + 
  scale_fill_gradientn(colors = rev(heat.colors(32)),  # Usa la paleta "heat"
                       name = "Cambio porcentual") +
  theme_minimal() +
  labs(title = "Variación porcentual en el número de trabajadores por entidad",
       subtitle = "Febrero 2020 - Julio 2024",
       caption = "Elaboración propia con datos del IMSS")

dev.off()  # Cierra el archivo JPG



#
#
#
#
#
#
#
#

##### 2.10 ####

# Cargar el shapefile
shape_municipios_dir <- paste(shapes_dir, "/muni_2018gw/muni_2018gw.shp", sep = "")
municipios <- st_read(shape_municipios_dir)

# Cargar el la base del IMSS por municipio
imss_dir <- paste(datos, "/imss match final.xlsx", sep = "")
imss <- readxl::read_excel(imss_dir, sheet = "Stata")

# Unir la base de datos con los salarios al shapefile
municipios_salario <- merge(municipios, imss, by = "CVEGEO", all.x = TRUE)

###### Cambios en salario promedio ####

###### Gráfico 1 ####
# Guardar el primer gráfico: cambios porcentuales en salario promedio 2018-2019
plot_file <- paste(graficos, "/10/cambios_salario_2018_2019.jpg", sep = "")
jpeg(plot_file, width = 3000, height = 2000, res = 300)

# Corro el gráfico
ggplot(municipios_salario) +
  geom_sf(aes(fill = prom_18_19)) + 
  scale_fill_gradientn(colors = rev(heat.colors(32)),  # Usa la paleta "heat"
                       name = "Cambio porcentual") +
  theme_minimal() +
  labs(title = "Variación porcentual en los salarios promedio por municipio",
       subtitle = "2018 - 2019. Municipios con al menos 10,000 empleados en 2018.",
       caption = "Elaboración propia con datos del IMSS. Tomamos julio como el mes de referencia")

dev.off()  # Cierra el archivo JPG

####### Gráfico 2 ####
# Guardar el segundo gráfico: cambios porcentuales en salario promedio 2018-2024
plot_file <- paste(graficos, "/10/cambios_salario_2018_2024.jpg", sep = "")
jpeg(plot_file, width = 3000, height = 2000, res = 300)

# Corro el gráfico
ggplot(municipios_salario) +
  geom_sf(aes(fill = prom_18_24)) + 
  scale_fill_gradientn(colors = rev(heat.colors(32)),  # Usa la paleta "heat"
                       name = "Cambio porcentual") +
  theme_minimal() +
  labs(title = "Variación porcentual en los salarios promedio por municipio",
       subtitle = "2018 - 2024. Municipios con al menos 10,000 empleados en 2018.",
       caption = "Elaboración propia con datos del IMSS. Tomamos julio como el mes de referencia")

dev.off()  # Cierra el archivo JPG

###### Cambios en trabajadores ####

####### Gráfico 3 ####
# Guardar el primer gráfico: cambios porcentuales en no. de trabajadores 2018-2019
plot_file <- paste(graficos, "/10/cambios_trabajadores_2018_2019.jpg", sep = "")
jpeg(plot_file, width = 3000, height = 2000, res = 300)

# Corro el gráfico
ggplot(municipios_salario) +
  geom_sf(aes(fill = ta_18_19)) + 
  scale_fill_gradientn(colors = rev(heat.colors(32)),  # Usa la paleta "heat"
                       name = "Cambio porcentual") +
  theme_minimal() +
  labs(title = "Variación porcentual en el número de trabajadores por municipio",
       subtitle = "2018 - 2019. Municipios con al menos 10,000 empleados en 2018.",
       caption = "Elaboración propia con datos del IMSS. Tomamos julio como el mes de referencia")

dev.off()  # Cierra el archivo JPG

###### Gráfico 4 ####
# Guardar el primer gráfico: cambios porcentuales en no. de trabajadores 2018-2024
plot_file <- paste(graficos, "/10/cambios_trabajadores_2018_2024.jpg", sep = "")
jpeg(plot_file, width = 3000, height = 2000, res = 300)

# Corro el gráfico
ggplot(municipios_salario) +
  geom_sf(aes(fill = ta_18_24)) + 
  scale_fill_gradientn(colors = rev(heat.colors(32)),  # Usa la paleta "heat"
                       name = "Cambio porcentual") +
  theme_minimal() +
  labs(title = "Variación porcentual en el número de trabajadores por municipio",
       subtitle = "2018 - 2024. Municipios con al menos 10,000 empleados en 2018.",
       caption = "Elaboración propia con datos del IMSS. Tomamos julio como el mes de referencia")

dev.off()  # Cierra el archivo JPG
