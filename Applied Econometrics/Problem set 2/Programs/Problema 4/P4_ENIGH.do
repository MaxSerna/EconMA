/*
Econometría Aplicada
Problem Set 2
Ejercicio 4
Max Brando Serna Leyva
2023-2025
*/

***********************
* PROBLEMA 4 - Bootstrap : ENIGH *
***********************

global general "D:\Eco aplicada\Tarea 2\4"
global datos "$general\Datos"
global Resultados "$general\Resultados\ENIGH"

*Cargamos nuestra base enigh que creamos y limpiamos en el problema 1

*ssc install outreg2,replace
*ssc install estout, replace

use "$datos\base final.dta", clear

*Estima la regresión de log salario por hora en función de años de escolaridad, edad, edad2, dummy de rural y dummy de female para el año 2022.

keep if year==2022
gen edad2 = edad^2
keep if trabajo==1

la var rural "Rural"
la def rural 0 "No rural" 1 "Rural", replace
la values rural rural
tab rural

*Generamos la variable female
gen female = 1 - sexo
label variable female "Mujer"
label define female 0 "Hombre" 1 "Mujer"
label values female female

* Salario real por hora
gen lnsalariohr = ln(salario_hora)

reg lnsalariohr years_ed edad edad2 rural female [aw=fac], robust
estimates store reg_ols_enigh

// OLS en tabla
outreg2 [reg_ols_enigh] using "$Resultados/coefbt_100_enigh.tex", ///
ctitle(MCO) ///
drop(lhwage*) stats(coef se ci tstat) label replace

// Bootstrap

**Bootstrap no parámetrico con 100 repeticiones
bootstrap _b _se, saving("$Resultados/bootstrap_100_enigh", replace) reps(100): reg lnsalariohr years_ed edad edad2 rural female, robust

estimates store bootstrap_100_enigh

* Guardamos los resultados en una tabla
outreg2 [bootstrap_100_enigh] using "$Resultados/coefbt_100_enigh.tex", ///
append ctitle(Bootstrap 100) label  ///
drop(lnsalariohr*) stats(coef se ci tstat)


* Hacemos manipulación de datos bootstrap
preserve
use "$Resultados/bootstrap_100_enigh.dta", clear
gen hip = 0 // Hipótesis Nula=H0

