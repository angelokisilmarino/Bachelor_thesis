*==============================================================================*
* Título: Master

* Objetivo: roda todos os códigos de Stata da pesquisa da monografia
	
* Autor: Angelo Kisil Marino
*==============================================================================*

* Comandos iniciais
clear all
set more off
cd "C:/Users/angel/Documents/Angelo/FEA/Monografia"

do "do-files/importa_bases-v1.do"

do "do-files/une_bases-v1.do"

do "do-files/prepara_base-v1.do"

do "do-files/graficos_politicas.do"

do "do-files/analise_dados-v3.do"

do "do-files/apendiceA-v1.do"

do "do-files/apendiceB-v1.do"
