/*
Econometría Aplicada
Problem Set 2
Ejercicio 2
Max Brando Serna Leyva
2023-2025
*/

/*
ssc install egenmore, replace
ssc install outreg2, replace
ssc install spmap, replace
ssc install geo2xy, replace    
ssc install palettes, replace        
ssc install colrspace, replace
ssc install schemepack, replace
ssc install synth2, replace
ssc install synth, replace
cap ado uninstall synth_runner //in-case already installed
net install synth_runner, from(https://raw.github.com/bquistorff/synth_runner/master/) replace
*/


*Problema 2: IMSS

global general = "D:\Eco aplicada\Tarea 2\2"
global imss= "$general\BASE_FINAL"
global output= "$general\OUTPUT"
global data = "$general\BASES_ORI" // database
global datos_mapas = "$general\Datos"


**#Ejercicio 1: Graficar el número de empleados totales por hombre y por mujer con masa salarial positiva
********************************************************************************

/*
use   "$imss\IMSS_2024.dta", clear

forval year = 2000/2024 {
	use "$imss\IMSS_`year'.dta", clear
	collapse (sum) ta_sal, by(fecha sexo)
	label define l_sexo 1 "Hombre" 2 "Mujer", replace  //definimos la etiqueta
	label values sexo l_sexo //asignamos la etiqueta a una variable
save "$output\inciso1\imss1_`year'.dta", replace
}

clear 

forval year = 2000/2024 {
    local filepath "$output\inciso1\imss1_`year'.dta"
    append using "`filepath'"
}

gen ta_miles = ta_sal / 1000
save "$output\inciso1\imss1final.dta", replace

*/

*GRAFICA


use "$output\inciso1\imss1final.dta", clear

twoway (line ta_miles fecha if sexo == 1, lpattern(solid) color(navy)) ///
       (line ta_miles fecha if sexo == 2, lpattern(shortdash) color(orange_red)), ///
       tlabel(2000m1(12)2024m7, angle(45) labsize(small))  ///
	   ylabel(4000(1000)14000, angle (0) labsize(small)) ///
       title("Número de empleados totales por sexo") ///
	   subtitle("2000-2024") ///
       ytitle("Miles de trabajadores") ///
       xtitle("") ///
	   caption("Fuente: Elaboración propia con datos del IMSS", size(small)) ///
       legend(order(1 "Hombre" 2 "Mujer") position(6) rows(1)) ///
	   ysize(20cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white)
	   
	   graph export "$output\inciso1\graphs\imss1.png" , replace
	   
	   
	   
**#Ejercicio 2: grafica el promedio de los ingresos y la mediana de los ingresos para todos los trabajadores en todo el periodo
********************************************************************************

/*
clear

forval year = 2000/2024 {
	use "$imss\IMSS_`year'.dta", clear
	gen mean_sal = masa_sal_ta/ta_sal //SALARIO BASE DE COTIZACIÓN DIARIO
	gen mean_sal2 = masa_sal_ta/ta_sal
	collapse (mean) mean_sal (median) mean_sal2 [aw = ta_sal], by(fecha)
	gen prom_men = mean_sal*30 //SALARIO PROMEDIO DE COTIZACIÓN MENSUAL
	gen med_men = mean_sal2*30 //Mediana del SALARIO DE COTIZACIÓN MENSUAL
	drop mean_sal mean_sal2
save "$output\inciso2\imss2_`year'.dta", replace
}


clear 


forval year = 2000/2024 {
    local filepath "$output\inciso2\imss2_`year'.dta"
    append using "`filepath'"
}

save "$output\inciso2\imss2final.dta", replace
clear

use "$output\inciso2\imss2final.dta", clear
merge 1:1 fecha using "$general\INPC\INPC.dta" //tambien puede ser 1:n te va a unir por cada fila de fecha, varias columnas.

rename ipc INPC //RENOMBRAMOS LA VARIABLE

gen factor_ingreso_real = 136.003/INPC
gen prom_ingreso_real = prom_men*factor_ingreso_real
gen med_ingreso_real = med_men*factor_ingreso_real
format %tm fecha
*drop prom_men med_men
save "$output\inciso2\imss2final_inf.dta", replace

*/

*GRAFICA

use "$output\inciso2\imss2final_inf.dta", clear

tsset fecha 

twoway (tsline prom_ingreso_real, lpattern(solid) color(green)) ///
       (tsline med_ingreso_real, lpattern(shortdash) color(blue)), ///
       tlabel(2000m1(12)2024m7, angle(45) labsize(small))  ///
	   ylabel(5000(2000)20000, angle (0) labsize(small)) ///
       title("Promedio salarial vs Mediana salarial") ///
	   subtitle("2000-2024. Pesos constantes de 2024.") ///
       ytitle("Pesos") ///
       xtitle("") ///
	   caption("Fuente: Elaboración propia con datos del IMSS", size(small)) ///
       legend(order(1 "Promedio" 2 "Mediana") position(6) rows(1)) ///
	   ysize(22cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white)
 

 graph export "$output\inciso2\graphs\imss2.png" , replace
 
 
**#Ejercicio 3:  Grafica el promedio y la mediana del salario al mes para todos los trabajadores. ¿En que percentil se encuentra el promedio?
********************************************************************************
 
 /*
 clear
 
 forvalues year = 2000/2024{
    foreach mes in "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" {
        foreach dia in "28" "29" "30" "31" {
            // Limpiar datos
            clear
            
            // Intentar cargar el archivo .dta
            cap use "$data/IMSS_`year'_`mes'_`dia'.dta", clear
            
            // Verificar si el archivo se cargó correctamente
            if _rc == 0 {
                // Convertir mes a número y agregar las variables year, mes y fecha
                gen year = `year'
                gen mes = real("`mes'")
                gen fecha = ym(`year', mes)
                format fecha %tm
                gen prom_men = (masa_sal_ta/ta_sal)*30 //SALARIO BASE DE COTIZACIÓN DIARIO
				merge n:1 fecha using	"$general\INPC\INPC.dta" 
				rename ipc INPC 
				drop if _merge == 2
				drop _merge
				gen factor_ingreso_real = 136.003/INPC
				gen prom_ingreso_real = prom_men*factor_ingreso_real
				format %tm fecha
				egen percentil = xtile (prom_ingreso_real), n(100) weights(ta_sal) //Revisar si se usa el ponderador aqui o no
				summarize prom_ingreso_real [aw = ta_sal]
				local media = r(mean)
				generate media_ingresos = `media'
				gen ch = media_ingresos - prom_ingreso_real
				generate abs_diff = abs(ch)
				sort abs_diff
				keep in 1
                // Guardar el archivo modificado
                save "$output\inciso3\IMSS_`year'_`mes'_`dia'", replace
            } 
            else {
                // Mostrar mensaje si el archivo no se encontró
                display "Archivo no encontrado: IMSS_`year'_`mes'_`dia'.dta"
            }
        }
    }
}

clear 

 forvalues year = 2000/2024 {

    foreach mes in "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" {
        foreach dia in "28" "29" "30" "31" {
            cap append using "$output\inciso3\IMSS_`year'_`mes'_`dia'"
        }
    }
    
    save "$output\inciso3\IMSS_finalpromedio.dta", replace
}

clear 

*/

*GRAFICA

use "$output\inciso3\IMSS_finalpromedio.dta", clear

tsset fecha
   
graph twoway connected percentil fecha, ///
    msymbol(S) ///
    mcolor(black) msize(tiny) ///
    lcolor(gold) lwidth(thick) ///
    title("¿A qué percentil de la distribución pertenece el promedio salarial?", size(medium) justification(center) span) ///
	subtitle("2000-2024") ///
    xtitle("", size(small)) ///
	ytitle("Percentil", size(medium)) ///
	tlabel(2000m1(12)2024m7, angle(45) labsize(small))  ///
	ylabel(69(1)75, angle(0)) ///
    ysize(20cm) xsize(40cm) ///
    caption("Elaboración propia con datos del IMSS.", size(vsmall) span) ///
	scheme(stsj) ///
	bgcolor(white)

