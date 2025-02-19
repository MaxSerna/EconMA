/*
Econometría Aplicada
Problem Set 2
Ejercicio 4
Max Brando Serna Leyva
2023-2025
*/

***********************
* PROBLEMA 4 - Bootstrap : ENOE *
***********************

global general "D:\Eco aplicada\Tarea 2\4"
global datos "$general\Datos"
global Resultados "$general\Resultados\ENOE"

use "$datos\ENOE_FINAL.dta", clear

*ssc install outreg2,replace

*Filtramos los datos para el año 2024
*las variables venian en formato string, las hacemos numericas
destring year, replace
destring trim, replace
keep if year == 2024 & trim == 2

gen edad2 = eda^2
gen log_salarioxhr = log(sal_hora)
gen female = sex - 1
label variable female "Mujer"
label define female 0 "Hombre" 1 "Mujer"
label values female female
gen rural = 0
replace rural = 1 if t_loc_tri == 4 // para generar dummy solamente si es rural t_loc_tri == 4
tab rural t_loc_tri // para verificar que se hayan copiado bien
/* 
 tab rural t_loc_tri

           |           Tamaño de la localidad
     rural | Localidad  Localidad  Localidad  Localidad |     Total
-----------+--------------------------------------------+----------
         0 |   130,847     28,201     27,191          0 |   186,239 
         1 |         0          0          0     32,623 |    32,623 
-----------+--------------------------------------------+----------
     Total |   130,847     28,201     27,191     32,623 |   218,862 

*/ 
label variable rural "Rural" // etiquetar variable
label define rural 1 "Rural" 0 "Urbano" // etiquetar valores
label values rural rural // comando de hacer valores en etiqueta en la base

save "$Resultados/ENOEproblema4tarea2.dta", replace

* Estima la regresión OLS con errores estándar robustos para el segundo trimestre 2023	

use "$Resultados/ENOEproblema4tarea2.dta", clear

reg log_salarioxhr anios_esc eda edad2 rural female [aw=fac], vce(robust)

estimates store reg_ols_enoe

// OLS en tabla
outreg2 [reg_ols_enoe] using "$Resultados/coefbt_100_enoe.tex", ///
ctitle(OLS) ///
drop(log_salarioxhr*) stats(coef se ci tstat) label replace

// Bootstrap

bootstrap _b _se, saving("$Resultados/bootstrap_100_enoe", replace) reps(100): reg log_salarioxhr anios_esc eda edad2 rural female 

estimates store bootstrap_100_enoe

* Guardamos los resultados en una tabla
outreg2 [bootstrap_100_enoe] using "$Resultados/coefbt_100_enoe.tex", ///
append ctitle(Bootstrap 100) label  ///
drop(log_salarioxhr*) stats(coef se ci tstat)

* Hacemos manipulación de datos bootstrap
preserve
use "$Resultados/bootstrap_100_enoe.dta", clear
gen hip = 0 // Hipótesis Nula=H0

foreach var in anios_esc eda edad2 rural female {
	rename _b_`var' b`var'
	rename _se_`var' se_`var'
	gen t_`var'=(b`var'-hip)/se_`var'
	
	sort b`var'
	gen icl_`var'_bt=0.5*b`var'[2]+0.5*b`var'[3]
	gen icu_`var'_bt=0.5*b`var'[97]+0.5*b`var'[98]
	sort t_`var'
	gen ictl_`var'_bt=0.5*t_`var'[2]+0.5*t_`var'[3]
	gen ictu_`var'_bt=0.5*t_`var'[97]+0.5*t_`var'[98]
}

estpost summarize

esttab, cells(mean) obslast, using "$Resultados/boot_ic_100_enoe.tex", replace ///
sfmt(fmt(%9.0g)) ///
label mtitles ("Bootstrap 100 ENOE") ///
title("Summarize Bootstrap 100 ENOE") ///
addnote("Author's own construction with ENOE dataset")

restore


* (b) Bootstrap no parametrico con 1000 repeticiones. Organiza en una tabla tus resultados: error estandar robusto de OLS, error estandar del bootstrap, el intervalo de confianza del estimador de bootstrap con el metodo del percentil, el metodo percentil-t al 95% de confianza y comparalo con la t de OLS para rechazar o no la hipotesis nula de un efecto cero.

