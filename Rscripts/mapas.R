require(tidyverse)
require(stringr)
require(sf)
require(readxl)
library(taRifx)

setwd("C:/Users/isaac/Dropbox/repos/division_cdmx")


poligonos <- st_read('./shp/CP_09CdMx_v7.shp', stringsAsFactors = F) %>%
  rename(cp = d_cp)

regiones <- read.csv('./tabla_dinamica.csv') 
regiones$cp[nchar(regiones$cp)==3] <- paste("0" , regiones$cp[nchar(regiones$cp)==3], sep="")
regiones$cp[nchar(regiones$cp)==4] <- paste("0" , regiones$cp[nchar(regiones$cp)==4], sep="")



listas_regiones <- list(c(2,13,12))

for (i in c(1:length(listas_regiones))){
  regionesMapa <- listas_regiones[[i]]
  total <- length(regionesMapa)
  min <-min( regionesMapa[regionesMapa!=min(regionesMapa)] )
  temporal <- subset(regiones, new_region %in% regionesMapa)
  
  
  pol <- poligonos %>%
    inner_join(temporal) %>%
    mutate(division = as.factor(new_region))
  
  cps <- st_centroid(pol) 
  cps <- cbind(cps, st_coordinates(st_centroid(pol$geometry)))
  
  mapa <-  ggplot() +
    geom_sf(data=poligonos)  +    
    geom_sf(data=pol, aes(fill = division))  +
    geom_text(data=cps, aes(x=X, y=Y, label=cp), size=0.5)
  
  ggsave(paste0('./tempfig/Region',eval(total),'-',eval(min),'.pdf'), mapa, device='pdf')
}


################################################################################


regiones_tuning <- read_xlsx('./tabla_dinamica.xlsx', "raw_data") 
regiones_tuning$cp[nchar(regiones_tuning$cp)==3] <- paste("0" , regiones_tuning$cp[nchar(regiones_tuning$cp)==3], sep="")
regiones_tuning$cp[nchar(regiones_tuning$cp)==4] <- paste("0" , regiones_tuning$cp[nchar(regiones_tuning$cp)==4], sep="")
regiones_tuning$new_region <- destring(regiones_tuning$new_region_tuning)



listas_regiones <- list(c(4,17,23,24))
  
for (i in c(1:length(listas_regiones))){
  regionesMapa <- listas_regiones[[i]]
  total <- length(regionesMapa)
  min <-min( regionesMapa[regionesMapa!=min(regionesMapa)] )
  temporal <- subset(regiones_tuning, new_region %in% regionesMapa)
  
  
  pol <- poligonos %>%
    inner_join(temporal) %>%
    mutate(division = as.factor(new_region))
  
  cps <- st_centroid(pol) 
  cps <- cbind(cps, st_coordinates(st_centroid(pol$geometry)))
  
  mapa <-  ggplot() +
    geom_sf(data=poligonos)  +    
    geom_sf(data=pol, aes(fill = division))  +
    geom_text(data=cps, aes(x=X, y=Y, label=cp), size=0.5)
  
  ggsave(paste0('./mapas/Region_adj_',eval(total),'-',eval(min),'.pdf'), mapa, device='pdf')
}
