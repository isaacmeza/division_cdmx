
library(pracma)
library(matrixStats)
library(Matrix)
library(PopED)
library(osrm)
library(dplyr)
library(tidyverse)

#setwd('E:\Enrique\I\division')
setwd('D:/Dropbox/Dropbox/P15/div/division')

# Load functions
source('osrm_time.R')
source('creacion_viboras.R')

# Use OSRM's server
# options(osrm.server = "http://router.project-osrm.org/")
# Use local instance
# cd E:\Enrique\I\osrm-backend\osrm-backend
# osrm-routed --max-table-size=20500 mexico-latest.osrm
options(osrm.server = "http://localhost:5000/")
set.seed(58238)

#viboras
df <- read.csv(file="zip_code_centroid.csv", header=TRUE, sep=",")  %>% na.omit
viaje <- osrmTable(df)
snake <- vibora(viaje$durations)

orden_zp <- data.frame(df$lon[snake] , df$lat[snake], df$zip_code[snake] )
orden_zp <- mutate(orden_zp, id = rownames(orden_zp))
names(orden_zp)=c("lon", "lat", "zip_code", "id")


write.csv(orden_zp, file = "orden_zp.csv")



pts <- read.csv(file="loc_cluster.csv", header=TRUE, sep=",") 
# %>% sample_frac(0.005)

df <- merge(select(pts,lat,lon,zip_code), select(orden_zp,zip_code,id), by='zip_code', all=FALSE)


X <- df %>% select(c("lat", "lon")) %>%
  as.matrix %>% t
zip_code <-as.numeric(df$id)%>%
  as.matrix  


iter <- 1
vr0 <- Inf

corte <- zeros(59,1)
tiempo <- zeros(60,1)

uzp <- size(unique(zip_code),1)
step <- floor(uzp/60)
corte[1] <- step
tiempo[1] <- simulaciones(X[,zip_code<=corte[1]])
for (j in 2:59) {
  corte[j] <- corte[(j-1)]+step+round(rand(1))
  tiempo[j] <- simulaciones(X[,zip_code>corte[(j-1)] & zip_code<=corte[j]])
  while (tiempo[j]>2*tiempo[(j-1)]){
    corte[(j-1)] <- corte[(j-1)]+1
    tiempo[(j-1)] <- simulaciones(X[,zip_code>corte[(j-2)] & zip_code<=corte[(j-1)]])
    corte[j] <- corte[j]-1
    tiempo[j] <- simulaciones(X[,zip_code>corte[(j-1)] & zip_code<=corte[j]])
  }
  print(t(tiempo))
}
tiempo[60] <- simulaciones(X[,zip_code>corte[59]])
vr <- var(tiempo)
print(vr)
cut <- mean(tiempo)


############################################################################

while (vr < vr0 && iter<=100) {
  corte0 <- corte
  tiempo0 <- tiempo
  vr0 <- vr
  
  corte <- zeros(59,1)
  tiempo <- zeros(60,1)
  
  l0 <- 1
  for (j in 1:59) {
    print(iter)
    print(j)
    l1 <- l0 
    times <- 0
    while (times<cut && l1<uzp){
      times <- simulaciones(X[,zip_code>=l0 & zip_code<=l1])
      l1 <- l1+1
      print(l1)
    }
    times0 <- simulaciones(X[,zip_code>=l0 & zip_code<=(l1-1)])
    if (abs(times-cut)<abs(times0<cut)){
      corte[j] <- l1
      l0 <- l1 + 1
      tiempo[j] <- times  
    } else {
      corte[j] <- l1 - 1
      l0 <- l1 
      tiempo[j] <- times0 
    } 
  }
  
  tiempo[60] <- simulaciones(X[,zip_code>=l0])
  
  vr <- var(tiempo)
  print(vr)
  cut <- mean(tiempo)
  iter <- iter + 1
  
}

vr <- vr0
corte <- corte0   
tiempo <- tiempo0


############################################################################

