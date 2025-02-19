/*
Econometría Aplicada
Problem Set 2
Ejercicio 5
Max Brando Serna Leyva
2023-2025
*/

******ESTABLECER DIRECTORIOS
global main = "D:\Eco aplicada\Tarea 2\5"
global enoe = "$main\Bases\ENOE"
global graficosenoe = "$main\Gráficos\ENOE"
global resultadosenoe = "$main\Resultados\ENOE"


*********************************************************************************PARA LA ENOE
****-------------------------------------------------------------------Inciso 2)

************OJOOOOOOOOO: El tiempo para generar las gráficas es bastante la mayoría a tardar 30-40 min. SI quieres ahorrar tiempo, te sugiero usar la Base PROBLEMA5_ULTVERSION.dta, PARA GENERAR LAS GRÁFICAS USANDO ESTA BASE SOLO SE TIENEN QUE CORRER AQUELLOS QUE TENGAN GRAPH EXPORT, el inconveniente es que el tamaño de las etiquetas de los gráficos no va a cambiar. 

*Si quieres hacer todo paso por paso y modificarle al gusto, usa la base ENOE_FINAL.dta en lugar de PROBLEMA5_ULTVERSION.dta, y quita los asteriscos de las siguientes 4 líneas. 


use "$enoe\PROBLEMA5_ULTVERSION.dta", clear 
*use "$enoe\ENOE_FINAL.dta", clear
*destring year, replace  //// Pasando la variable year a valor numérico
*label variable year "Año"
*drop _merge
*drop if hrsocup==0


***Restringiendo los valores de los salarios por hora. 

twoway (kdensity sal_hora if inlist(year, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023,2024) & sal_hora <= 500, lc(blue) lwidth(0.5)), ///
       by(year, note("") title("Distribución del salario por hora por año, 2005 - 2024", margin(small) position(12)) style(stata7)) ytitle("Densidad del salario por hora", margin(small)) xticks(0(100)500) xtitle("Salario por hora", margin(small)) xlabel(0(100)500, labsize(small)) ylabel(, labsize(small)) scheme (stcolor)
graph export "$graficosenoe\kdensityacotado.png", replace	


****Grafica una distribución no paramétrica para esta nueva variable	   
twoway (kdensity log_salhora if inlist(year, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024), lc(blue) lwidth(0.5)), ///
       by(year, note("") style(stata7) title("Distribución del log_salario por hora por año, 2005 - 2024", margin(small) position(12)) compact) ytitle("Densidad del Log_salario por hora", margin(small)) xticks(0(2)9) xtitle("Log del salario por hora", margin(small)) xlabel(, labsize(small)) ylabel(, labsize(small)) scheme (stcolor)	   
graph export "$graficosenoe\kdensitylog_salhora.png", replace

