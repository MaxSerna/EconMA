/*
El Colegio de México
Econometría Aplicada
Max Serna

Problem set 1
Probema 4

*/



gl datos = "D:\Eco aplicada\Tarea 1\Data"


* Base de la ENIGH 92-2022
use "$datos\ENIGH\ENIGH", clear

* Restringimos por edad
keep if edad>19 & edad <66

* homologamos factores
replace factor = factor_hog if año==2014 | año==2012
drop factor_hog

*la variable folio = folioviv + foliohog, y refiere a un hogar específico
*la variable id_per identifica a cada persona; id_per = folio + numren

* (codigo viejo) Definimos al trabajador como aquel que trabaja al menos una hora a la semana
* gen trabaja = (hrxsem > 0 & hrxsem<101)

* renombramos variable dummy para trabajadores
rename trabajo_mp trabaja

* (codigo viejo) Definimos la variable para identificar a las mujeres
*destring sexo, replace
*recode sexo (1=0) (2=1)
*rename sexo mujer
*label variable mujer Mujer

label define Sexo 0 "Hombre", modify
label define Sexo 1 "Mujer", modify
recode sexo (1=0) (0=1)
rename sexo mujer


* (codigo viejo) Definimos la variable para identificar a las personas con educación universitaria
*gen universitario = educaños >= 16
gen universitario = (nivel_ed == 4 | nivel_ed== 5)

* Dado que cada individuo aparece una vez por año, la siguiente variable nos servira para contar cuántas personas hay por año
gen conteo = 1

* Definimos una variable que identificara al hogar en cada año
tostring folio, replace format("%12.0f")
gen folio_año = folio + "_" + string(año)

* Definimos una variable para contar los hogares por año (un hogar puede aparecer mas de una vez por año pues hay mas de una persona en el hogar; tambien puede aparecer en mas de dos años)
egen unique_folio = tag(folio_año)

save "$datos\ENIGH\ENIGH_ready", replace

********** 4.1 y graficos
* codigo viejo
*collapse (sum) conteo unique_folio (mean) universitario trabaja rural [fweight=fac_h], by(año)



/*
1. Realiza una tabla con el númerode observaciones: hogares e individuos, el % con grado
de educación universitaria, el % que trabaja, el % sector rural. Define claramente estas
variables de tal manera que sean comparables en el tiempo. Todo con el comando
putexcel (estout, xtable, o cualquier otro), no se permite copy-paste. Dos decimales
máximo.
*/

collapse (sum) conteo unique_folio (mean) universitario trabaja rural [fweight=factor], by(año)