vr0 <- Inf
while (vr<vr0) {
  vr0 <- vr
  corte0 <- corte
  tiempo0 <- tiempo
  if (tiempo[1]<tiempo[2]){
    corte[1] <- corte[1]+1
  } else {
    corte[1] <- corte[1]-1
  }
  tiempo[1] <- simulaciones(X[, zip_code<=corte[1]])
  tiempo[2] <- simulaciones(X[,zip_code>corte[1] & zip_code<=corte[2]])
  vr <- var(tiempo)
}
vr <- vr0
corte <- corte0
tiempo <- tiempo0


for (j in 2:58) {
  print(j)
  vr0 <- Inf
  while (vr<vr0) {
    vr0 <- vr
    corte0 <- corte
    tiempo0 <- tiempo
    if (tiempo[j]<tiempo[(j+1)]){
      corte[j] <- corte[j]+1
    } else {
      corte[j] <- corte[j]-1
    }
    tiempo[j] <- simulaciones(X[,zip_code>corte[(j-1)] & zip_code<=corte[j]])
    tiempo[(j+1)] <- simulaciones(X[,zip_code>corte[j] & zip_code<=corte[(j+1)]])
    vr <- var(tiempo)
  }
  vr <- vr0
  corte <- corte0
  tiempo <- tiempo0
}


vr0 <- Inf
while (vr<vr0) {
  vr0 <- vr
  corte0 <- corte
  tiempo0 <- tiempo
  if (tiempo[59]<tiempo[60]){
    corte[59] <- corte[59]+1
  } else {
    corte[59] <- corte[59]-1
  }
  tiempo[59] <- simulaciones(X[,zip_code>corte[58] & zip_code<=corte[59]])
  tiempo[60] <- simulaciones(X[,zip_code>corte[59]])
  vr <- var(tiempo)
}
vr <- vr0
corte <- corte0
tiempo <- tiempo0

############################################################################


vr0 <- Inf
mn <- order(tiempo)[1]
while (vr<vr0){
  vr0 <- vr
  corte0 <- corte
  tiempo0 <- tiempo
  
  corte[mn:59] <- corte[mn:59] + 1
  for (j in mn:59){
    print(j)
    if (j==1){
      tiempo[j] <- simulaciones(X[, zip_code<=corte[1]])
    } else {
      tiempo[j] <- simulaciones(X[,zip_code>corte[(j-1)] & zip_code<=corte[j]])
    }
  }
  tiempo[60] <- simulaciones(X[,zip_code>corte[59]])
  vr <- var(tiempo)
}

vr <- vr0
corte <- corte0
tiempo <- tiempo0


##########################################################################

vr0 <- Inf
while (vr<vr0) {
  vr0 <- vr
  corte0 <- corte
  tiempo0 <- tiempo
  if (tiempo[1]<tiempo[2]){
    corte[1] <- corte[1]+1
  } else {
    corte[1] <- corte[1]-1
  }
  tiempo[1] <- simulaciones(X[, zip_code<=corte[1]])
  tiempo[2] <- simulaciones(X[,zip_code>corte[1] & zip_code<=corte[2]])
  vr <- var(tiempo)
}
vr <- vr0
corte <- corte0
tiempo <- tiempo0


for (j in 2:58) {
  print(j)
  vr0 <- Inf
  while (vr<vr0) {
    vr0 <- vr
    corte0 <- corte
    tiempo0 <- tiempo
    if (tiempo[j]<tiempo[(j+1)]){
      corte[j] <- corte[j]+1
    } else {
      corte[j] <- corte[j]-1
    }
    tiempo[j] <- simulaciones(X[,zip_code>corte[(j-1)] & zip_code<=corte[j]])
    tiempo[(j+1)] <- simulaciones(X[,zip_code>corte[j] & zip_code<=corte[(j+1)]])
    vr <- var(tiempo)
  }
  vr <- vr0
  corte <- corte0
  tiempo <- tiempo0
}


vr0 <- Inf
while (vr<vr0) {
  vr0 <- vr
  corte0 <- corte
  tiempo0 <- tiempo
  if (tiempo[59]<tiempo[60]){
    corte[59] <- corte[59]+1
  } else {
    corte[59] <- corte[59]-1
  }
  tiempo[59] <- simulaciones(X[,zip_code>corte[58] & zip_code<=corte[59]])
  tiempo[60] <- simulaciones(X[,zip_code>corte[59]])
  vr <- var(tiempo)
}
vr <- vr0
corte <- corte0
tiempo <- tiempo0

