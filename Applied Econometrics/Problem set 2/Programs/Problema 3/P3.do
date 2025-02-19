/*
Econometría Aplicada
Problem Set 2
Ejercicio 3
Max Brando Serna Leyva
2023-2025
*/


* Definir las rutas globales
global general "D:\Eco aplicada\Tarea 2\3"
global datos "$general\datos"
global graphs "$general\Gráficas"


*---- Problema 3 ---------------------------------------------------------------
*----------------- Problema 3.3 ------------------------------------------------
* Queremos observar las variaciones de los salarios (logaritmo) para los años 
* 2016, 2018 y 2022 diferenciado por hombre y mujer por cada percentil.

/*
* Cargar el archivo de datos
use "$datos\base final.dta", clear

*Crear la variable de logaritmo del salario por hora
gen log_salario_hora = log(salario_hora)

keep if !missing(log_salario_hora)
drop if log_salario_hora == 0

*Genera dummy de mujer 
generate female =(sexo ==0)

*Creamos los cuantiles
foreach i of numlist 2016 2018 2020 2022{
pctile hom_`i'= log_salario_hora if year == `i' & female==0 [fw = factor], n(100)
pctile muj_`i'= log_salario_hora if year == `i' & female==1 [fw = factor], n(100)
}
*Luego, nos quedamos solamente con las observaciones con los percentiles asociados
keep hom* muj* 
keep in 1/99

*Añadimos el year del percentil
gen percentil = _n

*Cambios entre years para hombres y mujeres
gen hom_crec_16_22 = hom_2022-hom_2016
gen hom_crec_18_22 = hom_2022-hom_2018
gen muj_crec_16_22 = muj_2022-muj_2016
gen muj_crec_18_22 = muj_2022-muj_2018


*Etiquetamos las variables
label var hom_crec_16_22 "Crecimiento % salario de hombres, 2016 a 2022"
label var hom_crec_18_22 "Crecimiento % salario de hombres, 2018 a 2022"
label var muj_crec_16_22 "Crecimiento % salario de mujeres, 2016 a 2022"
label var muj_crec_18_22 "Crecimiento % salario de mujeres, 2018 a 2022"

keep *_crec_* percentil

save "$datos\base1.dta", replace

*/

*Gráficos 
use "$datos\base1.dta", clear

foreach var of varlist hom_crec_16_22 hom_crec_18_22 muj_crec_16_22 muj_crec_18_22 {
    replace `var' = `var'*100
}

* 16-22
twoway (line hom_crec_16_22  percentil, lwidth(medthick) lpattern(shortdash) color(blue)) ///
	   (line muj_crec_16_22  percentil, lwidth(medium) lpattern(solid) color(pink)) ///
	   (rarea hom_crec_16_22 muj_crec_16_22  percentil, color(lavender%15)), ///
	   xtitle("Percentiles", size(small)) ///
	   yline(0, lcolor(black) lpattern(longdash)) ///
	   ytitle("%" , size(small) orientation(horizontal)) ///
	   graphregion(fcolor(white)) ///
	   title("Variación porcentual en el salario por hora", size(medium)) ///
	   subtitle("2016 - 2022. Comparación entre géneros", size(small)) ///
	   legend(pos(6) r(1) size(small)) ///
	   note(Fuente: Elaboración propia con datos de ENIGH, size(small)) ///
	   legend(order(1 "Hombres" 2 "Mujeres" 3 "Brecha") size(small) pos(6) rows(1)) ///
	   ylabel(-15(5)35, angle(0) labsize(small)) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white)
		   
graph export "$graphs\sal_enigh_16_22.png", replace

* 18-22	
twoway (line hom_crec_18_22  percentil, lwidth(medthick) lpattern(shortdash) color(blue)) ///
	   (line muj_crec_18_22  percentil, lwidth(medium) lpattern(solid) color(pink)) ///
	   (rarea hom_crec_18_22 muj_crec_18_22  percentil, color(lavender%15)), ///
	   xtitle("Percentiles", size(small)) ///
	   yline(0, lcolor(black) lpattern(longdash)) ///
	   ytitle("%" , size(small) orientation(horizontal)) ///
	   graphregion(fcolor(white)) ///
	   title("Variación porcentual en el salario por hora", size(medium)) ///
	   subtitle("2018 - 2022. Comparación entre géneros", size(small)) ///
	   legend(pos(6) r(1) size(small)) ///
	   note(Fuente: Elaboración propia con datos de ENIGH, size(small)) ///
	   legend(order(1 "Hombres" 2 "Mujeres" 3 "Brecha") size(small) pos(6) rows(1)) ///
	   ylabel(-12(5)25, angle(0) labsize(small)) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white)
		   
graph export "$graphs\sal_enigh_18_22.png", replace


* Version con gráficos en mismo renglón
* 16-22
twoway (line hom_crec_16_22  percentil, lwidth(medthick) lpattern(shortdash) color(blue)) ///
	   (line muj_crec_16_22  percentil, lwidth(medium) lpattern(solid) color(pink)) ///
	   (rarea hom_crec_16_22 muj_crec_16_22  percentil, color(lavender%15)), ///
	   xtitle("Percentiles", size(small)) ///
	   yline(0, lcolor(black) lpattern(longdash)) ///
	   ytitle("%" , size(small) orientation(horizontal)) ///
	   graphregion(fcolor(white)) ///
	   title("2016 - 2022", size(medium)) ///
	   legend(order(1 "Hombres" 2 "Mujeres" 3 "Brecha") size(small) pos(6) rows(1)) ///
	   ylabel(-15(5)35, angle(0) labsize(small)) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   scheme(stsj) ///
	   bgcolor(white) ///
	   nodraw
graph save "$graphs\plot1.jpg", replace

* 18-22	
twoway (line hom_crec_18_22  percentil, lwidth(medthick) lpattern(shortdash) color(blue)) ///
	   (line muj_crec_18_22  percentil, lwidth(medium) lpattern(solid) color(pink)) ///
	   (rarea hom_crec_18_22 muj_crec_18_22  percentil, color(lavender%15)), ///
	   xtitle("Percentiles", size(small)) ///
	   yline(0, lcolor(black) lpattern(longdash)) ///
	   ytitle("") ///
	   graphregion(fcolor(white)) ///
	   title("2018 - 2022", size(medium)) ///
	   ylabel(-15(5)35, nolab) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   scheme(stsj) ///
	   bgcolor(white) ///
	   nodraw
graph save "$graphs\plot2.jpg", replace

grc1leg "$graphs\plot1.jpg" "$graphs\plot2.jpg", ///
       col(2) ///
	   row(1) ///
	   iscale(0.8) ///
	   xcommon ycommon ///
	   title("Variación porcentual en el salario por hora", size(small)) ///
	   subtitle("Comparación entre sexos", margin(b=3) size(small)) ///
	   imargin(vsmall) ///
	   legendfrom("$graphs\plot1.jpg") ///
	   caption("Elaboración propia con datos de la ENIGH.", ///
	   size(vsmall) span)
	   
graph display , ysize(45cm) xsize(80cm)
graph export "$graphs\Sal_16 y 18 vs 22.jpg", replace



