*==============================================================================*
* Título: Apêndice B monografia

* Objetivo: estimar placebos dos efeitos do lockdown para o apêndice
	
* Autor: Angelo Kisil Marino
*==============================================================================*

* Comandos iniciais
clear all
set more off
cd "C:/Users/angel/Documents/Angelo/FEA/Monografia"

* Base de dados
use "bases/base_pre_analise", clear

*------------------------------------------------------------------------------*
* Redefine variável days
*------------------------------------------------------------------------------*

drop days months per_days per_months

* Define dias e meses em relação à política
bysort codmun (date): gen c = date if lockdown==1 & lockdown[_n-1]==0
bysort codmun (date): egen dia0=min(c)
replace dia0=dia0-365
bysort codmun (date): gen days = date - dia0
bysort codmun (date): gen months = month(date) - month(dia0) if year(date)==2020
/*gen mes0=.
replace mes0=month(dia0)
replace months=1 if mes0==11 & month(date)==12 & year(date)==2020
replace months=2 if mes0==11 & month(date)==1 & year(date)==2021
replace months=3 if mes0==11 & month(date)==2 & year(date)==2021
replace months=1 if mes0==12 & month(date)==1 & year(date)==2021
replace months=2 if mes0==12 & month(date)==2 & year(date)==2021
replace months=3 if mes0==12 & month(date)==3 & year(date)==2021 */
drop c dia0 //mes0

* Define períodos de análise
/*sum date if inrange(days,-7,50) // min(date)=09nov2021 & max(date)=10feb2021
gen per_days=inrange(date,td(09nov2020),td(10feb2021))
gen per_months=inlist(date,td(01aug2020),td(01sep2020),td(01oct2020),td(01nov2020),td(01dec2020),td(01jan2021),td(01feb2021),td(01mar2021))*/

sum date if inrange(days,-7,50) // min(date)=08may2020 & max(date)=09augl2020
gen per_days=inrange(date,td(08may2020),td(09aug2020))
gen per_months=inlist(date,td(01feb2020),td(01mar2020),td(01apr2020),td(01may2020),td(01jun2020),td(01jul2020),td(01aug2020),td(01sep2020))

* Torna days positiva
replace days = days + 7
replace days=. if days<0
replace days=999999 if t==0 // define days de forma que as dummies ix.days seja definida para os controles sempre como 0

* Torna months positiva
replace months = months + 3
replace months=. if months<0
replace months=999999 if t==0

*------------------------------------------------------------------------------*
* Globals
*------------------------------------------------------------------------------*

global psm_var_all casos_novos_pc_pre obitos_novos_pc_pre saldo_pc_pre ///
					vacinas_novas_pc_pre pop pop60 va_agro2018 va_ind2018 ///
					va_ser2018 va_adm2018 pibpc2018 renda_mensal_1qsm
					
global days_reg i0.days i1.days i2.days i3.days i4.days i5.days ib6.days i7.days i8.days ///
				i9.days i10.days i11.days i12.days i13.days i14.days i15.days i16.days ///
				i17.days i18.days i19.days i20.days i21.days i22.days i23.days i24.days ///
				i25.days i26.days i27.days i28.days i29.days i30.days i31.days i32.days ///
				i33.days i34.days i35.days i36.days i37.days i38.days i39.days i40.days ///
				i41.days i42.days i43.days i44.days i45.days i46.days i47.days i48.days ///
				i49.days i50.days i51.days i52.days i53.days i54.days i55.days i56.days ///
				i57.days
					
global months_reg i0.months i1.months ib2.months i3.months i4.months i5.months i6.months


global tw_graph ///
		connected coefb coefat if coefat<=6, mc("51 153 255") msiz(1.5) ms(o) lc("51 153 255") lw(.3)  /// 
		|| connected coefb coefat if coefat>7, mc("51 153 255") msiz(1.5) ms(o) lc("51 153 255") lw(.3) ///
		|| line coeful1 coefll1 coefat if coefat<=6, lc(gray gray) lp(dash dash) ///
		|| line coefll1 coeful1 coefat if coefat>7, lc(gray gray) lp(dash dash) /// 
		||, xlab(1 "-7" 2 " " 3 "-5" 4 " " 5 "-3" 6 " " 7 "-1" 8 " " 9 "1" 10 " " ///
		11 "3" 12 " " 13 "5" 14 " " 15 "7" 16 " " 17 "9" 18 " " 19 "11" 20 " " 21 ///
		"13" 22 " " 23 "15" 24 " " 25 "17" 26 " " 27 "19" 28 " " 29 "21" 30 " " 31 ///
		"23" 32 " " 33 "25" 34 " " 35 "27" 36 " " 37 "29" 38 " " 39 "31" 40 " " 41 ///
		"33" 42 " " 43 "35" 44 " " 45 "37" 46 " " 47 "39" 48 " " 49 "41" 50 " " 51 ///
		"43" 52 " " 53 "45" 54 " " 55 "47" 56 " " 57 "49" 58 " ", labsize(small)) ///
		ylab(,labsize(small) nogrid) ///
		xsc(titlegap(1.5)) ysc(titlegap(1.5)) ///
		xline(7.5, lc(red) lw(.2)) yline(0, lc(black) lw(.2)) ///
		legend(off) graphr(color(white)) 
		