##########################################################################



vr0 <- Inf
mx <- order(-tiempo)[1] - 1
while (vr<vr0){
  vr0 <- vr
  corte0 <- corte
  tiempo0 <- tiempo
  
  corte[mx:1] <- corte[mx:1] + 1
  for (j in mx:1){
    if (j==1){
      tiempo[j] <- simulaciones(X[, zip_code<=corte[1]])
    } else {
      tiempo[j] <- simulaciones(X[,zip_code>corte[(j-1)] & zip_code<=corte[j]])
    }
  }
  tiempo[60] <- simulaciones(X[,zip_code>corte[59]])
  vr <- var(tiempo)
}

vr <- vr0
corte <- corte0
tiempo <- tiempo0


##########################################################################

vr0 <- Inf
while (vr<vr0) {
  vr0 <- vr
  corte0 <- corte
  tiempo0 <- tiempo
  if (tiempo[1]<tiempo[2]){
    corte[1] <- corte[1]+1
  } else {
    corte[1] <- corte[1]-1
  }
  tiempo[1] <- simulaciones(X[, zip_code<=corte[1]])
  tiempo[2] <- simulaciones(X[,zip_code>corte[1] & zip_code<=corte[2]])
  vr <- var(tiempo)
}
vr <- vr0
corte <- corte0
tiempo <- tiempo0


for (j in 2:58) {
  print(j)
  vr0 <- Inf
  while (vr<vr0) {
    vr0 <- vr
    corte0 <- corte
    tiempo0 <- tiempo
    if (tiempo[j]<tiempo[(j+1)]){
      corte[j] <- corte[j]+1
    } else {
      corte[j] <- corte[j]-1
    }
    tiempo[j] <- simulaciones(X[,zip_code>corte[(j-1)] & zip_code<=corte[j]])
    tiempo[(j+1)] <- simulaciones(X[,zip_code>corte[j] & zip_code<=corte[(j+1)]])
    vr <- var(tiempo)
  }
  vr <- vr0
  corte <- corte0
  tiempo <- tiempo0
}


vr0 <- Inf
while (vr<vr0) {
  vr0 <- vr
  corte0 <- corte
  tiempo0 <- tiempo
  if (tiempo[59]<tiempo[60]){
    corte[59] <- corte[59]+1
  } else {
    corte[59] <- corte[59]-1
  }
  tiempo[59] <- simulaciones(X[,zip_code>corte[58] & zip_code<=corte[59]])
  tiempo[60] <- simulaciones(X[,zip_code>corte[59]])
  vr <- var(tiempo)
}
vr <- vr0
corte <- corte0
tiempo <- tiempo0

##########################################################################


