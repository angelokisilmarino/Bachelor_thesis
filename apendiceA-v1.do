*==============================================================================*
* Título: Apêndice A monografia

* Objetivo: estimar PSM e estimar regressões dos efeitos do lockdown para o apêndice
	
* Autor: Angelo Kisil Marino
*==============================================================================*

* Comandos iniciais
clear all
set more off
cd "C:/Users/angel/Documents/Angelo/FEA/Monografia"

* Base consolidada
use "bases/base_consolidada", clear

*------------------------------------------------------------------------------*
* Alterações na base para análise
*------------------------------------------------------------------------------*

/* Os municípios tratados e os detalhes das políticas estão disponíveis em:
"bases/politicas_infos.xlsx". Essa é a base para a definição das variáveis de 
tratamento e de lockdown. */

* Define variável de tratamento
gen t=1 if inlist(nomemun, "altinópolis", "araraquara", "batatais", "bebedouro", ///
	"brodowski", "colômbia", "cristais paulista", "franca") | ///
	inlist(nomemun, "itirapuã", "jardinópolis", "patrocínio paulista", ///
	"restinga", "ribeirão preto", "são josé da bela vista", "taiúva")

* Identifica potenciais controles
replace t=0 if t==. // t=0 -> potenciais controles

* Identificar DRSs dos municípios tratados
gen drs_abfr=inlist(nome_drs, "araraquara", "barretos", "franca", "ribeirão preto")

* Define variável de lockdown para cada cidade
gen lockdown=0
replace lockdown=1 if nomemun=="altinópolis" & inrange(date, td(25may2021), td(07jun2021))
replace lockdown=1 if nomemun=="araraquara" & inrange(date, td(20jun2021), td(27jun2021))
replace lockdown=1 if nomemun=="batatais" & inrange(date, td(15may2021), td(31may2021))
replace lockdown=1 if nomemun=="bebedouro" & inrange(date, td(20may2021), td(30may2021))
replace lockdown=1 if nomemun=="brodowski" & inrange(date, td(25may2021), td(06jun2021))
replace lockdown=1 if nomemun=="colômbia" & inrange(date, td(21may2021), td(25may2021))
replace lockdown=1 if nomemun=="cristais paulista" & inrange(date, td(28may2021), td(10jun2021))
replace lockdown=1 if nomemun=="franca" & inrange(date, td(27may2021), td(10jun2021))
replace lockdown=1 if nomemun=="itirapuã" & inrange(date, td(27may2021), td(10jun2021))
replace lockdown=1 if nomemun=="jardinópolis" & inrange(date, td(03jun2021), td(13jun2021))
replace lockdown=1 if nomemun=="patrocínio paulista" & inrange(date, td(28may2021), td(10jun2021))
replace lockdown=1 if nomemun=="restinga" & inrange(date, td(27may2021), td(10jun2021))
replace lockdown=1 if nomemun=="ribeirão preto" & inrange(date, td(27may2021), td(02jun2021))
replace lockdown=1 if nomemun=="são josé da bela vista" & inrange(date, td(28may2021), td(10jun2021))
replace lockdown=1 if nomemun=="taiúva" & inrange(date, td(20may2021), td(30may2021))

* Duração lockdown
egen duracao = total(lockdown), by(codmun)

* Define dias e meses em relação à política
bysort codmun (date): gen c = date if lockdown==1 & lockdown[_n-1]==0
bysort codmun (date): egen dia0=min(c)
bysort codmun (date): gen days = date - dia0
bysort codmun (date): gen months = month(date) - month(dia0) if year(date)==2021
drop c dia0

* Define períodos de análise
sum date if inrange(days,-7,50) // min(date)=08may2021 & max(date)=09augl2021
gen per_days=inrange(date,td(08may2021),td(09aug2021))
gen per_months=inlist(date,td(01feb2021),td(01mar2021),td(01apr2021),td(01may2021),td(01jun2021),td(01jul2021),td(01aug2021))

* Intervalos
gen intervals=.
replace intervals=0 if days==-1
replace intervals=1 if inrange(days,0,7)
replace intervals=2 if inrange(days,8,14)
replace intervals=3 if inrange(days,15,21)
replace intervals=4 if inrange(days,22,28)
replace intervals=5 if inrange(days,29,35)
replace intervals=6 if inrange(days,36,42)
replace intervals=7 if inrange(days,43,50)
replace intervals=999999 if t==0

*------------------------------------------------------------------------------*
* Alterações para o Propensity Score Matching (PSM)
*------------------------------------------------------------------------------*

/* A primeira data de adoção de um lockdown a ser analisado é de 15may2021. 
Tendo isso em vista, considerar-se-á como período relevante anterior à política 
diferentes intervalos de tempo até 14may2021. Testou-se começando em 01apr, 15apr,
01may, 07may. */
gen pre=inrange(date, td(01may2021), td(14may2021))

