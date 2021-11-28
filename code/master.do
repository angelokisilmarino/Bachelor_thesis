*==============================================================================*
* Título: Master

* Objetivo: roda todos os códigos de Stata da pesquisa da monografia
	
* Autor: Angelo Kisil Marino
*==============================================================================*

* Comandos iniciais
clear all
set more off
cd "C:/Users/angel/Documents/Angelo/FEA/Monografia"

do "do-files/import_data.do"

do "do-files/merge_data.do"

do "do-files/process_data.do"

do "do-files/policies_graph.do"

do "do-files/data_analysis.do"

do "do-files/appendixA.do"

do "do-files/appendixB.do"