#Juntar el área con tiempo mínimo y dividir el área con tiempo máximo
uzp <- size(unique(zip_code),1)
vr0 <- Inf
while (vr<vr0){
  vr0 <- vr
  corte0 <- corte
  tiempo0 <- tiempo
  
  mn <- order(tiempo)[1]
  mx <- order(-tiempo)[1]-1
  
  #Merge & Split
  if (mn==1 && mx==59){
    corte[mn:(mx-1)] <- corte[(mn+1):mx]
    corte[mx] <- round((uzp+corte[mx])/2)
    
    tiempo[mx] <- simulaciones(X[,zip_code>corte[(mx-1)] & zip_code<=corte[mx]])
    tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx]])  
    
    vr_aux0 <- Inf
    vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))              
    while (vr_aux<vr_aux0){
      vr_aux0 <- vr_aux
      if (tiempo[mx]<tiempo[(mx+1)]){
        corte[mx] <- corte[mx]+1
      } else {
        corte[mx] <- corte[mx]-1
      }
      tiempo[mx] <- simulaciones(X[,zip_code>corte[(mx-1)] & zip_code<=corte[mx]])
      tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx]])
      vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))
    }
  } 
  if (mn==1 && mx<59){
    corte[mn:(mx-1)] <- corte[(mn+1):mx]
    corte[mx] <- round((corte[(mx+1)]+corte[mx])/2)
    
    tiempo[mx] <- simulaciones(X[,zip_code>corte[(mx-1)] & zip_code<=corte[mx]])
    tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
    
    vr_aux0 <- Inf
    vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))              
    while (vr_aux<vr_aux0){
      vr_aux0 <- vr_aux
      if (tiempo[mx]<tiempo[(mx+1)]){
        corte[mx] <- corte[mx]+1
      } else {
        corte[mx] <- corte[mx]-1
      }
      tiempo[mx] <- simulaciones(X[,zip_code>corte[(mx-1)] & zip_code<=corte[mx]])
      tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
      vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))
    }
  }
  if (mn==59 && mx==1){
    corte[(mx+1):mn] <- corte[mx:(mn-1)]
    corte[mx] <- round(corte[mx]/2)
    
    tiempo[mx] <- simulaciones(X[, zip_code<=corte[mx]])
    tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
    
    vr_aux0 <- Inf
    vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))              
    while (vr_aux<vr_aux0){
      vr_aux0 <- vr_aux
      if (tiempo[mx]<tiempo[(mx+1)]){
        corte[mx] <- corte[mx]+1
      } else {
        corte[mx] <- corte[mx]-1
      }
      tiempo[mx] <- simulaciones(X[, zip_code<=corte[mx]])
      tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
      vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))
    }
  }
  if (mn==59 && mx<59){
    corte[(mx+1):mn] <- corte[mx:(mn-1)]
    corte[mx] <- round((corte[(mx+1)]+corte[mx])/2)
    
    tiempo[mx] <- simulaciones(X[, zip_code<=corte[mx]])
    tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
    
    vr_aux0 <- Inf
    vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))              
    while (vr_aux<vr_aux0){
      vr_aux0 <- vr_aux
      if (tiempo[mx]<tiempo[(mx+1)]){
        corte[mx] <- corte[mx]+1
      } else {
        corte[mx] <- corte[mx]-1
      }
      tiempo[mx] <- simulaciones(X[,zip_code>corte[(mx-1)] & zip_code<=corte[mx]])
      tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
      vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))
    }
  }
  if (mn<59 && mx==59){
    corte[mn:(mx-1)] <- corte[(mn+1):mx]
    corte[mx] <- round((uzp+corte[mx])/2)

    tiempo[mx] <- simulaciones(X[,zip_code>corte[(mx-1)] & zip_code<=corte[mx]])
    tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx]])

    vr_aux0 <- Inf
    vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))              
    while (vr_aux<vr_aux0){
      vr_aux0 <- vr_aux
      if (tiempo[mx]<tiempo[(mx+1)]){
        corte[mx] <- corte[mx]+1
      } else {
        corte[mx] <- corte[mx]-1
      }
      tiempo[mx] <- simulaciones(X[,zip_code>corte[(mx-1)] & zip_code<=corte[mx]])
      tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx]])
      vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))
    }
  }
  if (mn<59 && mx==1){
    corte[(mx+1):mn] <- corte[mx:(mn-1)]
    corte[mx] <- round(corte[mx]/2)
    
    tiempo[mx] <- simulaciones(X[, zip_code<=corte[mx]])
    tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
    
    vr_aux0 <- Inf
    vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))              
    while (vr_aux<vr_aux0){
      vr_aux0 <- vr_aux
      if (tiempo[mx]<tiempo[(mx+1)]){
        corte[mx] <- corte[mx]+1
      } else {
        corte[mx] <- corte[mx]-1
      }
      tiempo[mx] <- simulaciones(X[, zip_code<=corte[mx]])
      tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
      vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))
    }
  }
  if (mn<59 && mx<59) {
    corte[mn:(mx-1)] <- corte[(mn+1):mx]
    corte[mx] <- round((corte[(mx+1)]+corte[mx])/2)
    
    tiempo[mx] <- simulaciones(X[,zip_code>corte[(mx-1)] & zip_code<=corte[mx]])
    tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
    
    vr_aux0 <- Inf
    vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))              
    while (vr_aux<vr_aux0){
      vr_aux0 <- vr_aux
      if (tiempo[mx]<tiempo[(mx+1)]){
        corte[mx] <- corte[mx]+1
      } else {
        corte[mx] <- corte[mx]-1
      }
      tiempo[mx] <- simulaciones(X[,zip_code>corte[(mx-1)] & zip_code<=corte[mx]])
      tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
      vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))
    }
  }

  
  for (j in 1:59){
    print(j)
    if (j==1){
      tiempo[j] <- simulaciones(X[, zip_code<=corte[1]])
    } else {
      tiempo[j] <- simulaciones(X[,zip_code>corte[(j-1)] & zip_code<=corte[j]])
    }
  }
  tiempo[60] <- simulaciones(X[,zip_code>corte[59]])
  vr <- var(tiempo)
  print(vr)
}  