*----------------- Problema 3.4 ------------------------------------------------
* Queremos estimar la relación entre el log del salario y las siguientes variables
* escolaridad, edad, edad^2, dummy rural y dummy de famale  para cada uno de los
* cuantiles para los años 2016, 2018, 2022. Además etimar OLS

/*

* Cargar el archivo de datos
use "$datos\base final.dta", clear

*Crear la variable de logaritmo del salario por hora
gen log_salario_hora = log(salario_hora)

*Generamos la varaibel años al cuadrado
gen edad2 = edad^2

*Genera dummy de mujer 
generate female =(sexo ==0)


* Corremos las regresiones cuantiles
* Ponemos un valor de tolerancia de 0.0001 para las iteraciones en caso de no
* converger a cero.
foreach year in 2016 2022 {
	forvalues q = 1(1)99 {
		local quant = `q' / 100
		qreg log_salario_hora years_ed edad edad2 female rural [pweight = factor] if year == `year', quantile(`quant') iterate(100) 
		matrix b_cuantil_`year'_`q' = e(b)
		matrix se_cuantil_`year'_`q' = e(V)
		}
}
		
* Estimar usando MCO para 2016 y 2022
foreach year in 2016 2022 {
	regress log_salario_hora years_ed edad edad2 female rural [pweight = factor] if year == `year'
    matrix b_ols_`year' = e(b)
	matrix se_ols_`year' = e(V)
}

* Para graficar los resultados
* Crear un dataset vacío para guardar los coeficientes

* Llenar el dataset con los coeficientes cuantil 
foreach year in 2016 2022 {
	forvalues q = 1(1)99 {
		* Extraer coeficientes e IC para escolaridad y género
		matrix coef_cuantil_`year'_`q' = b_cuantil_`year'_`q'
		matrix se_cuantil_`year'_`q' = se_cuantil_`year'_`q'
		}
}
		
foreach year in 2016 2022 {
	forvalues q = 1(1)99 {
		* Escolaridad
		scalar coef_ed_`year'_`q' = coef_cuantil_`year'_`q'[1, "years_ed"]
		scalar se_ed_`year'_`q' = se_cuantil_`year'_`q'[1, "years_ed"]
		scalar lb_ed_`year'_`q' = coef_ed_`year'_`q' - (-1.959983) * se_ed_`year'_`q'
		scalar ub_ed_`year'_`q' = coef_ed_`year'_`q' + (-1.959983) * se_ed_`year'_`q'
		}
}	
			
foreach year in 2016 2022 {
	forvalues q = 1(1)99 {	
		* Sexo
		scalar coef_sex_`year'_`q' = coef_cuantil_`year'_`q'[1, "female"]
		scalar se_sex_`year'_`q' = se_cuantil_`year'_`q'[1, "female"]
		scalar lb_sex_`year'_`q' = coef_sex_`year'_`q' - (-1.959983) * se_sex_`year'_`q'
		scalar ub_sex_`year'_`q' = coef_sex_`year'_`q' + (-1.959983) * se_sex_`year'_`q'
		}
}


*-------------------------------------------------
* Crear un dataset vacío para los coeficientes
clear
gen year = .
gen cuantil = .
gen coef_escolaridad = .
gen lb_escolaridad = .   // límite inferior para IC al 95%
gen ub_escolaridad = .   // límite superior para IC al 95%
gen coeficiente_sexo = . 
gen ci_sexo = .          // cota inferior para ic AL 95%
gen cs_sexo = .          // cota Superior para ic AL 95%


label variable coef_escolaridad "Beta Escolaridad"
label variable coeficiente_sexo "Beta Sexo"
label variable year "Año"
label variable cuantil "Cuantil"
label variable lb_escolaridad "Límite inferior CI escolaridad"
label variable ub_escolaridad "Límite superior CI escolaridad"
label variable ci_sexo "Límite inferior CI sexo"
label variable cs_sexo "Límite superior CI sexo"


foreach year in 2016 2022 {
    forvalues q = 1(1)99 {
		* Añadir una nueva observación
        set obs `=_N+1'
        
        * Definir los valores para la última observación
        replace year = `year' in L
        replace cuantil = `q' in L
        
        * Obtener los coeficientes y sus intervalos de confianza educación
        scalar coef_ed = coef_cuantil_`year'_`q'[1,1]
        scalar se_ed = se_cuantil_`year'_`q'[1,1]
        scalar lb_ed = coef_ed - (-1.959983) * sqrt(se_ed)
        scalar ub_ed = coef_ed + (-1.959983) * sqrt(se_ed)
        
        replace coef_escolaridad = coef_ed in L
        replace lb_escolaridad = lb_ed in L
        replace ub_escolaridad = ub_ed in L
		
		*Obtener los coeficientes y sus intervalos de confianza para sexo
        scalar coef_sex = coef_cuantil_`year'_`q'[1,"female"]
        scalar se_sex = se_cuantil_`year'_`q'[4,"female"]
        scalar lb_sex = coef_sex - 1.96 * sqrt(se_sex)
        scalar ub_sex = coef_sex + 1.96 * sqrt(se_sex)
        
        *replace coef_sexo = coef_sex in L
        replace coeficiente_sexo  = coef_sex in L
		replace ci_sexo = lb_sex in L
        replace cs_sexo = ub_sex in L
		}
}

*Agregar el OLS

* Extraer los coeficientes de educación para cada año
local ols_co_edu_2016 = b_ols_2016[1, "years_ed"]
local ols_co_edu_2022 = b_ols_2022[1, "years_ed"]
local ols_co_sex_2016 = b_ols_2016[1, "female"]
local ols_co_sex_2022 = b_ols_2022[1, "female"]


local ser_edu_2016_ols = se_ols_2016[1, "years_ed"]
local ser_edu_2022_ols = se_ols_2022[1, "years_ed"]
local ser_sex_2016_ols = se_ols_2016[4, "female"]
local ser_sex_2022_ols = se_ols_2022[4, "female"]


* Valor crítico para un intervalo de confianza del 95%
local t_critical = -1.959983

* Crear nuevas variables con los coeficientes de educación para cada año
gen ols_coe_edu_16 = .
replace ols_coe_edu_16 =  b_ols_2016[1, "years_ed"] if year == 2016

gen ols_coe_edu_22 = .
replace ols_coe_edu_22 = b_ols_2022[1, "years_ed"] if year == 2022

gen ols_coe_sex_16 = .
replace ols_coe_sex_16 = b_ols_2016[1, "female"] if year == 2016

gen ols_coe_sex_22 = .
replace ols_coe_sex_22 = b_ols_2022[1, "female"] if year == 2022

* Guardar la base
save "$datos/educa_sexo.dta", replace  

*generar los IC de Educación
gen ols_ci_edu_16 = .
gen ols_cs_edu_16 = .

matrix list b_ols_2016
matrix list se_ols_2016
replace ols_ci_edu_16 = 0.0965837 - 1.959983 *  sqrt(9.711e-07) // los valores los tuve que poner manual.
replace ols_cs_edu_16 = 0.0965837 + 1.959983 *  sqrt(9.711e-07)

gen lb_ed_ols_22 = .
gen ub_ed_ols_22 = .
matrix list b_ols_2022
matrix list se_ols_2022
replace lb_ed_ols_22 = 0.08225558 - 1.959983 * sqrt(6.930e-07)
replace ub_ed_ols_22 = 0.08225558 + 1.959983 * sqrt(6.930e-07)

* Generar los IC de sexo

gen lb_sex_ols_16 = .
gen ub_sex_ols_16 = .
matrix list b_ols_2016
matrix list se_ols_2016
replace lb_sex_ols_16 = -0.12342135 - 1.959983 * sqrt(0.00006194)
replace ub_sex_ols_16 = -0.12342135 + 1.959983 * sqrt(0.00006194)

gen lb_sex_ols_22 = .
gen ub_sex_ols_22 = .
matrix list b_ols_2022
matrix list se_ols_2022
replace lb_sex_ols_22 = -0.15562112 - 1.959983 * sqrt(0.00004184)
replace ub_sex_ols_22 = -0.15562112 + 1.959983 * sqrt(0.00004184)

label variable ols_coe_edu_16 "Beta educación ols 2016"
label variable ols_coe_edu_22 "Beta educación ols 2022"
label variable ols_coe_sex_16 "Beta sexo ols 2016"
label variable ols_coe_sex_22 "Beta sexo ols 2022"
label variable ols_ci_edu_16 "Límite inferior OLS Edu 2016"
label variable ols_cs_edu_16 "Límite superior OLS Edu 2016"
label variable lb_ed_ols_22 "Límite inferior OLS Edu 2022"
label variable ub_ed_ols_22 "Límite superior OLS Edu 2022"
label variable lb_sex_ols_16 "Límite inferior OLS sex 2016"
label variable ub_sex_ols_16 "Límite superior OLS sex 2016"
label variable lb_sex_ols_22 "Límite inferior OLS sex 2022"
label variable ub_sex_ols_22 "Límite superior OLS sex 2022"

* Guardar la base
save "$datos/educa_sexo.dta", replace  

*/

