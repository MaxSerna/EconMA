/*
Econometría Aplicada
Problem Set 2
Ejercicio 6
Max Brando Serna Leyva
2023-2025
*/

gl general = "D:\Eco aplicada\Tarea 2\6"

***************************
gl datos = "$general\Datos"
gl Union = "$datos\Union"
gl coe2 = "$datos\coe2-1" 
gl enoe = "$datos\sdem1"
gl temp = "$datos\temp" 
gl resultados  = "$general\Gráficas" 


gl log  = "$temp"

/*** 2. Para la ENOE 2005-2023, cómo cambia el % de trabajadores que no reportan ingresos (pero sí son
trabajadores)? Realiza análisis por grupo: para formales vs informales; grupo educación; sexo; etc.
¿El cambio en el no reporte podrías considerarlo aleatorio, explica? ¿Cuántos o % no contestan la
pregunta de ingreso pero sí contestan la pregunta de rangos de SM? ¿Cómo esa % ha cambiado en
el tiempo del total que no contesta la pregunta?
***/
/*
//Primero cargo la misma base de la ENOE
use "$Union\ENOE_FINAL.dta", clear

/*Moviendo algunas variables para crear las variables de:
foliop y folioh
*/
gen foliop = cd_a
	foreach i in ent con v_sel tipo mes_cal ca n_hog h_mud n_ren {
	capture confirm variable `i' 
    if !_rc replace foliop = foliop + `i' 
	}

	
gen folioh = cd_a
	foreach i in ent con v_sel tipo mes_cal ca n_hog h_mud {
	capture confirm variable `i'
    if !_rc replace folioh = folioh + `i'
	}
	

*Se utilizarán las respuestas completas
keep if r_def=="00"
*Condicion de residencia: Sólo residentes definitivos o nuevos
keep if c_res==1 | c_res==3
label variable year "Año"

*Generamos los grupos que necesitamos: para formales vs informales; grupo educación; sexo
*Grupo de formales vs informales:
gen formal=.
replace formal=1 if imssissste==1 |imssissste==2 | imssissste==3
replace formal=0 if imssissste==4

*Grupo educación:
generate niv_educ=.
replace niv_educ=0 if cs_p13_1==0 | cs_p13_1==1
replace niv_educ=1 if cs_p13_1==2
replace niv_educ=2 if cs_p13_1==3
replace niv_educ=3 if cs_p13_1==4 | cs_p13_1==5 | cs_p13_1==6
replace niv_educ=4 if cs_p13_1==7
replace niv_educ=5 if cs_p13_1==8 | cs_p13_1==9

label define a 0 "Sin instrucción" 1 "Primaria" 2 "Secundaria" 3 "Media Superior" 4 "Superior" 5 "Posgrado", replace
label values niv_educ a
label var niv_educ "Nivel educativo"

*Grupo sexo: (Con la variable sex es suficiente)

*Grupo de personas que viven en localidades urbanas o rurales:
gen rural=0
replace rural=1 if t_loc==4
replace rural=. if t_loc==.
label variable rural "Tipo de localidad"
label define b 1 "Rural" 0 "Urbano", replace
label values rural b

*Grupos de edad:
gen edad=1 if eda>=14 &eda<=20
replace edad=2 if eda>=21 & eda<=35
replace edad=3 if eda>=36 & eda<=50
replace edad=4 if eda>=51

label define c 1 "14 a 20 años" 2 "21 a 35 años" 3 "36 a 50 años" 4 "51 años o más", replace
label values edad c
label var edad "Grupos de edad"

*Limpio para personas que trabajan
replace ingocup=. if ingocup==999999 | ingocup==999998 | ingocup==0
keep if eda>=14
keep if clase2==1
keep if hrsocup>0 & hrsocup<=168
drop if pos_ocu==4 | pos_ocu==5 | pos_ocu==. | ing7c==6

*Personas que reciben un ingreso inválido
gen ing_inv=0
replace ing_inv=1 if ingocup==.

label define d 0 "Ingreso válido" 1 "Ingreso inválido", replace
label values ing_inv d
label var ing_inv "Clasificación"

*Personas que reportan rango de salario mínimo
gen sal_min=.
replace sal_min=0 if ing7c==7
replace sal_min=1 if ing7c>=1 & ing7c<=6

label define salmin 0 "No" 1 "Sí", replace
label values sal_min salmin
label var sal_min "Reporta rango de salario mínimo"

*Personas con ingreso inválido pero con rango de salario mínimo
gen inv_RM=0
replace inv_RM=1 if ing_inv==1 & sal_min==1

replace trimestre = subinstr(trimestre, "T", "q", .)
gen tqtrimestre = quarterly(trimestre, "Yq")
format tqtrimestre %tq

save "$Union\ENOE_con_grupos.dta", replace
*/
///Ahora voy a hacer gráficas de los comparativos, 
///primero el porcentaje de personas que reportan o no ingresos a lo largo del tiempo
///Además, haré un comparativo similar para cada uno de los grupos creados

use "$Union\ENOE_con_grupos.dta", clear

preserve
collapse (mean) ing_inv [aweight = fac_tri], by(tqtrimestre)
replace ing_inv=ing_inv*100
twoway (line ing_inv tqtrimestre, lcolor(blue) lwidth(thick)), ///
	title(Porcentaje de trabajadores que no reportan ingresos válidos) ///
	xtitle("") ///
	ytitle(Porcentaje) ///
	tlabel(2005q1(4)2024q2, angle(45)) ///
	ylabel(9(4)34) ///
	caption("Fuente: Elaboración propia con datos la ENOE", size(medium)) ///
	ysize(30cm) xsize(40cm) ///
	scale(0.7) ///
	scheme(stcolor) ///
	graphregion(color(white)) ///
    plotregion(fcolor(white)) ///
	bgcolor(white)
graph export "$resultados\graf_ing_inv_t.png", replace
restore

*Para el grupo de formalidad
preserve
collapse (mean) ing_inv [aweight = fac_tri], by(tqtrimestre formal)
drop if formal == .
reshape wide ing_inv, i(tqtrimestre) j(formal)

foreach i in 0 1{
	replace ing_inv`i'=ing_inv`i'*100
}
label var ing_inv0 "Informal" 
label var ing_inv1 "Formal"

twoway (line ing_inv0 tqtrimestre, lpattern(solid) lw(thick)) ///
	   (line ing_inv1 tqtrimestre, lpattern(shortdash) lw(thick)), ///
	   title("Según condición de formalidad en el empleo") ///
	   xtitle("") ///
	   ytitle(Porcentaje) ///
	   tlabel(2005q1(4)2024q2, angle(45)) ///
	   ylabel(8(4)40) ///
	   caption("Fuente: Elaboración propia con datos la ENOE", size(medium)) ///
	   legend(position(6) rows(1)) ///
	   ysize(30cm) xsize(40cm) ///
	   scale(0.7) ///
	   scheme(stcolor) ///
	   graphregion(color(white)) ///
	   plotregion(fcolor(white)) ///
	   bgcolor(white)