/* Cajuru e Guará tiveram lockdown em abril e, portanto, não poderão servir como
controles, por isso eles são excluídos da amostra. Todos os outros municípios 
dos DRSs de interesse não adotaram lockdown neste período. */
drop if nomemun=="cajuru" | nomemun=="guará"

* Calcula média de variáveis antes do lockdown para o PSM

	* Casos novos por 100 mil habitantes (pc)
	gen casos_novos_pc = 100000*casos_novos/pop // casos novos por 100 mil habitantes
	bysort codmun (date): egen casos_novos_pc_pre = mean(casos_novos_pc) if pre==1
	
	* Óbitos novos pc
	gen obitos_novos_pc = 100000*obitos_novos/pop
	bysort codmun (date): egen obitos_novos_pc_pre = mean(obitos_novos_pc) if pre==1
	
	* Emprego pc
	gen saldo_pc = 100000*saldo/pop
	bysort codmun (date): egen saldo_pc_pre = mean(saldo_pc) if pre==1
	
	* Isolamento
	bysort codmun(date): egen iso_pre = mean(iso) if pre==1
	sum codmun if iso_pre!=. & date==td(14may2021) 
	/* Só há dados para de isolamento para 16 municípios, isso limita muito
	o tamanho da amostra e, por isso, os dados de isolamento não serão
	utilizados no PSM */
	
	* Vacinas pc
	gen vacinas_novas_pc = 100000*vacina/pop
	bysort codmun(date): egen vacinas_novas_pc_pre = mean(vacinas_novas_pc) if pre==1
	
	/* Outras variáveis observáveis e que são constantes ao longo do tempo:
	população, população idosa, %VA agro, %VA ind, %VA ser, %VA adm,
	PIB per capita 2018, renda sub 1/4 s.m. */
	
*------------------------------------------------------------------------------*
* Alterações para o Regressões
*------------------------------------------------------------------------------*
	
/* Adicionar mais 7 dias em days de forma que days=7 seja o dia da implementação
e days=0 seja 1 semana antes do lockdown. Isso porque não é possível criar 
dummies com valores negativos. Olhamos para o impacto até 50 dias (7 semanas) 
depois da implementação da política. 

Adicionar mais 3 dias em months, de forma que months=3 seja o mes de implementação
e months=0 seja 3 meses antes do lockdown.

As alterações nas variáveis dependentes são calculadas em relação a 1 dia antes
da adoção do lockdown, ou seja, no dia -1 que é identificado por days=6. 

As alterações em emprego são calculadas em relação a 1 mês antes da adoção months=2 */

* Torna days positiva
replace days = days + 7
replace days=. if days<0
replace days=999999 if t==0 // define days de forma que as dummies ix.days seja definida para os controles sempre como 0

* Torna months positiva
replace months = months + 3
replace months=. if months<0
replace months=999999 if t==0

* Cria média móvel de 7 dias para variáveis dependentes
bysort codmun: asrol iso, wind(date 7) stat(mean) min(7)
rename mean7_iso iso_mm7d
bysort codmun: asrol casos_novos_pc, wind(date 7) stat(mean) min(7)
rename mean7_casos casos_novos_pc_mm7d
bysort codmun: asrol obitos_novos_pc, wind(date 7) stat(mean) min(7)
rename mean7_obitos obitos_novos_pc_mm7d

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
psmatch2 t $psm_var_all if date==td(14may2021) & drs_abfr==1, n(5) qui

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
gr export "graficos/apendice/iso_tend.png", replace
drop coefby-coeful1
	
* Casos
qui reghdfe casos_novos_pc_mm7d $days_reg [aw=pop] if psm!=. & per_days==1, a(codmun date codmun#c.date) vce(robust)
coefplot, vertical baselevels drop(_cons) generate(coef)
twoway $tw_graph ///
		ytitle("Lockdown effect on cases", size(small)) ///
		xtitle("Days before/after lockdown", size(small))
gr export "graficos/apendice/casos_tend.png", replace // falar que com tend violou por pouco 2 coeficientes
drop coefby-coeful1

* Óbitos
qui reghdfe obitos_novos_pc_mm7d $days_reg [aw=pop] if psm!=. & per_days==1, a(codmun date codmun#c.date) vce(robust)
coefplot, vertical baselevels drop(_cons) generate(coef)
twoway $tw_graph ///
	ytitle("Lockdown effect on deaths", size(small)) ///
	xtitle("Days before/after lockdown", size(small)) 
gr export "graficos/apendice/obitos_tend.png", replace
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
gr export "graficos/apendice/emprego.png", replace	
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
	estout using "tabelas/apendice/ap_`dep_var'.tex", `reg_format' title("TABLENAME")
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
estout using "tabelas/apendice/ap_emprego.tex", `reg_format' title("TABLENAME")
eststo clear
