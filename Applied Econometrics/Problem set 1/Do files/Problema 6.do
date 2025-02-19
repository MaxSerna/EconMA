/*
El Colegio de México
Econometría Aplicada
Max Brando Serna Leyva

Problem set 1
Problema 6
*/



gl origen = "D:\Eco aplicada\Tarea 1\Programas\P6"
gl destino = "D:\Eco aplicada\Tarea 1\Programas\P6\Tabla y gráficos\Datos"


foreach year in 22 20 18 16 {
	use "$origen\20`year'\Bases\pobreza_`year'.dta", clear
	
	generate año = 20`year'
	
	save "$destino\20`year'", replace
}

* Set the working directory to the folder containing your .dta files
cd "$destino"

* Create an empty dataset to start with
clear

* List of years to loop over
local years 2022 2020 2018 2016

* Loop through each year
foreach year of local years {
    * Load the dataset for the current year
    use "`year'.dta", clear
    
    * If it's the first file, just save it
    if "`year'" == "2022" {
        save combined_dataset.dta, replace
    }
    else {
        * Append the dataset to the combined dataset
        append using combined_dataset.dta
        save combined_dataset.dta, replace
    }
}


use "combined_dataset.dta", clear

collapse (mean) pobreza pobreza_m pobreza_e vul_car vul_ing no_pobv carencias carencias3 ic_rezedu ic_asalud ic_segsoc ic_cv ic_sbv ic_ali_nc plp_e plp [w=factor], by(año)

xpose, clear varname

ssc install nrow

nrow
ren año variable
ren _* año*

order variable año2016 año2018 año2020 año2022

foreach var in año2016 año2018 año2020 año2022 {
	replace `var' = `var'*100
	format %9.1f `var'
}

replace variable = "Población en situación de pobreza" if variable == "pobreza"
replace variable = "Población en situación de pobreza moderada" if variable == "pobreza_m"
replace variable = "Población en situación de pobreza extrema" if variable == "pobreza_e"
replace variable = "Población vulnerable por carencias sociales" if variable == "vul_car"
replace variable = "Población vulnerable por ingresos" if variable == "vul_ing"
replace variable = "Población no pobre y no vulnerable" if variable == "no_pobv"
replace variable = "Población con al menos una carencia social" if variable == "carencias"
replace variable = "Población con al menos tres carencias sociales" if variable == "carencias3"
replace variable = "Rezago educativo" if variable == "ic_rezedu"
replace variable = "Carencia por acceso a los servicios de salud" if variable == "ic_asalud"
replace variable = "Carencia por acceso a la seguridad social" if variable == "ic_segsoc"
replace variable = "Carencia por calidad y espacios de la vivienda" if variable == "ic_cv"
replace variable = "Carencia por acceso a los servicios básicos en la vivienda" if variable == "ic_sbv"
replace variable = "Carencia por acceso a la alimentación nutritiva y de calidad" if variable == "ic_ali_nc"
replace variable = "Población con ingreso inferior a la línea de pobreza extrema por ingresos" if variable == "plp_e"
replace variable = "Población con ingreso inferior a la línea de pobreza por ingresos" if variable == "plp"

rename variable Indicador
rename año2016 _2016
rename año2018 _2018
rename año2020 _2020
rename año2022 _2022

texsave * using "D:\Eco aplicada\Tarea 1\Programas\P6\Tabla y gráficos\Tablas\pobreza.tex", replace

save tabla_final.dta, replace

use tabla_final.dta, clear

keep if _n < 4

reshape long _ , i(Indicador) j(año) string
rename _ value
label variable value "Porcentaje"
label define año 2016 "2016" 2018 "2018" 2020 "2020" 2022 "2022"
destring año, replace

line value año if Indicador=="Población en situación de pobreza",  yaxis(1 2) xaxis(1 2) || scatter value año if Indicador=="Población en situación de pobreza" ||, xlabel("", axis(1)) xtitle("", axis(1)) ytitle("", axis(2)) xtitle("", axis(2)) legend(off) title("Población en situación de pobreza") subtitle(" ") note("Fuente: Elaboración propia con datos del INEGI") scheme(stcolor)

graph export "D:\Eco aplicada\Tarea 1\Programas\P6\Tabla y gráficos\Gráficos\pobreza.jpg"

line value año if Indicador=="Población en situación de pobreza extrema",  yaxis(1 2) xaxis(1 2) || scatter value año if Indicador=="Población en situación de pobreza extrema" ||, xlabel("", axis(1)) xtitle("", axis(1)) ytitle("", axis(2)) xtitle("", axis(2)) legend(off) title("Población en situación de pobreza extrema", l) subtitle(" ") note("Fuente: Elaboración propia con datos del INEGI") scheme(stcolor)

graph export "D:\Eco aplicada\Tarea 1\Programas\P6\Tabla y gráficos\Gráficos\pobreza_e.jpg"