vr <- vr0
corte <- corte0
tiempo <- tiempo0

##########################################################################

vr0 <- Inf
while (vr<vr0) {
  vr0 <- vr
  corte0 <- corte
  tiempo0 <- tiempo
  if (tiempo[1]<tiempo[2]){
    corte[1] <- corte[1]+1
  } else {
    corte[1] <- corte[1]-1
  }
  tiempo[1] <- simulaciones(X[, zip_code<=corte[1]])
  tiempo[2] <- simulaciones(X[,zip_code>corte[1] & zip_code<=corte[2]])
  vr <- var(tiempo)
}
vr <- vr0
corte <- corte0
tiempo <- tiempo0


for (j in 2:58) {
  print(j)
  vr0 <- Inf
  while (vr<vr0) {
    vr0 <- vr
    corte0 <- corte
    tiempo0 <- tiempo
    if (tiempo[j]<tiempo[(j+1)]){
      corte[j] <- corte[j]+1
    } else {
      corte[j] <- corte[j]-1
    }
    tiempo[j] <- simulaciones(X[,zip_code>corte[(j-1)] & zip_code<=corte[j]])
    tiempo[(j+1)] <- simulaciones(X[,zip_code>corte[j] & zip_code<=corte[(j+1)]])
    vr <- var(tiempo)
  }
  vr <- vr0
  corte <- corte0
  tiempo <- tiempo0
}


vr0 <- Inf
while (vr<vr0) {
  vr0 <- vr
  corte0 <- corte
  tiempo0 <- tiempo
  if (tiempo[59]<tiempo[60]){
    corte[59] <- corte[59]+1
  } else {
    corte[59] <- corte[59]-1
  }
  tiempo[59] <- simulaciones(X[,zip_code>corte[58] & zip_code<=corte[59]])
  tiempo[60] <- simulaciones(X[,zip_code>corte[59]])
  vr <- var(tiempo)
}
vr <- vr0
corte <- corte0
tiempo <- tiempo0

##########################################################################