foreach	var in universitario rural trabaja {
	replace `var' = `var'*100
	format %9.1f `var'
}

replace conteo = conteo / 1000000
replace unique_folio = unique_folio / 1000000

format %9.1f conteo unique_folio

label var año "Año"
label var conteo "Individuos"
label var unique_folio "Hogares"
label var universitario "Grado Universitario"
label var rural "Vivienda Rural"
label var trabaja "Sí trabaja"

texsave * using "D:\Eco aplicada\Tarea 1\Programas\P4\Tablas\ENIGH\Tabla ENIGH", replace ///
title (ENIGH: Características Sociodemográficas 1992 - 2022 ) varlabels location(h) headersep("5px") ///
footnote("Individuos y hogares en millones; el resto en porcentajes \\ Elaboración propia con datos de la ENIGH")

graph twoway connected universitario año, ///
    msymbol(circle) ///
    mcolor(navy) msize(small) ///
    lcolor(edkblue) lwidth(thick) ///
    title("Porcentaje de la población con grado universitario", size(medium) justification(center) span) ///
    xtitle("Año", size(small)) ytitle("Porcentaje (%)", size(small)) ///
    xlabel(1992(2)2022, valuelabel angle(vertical) labsize(small)) ///
    ysize(20cm) xsize(40cm) ///
    scheme(economist) ///  
    caption("Elaboración propia con datos de la ENIGH", size(vsmall) span)
	
graph export "D:\Eco aplicada\Tarea 1\Programas\P4\Gráficos\ENIGH\Universitario ENIGH.jpg", replace

	
graph twoway connected trabaja año, ///
    msymbol(circle) ///
    mcolor(navy) msize(small) ///
    lcolor(edkblue) lwidth(thick) ///
    title("Porcentaje de la población que trabaja", size(medium) justification(center) span) ///
    xtitle("Año", size(small)) ytitle("Porcentaje (%)", size(small)) ///
    xlabel(1992(2)2022, valuelabel angle(vertical) labsize(small)) ///
    ysize(20cm) xsize(40cm) ///
    scheme(economist) ///  
    caption("Elaboración propia con datos de la ENIGH", size(vsmall) span)
	
graph export "D:\Eco aplicada\Tarea 1\Programas\P4\Gráficos\ENIGH\Trabaja ENIGH.jpg", replace
	

graph twoway connected rural año, ///
    msymbol(circle) ///
    mcolor(navy) msize(small) ///
    lcolor(edkblue) lwidth(thick) ///
    title("Porcentaje de la población rural", size(medium) justification(center) span) ///
    xtitle("Año", size(small)) ytitle("Porcentaje (%)", size(small)) ///
    xlabel(1992(2)2022, valuelabel angle(vertical) labsize(small)) ///
    ysize(20cm) xsize(40cm) ///
    scheme(economist) ///  
    caption("Elaboración propia con datos de la ENIGH", size(vsmall) span)
	
graph export "D:\Eco aplicada\Tarea 1\Programas\P4\Gráficos\ENIGH\Rural ENIGH.jpg", replace


********** 4.2 y graficos
/*
Tabla. ¿Puedes identificar el % de mujeres que trabaja, cómo ha evolucionado en el
tiempo? ¿Cómo ha evolucionado para los años mencionados por nivel educativo o por
estado civil o por si tienen hijos? Todo con el comando putexcel, no se permite copypaste. Dos decimales máximo.
*/

use "$datos\ENIGH\ENIGH_ready", clear

keep if mujer==1

* % de mujeres en el tiempo
collapse (mean) trabaja [fweight=factor], by(año)
label var trabaja "Participación laboral femenina (%)"
label var año "Año"
replace traba = trabaja*100
format %9.1f trabaja

twoway connected trabaja año, ///
title("Participación laboral femenina 1992 - 2022", size(medium) justification(center) span) ///
    xtitle("Año", size(small)) ytitle("Porcentaje (%)", size(small)) ///
    xlabel(1992(2)2022, valuelabel angle(vertical) labsize(small)) ///
    ysize(20cm) xsize(40cm) ///
    caption("Elaboración propia con datos de la ENIGH", size(vsmall) span)
	
graph export "D:\Eco aplicada\Tarea 1\Programas\P4\Gráficos\ENIGH\PLF.jpg", replace

texsave * using "D:\Eco aplicada\Tarea 1\Programas\P4\Tablas\ENIGH\PLF", replace ///
title (ENIGH: Participación laboral femenina 1992 - 2022 ) varlabels location(h) headersep("5px") ///
footnote("Elaboración propia con datos de la ENIGH")	
	
	
* nivel educativo
use "$datos\ENIGH\ENIGH_ready", clear
collapse (mean) trabaja [fweight=factor], by(año nivel_ed)
drop if nivel_ed==.
reshape wide trabaja, i(año) j(nivel_ed)

foreach	var in trabaja0 trabaja1 trabaja2 trabaja3 trabaja4 trabaja5 {
	replace `var' = `var'*100
	format %9.1f `var'
}

label var año "Año"
label var trabaja0 "Sin Educación"
label var trabaja1 "Primaria"
label var trabaja2 "Secundaria"
label var trabaja3 "Preparatoria"
label var trabaja4 "Universidad"
label var trabaja5 "Posgrado"

twoway connected trabaja1 trabaja2 trabaja3 trabaja4 trabaja5 año, ///
title("Participación laboral femenina por nivel educativo 1992 - 2022", size(medium) justification(center) span) ///
    xtitle("Año", size(small)) ytitle("Porcentaje (%)", size(small)) ///
    xlabel(1992(2)2022, valuelabel angle(vertical) labsize(small)) ///
    ysize(20cm) xsize(40cm) ///
    caption("Elaboración propia con datos de la ENIGH", size(vsmall) span)

graph export "D:\Eco aplicada\Tarea 1\Programas\P4\Gráficos\ENIGH\PLF estudios.jpg", replace

texsave * using "D:\Eco aplicada\Tarea 1\Programas\P4\Tablas\ENIGH\PLF estudios", replace ///
title (ENIGH: Participación laboral femenina por nivel educativo 1992 - 2022 ) varlabels location(h) headersep("5px") ///
footnote("Elaboración propia con datos de la ENIGH")	
	
* estado civil
use "$datos\ENIGH\ENIGH_ready", clear
collapse (mean) trabaja [fweight=factor], by(año edo_conyug)
drop if edo_conyug == 0 | edo_conyug==.
reshape wide trabaja, i(año) j(edo_conyug)

foreach	var in trabaja1 trabaja2 trabaja3 trabaja4 trabaja5 trabaja6 {
	replace `var' = `var'*100
	format %9.1f `var'
}

label var año "Año"
label var trabaja1 "Unión libre"
label var trabaja2 "Casada"
label var trabaja3 "Separada"
label var trabaja4 "Divorciada"
label var trabaja5 "Viuda"
label var trabaja6 "Soltera"

twoway connected trabaja1 trabaja2 trabaja3 trabaja4 trabaja5 trabaja6 año, ///
title("Participación laboral femenina por estado civil 1992 - 2022", size(medium) justification(center) span) ///
    xtitle("Año", size(small)) ytitle("Porcentaje (%)", size(small)) ///
    xlabel(1996(2)2022, valuelabel angle(vertical) labsize(small)) ///
    ysize(20cm) xsize(40cm) ///
    caption("Elaboración propia con datos de la ENIGH", size(vsmall) span)
	
graph export "D:\Eco aplicada\Tarea 1\Programas\P4\Gráficos\ENIGH\PLF Edocivil.jpg", replace

texsave * using "D:\Eco aplicada\Tarea 1\Programas\P4\Tablas\ENIGH\PLF Edocivil", replace ///
title (ENIGH: Participación laboral femenina por estado civil 1992 - 2022 ) varlabels location(h) headersep("5px") ///
footnote("Elaboración propia con datos de la ENIGH")	

* hijos
use "$datos\ENIGH\ENIGH_ready", clear
collapse (mean) trabaja [fweight=factor], by(año hijos)
drop if hijos==.
reshape wide trabaja, i(año) j(hijos)

foreach	var in trabaja0 trabaja1{
	replace `var' = `var'*100
	format %9.1f `var'
}

label var año "Año"
label var trabaja0 "Sin hijos"
label var trabaja1 "Con hijos"

twoway connected trabaja0 trabaja1 año, ///
title("Participación laboral femenina con hijos y sin hijos 1992 - 2022", size(medium) justification(center) span) ///
    xtitle("Año", size(small)) ytitle("Porcentaje (%)", size(small)) ///
    xlabel(2004(2)2022, valuelabel angle(vertical) labsize(small)) ///
    ysize(20cm) xsize(40cm) ///
    caption("Elaboración propia con datos de la ENIGH", size(vsmall) span)
	
graph export "D:\Eco aplicada\Tarea 1\Programas\P4\Gráficos\ENIGH\PLF hijos.jpg", replace

texsave * using "D:\Eco aplicada\Tarea 1\Programas\P4\Tablas\ENIGH\PLF hijos", replace ///
title (ENIGH: Participación laboral femenina con hijos y sin hijos 1992 - 2022 ) varlabels location(h) headersep("5px") ///
footnote("Elaboración propia con datos de la ENIGH")	