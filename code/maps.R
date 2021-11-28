### Mapas ###
rm(list = ls())
setwd("~/Angelo/FEA/Monografia/")

# Pacotes
library(tidyverse)
library(sf)
library(ggpubr)
library(readr)

# Importa bases
uf <- st_read("bases/shapefiles/BR_UF_2019.shp")
mun <- st_read("bases/shapefiles/BR_Municipios_2019.shp")
drs <- read.csv("bases/20210929_dados_covid_municipios_sp.csv", 
                sep = ";", encoding = "UTF-8")

# Seleciona shp sp
sp <- mun %>% subset(SIGLA_UF=="SP")

# Trata dados mun sp
drs <- drs %>%
  rename(CD_MUN = codigo_ibge) %>%
  select(CD_MUN, nome_ra, nome_drs, cod_ra, cod_drs) %>%
  filter(CD_MUN != 9999999) %>% # Munic?pio n?o identificado
  unique() %>%
  mutate_all(as.character)

# Adiciona dados drs e ra no shp de sp
sp <- left_join(sp, drs)

# Define tratados e controles
tratados <- c("Altinópolis", "Araraquara", "Batatais", "Bebedouro",
              "Brodowski", "Colômbia", "Cristais Paulista", "Franca",
              "Itirapuã", "Jardinópolis", "Patrocínio Paulista", 
              "Restinga", "Ribeirão Preto", "São José da Bela Vista", "Taiúva")
controles <- c("Boa Esperança do Sul", "Cássia dos Coqueiros", "Guaraci",
              "Guatapará", "Igarapava", "Ituverava", "Jaboticabal", 
              "Jeriquara", "Monte Azul Paulista", "Pitangueiras",
              "Ribeirão Bonito", "Santa Cruz da Esperança", "Santa Lúcia",
              "São Simão", "Tabatinga", "Taiaçu", "Taquaritinga", "Trabiju",
              "Vista Alegre do Alto")
drs_interesse <- c("Araraquara", "Barretos", "Franca", "Ribeirão Preto")

sp <- sp %>% 
  mutate(status = ifelse(NM_MUN %in% tratados,
                         "Treated",
                         ifelse((NM_MUN %in% controles),
                                "Control",
                                ifelse(!(NM_MUN %in% tratados) &
                                  !(NM_MUN %in% controles) &
                                  nome_drs %in% drs_interesse,
                                "Not selected control",
                                "Out of sample"))))
                    

sp$status <- factor(sp$status, levels = c("Treated", "Control", 
                                          "Not selected control",
                                          "Out of sample"))

# Mapa
mapa <- ggplot(data = sp, aes(fill = status)) +
  geom_sf() +
  scale_fill_manual(values = c("Treated" = rgb(51,153,255,maxColorValue = 255),
                               "Control" = rgb(255,102,102,maxColorValue = 255),
                               "Not selected control" = "gray",
                               "Out of sample" = "white")) +
  theme_void() +
  labs(fill = "Treatment status") +
  theme(legend.position = c(0.2,0.25),
        legend.text = element_text(size = 25),
        legend.title = element_text(size = 25, face = "bold"))
  

ggsave("graficos/mapas/mapa.pdf",
       mapa,
       width=1280/72, height=657.3333/72)

ggsave("graficos/mapas/mapa.png",
       mapa,
       width=1280/72, height=657.3333/72)



