*==============================================================================*
* Título: Prepara base para análise

* Objetivo: criar variáveis de interesse para análise a partir da base consolidada
	
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
gen pre=inrange(date, td(14apr2021), td(14may2021))

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

* Salva base pre-analise
save "bases/base_pre_analise.dta", replace
