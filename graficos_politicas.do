*==============================================================================*
* Título: Gráfico de alinhamento das políticas

* Objetivo: criar gráfico que ilustra alinhamento temporal de event-studies
	
* Autor: Angelo Kisil Marino
*==============================================================================*

* Comandos iniciais
clear all
set more off
cd "C:/Users/angel/Documents/Angelo/FEA/Monografia"

* Base de dados
use "bases/base_pre_analise", clear

*------------------------------------------------------------------------------*
* Gráficos políticas
*------------------------------------------------------------------------------*
gen altura=.
replace altura=15 if lockdown==1 & nomemun=="altinópolis"
replace altura=14 if lockdown==1 & nomemun=="araraquara"
replace altura=13 if lockdown==1 & nomemun=="batatais"
replace altura=12 if lockdown==1 & nomemun=="bebedouro"
replace altura=11 if lockdown==1 & nomemun=="brodowski"
replace altura=10 if lockdown==1 & nomemun=="colômbia"
replace altura=9 if lockdown==1 & nomemun=="cristais paulista"
replace altura=8 if lockdown==1 & nomemun=="franca"
replace altura=7 if lockdown==1 & nomemun=="itirapuã"
replace altura=6 if lockdown==1 & nomemun=="jardinópolis"
replace altura=5 if lockdown==1 & nomemun=="patrocínio paulista"
replace altura=4 if lockdown==1 & nomemun=="restinga"
replace altura=3 if lockdown==1 & nomemun=="ribeirão preto"
replace altura=2 if lockdown==1 & nomemun=="são josé da bela vista"
replace altura=1 if lockdown==1 & nomemun=="taiúva"
gen days_graph=days-7

global ylabs 1 "Taiúva" 2 "São José da Bela Vista" 3 "Ribeirão Preto" ///
			4 "Restinga" 5 "Patrocínio Paulista" 6 "Jardinópolis" 7 "Itirapuã" 8 "Franca" ///
			9 "Cristais Paulista" 10 "Colômbia" 11 "Brodowski" 12 "Bebedouro" 13 "Batatais" ///
			14 "Araraquara" 15 "Altinópolis"

* Datas
tw line altura date if nomemun=="altinópolis", lw(1.2) lc("51 153 255") ///
	|| line altura date if nomemun=="araraquara", lw(1.2) lc("51 153 255") ///
	|| line altura date if nomemun=="batatais", lw(1.2) lc("51 153 255") ///
	|| line altura date if nomemun=="bebedouro", lw(1.2) lc("51 153 255") ///
	|| line altura date if nomemun=="brodowski", lw(1.2) lc("51 153 255") ///
	|| line altura date if nomemun=="colômbia", lw(1.2) lc("51 153 255") ///
	|| line altura date if nomemun=="cristais paulista", lw(1.2) lc("51 153 255") ///
	|| line altura date if nomemun=="franca", lw(1.2) lc("51 153 255") ///
	|| line altura date if nomemun=="itirapuã", lw(1.2) lc("51 153 255") ///
	|| line altura date if nomemun=="jardinópolis", lw(1.2) lc("51 153 255") ///
	|| line altura date if nomemun=="patrocínio paulista", lw(1.2) lc("51 153 255") ///
	|| line altura date if nomemun=="restinga", lw(1.2) lc("51 153 255") ///
	|| line altura date if nomemun=="ribeirão preto", lw(1.2) lc("51 153 255") ///
	|| line altura date if nomemun=="são josé da bela vista", lw(1.2) lc("51 153 255") ///
	|| line altura date if nomemun=="taiúva", lw(1.2) lc("51 153 255") ///
	|| if inrange(date,td(10may2021),td(15jun2021)), ///
	xlab(22410 "10-05-2021" 22430 "30-05-2021" 22451 "20-06-2021") ///
	ylab($ylabs, nogrid angle(horizontal) notick) ///
	xtitle("Calendar days") ytitle("") ///
	xscale(range(22410 22455) titlegap(1.5)) yscale(noline) ///
	legend(off) graphr(color(white))
gr export "graficos/politicas/dates.png", replace

* Days
tw line altura days_graph if nomemun=="altinópolis", lw(1.2) lc("51 153 255") ///
	|| line altura days_graph if nomemun=="araraquara", lw(1.2) lc("51 153 255") ///
	|| line altura days_graph if nomemun=="batatais", lw(1.2) lc("51 153 255") ///
	|| line altura days_graph if nomemun=="bebedouro", lw(1.2) lc("51 153 255") ///
	|| line altura days_graph if nomemun=="brodowski", lw(1.2) lc("51 153 255") ///
	|| line altura days_graph if nomemun=="colômbia", lw(1.2) lc("51 153 255") ///
	|| line altura days_graph if nomemun=="cristais paulista", lw(1.2) lc("51 153 255") ///
	|| line altura days_graph if nomemun=="franca", lw(1.2) lc("51 153 255") ///
	|| line altura days_graph if nomemun=="itirapuã", lw(1.2) lc("51 153 255") ///
	|| line altura days_graph if nomemun=="jardinópolis", lw(1.2) lc("51 153 255") ///
	|| line altura days_graph if nomemun=="patrocínio paulista", lw(1.2) lc("51 153 255") ///
	|| line altura days_graph if nomemun=="restinga", lw(1.2) lc("51 153 255") ///
	|| line altura days_graph if nomemun=="ribeirão preto", lw(1.2) lc("51 153 255") ///
	|| line altura days_graph if nomemun=="são josé da bela vista", lw(1.2) lc("51 153 255") ///
	|| line altura days_graph if nomemun=="taiúva", lw(1.2) lc("51 153 255") ///
	|| if inrange(days_graph,-10,20), ///
	xlab(-10(10)22) ylab($ylabs, nogrid angle(horizontal) notick) ///
	xtitle("Days before/after lockdown") ytitle("") ///
	xscale(range(-10 20) titlegap(1.5)) yscale(noline) ///
	legend(off) graphr(color(white))
gr export "graficos/politicas/days.png", replace