foreach var in years_ed edad edad2 rural female {
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

esttab, cells(mean) obslast, using "$Resultados/boot_ic_100_enigh.tex", replace ///
sfmt(fmt(%9.0g)) ///
label mtitles ("Bootstrap 100 Enigh") ///
title("Summarize Bootstrap 100 Enigh") ///
addnote("Elaboración propia con datos de la ENIGH")

restore

reg lnsalariohr years_ed edad edad2 rural female [aw=fac], robust
estimates store reg_ols_enigh

// OLS en tabla
outreg2 [reg_ols_enigh] using "$Resultados/coefbt_1000_enigh.tex", ///
ctitle(OLS) ///
drop(lhwage*) stats(coef se ci tstat) label replace

**Bootstrap no paramétrico con 1000 repeticiones
bootstrap _b _se, saving("$Resultados/bootstrap_1000_enigh", replace) reps(1000): reg lnsalariohr years_ed edad edad2 rural female, robust

estimates store bootstrap_1000_enigh

*Guardamos los resultados en una tabla
outreg2 [bootstrap_1000_enigh] using "$Resultados/coefbt_1000_enigh.tex", ///
append ctitle (Bootstrap 1000) label ///
drop (lnsalariohr*) stats(coef se ci tstat)

*Hacemos manipulación de datos bootstrap
preserve 
use "$Resultados/bootstrap_1000_enigh.dta", clear
gen hip = 0

foreach var in years_ed edad edad2 rural female {
	rename _b_`var' b`var'
	rename _se_`var' se_`var'
	gen t_`var' = (b`var'-hip)/se_`var'
	
	sort b`var'
	gen icl_`var'_bt=0.5*b`var'[2]+0.5*b`var'[3]
	gen icu_`var'_bt=0.5*b`var'[97]+0.5*b`var'[98]
	sort t_`var'
	gen ictl_`var'_bt=0.5*t_`var'[2]+0.5*t_`var'[3]
	gen ictu_`var'_bt=0.5*t_`var'[97]+0.5*t_`var'[98]
}

estpost summarize 

esttab, cells(mean) obslast, using "$Resultados/boot_ic_1000_enigh.tex", replace ///
sfmt(fmt(%9.0g)) ///
label mtitles ("Bootstrap 1000 Enigh") ///
title("Summarize Bootstrap 1000 Enigh") ///
addnote("Elaboración propia con datos de la ENIGH")

restore

/*

*Método jacknife para calcular los errores estándar
*Tarda mucho, cuidado con correrlo 

jackknife _b _se, saving("$Resultados/jackknife_enigh", replace): reg lnsalariohr years_ed edad edad2 rural female, robust

estimates store jackknife_enigh

*Guardamos los resultados en una tabla
outreg2 [jackknife_enigh] using "$Resultados/coefjck_enigh.tex", ///
append ctitle (Jackknife) label ///
drop (lnsalariohr*) stats(coef se ci tstat)
*/

*/

**Realizamos nuevamente bootstrap no parámetrico con 100 repeticiones pero ahora en lugar de tomar un bootstrap de toda la muestra, lo realizamos con el 25% de la muestra.

set seed 1234
gen unif=runiform()
keep if unif<0.25 // Random sample 25%

reg lnsalariohr years_ed edad edad2 rural female [aw=fac], robust
estimates store reg_enigh_4

outreg2 [reg_enigh_4] using "$Resultados/coefbt_100_enigh_4.tex", ///
ctitle(OLS) ///
drop(lnwagehr*) stats(coef se ci tstat) label replace

*Bootstrap
bootstrap _b _se, saving("$Resultados/bootstrap_100_enigh_4", replace) reps(100) seed(1234): reg lnsalariohr years_ed edad edad2 rural female, robust

estimates store bootstrap_100_enigh_4

* Guardamos los resultados en una tabla
outreg2 [bootstrap_100_enigh_4] using "$Resultados/coefbt_100_enigh_4.tex", ///
append ctitle(Bootstrap 100 con 25%) label  ///
drop(lnwagehr*) stats(coef se ci tstat)

* Hacemos manipulación de datos bootstrap
preserve
use "$Resultados/bootstrap_100_enigh_4.dta", clear
gen hip = 0 // Hipótesis Nula=H0

foreach var in years_ed edad edad2 rural female {
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

esttab, cells(mean) obslast, using "$Resultados/boot_100_25_enigh.tex", replace ///
sfmt(fmt(%9.0g)) ///
label mtitles ("Bootstrap 100 Enigh 25%") ///
title("Summarize Bootstrap 100 Enigh with 25% sample") ///
addnote("Elaboración propia con datos de la ENIGH")

restore

**Realizamos nuevamente bootstrap no parámetrico con 1000 repeticiones pero ahora en lugar de tomar un bootstrap de toda la muestra, lo realizamos con el 25% de la muestra.

reg lnsalariohr years_ed edad edad2 rural female [aw=fac], robust
estimates store reg_ols_enigh

// OLS en tabla
outreg2 [reg_ols_enigh] using "$Resultados/coefbt_1000_enigh_25.tex", ///
ctitle(OLS) ///
drop(lhwage*) stats(coef se ci tstat) label replace

*Bootstrap
bootstrap _b _se, saving("$Resultados/bootstrap_1000_enigh_25", replace) reps(1000) seed(1234): reg lnsalariohr years_ed edad edad2 rural female, robust

estimates store bootstrap_1000_enigh_25

* Guardamos los resultados en una tabla
outreg2 [bootstrap_1000_enigh_25] using "$Resultados/coefbt_1000_enigh_25.tex", ///
append ctitle(Bootstrap 1000 con 25%) label  ///
drop(lnsalariohr*) stats(coef se ci tstat)

* Hacemos manipulación de datos bootstrap
preserve
use "$Resultados/bootstrap_1000_enigh_25.dta", clear
gen hip = 0 // Hipótesis Nula=H0

foreach var in years_ed edad edad2 rural female {
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

esttab, cells(mean) obslast, using "$Resultados/boot_1000_25_enigh.tex", replace ///
sfmt(fmt(%9.0g)) ///
label mtitles ("Bootstrap 1000 Enigh 25%") ///
title("Summarize Bootstrap 1000 Enigh with 25% sample") ///
addnote("Elaboración propia con datos de la ENIGH")

restore


*2) Utiliza el comando bsample ahora y haz las repeticiones por ti mismo. 

*Repetimos el inciso a

use "$datos\base final.dta", clear

*Estima la regresión de log salario por hora en función de años de escolaridad, edad, edad2, dummy de rural y dummy de female para el año 2022.

keep if year==2022
gen edad2 = edad^2
keep if trabajo==1

la var rural "Rural"
la def rural 0 "No rural" 1 "Rural", replace
la values rural rural
tab rural

*Generamos la variable female
gen female = 1 - sexo
label variable female "Mujer"
label define female 0 "Hombre" 1 "Mujer"
label values female female

* Salario real por hora
gen lnsalariohr = ln(salario_hora)

reg lnsalariohr years_ed edad edad2 rural female [aw=fac], robust
estimates store reg_ols_enigh_2

* Guardamos los resultados en una tabla
outreg2 [reg_ols_enigh_2] using "$Resultados/coefbt_100_enigh.tex", ///
ctitle(OLS) ///
drop(lnsalariohr*) stats(coef se ci tstat) label replace

*Bootstrap no paramétrico con 100 repeticiones

forval q=1/100 {
	
quietly use if year==2022 using "$datos\base final.dta", clear
	
* Generamos variables
gen edad2 = edad^2
keep if trabajo==1
gen lnsalariohr = ln(salario_hora)

la var rural "Rural"
la def rural 0 "No rural" 1 "Rural", replace
la values rural rural

gen female = 1 - sexo
label variable female "Mujer"
label define female 0 "Hombre" 1 "Mujer"
label values female female

* Label variables *
label variable years_ed "Años de educación"
label variable edad "Edad"
label variable edad2 "Edad al cuadrado"
label variable rural "Rural dummy"
label variable female "Female dummy"

global X = "years_ed edad edad2 rural female"

quietly reg lnsalariohr $X [aw=fac], robust
	
	quietly bsample
	
	quietly gen bsample=`q'
	quietly gen hip=0
	
foreach var in $X {
		quietly gen b`var' = _b[`var']
		quietly gen b`var'_se = _se[`var']
		quietly gen t_`var' = (_b[`var']-hip)/_se[`var']
}

