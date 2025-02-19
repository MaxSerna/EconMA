/*
Econometría Aplicada
Problem Set 2
Ejercicio 5
Max Brando Serna Leyva
2023-2025
*/

*********************************************************************************PARA LA ENIGH

global main = "D:\Eco aplicada\Tarea 2\5"
global enigh = "$main\Bases\ENIGH"
global graficosenigh = "$main\Gráficos\ENIGH"
global resultadosenigh = "$main\Resultados\ENIGH"

use "$enigh\basefinal.dta", clear
drop if htrab==0
*******Generando el log de la variable salario por hora   
gen log_salhora= .
replace log_salhora=log(salario_hora) 
*---------------------------------------------INCISO 2)

***Restringiendo los valores de los salarios por hora. 

twoway (kdensity salario_hora if inlist(year, 1992, 1994, 1996, 1998, 2000, 2002, 2004, 2005, 2006, 2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022)  & salario_hora <= 500, lc(blue) lwidth(0.5)), ///
       by(year, style(stata7) title("Distribución del salario por hora por año, 1992 - 2022", size(4) position(12)) note("") ///
	   caption("Fuente: Elaboración propia con datos de la ENIGH", size(2))) ///
	   ytitle("Densidad del salario por hora", size(3)) xticks(0(50)500) ///
	   xtitle("Salario por hora", size(3)) ///
	   xlabel(0(100)500, labsize(small)) ///
	   ylabel(, labsize(small)) ///
	   ysize(30cm) xsize(40cm) ///
	   scheme(stcolor)
graph export "$graficosenigh\kdensityacotado.png", replace	


* Distribución no paramétrica para el log_salhora
kdensity log_salhora, graph normal
graph export "$graficosenigh\kdensity_logsalhora.png", replace

****Grafica una distribución no paramétrica para esta nueva variable	
twoway (kdensity log_salhora if inlist(year, 1992, 1994, 1996, 1998, 2000, 2002, 2004, 2005, 2006, 2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022), lc(blue) lwidth(0.5)), ///
       by(year, note("") style(stata7) title("Distribución del log_salario por hora por año, 1992 - 2022", size(4) position(12)) caption("Fuente: Elaboración propia con datos de la ENIGH", size(2))) ///
	   ytitle("Densidad del Log_salario por hora", size(3)) ///
	   xticks(0(1)9) /// 
	   xtitle("Log del salario por hora", size(3)) ///
	   xlabel(0(2)9, labsize(small)) ///
	   ylabel(, labsize(small)) ///
	   ysize(30cm) xsize(40cm) ///
	   scheme(stcolor)	   
graph export "$graficosenigh\kdensitylog_salhora.png", replace

******-----------------------------------------------------------------Inciso 3)
***********Crea dos gráficas con distribuciones no paramétricas con diferentes bandwidth para un año

twoway (kdensity log_salhora if year == 2022, bw(2) lcolor(blue) lwidth(medium)) ///
       , scheme(stcolor) ///
         subtitle("Bw=2", size(3.5)) ///
         xtitle("Logaritmo Natural del Salario por Hora", size(3)) ///
         ytitle("Densidad", size(3)) ///
         caption("", size(2)) nodraw
graph save Distnopara_diferentebandmedioenigh.gph, replace 

twoway (kdensity log_salhora if year == 2022, bw(0.01) lcolor(blue) lwidth(medium)) ///
       , scheme(stcolor) ///
         subtitle("Bw=0.01", size(3.5))  ///
         xtitle("Logaritmo Natural del Salario por Hora", size(3)) ///
         ytitle("Densidad", size(3)) ///
		 caption("", size(2)) nodraw
graph save Distnopara_diferentebandbajoenigh.gph, replace 


***Junta los dos gráficos anteriores
graph combine Distnopara_diferentebandmedioenigh.gph Distnopara_diferentebandbajoenigh.gph, ///
    imargin(zero) ycommon xcommon subtitle("", size(3)) ///
    title("Distribución no paramétrica del salario por hora, 2022", size(4)) ///
	subtitle("Para diferentes bandwidth", size(3)) ///
	caption("Elaboración propia con datos de la ENIGH", size(2)) ///
	scheme(stcolor)
