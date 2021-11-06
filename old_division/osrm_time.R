

####### Funciones ########

#Get distancia recibe un data frame con latitud y longitud.
#Elimina duplicados de esos puntos (si los hay),
#le pega al data frame (hasta arriba) las coordenandas de la junta 
#y hace el trip, del cual guarda el tiempo.


travel <- function(dist_mat){
  # Greedy algorithm
  
  n <- size(dist_mat,1)
  travel_pts <- zeros(1,n+1)
  travel_pts[1] <- 1; travel_pts[(n+1)] <- 1
  aux_dist <- dist_mat
  travel_time <- 0
  
  for (i in 1:(n-1)){
    aux_dist[travel_pts[i],setdiff(travel_pts,0)] <- Inf
    # Next (closest) destination not traveled
    travel_pts[(i+1)] <- order(aux_dist[travel_pts[i],])[1]
    # Travel time
    travel_time <- travel_time + dist_mat[travel_pts[i],travel_pts[(i+1)]]
  }
  
  travel_time <- travel_time +  dist_mat[travel_pts[n],travel_pts[(n+1)]]
  
}




get_distancia <- function(puntos){
  
  #puntos <-  puntos[!duplicated(puntos),]
  
  #Al df puntos ve vamos a poner hasta arriba
  #las coordenadas de la JLCA.
  junta_local<-data.frame(19.425664, -99.145288)
  names(junta_local)<-c("lat","lon")

  puntos <- rbind(junta_local,puntos)
  
  #osrm necesita un id, entonces generamos uno.
  id <- rownames(puntos)
  puntos <- cbind(id=id, puntos)
  puntos <- puntos[c("id","lon","lat")]
  
  viaje <- osrmTable(puntos)
  tabla_duraciones <- viaje$durations
  rownames(tabla_duraciones) <- c()
  colnames(tabla_duraciones) <- c()
  
  tiempo <- data.frame(travel(tabla_duraciones))
  names(tiempo) = c("tiempo")
  
  return(tiempo)
}


#Esta función recibe una matriz, donde el PRIMER renglón es la 
#longitud y el segundo la latitud. Lo primero que hace es
#pasarlo a un data frame. 
#Hace 20 simulaciones y toma un random sample del 5%

simulaciones <- function(matrix){
  
  complete <- list()
  
  datos <- as.data.frame(t(matrix))
  names(datos) = c("lat","lon")

  for (j in 1:100){
    #Tomar un random sample
    datos_sample <- datos %>%
      sample_frac(.05) 
    
    #Vamos a poner una llave:
    #Cuando el sample sólo queda 
    if (nrow(datos_sample)>0){
      complete[[`j`]] <- get_distancia(datos_sample)
    }
    else{
      if (!is.na(datos$lat[1])){
        datos_sample <- datos %>%
          sample_n(1)
        complete[[`j`]] <- get_distancia(datos_sample)
      } 
      else{
        complete[[`j`]] <- 0
      }
    }
  }
  
  #Luego hacer un rbind para todos los elementos de complete.
  datos_finales <- do.call("rbind", complete)
  if (typeof(datos_finales) == "double"){
    print("hola")
    media <- 0
  }
  else{
    media <- mean(datos_finales$tiempo)
  }
  
  
  return(media)
}