*----------------- Problema 3.6 ------------------------------------------------
******----------------------- Graficas------------------------------------------------

use "$datos/educa_sexo.dta", clear

* Salarios y educación: 2016
	   
twoway (scatter coef_escolaridad cuantil if year==2016, msymbol(sh) mlwidth(thin) msize(vsmall) mcolor(cranberry)) ///
	   (rarea ub_escolaridad lb_escolaridad cuantil if year==2016, color(red%7)) ///
	   (scatter ols_coe_edu_16 cuantil if year==2016, msymbol(Oh) mlwidth(thin) msize(tiny) mcolor(navy)) ///
	   (rarea ols_ci_edu_16 ols_cs_edu_16 cuantil if year==2016, color(blue%7)), ///
	   title("2016: Efecto de la educación sobre el salario por percentiles", size(medium)) /// 
	   subtitle("Estimadores de regresión cuantil (QR) vs MCO", size(small)) ///
	   ytitle("Valor del estimador", size(small)) ///
	   xtitle("Percentiles", size(small)) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   legend(order(1 "Regresión cuantil" 3 "MCO" 2 "IC QR 95%" 4 "IC MCO 95%") rows(1) position(6) size(small)) ///
	   caption(Fuente: Elaboración propia con datos de la ENIGH, size(*0.7)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white)
graph export "$graphs\QR_MCO_edu_16.png", replace


* Salarios y educación: 2022

twoway (scatter coef_escolaridad cuantil if year==2022, msymbol(sh) mlwidth(thin) msize(vsmall) mcolor(cranberry)) ///
	   (rarea ub_escolaridad lb_escolaridad cuantil if year==2022, color(red%7)) ///
	   (scatter ols_coe_edu_22 cuantil if year==2022, msymbol(Oh) mlwidth(thin) msize(tiny) mcolor(navy)) ///
	   (rarea lb_ed_ols_22 ub_ed_ols_22 cuantil if year==2022, color(blue%7)), ///
	   title("2022: Efecto de la educación sobre el salario por percentiles", size(medium)) /// 
	   subtitle("Estimadores de regresión cuantil (QR) vs MCO", size(small)) ///
	   ytitle("Valor del estimador", size(small)) ///
	   xtitle("Percentiles", size(small)) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   legend(order(1 "Regresión cuantil" 3 "MCO" 2 "IC QR 95%" 4 "IC MCO 95%") rows(1) position(6) size(small)) ///
	   caption(Fuente: Elaboración propia con datos de la ENIGH, size(*0.7)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white)
graph export "$graphs\QR_MCO_edu_22.png", replace


* Version con gráficos en mismo renglón
* 16
twoway (scatter coef_escolaridad cuantil if year==2016, msymbol(Sh) mlwidth(vthin) msize(tiny) mcolor(cranberry)) ///
	   (rarea ub_escolaridad lb_escolaridad cuantil if year==2016, color(red%7)) ///
	   (scatter ols_coe_edu_16 cuantil if year==2016, msymbol(Oh) mlwidth(vthin) msize(tiny) mcolor(navy)) ///
	   (rarea ols_ci_edu_16 ols_cs_edu_16 cuantil if year==2016, color(blue%7)), ///
	   title("2016", size(medium)) /// 
	   ytitle("Valor del estimador", size(small)) ///
	   xtitle("Percentiles", size(small)) ///
	   ylabel(0.07(.01).12, labsize(small)) ///	   
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   legend(order(1 "Regresión cuantil" 3 "MCO" 2 "IC QR 95%" 4 "IC MCO 95%") rows(1) position(6) size(small)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white) ///
	   nodraw
graph save "$graphs\plot1.jpg", replace
	   
* 22
twoway (scatter coef_escolaridad cuantil if year==2022, msymbol(Sh) mlwidth(vthin) msize(tiny) mcolor(cranberry)) ///
	   (rarea ub_escolaridad lb_escolaridad cuantil if year==2022, color(red%7)) ///
	   (scatter ols_coe_edu_22 cuantil if year==2022, msymbol(Oh) mlwidth(vthin) msize(tiny) mcolor(navy)) ///
	   (rarea lb_ed_ols_22 ub_ed_ols_22 cuantil if year==2022, color(blue%7)), ///
	   title("2022", size(medium)) /// 
	   ytitle("") ///
	   xtitle("Percentiles", size(small)) ///
	   ylabel(0.07(.01).12, nolab) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white) ///
	   nodraw
graph save "$graphs\plot2.jpg", replace

grc1leg "$graphs\plot1.jpg" "$graphs\plot2.jpg", ///
       col(2) ///
	   row(1) ///
	   iscale(0.8) ///
	   xcommon ycommon ///
	   title("Efecto de la educación sobre el salario por percentiles", size(medium)) ///
	   subtitle("Estimadores de regresión cuantil (QR) vs MCO", margin(b=3) size(small)) ///
	   imargin(vsmall) ///
	   legendfrom("$graphs\plot1.jpg") ///
	   caption("Elaboración propia con datos de la ENIGH.", ///
	   size(vsmall) span)
	   