graph export "$output\inciso3\graphs\imsspromedio.png" , replace


**#Ejercicio 4:  Grafica la brecha salarial de genero para todo el periodo.
********************************************************************************

/*

clear

 forvalues year = 2000/2024{
    foreach mes in "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" {
        foreach dia in "28" "29" "30" "31" {
            // Limpiar datos
            clear
            
            // Intentar cargar el archivo .dta
            cap use "$data/IMSS_`year'_`mes'_`dia'.dta", clear
            
            // Verificar si el archivo se cargó correctamente
            if _rc == 0 {
                // Convertir mes a número y agregar las variables year, mes y fecha
                gen year = `year'
                gen mes = real("`mes'")
                gen fecha = ym(`year', mes)
               format fecha %tm
				gen prom_men = (masa_sal_ta/ta_sal)*30 //SALARIO BASE DE COTIZACIÓN DIARIO
				merge n:1 fecha using	"$general\INPC\INPC.dta" 
				rename ipc INPC 
				drop if _merge == 2
				drop _merge
				gen factor_ingreso_real = 136.003/INPC
				gen prom_ingreso_real = prom_men*factor_ingreso_real
				gen mediana_ingreso_real = prom_ingreso_real
				format %tm fecha
				collapse (mean) prom_ingreso_real (median) mediana_ingreso_real [aw = ta_sal], by(fecha sexo)
				reshape wide prom_ingreso_real mediana_ingreso_real, i(fecha) j(sexo)
				gen brecha_prom = ((prom_ingreso_real1-prom_ingreso_real2)/prom_ingreso_real1)
				gen brecha_med = ((mediana_ingreso_real1 -mediana_ingreso_real2 )/mediana_ingreso_real1)
                // Guardar el archivo modificado
                save "$output\inciso4\IMSS_`year'_`mes'_`dia'", replace
            } 
            else {
                // Mostrar mensaje si el archivo no se encontró
                display "Archivo no encontrado: IMSS_`year'_`mes'_`dia'.dta"
            }
        }
    }
}

clear 

 forvalues year = 2000/2024 {

    foreach mes in "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" {
        foreach dia in "28" "29" "30" "31" {
            cap append using "$output\inciso4\IMSS_`year'_`mes'_`dia'"
        }
    }
    
    save "$output\inciso4\IMSS_finalbrechagenero.dta", replace
}

clear 

*/

*GRAFICA

use "$output\inciso4\IMSS_finalbrechagenero.dta", clear

gen brecha_prom_porcentual = brecha_prom * 100
gen brecha_med_porcentual = brecha_med *100

tsset fecha
 
twoway (tsline brecha_prom_porcentual, lpattern(solid) color(green)) ///
       (tsline brecha_med_porcentual, lpattern(shortdash) color(blue)), ///
       tlabel(2000m1(12)2024m7, angle(45) labsize(small))  ///
	   ylabel(0(5)30, angle (0) labsize(small)) ///
       title("Brecha salarial de género") ///
	   subtitle("2000-2024.") ///
       ytitle("%", orientation(horizontal)) ///
       xtitle("") ///
	   caption("Fuente: Elaboración propia con datos del IMSS", size(small)) ///
       legend(order(1 "Promedio salarial" 2 "Mediana salarial") position(6) rows(1)) ///
	   ysize(22cm) xsize(40cm) ///
	   scheme(stsj) ///
	   bgcolor(white)
 
graph export "$output\inciso4\graphs\imssbrechasalarial.png" , replace


**#Ejercicio 5:  Realiza un bootstrap para obtener intervalos de confianza con el método del percentil 95%, e incluyelos en tu figura de brecha de género
********************************************************************************
/*
clear

forval yr = 2000/2024{
use "$imss\IMSS_`yr'.dta",clear

gen prom_men = (masa_sal_ta/ta_sal)*30 //SALARIO BASE DE COTIZACIÓN DIARIO
merge n:1 fecha using	"$general\INPC\INPC.dta" 
rename ipc INPC 
drop if _merge == 2
drop _merge
gen factor_ingreso_real = 136.003/INPC
gen prom_ingreso_real = prom_men*factor_ingreso_real
gen mean_sal = masa_sal_ta/ta_sal
gen ln_prom_mr = ln(prom_ingreso_real)

*Bootstrap 

sample 1, by(fecha sexo)
	replace sexo=0 if sexo==1
	replace sexo=1 if sexo==2
putexcel set "$output\inciso5\bootxl_`yr'.xlsx", replace 
forval i=1/12 {
	
	preserve
	bootstrap "reg ln_prom_mr sexo, robust" _b _se, reps(200) dots saving("$output\inciso5\bs2_`yr'") replace
	
	reg ln_prom_mr sexo, robust
	
	use "$output\inciso5\bs2_`yr'", clear
	
	generate tmale= (b_sexo - _b[sexo]) / se_sexo 
	
	_pctile tmale, p(2.5 97.5)

	
	mat define Z=[_b[sexo]- _se[sexo]*r(r2), _b[sexo], _b[sexo]- _se[sexo]*r(r1)]
	
	putexcel set "$output\inciso5\boot2_`yr'.xlsx", modify
	putexcel A`i' = `yr'
	putexcel B`i' = `i'
	putexcel C`i'= matrix(Z)

	restore
}

}

clear 

forval yr = 2000/2024{

import excel "$output\inciso5\boot2_`yr'.xlsx", clear
rename A year
rename B Mes
rename C _binf
rename D _beta
rename E _bsup
gen fecha = mdy(Mes,1,year)
format fecha %d
save "$output\inciso5\IMSS_bootfinal_`yr'.dta", replace
}

clear 

forval yr = 2000/2024 {
    local filepath "$output\inciso5\IMSS_bootfinal_`yr'.dta"
    append using "`filepath'"
}

save "$output\inciso5\boot_completo2.dta", replace
clear

*/

*****Grafica intervalos de confianza 

use "$output\inciso5\boot_completo2.dta", clear

replace fecha = mofd(fecha)    // Convert daily date to monthly date
tsset fecha
format fecha %tm

foreach var of varlist _binf _beta _bsup {
    replace `var' = `var' * -100
}
	 
twoway (tsline _beta, color(red) lwidth(medthick)) ///
	   (rarea _binf _bsup fecha, color(lavender%40)), ///
	   tlabel(2000m1(12)2024m7, angle(45) labsize(small))  ///
	   ylabel(10(1)20, angle (0) labsize(small)) ///
       title("Brecha salarial de género") ///
	   subtitle("2000-2024.") ///
       ytitle("%", orientation(horizontal)) ///
       xtitle("") ///
	   caption("Fuente: Elaboración propia con datos del IMSS", size(small)) ///
       legend(order(1 "Brecha salarial" 2 "Intervalo de confianza al 95% (Boostrap)") position(6) rows(1)) ///
	   ysize(22cm) xsize(40cm)  ///
	   scheme(stsj) ///
	   bgcolor(white)
	   
graph export "$output\inciso5\graphs\imss_intervalos de confianza.png" , replace


**#Ejercicio 6: ¿Qué entidad federativa tiene la menor y mayor brecha de género en 2024?
********************************************************************************


*¿Qué entidad federativa tiene mayor brecha de género en 2024?

/*

use "$imss\IMSS_2024.dta",clear

gen prom_men = (masa_sal_ta/ta_sal)*30 //SALARIO BASE DE COTIZACIÓN DIARIO
merge n:1 fecha using	"$general\INPC\INPC.dta" 
rename ipc INPC 
drop if _merge == 2
drop _merge
gen factor_ingreso_real = 136.003/INPC
gen prom_ingreso_real = prom_men*factor_ingreso_real
gen mediana_ingreso_real = prom_ingreso_real
format %tm fecha
collapse (mean) prom_ingreso_real (median) mediana_ingreso_real [aw = ta_sal], by(cve_entidad sexo)
reshape wide prom_ingreso_real mediana_ingreso_real, i(cve_entidad) j(sexo)
gen brecha_prom = ((prom_ingreso_real1-prom_ingreso_real2)/prom_ingreso_real1)*100
gen brecha_med = ((mediana_ingreso_real1-mediana_ingreso_real2)/mediana_ingreso_real)*100
merge 1:1 cve_entidad using "$general\imss_entidades"


save "$output\inciso6\imss_brecha_por_entidades.dta", replace

clear 

*/