reg log_salarioxhr anios_esc eda edad2 rural female  [aw=fac], robust

estimates store reg_ols_enoe

// OLS en tabla
outreg2 [reg_ols_enoe] using "$Resultados/coefbt_1000_enoe.tex", ///
ctitle(OLS) ///
drop(log_salarioxhr*) stats(coef se ci tstat) label replace

// Bootstrap

bootstrap _b _se, saving("$Resultados/bootstrap_1000_enoe", replace) reps(1000): reg log_salarioxhr anios_esc eda edad2 rural female, robust

estimates store bootstrap_1000_enoe


* Guardamos los resultados en una tabla
outreg2 [bootstrap_1000_enoe] using "$Resultados/coefbt_1000_enoe.tex", ///
append ctitle(Bootstrap 1000) label  ///
drop(log_salarioxhr*) stats(coef se ci tstat)

* Hacemos manipulación de datos bootstrap
*En caso de error, declaramos los macros nuevamente
preserve
use "$Resultados/bootstrap_1000_enoe.dta", clear
gen hip = 0 // Hipótesis Nula=H0

foreach var in anios_esc eda edad2 rural female {
	rename _b_`var' b`var'
	rename _se_`var' se_`var'
	gen t_`var'=(b`var'-hip)/se_`var'
	
	sort b`var'
	gen icl_`var'_bt=0.5*b`var'[2]+0.5*b`var'[3]
	gen icu_`var'_bt=0.5*b`var'[97]+0.5*b`var'[98]
	sort t_`var'
	gen ictl_`var'_bt=0.5*t_`var'[2]+0.5*t_`var'[3]
	gen ictu_`var'_bt=0.5*t_`var'[97]+0.5*t_`var'[98]
	
}

estpost summarize

esttab, cells(mean) obslast, using "$Resultados/boot_ic_1000_enoe.tex", replace ///
sfmt(fmt(%9.0g)) ///
label mtitles ("Bootstrap 1000 ENOE") ///
title("Summarize Bootstrap 1000 ENOE") ///
addnote("Author's own construction with ENOE dataset")

restore

*(d) Realiza nuevamente (a) pero en lugar de tomar un bootstrap de toda la muestra N, realiza un bootstrap con 0.25*N. Es decir, el tama˜no de muestra es menor en cada bootstrap.

set seed 1
gen unif=runiform()
keep if unif<0.25 // Random sample 25%

* Reg. OLS
reg log_salarioxhr anios_esc eda edad2 rural female [aw=fac], robust

estimates store reg_ols_enoe_4

// OLS en tabla
outreg2 [reg_ols_enoe_4] using "$Resultados/coefbt_100_enoe_incisod.tex", ///
ctitle(OLS) ///
drop(log_salarioxhr*) stats(coef se ci tstat) label replace

// Bootstrap

bootstrap _b _se, saving("$Resultados/bootstrap_100_enoe_incisod", replace) reps(100) seed(1): reg log_salarioxhr anios_esc eda edad2 rural female, robust

estimates store bootstrap_100_enoe_4

* Guardamos los resultados en una tabla
outreg2 [bootstrap_100_enoe_4] using "$Resultados/coefbt_100_enoe_incisod.tex", ///
append ctitle(Bootstrap 100 con 25%) label  ///
drop(log_salarioxhr*) stats(coef se ci tstat)

* Hacemos manipulación de datos bootstrap
preserve
use "$Resultados/bootstrap_100_enoe_incisod.dta", clear
gen hip = 0 // Hipótesis Nula=H0

foreach var in anios_esc eda edad2 rural female {
	rename _b_`var' b`var'
	rename _se_`var' se_`var'
	gen t_`var'=(b`var'-hip)/se_`var'
	
	sort b`var'
	gen icl_`var'_bt=0.5*b`var'[2]+0.5*b`var'[3]
	gen icu_`var'_bt=0.5*b`var'[97]+0.5*b`var'[98]
	sort t_`var'
	gen ictl_`var'_bt=0.5*t_`var'[2]+0.5*t_`var'[3]
	gen ictu_`var'_bt=0.5*t_`var'[97]+0.5*t_`var'[98]
}

estpost summarize

esttab, cells(mean) obslast, using "$Resultados/boot_ic_100_enoe_incisod.tex", replace ///
sfmt(fmt(%9.0g)) ///
label mtitles ("Bootstrap 100 ENOE 25% de muestra") ///
title("Resumen Bootstrap 100 ENOE 25% de muestra") ///
addnote("Elaboración propia con datos de la ENOE")