graph display , ysize(45cm) xsize(80cm)
graph export "$graphs\QR_MCO_edu_16_y_22.jpg", replace

*
*
*
*
*
*
*
	   
* Salarios y sexo: 2016
	   
twoway (scatter coeficiente_sexo cuantil if year==2016, msymbol(sh) mlwidth(thin) msize(vsmall) mcolor(cranberry)) ///
	   (rarea cs_sexo ci_sexo cuantil if year==2016, color(red%7)) ///
	   (scatter ols_coe_sex_16 cuantil if year==2016, msymbol(Oh) mlwidth(thin) msize(tiny) mcolor(navy)) ///
	   (rarea lb_sex_ols_16 ub_sex_ols_16 cuantil if year==2016, color(blue%7)), ///
	   title("2016: Brecha de género en el salario por percentiles", size(medium)) /// 
	   subtitle("Estimadores de regresión cuantil (QR) vs MCO", size(small)) ///
	   ytitle("Valor del estimador", size(small)) ///
	   xtitle("Percentiles", size(small)) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   ylabel(-0.4(.05)-.05, labsize(small)) ///
	   legend(order(1 "Regresión cuantil" 3 "MCO" 2 "IC QR 95%" 4 "IC MCO 95%") rows(1) position(6) size(small)) ///
	   caption(Fuente: Elaboración propia con datos de la ENIGH, size(*0.7)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white)
graph export "$graphs\QR_MCO_sex_16.png", replace


* Salarios y sexo: 2022

twoway (scatter coeficiente_sexo cuantil if year==2022, msymbol(sh) mlwidth(thin) msize(vsmall) mcolor(cranberry)) ///
	   (rarea cs_sexo ci_sexo cuantil if year==2022, color(red%7)) ///
	   (scatter ols_coe_sex_22 cuantil if year==2022, msymbol(Oh) mlwidth(thin) msize(tiny) mcolor(navy)) ///
	   (rarea lb_sex_ols_22 ub_sex_ols_22 cuantil if year==2022, color(blue%7)), ///
	   title("2022: Brecha de género en el salario por percentiles", size(medium)) /// 
	   subtitle("Estimadores de regresión cuantil (QR) vs MCO", size(small)) ///
	   ytitle("Valor del estimador", size(small)) ///
	   xtitle("Percentiles", size(small)) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   ylabel(-0.5(.05)-.05, labsize(small)) ///
	   legend(order(1 "Regresión cuantil" 3 "MCO" 2 "IC QR 95%" 4 "IC MCO 95%") rows(1) position(6) size(small)) ///
	   caption(Fuente: Elaboración propia con datos de la ENIGH, size(*0.7)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white)
graph export "$graphs\QR_MCO_sex_22.png", replace


* Version con gráficos en mismo renglón
* 16
twoway (scatter coeficiente_sexo cuantil if year==2016, msymbol(Sh) mlwidth(vthin) msize(tiny) mcolor(cranberry)) ///
	   (rarea cs_sexo ci_sexo cuantil if year==2016, color(red%7)) ///
	   (scatter ols_coe_sex_16 cuantil if year==2016, msymbol(Oh) mlwidth(vthin) msize(tiny) mcolor(navy)) ///
	   (rarea lb_sex_ols_16 ub_sex_ols_16 cuantil if year==2016, color(blue%7)), ///
	   title("2016", size(medium)) /// 
	   ytitle("Valor del estimador", size(small)) ///
	   xtitle("Percentiles", size(small)) ///
	   ylabel(-0.5(.05)-.05, labsize(small)) ///	   
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   legend(order(1 "Regresión cuantil" 3 "MCO" 2 "IC QR 95%" 4 "IC MCO 95%") rows(1) position(6) size(small)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white) ///
	   nodraw
graph save "$graphs\plot1.jpg", replace
	   
* 22
twoway (scatter coeficiente_sexo cuantil if year==2022, msymbol(Sh) mlwidth(vthin) msize(tiny) mcolor(cranberry)) ///
	   (rarea cs_sexo ci_sexo cuantil if year==2022, color(red%7)) ///
	   (scatter ols_coe_sex_22 cuantil if year==2022, msymbol(Oh) mlwidth(vthin) msize(tiny) mcolor(navy)) ///
	   (rarea lb_sex_ols_22 ub_sex_ols_22 cuantil if year==2022, color(blue%7)), ///
	   title("2022", size(medium)) /// 
	   ytitle("") ///
	   xtitle("Percentiles", size(small)) ///
	   ylabel(-0.5(.05)-.05, nolab) ///	   
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white) ///
	   nodraw
graph save "$graphs\plot2.jpg", replace

grc1leg "$graphs\plot1.jpg" "$graphs\plot2.jpg", ///
       col(2) ///
	   row(1) ///
	   iscale(0.8) ///
	   xcommon ycommon ///
	   title("Brecha de género en el salario por percentiles", size(medium)) ///
	   subtitle("Estimadores de regresión cuantil (QR) vs MCO", margin(b=3) size(small)) ///
	   imargin(vsmall) ///
	   legendfrom("$graphs\plot1.jpg") ///
	   caption("Elaboración propia con datos de la ENIGH.", ///
	   size(vsmall) span)
	   
graph display , ysize(45cm) xsize(80cm)
graph export "$graphs\QR_MCO_sex_16_y_22.jpg", replace


******************************************************
******************************************************
******************************************************
******************************************************
******************************************************
******************************************************
******************************************************
******************************************************
******************************************************
***********************ENOE***************************
******************************************************
******************************************************
******************************************************
******************************************************
******************************************************
******************************************************
******************************************************
******************************************************
******************************************************

/*
use "$datos\ENOE_FINAL.dta", clear
destring year, replace
keep if inlist(year, 2005, 2010, 2018, 2024)
destring trim, replace
keep if inlist(trim, 1, 2)

keep if trabajador == 1 //deja solo registros con salario valido
summarize sal_hora
generate log_sal = log(sal_hora)  //crea variable log(salario hora)
summarize log_sal 
replace log_sal = 0 if log_sal <0 //convierte negativos a 1

*Genera dummy de mujer 
generate female =(sex ==2)

*Genera dummy de rural  
generate rural =(t_loc_tri ==4)

*deja variables de interes 
keep year log_sal anios_esc sex eda rural female rural fac_tri trim

*Renombra variables 
rename anios_esc esc
rename fac_tri factor

label variable log_sal "Log(Salario por hora)"
label variable female "Mujer"
label variable rural "Rural"


*Genera esdtadisticas basicas 
sum esc female log_sal female [fw = factor]
sum esc female log_sal female

destring year,replace 
save "$datos\base_pre.dta", replace // guarda base

*/

*****************************************

