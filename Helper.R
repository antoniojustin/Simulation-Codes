#entropy
entropy_s = function(incidence, probability){
  idx_1 = which(incidence == 1)
  idx_0 = which(incidence == 0)
  return(-(sum(log(probability[idx_1])) + sum(log(1 - probability[idx_0])))/length(incidence))
}

# Brier score
brier_s = function(incidence, probability){
  return(sum((abs(incidence - probability))^2)/length(incidence))
}

# Helper function
named.list <- function(...) { 
  l <- setNames( list(...) , as.character( match.call()[-1]) ) 
  l
}