******-----------------------------------------------------------------Inciso 3)
***********Crea dos gráficas con distribuciones no paramétricas con diferentes bandwidth para un año
/*
twoway (kdensity log_salhora if year == 2023 & log_salhora<8, bw(4) lcolor(blue) lwidth(medium)) ///
       , scheme(stcolor) ///
         subtitle("Bw=4", size(2.5)) ///
         xtitle("Logaritmo Natural del Salario por Hora", size(3)) ///
         ytitle("Densidad", size(3)) 
graph save Distnopara_diferentebandmayor.gph, replace 

twoway (kdensity log_salhora if year == 2023 & log_salhora<8, bw(1.5) lcolor(blue) lwidth(medium)) ///
       , scheme(stcolor) ///
         subtitle("Bw=2.5", size(2.5)) ///
         xtitle("Logaritmo Natural del Salario por Hora", size(3)) ///
         ytitle("Densidad", size(3)) 
graph save Distnopara_diferentebandmedio.gph, replace 

twoway (kdensity log_salhora if year == 2023 & log_salhora<8, bw(0.5) lcolor(blue) lwidth(medium)) ///
       , scheme(stcolor) ///
         subtitle("Bw=0.5", size(2.5))  ///
         xtitle("Logaritmo Natural del Salario por Hora", size(3)) ///
         ytitle("Densidad", size(3)) 
graph save Distnopara_diferentebandbajo.gph, replace 

twoway (kdensity log_salhora if year == 2023 & log_salhora<8, bw(0.001) lcolor(blue) lwidth(medium)) ///
       , scheme(stcolor) ///
         subtitle("Bw=0.001", size(2.5))  ///
         xtitle("Logaritmo Natural del Salario por Hora", size(3)) ///
         ytitle("Densidad", size(3)) 
graph save Distnopara_diferentebandmuybajo.gph, replace 

graph combine Distnopara_diferentebandmayor.gph Distnopara_diferentebandmedio.gph ///
Distnopara_diferentebandbajo.gph Distnopara_diferentebandmuybajo.gph, ///
    imargin(zero) ycommon xcommon subtitle("", size(3)) ///
    title("Distribución no paramétrica del salario por hora, 2023", size(4)) ///
	subtitle("Para diferentes bandwidth", size(3)) ///
	caption("Elaboración propia con datos de la ENOE", size(2))
graph export "$graficosenoe\Distr_npara_difband.png", replace

************Crea dos gráficas con distribuciones no paramétricas con diferentes kernels para un año (Gaussian y Epanechnikov) para el mismo bandwidth 

twoway (kdensity log_salhora if year == 2023, kernel(gaussian) bw(1) lcolor(blue) lwidth(medium)) ///
     , scheme(stcolor) ///
	   subtitle("Kernel(Gaussian)", size(3))  ///
       xtitle("Logaritmo Natural del Salario por Hora", size(3)) ///
       ytitle("Densidad", size(3)) ///
	   nodraw
graph save Distnopara_gaussian.gph, replace 


twoway (kdensity log_salhora if year == 2023, kernel(epanechnikov) bw(1) lcolor(blue) lwidth(medium)) ///
     , scheme(stcolor) ///
	   subtitle("Kernel(Epanechnikov)", size(3))  ///
       xtitle("Logaritmo Natural del Salario por Hora", size(3)) ///
       ytitle("Densidad", size(3)) ///
	   nodraw
graph save Distnopara_epanech.gph, replace 	   

graph combine Distnopara_gaussian.gph Distnopara_epanech.gph, ///
    imargin(zero) ycommon xcommon subtitle("", size(3)) ///
    title("Distribución no paramétrica del salario por hora, 2023", size(4)) ///
	subtitle("Para diferentes Kernels", size(3)) ///
	caption("Elaboración propia con datos de la ENOE", size(2)) ///
	scheme(stcolor)
graph export "$graficosenoe\Distr_npara_difkernel.png", replace
*/

******----------------------------------------------------------------Inciso 4)

*************Grafica la distribución no paramétrica del logaritmo del salario por hora del año 2016 con la de /// los años 2018 y 2022 en el mismo gráfico utilizando el bandwidth óptimo de Silverman.

* Calcularndo los bandwidth optimos de Silverman para cada año (opcional, kdensity ya los incluye)
summarize log_salhora if year == 2016, detail
scalar iqr_2016 = r(p75) - r(p25)
scalar bw_2016 = 0.9 * min(r(sd), iqr_2016 / 1.349) * r(N)^(-1/5)
display(bw_2016)

summarize log_salhora if year == 2018, detail
scalar iqr_2018 = r(p75) - r(p25)  
scalar bw_2018 = 0.9 * min(r(sd), iqr_2018 / 1.349) * r(N)^(-1/5)
display(bw_2018)

summarize log_salhora if year == 2022, detail
scalar iqr_2022 = r(p75) - r(p25)
scalar bw_2022 = 0.9 * min(r(sd), iqr_2022 / 1.349) * r(N)^(-1/5)
display(bw_2022)


* Crear la gráfica usando los bandwidths calculados