keep bsample byears_ed bedad bedad2 brural bfemale byears_ed_se bedad_se bedad2_se brural_se bfemale_se t_years_ed t_edad t_edad2 t_rural t_female 

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

foreach var in $X {
sort b`var' 
gen icl`var'_boot=0.5*b`var'[2]+0.5*b`var'[3]
gen icu`var'_boot=0.5*b`var'[97]+0.5*b`var'[98]
sort t_`var'
gen ictl`var'_boot=0.5*t_`var'[2]+0.5*t_`var'[3]
gen ictu`var'_boot=0.5*t_`var'[97]+0.5*t_`var'[98]
}

* Generamos tabla

estpost summarize 

esttab , cells("mean") obslast, using "$Resultados/bsample100_enigh.tex", replace ///
lab mtitles("bsample 100 Enigh") ///
title("bsample 100 Enigh and OLS") ///
addnote("Elaboración propia con datos de la ENIGH")


**Bootstrap no paramétrico con 1000 repeticiones

forval q=1/1000 {
	
quietly use if year==2022 using "$datos\base final.dta", clear
	
* Generamos variables
gen edad2 = edad^2
keep if trabajo==1
gen lnsalariohr = ln(salario_hora)

la var rural "Rural"
la def rural 0 "No rural" 1 "Rural", replace
la values rural rural

gen female = 1 - sexo
label variable female "Mujer"
label define female 0 "Hombre" 1 "Mujer"
label values female female

* Label variables *
label variable years_ed "Años de educación"
label variable edad "Edad"
label variable edad2 "Edad al cuadrado"
label variable rural "Rural dummy"
label variable female "Female dummy"

global X = "years_ed edad edad2 rural female"

quietly reg lnsalariohr $X [aw=fac], robust
	
	quietly bsample
	
	quietly gen bsample=`q'
	quietly gen hip=0
	
foreach var in $X {
		quietly gen b`var' = _b[`var']
		quietly gen b`var'_se = _se[`var']
		quietly gen t_`var' = (_b[`var']-hip)/_se[`var']
}

keep bsample byears_ed bedad bedad2 brural bfemale byears_ed_se bedad_se bedad2_se brural_se bfemale_se t_years_ed t_edad t_edad2 t_rural t_female 

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

foreach var in $X {
sort b`var' 
gen icl`var'_boot=0.5*b`var'[2]+0.5*b`var'[3]
gen icu`var'_boot=0.5*b`var'[97]+0.5*b`var'[98]
sort t_`var'
gen ictl`var'_boot=0.5*t_`var'[2]+0.5*t_`var'[3]
gen ictu`var'_boot=0.5*t_`var'[97]+0.5*t_`var'[98]
}

* Generamos tabla

estpost summarize 

esttab , cells("mean") obslast, using "$Resultados/bsample1000_enigh.tex", replace ///
lab mtitles("bsample 1000 Enigh") ///
title("bsample 1000 Enigh and OLS") ///
addnote("Elaboración propia con datos de la ENIGH")