#Juntar el área con tiempo mínimo y dividir el área con tiempo máximo
uzp <- size(unique(zip_code),1)
vr0 <- Inf
while (vr<vr0){
  vr0 <- vr
  corte0 <- corte
  tiempo0 <- tiempo
  
  mn <- order(tiempo)[1]
  mx <- order(-tiempo)[1]-1
  
  #Merge & Split
  if (mn==1 && mx==59){
    corte[mn:(mx-1)] <- corte[(mn+1):mx]
    corte[mx] <- round((uzp+corte[mx])/2)
    
    tiempo[mx] <- simulaciones(X[,zip_code>corte[(mx-1)] & zip_code<=corte[mx]])
    tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx]])  
    
    vr_aux0 <- Inf
    vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))              
    while (vr_aux<vr_aux0){
      vr_aux0 <- vr_aux
      if (tiempo[mx]<tiempo[(mx+1)]){
        corte[mx] <- corte[mx]+1
      } else {
        corte[mx] <- corte[mx]-1
      }
      tiempo[mx] <- simulaciones(X[,zip_code>corte[(mx-1)] & zip_code<=corte[mx]])
      tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx]])
      vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))
    }
  } 
  if (mn==1 && mx<59){
    corte[mn:(mx-1)] <- corte[(mn+1):mx]
    corte[mx] <- round((corte[(mx+1)]+corte[mx])/2)
    
    tiempo[mx] <- simulaciones(X[,zip_code>corte[(mx-1)] & zip_code<=corte[mx]])
    tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
    
    vr_aux0 <- Inf
    vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))              
    while (vr_aux<vr_aux0){
      vr_aux0 <- vr_aux
      if (tiempo[mx]<tiempo[(mx+1)]){
        corte[mx] <- corte[mx]+1
      } else {
        corte[mx] <- corte[mx]-1
      }
      tiempo[mx] <- simulaciones(X[,zip_code>corte[(mx-1)] & zip_code<=corte[mx]])
      tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
      vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))
    }
  }
  if (mn==59 && mx==1){
    corte[(mx+1):mn] <- corte[mx:(mn-1)]
    corte[mx] <- round(corte[mx]/2)
    
    tiempo[mx] <- simulaciones(X[, zip_code<=corte[mx]])
    tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
    
    vr_aux0 <- Inf
    vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))              
    while (vr_aux<vr_aux0){
      vr_aux0 <- vr_aux
      if (tiempo[mx]<tiempo[(mx+1)]){
        corte[mx] <- corte[mx]+1
      } else {
        corte[mx] <- corte[mx]-1
      }
      tiempo[mx] <- simulaciones(X[, zip_code<=corte[mx]])
      tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
      vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))
    }
  }
  if (mn==59 && mx<59){
    corte[(mx+1):mn] <- corte[mx:(mn-1)]
    corte[mx] <- round((corte[(mx+1)]+corte[mx])/2)
    
    tiempo[mx] <- simulaciones(X[, zip_code<=corte[mx]])
    tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
    
    vr_aux0 <- Inf
    vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))              
    while (vr_aux<vr_aux0){
      vr_aux0 <- vr_aux
      if (tiempo[mx]<tiempo[(mx+1)]){
        corte[mx] <- corte[mx]+1
      } else {
        corte[mx] <- corte[mx]-1
      }
      tiempo[mx] <- simulaciones(X[,zip_code>corte[(mx-1)] & zip_code<=corte[mx]])
      tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
      vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))
    }
  }
  if (mn<59 && mx==59){
    corte[mn:(mx-1)] <- corte[(mn+1):mx]
    corte[mx] <- round((uzp+corte[mx])/2)
    
    tiempo[mx] <- simulaciones(X[,zip_code>corte[(mx-1)] & zip_code<=corte[mx]])
    tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx]])
    
    vr_aux0 <- Inf
    vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))              
    while (vr_aux<vr_aux0){
      vr_aux0 <- vr_aux
      if (tiempo[mx]<tiempo[(mx+1)]){
        corte[mx] <- corte[mx]+1
      } else {
        corte[mx] <- corte[mx]-1
      }
      tiempo[mx] <- simulaciones(X[,zip_code>corte[(mx-1)] & zip_code<=corte[mx]])
      tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx]])
      vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))
    }
  }
  if (mn<59 && mx==1){
    corte[(mx+1):mn] <- corte[mx:(mn-1)]
    corte[mx] <- round(corte[mx]/2)
    
    tiempo[mx] <- simulaciones(X[, zip_code<=corte[mx]])
    tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
    
    vr_aux0 <- Inf
    vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))              
    while (vr_aux<vr_aux0){
      vr_aux0 <- vr_aux
      if (tiempo[mx]<tiempo[(mx+1)]){
        corte[mx] <- corte[mx]+1
      } else {
        corte[mx] <- corte[mx]-1
      }
      tiempo[mx] <- simulaciones(X[, zip_code<=corte[mx]])
      tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
      vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))
    }
  }
  if (mn<59 && mx<59) {
    corte[mn:(mx-1)] <- corte[(mn+1):mx]
    corte[mx] <- round((corte[(mx+1)]+corte[mx])/2)
    
    tiempo[mx] <- simulaciones(X[,zip_code>corte[(mx-1)] & zip_code<=corte[mx]])
    tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
    
    vr_aux0 <- Inf
    vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))              
    while (vr_aux<vr_aux0){
      vr_aux0 <- vr_aux
      if (tiempo[mx]<tiempo[(mx+1)]){
        corte[mx] <- corte[mx]+1
      } else {
        corte[mx] <- corte[mx]-1
      }
      tiempo[mx] <- simulaciones(X[,zip_code>corte[(mx-1)] & zip_code<=corte[mx]])
      tiempo[(mx+1)] <- simulaciones(X[,zip_code>corte[mx] & zip_code<=corte[(mx+1)]])
      vr_aux <- var(c(tiempo[mx], tiempo[(mx+1)]))
    }
  }
  
  
  for (j in 1:59){
    print(j)
    if (j==1){
      tiempo[j] <- simulaciones(X[, zip_code<=corte[1]])
    } else {
      tiempo[j] <- simulaciones(X[,zip_code>corte[(j-1)] & zip_code<=corte[j]])
    }
  }
  tiempo[60] <- simulaciones(X[,zip_code>corte[59]])
  vr <- var(tiempo)
  print(vr)
}  