graph export "$resultados\graf_ing_inv_formalidad.png", replace
restore

*Para el grupo de educación
preserve
collapse (mean) ing_inv [aweight = fac_tri], by(tqtrimestre niv_educ)
drop if niv_educ == .
reshape wide ing_inv, i(tqtrimestre) j(niv_educ)

foreach i in 0 1 2 3 4 5{
	replace ing_inv`i'=ing_inv`i'*100
}
label var ing_inv0 "Sin instrucción" 
label var ing_inv1 "Primaria"
label var ing_inv2 "Secundaria"
label var ing_inv3 "Media Superior"
label var ing_inv4 "Superior"
label var ing_inv5 "Posgrado"

twoway (line ing_inv0 tqtrimestre, lpattern(solid) lw(medthick)) ///   // Solid line
       (line ing_inv1 tqtrimestre, lpattern(dash) lw(medthick)) ///    // Dashed line
       (line ing_inv2 tqtrimestre, lpattern(dot) lwidth(thick)) ///     // Dotted line
       (line ing_inv3 tqtrimestre, lpattern(longdash) lw(medthick)) /// // Long dashed line
       (line ing_inv4 tqtrimestre, lpattern(dash_dot) lw(medthick)) /// // Dash-dot line
       (line ing_inv5 tqtrimestre, lpattern(shortdash) lw(medthick)), /// // Dot-dash line
	   title("Según nivel educativo") ///
       xtitle("") ///
       ytitle(Porcentaje) ///
       tlabel(2005q1(4)2024q2, angle(45)) ///
       caption("Fuente: Elaboración propia con datos la ENOE", size(medium)) ///
       legend(position(6) rows(2)) ///
	   ylabel(5(5)60) ///
       ysize(30cm) xsize(40cm) ///
       scale(0.7) ///
       scheme(stcolor) ///
       graphregion(color(white)) ///
       plotregion(fcolor(white)) ///
       bgcolor(white)
graph export "$resultados\graf_ing_inv_educacion.png", replace
restore

*Para el grupo de edad
preserve
collapse (mean) ing_inv [aweight = fac_tri], by(tqtrimestre edad)
drop if edad == .
reshape wide ing_inv, i(tqtrimestre) j(edad)

foreach i in 1 2 3 4{
	replace ing_inv`i'=ing_inv`i'*100
}
label var ing_inv1 "14 a 20 años" 
label var ing_inv2 "21 a 35 años"
label var ing_inv3 "36 a 50 años"
label var ing_inv4 "51 años o más"

twoway (line ing_inv1 tqtrimestre, lpattern(solid) lw(medthick)) ///   // Solid line
       (line ing_inv2 tqtrimestre, lpattern(shortdash) lw(medthick)) ///    // Dashed line
       (line ing_inv3 tqtrimestre, lpattern(dot) lwidth(thick)) ///     // Dotted line
       (line ing_inv4 tqtrimestre, lpattern(longdash) lw(medthick)), /// // Long dashed line
	   title("Según su rango de edad") ///
	   xtitle("") ///
       ytitle(Porcentaje) ///
       tlabel(2005q1(4)2024q2, angle(45)) ///
       caption("Fuente: Elaboración propia con datos la ENOE", size(medium)) ///
       legend(position(6) rows(1)) ///
	   ylabel(5(5)35) ///
       ysize(30cm) xsize(40cm) ///
       scale(0.7) ///
       scheme(stcolor) ///
       graphregion(color(white)) ///
       plotregion(fcolor(white)) ///
       bgcolor(white)
graph export "$resultados\graf_ing_inv_edad.png", replace
restore

*Para el grupo de rural-urbano
preserve
collapse (mean) ing_inv [aweight = fac_tri], by(tqtrimestre rural)
drop if rural == .
reshape wide ing_inv, i(tqtrimestre) j(rural)

foreach i in 0 1{
	replace ing_inv`i'=ing_inv`i'*100
}
label var ing_inv0 "Urbano" 
label var ing_inv1 "Rural"

twoway (line ing_inv0 tqtrimestre, lpattern(solid) lw(thick) lc(green)) ///
	   (line ing_inv1 tqtrimestre, lpattern(shortdash) lw(thick) lc(orange)), ///
	   title("Según si habitan en zona rural o urbana") ///
	   xtitle("") ///
       ytitle(Porcentaje) ///
       tlabel(2005q1(4)2024q2, angle(45)) ///
       caption("Fuente: Elaboración propia con datos la ENOE", size(medium)) ///
       legend(position(6) rows(1)) ///
	   ylabel(5(5)35) ///
       ysize(30cm) xsize(40cm) ///
       scale(0.7) ///
       scheme(stcolor) ///
       graphregion(color(white)) ///
       plotregion(fcolor(white)) ///
       bgcolor(white)
graph export "$resultados\graf_ing_inv_rural.png", replace
restore

*No contestan la pregunta de ingreso por sexo
preserve
collapse (mean) ing_inv [aweight = fac_tri], by(tqtrimestre sex)
drop if sex == .
reshape wide ing_inv, i(tqtrimestre) j(sex)

foreach i in 1 2 {
	replace ing_inv`i'=ing_inv`i'*100
}
label var ing_inv1 "Hombres" 
label var ing_inv2 "Mujeres"

twoway (line ing_inv1 tqtrimestre, lpattern(solid) lw(thick) lc(sienna)) ///
	   (line ing_inv2 tqtrimestre, lpattern(shortdash) lw(thick) lc(ebblue)), ///
	   title("Según sexo") ///
	   xtitle("") ///
       ytitle(Porcentaje) ///
       tlabel(2005q1(4)2024q2, angle(45)) ///
       caption("Fuente: Elaboración propia con datos la ENOE", size(medium)) ///
       legend(position(6) rows(1)) ///
	   ylabel(5(5)35) ///
       ysize(30cm) xsize(40cm) ///
       scale(0.7) ///
       scheme(stcolor) ///
       graphregion(color(white)) ///
       plotregion(fcolor(white)) ///
       bgcolor(white)
graph export "$resultados\graf_ing_inv_sexo.png", replace
restore

* Personas con ingresos inválidos pero con rango de salarios mínimos
preserve
collapse (mean) inv_RM [aweight = fac_tri], by(tqtrimestre)
replace inv_RM=inv_RM*100
twoway (line inv_RM tqtrimestre, lcolor(red) lwidth(thick)), ///
	title(Porcentaje de trabajadores con ingresos inválidos que sí reportan RM) ///
	xtitle("") ///
	ytitle(Porcentaje) ///
	tlabel(2005q1(4)2024q2, angle(45)) ///
	ylabel(4(1)19) ///
	caption("Fuente: Elaboración propia con datos la ENOE", size(medium)) ///
	ysize(30cm) xsize(40cm) ///
	scale(0.7) ///
	scheme(stcolor) ///
	graphregion(color(white)) ///
    plotregion(fcolor(white)) ///
	bgcolor(white)