**Bootstrap no paramétrico con 100 repeticiones y 0.25*N
forval q=1/100 {
quietly use if year==2022 using "$datos\base final.dta", clear
	
* Generamos variables
gen edad2 = edad^2
keep if trabajo==1
gen lnsalariohr = ln(salario_hora)

la var rural "Rural"
la def rural 0 "No rural" 1 "Rural", replace
la values rural rural

gen female = 1 - sexo
label variable female "Mujer"
label define female 0 "Hombre" 1 "Mujer"
label values female female

* Label variables *
label variable years_ed "Años de educación"
label variable edad "Edad"
label variable edad2 "Edad al cuadrado"
label variable rural "Rural dummy"
label variable female "Female dummy"

global X = "years_ed edad edad2 rural female"

quietly reg lnsalariohr $X [aw=fac], robust
	
	quietly bsample round(0.25*_N)
	
	quietly gen bsample=`q'
	quietly gen hip=0
	
foreach var in $X {
		quietly gen b`var' = _b[`var']
		quietly gen b`var'_se = _se[`var']
		quietly gen t_`var' = (_b[`var']-hip)/_se[`var']
}

keep bsample byears_ed bedad bedad2 brural bfemale byears_ed_se bedad_se bedad2_se brural_se bfemale_se t_years_ed t_edad t_edad2 t_rural t_female 

quietly keep if _n==1

	if `q'==1 {
		quietly save "$Resultados/bsample100_25.dta", replace
	}
	
	else {
		quietly append using "$Resultados/bsample100_25.dta"
		quietly save "$Resultados/bsample100_25.dta", replace
	}

} 

* Llamamos a la base que creamos con las observaciones

use "$Resultados/bsample100_25.dta", clear

* Confidence intervals 

foreach var in $X {
sort b`var' 
gen icl`var'_boot=0.5*b`var'[2]+0.5*b`var'[3]
gen icu`var'_boot=0.5*b`var'[97]+0.5*b`var'[98]
sort t_`var'
gen ictl`var'_boot=0.5*t_`var'[2]+0.5*t_`var'[3]
gen ictu`var'_boot=0.5*t_`var'[97]+0.5*t_`var'[98]
}

* Generamos tabla

estpost summarize 

esttab , cells("mean") obslast, using "$Resultados/bsample100_25_enigh.tex", replace ///
lab mtitles("bsample 100 Enigh con 0.25*N") ///
title("bsample 100 Enigh 0.25*N and OLS") ///
addnote("Elaboración propia con datos de la ENIGH")


**Bootstrap no paramétrico con 1000 repeticiones y 0.25*N
forval q=1/1000 {
quietly use if year==2022 using "$datos\base final.dta", clear
	
* Generamos variables
gen edad2 = edad^2
keep if trabajo==1
gen lnsalariohr = ln(salario_hora)

la var rural "Rural"
la def rural 0 "No rural" 1 "Rural", replace
la values rural rural

gen female = 1 - sexo
label variable female "Mujer"
label define female 0 "Hombre" 1 "Mujer"
label values female female

* Label variables *
label variable years_ed "Años de educación"
label variable edad "Edad"
label variable edad2 "Edad al cuadrado"
label variable rural "Rural dummy"
label variable female "Female dummy"

global X = "years_ed edad edad2 rural female"

quietly reg lnsalariohr $X [aw=fac], robust
	
	quietly bsample round(0.25*_N)
	
	quietly gen bsample=`q'
	quietly gen hip=0
	
foreach var in $X {
		quietly gen b`var' = _b[`var']
		quietly gen b`var'_se = _se[`var']
		quietly gen t_`var' = (_b[`var']-hip)/_se[`var']
}

keep bsample byears_ed bedad bedad2 brural bfemale byears_ed_se bedad_se bedad2_se brural_se bfemale_se t_years_ed t_edad t_edad2 t_rural t_female

quietly keep if _n==1

	if `q'==1 {
		quietly save "$Resultados/bsample1000_25.dta", replace
	}
	
	else {
		quietly append using "$Resultados/bsample1000_25.dta"
		quietly save "$Resultados/bsample1000_25.dta", replace
	}

} 

* Llamamos a la base que creamos con las observaciones

use "$Resultados/bsample1000_25.dta", clear

* Confidence intervals 

foreach var in $X {
sort b`var' 
gen icl`var'_boot=0.5*b`var'[2]+0.5*b`var'[3]
gen icu`var'_boot=0.5*b`var'[97]+0.5*b`var'[98]
sort t_`var'
gen ictl`var'_boot=0.5*t_`var'[2]+0.5*t_`var'[3]
gen ictu`var'_boot=0.5*t_`var'[97]+0.5*t_`var'[98]
}

* Generamos tabla

estpost summarize 

esttab , cells("mean") obslast, using "$Resultados/bsample1000_25_enigh.tex", replace ///
lab mtitles("bsample 1000 Enigh con 0.25*N") ///
title("bsample 1000 Enigh 0.25*N and OLS") ///
addnote("Elaboración propia con datos de la ENIGH")