graph export "$graficosenigh\Distr_npara_difband.png", replace


/*
**Por si quieren correr otro gráfico para un bandwidth menor
twoway (kdensity log_salhora if year == 2022, bw(0.001) lcolor(blue) lwidth(medium)) ///
       , scheme(stcolor) ///
	    title("Distribución no paramétrica del salario por hora, 2022", size(4)) ///
         subtitle("Bw=0.001", size(3.5))  ///
         xtitle("Logaritmo Natural del Salario por Hora", size(3)) ///
         ytitle("Densidad", size(3)) ///
		 caption("Elaboración propia con datos de la ENIGH", size(2))
graph export "Distnopara_diferentebandmuybajoenigh.png", replace 
*/


************Crea dos gráficas con distribuciones no paramétricas con diferentes kernels para un año (Gaussian y Epanechnikov) para el mismo bandwidth 

twoway (kdensity log_salhora if year == 2022, kernel(gaussian) lcolor(blue) lwidth(medium)) ///
     , scheme(stcolor) ///
	   subtitle("Kernel(Gaussian)", size(3))  ///
       xtitle("Logaritmo Natural del Salario por Hora", size(3)) ///
       ytitle("Densidad", size(3)) ///
	   caption("", size(2)) nodraw
graph save Distnopara_gaussianenigh.gph, replace 


twoway (kdensity log_salhora if year == 2022, kernel(epanechnikov) lcolor(blue) lwidth(medium)) ///
     , scheme(stcolor) ///
	   subtitle("Kernel(Epanechnikov)", size(3))  ///
       xtitle("Logaritmo Natural del Salario por Hora", size(3)) ///
       ytitle("", size(3)) ///
	   caption("", size(2)) nodraw
graph save Distnopara_epanechenigh.gph, replace 	   

graph combine Distnopara_gaussianenigh.gph Distnopara_epanechenigh.gph, ///
    imargin(zero) ycommon xcommon subtitle("", size(3)) ///
    title("Distribución no paramétrica del salario por hora, 2022", size(4)) ///
	subtitle("Para diferentes Kernels considerando Bw óptimo (default de Stata)", size(3)) ///
	caption("Elaboración propia con datos de la ENIGH", size(2)) ///
	scheme(stcolor)
graph export "$graficosenigh\Distr_npara_difkernel.png", replace

******----------------------------------------------------------------Inciso 4)

*************Grafica la distribución no paramétrica del logaritmo del salario por hora del año 2016 con la de /// los años 2018 y 2022 en el mismo gráfico utilizando el bandwidth óptimo de Silverman.

/*
/*
OPCIONAL: El código siguiente nos permite confirmar que el comando kdensity utiliza el bandwidth óptimo de Silverman
*/

* Calcularndo los bandwidth optimos de Silverman para cada año
* Calculate summary statistics
summarize log_salhora if year == 2016, detail
scalar iqr_2016 = r(p75) - r(p25)
scalar bw_2016 = 0.9 * min(r(sd), iqr_2016 / 1.349) * r(N)^(-1/5)

summarize log_salhora if year == 2018, detail
scalar iqr_2018 = r(p75) - r(p25)  
scalar bw_2018 = 0.9 * min(r(sd), iqr_2018 / 1.349) * r(N)^(-1/5)

summarize log_salhora if year == 2022, detail
scalar iqr_2022 = r(p75) - r(p25)
scalar bw_2022 = 0.9 * min(r(sd), iqr_2022 / 1.349) * r(N)^(-1/5)

* Kernel density estimation for 2016
kdensity log_salhora if year == 2016, nodraw
scalar bw_2016_stata = r(bwidth)

* Kernel density estimation for 2018
kdensity log_salhora if year == 2018, nodraw
scalar bw_2018_stata = r(bwidth)

* Kernel density estimation for 2022
kdensity log_salhora if year == 2022, nodraw
scalar bw_2022_stata = r(bwidth)

