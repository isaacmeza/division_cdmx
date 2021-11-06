




vibora <- function(dist_mat){
  # Greedy algorithm
  
  n <- size(dist_mat,1)
  travel_pts <- zeros(1,n)
  travel_pts[1] <- 1; 
  aux_dist <- dist_mat
  
  for (i in 1:(n-1)){
    aux_dist[travel_pts[i],setdiff(travel_pts,0)] <- Inf
    # Next (closest) destination not traveled
    travel_pts[(i+1)] <- order(aux_dist[travel_pts[i],])[1]
  }
  return(travel_pts)
}