/*

use "$datos\base_pre.dta", clear // abre base

rename log_sal log_salario

keep if !missing(log_salario)
drop if log_salario == 0

keep log_salario female eda esc factor year trim sex
keep if inlist(year, 2005, 2010, 2018, 2022, 2024)
destring trim, replace
keep if inlist(trim, 1, 2)

**Cuantiles
foreach i of numlist 2005 2010 2018 2024{
pctile hom_`i'= log_salario if year == `i' & female==0 [fw = factor], n(100)
pctile muj_`i'= log_salario if year == `i' & female==1 [fw = factor], n(100)
}
*Luego, nos quedamos solamente con las observaciones con los percentiles asociados
keep hom* muj* 
keep in 1/99

*Añadimos la información de a qué percentil corresponden los generados antes
gen cuantil = _n

gen cambio_2024_2005_hombre = hom_2024-hom_2005
gen cambio_2024_2010_hombre = hom_2024-hom_2010
gen cambio_2024_2018_hombre = hom_2024-hom_2018
gen cambio_2024_2005_mujeres = muj_2024-muj_2005
gen cambio_2024_2010_mujeres = muj_2024-muj_2010
gen cambio_2024_2018_mujeres = muj_2024-muj_2018

* Guardar los datos
save "$datos/ENOE_FINAL_graficar.dta", replace 

*/

*** Gráficos

use "$datos/ENOE_FINAL_graficar.dta", clear	   

foreach var of varlist cambio_2024_2018_mujeres cambio_2024_2018_hombre cambio_2024_2010_mujeres cambio_2024_2010_hombre cambio_2024_2005_mujeres cambio_2024_2005_hombre {
    replace `var' = `var'*100
}

* 18-24
twoway (line cambio_2024_2018_hombre cuantil, lwidth(medthick) lpattern(shortdash) color(blue)) ///
	   (line cambio_2024_2018_mujeres cuantil, lwidth(medium) lpattern(solid) color(pink)) ///
	   (rarea cambio_2024_2018_hombre cambio_2024_2018_mujeres  cuantil, color(lavender%15)), ///
	   xtitle("Percentiles", size(small)) ///
	   ytitle("%" , size(small) orientation(horizontal)) ///
	   graphregion(fcolor(white)) ///
	   title("Variación porcentual en el salario por hora", size(medium)) ///
	   subtitle("2018 - 2024. Comparación entre géneros", size(small)) ///
	   legend(pos(6) r(1) size(small)) ///
	   note("Fuente: Elaboración propia con datos de la ENOE. Se considera el primer semestre de cada año.", size(small)) ///
	   legend(order(1 "Hombres" 2 "Mujeres" 3 "Brecha") size(small) pos(6) rows(1)) ///
	   ylabel(5(5)25, angle(0) labsize(small)) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white)
		   
graph export "$graphs\sal_ENOE_18_24.png", replace

* 10-24	
twoway (line cambio_2024_2010_hombre cuantil, lwidth(medthick) lpattern(shortdash) color(blue)) ///
	   (line cambio_2024_2010_mujeres cuantil, lwidth(medium) lpattern(solid) color(pink)) ///
	   (rarea cambio_2024_2010_hombre cambio_2024_2010_mujeres  cuantil, color(lavender%15)), ///
	   xtitle("Percentiles", size(small)) ///
	   ytitle("%" , size(small) orientation(horizontal)) ///
	   graphregion(fcolor(white)) ///
	   title("Variación porcentual en el salario por hora", size(medium)) ///
	   subtitle("2010 - 2024. Comparación entre géneros", size(small)) ///
	   legend(pos(6) r(1) size(small)) ///
	   note("Fuente: Elaboración propia con datos de la ENOE. Se considera el primer semestre de cada año.", size(small)) ///
	   legend(order(1 "Hombres" 2 "Mujeres" 3 "Brecha") size(small) pos(6) rows(1)) ///
	   ylabel(-10(5)40, angle(0) labsize(small)) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white)
		   
graph export "$graphs\sal_ENOE_10_24.png", replace

* 05-24	
twoway (line cambio_2024_2005_hombre cuantil, lwidth(medthick) lpattern(shortdash) color(blue)) ///
	   (line cambio_2024_2005_mujeres cuantil, lwidth(medium) lpattern(solid) color(pink)) ///
	   (rarea cambio_2024_2005_hombre cambio_2024_2005_mujeres  cuantil, color(lavender%15)), ///
	   xtitle("Percentiles", size(small)) ///
	   ytitle("%" , size(small) orientation(horizontal)) ///
	   graphregion(fcolor(white)) ///
	   title("Variación porcentual en el salario por hora", size(medium)) ///
	   subtitle("2005 - 2024. Comparación entre géneros", size(small)) ///
	   legend(pos(6) r(1) size(small)) ///
	   note("Fuente: Elaboración propia con datos de la ENOE. Se considera el primer semestre de cada año.", size(small)) ///
	   legend(order(1 "Hombres" 2 "Mujeres" 3 "Brecha") size(small) pos(6) rows(1)) ///
	   ylabel(-15(5)50, angle(0) labsize(small)) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white)
		   
graph export "$graphs\sal_ENOE_05_24.png", replace


* Version con gráficos en mismo renglón
* 05-24
twoway (line cambio_2024_2005_hombre cuantil, lwidth(medthick) lpattern(shortdash) color(blue)) ///
	   (line cambio_2024_2005_mujeres cuantil, lwidth(medium) lpattern(solid) color(pink)) ///
	   (rarea cambio_2024_2005_hombre cambio_2024_2005_mujeres  cuantil, color(lavender%15)), ///
	   xtitle("Percentiles", size(small)) ///
	   yline(0, lcolor(black) lpattern(longdash)) ///
	   ytitle("%" , size(small) orientation(horizontal)) ///
	   graphregion(fcolor(white)) ///
	   title("2005 - 2024", size(medium)) ///
	   legend(order(1 "Hombres" 2 "Mujeres" 3 "Brecha") size(small) pos(6) rows(1)) ///
	   ylabel(-15(5)50, angle(0) labsize(small)) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   scheme(stsj) ///
	   bgcolor(white) ///
	   nodraw
graph save "$graphs\plot1.jpg", replace

* 10-24	
twoway (line cambio_2024_2010_hombre cuantil, lwidth(medthick) lpattern(shortdash) color(blue)) ///
	   (line cambio_2024_2010_mujeres cuantil, lwidth(medium) lpattern(solid) color(pink)) ///
	   (rarea cambio_2024_2010_hombre cambio_2024_2010_mujeres  cuantil, color(lavender%15)), ///
	   xtitle("Percentiles", size(small)) ///
	   yline(0, lcolor(black) lpattern(longdash)) ///
	   ytitle("") ///
	   graphregion(fcolor(white)) ///
	   title("2010 - 2024", size(medium)) ///
	   legend(order(1 "Hombres" 2 "Mujeres" 3 "Brecha") size(small) pos(6) rows(1)) ///
	   ylabel(-15(5)50, angle(0) labsize(small) nolab) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   scheme(stsj) ///
	   bgcolor(white) ///
	   nodraw
graph save "$graphs\plot2.jpg", replace

