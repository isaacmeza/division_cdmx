################
### CUCHAREO ###
################

#Set up
remove(list = ls())
x <- c("sf","tidyverse","readxl","haven","pracma","matrixStats","Matrix",
       "PopED","dplyr","osrm")
lapply(x, library, character.only = TRUE)

library(purrr)

setwd("E:\\Enrique\\I\\division")

#Fronteras
load("vecinos.RData")

#Códigos postales
cluster_zip <- read.csv("loc_cluster_final2.csv") %>% 
  dplyr::count(zip_code, cluster) %>%
  dplyr::select(-c("n"))
cluster_zip <- data.frame(cluster_zip)

# La base
direcciones <- read.csv("loc_cluster_final2.csv") %>%
  dplyr::select(-c("id","X"))


direcciones_sample <- direcciones %>%
  sample_frac(.10) %>%
  select(-c("zip_code"))

#Summary Stats de base
cluster_summary <- simulaciones(direcciones_sample)

#Dos funciones: 
#La primera función toma como input la base de direcciones,y un cluster.
#Busca al cluster más cercano y con la duration más pequeña,
#al cluster original le da uno de sus zip codes al de la duration más pequeña.
#después vuelve a calcular las simulaciones. 


# Primera función: Quitar zip codes
remove_zip_codes <- function(datos,zona){

  #Nos quedamos con los zip codes de la zona
  clusterMAX <- subset(fronteras,cluster==zona) %>%
    dplyr::rename(zip_Main = zip_code) %>%
    dplyr::mutate(zip_code = as.numeric(zip_Second)) %>%
    select(-c("zip_Second","cluster")) %>%
    left_join(cluster_zip,by="zip_code") %>%
    filter(!is.na(cluster),
           cluster != zona) %>%
    left_join(cluster_summary,by="cluster")
  
  #vamos a escoger el cluster con el duration MÁS PEQUEÑO
  attach(clusterMAX)
  segundo <- clusterMAX[order(clusterMAX$duration),]
  segundo <- segundo$cluster[1]
  clusterMAX <- subset(clusterMAX,cluster==segundo) 
  
  #Ya que tenemos al más pequeño, vemos que tiene varios...
  #Entonces vamos a hacer un loop:
  
  renglones <- nrow(clusterMAX)
  desviacion <- list()

  for (j in 1:renglones){
    vecino <- clusterMAX[`j`,]
    direcciones2 <- read.csv("loc_cluster_final.csv") %>%
      dplyr::select(-c("id","X"))
    #Cuando el código postal sea igual al del vecino, se lo quitamos a zona. 
    #Y se lo damos a segundo. 
    direcciones2$cluster[direcciones2$zip_code == vecino$zip_Main] <- segundo 
    direcciones_sample2 <- direcciones2 %>%
      group_by(cluster) %>%
      sample_frac(.05) %>%
      ungroup()
    cluster_summary2 <- simulaciones(direcciones_sample2)
    desviacion[[`j`]] <- var(cluster_summary2$duration)
  }
  vecinos <- do.call("rbind",desviacion)
  ganador <- which.min(vecinos)
  vecino <- clusterMAX[ganador,]
  sd_vecino <-  desviacion[[ganador]]

  ganadores <- list()
  if (sd_vecino < original) {
    ganadores[[1]] <- sd_vecino 
    #Volvemos a cargar la base de direcciones.
    direcciones2 <- read.csv("loc_cluster_final.csv") %>%
      dplyr::select(-c("id","X"))
    direcciones2$cluster[direcciones2$zip_code == vecino$zip_code] <- segundo 
    ganadores[[2]] <- direcciones2
    ganadores[[3]] <- cluster_summary2
    ganadores[[4]] <- vecino$cluster
    return(ganadores)
  } else{
    yx <- "Sin cambios"
    return(print(yx))
  }
}

#Segunda Función. 
#Toma el más pequeño y le pega de su vecino con la duration más alto uno de sus zip codes

add_zip_codes <- function(datos,zona){

  #Nos quedamos con los zip codes de la zona
  clusterMAX <- subset(fronteras,cluster==zona) %>%
    dplyr::rename(zip_Main = zip_code) %>%
    dplyr::mutate(zip_code = as.numeric(zip_Second)) %>%
    select(-c("zip_Second","cluster")) %>%
    left_join(cluster_zip,by="zip_code") %>%
    filter(!is.na(cluster),
           cluster != zona) %>%
    left_join(cluster_summary,by="cluster")
  
  #vamos a escoger el cluster con el duration MÁS GRANDE
  attach(clusterMAX)
  segundo <- clusterMAX[order(-clusterMAX$duration),]
  segundo <- segundo$cluster[1]
  clusterMAX <- subset(clusterMAX,cluster==segundo)
  
  #Ya que tenemos al más pequeño, vemos que tiene varios...
  #Entonces vamos a hacer un loop:
  
  renglones <- nrow(clusterMAX)
  desviacion <- list()
  
  for (j in 1:renglones){
    vecino <- clusterMAX[1,]
    direcciones2 <- read.csv("loc_cluster_final.csv") %>%
      dplyr::select(-c("id","X"))
    #Aquí está la diferenia más grande con remove_zip_code:
    #Cuandoe l zip code sea igual al del vecino, se lo quitamos al vecino!!!
    direcciones2$cluster[direcciones2$zip_code == vecino$zip_code] <- zona
    direcciones_sample2 <- direcciones2 %>%
      group_by(cluster) %>%
      sample_frac(.1) %>%
      ungroup()
    cluster_summary2 <- simulaciones(direcciones_sample2)
    desviacion[[`j`]] <- var(cluster_summary2$duration)
  }
  vecinos <- do.call("rbind",desviacion)
  ganador <- which.min(vecinos)
  vecino <- clusterMAX[ganador,]
  sd_vecino <-  desviacion[[ganador]]
  
  ganadores <- list()
  if (sd_vecino < original) {
    ganadores[[1]] <- sd_vecino 
    #Volvemos a cargar la base de direcciones.
    direcciones2 <- read.csv("loc_cluster_final.csv") %>%
      dplyr::select(-c("id","X"))
    direcciones2$cluster[direcciones2$zip_code == vecino$zip_code] <- zona
    ganadores[[2]] <- direcciones2
    ganadores[[3]] <- cluster_summary2
    ganadores[[4]] <- vecino$cluster
    return(ganadores)
  } else{
    yx <- "Sin cambios"
    print(yx)
  }
}