*------------------------------------------------------------------------------*
* PSM
*------------------------------------------------------------------------------*
			
* PSM
psmatch2 t $psm_var_all if date==td(14may2021) & drs_abfr==1, n(3) qui

* Teste de média
bysort codmun (date): gen den_pop=pop/area
*pstest $psm_var_all den_pop, both // exportei tabela manualmente

* Dummy psm
egen psm = mean(_weight), by(codmun)
			
* Municípios por grupo
*tab nomemun if psm!=. & t==0 & date==td(14may2021)
*tab nomemun if psm!=. & t==1 & date==td(14may2021)

*------------------------------------------------------------------------------*
* Regressões - Gráficos
*------------------------------------------------------------------------------*
	
* Isolamento
qui reghdfe iso_mm7d $days_reg [aw=pop] if psm!=. & per_days==1, a(codmun date codmun#c.date) vce(robust)
coefplot, vertical baselevels drop(_cons) generate(coef)
twoway $tw_graph ///
	ytitle("Lockdown placebo effect on isolation", size(small)) ///
	xtitle("Days before/after placebo lockdown", size(small))
gr export "graficos/apendice/apB_iso_tend.png", replace
drop coefby-coeful1
	
* Casos
qui reghdfe casos_novos_pc_mm7d $days_reg [aw=pop] if psm!=. & per_days==1, a(codmun date codmun#c.date) vce(robust)
coefplot, vertical baselevels drop(_cons) generate(coef)
twoway $tw_graph ///
		ytitle("Lockdown placebo effect on cases", size(small)) ///
		xtitle("Days before/after placebo lockdown", size(small))
gr export "graficos/apendice/apB_casos_tend.png", replace // falar que com tend violou por pouco 2 coeficientes
drop coefby-coeful1

* Óbitos
qui reghdfe obitos_novos_pc_mm7d $days_reg [aw=pop] if psm!=. & per_days==1, a(codmun date codmun#c.date) vce(robust)
coefplot, vertical baselevels drop(_cons) generate(coef)
twoway $tw_graph ///
	ytitle("Lockdown placebo effect on deaths", size(small)) ///
	xtitle("Days before/after placebo lockdown", size(small)) 
gr export "graficos/apendice/apB_obitos_tend.png", replace
drop coefby-coeful1

* Emprego
qui reghdfe saldo_pc $months_reg [aw=pop] if psm!=. & per_months==1, a(codmun date) vce(robust)
coefplot, vertical baselevels drop(_cons) generate(coef)
twoway connected coefb coefat if coefat<=2, mc("51 153 255") msiz(1.5) ms(o) lc("51 153 255") lw(.3)  /// 
	|| connected coefb coefat if coefat>3, mc("51 153 255") msiz(1.5) ms(o) lc("51 153 255") lw(.3) ///
	|| rcap coeful1 coefll1 coefat if coefat<=2, lc(gray gray) ///
	|| rcap coefll1 coeful1 coefat if coefat>3, lc(gray gray) /// 
	||, xlab(1 "-3" 2 "-2" 3 "-1" 4 "0" 5 "1" 6 "2" 7 "3",labsize(small)) ///
	ylab(,labsize(small) nogrid) ///
	xsc(titlegap(1.5)) ysc(titlegap(1.5)) ///
	xline(3.5, lc(red) lw(.2)) yline(0, lc(black) lw(.2)) ///
	legend(off) graphr(color(white)) ///
	ytitle("Lockdown placebo effect on employment", size(small)) ///
	xtitle("Months before/after placebo lockdown", size(small))
gr export "graficos/apendice/apB_emprego.png", replace	
drop coefby-coeful1
	