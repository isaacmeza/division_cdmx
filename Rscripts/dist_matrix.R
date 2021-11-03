# Loading example data
library(raster) # loads shapefile

# Distances
#require(devtools)
#install_version("osrm", version = "3.0.2", repos = "http://cran.us.r-project.org")
library(osrm)
library(geodist)

# Data Analysis
library(igraph) # build network
library(spdep) # builds network

# Visualisation
library(RColorBrewer)  # for plot colour palette
library(ggplot2) # plots results
library(tmap)

#
library(dplyr)
library(tidyverse)

setwd("C:/Users/isaac/Dropbox/repos/division_cdmx")



#import data
cp_exp <- read.csv("./_aux/cp_exp_unique.csv") 

cp_exp$cp[nchar(cp_exp$cp)==3] <- paste("0" , cp_exp$cp[nchar(cp_exp$cp)==3], sep="")
cp_exp$cp[nchar(cp_exp$cp)==4] <- paste("0" , cp_exp$cp[nchar(cp_exp$cp)==4], sep="")


# Load Data

boundaries <-shapefile("./shp/CP_09CDMX_v7.shp")
boundaries_exp <-subset(boundaries, boundaries@data$d_cp %in% cp_exp$cp)


# Find adyacency matrix
nb_q <- poly2nb(boundaries_exp, queen = FALSE)
adyacency <- nb2mat(nb_q, style = "B", zero.policy = TRUE)
write_csv(as.data.frame(adyacency), "./_aux/adyacency.csv")

# Add area

crs(boundaries_exp)
crs(boundaries)

boundaries_exp$area_sqkm <- area(boundaries_exp) / 1000000
ar <- boundaries_exp@data %>% rename(cp = d_cp)

boundaries$area_sqkm <- area(boundaries) / 1000000
otroscp <- boundaries@data %>% rename(cp = d_cp) %>% mutate(otros = 1)
write_csv(otroscp, "./_aux/otroscp.csv")

cp_exp_unique_ <- merge(cp_exp,ar,by="cp", all = TRUE)
# impute median for NA's
cp_exp_unique_$area_sqkm[is.na(cp_exp_unique_$area_sqkm)]<-median(cp_exp_unique_$area_sqkm,na.rm=TRUE)


normalize <- function(x, na.rm = TRUE) {
  return((x- min(x)) /(max(x)-min(x)))
}


cp_exp_unique_ <- cp_exp_unique_ %>% mutate_at(c("num_diligencias_cpxgeo", "num_addr_cpxgeo", "area_sqkm"), normalize)





# Use OSRM's server
# options(osrm.server = "http://router.project-osrm.org/")
# Use local instance
options(osrm.server = "http://localhost:5000/")
options(osrm.profile = "car")


cp_exp_unique_$id <- seq.int(nrow(cp_exp_unique_)) 

write_csv(cp_exp_unique_, "./_aux/cp_exp_unique_.csv")


P <- osrmTable(loc = cp_exp_unique_[,c("id","lon_c","lat_c")])
PD <- geodist(cp_exp_unique_[,c("lon_c","lat_c")])
PT <- P$durations


write_csv(as.data.frame(PD), "./_aux/PD.csv")
write_csv(as.data.frame(PT), "./_aux/PT.csv")


# R--------------> STATA
################################################################################
################################################################################
################################################################################

# STATA --------------> R

#import data
sub_exp <- read.csv("./_aux/sub_exp_unique.csv") 


# Use OSRM's server
# options(osrm.server = "http://router.project-osrm.org/")
# Use local instance
# cd C:/Users/isaac/Dropbox/repos/osrm/osrm-backend
# osrm-routed --max-table-size=1500 mexico-latest.osrm
options(osrm.server = "http://localhost:5000/")
options(osrm.profile = "car")


sub_exp$id <- seq.int(nrow(sub_exp)) 

P_sub <- osrmTable(loc = sub_exp[,c("id","lon_c","lat_c")])
PD_sub <- geodist(sub_exp[,c("lon_c","lat_c")])
PT_sub <- P_sub$durations


write_csv(sub_exp, "./_aux/sub_exp_unique_.csv")
write_csv(as.data.frame(PD_sub), "./_aux/PD_sub.csv")
write_csv(as.data.frame(PT_sub), "./_aux/PT_sub.csv")