graph export "$resultados\graf_inv_RM_t.png", replace
restore

* Personas con ingresos inválidos pero con rango de salarios mínimos, como porcentaje de las personas con ingresos inválidos
preserve
keep if ing_inv==1
collapse (mean) inv_RM [aweight = fac_tri], by(tqtrimestre)
replace inv_RM=inv_RM*100
twoway (line inv_RM tqtrimestre, lcolor(orange) lwidth(thick)), ///
	title(Proporción de los trabajadores con ingresos inválidos que sí reportan RM) ///
	xtitle("") ///
	ytitle(Porcentaje) ///
	tlabel(2005q1(4)2024q2, angle(45)) ///
	ylabel(45(1)60) ///
	caption("Fuente: Elaboración propia con datos la ENOE", size(medium)) ///
	ysize(30cm) xsize(40cm) ///
	scale(0.7) ///
	scheme(stcolor) ///
	graphregion(color(white)) ///
    plotregion(fcolor(white)) ///
	bgcolor(white)
graph export "$resultados\graf_inv_RM_entre_ing_inv_t.png", replace
restore

/*

/********************************************************
PROGRAMA PARA LA CONSTRUCCIÓN DEL ÍNDICE DE LA TENDENCIA LABORAL DE LA POBREZA CON INTERVALOS DE SALARIOS
********************************************************/

*********************************************************
clear all
set mem 400m 
set more off 
*********************************************************

set obs 1  
gen periodo = .  
gen TLP = .  
save "$temp\pobreza_laboral.dta", replace  

/********************************************************
Parte I LÍNEA DE POBREZA EXTREMA POR INGRESOS:
********************************************************/  
di in red "Promedio trimestral del valor monetario mensual de la  Línea de Pobreza Extrema por Ingresos" 

scalar  uT105 	=	754.20	  
scalar  rT105 	=	556.78	  
scalar  uT205 	=	778.81	  
scalar  rT205 	=	581.33	  
scalar  uT305 	=	779.81	  
scalar  rT305 	=	579.00	  
scalar  uT405 	=	777.34	  
scalar  rT405 	=	574.19	  

scalar  uT106 	=	793.88	  
scalar  rT106 	=	589.73	  
scalar  uT206 	=	788.75	  
scalar  rT206 	=	583.12	  
scalar  uT306 	=	805.16	  
scalar  rT306 	=	599.09	  
scalar  uT406 	=	834.08	  
scalar  rT406 	=	629.22	  

scalar  uT107 	=	851.23	  
scalar  rT107 	=	641.50	  
scalar  uT207 	=	840.49	  
scalar  rT207 	=	629.76	  
scalar  uT307 	=	846.91	  
scalar  rT307 	=	634.21	  
scalar  uT407 	=	866.83	  
scalar  rT407 	=	650.59	  

scalar  uT108 	=	875.77	  
scalar  rT108 	=	655.79	  
scalar  uT208 	=	893.87	  
scalar  rT208 	=	671.92	  
scalar  uT308 	=	915.77	  
scalar  rT308 	=	689.23	  
scalar  uT408 	=	945.75	  
scalar  rT408 	=	715.18	  

scalar  uT109 	=	959.84	  
scalar  rT109 	=	724.50	  
scalar  uT209 	=	982.88	  
scalar  rT209 	=	747.36	  
scalar  uT309 	=	996.59	  
scalar  rT309 	=	758.12	  
scalar  uT409 	=	998.91	  
scalar  rT409 	=	759.10	  

scalar  uT110 	=	1026.57	  
scalar  rT110 	=	780.73	  
scalar  uT210 	=	1017.39	  
scalar  rT210 	=	769.93	  
scalar  uT310 	=	1008.45	  
scalar  rT310 	=	757.71    
scalar  uT410 	=	1032.81	  
scalar  rT410 	=	779.66	  

scalar  uT111 	=	1049.07	  
scalar  rT111 	=	791.31    
scalar  uT211 	=	1049.74	  
scalar  rT211 	=	793.00    
scalar  uT311 	=	1051.53	  
scalar  rT311 	=	794.21    
scalar  uT411 	=	1076.46	  
scalar  rT411 	=	817.32    

scalar  uT112 	=	1106.36	  
scalar  rT112 	=	843.60    
scalar  uT212 	=	1113.08	  
scalar  rT212 	=	847.74    
scalar  uT312 	=	1152.23	  
scalar  rT312 	=	884.25    
scalar  uT412 	=	1172.86	  
scalar  rT412 	=	901.01    

scalar  uT113 	=	1185.68	  
scalar  rT113 	=	908.25    
scalar  uT213 	=	1197.91	  
scalar  rT213 	=	918.90    
scalar  uT313 	=	1197.24	  
scalar  rT313 	=	913.56    
scalar  uT413 	=	1220.45	  
scalar  rT413 	=	934.09    

scalar  uT114 	=	1252.56	  
scalar  rT114 	=	952.71    
scalar  uT214 	=	1243.86	  
scalar  rT214 	=	939.94    
scalar  uT314 	=	1264.97	  
scalar  rT314 	=	954.15    
scalar  uT414 	=	1295.15	  
scalar  rT414 	=	982.12    

scalar  uT115 	=	1296.14	  
scalar  rT115 	=	981.50    
scalar  uT215 	=	1300.42	  
scalar  rT215 	=	985.56    
scalar  uT315 	=	1312.35	  
scalar  rT315 	=	992.04    
scalar  uT415 	=	1329.88	  
scalar  rT415 	=	1006.05	  

scalar  uT116 	=	1366.93	  
scalar  rT116 	=	1039.95	  
scalar  uT216 	=	1359.11	  
scalar  rT216 	=	1028.42	  
scalar  uT316 	=	1358.61	  
scalar  rT316 	=	1025.84	  
scalar  uT416 	=	1388.35	  
scalar  rT416 	=	1054.02	  

scalar  uT117 	=	1407.01	  
scalar  rT117 	=	1061.68	  
scalar  uT217 	=	1439.17	  
scalar  rT217 	=	1090.56	  
scalar  uT317 	=	1490.80	  
scalar  rT317 	=	1136.26	  
scalar  uT417 	=	1501.22	  
scalar  rT417 	=	1141.14	  

scalar  uT118 	=	1509.99	  
scalar  rT118 	=	1144.85	  
scalar  uT218 	=	1508.32	  
scalar  rT218 	=	1139.69	  
scalar  uT318 	=	1537.71	  
scalar  rT318 	=	1159.55	  
scalar  uT418 	=	1564.27	  
scalar  rT418 	=	1186.53	  