**Gráficas
use "$output\inciso6\imss_brecha_por_entidades.dta", clear

*Gráfica 1 (solo media)
graph bar brecha_prom brecha_med, ///
	over(Estado, ///
		sort(1) ///
		lab(angle(90))) ///
	legend(order(1 "En promedio salarial" 2 "En mediana salarial") position(6) rows(1) region(color(white))) ///
	title("Brecha salarial de género por entidad federativa 2024") ///
	bar(1, color(midblue%70)) ///
	bar(2, color(dkgreen%20)) ///
	ytitle("") ///
	scale(0.7) ///
	ylabel(-3(2)28, nolab) ///
	caption("Fuente: Elaboración propia con datos del IMSS", size(small)) ///
	blabel(bar, position(outside) format(%9.1f) size(small) orientation(vertical)) ///
	ysize(20cm) xsize(40cm) ///
	scheme(economist) ///
	graphregion(color(white)) ///
    plotregion(fcolor(white)) ///
	bgcolor(white)
  
  graph export "$output\inciso6\graphs\imssbrechasalarial_entidadesfederativas2.png", replace
  

*¿Qué entidades son las más afectadas por la COVID (Feb 2020 con Jul 2023)?


***** Analizamos esta afectación por el cambio % nivel de empleo por estado


/*
clear 

use "$imss\IMSS_2024.dta",clear
drop if mes != 7
rename ta_sal ta_2024_07
collapse (sum) ta_2024_07 , by(fecha cve_entidad)
save "$output\inciso6\2024_07.dta", replace

clear

use "$imss\IMSS_2020.dta",clear
drop if mes != 2
rename ta_sal ta_2020_02
collapse (sum) ta_2020_02 , by(fecha cve_entidad)
save "$output\inciso6\2020_02.dta", replace
merge 1:1 cve_entidad using "$output\inciso6\2024_07.dta"
drop _merge
merge 1:1 cve_entidad using "$general\imss_entidades"
drop _merge
gen change = ((ta_2024_07-ta_2020_02)/ta_2020_02)*100

save "$output\inciso6\cambio_nivel_de_empleo", replace

*/

use "$output\inciso6\cambio_nivel_de_empleo", clear

graph bar change, ///
	over(Estado, ///
		sort(1) ///
		lab(angle(90))) ///
	title("Variación porcentual en el empleo por entidad federativa") ///
	subtitle("Febrero 2020 - Julio 2024") ///
	bar(1, color(emerald%70)) ///
	ytitle("") ///
	scale(0.7) ///
	ylabel(-2(2)28, nolab) ///
	caption("Fuente: Elaboración propia con datos del IMSS", size(small)) ///
	blabel(bar, position(outside) format(%9.1f) size(small)) ///
	ysize(20cm) xsize(40cm) ///
	scheme(economist) ///
	graphregion(color(white)) ///
    plotregion(fcolor(white)) ///
	bgcolor(white)

graph export "$output\inciso6\graphs\imss_cambio_nivel_de_empleo_por_estado.png", replace


**#Ejercicio 7:  ¿Qué entidad federativa ha incrementado más su empleo en términos porcentuales entre 2012 y 2024 (usa el mismo mes o trimestre)?
********************************************************************************
/*

clear 

****usamos el mes de mayo de ambos años para generar la comparación

use "$imss\IMSS_2024.dta",clear
drop if mes != 5
rename ta_sal ta_2024
collapse (sum) ta_2024 , by(fecha cve_entidad)
save "$output\inciso7\2024.dta", replace

clear

use "$imss\IMSS_2012.dta",clear
drop if mes != 5
rename ta_sal ta_2012
collapse (sum) ta_2012 , by(fecha cve_entidad)
save "$output\inciso7\2012.dta", replace
merge 1:1 cve_entidad using "$output\inciso7\2024.dta"
drop _merge
merge 1:1 cve_entidad using "$general\imss_entidades"
drop _merge
gen change = ((ta_2024-ta_2012)/ta_2012)*100


save "$output\inciso7\cambio_nivel_de_empleo", replace

*/

use "$output\inciso7\cambio_nivel_de_empleo", clear

graph bar change, ///
	over(Estado, ///
		sort(1) ///
		lab(angle(90))) ///
	title("Variación porcentual en el nivel de empleo por entidad federativa") ///
	subtitle("Mayo 2012 - Mayo 2024") ///
	bar(1, color(ebblue%60)) ///
	ytitle("") ///
	scale(0.7) ///
	ylabel(-5(5)100, nolab nogrid) ///
	caption("Fuente: Elaboración propia con datos del IMSS", size(small)) ///
	blabel(bar, position(outside) format(%9.1f) size(small)) ///
	ysize(20cm) xsize(40cm) ///
	scheme(economist) ///
	graphregion(color(white)) ///
    plotregion(fcolor(white)) ///
	bgcolor(white)
  
graph export "$output\inciso7\graphs\imss_cambio_nivel_de_empleo_por_estado.png", replace