twoway (kdensity log_salhora if year == 2016 & log_salhora<8, bw(0.04166247) lcolor(blue) lwidth(medium) lpattern(solid)) ///
       (kdensity log_salhora if year == 2018 & log_salhora<8, bw(0.04210061) lcolor(red) lwidth(medthick) lpattern(shortdash)) ///
       (kdensity log_salhora if year == 2022 & log_salhora<8, bw(0.04120047) lcolor(green) lwidth(medthick) lpattern(longdash)) ///
       , title("Distribución no paramétrica del Logaritmo del Salario por Hora", size (4)) ///
         subtitle("Años 2016, 2018 y 2022 (Bandwidth óptimo de Silverman)", size(3)) ///
         xtitle("Logaritmo Natural del Salario por Hora", size(3)) ///
         ytitle("Densidad", size(3)) ///
         legend(label(1 "Año 2016") label(2 "Año 2018") label(3 "Año 2022") size(2.5) pos(6) r(1)) ///
         xlabel(, labsize(small)) ylabel(, labsize(small)) ///
		 scheme(stcolor)
graph export "$graficosenoe\kdensity_logsalhora_silverman.png", replace

*******-------------------------------------------------------------Inciso 5)
****b)
*Escoge el año de 2018. Grafica no paramétricamente utilizando lowess y lpoly el logaritmo del salario por hora separadamente para hombres y mujeres.

**Recodificando la var sexo
recode sex (1=1) (2=0)
*label define l_sexo 1 "Hombre" 0 "Mujer"
label values sex l_sexo

***Reg lowess del log_salhora por edad

twoway (lowess log_salhora eda if sex==1 & year==2018, color(blue)) ///
       (lowess log_salhora eda if sex==0 & year==2018, color(red)) ///
       , legend(label(1 "Hombres") label(2 "Mujeres") size(2.5) r(1)) ///
       xtitle("Edad", size(2.5)) ytitle("Logaritmo del salario por hora", size(2.5)) ///
       subtitle("Regresión no paramétrica tipo Lowess", size(3)) ///
       xlabel(, labsize(small)) ylabel(, labsize(small)) ///
       xscale(range(25 65)) ///
       scheme(stcolor) nodraw
graph save Regresmopara_Lowessedad2018.gph, replace