scalar  uT119 	=	1594.81	  
scalar  rT119 	=	1209.52	  
scalar  uT219 	=	1597.63	  
scalar  rT219 	=	1209.34	  
scalar  uT319 	=	1604.31	  
scalar  rT319 	=	1212.42	  
scalar  uT419 	=	1619.78	  
scalar  rT419 	=	1225.79	  

scalar  uT120 	=	1664.71	  
scalar  rT120 	=	1266.14	  
scalar  uT320 	=	1701.39	  
scalar  rT320 	=	1298.60	  
scalar  uT420 	=	1719.75	  
scalar  rT420 	=	1313.92	  

scalar  uT121 	=	1732.14	  
scalar  rT121 	=	1317.79	  
scalar  uT221 	=	1777.32	  
scalar  rT221 	=	1358.60	  
scalar  uT321 	=	1828.63	  
scalar  rT321 	=	1400.08	  
scalar  uT421 	=	1877.13	  
scalar  rT421 	=	1443.29	  

scalar  uT122	=	1951.74   
scalar  rT122 	=	1498.46	  
scalar  uT222	=	1990.99   
scalar  rT222 	=	1530.41	  
scalar  uT322	=	2081.04   
scalar  rT322 	=	1597.57	 
scalar  uT422	=	2115.73   
scalar  rT422 	=	1625.32	 

scalar  uT123	=	2154.34   
scalar  rT123 	=	1651.91   
scalar  uT223	=	2176.94   
scalar  rT223 	=	1665.47
scalar  uT323	=	2218.76  
scalar  rT323 	=	1697.79 
scalar  uT423	=	2239.99  
scalar  rT423 	=	1716.25	

scalar  uT124	=	2303.21  
scalar  rT124 	=	1768.38 
scalar  uT224	=	2301.81  
scalar  rT224 	=	1762.85 


/*********************************************************

Parte II CÁLCULO DEL INGRESO DE LOS HOGARES :

*********************************************************/