* 18-24	
twoway (line cambio_2024_2018_hombre cuantil, lwidth(medthick) lpattern(shortdash) color(blue)) ///
	   (line cambio_2024_2018_mujeres cuantil, lwidth(medium) lpattern(solid) color(pink)) ///
	   (rarea cambio_2024_2018_hombre cambio_2024_2018_mujeres  cuantil, color(lavender%15)), ///
	   xtitle("Percentiles", size(small)) ///
	   yline(0, lcolor(black) lpattern(longdash)) ///
	   ytitle("") ///
	   graphregion(fcolor(white)) ///
	   title("2018 - 2024", size(medium)) ///
	   legend(order(1 "Hombres" 2 "Mujeres" 3 "Brecha") size(small) pos(6) rows(1)) ///
	   ylabel(-15(5)50, angle(0) labsize(small) nolab) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   scheme(stsj) ///
	   bgcolor(white) ///
	   nodraw
graph save "$graphs\plot3.jpg", replace

grc1leg "$graphs\plot1.jpg" "$graphs\plot2.jpg", ///
       col(2) ///
	   row(1) ///
	   iscale(0.8) ///
	   xcommon ycommon ///
	   title("Variación porcentual en el salario por hora", size(small)) ///
	   subtitle("Comparación entre sexos", margin(b=3) size(small)) ///
	   imargin(vsmall) ///
	   legendfrom("$graphs\plot1.jpg") ///
	   caption("Fuente: Elaboración propia con datos de la ENOE. Se considera el primer semestre de cada año.", ///
	   size(vsmall) span)
	   
graph display , ysize(45cm) xsize(80cm)
graph export "$graphs\Sal_05 y 10 vs 24.jpg", replace

grc1leg "$graphs\plot1.jpg" "$graphs\plot3.jpg", ///
       col(2) ///
	   row(1) ///
	   iscale(0.8) ///
	   xcommon ycommon ///
	   title("Variación porcentual en el salario por hora", size(small)) ///
	   subtitle("Comparación entre sexos", margin(b=3) size(small)) ///
	   imargin(vsmall) ///
	   legendfrom("$graphs\plot1.jpg") ///
	   caption("Fuente: Elaboración propia con datos de la ENOE. Se considera el primer semestre de cada año.", ///
	   size(vsmall) span)
	   
graph display , ysize(45cm) xsize(80cm)
graph export "$graphs\Sal_05 y 18 vs 24.jpg", replace


*****************************************************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************


*----------------- Problema 3.4 ------------------------------------------------

/*
* Cargar el archivo de datos
use "$datos/base_pre.dta", clear // abre base

* Verificar que el archivo se haya cargado correctamente
describe

*Generamos la varaibel años al cuadrado
gen edad2 = eda^2

* Corremos las regresiones cuantiles
* Ponemos un valor de tolerancia de 0.0001 para las iteraciones en caso de no
* converger a cero.
foreach year in 2018 2024 {
forvalues q = 1(1)99 {
    local quant = `q' / 100
    qreg log_sal esc eda edad2 female rural [pweight = factor] if year == `year', quantile(`quant') iterate(1000) vce(robust)  
    matrix b_cuantil_`year'_`q' = e(b)
	matrix se_cuantil_`year'_`q' = e(V)
   }
}
	
* Estimar OLS para 2018, y 2024
foreach year in 2018 2024 {
    regress log_sal esc edad edad2 female rural [pweight = factor] if year == `year'
    matrix b_ols_`year' = e(b)
	matrix se_ols_`year' = e(V)
}

* Para graficar los resultados
* Crear un dataset vacío para guardar los coeficientes


* Llenar el dataset con los coeficientes cuantil 
foreach year in 2018 2024 {
	forvalues q = 1(1)99 {
			* Extraer coeficientes e IC para escolaridad y género
			matrix coef_cuantil_`year'_`q' = b_cuantil_`year'_`q'
			matrix se_cuantil_`year'_`q' = se_cuantil_`year'_`q'
	}
}
		
foreach year in 2018 2024 {
	forvalues q = 1(1)99 {
			* Escolaridad
			scalar coef_ed_`year'_`q' = coef_cuantil_`year'_`q'[1, "esc"]
			scalar se_ed_`year'_`q' = se_cuantil_`year'_`q'[1, "esc"]
			scalar lb_ed_`year'_`q' = coef_ed_`year'_`q' - (1.959983) * se_ed_`year'_`q'
			scalar ub_ed_`year'_`q' = coef_ed_`year'_`q' + (1.959983) * se_ed_`year'_`q'
			
	}
}	
			
foreach year in 2018 2024 {
	forvalues q = 1(1)99 {	
			* Sexo
			scalar coef_sex_`year'_`q' = coef_cuantil_`year'_`q'[1, "female"]
			scalar se_sex_`year'_`q' = se_cuantil_`year'_`q'[1, "female"]
			scalar lb_sex_`year'_`q' = coef_sex_`year'_`q' - (1.959983) * se_sex_`year'_`q'
			scalar ub_sex_`year'_`q' = coef_sex_`year'_`q' + (1.959983) * se_sex_`year'_`q'
			
	}
}

*-------------------------------------------------
* Crear un dataset vacío para los coeficientes
clear
gen year = .
gen cuantil = .
gen coef_escolaridad = .
gen lb_escolaridad = .   // límite inferior para IC al 95%
gen ub_escolaridad = .   // límite superior para IC al 95%
gen coeficiente_sexo = . 
gen ci_sexo = .
gen cs_sexo = .


label variable coef_escolaridad "Beta Escolaridad"
label variable coeficiente_sexo "Beta Sexo"
label variable year "Año"
label variable cuantil "Cuantil"
label variable lb_escolaridad "Límite inferior CI escolaridad"
label variable ub_escolaridad "Límite superior CI escolaridad"
label variable ci_sexo "Límite inferior CI sexo"
label variable cs_sexo "Límite superior CI sexo"


foreach year in 2018 2024 {
    forvalues q = 1(1)99 {
        * Añadir una nueva observación
        set obs `=_N+1'
        
        * Definir los valores para la última observación
        replace year = `year' in L
        replace cuantil = `q' in L
        
        * Obtener los coeficientes y sus intervalos de confianza educación
        scalar coef_ed = coef_cuantil_`year'_`q'[1,1]
        scalar se_ed = se_cuantil_`year'_`q'[1,1]
        scalar lb_ed = coef_ed - (1.959983) * sqrt(se_ed)
        scalar ub_ed = coef_ed + (1.959983) * sqrt(se_ed)
        
        replace coef_escolaridad = coef_ed in L
        replace lb_escolaridad = lb_ed in L
        replace ub_escolaridad = ub_ed in L
		
		*Obtener los coeficientes y sus intervalos de confianza para sexo
        scalar coef_sex = coef_cuantil_`year'_`q'[1,"female"]
        scalar se_sex = se_cuantil_`year'_`q'[4,"female"]
        scalar lb_sex = coef_sex - (1.959983) * sqrt(se_sex)
        scalar ub_sex = coef_sex + (1.959983) * sqrt(se_sex)
        
        *replace coef_sexo = coef_sex in L
        replace coeficiente_sexo  = coef_sex in L
		replace ci_sexo = lb_sex in L
        replace cs_sexo = ub_sex in L
		
		
    }
}
*-------------------------------------------------


*Agregar el OLS

* Extraer los coeficientes de educación para cada año
local ols_co_edu_2018 = b_ols_2018[1, "esc"]
local ols_co_edu_2024 = b_ols_2024[1, "esc"]
local ols_co_sex_2018 = b_ols_2018[1, "female"]
local ols_co_sex_2024 = b_ols_2024[1, "female"]


local ser_edu_2018_ols = se_ols_2018[1, "esc"]
local ser_edu_2024_ols = se_ols_2024[1, "esc"]
local ser_sex_2018_ols = se_ols_2018[4, "female"]
local ser_sex_2024_ols = se_ols_2024[4, "female"]


* Valor crítico para un intervalo de confianza del 95%
local t_critical = 1.959983

* Crear nuevas variables con los coeficientes de educación para cada año
gen ols_coe_edu_18 = .
replace ols_coe_edu_18 =  b_ols_2018[1, "esc"] if year == 2018

gen ols_coe_edu_24 = .
replace ols_coe_edu_24 = b_ols_2024[1, "esc"] if year == 2024

gen ols_coe_sex_18 = .
replace ols_coe_sex_18 = b_ols_2018[1, "female"] if year == 2018

gen ols_coe_sex_24 = .
replace ols_coe_sex_24 = b_ols_2024[1, "female"] if year == 2024

* Guardar la base
save "$datos/educa_sexo_ENOE.dta", replace  

*generar los IC de Educación
gen ols_ci_edu_18 = .
gen ols_cs_edu_18 = .

*************************--------------------------------------------------- CAMBIAR COEFICIENTES Y ERRORES ESTANDAR A MANO
* Escolaridad
matrix list b_ols_2018
matrix list se_ols_2018
replace ols_ci_edu_18 = 0.03930365 - 1.959983 *  sqrt(4.918e-06)
replace ols_cs_edu_18 = 0.03930365 + 1.959983 *  sqrt(4.918e-06)

gen lb_ed_ols_24 = .
gen ub_ed_ols_24 = .
matrix list b_ols_2024
matrix list se_ols_2024
replace lb_ed_ols_24 = 0.04006574 - 1.959983 * sqrt(2.546e-06)
replace ub_ed_ols_24 = 0.04006574 + 1.959983 * sqrt(2.546e-06)

* Generar los IC de sexo

gen lb_sex_ols_18 = .
gen ub_sex_ols_18 = .
matrix list b_ols_2018
matrix list se_ols_2018
replace lb_sex_ols_18 = -0.08533134 - 1.959983 * sqrt(0.00002756)
replace ub_sex_ols_18 = -0.08533134 + 1.959983 * sqrt(0.00002756)

gen lb_sex_ols_24 = .
gen ub_sex_ols_24 = .
matrix list b_ols_2024
matrix list se_ols_2024
replace lb_sex_ols_24 = -0.10549595 - 1.959983 * sqrt(0.00002621)
replace ub_sex_ols_24 = -0.10549595 + 1.959983 * sqrt(0.00002621)

label variable ols_coe_edu_18 "Beta educación ols 2018"
label variable ols_coe_edu_24 "Beta educación ols 2022"
label variable ols_coe_sex_18 "Beta sexo ols 2018"
label variable ols_coe_sex_24 "Beta sexo ols 2022"
label variable ols_ci_edu_18 "Límite inferior OLS Edu 2018"
label variable ols_cs_edu_18 "Límite superior OLS Edu 2018"
label variable lb_ed_ols_24 "Límite inferior OLS Edu 2022"
label variable ub_ed_ols_24 "Límite superior OLS Edu 2022"
label variable lb_sex_ols_18 "Límite inferior OLS sex 2018"
label variable ub_sex_ols_18 "Límite superior OLS sex 2018"
label variable lb_sex_ols_24 "Límite inferior OLS sex 2022"
label variable ub_sex_ols_24 "Límite superior OLS sex 2022"

* Guardar la base
save "$datos/educa_sexo_ENOE.dta", replace 
*/

