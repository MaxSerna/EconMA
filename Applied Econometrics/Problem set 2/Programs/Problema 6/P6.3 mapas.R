rm(list = ls())
setwd("D:/Eco aplicada/Tarea 2/6/")

library(sf)
library(RColorBrewer)
library(haven)
library(tidyverse)

# Bases de datos necesarias
Estados <- st_read("Datos/Mapas/Entidades_Mexico.shp",
                   options = "ENCODING=latin1") %>% 
  mutate(CVE_ENT = as.numeric(CVE_ENT))

# Conservo solo la información que necesito de lo obtenido en STATA
Pobreza_ENOE <- read_dta("Datos/temp/ITLP-1.dta") %>% 
  filter(year == max(year)) %>% 
  filter(trim_ayuda == max(trim_ayuda)) %>% 
  select(Aguascalientes, Baja_California, Baja_California_Sur, Campeche,
         Coahuila, Colima, Chiapas, Chihuahua, Cuidad_de_México,
         Durango, Guanajuato, Guerrero, Hidalgo, Jalisco, Estado_de_México,
         Michoacán, Morelos, Nayarit, Nuevo_León, Oaxaca, Puebla, Querétaro, 
         Quintana_Roo, San_Luis_Potosí, Sinaloa, Sonora, Tabasco, 
         Tamaulipas, Tlaxcala, Veracruz, Yucatán, Zacatecas) %>% 
  gather("Estado", "Pobreza_Lab") %>% 
  mutate(CVE_ENT = 1:n())

Pobreza_multid <- read.csv("Datos/Union/PM_2022.csv",
                           encoding = "latin1") %>% 
  rename(CVE_ENT = ent)

# Pego la información de pobreza al shape:
Pobreza_ENOE_m <- sp::merge(Estados, Pobreza_ENOE, by="CVE_ENT")
Pobreza_ENOE_m <- sp::merge(Pobreza_ENOE_m, Pobreza_multid, by="CVE_ENT")


plot_file <- "Gráficas/mapa_enoe_max.jpg"
jpeg(plot_file, width = 3000, height = 2000, res = 300)

# Pobreza laboral
ggplot(Pobreza_ENOE_m) +
  geom_sf(aes(fill = Pobreza_Lab)) + 
  scale_fill_gradientn(colors = rev(heat.colors(32)),  # Usa la paleta "heat"
                       name = "%") +
  theme_minimal() +
  labs(title = "Población en pobreza laboral. ",
       subtitle = "Segundo trimestre de 2024",
       caption = "Elaboración propia con datos de la ENOE")

dev.off()  # Cierra el archivo JPG


plot_file <- "Gráficas/mapa_enigh_max.jpg"
jpeg(plot_file, width = 3000, height = 2000, res = 300)

# Pobreza multidimensional
ggplot(Pobreza_ENOE_m) +
  geom_sf(aes(fill = pobreza)) + 
  scale_fill_gradientn(colors = rev(heat.colors(32)),  # Usa la paleta "heat"
                       name = "%") +
  theme_minimal() +
  labs(title = "Población en pobreza multidimensional. ",
       subtitle = "Segundo trimestre de 2024",
       caption = "Elaboración propia con datos de la ENIGH")

dev.off()  # Cierra el archivo JPG