**#Ejercicio 8:  Realiza unmapa en Stata y enRsobre los cambios en empleo y en salario a nivel entidad federativa. Usa dos an˜os base: 2010 y 2017, y el año final 2024. Queremos saber la distribuci´on de cambios en empleo y salario en ese periodo
********************************************************************************
/*

clear 

******2024

use "$imss\IMSS_2024.dta",clear
drop if mes != 7
format %tm fecha
collapse (sum) ta_sal , by(year cve_entidad)
save "$output\inciso8\2024_ta_sal.dta", replace

clear 



use "$imss\IMSS_2024.dta",clear
drop if mes != 7
gen prom_men = (masa_sal_ta/ta_sal)*30
gen med_men = prom_men
merge n:1 fecha using	"$general\INPC\INPC.dta" 
rename ipc INPC 
drop _merge
gen factor_ingreso_real = 136.003/INPC
gen prom_ingreso_real = prom_men*factor_ingreso_real
gen mediana_ingreso_real = med_men*factor_ingreso_real
format %tm fecha
collapse (mean) prom_ingreso_real (median) mediana_ingreso_real [aw = ta_sal], by(year cve_entidad)
merge n:1 cve_entidad using	"$output\inciso8\2024_ta_sal.dta"
drop _merge
save "$output\inciso8\2024.dta", replace

clear 



******2017

clear 

use "$imss\IMSS_2017.dta",clear
drop if mes != 7
format %tm fecha
collapse (sum) ta_sal , by(year cve_entidad)
save "$output\inciso8\2017_ta_sal.dta", replace


clear

use "$imss\IMSS_2017.dta",clear
drop if mes != 7
gen prom_men = (masa_sal_ta/ta_sal)*30
gen med_men = prom_men
merge n:1 fecha using	"$general\INPC\INPC.dta" 
rename ipc INPC 
drop _merge
gen factor_ingreso_real = 136.003/INPC
gen prom_ingreso_real = prom_men*factor_ingreso_real
gen mediana_ingreso_real = med_men*factor_ingreso_real
format %tm fecha
collapse (mean) prom_ingreso_real (median) mediana_ingreso_real [aw = ta_sal], by(year cve_entidad)
merge n:1 cve_entidad using	"$output\inciso8\2017_ta_sal.dta"
drop _merge
save "$output\inciso8\2017.dta", replace




********2010 


clear 

use "$imss\IMSS_2010.dta",clear
drop if mes != 7
format %tm fecha
collapse (sum) ta_sal , by(year cve_entidad)
save "$output\inciso8\2010_ta_sal.dta", replace


clear

use "$imss\IMSS_2010.dta",clear
drop if mes != 7
gen prom_men = (masa_sal_ta/ta_sal)*30
gen med_men = prom_men
merge n:1 fecha using	"$general\INPC\INPC.dta" 
rename ipc INPC 
drop _merge
gen factor_ingreso_real = 136.003/INPC
gen prom_ingreso_real = prom_men*factor_ingreso_real
gen mediana_ingreso_real = med_men*factor_ingreso_real
format %tm fecha
collapse (mean) prom_ingreso_real (median) mediana_ingreso_real [aw = ta_sal], by(year cve_entidad)
merge n:1 cve_entidad using	"$output\inciso8\2010_ta_sal.dta"
drop _merge
save "$output\inciso8\2010.dta", replace



*******unimos las bases

clear

foreach x in 2010 2017 2024 {
    local file "$output\inciso8\\`x'.dta"
    append using "`file'"
}



gen id = cve_entidad 
order id, before(cve_entidad)
drop cve_entidad
rename year año
rename prom_ingreso_real prom_mr
rename mediana_ingreso_real med_mr
save "$output\inciso8\imss8_final.dta", replace


use "$output\inciso8\imss8_final.dta", clear

**Salarios promedio
sort id año
by id : gen lag_wage1 = prom_mr[_n-1] 
replace lag_wage1 = 0 if lag_wage1==. 

by id : gen wage_d17_23 = ((prom_mr / lag_wage1)-1)*100  // 2024-2017
replace wage_d17_23=0 if (año==2010 | año==2017)

sort id año 
by id : gen lag_wage2 = prom_mr[_n-2]
replace lag_wage2=0 if lag_wage2==. 

by id : gen wage_d10_23 = ((prom_mr / lag_wage2) - 1)*100 // 2024-2010
replace wage_d10_23=0 if (año==2010 | año==2017)

**Salarios mediana
sort id año
by id : gen lag_med1 = med_mr[_n-1] 
replace lag_med1 = 0 if lag_med1==. 

by id : gen med_d17_23 = ((med_mr / lag_med1)-1)*100  // 2024-2017
replace med_d17_23=0 if (año==2010 | año==2017)

sort id año 
by id : gen lag_med2 = med_mr[_n-2]
replace lag_med2=0 if lag_med2==. 

by id : gen med_d10_23 = ((med_mr / lag_med2) - 1)*100 // 2024-2010
replace wage_d10_23=0 if (año==2010 | año==2017)

**Trabajadores
sort id año
by id : gen lag_ta1 = ta_sal[_n-1] 
replace lag_ta1 = 0 if lag_ta1==. 

by id : gen ta_d17_23 = ((ta_sal / lag_ta1)-1)*100  // 2024-2017
replace ta_d17_23=0 if (año==2010 | año==2017)

sort id año 
by id : gen lag_ta2 = ta_sal[_n-2]
replace lag_ta2=0 if lag_ta2==. 

by id : gen ta_d10_23 = ((ta_sal / lag_ta2) - 1)*100 // 2024-2010
replace ta_d10_23=0 if (año==2010 | año==2017)

*Reducimos decimales
format wage_d17_23 %2.1f
format wage_d10_23 %2.1f
format med_d17_23 %2.1f
format med_d10_23 %2.1f
format ta_d17_23 %2.1f
format ta_d10_23 %2.1f

save "$output\inciso8\imss8_final_cambios.dta", replace

*/

******Mapas*********

use "$output\inciso8\imss8_final_cambios.dta", clear

*Mapa 1 cambio salarial promedio 2017-2024
set scheme s2gcolor
colorpalette HSV heat, n(6) nograph reverse
local colors `r(p)'

spmap wage_d17_23 if año==2024 using "$datos_mapas\coord_estados_vnew.dta", id(id) ///
	clmethod(custom) clbreaks(0 5 10 20 30 40 50) ///
	legend(symy(*1.2) symx(*1.2) size(vsmall) region(fcolor(white))) ///
	title("Variación porcentual en los salarios promedio por entidad: 2024 vs 2017", size(medium) placement(left) margin(b=3 t=3)) ///
	fcolor("`colors'") ocolor(white ..) osize(0.1 ..) ///
	note("Fuente: Elaboración propia con datos del IMSS. Tomamos julio como el mes de referencia", size(2))

graph export "$output\inciso8\graphs\imss8_1.png", replace

*Mapa 2 cambio salarial promedio 2010-2024

set scheme s2gcolor
colorpalette HSV heat, n(6) nograph reverse
local colors `r(p)'

spmap wage_d10_23 if año==2024 using "$datos_mapas\coord_estados_vnew.dta", id(id) ///
	clmethod(custom) clbreaks(0 5 10 20 30 40 50) ///
	legend(symy(*1.2) symx(*1.2) size(vsmall) region(fcolor(white))) ///
	title("Variación porcentual en los salarios promedio por entidad: 2024 vs 2010", size(medium) placement(left) margin(b=3 t=3)) ///
	fcolor("`colors'") ocolor(white ..) osize(0.1 ..) ///
	note("Fuente: Elaboración propia con datos del IMSS. Tomamos julio como el mes de referencia", size(2))

graph export "$output\inciso8\graphs\imss8_2.png", replace


*Mapa 3 cambio trabajadores 2017-2024

set scheme s2gcolor
colorpalette HSV heat, n(6) nograph reverse
local colors `r(p)'

spmap ta_d17_23 if año==2024 using "$datos_mapas\coord_estados_vnew.dta", id(id) ///
	clmethod(custom) clbreaks(0 10 20 30 40 50) ///
	legend(symy(*1.2) symx(*1.2) size(vsmall) region(fcolor(white))) ///
	title("Variación porcentual en el número de trabajadores por entidad: 2024 vs 2017", size(medium) placement(left) margin(b=3 t=3)) ///
	fcolor("`colors'") ocolor(white ..) osize(0.1 ..) ///
	note("Fuente: Elaboración propia con datos del IMSS. Tomamos julio como el mes de referencia", size(2))

graph export "$output\inciso8\graphs\imss8_3.png", replace


*Mapa 4 cambio trabajadores 2010-2024

set scheme s2gcolor
colorpalette HSV heat, n(6) nograph reverse
local colors `r(p)'

spmap ta_d10_23 if año==2024 using "$datos_mapas\coord_estados_vnew.dta", id(id) ///
	clmethod(custom) clbreaks(0 10 40 60 80 100 120) ///
	legend(symy(*1.2) symx(*1.2) size(vsmall) region(fcolor(white))) ///
	title("Variación porcentual en el número de trabajadores por entidad: 2024 vs 2010", size(medium) placement(left) margin(b=3 t=3)) ///
	fcolor("`colors'") ocolor(white ..) osize(0.1 ..) ///
	note("Fuente: Elaboración propia con datos del IMSS. Tomamos julio como el mes de referencia", size(2))

graph export "$output\inciso8\graphs\imss8_6.png", replace


**#Ejercicio 9:   Realiza un mapa en Stata y enRsobre los cambios en empleo y en salario a nivel entidad federativa. Usa Febrero 2020 como base, y el an˜o final julio 2020 y 2024. Queremos saber la distribuci´on de cambios en empleo y salario en ese periodo.
********************************************************************************