*Periodos (trimestre, año) para los cuales se realiza la estimación
foreach x in 105 205 305 405 106 206 306 406 107 207 307 407 108 208 308 408 109 209 309 409 110 210 310 410 111 211 311 411 112 212 312 412 113 213 313 413 114 214 314 414 115 215 315 415 116 216 316 416 117 217 317 417 118 218 318 418 119 219 319 419  120     320 420 121 221 321 421 122 222 322 422  123 223 323 423 124 224 {
*Periodos (trimestre, año) para los cuales se realiza la estimación
*foreach x in 108 208 308 408 109 {
*foreach x in 207 {
	*Cargar las bases de datos de coe
	mata: st_local( "fn", dir("$coe2", "files", "*`x'*" , 1 )) 
	use "`fn'",clear 
	
	foreach var of varlist * {
    local newvar = lower("`var'")
    rename `var' `newvar'
	}
	
	*Generar el identificador único por persona
	global xlist cd_a ent v_sel n_ren 
	global ylist con 
	tostring $xlist, replace format(%02.0f) force
	tostring $ylist, replace format(%04.0f) force
	foreach i in n_hog h_mud tipo ca mes_cal {
	capture confirm variable `i' 
    if !_rc tostring `i' , replace force
	}
	 
	gen foliop = cd_a
	foreach i in ent con v_sel tipo mes_cal ca n_hog h_mud n_ren {
	capture confirm variable `i' 
    if !_rc replace foliop = foliop + `i' 
	}
	
	keep foliop p6c p6b2 p6_9 p6a3
	sort foliop
	save "$temp\ingresoT`x'.dta", replace
		
	*Cargar las bases de datos de sdem
	mata : st_local( "fn", dir("$enoe", "files", "*`x'*" , 1 ) ) 
	use "`fn'", clear 
			
	*Generar el identificador único por persona y por hogar;
	global xlist cd_a ent v_sel n_ren 
	global ylist con 
	tostring $xlist, replace format(%02.0f) force
	tostring $ylist, replace format(%04.0f) force
	foreach i in n_hog h_mud tipo ca mes_cal {
	capture confirm variable `i' 
    if !_rc tostring `i' , replace force
	}
	
	gen foliop = cd_a 
	foreach i in ent con v_sel tipo mes_cal ca n_hog h_mud n_ren {
	capture confirm variable `i' 
    if !_rc replace foliop = foliop + `i' 
	}
	
	gen folioh = cd_a 
	foreach i in ent con v_sel tipo mes_cal ca n_hog h_mud {
	capture confirm variable `i' 
    if !_rc replace folioh = folioh + `i' 
	}
	
	foreach i in fac_tri {
	capture confirm variable `i'
	if !_rc rename fac_tri fac 
	}

	foreach i in t_loc_tri {
	capture confirm variable `i'
	if !_rc rename t_loc_tri t_loc
	}

*Filtrar la base para mantener a las personas con entrevista completa y que son residentes habituales en las viviendas;
keep if r_def==0 & (c_res==1 | c_res==3)  

*Conservar variables de interés;
keep folioh foliop salario t_loc fac clase1 clase2 ent ingocup imssissste eda sex cs_p13_1 hrsocup pos_ocu ing7c
sort foliop

*Unir las bases sociodemográfica y de ingreso
merge foliop using "$temp\ingresoT`x'.dta"

tab _merge
drop _merge

gen ocupado=cond(clase1==1 & clase2==1,1,0)

destring p6b2 p6c t_loc, replace
recode p6b2 (999998=.) (999999=.)

*Recuperación de ingresos por rangos de salarios mínimos
gen double ingreso=p6b2
replace ingreso=0 if ocupado==0
replace ingreso=0 if p6b2==. & (p6_9==9 | p6a3==3)
replace ingreso=0.5*salario if p6b2==. & p6c==1
replace ingreso=1*salario if p6b2==. & p6c==2
replace ingreso=1.5*salario if p6b2==. & p6c==3
replace ingreso=2.5*salario if p6b2==. & p6c==4
replace ingreso=4*salario if p6b2==. & p6c==5
replace ingreso=7.5*salario if p6b2==. & p6c==6
replace ingreso=10*salario if p6b2==. & p6c==7

gen tamh = 1 

rename fac factor 
gen rururb = cond(t_loc>=1 & t_loc<=3,0,1) 
label define ru 0 "Urbano" 1 "Rural" 
label values rururb ru 
destring ent, replace

*Grupo de formales vs informales:
gen formal=.
replace formal=1 if imssissste==1 |imssissste==2 | imssissste==3
replace formal=0 if imssissste==4

*Grupos de edad:
gen edad=1 if eda>=14 &eda<=20
replace edad=2 if eda>=21 & eda<=35
replace edad=3 if eda>=36 & eda<=50
replace edad=4 if eda>=51

label define c 1 "14 a 20 años" 2 "21 a 35 años" 3 "36 a 50 años" 4 "51 años o más", replace
label values edad c
label var edad "Grupos de edad"

*Grupo educación:
generate niv_educ=.
replace niv_educ=0 if cs_p13_1==0 | cs_p13_1==1
replace niv_educ=1 if cs_p13_1==2
replace niv_educ=2 if cs_p13_1==3
replace niv_educ=3 if cs_p13_1==4 | cs_p13_1==5 | cs_p13_1==6
replace niv_educ=4 if cs_p13_1==7
replace niv_educ=5 if cs_p13_1==8 | cs_p13_1==9

label define a 0 "Sin instrucción" 1 "Primaria" 2 "Secundaria" 3 "Media Superior" 4 "Superior" 5 "Posgrado", replace
label values niv_educ a
label var niv_educ "Nivel educativo"

gen mv=cond(ingreso==. & ocupado==1,1,0)

//preserve
*guardar archivo temporal
save "$temp\archivo1.dta", replace 
*}
*Limpio para personas que trabajan
replace ingocup=. if ingocup==999999 | ingocup==999998 | ingocup==0
*keep if eda>=14
*keep if clase2==1
*keep if hrsocup>0 & hrsocup<=168
gen borrar = 0
replace borrar = 1 if (hrsocup==0 | clase2!=1 | pos_ocu==4 | pos_ocu==5 | pos_ocu==. | ing7c==6)
replace borrar = 0 if (ingreso !=0)
drop if borrar == 1
drop borrar
*drop if (hrsocup==0 | clase2!=1 | pos_ocu==4 | pos_ocu==5 | pos_ocu==. | ing7c==6) & ingreso !=0

*Personas que reciben un ingreso inválido
gen ing_inv=0
replace ing_inv=1 if ingocup==. & (ingreso ==0 | ingreso==.)

label define d 0 "Ingreso válido" 1 "Ingreso inválido", replace
label values ing_inv d
label var ing_inv "Clasificación"


****Imputación del ingreso para el inciso 4:
**Primero hago la imputación de Hotdeck:
* Paso 1: Crear variable indicadora de valores faltantes
gen missing_ingreso = missing(ingreso)
* Paso 2: Dividir los datos en grupos por las variables especificadas
bysort niv_educ sex edad formal rururb: gen group_id = _n
* Paso 3: Copiar ingreso a una nueva variable para imputar
gen ingreso_hd = ingreso  
* Paso 4: Para cada observación faltante, seleccionar un donante al azar dentro del grupo
gen donor = .
* Usamos un loop para imputar los valores
bysort niv_educ sex edad formal rururb: gen rand = runiform()  // Crear número aleatorio
bysort niv_educ sex edad formal rururb (rand): replace ingreso_hd = ingreso[_n-1] if missing(ingreso_hd)
* Paso 5: Limpiar las variables auxiliares
drop rand donor missing_ingreso



**** Imputación con medias de grupos con aleatoriedad:
* Paso 1: Crear una variable indicadora de valores faltantes en ingreso
gen missing_ingreso = missing(ingreso)
* Paso 2: Calcular la mediana y la desviación estándar para cada grupo
bysort niv_educ sex edad formal rururb: egen mediana_ingreso = median(ingreso)
bysort niv_educ sex edad formal rururb: egen sd_ingreso = sd(ingreso)
* Paso 3: Generar una nueva variable para almacenar el ingreso imputado
gen ingreso_mean = ingreso
* Paso 4: Generar una variable aleatoria normal estándar N(0,1)
gen z = rnormal()
* Paso 5: Imputar los valores faltantes con la mediana ajustada por la desviación estándar y el valor aleatorio
replace ingreso_mean = mediana_ingreso + sd_ingreso * z if missing(ingreso_mean)
* Paso 6: Limpiar las variables auxiliares si no las necesitas
drop z mediana_ingreso sd_ingreso missing_ingreso

replace ingreso_hd = . if ingreso_hd==0
replace ingreso_mean = . if ingreso_mean==0

keep foliop ingreso_hd ingreso_mean 
*Guardar archivo_temporal2 sacrificable
save "$temp\archivo2.dta", replace 
*Abro archivo temporal 1 y le pego el 2
use"$temp\archivo1.dta", clear
merge 1:1 foliop using "$temp\archivo2.dta"
drop _merge
save "$temp\archivo1.dta", replace 
*sigue todo igual
*Conservar variables de interés
keep folioh tamh ingreso ingreso_hd ingreso_mean rururb factor ent mv ocupado

*Obtener la base a nivel hogar con las variables de interés
collapse (sum) tamh ingreso ingreso_hd ingreso_mean mv ocupado (mean) rururb factor ent, by(folioh) 

*Se identifican y eliminan a los hogares que tienen valores perdidos en ingreso;
replace mv=1 if mv>0 & mv!=.
*drop if mv==1

/*******************************************************************

Parte III COMPARACIÓN DEL INGRESO LABORAL DEL HOGAR CON EL PROMEDIO DE LA 
LÍNEA DE POBREZA EXTREMA POR INGRESOS :

*******************************************************************/
*}
gen factorp = factor*tamh 

*foreach x in 207 {
	
*Estimar el porcentaje de la población en pobreza laboral nacional, rural y urbano;
gen lpT`x' = cond(rururb==0,uT`x',rT`x') 
gen pob = cond((ingreso/tamh)<lpT`x',1,0) 
gen pob_hd = cond((ingreso_hd/tamh)<lpT`x',1,0) 
gen pob_mean = cond((ingreso_mean/tamh)<lpT`x',1,0) 
*}

*Condicional de si esta por encima o por debajo de la línea de pobreza
sum pob [w=factorp] if mv!=1
gen double TLP=r(mean)*100 if mv!=1
sum pob_hd [w=factorp] 
gen double TLP_hd=r(mean)*100
sum pob_mean [w=factorp] 
gen double TLP_mean=r(mean)*100
format TLP %14.12gc
format TLP_hd %14.12gc
format TLP_mean %14.12gc
*
sum pob [w=factorp] if rururb==0 & mv!=1
gen double TLPu=r(mean)*100 if mv!=1
format TLPu %14.12gc

sum pob [w=factorp] if rururb==1 & mv!=1
gen double TLPr=r(mean)*100 if mv!=1
format TLPr %14.12gc
*
sum pob_hd [w=factorp] if rururb==0 
gen double TLPu_hd=r(mean)*100
format TLPu_hd %14.12gc

sum pob_hd [w=factorp] if rururb==1 
gen double TLPr_hd=r(mean)*100
format TLPr_hd %14.12gc
*
sum pob_mean [w=factorp] if rururb==0 
gen double TLPu_mean=r(mean)*100
format TLPu_mean %14.12gc

sum pob_mean [w=factorp] if rururb==1 
gen double TLPr_mean=r(mean)*100
format TLPr_mean %14.12gc

*Estimar el porcentaje de la población en pobreza laboral según entidad federativa;
foreach y in 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 { 

sum pob [w=factorp] if ent==`y' & mv!=1
gen double TLP`y'=r(mean)*100 if mv!=1
format TLP`y' %14.12gc

sum pob_hd [w=factorp] if ent==`y' 
gen double TLP`y'_hd=r(mean)*100
format TLP`y'_hd %14.12gc

sum pob_mean [w=factorp] if ent==`y' 
gen double TLP`y'_mean=r(mean)*100
format TLP`y'_mean %14.12gc

}

*Ingreso laborar per cápita
gen divis = ingreso/tamh
sum divis [aw=factorp] if mv!=1
gen double i_percapita=r(mean) if mv!=1

gen divis_hd = ingreso_hd/tamh
sum divis_hd [aw=factorp]
gen double i_percapita_hd=r(mean)

gen divis_mean = ingreso_mean/tamh
sum divis_mean [aw=factorp]
gen double i_percapita_mean=r(mean)

*foreach x in 207 {
*Definir el periodo
gen periodo="`x'" 

keep TLP* i_percapita* periodo
collapse (mean) TLP* i_percapita* (first) periodo

append using "$temp\pobreza_laboral.dta", force
save "$temp\pobreza_laboral.dta", replace 
} 




/*******************************************************************

Parte IV ESTIMACIÓN DEL ITLP :

*******************************************************************/

*Estimar el índice a nivel nacional, rural y urbano;	

*Definición del periodo base para el cálculo del ITLP;
sum TLP if periodo=="120" 
gen base=r(mean) 
format base %14.12gc 

sum TLP_hd if periodo=="120" 
gen base_hd=r(mean) 
format base_hd %14.12gc 

sum TLP_mean if periodo=="120" 
gen base_mean=r(mean) 
format base_mean %14.12gc 

*Estimar el índice a nivel nacional, rural y urbano;	
gen double ITLP=. 
replace ITLP=TLP/base 
label var ITLP "Valor del índice de la tendencia laboral de la pobreza" 
format ITLP %6.4f 

gen double ITLP_hd=. 
replace ITLP_hd=TLP_hd/base_hd
label var ITLP_hd "Valor del índice de la tendencia laboral de la pobreza" 
format ITLP_hd %6.4f 

gen double ITLP_mean=. 
replace ITLP_mean=TLP_mean/base_mean
label var ITLP_mean "Valor del índice de la tendencia laboral de la pobreza" 
format ITLP_mean %6.4f 


sum TLPu if periodo=="120" 
gen baseu=r(mean) 
format baseu %14.12gc 
gen double ITLPu=. 
replace ITLPu=TLPu/baseu 
label var ITLPu "Valor del índice de la tendencia laboral de la pobreza urbano" 
format ITLPu %6.4f 

sum TLPu_hd if periodo=="120" 
gen baseu_hd=r(mean) 
format baseu_hd %14.12gc 
gen double ITLPu_hd=. 
replace ITLPu_hd=TLPu_hd/baseu_hd
label var ITLPu_hd "Valor del índice de la tendencia laboral de la pobreza urbano" 
format ITLPu_hd %6.4f 

sum TLPu_mean if periodo=="120" 
gen baseu_mean=r(mean) 
format baseu_mean %14.12gc 
gen double ITLPu_mean=. 
replace ITLPu_mean=TLPu_mean/baseu_mean
label var ITLPu_mean "Valor del índice de la tendencia laboral de la pobreza urbano" 
format ITLPu_mean %6.4f 


sum TLPr if periodo=="120" 
gen baser=r(mean) 
format baser %14.12gc
gen double ITLPr=. 
replace ITLPr=TLPr/baser 
label var ITLPr "Valor del índice de la tendencia laboral de la pobreza rural" 
format ITLPr %6.4f 

sum TLPr_hd if periodo=="120" 
gen baser_hd=r(mean) 
format baser_hd %14.12gc
gen double ITLPr_hd=. 
replace ITLPr_hd=TLPr_hd/baser_hd
label var ITLPr_hd "Valor del índice de la tendencia laboral de la pobreza rural" 
format ITLPr_hd %6.4f 

sum TLPr_mean if periodo=="120" 
gen baser_mean=r(mean) 
format baser_mean %14.12gc
gen double ITLPr_mean=. 
replace ITLPr_mean=TLPr_mean/baser_mean
label var ITLPr_mean "Valor del índice de la tendencia laboral de la pobreza rural" 
format ITLPr_mean %6.4f 

*Estimar el índice a nivel según entidad federativa;
foreach z in  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 { 

sum TLP`z' if periodo=="120" 
gen base`z'=r(mean) 
format base`z' %14.12gc
gen double ITLP`z'=. 
replace ITLP`z'=TLP`z'/base`z' 
label var ITLP`z' "Valor del índice de la tendencia laboral de la pobreza `z'" 
format ITLP`z'  %6.4f 

sum TLP`z'_hd if periodo=="120" 
gen base`z'_hd=r(mean) 
format base`z'_hd %14.12gc
gen double ITLP`z'_hd=. 
replace ITLP`z'_hd=TLP`z'_hd/base`z'_hd
label var ITLP`z'_hd "Valor del índice de la tendencia laboral de la pobreza `z'" 
format ITLP`z'_hd  %6.4f 

sum TLP`z'_mean if periodo=="120" 
gen base`z'_mean=r(mean) 
format base`z'_mean %14.12gc
gen double ITLP`z'_mean=. 
replace ITLP`z'_mean=TLP`z'_mean/base`z'_mean
label var ITLP`z'_mean "Valor del índice de la tendencia laboral de la pobreza `z'" 
format ITLP`z'_mean  %6.4f 
}

gen orden=_n
gsort -orden 
keep periodo ITLP* TLP* i_percapita*

drop in 1

*Asignación del nombre del periodo y nombre de entidades;
destring periodo, replace force 
label define periodo 105 "I 2005" 205 "II 2005" 305 "III 2005" 405 "IV 2005" 106 "I 2006" 206 "II 2006" 306 "III 2006" 406 "IV 2006" 107 "I 2007" 207 "II 2007" 307 "III 2007" 407 "IV 2007" 108 "I 2008" 208 "II 2008" 308 "III 2008" 408 "IV 2008" 109 "I 2009" 209 "II 2009" 309 "III 2009" 409 "IV 2009" 110 "I 2010" 210 "II 2010" 310 "III 2010" 410 "IV 2010" 111 "I 2011" 211 "II 2011" 311 "III 2011" 411 "IV 2011" 112 "I 2012" 212 "II 2012" 312 "III 2012" 412 "IV 2012" 113 "I 2013" 213 "II 2013" 313 "III 2013" 413 "IV 2013" 114 "I 2014"  214 "II 2014" 314 "III 2014" 414 "IV 2014" 115 "I 2015" 215 "II 2015" 315 "III 2015" 415 "IV 2015" 116 "I 2016" 216 "II 2016" 316 "III 2016" 416 "IV 2016" 117 "I 2017" 217 "II 2017" 317 "III 2017" 417 "IV 2017" 118 "I 2018" 218 "II 2018" 318 "III 2018" 418 "IV 2018" 119 "I 2019" 219 "II 2019" 319 "III 2019" 419 "IV 2019" 120 "I 2020" 320 "III 2020" 420 "IV 2020" 121 "I 2021" 221 "II 2021" 321 "III 2021" 421 "IV 2021" 122 "I 2022" 222 "II 2022" 322 "III 2022" 422 "IV 2022" 123 "I 2023" 223 "II 2023" 323 "III 2023" 423 "IV 2023"  124 "I 2024"  224 "II 2024" 

label value periodo periodo 

rename TLP Nacional 
rename TLPu Urbano 
rename TLPr Rural 
rename TLP1 Aguascalientes 
rename TLP2 Baja_California 
rename TLP3 Baja_California_Sur 
rename TLP4 Campeche 
rename TLP5 Coahuila 
rename TLP6 Colima 
rename TLP7 Chiapas 
rename TLP8 Chihuahua 
rename TLP9 Cuidad_de_México
rename TLP10 Durango 
rename TLP11 Guanajuato 
rename TLP12 Guerrero 
rename TLP13 Hidalgo 
rename TLP14 Jalisco 
rename TLP15 Estado_de_México 
rename TLP16 Michoacán 
rename TLP17 Morelos 
rename TLP18 Nayarit 
rename TLP19 Nuevo_León 
rename TLP20 Oaxaca 
rename TLP21 Puebla 
rename TLP22 Querétaro 
rename TLP23 Quintana_Roo 
rename TLP24 San_Luis_Potosí 
rename TLP25 Sinaloa 
rename TLP26 Sonora 
rename TLP27 Tabasco 
rename TLP28 Tamaulipas 
rename TLP29 Tlaxcala 
rename TLP30 Veracruz 
rename TLP31 Yucatán 
rename TLP32 Zacatecas 

rename TLP_hd Nacional_hd
rename TLPu_hd Urbano_hd
rename TLPr_hd Rural_hd
rename TLP1_hd Aguascalientes_hd
rename TLP2_hd Baja_California_hd
rename TLP3_hd Baja_California_Sur_hd 
rename TLP4_hd Campeche_hd
rename TLP5_hd Coahuila_hd
rename TLP6_hd Colima_hd
rename TLP7_hd Chiapas_hd
rename TLP8_hd Chihuahua_hd
rename TLP9_hd Cuidad_de_México_hd
rename TLP10_hd Durango_hd
rename TLP11_hd Guanajuato_hd 
rename TLP12_hd Guerrero_hd
rename TLP13_hd Hidalgo_hd
rename TLP14_hd Jalisco_hd
rename TLP15_hd Estado_de_México_hd
rename TLP16_hd Michoacán_hd
rename TLP17_hd Morelos_hd
rename TLP18_hd Nayarit_hd
rename TLP19_hd Nuevo_León_hd 
rename TLP20_hd Oaxaca_hd
rename TLP21_hd Puebla_hd
rename TLP22_hd Querétaro_hd 
rename TLP23_hd Quintana_Roo_hd 
rename TLP24_hd San_Luis_Potosí_hd 
rename TLP25_hd Sinaloa_hd
rename TLP26_hd Sonora_hd
rename TLP27_hd Tabasco_hd
rename TLP28_hd Tamaulipas_hd 
rename TLP29_hd Tlaxcala_hd
rename TLP30_hd Veracruz_hd
rename TLP31_hd Yucatán_hd
rename TLP32_hd Zacatecas_hd

rename TLP_mean Nacional_mean
rename TLPu_mean Urbano_mean
rename TLPr_mean Rural_mean
rename TLP1_mean Aguascalientes_mean
rename TLP2_mean Baja_California_mean
rename TLP3_mean Baja_California_Sur_mean 
rename TLP4_mean Campeche_mean
rename TLP5_mean Coahuila_mean
rename TLP6_mean Colima_mean
rename TLP7_mean Chiapas_mean
rename TLP8_mean Chihuahua_mean
rename TLP9_mean Cuidad_de_México_mean
rename TLP10_mean Durango_mean
rename TLP11_mean Guanajuato_mean 
rename TLP12_mean Guerrero_mean
rename TLP13_mean Hidalgo_mean
rename TLP14_mean Jalisco_mean
rename TLP15_mean Estado_de_México_mean
rename TLP16_mean Michoacán_mean
rename TLP17_mean Morelos_mean
rename TLP18_mean Nayarit_mean
rename TLP19_mean Nuevo_León_mean 
rename TLP20_mean Oaxaca_mean
rename TLP21_mean Puebla_mean
rename TLP22_mean Querétaro_mean 
rename TLP23_mean Quintana_Roo_mean 
rename TLP24_mean San_Luis_Potosí_mean 
rename TLP25_mean Sinaloa_mean
rename TLP26_mean Sonora_mean
rename TLP27_mean Tabasco_mean
rename TLP28_mean Tamaulipas_mean 
rename TLP29_mean Tlaxcala_mean
rename TLP30_mean Veracruz_mean
rename TLP31_mean Yucatán_mean
rename TLP32_mean Zacatecas_mean

tabstat  Nacional-Zacatecas, by (per) format(%6.2f) nototal 
tabstat  Nacional_hd-Zacatecas_hd, by (per) format(%6.2f) nototal 
tabstat  Nacional_mean-Zacatecas_mean, by (per) format(%6.2f) nototal 

***Para tener la variable de trimestre en formato de tiempo:
tostring periodo, generate(periodo_str)
gen trimestre = "20"+substr(periodo_str, 2,2)+"q"+substr(periodo_str, 1,1)

**Traigo el INPC
merge 1:m trimestre using "$Union\ENOE_INCP.dta"
drop _merge 

*Ingreso per cápita en términos reales:
gen r_i_percapita = (i_percapita/inpc)*100
gen r_i_percapita_hd = (i_percapita_hd/inpc)*100
gen r_i_percapita_mean = (i_percapita_mean/inpc)*100

gen tqtrimestre = quarterly(trimestre, "Yq")
format tqtrimestre %tq

sort tqtrimestre
gen linea = _n

*** Ahora traigo los datos de Pobreza Multidimensional de la ENIGH
gen year = substr(trimestre, 1, 4)
destring year, replace
merge m:1 year using "$Union\Pobreza_mult.dta"

drop _merge
format year %ty

*No quiero tener valores repetidos de pobreza multidimensional. 
*Solo quiero conservar el tercer trimestre para cada año
gen trim_ayuda = substr(trimestre, 6, 1)
replace serie_anterior = . if trim_ayuda!= "3"
replace nueva_serie = . if trim_ayuda!= "3"

*Exportación de resultados
save "$temp\ITLP-1.dta", replace 

*/


use "$temp\ITLP-1.dta", clear

*Pobreza Laboral
twoway (line Nacional tqtrimestre if linea <= 61, lcolor(black) lpattern(solid) lw(medium)) ///
		(line Nacional tqtrimestre if linea >= 63, lcolor(black) lpattern(solid) lw(medium)) ///
		(line Nacional_hd tqtrimestre if linea <= 61, lcolor(red) lpattern(longdash) lw(medthick)) ///
		(line Nacional_hd tqtrimestre if linea >= 63, lcolor(red) lpattern(longdash) lw(medthick)) ///
		(line Nacional_mean tqtrimestre if linea <= 61, lcolor(blue) lpattern(shortdash) lwidth(medthick)) /// 
		(line Nacional_mean tqtrimestre if linea >= 63, lcolor(blue) lpattern(shortdash) lwidth(medthick)), /// 
		title("Pobreza laboral oficial y con ingreso imputado") /// 
		legend(order(1 "Pobreza laboral" 3 "Ajuste de Hotdeck" 5 "Ajuste por grupos con aleatoriedad") ///
        position(6) rows(1)) /// 
		xtitle("") ///
		ytitle(Porcentaje) ///
		tlabel(2005q1(4)2024q2, angle(45)) ///
		caption("Fuente: Elaboración propia con datos la ENOE", size(medium)) ///
		legend(position(6) rows(1)) ///
		ylabel(33(1)47) ///
		ysize(30cm) xsize(40cm) ///
		scale(0.7) ///
		scheme(stcolor) ///
		graphregion(color(white)) ///
		plotregion(fcolor(white)) ///
		bgcolor(white)
graph export "$resultados\graf_pobreza_laboral_3.png", replace

*Ingresos reales per cápita
twoway (line r_i_percapita tqtrimestre if linea <= 61, lcolor(black) lpattern(solid) lw(medium)) /// 
       (line r_i_percapita tqtrimestre if linea >= 63, lcolor(black) lpattern(solid) lw(medium)) /// 
       (line r_i_percapita_hd tqtrimestre if linea <= 61, lcolor(red) lpattern(longdash) lw(medthick)) /// 
       (line r_i_percapita_hd tqtrimestre if linea >= 63, lcolor(red) lpattern(longdash) lw(medthick)) /// 
       (line r_i_percapita_mean tqtrimestre if linea <= 61, lcolor(blue) lpattern(shortdash) lwidth(medthick)) /// 
       (line r_i_percapita_mean tqtrimestre if linea >= 63, lcolor(blue) lpattern(shortdash) lwidth(medthick)), /// 
       title("Ingreso real per cápita oficial e imputado" ///
             "(pesos constantes del 2018)") ///
       legend(order(1 "Ingreso real percápita" 3 "Ajuste de Hotdeck" 5 "Ajuste por grupos con aleatoriedad") ///
              position(6) rows(1)) /// 
       xtitle("") ytitle(Pesos) /// 
		tlabel(2005q1(4)2024q2, angle(45)) ///
		caption("Fuente: Elaboración propia con datos la ENOE", size(medium)) ///
		legend(position(6) rows(1)) ///
		ylabel(2150(100)3250) ///
		ysize(30cm) xsize(40cm) ///
		scale(0.7) ///
		scheme(stcolor) ///
		graphregion(color(white)) ///
		plotregion(fcolor(white)) ///
		bgcolor(white)
graph export "$resultados\graf_ingreso_real_percapita.png", replace

*Graficando ambas líneas de pobreza:
twoway (line Nacional tqtrimestre if linea >= 37 & linea <= 61, lcolor(black) lpattern(solid) lw(medium)) /// 
       (line Nacional tqtrimestre if linea >= 63, lcolor(black) lpattern(solid) lw(medium)) /// 
       (line serie_anterior tqtrimestre if linea >= 37, lcolor(red) lpattern(longdash) lw(medthick)) /// 
       (line nueva_serie tqtrimestre if linea >= 37, lcolor(blue) lpattern(shortdash) lwidth(medthick)), /// 
       title("Medición de la pobreza laboral y" ///
             "pobreza multidimensional (2014 - 2024)") ///
	   xtitle("") ///
		ytitle(Porcentaje) ///
		tlabel(2014q1(4)2024q2, angle(45)) ///
		caption("Fuente: Elaboración propia con datos la ENOE (P. laboral) y la ENIGH (P. multidimensional)", size(medium)) ///
		legend(order(1 "Pobreza laboral" 3 "Pobreza mult. serie anterior" 4 "Pobreza mult. nueva serie") ///
              position(6) rows(1)) /// 
		ylabel(35(1)47) ///
		ysize(30cm) xsize(40cm) ///
		scale(0.7) ///
		scheme(stcolor) ///
		graphregion(color(white)) ///
		plotregion(fcolor(white)) ///
		bgcolor(white)
graph export "$resultados\graf_tiempo_pobreza.png", replace

*Y por último, el gráfico de dispresión ENOE-ENIGH con pobreza
*Voy a conservar la nueva serie y lo que haga falta de la anterior
gen p_multid = cond(nueva_serie!=., nueva_serie, serie_anterior) 

keep Nacional p_multid year
keep if p_multid!=.

twoway (scatter Nacional p_multid, msymbol(S) mcolor(navy) msize(vlarge) mlabel(year) mlabcolor(black) mlabt(tick_label) mlabposition(3)) ///
       (function y=x, range(36 47) lcolor(black) lpattern(dash)), ///
       title("Pobreza Multidimensional y Laboral") ///
       xtitle("Porcentaje de población en pobreza laboral") ///
       ytitle("Porcentaje de población en pobreza multidimensional") ///
       note("Fuente: Elaboración propia con datos de la ENOE y la ENIGH" ///
            "(De la ENOE, solo se considera el tercer trimestre de cada año que corresponde con un levantamiento de la ENIGH)") ///
       legend(off) /// 
       xlabel(36(1)47) ///
       ylabel(36(1)47) ///
       ysize(30cm) xsize(40cm) ///
       scale(0.7) ///
       scheme(stcolor) ///
       graphregion(color(white)) ///
       plotregion(fcolor(white)) ///
       bgcolor(white)
graph export "$resultados\laboral vs multi.png", replace

correlate Nacional p_multid

****** INCISO 7