***Reg lpoly del log_salhora por edad
twoway (lpoly log_salhora eda if sex==1 & year==2018, color (blue)) ///
       (lpoly log_salhora eda if sex==0 & year==2018, color (red)) ///
	   ,legend(label(1 "Hombres") label(2 "Mujeres") size(2.5)) ///
	   xtitle("Edad", size(2.5)) ytitle("Logaritmo del salario por hora", size(2.5)) ///
	   subtitle("Regresión no paramétrica tipo Lpoly", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   xscale (range(25 65)) ///
	   scheme(stcolor) nodraw
graph save Regresmopara_lpolyedad2018.gph, replace

grc1leg Regresmopara_Lowessedad2018.gph Regresmopara_lpolyedad2018.gph, ///
    imargin(zero) ycommon xcommon subtitle("", size(3)) ///
    title("2018: Log-salario vs Edad", size(4)) ///
	subtitle("", size(3)) ///
	caption("Elaboración propia con datos de la ENOE", size(2)) ///
	scheme(stcolor)
graph export "$graficosenoe\Reglowess_lpoly_logsalarioh_edad2018.png", replace



***Reg lowess del log_salhora por Años de escolaridad
twoway (lowess log_salhora anios_esc if sex==1 & year==2018 & anios_esc >= 0 & anios_esc <= 25, color (blue)) ///
       (lowess log_salhora anios_esc if sex==0 & year==2018 & anios_esc >= 0 & anios_esc <= 25, color (red)) ///
	   ,legend(label(1 "Hombres") label(2 "Mujeres") size(2.5) r(1)) ///
	   xtitle("Años de escolaridad", size(2.5)) ytitle("Logaritmo del salario por hora", size(2.5)) ///
	   subtitle("Regresión no paramétrica tipo Lowess", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   xscale (range(0 25)) ///
	   scheme(stcolor) nodraw
graph save Regresmopara_Lowessescolo2018.gph, replace

***Reg lpoly del log_salhora por años de escolaridad
twoway (lpoly log_salhora anios_esc if sex==1 & year==2018 & anios_esc >= 0 & anios_esc <= 25, color (blue)) ///
       (lpoly log_salhora anios_esc if sex==0 & year==2018 & anios_esc >= 0 & anios_esc <= 25, color (red)) ///
	   ,legend(label(1 "Hombres") label(2 "Mujeres") size(2.5)) ///
	   xtitle("Años de escolaridad", size(2.5)) ytitle("Logaritmo del salario por hora", size(2.5)) ///
	   subtitle("Regresión no paramétrica tipo Lpoly", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   xscale (range(0 25)) ///
	   scheme(stcolor) nodraw
graph save Regresmopara_lpolyescolo2018.gph, replace 

grc1leg Regresmopara_Lowessescolo2018.gph Regresmopara_lpolyescolo2018.gph, ///
    imargin(zero) ycommon xcommon subtitle("", size(3)) ///
    title("2018: Log-salario vs Educación", size(4)) ///
	subtitle("", size(3)) ///
	caption("Elaboración propia con datos de la ENOE", size(2)) ///
	scheme(stcolor)
graph export "$graficosenoe\Reglowess_lpoly_logsalarioh_añosesc2018.png", replace


****c) Escoge el año de 2022. Grafica no paramétricamente utilizando lowess y lpoly el logaritmo del salario por hora separadamente para hombres y mujeres.

***Reg lowess del log_salhora por edad

twoway (lowess log_salhora eda if sex==1 & year==2022, color(blue)) ///
       (lowess log_salhora eda if sex==0 & year==2022, color(red)) ///
       , legend(label(1 "Hombres") label(2 "Mujeres") size(2.5) r(1)) ///
       xtitle("Edad", size(2.5)) ytitle("Logaritmo del salario por hora", size(2.5)) ///
       subtitle("Regresión no paramétrica tipo Lowess", size(3)) ///
       xlabel(, labsize(small)) ylabel(, labsize(small)) ///
       xscale(range(25 65)) ///
       scheme(stcolor) nodraw
graph save Regresnopara_Lowessedad2022.gph, replace

***Reg lpoly del log_salhora por edad
twoway (lpoly log_salhora eda if sex==1 & year==2022, color (blue)) ///
       (lpoly log_salhora eda if sex==0 & year==2022, color (red)) ///
	   ,legend(label(1 "Hombres") label(2 "Mujeres") size(2.5)) ///
	   xtitle("Edad", size(2.5)) ytitle("Logaritmo del salario por hora", size(2.5)) ///
	   subtitle("Regresión no paramétrica tipo Lpoly", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   xscale (range(25 65)) ///
	   scheme(stcolor)
graph save Regresnopara_lpolyedad2022.gph, replace

grc1leg Regresnopara_Lowessedad2022.gph Regresnopara_lpolyedad2022.gph, ///
    imargin(zero) ycommon xcommon subtitle("", size(3)) ///
    title("2022: Log-salario vs Edad", size(4)) ///
	subtitle("", size(3)) ///
	caption("Elaboración propia con datos de la ENOE", size(2)) ///
	scheme(stcolor)
graph export "$graficosenoe\Reglowess_lpoly_logsalarioh_edad2022.png", replace



***Reg lowess del log_salhora por Años de escolaridad
twoway (lowess log_salhora anios_esc if sex==1 & year==2022 & anios_esc >= 0 & anios_esc <= 25, color (blue)) ///
       (lowess log_salhora anios_esc if sex==0 & year==2022 & anios_esc >= 0 & anios_esc <= 25, color (red)) ///
	   ,legend(label(1 "Hombres") label(2 "Mujeres") size(3) r(1)) ///
	   xtitle("Años de escolaridad", size(3)) ytitle("Logaritmo del salario por hora", size(3)) ///
	   subtitle("Regresión no paramétrica tipo Lowess", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   xscale (range(0 25)) ///
	   scheme(stcolor)
graph save Regresmopara_Lowessescolo2022.gph, replace

***Reg lpoly del log_salhora por años de escolaridad
twoway (lpoly log_salhora anios_esc if sex==1 & year==2022 & anios_esc >= 0 & anios_esc <= 25, color (blue)) ///
       (lpoly log_salhora anios_esc if sex==0 & year==2022 & anios_esc >= 0 & anios_esc <= 25, color (red)) ///
	   ,legend(label(1 "Hombres") label(2 "Mujeres") size(3)) ///
	   xtitle("Años de escolaridad", size(3)) ytitle("Logaritmo del salario por hora", size(3)) ///
	   subtitle("Regresión no paramétrica tipo Lpoly", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   xscale (range(0 25)) ///
	   scheme(stcolor)
graph save Regresmopara_lpolyescolo2022.gph, replace 

grc1leg Regresmopara_Lowessescolo2022.gph Regresmopara_lpolyescolo2022.gph, ///
    imargin(zero) ycommon xcommon subtitle("", size(3)) ///
    title("2022: Log-salario vs Escolaridad", size(3.5)) ///
	subtitle("", size(3)) ///
	caption("Elaboración propia con datos de la ENOE", size(2)) ///
	scheme(stcolor)
graph export "$graficosenoe\Reglowess_lpoly_logsalarioh_añosesc2022.png", replace



*+++++++++++++++++++++++++++++++++++++  AQUÍ ME QUEDE 17-SEPT 11:23 AM CORRERLO A PARTIR DE AQUÍ


*****e) Un problema de las gráficas lowess y lpoly es que no controlan por ninguna variable explicativa. Existe análisis semiparamétrico que permite controlar por variables explicativas o hacer una regresión del salario en función de sus variables explicativas ¿.
***+++++++++++++++++++++++++++Regresión del log_salhora & recolección de errores

****Este dta ya carga todos los reg & plreg del inciso que sigue, para no volver hacerlo y ahorrar tiempo. Solo falta correr las gráficas. SI QUIERES CORRERLOS POR TU CUENTA SIMPLEMENTE PONLE ASTERISCO A LA SIGUIENTE LINEA, Y QUITASELO A LOS REG, PREDICT & PLREG
use "$enoe\PROBLEMA5_ULTVERSION.dta", clear 


*****Para 2018
*reg log_salhora anios_esc  [aw=fac_tri] if year==2018
*predict log_salhoraresiduos2018, residuals

*reg eda anios_esc [aw=fac_tri] if year==2018
*predict edad_residuos2018, residuals


******Graficando los residuales de ambas var. dependientes por sexo para el año 2018
*********Para Hombres

********2018 lowess
twoway (lowess log_salhoraresiduos2018 edad_residuos2018 if sex==1 & year==2018 & anios_esc >= 0 & anios_esc <= 25, color (blue)) ///
       (lowess log_salhoraresiduos2018 edad_residuos2018 if sex==0 & year==2018 & anios_esc >= 0 & anios_esc <= 25, color (red)), ///
	   legend(label(1 "Hombres") label(2 "Mujeres") size(2.5) r(1)) ///
	   xtitle("Residuales de la edad", size(3)) ytitle("Residuales del Log Salario por hora", size(3)) ///
	   subtitle("Regresión no paramétrica tipo Lowess", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   scheme(stcolor) nodraw
graph save Residuales_logsalhora_edad_2018_lowess.gph, replace


********2018 lpoly
twoway (lpoly log_salhoraresiduos2018 edad_residuos2018 if sex==1 & year==2018 & anios_esc >= 0 & anios_esc <= 25, color (blue)) ///
       (lpoly log_salhoraresiduos2018 edad_residuos2018 if sex==0 & year==2018 & anios_esc >= 0 & anios_esc <= 25, color (red)), ///
	   legend(label(1 "Hombres") label(2 "Mujeres") size(2.5) r(1)) ///
	   xtitle("Residuales de la edad", size(3)) ytitle("Residuales del Log Salario por hora", size(3)) ///
	   subtitle("Regresión no paramétrica tipo Lpoly", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   scheme(stcolor) nodraw
graph save Residuales_logsalhora_edad_2018_lpoly.gph, replace


******Graficando los residuales de ambas var. dependientes por sexo para el año 2022

*reg log_salhora anios_esc [aw=fac_tri] if year==2022
*predict log_salhoraresiduos2022, residuals

*reg eda anios_esc [aw=fac_tri] if year==2022
*predict edad_residuos2022, residuals


********2022 lowess
twoway (lowess log_salhoraresiduos2022 edad_residuos2022 if sex==1 & year==2022 & anios_esc >= 0 & anios_esc <= 25, color (blue)) ///
       (lowess log_salhoraresiduos2022 edad_residuos2022 if sex==0 & year==2022 & anios_esc >= 0 & anios_esc <= 25, color (red)), ///
	   legend(label(1 "Hombres") label(2 "Mujeres") size(2.5) r(1)) ///
	   xtitle("Residuales de la edad", size(3)) ytitle("Residuales del Log Salario por hora", size(3)) ///
	   subtitle("Regresión no paramétrica tipo Lowess", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   scheme(stcolor) nodraw
graph save Residuales_logsalhora_edad_2022_lowess.gph, replace


********2022 lpoly
twoway (lpoly log_salhoraresiduos2022 edad_residuos2022 if sex==1 & year==2022 & anios_esc >= 0 & anios_esc <= 25, color (blue)) ///
       (lpoly log_salhoraresiduos2022 edad_residuos2022 if sex==0 & year==2022 & anios_esc >= 0 & anios_esc <= 25, color (red)), ///
	   legend(label(1 "Hombres") label(2 "Mujeres") size(2.5) r(1)) ///
	   xtitle("Residuales de la edad", size(3)) ytitle("Residuales del Log Salario por hora", size(3)) ///
	   subtitle("Regresión no paramétrica tipo Lpoly", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   scheme(stcolor) nodraw
graph save Residuales_logsalhora_edad_2022_lpoly.gph, replace

***********+++++++++++Adjuntando los gráficos anteriores por sexo para una mejor visualización.
grc1leg Residuales_logsalhora_edad_2018_lowess.gph Residuales_logsalhora_edad_2018_lpoly.gph, ///
    imargin(zero) ycommon xcommon subtitle("Comparación de residuos", size(3)) ///
    title("2018: Residuos del logaritmo del salario por hora vs edad", size(4)) ///
    caption("Elaboración propia con datos de la ENOE", size(2)) ///
	scheme(stcolor)
graph export "$graficosenoe\Comparacion_residuales_logsal_edad_2018.png", replace


grc1leg Residuales_logsalhora_edad_2022_lowess.gph Residuales_logsalhora_edad_2022_lpoly.gph, ///
    imargin(zero) ycommon xcommon subtitle("Comparación de residuos", size(3)) ///
    title("2022: Residuos del logaritmo del salario por hora vs edad", size(4)) ///
	caption("Elaboración propia con datos de la ENOE", size(2)) ///
	scheme(stcolor)
graph export "$graficosenoe\Comparacion_residuales_logsal_edad_2022.png", replace

*+++++++++++++++++++++++++++++++++++++++++++++++Inciso e.iii)


**Baja el ado file plreg, checa el help, y compara tus gráficas y resultados anteriores con el resultado de ese comando.
*search plreg
***	La dirección del net puede cambiar, depende de la dirección que salga en el  search plreg
net install st0109, from(http://www.stata-journal.com/software/sj6-3)


*******Linear partial regressions (semiparametric regression models)

***Para hombres 2018

*plreg log_salhora anios_esc if (sex == 1 & year == 2018 & anios_esc >= 0 & anios_esc <= 25), nlf(eda) generate(plregH2018) 

twoway (lowess log_salhora eda if sex==1 & year==2018, color(blue) lpattern(solid)) ///
       (lpoly log_salhora eda if sex==1 & year==2018, color(red) lpattern(dash)) ///
       (line plregH2018 eda if sex==1 & year==2018, sort color(green) lpattern(solid)) ///
       ,legend(label(1 "Lowess") label(2 "Lpoly") label(3 "Plreg") size(3) r(1)) ///
       xtitle("Edad", size(3)) ytitle("Log Salario por hora", size(3)) ///
	   subtitle("Año 2018", size(3)) ///
       xlabel(, labsize(small)) ylabel(, labsize(small)) ///
       scheme(stcolor)
graph save Comparacion_3regs_H2018.gph, replace


***Para mujeres 2018
*plreg log_salhora anios_esc if (sex==0 & year==2018 & anios_esc >= 0 & anios_esc <= 25), nlf(eda) generate(plregM2018)

twoway (lowess log_salhora eda if sex==0 & year==2018, color(blue) lpattern(solid)) ///
       (lpoly log_salhora eda if sex==0 & year==2018, color(red) lpattern(dash)) ///
       (line plregM2018 eda if sex==0 & year==2018, sort color(green) lpattern(solid)) ///
       ,legend(label(1 "Lowess") label(2 "Lpoly") label(3 "Plreg") size(3) r(1)) ///
       xtitle("Edad", size(3)) ytitle("Log Salario por hora", size(3)) ///
	   subtitle("Año 2018", size(3)) ///
       xlabel(, labsize(small)) ylabel(, labsize(small)) ///
       scheme(stcolor)
graph save Comparacion_3regs_M2018.gph, replace


***Para hombres 2022
*plreg log_salhora anios_esc if sex==1 & year==2022 & anios_esc >= 0 & anios_esc <= 25, nlf(eda) generate(plregH2022)

twoway (lowess log_salhora eda if sex==1 & year==2022, color(blue) lpattern(solid)) ///
	   (lpoly log_salhora eda if sex==1 & year==2022, color(red) lpattern(dash)) ///
	   (line plregH2022 eda if sex==1 & year==2022,sort color(green) lpattern(solid)) ///
		,legend(label(1 "Lowess") label(2 "Lpoly") label(3 "Plreg") size(3) r(1)) ///
	    xtitle("Edad", size(3)) ytitle("Log Salario por hora", size(3)) ///
	    xlabel(, labsize(small)) ylabel(, labsize(small)) ///
		subtitle("Año 2022", size(3)) ///
	    scheme(stcolor)
graph save Comparacion_3regs_H2022.gph, replace


***Para mujeres 2022

*plreg log_salhora anios_esc if sex==0 & year==2022 & anios_esc >= 0 & anios_esc <= 25, nlf(eda) generate(plregM2022)

twoway (lowess log_salhora eda if sex==0 & year==2022, color(blue) lpattern(solid)) ///
       (lpoly log_salhora eda if sex==0 & year==2022, color(red) lpattern(dash)) ///
       (line plregM2022 eda if sex==0 & year==2022, sort color(green) lpattern(solid)) ///
       ,legend(label(1 "Lowess") label(2 "Lpoly") label(3 "Plreg") size(3)) ///
       xtitle("Edad", size(3)) ytitle("Log Salario por hora", size(3)) ///
       xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   subtitle("Año 2022", size(3)) ///
       scheme(stcolor) 
graph save Comparacion_3regs_M2022.gph, replace

*************Combinando los gráficos por sexo.
***Para hombres
grc1leg Comparacion_3regs_H2018.gph Comparacion_3regs_H2022.gph, ///
    imargin(zero) ycommon xcommon  ///
    title("Log Salario por hora vs Edad: Lowess, Lpoly y Plreg: Hombres", size(3.5)) ///
	subtitle("Comparación entre años", size(3)) ///
	caption("Elaboración propia con datos de la ENOE", size(2))
graph export "$graficosenoe\plregHombres.png", replace

***Para Mujeres
grc1leg Comparacion_3regs_M2018.gph Comparacion_3regs_M2022.gph, ///
    imargin(zero) ycommon xcommon  ///
    title("Log Salario por hora vs Edad: Lowess, Lpoly y Plreg: Mujeres", size(3.5)) ///
	subtitle("Comparación entre años", size(3)) ///
	caption("Elaboración propia con datos de la ENOE", size(2))
graph export "$graficosenoe\plregMujeres.png", replace