restore

*(e) Realiza nuevamente (b) pero en lugar de tomar un bootstrap de toda la muestra N, realiza un bootstrap con 0.25*N. Es decir, el tama˜no de muestra es menor en cada bootstrap.

* Reg. OLS
reg log_salarioxhr anios_esc eda edad2 rural female [aw=fac], robust

estimates store reg_ols_enoe_4

// OLS en tabla
outreg2 [reg_ols_enoe_4] using "$Resultados/coefbt_1000_enoe_incisod.tex", ///
ctitle(OLS) ///
drop(log_salarioxhr*) stats(coef se ci tstat) label replace

// Bootstrap

bootstrap _b _se, saving("$Resultados/bootstrap_1000_enoe_incisod", replace) reps(1000) seed(1): reg log_salarioxhr anios_esc eda edad2 rural female, robust

estimates store bootstrap_1000_enoe_4

* Guardamos los resultados en una tabla
outreg2 [bootstrap_1000_enoe_4] using "$Resultados/coefbt_1000_enoe_incisod.tex", ///
append ctitle(Bootstrap 1000 con 25%) label  ///
drop(log_salarioxhr*) stats(coef se ci tstat)

* Hacemos manipulación de datos bootstrap
preserve
use "$Resultados/bootstrap_1000_enoe_incisod.dta", clear
gen hip = 0 // Hipótesis Nula=H0

foreach var in anios_esc eda edad2 rural female {
	rename _b_`var' b`var'
	rename _se_`var' se_`var'
	gen t_`var'=(b`var'-hip)/se_`var'
	
	sort b`var'
	gen icl_`var'_bt=0.5*b`var'[2]+0.5*b`var'[3]
	gen icu_`var'_bt=0.5*b`var'[97]+0.5*b`var'[98]
	sort t_`var'
	gen ictl_`var'_bt=0.5*t_`var'[2]+0.5*t_`var'[3]
	gen ictu_`var'_bt=0.5*t_`var'[97]+0.5*t_`var'[98]
}

estpost summarize

esttab, cells(mean) obslast, using "$Resultados/boot_ic_1000_enoe_incisod.tex", replace ///
sfmt(fmt(%9.0g)) ///
label mtitles ("Bootstrap 1000 ENOE 25% de muestra") ///
title("Resumen Bootstrap 1000 ENOE 25% de muestra") ///
addnote("Elaboración propia con datos de la ENOE")

restore


*2. Utiliza el comando bsample ahora y haz las repeticiones por ti mismo. Es decir, repite a, b, d y e. En cada bsample, asegurate de guardar el coeficiente, error y la t, para luego poder encontrar el bootstrap error estandar y el percentil-t. Al final, tendras una base de datos de 100 observaciones o 1000 observaciones, y puedes obtener la parte a y b facilmente.

*Llamamos nuevamente a la base incial para evitar problemas 

reg log_salarioxhr anios_esc eda edad2 rural female  [aw=fac], robust
	
estimates store bsample100_enoe

// OLS en tabla
outreg2 [bsample100_enoe] using "$Resultados/bsample100_enoe.tex", ///
	ctitle(OLS) ///
drop(log_salarioxhr*) stats(coef se ci tstat) label replace

* a) Bootstrap no paramétrico con 100 repeticiones

forval q=1/100 {
	
	quietly use "$Resultados/ENOEproblema4tarea2.dta", clear

global X = "anios_esc eda edad2 rural female"

quietly reg log_salarioxhr $X [aw=fac], robust
	
	quietly bsample
	quietly gen bsample=`q'
	quietly gen hip=0
	
foreach var in $X {
		quietly gen b`var' = _b[`var']
		quietly gen b`var'_se = _se[`var']
		quietly gen t_`var' = (_b[`var']-hip)/_se[`var']
}

keep bsample banios_esc beda bedad2 brural bfemale banios_esc_se beda_se bedad2_se brural_se bfemale_se t_anios_esc t_eda t_edad2 t_rural t_female 