/*

clear 

******2024

use "$imss\IMSS_2024.dta",clear
drop if mes != 7
format %tm fecha
collapse (sum) ta_sal , by(year cve_entidad)
save "$output\inciso9\2024_ta_sal.dta", replace


use "$imss\IMSS_2024.dta",clear
drop if mes != 7
gen prom_men = (masa_sal_ta/ta_sal)*30
gen med_men = prom_men
merge n:1 fecha using	"$general\INPC\INPC.dta" 
rename ipc INPC 
drop _merge
gen factor_ingreso_real = 136.003/INPC
gen prom_ingreso_real_jul_2024 = prom_men*factor_ingreso_real
gen mediana_ingreso_real_jul_2024 = med_men*factor_ingreso_real
format %tm fecha
collapse (mean) prom_ingreso_real (median) mediana_ingreso_real [aw = ta_sal], by(year cve_entidad)
merge n:1 cve_entidad using	"$output\inciso9\2024_ta_sal.dta"
drop _merge
gen ta_24 = ta_sal
drop ta_sal
save "$output\inciso9\2024.dta", replace

******2020


use "$imss\IMSS_2020.dta",clear
drop if mes != 7
format %tm fecha
collapse (sum) ta_sal , by(year cve_entidad)
save "$output\inciso9\20207_ta_sal.dta", replace

use "$imss\IMSS_2020.dta",clear
drop if mes != 7
gen prom_men = (masa_sal_ta/ta_sal)*30
gen med_men = prom_men
merge n:1 fecha using	"$general\INPC\INPC.dta" 
rename ipc INPC 
drop _merge
gen factor_ingreso_real = 136.003/INPC
gen prom_ingreso_real_jul_2020 = prom_men*factor_ingreso_real
gen mediana_ingreso_real_jul_2020 = med_men*factor_ingreso_real
format %tm fecha
collapse (mean) prom_ingreso_real (median) mediana_ingreso_real [aw = ta_sal], by(year cve_entidad)
merge n:1 cve_entidad using	"$output\inciso9\20207_ta_sal.dta"
drop _merge
gen ta_20Jul = ta_sal
drop ta_sal
save "$output\inciso9\2020_07.dta", replace


********2020

use "$imss\IMSS_2020.dta",clear
drop if mes != 2
format %tm fecha
collapse (sum) ta_sal , by(year cve_entidad)
save "$output\inciso9\20202_ta_sal.dta", replace


use "$imss\IMSS_2020.dta",clear
drop if mes != 2
gen prom_men = (masa_sal_ta/ta_sal)*30
gen med_men = prom_men
merge n:1 fecha using	"$general\INPC\INPC.dta" 
rename ipc INPC 
drop _merge
gen factor_ingreso_real = 136.003/INPC
gen prom_ingreso_real_feb = prom_men*factor_ingreso_real
gen mediana_ingreso_real_feb = med_men*factor_ingreso_real
format %tm fecha
collapse (mean) prom_ingreso_real (median) mediana_ingreso_real [aw = ta_sal], by(year cve_entidad)
merge n:1 cve_entidad using	"$output\inciso9\20202_ta_sal.dta"
drop _merge
gen ta_20Feb = ta_sal
drop ta_sal
save "$output\inciso9\2020_02.dta", replace

*******unimos las bases

use "$output\inciso9\2020_02.dta", clear
merge 1:n cve_entidad using "$output\inciso9\2020_07.dta"
drop _merge
merge 1:1 cve_entidad using "$output\inciso9\2024.dta"
drop _merge year
gen id = cve_entidad 
order id, before(cve_entidad)
drop cve_entidad

save "$output\inciso9\imssfinal.dta", replace


*Salario promedio
gen prom_20J_20F = ((prom_ingreso_real_jul_2020/prom_ingreso_real_feb)-1)*100  //2020Feb - 2020Jul
gen prom_24_20F = ((prom_ingreso_real_jul_2024/prom_ingreso_real_feb) -1 ) *100 //2020Feb - 2024Jul


*Salario mediana
gen med_20J_20F = ((mediana_ingreso_real_jul_2020/mediana_ingreso_real_feb)-1)*100  //2020Feb - 2020Jul
gen med_24_20F = ((mediana_ingreso_real_jul_2024/mediana_ingreso_real_feb) -1 ) *100 //2020Feb - 2024Jul


*Trabajadores
gen ta_20J_20F = ((ta_20Jul/ta_20Feb)-1)*100  //2020Feb - 2020Jul
gen ta_24_20F = ((ta_24/ta_20Feb) -1 ) *100 //2020Feb - 2024Jul

*Reducimos decimales
format prom_20J_20F %2.1f
format prom_24_20F %2.1f
format med_20J_20F %2.1f
format med_24_20F %2.1f
format ta_20J_20F %2.1f
format ta_24_20F %2.1f

save "$output\inciso9\imssfinal_01.dta", replace

*/

*****Mapas*****
use "$output\inciso9\imssfinal_01.dta", clear

*Mapa 1 cambio salarial promedio 2020Feb-2020Jul

set scheme s2gcolor
colorpalette HSV heat, n(6) nograph reverse
local colors `r(p)'

spmap prom_20J_20F using "$datos_mapas\coord_estados_vnew.dta", id(id) ///
	clmethod(custom) clbreaks(-2 -1 0 1 2 3 5) ///
	legend(symy(*1.2) symx(*1.2) size(vsmall) region(fcolor(white))) ///
	title("Variación porcentual en los salarios promedio por entidad: Julio 2020 vs Febrero 2020", size(medium) placement(left) margin(b=3 t=3)) ///
	fcolor("`colors'") ocolor(white ..) osize(0.1 ..) ///
	note("Fuente: Elaboración propia con datos del IMSS.", size(2))

graph export "$output\inciso9\graphs\imssFebJul2020.png", replace


*Mapa 2 cambio salarial promedio 2020Feb-2024Jul

set scheme s2gcolor
colorpalette HSV heat, n(6) nograph reverse
local colors `r(p)'

spmap prom_24_20F using "$datos_mapas\coord_estados_vnew.dta", id(id) ///
	clmethod(custom) clbreaks(0 10 15 20 25 30 35) ///
	legend(symy(*1.2) symx(*1.2) size(vsmall) region(fcolor(white))) ///
	title("Variación porcentual en los salarios promedio por entidad: Julio 2024 vs Febrero 2020", size(medium) placement(left) margin(b=3 t=3)) ///
	fcolor("`colors'") ocolor(white ..) osize(0.1 ..) ///
	note("Fuente: Elaboración propia con datos del IMSS.", size(2))

graph export "$output\inciso9\graphs\imssFebJul2024.png", replace


*Mapa 3 cambio en trabajadores 2020Feb-2020Jul

set scheme s2gcolor
colorpalette HSV heat, n(6) nograph reverse
local colors `r(p)'

spmap ta_20J_20F using "$datos_mapas\coord_estados_vnew.dta", id(id) ///
	clmethod(custom) clbreaks(-30 -25 -20 -10 -5 0) ///
	legend(symy(*1.2) symx(*1.2) size(vsmall) region(fcolor(white))) ///
	title("Variación porcentual en el número de trabajadores por entidad: Julio 2020 vs Febrero 2020", size(medium) placement(left) margin(b=3 t=3)) ///
	fcolor("`colors'") ocolor(white ..) osize(0.1 ..) ///
	note("Fuente: Elaboración propia con datos del IMSS.", size(2))

graph export "$output\inciso9\graphs\imssFebJul2020trabjadores.png", replace


*Mapa 4 cambio en trabajadores 2020Feb-2024Jul

set scheme s2gcolor
colorpalette HSV heat, n(6) nograph reverse
local colors `r(p)'

spmap ta_24_20F using "$datos_mapas\coord_estados_vnew.dta", id(id) ///
	clmethod(custom) clbreaks(-1 0 5 10 15 20 30) ///
	legend(symy(*1.2) symx(*1.2) size(vsmall) region(fcolor(white))) ///
	title("Variación porcentual en el número de trabajadores por entidad: Julio 2024 vs Febrero 2020", size(medium) placement(left) margin(b=3 t=3)) ///
	fcolor("`colors'") ocolor(white ..) osize(0.1 ..) ///
	note("Fuente: Elaboración propia con datos del IMSS.", size(2))

graph export "$output\inciso9\graphs\imssFebJul2024trabjadores.png", replace


