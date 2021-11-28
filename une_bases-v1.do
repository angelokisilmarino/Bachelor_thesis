*==============================================================================*
* Título: Une bases

* Objetivo: unir todas por código municipal e data para montar uma base 
	// consolidada com dados do Estado de SP para a monografia
	
* Autor: Angelo Kisil Marino
*==============================================================================*

* Comandos iniciais
clear all
set more off
cd "C:/Users/angel/Documents/Angelo/FEA/Monografia"


*------------------------------------------------------------------------------* 
* Junta todas as bases - Merge
*------------------------------------------------------------------------------*

* Base de covid
use "bases/covid", clear

* Merge com base de isolamento social
merge 1:1 codmun date using "bases/isolamento"
drop _merge
/* Não há merge perfeito porque a base de isolamento não tem dados de todos 
os municípios do estado */
 
* Merge com base de PIB
merge m:1 codmun using "bases/pib"
drop _merge

* Merge com base de pobreza
merge m:1 codmun using "bases/pobreza"
drop _merge

* Merge com base de políticas 2020
merge m:1 codmun using "bases/pol2020"
drop _merge

* Organização dados
order codmun date
sort codmun date

* Merge com base de emprego
gen codmun6d=floor(codmun/10) // isso é necessário porque os códigos na base de 
							// emprego têm apenas 6 dígitos
gen mes_ano_str=substr(date_str,-7,.) // isso é necessário porque os dados de emprego são mensais
merge m:1 codmun6d mes_ano_str using "bases/emprego"
	
	* Analisa _merge
	tab _merge if substr(date_str,1,2)!="01" 
	tab date if _merge!=3 & substr(date_str,1,2)=="01"
	/* A maior parte dos dados sem merge é pelo fato de os dados de emprego estarem 
	definidos só até maio de 2021*/
	drop mes_ano_str _merge

* Merge com base de vacinas
merge 1:1 codmun6d date using "bases/vacinas"
drop codmun6d _merge
/* O merge não é perfeito, pois as vacinas restringem-se a dias a partir do meio
de janeiro de 2021, por isso não há match para nenhuma data anterior. Todas as 
observações da base de vacinas, no entanto, foram assimiladas à base consolidada.*/

	* Troca vazio por 0 
	replace vacina=0 if vacina==.
	replace vacina_dose1=0 if vacina_dose1==.
	replace vacina_dose2=0 if vacina_dose2==.
	replace vacina_dose_unica=0 if vacina_dose_unica==.
	
* Restringe período amostral
drop if date>td(31aug2021)

* Salva base consolidada Estado de SP
save "bases/base_consolidada.dta", replace