quietly keep if _n==1

	if `q'==1 {
		quietly save "$Resultados/bsample100.dta", replace
	}
	
	else {
		quietly append using "$Resultados/bsample100.dta"
		quietly save "$Resultados/bsample100.dta", replace
	}

} 

* Llamamos a la base que creamos con las observaciones

use "$Resultados/bsample100.dta", clear

* Confidence intervals 

foreach var in anios_esc eda edad2 rural female{
sort b`var' 
gen icl`var'_boot=0.5*b`var'[2]+0.5*b`var'[3]
gen icu`var'_boot=0.5*b`var'[97]+0.5*b`var'[98]
sort t_`var'
gen ictl`var'_boot=0.5*t_`var'[2]+0.5*t_`var'[3]
gen ictu`var'_boot=0.5*t_`var'[97]+0.5*t_`var'[98]
}

* Generamos tabla

estpost summarize 

esttab , cells("mean") obslast, using "$Resultados/bsample100_enoe.tex", replace ///
lab mtitles("bsample 100 ENOE") ///
title("bsample 100 ENOE") ///
addnote("Elaboración propia con datos de la ENOE")

* b) Bootstrap no paramétrico con 1000 repeticiones

forval q=1/1000 {
	
	quietly use "$Resultados/ENOEproblema4tarea2.dta", clear

global X = "anios_esc eda edad2 rural female"

quietly reg log_salarioxhr $X [aw=fac], robust
	
	quietly bsample
	quietly gen bsample=`q'
	quietly gen hip=0
	
foreach var in $X {
		quietly gen b`var' = _b[`var']
		quietly gen b`var'_se = _se[`var']
		quietly gen t_`var' = (_b[`var']-hip)/_se[`var']
}

keep bsample banios_esc beda bedad2 brural bfemale banios_esc_se beda_se bedad2_se brural_se bfemale_se t_anios_esc t_eda t_edad2 t_rural t_female 

quietly keep if _n==1

	if `q'==1 {
		quietly save "$Resultados/bsample1000.dta", replace
	}
	
	else {
		quietly append using "$Resultados/bsample1000.dta"
		quietly save "$Resultados/bsample1000.dta", replace
	}

} 

* Llamamos a la base que creamos con las observaciones

use "$Resultados/bsample1000.dta", clear

* Confidence intervals 

foreach var in anios_esc eda edad2 rural female{
sort b`var' 
gen icl`var'_boot=0.5*b`var'[2]+0.5*b`var'[3]
gen icu`var'_boot=0.5*b`var'[97]+0.5*b`var'[98]
sort t_`var'
gen ictl`var'_boot=0.5*t_`var'[2]+0.5*t_`var'[3]
gen ictu`var'_boot=0.5*t_`var'[97]+0.5*t_`var'[98]
}

* Generamos tabla

estpost summarize 

esttab , cells("mean") obslast, using "$Resultados/bsample1000_enoe.tex", replace ///
lab mtitles("bsample 1000 ENOE") ///
title("bsample 1000 ENOE") ///
addnote("Elaboración propia con datos de la ENOE")

*d) Realiza nuevamente (a) pero en lugar de tomar un bootstrap de toda la muestra N, realiza un bootstrap con 0.25*N. Es decir, el tamano de muestra es menor en cada bootstrap.

forval q=1/100 {
	
	quietly use "$Resultados/ENOEproblema4tarea2.dta", clear

global X = "anios_esc eda edad2 rural female"

quietly reg log_salarioxhr $X [aw=fac], robust
	
	quietly bsample round(0.25*_N)
	quietly bsample
	quietly gen bsample=`q'
	quietly gen hip=0
	
foreach var in $X {
		quietly gen b`var' = _b[`var']
		quietly gen b`var'_se = _se[`var']
		quietly gen t_`var' = (_b[`var']-hip)/_se[`var']
}

keep bsample banios_esc beda bedad2 brural bfemale banios_esc_se beda_se bedad2_se brural_se bfemale_se t_anios_esc t_eda t_edad2 t_rural t_female 