*----------------- Problema 3.6 ------------------------------------------------
******----------------------- Graficas------------------------------------------------

use "$datos/educa_sexo_ENOE.dta", clear

* Salarios y educación: 2018
	   
twoway (scatter coef_escolaridad cuantil if year==2018, msymbol(sh) mlwidth(thin) msize(vsmall) mcolor(cranberry)) ///
	   (rarea ub_escolaridad lb_escolaridad cuantil if year==2018, color(red%7)) ///
	   (scatter ols_coe_edu_18 cuantil if year==2018, msymbol(Oh) mlwidth(thin) msize(tiny) mcolor(navy)) ///
	   (rarea ols_ci_edu_18 ols_cs_edu_18 cuantil if year==2018, color(blue%7)), ///
	   title("2018: Efecto de la educación sobre el salario por percentiles", size(medium)) /// 
	   subtitle("Estimadores de regresión cuantil (QR) vs MCO", size(small)) ///
	   ytitle("Valor del estimador", size(small)) ///
	   xtitle("Percentiles", size(small)) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   legend(order(1 "Regresión cuantil" 3 "MCO" 2 "IC QR 95%" 4 "IC MCO 95%") rows(1) position(6) size(small)) ///
	   caption(Fuente: Elaboración propia con datos de la ENOE, size(*0.7)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white)
graph export "$graphs\QR_MCO_edu_18_ENOE.png", replace


* Salarios y educación: 2024

twoway (scatter coef_escolaridad cuantil if year==2024, msymbol(sh) mlwidth(thin) msize(vsmall) mcolor(cranberry)) ///
	   (rarea ub_escolaridad lb_escolaridad cuantil if year==2024, color(red%7)) ///
	   (scatter ols_coe_edu_24 cuantil if year==2024, msymbol(Oh) mlwidth(thin) msize(tiny) mcolor(navy)) ///
	   (rarea lb_ed_ols_24 ub_ed_ols_24 cuantil if year==2024, color(blue%7)), ///
	   title("2024: Efecto de la educación sobre el salario por percentiles", size(medium)) /// 
	   subtitle("Estimadores de regresión cuantil (QR) vs MCO", size(small)) ///
	   ytitle("Valor del estimador", size(small)) ///
	   xtitle("Percentiles", size(small)) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   legend(order(1 "Regresión cuantil" 3 "MCO" 2 "IC QR 95%" 4 "IC MCO 95%") rows(1) position(6) size(small)) ///
	   caption(Fuente: Elaboración propia con datos de la ENOE, size(*0.7)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white)
graph export "$graphs\QR_MCO_edu_24_ENOE.png", replace


* Version con gráficos en mismo renglón
* 18
twoway (scatter coef_escolaridad cuantil if year==2018, msymbol(Sh) mlwidth(vthin) msize(tiny) mcolor(cranberry)) ///
	   (rarea ub_escolaridad lb_escolaridad cuantil if year==2018, color(red%7)) ///
	   (scatter ols_coe_edu_18 cuantil if year==2018, msymbol(Oh) mlwidth(vthin) msize(tiny) mcolor(navy)) ///
	   (rarea ols_ci_edu_18 ols_cs_edu_18 cuantil if year==2018, color(blue%7)), ///
	   title("2018", size(medium)) /// 
	   ytitle("Valor del estimador", size(small)) ///
	   xtitle("Percentiles", size(small)) ///
	   ylabel(0(.01).08, labsize(small)) ///	   
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   legend(order(1 "Regresión cuantil" 3 "MCO" 2 "IC QR 95%" 4 "IC MCO 95%") rows(1) position(6) size(small)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white) ///
	   nodraw
