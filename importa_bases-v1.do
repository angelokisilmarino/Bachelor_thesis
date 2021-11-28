*==============================================================================*
* Título: Importa bases

* Objetivo: ler bases em excel e salvar em *.dta com dados do Estado de SP para 
	// a monografia
	
* Autor: Angelo Kisil Marino
*==============================================================================*


* Comandos iniciais
clear all
set more off
cd "C:/Users/angel/Documents/Angelo/FEA/Monografia"


*------------------------------------------------------------------------------* 
* Dados isolamento social
*------------------------------------------------------------------------------* 

* Importa csv
import delimited "bases/20210929_isolamento.csv", delimiter(";") encoding(utf8) clear

* Mantém apenas variáveis de interesse
drop populaçãoestimada2020 uf1 // usaremos dados de população da base de dados covid

* Renomeia variáveis
rename município nomemun
rename códigomunicípioibge codmun
rename médiadeíndicedeisolamento iso
rename data date_str

* Trata variável de data
replace date_str=substr(date_str,-5,.) // mantém apenas data do mês dd/mm
gen obs=_n // numera observações para ordenar usar em bysort
bysort codmun (obs): gen obs_mun=_n // numera observações por municípios
tab obs_mun if date_str=="01/01" // as observações de 1 a 271 são
								// de 2021, o resto de 2020
replace date_str=date_str+"/2021" if obs_mun<=271
replace date_str=date_str+"/2020" if obs_mun>271
gen date=date(date_str,"DMY") // cria data numérica
format %td date // formata data numérica para ficar legível
drop obs obs_mun

* Restringe período amostral
drop if date>td(31aug2021)

* Retira observações estaduais
drop if nomemun=="ESTADO DE SÃO PAULO"

* Retira nomemun, pois usaremos da base de covid
drop nomemun

* Notar que não há dados para todos os municípios
sum codmun if date==td(04may2021)

* Transforma isolamento em numérica
replace iso=substr(iso,1,2) // tira "%"
destring iso, replace

* Salva em .dta
save "bases/isolamento.dta", replace


*------------------------------------------------------------------------------* 
* Dados covid
*------------------------------------------------------------------------------* 

* Importa csv
import delimited "bases/20210929_dados_covid_municipios_sp.csv", delimiter(";") ///
	encoding(utf8) clear 

* Mantém apenas variáveis de interesse
drop dia mes letalidade map_leg map_leg_s latitude longitude 

* Renomeia variáveis
rename nome_munic nomemun
rename codigo_ibge codmun
rename datahora date_str
rename pop_60 pop60
rename semana_epidem semana_ep

* Trata variável de data
gen date=date(date_str,"DMY")
format %td date

* Retira observações sem município
drop if codmun==9999999

* Restringe período amostral
drop if date>td(31aug2021)

* Deixa tudo em minúsculo
replace nomemun=lower(nomemun)
replace nome_ra=lower(nome_ra)
replace nome_drs=lower(nome_drs)

* Salva em .dta
save "bases/covid.dta", replace


*------------------------------------------------------------------------------* 
* Dados PIB
*------------------------------------------------------------------------------* 

* Importa xls
import excel "bases/pib_mun_2008-2010.xls", sheet("PIB_dos_Municípios") firstrow clear

* Mantém apenas dados mais recentes (2018)
keep if Ano==2018

* Mantém apenas dados de SP
keep if SigladaUnidadedaFederação=="SP"

* Mantém apenas variáveis de interesse
keep CódigodoMunicípio ValoradicionadobrutodaAgrope-Valoradicionadobrutototala ///
	ProdutoInternoBrutoapreços ProdutoInternoBrutopercapita

* Renomeia variáveis
rename CódigodoMunicípio codmun
rename ValoradicionadobrutodaAgrope va_agro2018
rename ValoradicionadobrutodaIndúst va_ind2018
rename ValoradicionadobrutodosServi va_ser2018
rename ValoradicionadobrutodaAdmini va_adm2018
rename Valoradicionadobrutototala va_total2018
rename ProdutoInternoBrutoapreços pib2018
rename ProdutoInternoBrutopercapita pibpc2018

* Salva em .dta
save "bases/pib.dta", replace


*------------------------------------------------------------------------------* 
* Dados pobreza censo 2010
*------------------------------------------------------------------------------* 

* Importa xlsx
import excel "bases/sao_paulo_censo2010/tab12.xls", sheet("tab12A") clear

