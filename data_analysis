*==============================================================================*
* Título: Análise dos dados monografia

* Objetivo: estimar PSM e estimar regressões dos efeitos do lockdown
	
* Autor: Angelo Kisil Marino
*==============================================================================*

* Comandos iniciais
clear all
set more off
cd "C:/Users/angel/Documents/Angelo/FEA/Monografia"

* Base de dados
use "bases/base_pre_analise", clear

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
				
global intervals_reg ib0.intervals i1.intervals i2.intervals i3.intervals i4.intervals ///
					i5.intervals i6.intervals i7.intervals
					
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
	ytitle("Lockdown effect on isolation", size(small)) ///
	xtitle("Days before/after lockdown", size(small))
gr export "graficos/event_studies/iso_tend.png", replace
drop coefby-coeful1
	
* Casos
qui reghdfe casos_novos_pc_mm7d $days_reg [aw=pop] if psm!=. & per_days==1, a(codmun date codmun#c.date) vce(robust)
coefplot, vertical baselevels drop(_cons) generate(coef)
twoway $tw_graph ///
		ytitle("Lockdown effect on cases", size(small)) ///
		xtitle("Days before/after lockdown", size(small))
gr export "graficos/event_studies/casos_tend.png", replace // falar que com tend violou por pouco 2 coeficientes
drop coefby-coeful1

* Óbitos
qui reghdfe obitos_novos_pc_mm7d $days_reg [aw=pop] if psm!=. & per_days==1, a(codmun date codmun#c.date) vce(robust)
coefplot, vertical baselevels drop(_cons) generate(coef)
twoway $tw_graph ///
	ytitle("Lockdown effect on deaths", size(small)) ///
	xtitle("Days before/after lockdown", size(small)) 
gr export "graficos/event_studies/obitos_tend.png", replace
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
	ytitle("Lockdown effect on employment", size(small)) ///
	xtitle("Months before/after lockdown", size(small))
gr export "graficos/event_studies/emprego.png", replace	
drop coefby-coeful1
	
*------------------------------------------------------------------------------*
* Regressões - Tabelas
*------------------------------------------------------------------------------*
	
* Isolamento, casos e óbitos
local dep_vars iso_mm7d casos_novos_pc_mm7d obitos_novos_pc_mm7d

local reg_format cells(b(star fmt(3)) se(par fmt(3))) ///
				stats(r2 N, fmt (3 0) labels("R-squared" "Observations")) ///
				style(tex) drop(0.intervals) ///
				varlabels(1.intervals "Week 1" 2.intervals "Week 2" 3.intervals "Week 3" ///
				4.intervals "Week 4" 5.intervals "Week 5" 6.intervals "Week 6" ///
				7.intervals "Week 7" _cons "Constant" ) ///
				mlabels("(1)" "(2)" "(3)") ///
				prehead("" "\begin{table}[H]" "\centering" "\medskip" "\begin{threeparttable}" ///
				"\begin{tabular}{l*{@M}{c}}" "\hline" "\addlinespace" ///
				" \multirow{2}{*}{Independent variables} & \multicolumn{3}{c}{Dependent variable: VARNAME} \\ ") ///
				posthead("\addlinespace" "\hline" "\addlinespace") prefoot("\addlinespace" ///
				"\hline" "\addlinespace") postfoot("Municipal FE &  & X & X \\" "Date FE &  & X & X \\" ///
				"Municipal-specific trends &  &  & X \\" "\addlinespace" "\hline" ///
				"\end{tabular}" "\begin{tablenotes}" "\footnotesize" ///
				"\item Notes: Robust standard errors are in parenthesis. Blablabla" ///
				"\item *** $ p<0.01$, ** $ p<0.05$, * $ p<0.1$" "\end{tablenotes}" ///
				"\caption{{\sc @title}}" "\end{threeparttable}" "\end{table}" "") ///
				notype collabels(none) replace
				
foreach dep_var of local dep_vars {
	reg `dep_var' $intervals_reg [aw=pop] if psm!=. & per_days==1, vce(robust)
	eststo spec1
	reghdfe `dep_var' $intervals_reg [aw=pop] if psm!=. & per_days==1, a(codmun date) vce(robust)
	eststo spec2
	reghdfe `dep_var' $intervals_reg [aw=pop] if psm!=. & per_days==1, a(codmun date codmun#c.date) vce(robust)
	eststo spec3
	estout using "tabelas/`dep_var'.tex", `reg_format' title("TABLENAME")
	eststo clear
}
	
* Emprego
local reg_format cells(b(star fmt(3)) se(par fmt(3))) ///
				stats(r2 N, fmt (3 0) labels("R-squared" "Observations")) ///
				style(tex) drop(2.months) ///
				varlabels(3.months "Month 1" 4.months "Month 2" 5.months "Month 3" 6.months "Month 4" ///
				_cons "Constant" ) ///
				mlabels("(1)" "(2)" "(3)") ///
				prehead("" "\begin{table}[H]" "\centering" "\medskip" "\begin{threeparttable}" ///
				"\begin{tabular}{l*{@M}{c}}" "\hline" "\addlinespace" ///
				" \multirow{2}{*}{Independent variables} & \multicolumn{3}{c}{Dependent variable: VARNAME} \\ ") ///
				posthead("\addlinespace" "\hline" "\addlinespace") prefoot("\addlinespace" ///
				"\hline" "\addlinespace") postfoot("Municipal FE &  & X & X \\" "Date FE &  & X & X \\" ///
				"Municipal-specific trends &  &  & X \\" "\addlinespace" "\hline" ///
				"\end{tabular}" "\begin{tablenotes}" "\footnotesize" ///
				"\item Notes: Robust standard errors are in parenthesis. Blablabla" ///
				"\item *** $ p<0.01$, ** $ p<0.05$, * $ p<0.1$" "\end{tablenotes}" ///
				"\caption{{\sc @title}}" "\end{threeparttable}" "\end{table}" "") ///
				notype collabels(none) replace

reg saldo_pc ib2.months i3.months i4.months i5.months i6.months [aw=pop] if psm!=. & per_months==1, vce(robust)
eststo spec1
reghdfe saldo_pc ib2.months i3.months i4.months i5.months i6.months [aw=pop] if psm!=. & per_months==1, a(codmun date) vce(robust)
eststo spec2
reghdfe saldo_pc ib2.months i3.months i4.months i5.months i6.months [aw=pop] if psm!=. & per_months==1, a(codmun date codmun#c.date) vce(robust)
eststo spec3
estout using "tabelas/emprego.tex", `reg_format' title("TABLENAME")
eststo clear