graph save "$graphs\plot1.jpg", replace
	   
* 24
twoway (scatter coef_escolaridad cuantil if year==2024, msymbol(Sh) mlwidth(vthin) msize(tiny) mcolor(cranberry)) ///
	   (rarea ub_escolaridad lb_escolaridad cuantil if year==2024, color(red%7)) ///
	   (scatter ols_coe_edu_24 cuantil if year==2024, msymbol(Oh) mlwidth(vthin) msize(tiny) mcolor(navy)) ///
	   (rarea lb_ed_ols_24 ub_ed_ols_24 cuantil if year==2024, color(blue%7)), ///
	   title("2024", size(medium)) /// 
	   ytitle("") ///
	   xtitle("Percentiles", size(small)) ///
	   ylabel(0(.01).08, nolab) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white) ///
	   nodraw
graph save "$graphs\plot2.jpg", replace

grc1leg "$graphs\plot1.jpg" "$graphs\plot2.jpg", ///
       col(2) ///
	   row(1) ///
	   iscale(0.8) ///
	   xcommon ycommon ///
	   title("Efecto de la educación sobre el salario por percentiles", size(medium)) ///
	   subtitle("Estimadores de regresión cuantil (QR) vs MCO", margin(b=3) size(small)) ///
	   imargin(vsmall) ///
	   legendfrom("$graphs\plot1.jpg") ///
	   caption("Elaboración propia con datos de la ENOE. Primer semestre de cada año.", ///
	   size(vsmall) span)
	   
graph display , ysize(45cm) xsize(80cm)
graph export "$graphs\QR_MCO_edu_18_y_24_ENOE.jpg", replace

*
*
*
*
*
*
*
	   
* Salarios y sexo: 2018
	   
twoway (scatter coeficiente_sexo cuantil if year==2018, msymbol(sh) mlwidth(thin) msize(vsmall) mcolor(cranberry)) ///
	   (rarea cs_sexo ci_sexo cuantil if year==2018, color(red%7)) ///
	   (scatter ols_coe_sex_18 cuantil if year==2018, msymbol(Oh) mlwidth(thin) msize(tiny) mcolor(navy)) ///
	   (rarea lb_sex_ols_18 ub_sex_ols_18 cuantil if year==2018, color(blue%7)), ///
	   title("2018: Brecha de género en el salario por percentiles", size(medium)) /// 
	   subtitle("Estimadores de regresión cuantil (QR) vs MCO", size(small)) ///
	   ytitle("Valor del estimador", size(small)) ///
	   xtitle("Percentiles", size(small)) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   ylabel(-0.3(.05).05, labsize(small)) ///
	   legend(order(1 "Regresión cuantil" 3 "MCO" 2 "IC QR 95%" 4 "IC MCO 95%") rows(1) position(6) size(small)) ///
	   caption(Fuente: Elaboración propia con datos de la ENOE, size(*0.7)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white)
graph export "$graphs\QR_MCO_sex_18_ENOE.png", replace


* Salarios y sexo: 2024

twoway (scatter coeficiente_sexo cuantil if year==2024, msymbol(sh) mlwidth(thin) msize(vsmall) mcolor(cranberry)) ///
	   (rarea cs_sexo ci_sexo cuantil if year==2024, color(red%7)) ///
	   (scatter ols_coe_sex_24 cuantil if year==2024, msymbol(Oh) mlwidth(thin) msize(tiny) mcolor(navy)) ///
	   (rarea lb_sex_ols_24 ub_sex_ols_24 cuantil if year==2024, color(blue%7)), ///
	   title("2024: Brecha de género en el salario por percentiles", size(medium)) /// 
	   subtitle("Estimadores de regresión cuantil (QR) vs MCO", size(small)) ///
	   ytitle("Valor del estimador", size(small)) ///
	   xtitle("Percentiles", size(small)) ///
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   ylabel(-0.3(.05).01, labsize(small)) ///
	   legend(order(1 "Regresión cuantil" 3 "MCO" 2 "IC QR 95%" 4 "IC MCO 95%") rows(1) position(6) size(small)) ///
	   caption(Fuente: Elaboración propia con datos de la ENOE, size(*0.7)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white)
graph export "$graphs\QR_MCO_sex_24_ENOE.png", replace


* Version con gráficos en mismo renglón
* 18
twoway (scatter coeficiente_sexo cuantil if year==2018, msymbol(Sh) mlwidth(vthin) msize(tiny) mcolor(cranberry)) ///
	   (rarea cs_sexo ci_sexo cuantil if year==2018, color(red%7)) ///
	   (scatter ols_coe_sex_18 cuantil if year==2018, msymbol(Oh) mlwidth(vthin) msize(tiny) mcolor(navy)) ///
	   (rarea lb_sex_ols_18 ub_sex_ols_18 cuantil if year==2018, color(blue%7)), ///
	   title("2018", size(medium)) /// 
	   ytitle("Valor del estimador", size(small)) ///
	   xtitle("Percentiles", size(small)) ///
	   ylabel(-0.3(.05).05, labsize(small)) ///	   
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   legend(order(1 "Regresión cuantil" 3 "MCO" 2 "IC QR 95%" 4 "IC MCO 95%") rows(1) position(6) size(small)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white) ///
	   nodraw
graph save "$graphs\plot1.jpg", replace
	   
* 24
twoway (scatter coeficiente_sexo cuantil if year==2024, msymbol(Sh) mlwidth(vthin) msize(tiny) mcolor(cranberry)) ///
	   (rarea cs_sexo ci_sexo cuantil if year==2024, color(red%7)) ///
	   (scatter ols_coe_sex_24 cuantil if year==2024, msymbol(Oh) mlwidth(vthin) msize(tiny) mcolor(navy)) ///
	   (rarea lb_sex_ols_24 ub_sex_ols_24 cuantil if year==2024, color(blue%7)), ///
	   title("2024", size(medium)) /// 
	   ytitle("") ///
	   xtitle("Percentiles", size(small)) ///
	   ylabel(-0.3(.05).05, nolab) ///	   
	   xlabel(1 10 20 30 40 50 60 70 80 90 99, labsize(small)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white) ///
	   nodraw
graph save "$graphs\plot2.jpg", replace

grc1leg "$graphs\plot1.jpg" "$graphs\plot2.jpg", ///
       col(2) ///
	   row(1) ///
	   iscale(0.8) ///
	   xcommon ycommon ///
	   title("Brecha de género en el salario por percentiles", size(medium)) ///
	   subtitle("Estimadores de regresión cuantil (QR) vs MCO", margin(b=3) size(small)) ///
	   imargin(vsmall) ///
	   legendfrom("$graphs\plot1.jpg") ///
	   caption("Elaboración propia con datos de la ENOE. Primer semestre de cada año.", ///
	   size(vsmall) span)
	   
graph display , ysize(45cm) xsize(80cm)
graph export "$graphs\QR_MCO_sex_18_y_24_ENOE.jpg", replace