* Display the bandwidths
di "Bandwidth para 2016. Calculado: " bw_2016 ". De Stata: " bw_2016_stata
di "Bandwidth para 2018. Calculado: " bw_2018 ". De Stata: " bw_2018_stata
di "Bandwidth para 2022. Calculado: " bw_2022 ". De Stata: " bw_2022_stata

*/


* Crear la gráfica usando los bandwidths óptimos

twoway (kdensity log_salhora if year == 2016, lcolor(blue) lwidth(medium) lpattern(solid)) ///
       (kdensity log_salhora if year == 2018, lcolor(red) lwidth(medthick) lpattern(shortdash)) ///
       (kdensity log_salhora if year == 2022, lcolor(green) lwidth(medthick) lpattern(longdash)) ///
       , title("Distribución no paramétrica del Logaritmo del Salario por Hora", size (4)) ///
         subtitle("Años: 2016, 2018 y 2022 (Bandwidth óptimo de Silverman)", size(3)) ///
         xtitle("Logaritmo Natural del Salario por Hora", size(2.5)) ///
         ytitle("Densidad", size(2.5)) ///
         legend(label(1 "Año 2016") label(2 "Año 2018") label(3 "Año 2022") size(2.5) r(1) pos(6)) ///
         xlabel(, labsize(small)) ylabel(, labsize(small)) ///
		 caption("Elaboración propia con datos de la ENIGH", size(2)) ///
		 scheme(stcolor)
graph export "$graficosenigh\kdensity_logsalhora_silverman.png", replace

*******-------------------------------------------------------------Inciso 5) ME QUEDE AQUI 13-SEPT 2:30 PM
****b)
*Escoge el año de 2018. Grafica no paramétricamente utilizando lowess y lpoly el logaritmo del salario por hora separadamente para hombres y mujeres.

**Recodificando la var sexo
recode sexo (1=1) (2=0)
label define l_sexo 1 "Hombre" 0 "Mujer"
label values sexo l_sexo

***Reg lowess del log_salhora por edad

twoway (lowess log_salhora edad if sex==1 & year==2018, color(blue)) ///
       (lowess log_salhora edad if sex==0 & year==2018, color(red)) ///
       , legend(label(1 "Hombres") label(2 "Mujeres") size(small) r(1)) ///
       xtitle("Edad", size(3)) ytitle("Logaritmo del salario por hora", size(3)) ///
       subtitle("Regresión no paramétrica tipo Lowess", size(3)) ///
       xlabel(, labsize(small)) ylabel(, labsize(small)) ///
       xscale(range(25 65)) ///
       scheme(stcolor) nodraw
graph save Regresmopara_Lowessedad2018enigh.gph, replace
*graph export "$graficosenigh\Regresnopara_Lowessedad2018enigh.png", replace

***Reg lpoly del log_salhora por edad