quietly keep if _n==1

	if `q'==1 {
		quietly save "$Resultados/bsample100_25muestra.dta", replace
	}
	
	else {
		quietly append using "$Resultados/bsample100_25muestra.dta"
		quietly save "$Resultados/bsample100_25muestra.dta", replace
	}

} 

* Llamamos a la base que creamos con las observaciones

use "$Resultados/bsample100_25muestra.dta", clear

* Confidence intervals 

foreach var in anios_esc eda edad2 rural female{
sort b`var' 
gen icl`var'_boot=0.5*b`var'[2]+0.5*b`var'[3]
gen icu`var'_boot=0.5*b`var'[97]+0.5*b`var'[98]
sort t_`var'
gen ictl`var'_boot=0.5*t_`var'[2]+0.5*t_`var'[3]
gen ictu`var'_boot=0.5*t_`var'[97]+0.5*t_`var'[98]
}

* Generamos tabla

estpost summarize 

esttab , cells("mean") obslast, using "$Resultados/bsample100_enoe25muestra.tex", replace ///
lab mtitles("bsample 100 ENOE 25% muestra") ///
title("bsample 100 ENOE 25% muestra") ///
addnote("Elaboración propia con datos de la ENOE")


*(e) Realiza nuevamente (b) pero en lugar de tomar un bootstrap de toda la muestra N, realiza un bootstrap con 0.25*N. Es decir, el tama˜no de muestra es menor en cada bootstrap.

forval q=1/1000 {
	
	quietly use "$Resultados/ENOEproblema4tarea2.dta", clear

global X = "anios_esc eda edad2 rural female"

quietly reg log_salarioxhr $X [aw=fac], robust
	
	quietly bsample round(0.25*_N)
	quietly bsample
	quietly gen bsample=`q'
	quietly gen hip=0
	
foreach var in $X {
		quietly gen b`var' = _b[`var']
		quietly gen b`var'_se = _se[`var']
		quietly gen t_`var' = (_b[`var']-hip)/_se[`var']
}

keep bsample banios_esc beda bedad2 brural bfemale banios_esc_se beda_se bedad2_se brural_se bfemale_se t_anios_esc t_eda t_edad2 t_rural t_female 

quietly keep if _n==1

	if `q'==1 {
		quietly save "$Resultados/bsample1000_25muestra.dta", replace
	}
	
	else {
		quietly append using "$Resultados/bsample1000_25muestra.dta"
		quietly save "$Resultados/bsample1000_25muestra.dta", replace
	}

} 

* Llamamos a la base que creamos con las observaciones

use "$Resultados/bsample1000_25muestra.dta", clear

* Confidence intervals 

foreach var in anios_esc eda edad2 rural female{
sort b`var' 
gen icl`var'_boot=0.5*b`var'[2]+0.5*b`var'[3]
gen icu`var'_boot=0.5*b`var'[97]+0.5*b`var'[98]
sort t_`var'
gen ictl`var'_boot=0.5*t_`var'[2]+0.5*t_`var'[3]
gen ictu`var'_boot=0.5*t_`var'[97]+0.5*t_`var'[98]
}

* Generamos tabla

estpost summarize 

esttab , cells("mean") obslast, using "$Resultados/bsample1000_enoe25muestra.tex", replace ///
lab mtitles("bsample 1000 ENOE 25% muestra") ///
title("bsample 1000 ENOE 25% muestra") ///
addnote("Elaboración propia con datos de la ENOE")

/******************Diferencia entre bootstrap y bsmaple ***********************

Bootstrap
Se utiliza para realizar estimaciones de intervalos de confianza y errores estándar para los coeficientes de un modelo estadístico, aplicando el método de remuestreo conocido como bootstrap.
El proceso de bootstrap implica generar múltiples muestras de remuestreo (con reemplazo) a partir de los datos originales, recalcular la estadística de interés en cada muestra, y luego usar la distribución de estas estadísticas recalculadas para estimar intervalos de confianza y errores estándar.
Se usa cuando se quiere obtener estimaciones más robustas de los parámetros del modelo o cuando se trabaja con muestras pequeñas y los supuestos de los métodos paramétricos 

Bsample
Spara generar una muestra de remuestreo (con reemplazo) a partir de los datos actuales. Es una herramienta útil para realizar remuestreo en el análisis de datos, pero no proporciona directamente estimaciones de errores estándar ni intervalos de confianza.
Al usar el comando se crea una nueva muestra de tamaño igual al de la muestra original, pero con algunos casos posiblemente repetidos y otros omitidos, dado que el muestreo se realiza con reemplazo.
Se usa a menudo en combinación con otros comandos para realizar técnicas de remuestreo, como el bootstrap. Es más una herramienta de preparación que un método de estimación por sí mismo.

********************************************************************************
