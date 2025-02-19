/*
Econometría Aplicada
Problem Set 2
Ejercicio 2
Max Brando Serna Leyva
2023-2025
*/

use "D:\Eco aplicada\Tarea 2\1\ENOE\ENOE_FINAL", clear

gl graphs "D:\Eco aplicada\Tarea 2\1\Gráficos\1\ENOE"
net install grc1leg,from( http://www.stata.com/users/vwiggins/)

**** 1.8 ****
gen ln_sal_hora = log(sal_hora)
destring year, replace

gen qdate = quarterly(trimestre, "YQ")  // Create quarterly date variable
format qdate %tq                      // Format it as a quarterly date

/*
preserve
drop if hrsocup==0
graph box ln_sal_hora, over(year, label(labsize(small) angle(45))) ///
    marker(1, msymbol(sh) msize(small) mcolor(navy%20)) ///
	bar(1, color(navy)) ///
    title("Logaritmo del Salario por Hora (2005-2024)", size(medium)) ///
    ytitle("Log-Salario por Hora", size(small)) ///
    caption("Elaboración propia con datos de la ENOE", size(small) span) ///
    graphregion(margin(0 0 0 0)) plotregion(margin(5 10 10 5))

graph export "D:\Eco aplicada\Tarea 2\1\Gráficos\1\ENOE\Log salario años.jpg", replace
restore
*/

************************************************************************************** 1.9 ****
/*
NOTA: Se crean variable "grupo" con valores del 1 al 9 dependiendo el grupo:
	Grupo 1: hombres-25 a 45años -menos de prepa
	Grupo 2: hombres-25 a 45años -mas o igual a prepa
	Grupo 3: hombres-46 a 65años -menos de prepa
	Grupo 4: hombres-46 a 65años -mas o igual a prepa
	Grupo 5: mujeres-25 a 45años -menos de prepa
	Grupo 6: mujeres-25 a 45años -mas o igual a prepa
	Grupo 7: mujeres-46 a 65años -menos de prepa
	Grupo 8: mujeres-46 a 65años -mas o igual a prepa
*/

generate grupo = 1 if (sex == 1) & (eda <= 45) & (cs_p13_1 <= 3 | cs_p13_1 == 99)
replace grupo = 2 if (sex == 1) & (eda <= 45) & (cs_p13_1 >=3 & cs_p13_1 <=9)
replace grupo = 3 if (sex == 1) & (eda >= 46) & (cs_p13_1 <= 3 | cs_p13_1 == 99)
replace grupo = 4 if (sex == 1) & (eda >= 46) & (cs_p13_1 >=3 & cs_p13_1 <=9)
replace grupo = 5 if (sex == 2) & (eda <= 45) & (cs_p13_1 <= 3 | cs_p13_1 == 99)
replace grupo = 6 if (sex == 2) & (eda <= 45) & (cs_p13_1 >=3 & cs_p13_1 <=9)
replace grupo = 7 if (sex == 2) & (eda >= 46) & (cs_p13_1 <= 3 | cs_p13_1 == 99)
replace grupo = 8 if (sex == 2) & (eda >= 46) & (cs_p13_1 >=3 & cs_p13_1 <=9)
 
label variable grupo "Grupo por edad, sexo y educación"
label define grupo_label 1 "Grupo 1" 2 "Grupo 2" 3 "Grupo 3" 4 "Grupo 4" ///
							5 "Grupo 5" 6 "Grupo 6" 7 "Grupo 7" 8 "Grupo 8"
label value grupo grupo_label

* eliminamos observaciones sin ingreso válido
rename trabajador valido
drop if valido==0


***** gráfica del ingreso medio por trimestre para toda la población
/*
preserve
collapse (mean) ingreso [aweight=fac_tri], by(qdate)
graph twoway connected ingreso qdate, ///
    msymbol(S) ///
    mcolor(black) msize(small) ///
    lcolor(gold) lwidth(thick) ///
    title("Evolución del salario mensual promedio", size(medium) justification(center) span) ///
    xtitle("", size(small)) ytitle("Pesos", size(small)) ///
	tlabel(2005q1(4)2024q2, angle(45) labsize(small))  ///
    ysize(20cm) xsize(40cm) ///
    caption("Elaboración propia con datos de la ENOE. Valores en pesos constantes de enero 2024", size(vsmall) span)
	
graph export "$graphs\Salario_mensual.jpg", replace
restore
*/

***** gráfica del ingreso medio por trimestre por grupos: educación
/*
preserve
collapse (mean) ingreso [aweight=fac_tri], by(qdate grupo)
   
* Plot 1: Group 1 vs Group 2

twoway (line ingreso qdate if grupo == 1, lpattern(solid)) ///
       (line ingreso qdate if grupo == 2, lpattern(shortdash)), ///
       tlabel(2005q1(4)2024q2, nolab)  ///
       title("Hombres: 25 a 45 años") ///
       ytitle("Pesos") ///
       xtitle("") ///
       legend(order(1 "Menos de prepa" 2 "Prepa o más") position(6) rows(1)) ///
	   nodraw
graph save "$graphs\plot1.jpg", replace

* Plot 2: Group 3 vs Group 4
twoway (line ingreso qdate if grupo == 3, lpattern(solid)) ///
       (line ingreso qdate if grupo == 4, lpattern(shortdash)), ///
       tlabel(2005q1(4)2024q2, nolab)  ///
       title("Hombres: 46 a 65 años") ///
	   ytitle("") ///
	   xtitle("") ///
       legend(off) ///
	   nodraw   
graph save "$graphs\plot2.jpg", replace

* Plot 3: Group 5 vs Group 6
twoway (line ingreso qdate if grupo == 5, lpattern(solid)) ///
       (line ingreso qdate if grupo == 6, lpattern(shortdash)), ///
       tlabel(2005q1(4)2024q2, angle(45) labsize(small))  ///
       title("Mujeres: 25 a 45 años") ///
       xtitle("") ytitle("Pesos") ///
       legend(off) ///
	   nodraw
graph save "$graphs\plot3.jpg", replace

* Plot 4: Group 7 vs Group 8
twoway (line ingreso qdate if grupo == 7, lpattern(solid)) ///
       (line ingreso qdate if grupo == 8, lpattern(shortdash)), ///
       tlabel(2005q1(4)2024q2, angle(45) labsize(small))  ///
       title("Mujeres: 46 a 65 años") ///
       xtitle("") ///
	   ytitle("") ///
       legend(off) ///
	   nodraw
graph save "$graphs\plot4.jpg", replace
	   
grc1leg "$graphs\plot1.jpg" "$graphs\plot2.jpg" "$graphs\plot3.jpg" "$graphs\plot4.jpg", ///
       col(2) ///
	   row(2) ///
	   iscale(0.5) ///
	   xcommon ///
	   title("Salario mensual promedio por sexo, grupo educativo y etario", size(small)) ///
	   subtitle("Comparación entre grupos educativos", margin(b=3) size(small)) ///
	   imargin(vsmall) ///
	   legendfrom("$graphs\plot1.jpg") ///
	   caption("Elaboración propia con datos de la ENOE. Valores en pesos constantes de enero 2024", ///
	   size(vsmall) span)

graph display , ysize(65cm) xsize(80cm)
graph export "$graphs\Salario_mensual_grupos.jpg", replace
restore
*/
*****
*****
***** gráfica del ingreso medio por trimestre por grupos: sexo
*****
*****
/*
preserve
collapse (mean) ingreso [aweight=fac_tri], by(qdate grupo)
   
twoway (line ingreso qdate if grupo == 1, lpattern(solid)) ///
       (line ingreso qdate if grupo == 5, lpattern(shortdash)), ///
       tlabel(2005q1(4)2024q2, nolab)  ///
       title("Menos de prepa: 25 a 45 años") ///
       ytitle("Pesos") ///
	   xtitle("") ///
       legend(order(1 "Hombres" 2 "Mujeres") position(6) rows(1)) ///
	   nodraw
graph save "$graphs\plot1.jpg", replace

twoway (line ingreso qdate if grupo == 2, lpattern(solid)) ///
       (line ingreso qdate if grupo == 6, lpattern(shortdash)), ///
       tlabel(2005q1(4)2024q2, nolab)  ///
       title("Prepa o más: 25 a 45 años") ///
	   ytitle("") ///
	   xtitle("") ///
       legend(off) ///
	   nodraw   
graph save "$graphs\plot2.jpg", replace

twoway (line ingreso qdate if grupo == 3, lpattern(solid)) ///
       (line ingreso qdate if grupo == 7, lpattern(shortdash)), ///
       tlabel(2005q1(4)2024q2, angle(45) labsize(small))  ///
       title("Menos de prepa: 46 a 65 años") ///
       xtitle("") ytitle("Pesos") ///
       legend(off) ///
	   nodraw
graph save "$graphs\plot3.jpg", replace

* Plot 4: Group 7 vs Group 8
twoway (line ingreso qdate if grupo == 4, lpattern(solid)) ///
       (line ingreso qdate if grupo == 8, lpattern(shortdash)), ///
       tlabel(2005q1(4)2024q2, angle(45) labsize(small))  ///
       title("Prepa o más: 46 a 65 años") ///
       xtitle("") ///
	   ytitle("") ///
       legend(off) ///
	   nodraw
graph save "$graphs\plot4.jpg", replace
	   
grc1leg "$graphs\plot1.jpg" "$graphs\plot2.jpg" "$graphs\plot3.jpg" "$graphs\plot4.jpg", ///
       col(2) ///
	   row(2) ///
	   iscale(0.5) ///
	   xcommon ///
	   title("Salario mensual promedio por sexo, grupo educativo y etario", size(small)) ///
	   subtitle("Comparación entre sexos", margin(b=3) size(small)) ///
	   imargin(vsmall) ///
	   legendfrom("$graphs\plot1.jpg") ///
	   caption("Elaboración propia con datos de la ENOE. Valores en pesos constantes de enero 2024", ///
	   size(vsmall) span)
	   
graph display , ysize(65cm) xsize(80cm)
graph export "$graphs\Salario_mensual_sexo.jpg", replace
restore
*/


***** gráfica del salario por hora medio
/*
preserve
drop if hrsocup==0
collapse (mean) sal_hora [aweight=fac_tri], by(qdate)
graph twoway connected sal_hora qdate, ///
    msymbol(S) ///
    mcolor(black) msize(small) ///
    lcolor(midblue) lwidth(thick) ///
    title("Evolución del salario por hora promedio", size(medium) justification(center) span) ///
    xtitle("", size(small)) ytitle("Pesos", size(small)) ///
	tlabel(2005q1(4)2024q2, angle(45) labsize(small))  ///
    ysize(20cm) xsize(40cm) ///
    caption("Elaboración propia con datos de la ENOE. Valores en pesos constantes de enero 2024", size(vsmall) span)
	
graph export "$graphs\Salario_x_hora.jpg", replace
restore
*/

***** gráfica del salario por hora por trimestre por grupos: educación
/*
preserve
drop if hrsocup==0
collapse (mean) sal_hora [aweight=fac_tri], by(qdate grupo)
   
* Plot 1: Group 1 vs Group 2

twoway (line sal_hora qdate if grupo == 1, lpattern(solid)) ///
       (line sal_hora qdate if grupo == 2, lpattern(shortdash)), ///
       tlabel(2005q1(4)2024q2, nolab)  ///
       title("Hombres: 25 a 45 años") ///
       ytitle("Pesos") ///
       xtitle("") ///
       legend(order(1 "Menos de prepa" 2 "Prepa o más") position(6) rows(1)) ///
	   nodraw
graph save "$graphs\plot1.jpg", replace

* Plot 2: Group 3 vs Group 4
twoway (line sal_hora qdate if grupo == 3, lpattern(solid)) ///
       (line sal_hora qdate if grupo == 4, lpattern(shortdash)), ///
       tlabel(2005q1(4)2024q2, nolab)  ///
       title("Hombres: 46 a 65 años") ///
	   ytitle("") ///
	   xtitle("") ///
       legend(off) ///
	   nodraw   
graph save "$graphs\plot2.jpg", replace

* Plot 3: Group 5 vs Group 6
twoway (line sal_hora qdate if grupo == 5, lpattern(solid)) ///
       (line sal_hora qdate if grupo == 6, lpattern(shortdash)), ///
       tlabel(2005q1(4)2024q2, angle(45) labsize(small))  ///
       title("Mujeres: 25 a 45 años") ///
       xtitle("") ytitle("Pesos") ///
       legend(off) ///
	   nodraw
graph save "$graphs\plot3.jpg", replace

* Plot 4: Group 7 vs Group 8
twoway (line sal_hora qdate if grupo == 7, lpattern(solid)) ///
       (line sal_hora qdate if grupo == 8, lpattern(shortdash)), ///
       tlabel(2005q1(4)2024q2, angle(45) labsize(small))  ///
       title("Mujeres: 46 a 65 años") ///
       xtitle("") ///
	   ytitle("") ///
       legend(off) ///
	   nodraw
graph save "$graphs\plot4.jpg", replace
	   
grc1leg "$graphs\plot1.jpg" "$graphs\plot2.jpg" "$graphs\plot3.jpg" "$graphs\plot4.jpg", ///
       col(2) ///
	   row(2) ///
	   iscale(0.5) ///
	   xcommon ///
	   title("Salario por hora medio por sexo, grupo educativo y etario", size(small)) ///
	   subtitle("Comparación entre grupos educativos", margin(b=3) size(small)) ///
	   imargin(vsmall) ///
	   legendfrom("$graphs\plot1.jpg") ///
	   caption("Elaboración propia con datos de la ENOE. Valores en pesos constantes de enero 2024", ///
	   size(vsmall) span)
	   
graph display , ysize(65cm) xsize(80cm)
graph export "$graphs\Salario_x_hora_grupos.jpg", replace

restore
*/

***** gráfica del salario por hora medio por grupos: sexo
*****
*****
/*
preserve
drop if hrsocup==0
collapse (mean) sal_hora [aweight=fac_tri], by(qdate grupo)
   
twoway (line sal_hora qdate if grupo == 1, lpattern(solid)) ///
       (line sal_hora qdate if grupo == 5, lpattern(shortdash)), ///
       tlabel(2005q1(4)2024q2, nolab)  ///
       title("Menos de prepa: 25 a 45 años") ///
       ytitle("Pesos") ///
	   xtitle("") ///
       legend(order(1 "Hombres" 2 "Mujeres") position(6) rows(1)) ///
	   nodraw
graph save "$graphs\plot1.jpg", replace

twoway (line sal_hora qdate if grupo == 2, lpattern(solid)) ///
       (line sal_hora qdate if grupo == 6, lpattern(shortdash)), ///
       tlabel(2005q1(4)2024q2, nolab)  ///
       title("Prepa o más: 25 a 45 años") ///
	   ytitle("") ///
	   xtitle("") ///
       legend(off) ///
	   nodraw   
graph save "$graphs\plot2.jpg", replace

twoway (line sal_hora qdate if grupo == 3, lpattern(solid)) ///
       (line sal_hora qdate if grupo == 7, lpattern(shortdash)), ///
       tlabel(2005q1(4)2024q2, angle(45) labsize(small))  ///
       title("Menos de prepa: 46 a 65 años") ///
       xtitle("") ytitle("Pesos") ///
       legend(off) ///
	   nodraw
graph save "$graphs\plot3.jpg", replace

* Plot 4: Group 7 vs Group 8
twoway (line sal_hora qdate if grupo == 4, lpattern(solid)) ///
       (line sal_hora qdate if grupo == 8, lpattern(shortdash)), ///
       tlabel(2005q1(4)2024q2, angle(45) labsize(small))  ///
       title("Prepa o más: 46 a 65 años") ///
       xtitle("") ///
	   ytitle("") ///
       legend(off) ///
	   nodraw
graph save "$graphs\plot4.jpg", replace
	   
grc1leg "$graphs\plot1.jpg" "$graphs\plot2.jpg" "$graphs\plot3.jpg" "$graphs\plot4.jpg", ///
       col(2) ///
	   row(2) ///
	   iscale(0.5) ///
	   xcommon ///
	   title("Salario por hora medio por sexo, grupo educativo y etario", size(small)) ///
	   subtitle("Comparación entre sexos", margin(b=3) size(small)) ///
	   imargin(vsmall) ///
	   legendfrom("$graphs\plot1.jpg") ///
	   caption("Elaboración propia con datos de la ENOE. Valores en pesos constantes de enero 2024", ///
	   size(vsmall) span)
	   
graph display , ysize(65cm) xsize(80cm)
graph export "$graphs\Salario_x_hora_sexo.jpg", replace
restore
*/

******* tabla de ingresos por año

/*
collect clear
table year grupo [aweight=fac_tri], stat(mean ingreso)

// Adjust column widths (for better table fitting)
collect style cell, nformat(%9.0fc) // Adjust this format as needed

// Export to LaTeX
collect export "D:\Eco aplicada\Tarea 2\1\Tablas\Ingreso_por_grupo.tex", as(tex) replace

******* tabla de salario por hora por año
collect clear
table year grupo [aweight=fac_tri] if hrsocup>0, stat(mean sal_hora)

// Adjust column widths (for better table fitting)
collect style cell, nformat(%9.0fc) // Adjust this format as needed

// Export to LaTeX
collect export "D:\Eco aplicada\Tarea 2\1\Tablas\SalxHora_por_grupo.tex", as(tex) replace
*/


************************************************************************************** 1.10 ****
gen trabajador = 0
replace trabajador = 1 if valido==1 & hrsocup>0


** tabla de participación laboral
collect clear
table year grupo [aweight=fac_tri], stat(mean trabajador)

// Adjust column widths (for better table fitting)
collect style cell, nformat(%9.2fc) // Adjust this format as needed

// Export to LaTeX
collect export "D:\Eco aplicada\Tarea 2\1\Tablas\PL_por_grupo.tex", as(tex) replace
*/


/*
preserve
expand 2, generate(duplicado)
replace grupo = 9 if duplicado==1
* Modify the existing label definition to include the new value
label define grupo_label 1 "Grupo 1" 2 "Grupo 2" 3 "Grupo 3" 4 "Grupo 4" ///
                         5 "Grupo 5" 6 "Grupo 6" 7 "Grupo 7" 8 "Grupo 8" ///
                         9 "Total", modify

* Apply the updated label set to the variable (if not already applied)
label value grupo grupo_label
collapse (mean) trabajador [aweight=fac_tri], by(year grupo)
   
* Plot 1: Group 1 vs Group 2

twoway (line trabajador year if grupo == 1, lpattern(solid)) ///
       (line trabajador year if grupo == 2, lpattern(shortdash)) ///
       (line trabajador year if grupo == 9, lcolor(green)), ///	   
       xlabel(2005(1)2024, nolab)  ///
       title("Hombres: 25 a 45 años") ///
       ytitle("Porcentaje") ///
       xtitle("") ///
       legend(order(1 "Menos de prepa" 2 "Prepa o más" 3 "Nacional") position(6) rows(1)) ///
	   nodraw
graph save "$graphs\plot1.jpg", replace

* Plot 2: Group 3 vs Group 4
twoway (line trabajador year if grupo == 3, lpattern(solid)) ///
       (line trabajador year if grupo == 4, lpattern(shortdash)) ///
       (line trabajador year if grupo == 9, lcolor(green)), ///	   
       xlabel(2005(1)2024, nolab)  ///
       title("Hombres: 46 a 65 años") ///
	   ytitle("") ///
	   xtitle("") ///
       legend(off) ///
	   nodraw   
graph save "$graphs\plot2.jpg", replace

* Plot 3: Group 5 vs Group 6
twoway (line trabajador year if grupo == 5, lpattern(solid)) ///
       (line trabajador year if grupo == 6, lpattern(shortdash)) ///
       (line trabajador year if grupo == 9, lcolor(green)), ///	   	   
       xlabel(2005(1)2024, angle(45) labsize(small))  ///
       title("Mujeres: 25 a 45 años") ///
       xtitle("") ytitle("Porcentaje") ///
       legend(off) ///
	   nodraw
graph save "$graphs\plot3.jpg", replace

* Plot 4: Group 7 vs Group 8
twoway (line trabajador year if grupo == 7, lpattern(solid)) ///
       (line trabajador year if grupo == 8, lpattern(shortdash)) ///
       (line trabajador year if grupo == 9, lcolor(green)), ///	   
       xlabel(2005(1)2024, angle(45) labsize(small))  ///
       title("Mujeres: 46 a 65 años") ///
       xtitle("") ///
	   ytitle("") ///
       legend(off) ///
	   nodraw
graph save "$graphs\plot4.jpg", replace
	   
grc1leg "$graphs\plot1.jpg" "$graphs\plot2.jpg" "$graphs\plot3.jpg" "$graphs\plot4.jpg", ///
       col(2) ///
	   row(2) ///
	   iscale(0.5) ///
	   xcommon ///
	   title("Participación laboral por sexo, grupo educativo y etario", size(small)) ///
	   subtitle("Comparación entre grupos educativos", margin(b=3) size(small)) ///
	   imargin(vsmall) ///
	   legendfrom("$graphs\plot1.jpg") ///
	   caption("Elaboración propia con datos de la ENOE.", ///
	   size(vsmall) span)
	   
graph display , ysize(65cm) xsize(80cm)
graph export "$graphs\PL_grupos.jpg", replace

restore
*/

/*
preserve
expand 2, generate(duplicado)
replace grupo = 9 if duplicado==1
* Modify the existing label definition to include the new value
label define grupo_label 1 "Grupo 1" 2 "Grupo 2" 3 "Grupo 3" 4 "Grupo 4" ///
                         5 "Grupo 5" 6 "Grupo 6" 7 "Grupo 7" 8 "Grupo 8" ///
                         9 "Total", modify

* Apply the updated label set to the variable (if not already applied)
label value grupo grupo_label
collapse (mean) trabajador [aweight=fac_tri], by(year grupo)
   
* Plot 1: Group 1 vs Group 2

twoway (line trabajador year if grupo == 1, lpattern(solid)) ///
       (line trabajador year if grupo == 5, lpattern(shortdash)) ///
       (line trabajador year if grupo == 9, lcolor(green)), ///	   
       xlabel(2005(1)2024, nolab)  ///
       title("Menos de prepa: 25 a 45 años") ///
       ytitle("Porcentaje") ///
       xtitle("") ///
       legend(order(1 "Hombres" 2 "Mujeres" 3 "Nacional") position(6) rows(1)) ///
	   nodraw
graph save "$graphs\plot1.jpg", replace

* Plot 2: Group 3 vs Group 4
twoway (line trabajador year if grupo == 2, lpattern(solid)) ///
       (line trabajador year if grupo == 6, lpattern(shortdash)) ///
       (line trabajador year if grupo == 9, lcolor(green)), ///	   
       xlabel(2005(1)2024, nolab)  ///
       title("Prepa o más: 25 a 45 años") ///
	   ytitle("") ///
	   xtitle("") ///
       legend(off) ///
	   nodraw   
graph save "$graphs\plot2.jpg", replace

* Plot 3: Group 5 vs Group 6
twoway (line trabajador year if grupo == 3, lpattern(solid)) ///
       (line trabajador year if grupo == 7, lpattern(shortdash)) ///
       (line trabajador year if grupo == 9, lcolor(green)), ///	   	   
       xlabel(2005(1)2024, angle(45) labsize(small))  ///
       title("Menos de prepa: 46 a 65 años") ///
       xtitle("") ytitle("Porcentaje") ///
       legend(off) ///
	   nodraw
graph save "$graphs\plot3.jpg", replace

* Plot 4: Group 7 vs Group 8
twoway (line trabajador year if grupo == 4, lpattern(solid)) ///
       (line trabajador year if grupo == 8, lpattern(shortdash)) ///
       (line trabajador year if grupo == 9, lcolor(green)), ///	   
       xlabel(2005(1)2024, angle(45) labsize(small))  ///
       title("Prepa o más: 46 a 65 años") ///
       xtitle("") ///
	   ytitle("") ///
       legend(off) ///
	   nodraw
graph save "$graphs\plot4.jpg", replace
	   
grc1leg "$graphs\plot1.jpg" "$graphs\plot2.jpg" "$graphs\plot3.jpg" "$graphs\plot4.jpg", ///
       col(2) ///
	   row(2) ///
	   iscale(0.5) ///
	   xcommon ///
	   title("Participación laboral por sexo, grupo educativo y etario", size(small)) ///
	   subtitle("Comparación entre sexos", margin(b=3) size(small)) ///
	   imargin(vsmall) ///
	   legendfrom("$graphs\plot1.jpg") ///
	   caption("Elaboración propia con datos de la ENOE.", ///
	   size(vsmall) span)
	   
graph display , ysize(65cm) xsize(80cm)
graph export "$graphs\PL_grupos_sexo.jpg", replace

restore
*/

*tabulate year grupo [aweight=fac_tri], summarize(trabajador) means