twoway (lpoly log_salhora edad if sex==1 & year==2018, color (blue)) ///
       (lpoly log_salhora edad if sex==0 & year==2018, color (red)) ///
	   ,legend(label(1 "Hombres") label(2 "Mujeres") size(small)) ///
	   xtitle("Edad", size(3)) ytitle("Logaritmo del salario por hora", size(3)) ///
	   subtitle("Regresión no paramétrica tipo Lpoly", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   xscale (range(25 65)) ///
	   scheme(stcolor) nodraw
graph save Regresmopara_Lpolyedad2018enigh.gph, replace	 


grc1leg Regresmopara_Lowessedad2018enigh.gph Regresmopara_Lpolyedad2018enigh.gph, ///
    imargin(zero) ycommon xcommon subtitle("", size(3)) ///
    title("2018: Log-salario vs Edad", size(4)) ///
	subtitle("", size(3)) ///
	caption("Elaboración propia con datos de la ENIGH", size(2)) ///
	scheme(stcolor)
graph export "$graficosenigh\Reglowess_lpoly_logsalarioh_edad2018.png", replace



***Reg lowess del log_salhora por años de educación
twoway (lowess log_salhora years_ed if sex==1 & year==2018, color (blue)) ///
       (lowess log_salhora years_ed if sex==0 & year==2018, color (red)) ///
	   ,legend(label(1 "Hombres") label(2 "Mujeres") size(small) r(1)) ///
	   xtitle("Años de escolaridad", size(3)) ytitle("Logaritmo del salario por hora", size(3)) ///
	   subtitle("Regresión no paramétrica tipo Lowess", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   scheme(stcolor) nodraw
graph save Regresmopara_Lowessescolo2018enigh.gph, replace 
*graph export "$graficosenigh\Regresnopara_Lowessescolo2018enigh.png", replace


***Reg lpoly del log_salhora por años de educación

twoway (lpoly log_salhora years_ed if sex==1 & year==2018, color (blue)) ///
       (lpoly log_salhora years_ed if sex==0 & year==2018, color (red)) ///
	   ,legend(label(1 "Hombres") label(2 "Mujeres") size(small)) ///
	   xtitle("Años de escolaridad", size(3)) ytitle("Logaritmo del salario por hora", size(3)) ///
	   subtitle("Regresión no paramétrica tipo Lpoly", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   scheme(stcolor) nodraw
graph save Regresmopara_lpolyescolo2018enigh.gph, replace 
*graph export "$gráficosenigh\Regresnopara_lpolyescolo2018enigh.png", replace

grc1leg Regresmopara_Lowessescolo2018enigh.gph Regresmopara_lpolyescolo2018enigh.gph, ///
    imargin(zero) ycommon xcommon subtitle("", size(3)) ///
    title("2018: Log-salario vs Escolaridad", size(4)) ///
	subtitle("", size(3)) ///
	caption("Elaboración propia con datos de la ENIGH", size(2)) ///
	scheme(stcolor) ///
	
graph export "$graficosenigh\Reglowess_logsalarioh_niveleduc2018conetiqueta.png", replace




****c) Escoge el año de 2022. Grafica no paramétricamente utilizando lowess y lpoly el logaritmo del salario por hora separadamente para hombres y mujeres.

***Reg lowess del log_salhora por edad

twoway (lowess log_salhora edad if sex==1 & year==2022, color(blue)) ///
       (lowess log_salhora edad if sex==0 & year==2022, color(red)) ///
       , legend(label(1 "Hombres") label(2 "Mujeres") size(small) r(1)) ///
       xtitle("Edad", size(3)) ytitle("Logaritmo del salario por hora", size(3)) ///
       subtitle("Regresión no paramétrica tipo Lowess", size(3)) ///
       xlabel(, labsize(small)) ylabel(, labsize(small)) ///
       xscale(range(25 65)) ///
       scheme(stcolor) nodraw
graph save Regresmopara_Lowessedad2022enigh.gph, replace
*graph export "$graficosenigh\Regresnopara_Lowessescolo2022enigh.png", replace   
///Si quieren guardar la gráfica se debe quitar el nodraw


***Reg lpoly del log_salhora por edad

twoway (lpoly log_salhora edad if sex==1 & year==2022, color (blue)) ///
       (lpoly log_salhora edad if sex==0 & year==2022, color (red)) ///
	   ,legend(label(1 "Hombres") label(2 "Mujeres") size(small)) ///
	   xtitle("Edad", size(3)) ytitle("Logaritmo del salario por hora", size(3)) ///
	   subtitle("Regresión no paramétrica tipo Lpoly", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   xscale (range(25 65)) ///
	   scheme(stcolor) nodraw
graph save Regresmopara_Lpolyedad2022enigh.gph, replace	   


grc1leg Regresmopara_Lowessedad2022enigh.gph Regresmopara_lpolyedad2022enigh.gph, ///
    imargin(zero) ycommon xcommon subtitle("", size(3)) ///
    title("2022: Log-salario vs Edad", size(4)) ///
	subtitle("", size(3)) ///
	caption("Elaboración propia con datos de la ENIGH", size(2)) ///
	scheme(stcolor)
graph export "$graficosenigh\Reglowess_lpoly_logsalarioh_edad2022.png", replace


***Reg lowess del log_salhora por años de educación
twoway (lowess log_salhora years_ed if sex==1 & year==2022, color (blue)) ///
       (lowess log_salhora years if sex==0 & year==2022, color (red)) ///
	   ,legend(label(1 "Hombres") label(2 "Mujeres") size(small) r(1)) ///
	   xtitle("Años de escolaridad", size(3)) ytitle("Logaritmo del salario por hora", size(3)) ///
	   subtitle("Regresión no paramétrica tipo Lowess", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   scheme(stcolor) nodraw
graph save Regresmopara_Lowessescolo2022enigh.gph, replace
*graph export "$graficosenigh\Regresnopara_Lowessescolo2022enigh.png", replace

***Reg lpoly del log_salhora por nivel educativo

twoway (lpoly log_salhora years_ed if sex==1 & year==2022, color (blue)) ///
       (lpoly log_salhora years_ed if sex==0 & year==2022, color (red)) ///
	   ,legend(label(1 "Hombres") label(2 "Mujeres") size(small)) ///
	   xtitle("Años de escolaridad", size(3)) ytitle("Logaritmo del salario por hora", size(3)) ///
	   subtitle("Regresión no paramétrica tipo Lpoly", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   scheme(stcolor) nodraw
graph save Regresmopara_lpolyescolo2022enigh.gph, replace 


grc1leg Regresmopara_Lowessescolo2022enigh.gph Regresmopara_lpolyescolo2022enigh.gph, ///
    imargin(zero) ycommon xcommon subtitle("", size(3)) ///
    title("2022: Log-salario vs Escolaridad", size(4)) ///
	subtitle("", size(3)) ///
	caption("Elaboración propia con datos de la ENIGH", size(2)) ///
	scheme(stcolor)
graph export "$graficosenigh\Reglowess_logsalarioh_niveleduc2022conetiqueta.png", replace




*****e) Un problema de las gráficas lowess y lpoly es que no controlan por ninguna variable explicativa. Existe análisis semiparamétrico que permite controlar por variables explicativas o hacer una regresión del salario en función de sus variables explicativas ¿.
***+++++++++++++++++++++++++++Regresión del log_salhora & recolección de errores. NOTA: DEFINIR EL PONDERADOR
*****Para 2018
reg log_salhora years_ed rural [aw=factor] if year==2018
predict log_salhoraresiduos2018enigh, residuals

reg edad years_ed rural [aw=factor] if year==2018      
predict edad_residuos2018enigh, residuals

******Graficando los residuales de ambas var. dependientes por sexo para el año 2022

reg log_salhora years_ed rural[aw=factor] if year==2022
predict log_salhoraresiduos2022enigh, residuals

reg edad years_ed rural [aw=factor] if year==2022
predict edad_residuos2022enigh, residuals

********2018 lowess
twoway (lowess log_salhoraresiduos2018enigh edad_residuos2018enigh if sex==1 & year==2018, color (blue)) ///
       (lowess log_salhoraresiduos2018enigh edad_residuos2018enigh if sex==0 & year==2018, color (red)), ///
	   legend(label(1 "Hombres") label(2 "Mujeres") size(2.5) r(1)) ///
	   xtitle("Residuales de la edad", size(3)) ytitle("Residuales del Log Salario por hora", size(3)) ///
	   subtitle("Regresión no paramétrica tipo Lowess", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   scheme(stcolor) nodraw
graph save Residuales_logsalhora_edad_2018enigh_lowess.gph, replace

********2018 lpoly
twoway (lpoly log_salhoraresiduos2018enigh edad_residuos2018enigh if sex==1 & year==2018, color (blue)) ///
       (lpoly log_salhoraresiduos2018enigh edad_residuos2018enigh if sex==0 & year==2018, color (red)), ///
	   legend(label(1 "Hombres") label(2 "Mujeres") size(2.5) r(1)) ///
	   xtitle("Residuales de la edad", size(3)) ytitle("Residuales del Log Salario por hora", size(3)) ///
	   subtitle("Regresión no paramétrica tipo Lpoly", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   scheme(stcolor) nodraw
graph save Residuales_logsalhora_edad_2018enigh_lpoly.gph, replace

******Graficando los residuales de ambas var. dependientes por sexo para el año 2022

********2022 lowess
twoway (lowess log_salhoraresiduos2022enigh edad_residuos2022enigh if sex==1 & year==2022, color (blue)) ///
       (lowess log_salhoraresiduos2022enigh edad_residuos2022enigh if sex==0 & year==2022, color (red)), ///
	   legend(label(1 "Hombres") label(2 "Mujeres") size(2.5) r(1)) ///
	   xtitle("Residuales de la edad", size(3)) ytitle("Residuales del Log Salario por hora", size(3)) ///
	   subtitle("Regresión no paramétrica tipo Lowess", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   scheme(stcolor) nodraw
graph save Residuales_logsalhora_edad_2022enigh_lowess.gph, replace


********2022 lpoly
twoway (lpoly log_salhoraresiduos2022enigh edad_residuos2022enigh if sex==1 & year==2022, color (blue)) ///
       (lpoly log_salhoraresiduos2022enigh edad_residuos2022enigh if sex==0 & year==2022, color (red)), ///
	   legend(label(1 "Hombres") label(2 "Mujeres") size(2.5) r(1)) ///
	   xtitle("Residuales de la edad", size(3)) ytitle("Residuales del Log Salario por hora", size(3)) ///
	   subtitle("Regresión no paramétrica tipo Lpoly", size(3)) ///
	   xlabel(, labsize(small)) ylabel(, labsize(small)) ///
	   scheme(stcolor) nodraw
graph save Residuales_logsalhora_edad_2022enigh_lpoly.gph, replace

***********+++++++++++Adjuntando los gráficos anteriores por sexo para una mejor visualización.
grc1leg Residuales_logsalhora_edad_2018enigh_lowess.gph Residuales_logsalhora_edad_2018enigh_lpoly.gph, ///
    imargin(zero) ycommon xcommon subtitle("Comparación de residuos", size(3)) ///
    title("2018: Residuos del logaritmo del salario por hora vs edad", size(4)) ///
    saving(Comparacion_Residuales_logsalhora_edad_Hombres.gph, replace) ///
	scheme(stcolor)
graph export "$graficosenigh\Comparacion_residuales_logsal_edad_2018.png", replace


grc1leg Residuales_logsalhora_edad_2022enigh_lowess.gph Residuales_logsalhora_edad_2022enigh_lpoly.gph, ///
    imargin(zero) ycommon xcommon subtitle("Comparación de residuos", size(3)) ///
    title("2022: Residuos del logaritmo del salario por hora vs edad", size(4)) ///
    saving(Comparacion_Residuales_logsalhora_edad_Hombres.gph, replace) ///
	scheme(stcolor)
graph export "$graficosenigh\Comparacion_residuales_logsal_edad_2022.png", replace




*+++++++++++++++++++++++++++++++++++++++++++++++Inciso e.iii)


**Baja el ado file plreg, checa el help, y compara tus gráficas y resultados anteriores con el resultado de ese comando.
search plreg
net install st0109, from(http://www.stata-journal.com/software/sj6-3)

****Este dta ya carga todos lo plreg del inciso que sigue, para no volver hacerlo y ahorrar tiempo. Solo falta correr las gráficas
*******Linear partial regressions (semiparametric regression models)

***Para hombres 2018
***CAMBIAR ANIOS_ESC POR NIVEL EDUCATIVO
plreg log_salhora years_ed rural if (sex == 1 & year == 2018), nlf(edad) generate(plregH2018enigh) 

twoway (lowess log_salhora edad if sex==1 & year==2018, color(blue) lpattern(solid)) ///
       (lpoly log_salhora edad if sex==1 & year==2018, color(red) lpattern(dash)) ///
       (line plregH2018enigh edad if sex==1 & year==2018, sort color(green) lpattern(solid)) ///
       ,legend(label(1 "Lowess") label(2 "Lpoly") label(3 "Plreg") size(small) r(1)) ///
	   subtitle("2018", size(3)) ///
       xtitle("Edad", size(2.5)) ytitle("Log Salario por hora", size(2.5)) ///
       xlabel(, labsize(small)) ylabel(, labsize(small)) ///
       scheme(stcolor) nodraw
graph save Comparacion_3regs_H2018enigh.gph, replace


***Para mujeres 2018
plreg log_salhora years_ed rural if (sex==0 & year==2018), nlf(edad) generate(plregM2018enigh)

twoway (lowess log_salhora edad if sex==0 & year==2018, color(blue) lpattern(solid)) ///
       (lpoly log_salhora edad if sex==0 & year==2018, color(red) lpattern(dash)) ///
       (line plregM2018enigh edad if sex==0 & year==2018, sort color(green) lpattern(solid)) ///
       ,legend(label(1 "Lowess") label(2 "Lpoly") label(3 "Plreg") size(small) r(1)) ///
	   subtitle("2018", size(3)) ///
       xtitle("Edad", size(2.5)) ytitle("Log Salario por hora", size(2.5)) ///
       xlabel(, labsize(small)) ylabel(, labsize(small)) ///
       scheme(stcolor) nodraw
graph save Comparacion_3regs_M2018enigh.gph, replace


***Para hombres 2022
plreg log_salhora years_ed rural if sex==1 & year==2022, nlf(edad) generate(plregH2022enigh)

twoway (lowess log_salhora edad if sex==1 & year==2022, color(blue) lpattern(solid)) ///
	   (lpoly log_salhora edad if sex==1 & year==2022, color(red) lpattern(dash)) ///
	   (line plregH2022enigh edad if sex==1 & year==2022,sort color(green) lpattern(solid)) ///
	   ,legend(label(1 "Lowess") label(2 "Lpoly") label(3 "Plreg") size(small)) ///
	   	subtitle("2022", size(3)) ///
	    xtitle("Edad", size(2.5)) ytitle("Log Salario por hora", size(2.5)) ///
		xlabel(, labsize(small)) ylabel(, labsize(small)) ///
		scheme(stcolor) nodraw
graph save Comparacion_3regs_H2022enigh.gph, replace


***Para mujeres 2022

plreg log_salhora years_ed rural if sex==0 & year==2022, nlf(edad) generate(plregM2022enigh)

twoway (lowess log_salhora edad if sex==0 & year==2022, color(blue) lpattern(solid)) ///
       (lpoly log_salhora edad if sex==0 & year==2022, color(red) lpattern(dash)) ///
       (line plregM2022enigh edad if sex==0 & year==2022, sort color(green) lpattern(solid)) ///
       ,legend(label(1 "Lowess") label(2 "Lpoly") label(3 "Plreg") size(small)) ///
	   subtitle("2022", size(3)) ///
       xtitle("Edad", size(2.5)) ytitle("Log Salario por hora", size(2.5)) ///
       xlabel(, labsize(small)) ylabel(, labsize(small)) ///
       scheme(stcolor) nodraw
graph save Comparacion_3regs_M2022enigh.gph, replace

*************Combinando los gráficos por sexo.
***Para hombres
grc1leg Comparacion_3regs_H2018enigh.gph Comparacion_3regs_H2022enigh.gph, ///
    imargin(zero) ycommon xcommon  ///
    title("Log Salario por hora vs Edad: Lowess, Lpoly y Plreg. 2018 vs 2022", size(3.5)) ///
	subtitle("Para Hombres", size(2.5)) ///
	caption("Elaboración propia con datos de la ENIGH", size(2)) ///
	scheme(stcolor)
graph export "$graficosenigh\plreg_Hombres.png", replace

***Para Mujeres
grc1leg Comparacion_3regs_M2018enigh.gph Comparacion_3regs_M2022enigh.gph, ///
    imargin(zero) ycommon xcommon  ///
    title("Log Salario por hora vs Edad: Lowess, Lpoly y Plreg. 2018 vs 2022", size(3.5)) ///
	subtitle("Para Mujeres", size(3)) ///
	caption("Elaboración propia con datos de la ENIGH", size(2)) ///
	scheme(stcolor)
graph export "$graficosenigh\plregMujeres.png", replace