vr <- vr0
corte <- corte0
tiempo <- tiempo0

##########################################################################

vr0 <- Inf
while (vr<vr0) {
  vr0 <- vr
  corte0 <- corte
  tiempo0 <- tiempo
  if (tiempo[1]<tiempo[2]){
    corte[1] <- corte[1]+1
  } else {
    corte[1] <- corte[1]-1
  }
  tiempo[1] <- simulaciones(X[, zip_code<=corte[1]])
  tiempo[2] <- simulaciones(X[,zip_code>corte[1] & zip_code<=corte[2]])
  vr <- var(tiempo)
}
vr <- vr0
corte <- corte0
tiempo <- tiempo0


for (j in 2:58) {
  print(j)
  vr0 <- Inf
  while (vr<vr0) {
    vr0 <- vr
    corte0 <- corte
    tiempo0 <- tiempo
    if (tiempo[j]<tiempo[(j+1)]){
      corte[j] <- corte[j]+1
    } else {
      corte[j] <- corte[j]-1
    }
    tiempo[j] <- simulaciones(X[,zip_code>corte[(j-1)] & zip_code<=corte[j]])
    tiempo[(j+1)] <- simulaciones(X[,zip_code>corte[j] & zip_code<=corte[(j+1)]])
    vr <- var(tiempo)
  }
  vr <- vr0
  corte <- corte0
  tiempo <- tiempo0
}


vr0 <- Inf
while (vr<vr0) {
  vr0 <- vr
  corte0 <- corte
  tiempo0 <- tiempo
  if (tiempo[59]<tiempo[60]){
    corte[59] <- corte[59]+1
  } else {
    corte[59] <- corte[59]-1
  }
  tiempo[59] <- simulaciones(X[,zip_code>corte[58] & zip_code<=corte[59]])
  tiempo[60] <- simulaciones(X[,zip_code>corte[59]])
  vr <- var(tiempo)
}
vr <- vr0
corte <- corte0
tiempo <- tiempo0

##########################################################################

df$cluster <- 0
df$id <- as.numeric(df$id)

df$cluster[df$id<=corte[1]] <- 1
for (j in 2:59) {
  df$cluster[df$id>corte[(j-1)] & df$id<=corte[j]] <- j
}
df$cluster[df$id>corte[59]] <- 60



loc_cluster <- df[,c(2,3,1,4,5)]

write.csv(loc_cluster, file = "loc_cluster_final2.csv")


Y <- loc_cluster %>% select(c("lat", "lon")) %>%
  as.matrix %>% t
cluster_Y <-as.numeric(loc_cluster$cluster)%>%
  as.matrix  

time_pro <- size(60,1)
for (j in 1:60){
  print(j)
  time_pro[j] <- simulaciones(Y[,cluster_Y==j])
  print(time_pro[j])
  print(sum(cluster_Y==j))
}
var(time_pro)