/* Essa base precisará de mais ajustes devido ao fato de que a tabela fornecida 
pelo censo já vem com uma formatação em excel que resulta em uma leitura pior
quando se importa para o Stata */

* Mantém variáveis de interesse e renomeia variáveis
rename A codmun
drop B C
rename D renda_mensal_70
rename E renda_mensal_1qsm
rename F renda_mensal_2qsm
drop G H I

* Cria labels
label variable renda_mensal_70 "% pop em com renda mensal domiciliar pc até R$70"
label variable renda_mensal_1qsm ///
	"% pop em com renda mensal domiciliar pc até R$127,50 (1/4 sal. mín.)"
label variable renda_mensal_2qsm ///
	"% pop em com renda mensal domiciliar pc até R$255 (1/2 sal. mín.)"

* Retira linhas extras
drop if missing(codmun) | codmun=="Código do município"

* Transforma variáveis em numéricas
destring codmun, replace
destring renda_mensal_70, replace
destring renda_mensal_1qsm, replace
destring renda_mensal_2qsm, replace


* Salva em .dta
save "bases/pobreza.dta", replace


*------------------------------------------------------------------------------* 
* Dados políticas 2020
*------------------------------------------------------------------------------* 

* Importa xlsx
import excel "bases/medidas_oxford.xlsx", sheet("Covid19-MedidasContencao") firstrow clear

* Mantém apenas dados de SP
keep if UF=="SP"

* Mantém variáveis de interesse
keep Ibge Q1Barreirassanitáriasposto-Q6DataInício
drop Q5Qualfoiaporcentagemdere

* Renomeia variáveis
rename Ibge codmun
rename Q1Barreirassanitáriasposto barreira_sanit
rename Q1DataInício barreira_sanit_inicio
rename Q2Medidasrestritivasparadim dim_aglr
rename Q2DataInício dim_aglr_inicio
rename Q3Medidasdeisolamentosocial susp_n_essenciais
rename Q3DataInício susp_n_essenciais_inicio
rename Q4Usoobrigatóriodemáscaras mascara
rename Q4DataInício mascara_inicio
rename Q5Foramadotadasmedidasdere red_transp
rename Q5DataInício red_transp_inicio
rename Q6Houveflexibilizaçãodasmed flexibilizacao
rename Q6DataInício flexibilizacao_inicio

* Salva em .dta
save "bases/pol2020.dta", replace


*------------------------------------------------------------------------------* 
* Dados emprego
*------------------------------------------------------------------------------* 

/* Nesse caso há um arquivo .txt para cada mês de cada ano, com os respectivos
microdados disponibilizados pelo CAGED. Abaixo, realizo a leitura,
tratamento e append de cada uma dessas bases de dados mensais de emprego a
nível municipal. */