**#Ejercicio 10:   Realiza un mapa en R a nivel municipal sobre los cambios en empleo y en salario. Restringe la muestra a aquellos municipios con al menos 10,000 empleados en el an˜o base. Para poder hacer este ejercicio tendrás que hacer un merge con la base de municipios de c´odigo INEGI, ver el diccionario que presentael IMSS. Usa año base 2018, y el an˜o final 2019 y 2024. Queremos saber la distribución de cambios enempleo y salario en ese periodo.
************************************************************************
/*

clear

******2018

use "$imss\IMSS_2018.dta",clear
drop if mes != 7
gen prom_men = (masa_sal_ta/ta_sal)*30
gen med_men = prom_men
merge n:1 fecha using	"$general\INPC\INPC.dta" 
rename ipc INPC 
drop _merge
gen factor_ingreso_real = 136.003/INPC
gen prom_ingreso_real = prom_men*factor_ingreso_real
gen mediana_ingreso_real = med_men*factor_ingreso_real
format %tm fecha
collapse (rawsum) ta_sal (mean) prom_ingreso_real (median)  mediana_ingreso_real [aw = ta_sal], by(cve_entidad cve_municipio)
drop if ta_sal<10000
rename ta_sal ta_18
rename prom_ingreso_real prom_18
rename  mediana_ingreso_real med_18
save "$output\inciso10\2018.dta", replace


******2019
use "$imss\IMSS_2019.dta",clear
drop if mes != 7
gen prom_men = (masa_sal_ta/ta_sal)*30
gen med_men = prom_men
merge n:1 fecha using	"$general\INPC\INPC.dta" 
rename ipc INPC 
drop _merge
gen factor_ingreso_real = 136.003/INPC
gen prom_ingreso_real = prom_men*factor_ingreso_real
gen mediana_ingreso_real = med_men*factor_ingreso_real
format %tm fecha
collapse (rawsum) ta_sal (mean) prom_ingreso_real (median)  mediana_ingreso_real [aw = ta_sal], by(cve_entidad cve_municipio)
drop if ta_sal<10000
rename ta_sal ta_19
rename prom_ingreso_real prom_19
rename  mediana_ingreso_real med_19
save "$output\inciso10\2019.dta", replace



******2024
use "$imss\IMSS_2024.dta",clear
drop if mes != 7
gen prom_men = (masa_sal_ta/ta_sal)*30
gen med_men = prom_men
merge n:1 fecha using	"$general\INPC\INPC.dta" 
rename ipc INPC 
drop _merge
gen factor_ingreso_real = 136.003/INPC
gen prom_ingreso_real = prom_men*factor_ingreso_real
gen mediana_ingreso_real = med_men*factor_ingreso_real
format %tm fecha
collapse (rawsum) ta_sal (mean) prom_ingreso_real (median)  mediana_ingreso_real [aw = ta_sal], by(cve_entidad cve_municipio)
drop if ta_sal<10000
rename ta_sal ta_24
rename prom_ingreso_real prom_24
rename  mediana_ingreso_real med_24
save "$output\inciso10\2024.dta", replace

use "$output\inciso10\2018.dta", clear

merge 1:1 cve_municipio using "$output\inciso10\2019.dta"
drop if _merge == 2
drop _merge
merge 1:1 cve_municipio using "$output\inciso10\2024.dta"
drop if _merge == 2
drop _merge

gen id = cve_entidad 
order id, before(cve_entidad)
sort id
drop cve_entidad

save "$output\inciso10\basefinal.dta", replace


*Salario promedio
gen prom_18_19 = ((prom_19/prom_18)-1)*100  
gen prom_18_24 = ((prom_24/prom_18) -1 ) *100 


*Salario mediana
gen med_18_19 = ((med_19/med_18)-1)*100 
gen med_18_24 = ((med_24/med_18) -1 ) *100 


*Trabajadores
gen ta_18_19 = ((ta_19/ta_18)-1)*100
gen ta_18_24 = ((ta_24/ta_18) -1 ) *100

format prom_18_19 %2.1f
format prom_18_24 %2.1f
format med_18_19 %2.1f
format med_18_24 %2.1f
format ta_18_19 %2.1f
format ta_18_24 %2.1f


sort id
save "$output\inciso10\imss10_final.dta", replace

******se continuo en R**********

*/

clear


**#Ejercicio 12:  CONTROL SINTE´TICO Efecto del programa de salario m´ınimo y reducci´on de IVA en la ZLFN a nivel entidad (programa empieza en 2019). Qu´edate con meses de enero 2015 a julio 2024. Realiza control sint´etico a nivel entidad. Es decir, tendr´as 1 observacio´n tratada que es la ZLFN (todos los municipios que la conforman), y 31 observaciones a nivel entidad federativa (realizar un collapse sum de empleo y de masa salarial y despu´es se calcula el promedio). Tendr´as por ejemplo Tamaulipas sin incluir la ZLFN como control potencial, BC no entra como control porque todos los municipios son parte de la ZLFN. Se pide: 1) Estimar control sint´etico para 10 modelos (los mejores en RMSPE), discute cu´al se eligi´o. 2) Estimar valor p de cada modelo para empleo y salario promedio. 3) Discutir similitudes o diferencias al artículo sobre efectos del salario mínimo en la ZLFN de Campos-Vazquez, Delgado y Rodas (2020). https://www.sciendo.com/article/10.2478/izajolp-2020-0012




*****NOTA: PARA CORRER LAS GRÁFICAS DE ESTE INCISO. SE CORREN POR SEPARADO EMPLEO Y SALARIOS. SE NECESITA CORRER LOS "grstyle" DE CADA UNO Y SOLO LA PARTE QUE SE MENCIONA.






***************Control sintetico empleo*****************************************


grstyle init
grstyle set plain, horizontal grid
grstyle set imesh, horizontal compact minor
grstyle set legend 12, nobox
grstyle set color hue, select(2) inten(.8)
grstyle set color hue, select(2) inten(.8): histogram


*--------------- Empleo
 use "$output\inciso12\p12_synth_empl.dta", clear
 
drop if cve_entidad ==. 
 
 *Se establece el ID y el tiempo
tset cve_entidad fecha

gen treatment=1 	if cve_entidad==33 & fecha>707
replace treatment=0 if treatment==.

global cambio 707

*+++++++  Modelos a usar +++++++++

*usando edades
local set_1_empl empl_age_1 empl_age_2 empl_age_3

*usando tamaño de empresas
local set_2_empl empl_firm_1 empl_firm_2 empl_firm_3

*usando sexo
local set_3_empl empl_sexo_1 empl_sexo_2

*usando sectores
local set_4_empl empl_sector0 empl_sector1 empl_sector3 empl_sector4 empl_sector5 empl_sector6 empl_sector7 empl_sector8 empl_sector9

*usando edades y sexo
local set_5_empl empl_age_1 empl_age_2 empl_age_3 empl_sexo_1 empl_sexo_2

*usando tamaños de empresas y sectores
local set_6_empl empl_firm_1 empl_firm_2 empl_firm_3 empl_sector0 empl_sector1 empl_sector3 empl_sector4 empl_sector5 empl_sector6 empl_sector7 empl_sector8 empl_sector9

*usando tamaños edades, sexo y tamaños de empresas
local set_7_empl empl_age_1 empl_age_2 empl_age_3 empl_sexo_1 empl_sexo_2 empl_firm_1 empl_firm_2 empl_firm_3

*usando edades, sexo y sectores
local set_8_empl empl_age_1 empl_age_2 empl_age_3 empl_sexo_1 empl_sexo_2 empl_sector0 empl_sector1 empl_sector3 empl_sector4 empl_sector5 empl_sector6 empl_sector7 empl_sector8 empl_sector9

*usando edades, sexo, tamaños de empresas y sectores
local set_9_empl empl_age_1 empl_age_2 empl_age_3 empl_sexo_1 empl_sexo_2  empl_firm_1 empl_firm_2 empl_firm_3 empl_sector0 empl_sector1 empl_sector3 empl_sector4 empl_sector5 empl_sector6 empl_sector7 empl_sector8 empl_sector9