* Realiza os procedimentos especificados para meses de 2020 e 2021
foreach ano in 2020 2021{
	
	* Cria vetor de meses disponíveis para cada ano
	if `ano'==2020 {
		local meses 01 02 03 04 05 06 07 08 09 10 11 12
		}
	else {
		local meses 01 02 03 04 05 06 07 08
	}
	
	foreach mes of local meses {
	
		* Importa txt
		import delimited "bases/CAGED Movimentações/CAGEDMOV`ano'`mes'.txt", ///
			delimiter(";") case(preserve) encoding(utf8) varnames(1) clear
		
		* Mantém variáveis de interesse
		keep competência uf-subclasse saldomovimentação graudeinstrução raçacor ///
			sexo tamestabjan
		
		* Cria identificadores de interesse
		
			* Agricultura e indústria extrativa e de transformação
			gen agro = 0
			replace agro = 1 if subclasse >= 0111301 & subclasse <= 3329599
			
			* Água, gás, luz, esgoto, construção
			gen infra = 0
			replace infra = 1 if subclasse >= 3511500 & subclasse <= 4399199	
			
			* Comércio e serviços (incluindo públicos)
			gen servicos = 0
			replace servicos = 1 if subclasse >= 4511101 
			
			* Ensino fundamental incompleto
			gen semfund = 0
			replace semfund = 1 if graudeinstrução >= 1 & graudeinstrução <= 4
			
			* Ensino médio incompleto e fundamental completo
			gen emincomp = 0
			replace emincomp = 1 if graudeinstrução >= 5 & graudeinstrução <= 6
			
			* Ensino superior incompleto e médio completo
			gen esincomp = 0
			replace esincomp = 1 if graudeinstrução >= 7 & graudeinstrução <= 8
			
			* Ensino superior completo ou mais
			gen escomp = 0 
			replace escomp = 1 if graudeinstrução >= 9 & graudeinstrução <= 80

			* Mulher
			gen mulher = 0
			replace mulher = 1 if sexo == 3
			
			* Branco 
			gen branco = 0 
			replace branco = 1 if raçacor == 1
			
			* Preto ou pardo
			gen negro = 0
			replace negro = 1 if raçacor == 2 | raçacor == 3
		
		* Cria variável de admitidos
		gen admitidos = 0
		replace admitidos = saldomovimentação if saldomovimentação > 0
		
		* Cria variável de desligados
		gen desligados = 0
		replace desligados = saldomovimentação if saldomovimentação < 0
			
		rename saldomovimentação saldo
		
		* Cria variáveis de admissão, desligamento e saldo de acordo com identificadores
		foreach m in admitidos desligados saldo {
			foreach n in agro infra servicos semfund emincomp esincomp escomp mulher branco negro {
				gen `m'_`n' = .
				replace `m'_`n' = `m' if `n'==1
			}
		}
		
		* Colapsa por mês e município
		gcollapse (sum) admitidos* desligados* saldo* ///
			(mean) agro infra servicos semfund emincomp esincomp escomp mulher branco negro, ///
			by (competência uf município)
		
		sort município
		
		save "bases/CAGED Movimentações/caged_`ano'`mes'.dta", replace
	}
}

* Faz o append de todas as bases mensais
use "bases/CAGED Movimentações/caged_202001.dta", clear

foreach ano in 2020 2021 {
	
	* Cria vetor de meses disponíveis para cada ano
	if `ano'==2020 {
		local meses 02 03 04 05 06 07 08 09 10 11 12
	}
	else {
		local meses 01 02 03 04 05 06 07 08
	}
	
	* Faz o append das bases mensais
	foreach mes of local meses {
		append using "bases/CAGED Movimentações/caged_`ano'`mes'.dta"
	}
}

* Mantém apenas dados de SP
keep if uf==35

* Trata variável de data
rename competência mes_ano_str
tostring mes_ano_str, replace
replace mes_ano_str=substr(mes_ano_str,5,6) + "/" + substr(mes_ano_str,1,4)

* Renomeia e mantém variáveis de interesse
rename município codmun6d
drop uf agro-negro
order mes_ano_str codmun6d admitidos desligados saldo

* Remove dados de janeiro e fevereiro 2020
drop if mes_ano_str=="01/2020" | mes_ano_str=="02/2020"

* Salva em .dta
save "bases/emprego.dta", replace


*------------------------------------------------------------------------------* 
* Dados vacinação
*------------------------------------------------------------------------------*

/* Essa base tem dados anonimizados de todas as vacinas aplicadas no Brasil. A
ideia é somar as vacinas por dia e por município de forma a obter dados de 
vacinação diária nos municípios do Estado de SP. */

* Importa csv
import delimited "bases/part-00000-ff63c21e-4a2f-448d-beb3-37560db64051.c000.csv", ///
	delimiter(";") clear

* Mantém variáveis de interesse
keep paciente_endereco_coibgemunicipi vacina_dataaplicacao vacina_descricao_dose

* Renomeia variáveis
rename paciente_endereco_coibgemunicipi codmun
rename vacina_dataaplicacao date_str 
rename vacina_descricao_dose vacina

* Cria discriminação por dose
gen vacina_dose1=vacina=="1ÂªÂ Dose"
gen vacina_dose2=vacina=="2ÂªÂ Dose"
gen vacina_dose_unica=vacina=="ÃnicaÂ"

* Transforma descriçao da vacina em número de vacinas
drop vacina
gen vacina=1

* Trata variável de data
gen date=date(date_str,"YMD")
format %td date
sort codmun date

* Elimina vacinas que foram tomadas por pessoas de fora de SP
tempvar cod_inicio
tostring codmun, gen(`cod_inicio')
replace `cod_inicio'=substr(`cod_inicio',1,2)
tab `cod_inicio'
drop if `cod_inicio'!="35"
drop if codmun==350000 // código de município ignorado

* Soma vacinas por data por município
gcollapse (sum) vacina*, by (codmun date)
order codmun date vacina

* Adapta nome da variável de código municipal de 6 dígitos
rename codmun codmun6d

* Restringe período amostral
drop if date>td(31aug2021)

* Salva em .dta
save "bases/vacinas.dta", replace