*usando edades, tamaños de empresas y sectores
local set_10_empl empl_age_1 empl_age_2 empl_age_3 empl_firm_1 empl_firm_2 empl_firm_3 empl_sector0 empl_sector1 empl_sector3 empl_sector4 empl_sector5 empl_sector6 empl_sector7 empl_sector8 empl_sector9


****************************PARA LAS GRÁFICAS DE ESTE INCISO SOLO CORRER DESDE AQUI (TODO COMPLETO)*******************

forvalues i = 1/10 {
	display "Regresión con `set_`i'_empl'"
	
	*Modelo `i'
	di `set_`i'_empl'
	synth_runner empleados `set_`i'_empl', d(treatment) ci gen_vars synthsettings(nested)

	*Modificar para el modelo que queremos las graficas
	if `i' == 3{
		
		single_treatment_graphs, raw_options( title("Placebos, cambio en el empleo") xtitle("Año") ytitle("Salario mensual") note("Promedio. Elaboración propia con datos abiertos del IMSS.") subtitle("Grupo de control por Estado") xline($cambio) xlabel(,angle(45)))  effects_options(title("Diferencia entre placebos, empleo") xtitle("Año") ytitle("Empleos") note("Elaboración propia con datos abiertos del IMSS.") subtitle("Grupo de control por Estado") xline($cambio) xlabel(,angle(45))) do_color(teal%25) treated_name("ZLFN") donors_name("Otros Estados")
		
		effect_graphs, effect_options( title("Efecto en la ZLFN en el empleo") xtitle("Año") ytitle("Empleo") note("Elaboración propia con datos abiertos del IMSS.") subtitle("Grupo de control por Estado") xline($cambio) xlabel(,angle(45)) ) tc_options(title("Empleos ZLFN y control sintético") xtitle("Año") ytitle("Empleos") note("Elaboración propia con datos abiertos del IMSS.") subtitle("Grupo por Estado") xline($cambio) xlabel(,angle(45))) treated_name("ZLFN") sc_name("Control sintético")
		
		pval_graphs, pvals_options(title("Valores P" ) xtitle("Periodos postratamiento") ytitle("Valor P") subtitle("Grupo por Estado") xlabel(#10))  pvals_std_options( title("Valores P estandarizados") xtitle("Periodos postratamiento") ytitle("Valor P estandarizado") subtitle("Grupo de control por Estados") xlabel(#10) )
		
		*Exporto las graficas
		graph export "$output\inciso12\graphs\modelo_`i'_empl_raw.jpg",as(jpg) name("raw") quality(100) replace
		
		graph export "$output\inciso12\graphs\modelo_`i'_empl_effects.jpg", as(jpg) name("effects") quality(100) replace
		
		graph export "$output\inciso12\graphs\modelo_`i'_empl_effect.jpg", as(jpg) name("effect") quality(100) replace
		
		graph export "$output\inciso12\graphs\modelo_`i'_empl_tc.jpg", as(jpg) name("tc") quality(100) replace
		
		graph export "$output\inciso12\graphs\modelo_`i'_empl_pvals.jpg", as(jpg) name("pvals") quality(100) replace
		
		graph export "$output\inciso12\graphs\modelo_`i'_empl_pvals_std.jpg", as(jpg) name("pvals_std") quality(100) replace
		
		}
		
		
		*Exporto los resultados del control sintetico a Excel
		
		putexcel set "$output\inciso12\p_12_synth_empl_resultados", sheet(modelo_`i') modify
		
		matrix num		 	 =e(n_pl)
		matrix num_usados 	 =e(n_pl_used)
		matrix pval_joint	 =e(pval_joint_post) 
		matrix pval_joint_std=e(pval_joint_post_std)
		matrix avg_pre_rmspe =e(avg_pre_rmspe_p) 
		
		matrix b			 =e(b)
		matrix pvals_std	 =e(pvals_std)
		matrix ci			 =e(ci)
		matrix pvals		 =e(pvals)
		matrix treat_control =e(treat_control)
		
		putexcel B2			 =matrix(num)
		putexcel B3			 =matrix(num_usados)
		putexcel B4			 =matrix(pval_joint)
		putexcel B5			 =matrix(pval_joint_std)
		putexcel B6			 =matrix(avg_pre_rmspe)
		putexcel B15		 =matrix(b)
		putexcel B17 		 =matrix(pvals_std)
		putexcel B19	     =matrix(ci)
		putexcel B22		 =matrix(pvals)
		putexcel B24	   	 =matrix(treat_control)
		
		putexcel B1	="salario mensual"
		putexcel B8	="Estados"
		putexcel B7 ="$cambio "
		putexcel B9	="single unit"
		putexcel B11="synth_runner"
		putexcel B13="b"

		putexcel A2	="numero_placebos"
		putexcel A3 ="placebos_usados"
		putexcel A4	="pval_joint"
		putexcel A5 ="pval_joint_std"
		putexcel A6 ="avg_pre_rmspe"
		putexcel A7 ="trperiod"
		putexcel A8 ="trunit"
		putexcel A9 ="treat_type"
		putexcel A10="depvar"
		putexcel A1="cmd"
		putexcel A13="properties"
		putexcel A15="b"
		putexcel A17="pvals_std"
		putexcel A19="ci"
		putexcel A22="pvals"
		putexcel A24="treat_control"

		*Exporto un resumen de los resultados a un Excel 
		putexcel set "$output\inciso12\p_12_synth_empl_resumen" , sheet(modelo_`i') modify 
				
			local num_col = colsof(b) 
		*Operacion para sumar los efectos por periodo
			mata : st_matrix("mat1", rowsum(st_matrix("b")))
			local suma = mat1[1,1]					
		*Operacion para obtener el efecto promedio
			local prom = `=`suma'/`num_col''
			mat promedio = `prom' 
		*Matriz con el numero de periodo rezagado en el tratamiento 
		*Porcentaje del cambio en el salario
			sum empleados if t>$cambio & cve_entidad!=33
			local empleados_not = r(mean)
		*operacion para obtener el porcentaje de incremento en el ingreso
			local efec_per = `= `prom' / `empleados_not'  ' * 100
							
			mat efecto_per = `efec_per' 
							
							
		*Matriz con los resultados a exportar)
			mat tot = (num_usados, promedio, pval_joint_std, avg_pre_rmspe, efecto_per)
							
			putexcel A2 = mat(tot)  
			putexcel A1="Número de donantes empleados"
			putexcel B1="Efecto promedio"
			putexcel C1="Valor p conjunto, estandarizado"
			putexcel D1="RMSPE promedio"
							

		drop empleados_synth effect lead post_rmspe pre_rmspe
		
		}

*************************HASTA AQUI SE CORRE****************************










***************Control sintetico salario*****************************************
*******VOLVER A CORRER LOS grstyle y la base******************

grstyle init
grstyle set plain, horizontal grid
grstyle set imesh, horizontal compact minor
grstyle set legend 12, nobox
grstyle set color hue, select(2) inten(.8)
grstyle set color hue, select(2) inten(.8): histogram


*--------------- salario 
 use "$output\inciso12\p12_synth_sal.dta", clear
 
drop if cve_entidad ==. 
 
 *Se establece el ID y el tiempo
tset cve_entidad fecha

gen treatment=1 	if cve_entidad==33 & fecha>707
replace treatment=0 if treatment==.

global cambio 707


*+++++++  Modelos a usar +++++++++

*usando edades
local set_1_sal empl_age_sal1_r empl_age_sal2_r empl_age_sal3_r

*usando tamaño de empresas
local set_2_sal firm_sal1_r firm_sal2_r firm_sal3_r

*usando sexo
local set_3_sal sexo_sal1_r sexo_sal2_r

*usando sectores
local set_4_sal sector0_sal_r sector1_sal_r sector3_sal_r sector4_sal_r sector5_sal_r sector6_sal_r sector7_sal_r sector8_sal_r sector9_sal_r

*usando edades y sexo
local set_5_sal empl_age_sal1_r empl_age_sal2_r empl_age_sal3_r sexo_sal1_r sexo_sal2_r

*usando tamaños de empresas y sectores
local set_6_sal firm_sal1_r firm_sal2_r firm_sal3_r sector0_sal_r sector1_sal_r sector3_sal_r sector4_sal_r sector5_sal_r sector6_sal_r sector7_sal_r sector8_sal_r sector9_sal_r

*usando edades, sexo y tamaños de empresas
local set_7_sal empl_age_sal1_r empl_age_sal2_r empl_age_sal3_r sexo_sal1_r sexo_sal2_r firm_sal1_r firm_sal2_r firm_sal3_r

*usando edades, sexo y sectores
local set_8_sal empl_age_sal1_r empl_age_sal2_r empl_age_sal3_r sexo_sal1_r sexo_sal2_r sector0_sal_r sector1_sal_r sector3_sal_r sector4_sal_r sector5_sal_r sector6_sal_r sector7_sal_r sector8_sal_r sector9_sal_r

*usando edades, sexo, tamños de empresas y sectores
local set_9_sal empl_age_sal1_r empl_age_sal2_r empl_age_sal3_r sexo_sal1_r sexo_sal2_r firm_sal1_r firm_sal2_r firm_sal3_r sector0_sal_r sector1_sal_r sector3_sal_r sector4_sal_r sector5_sal_r sector6_sal_r sector7_sal_r sector8_sal_r sector9_sal_r

*usando edades, tamaños de empresas y sectores
local set_10_sal empl_age_sal1_r empl_age_sal2_r empl_age_sal3_r firm_sal1_r firm_sal2_r firm_sal3_r sector0_sal_r sector1_sal_r sector3_sal_r sector4_sal_r sector5_sal_r sector6_sal_r sector7_sal_r sector8_sal_r sector9_sal_r


****************************PARA LAS GRÁFICAS DE ESTE INCISO SOLO CORRER DESDE AQUI (TODO COMPLETO)*******************


forvalues i = 1/10 {
	
display "Regresión con `set_`i'_sal'"
	
	*Modelo `i'
di `set_`i'_sal'
synth_runner sal_prom_mens_r `set_`i'_sal', d(treatment) ci gen_vars synthsettings(nested)

	*Modificar para el modelo que queremos las graficas
	if `i' == 2{
		
	single_treatment_graphs, raw_options( title("Placebos, salario promedio") xtitle("Año") ytitle("Salario mensual") note("Promedio. Deflactado, base segunda quincena de 2018") subtitle("Grupo de control por Estado") xline($cambio) xlabel(,angle(45)))  effects_options(title("Diferencia entre placebos, salario promedio") xtitle("Año") ytitle("Salario mensual") note("Deflactado, base segunda quincena de 2018") subtitle("Grupo de control por Estado") xline($cambio) xlabel(,angle(45))) do_color(teal%25) treated_name("ZLFN") donors_name("Otros Estados")

	
	effect_graphs, effect_options( title("Efecto en la ZLFN, salario mensual") xtitle("Año") ytitle("Salario mensual") note("Deflactado, base segunda quincena de 2018") subtitle("Grupo de control por Estado") xline($cambio) xlabel(,angle(45)) ) tc_options(title("Salario mensual, ZLFN y control sintético") xtitle("Año") ytitle("Pesos diarios") note("Deflactado, base segunda quincena de 2018") subtitle("Grupo por Estado") xline($cambio) xlabel(,angle(45))) treated_name("ZLFN") sc_name("Control sintético") 


	pval_graphs, pvals_options(title("Valores P" ) xtitle("Periodos postratamiento") ytitle("Valor P") subtitle("Grupo por Estado") xlabel(#10))  pvals_std_options( title("Valores P estandarizados") xtitle("Periodos postratamiento") ytitle("Valor P estandarizado") subtitle("Grupo de control por Estados") xlabel(#10) )

*Exporto las graficas
graph export "$output\inciso12\graphs\modelo_`i'_sal_raw.jpg",as(jpg) name("raw") quality(100) replace

graph export "$output\inciso12\graphs\modelo_`i'_sal_effects.jpg", as(jpg) name("effects") quality(100) replace

graph export "$output\inciso12\graphs\modelo_`i'_sal_effect.jpg", as(jpg) name("effect") quality(100) replace

graph export "$output\inciso12\graphs\modelo_`i'_sal_tc.jpg", as(jpg) name("tc") quality(100) replace

graph export "$output\inciso12\graphs\modelo_`i'_sal_pvals.jpg", as(jpg) name("pvals") quality(100) replace

graph export "$output\inciso12\graphs\modelo_`i'_sal_pvals_std.jpg", as(jpg) name("pvals_std") quality(100) replace

	}


*Exporto los resultados del control sintetico a Excel
putexcel set "$output\inciso12\p_12_synth_sal_resultados", sheet(modelo_`i') modify

matrix num		 	 =e(n_pl)
matrix num_usados 	 =e(n_pl_used)
matrix pval_joint	 =e(pval_joint_post) 
matrix pval_joint_std=e(pval_joint_post_std)
matrix avg_pre_rmspe =e(avg_pre_rmspe_p) 

matrix b			 =e(b)
matrix pvals_std	 =e(pvals_std)
matrix ci			 =e(ci)
matrix pvals		 =e(pvals)
matrix treat_control =e(treat_control)

putexcel B2			 =matrix(num)
putexcel B3			 =matrix(num_usados)
putexcel B4			 =matrix(pval_joint)
putexcel B5			 =matrix(pval_joint_std)
putexcel B6			 =matrix(avg_pre_rmspe)
putexcel B15		 =matrix(b)
putexcel B17 		 =matrix(pvals_std)
putexcel B19	     =matrix(ci)
putexcel B22		 =matrix(pvals)
putexcel B24	   	 =matrix(treat_control)


putexcel B1	="salario mensual"
putexcel B8	="Estados"
putexcel B7 ="$cambio "
putexcel B9	="single unit"
putexcel B11="synth_runner"
putexcel B13="b"

putexcel A2	="numero_placebos"
putexcel A3 ="placebos_usados"
putexcel A4	="pval_joint"
putexcel A5 ="pval_joint_std"
putexcel A6 ="avg_pre_rmspe"
putexcel A7 ="trperiod"
putexcel A8 ="trunit"
putexcel A9 ="treat_type"
putexcel A10="depvar"
putexcel A1="cmd"
putexcel A13="properties"
putexcel A15="b"
putexcel A17="pvals_std"
putexcel A19="ci"
putexcel A22="pvals"
putexcel A24="treat_control"

*Exporto un resumen de los resultados a un Excel 
putexcel set "$output\inciso12\p_12_synth_sal_resumen" , sheet(modelo_`i') modify 
		
	local num_col = colsof(b) 
*Operacion para sumar los efectos por periodo
	mata : st_matrix("mat1", rowsum(st_matrix("b")))
	local suma = mat1[1,1]					
*Operacion para obtener el efecto promedio
	local prom = `=`suma'/`num_col''
	mat promedio = `prom' 
*Matriz con el numero de periodo rezagado en el tratamiento 
*Porcentaje del cambio en el salario
	sum sal_prom_mens_r if t>$cambio & cve_entidad!=33
	local sal_prom_not = r(mean)
*operacion para obtener el porcentaje de incremento en el ingreso
	local efec_per = `= `prom' / `sal_prom_not'  ' * 100
					
	mat efecto_per = `efec_per' 
					
					
*Matriz con los resultados a exportar)
	mat tot = (num_usados, promedio, pval_joint_std, avg_pre_rmspe, efecto_per)
					
	putexcel A2 = mat(tot)  
	putexcel A1="Número de donantes empleados"
	putexcel B1="Efecto promedio"
	putexcel C1="Valor p conjunto, estandarizado"
	putexcel D1="RMSPE promedio"
					

drop sal_prom_mens_r_synth effect lead post_rmspe pre_rmspe

}




******************HASTA AQUI SE CORRE*************************




