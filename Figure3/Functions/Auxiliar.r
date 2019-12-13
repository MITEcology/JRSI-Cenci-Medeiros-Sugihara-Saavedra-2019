### To make next step prediction
Testing <- function(C, C0, X){
  c0 = C0[nrow(C0), ]
  J = C[[length(C)]]
  return(c0 + J%*%X)
}
Add_to_TS <- function(TS, x){
  return(rbind(TS, x))
}
take.coeff <- function(X, col.to.extract, original.emb){
  ### To use when prediction are made using lagged variables
  ### Take as input the sequence X of Jacobian along the attractor
  ### and the species to look at
  ### return a new sequence of Jacobian of the interaction among those species
  m = lapply(1:length(X$J), function(t, M, specie) M$J[[t]][specie,specie], 
                X, col.to.extract)
  for(i in 1:length(m)){
    colnames(m[[i]]) = rownames(m[[i]]) =original.emb
  }
  return(m)
}
naive.forecast <- function(last.point.training, test.set){
  #### Return the naive forecast, i.e., the test set is the last point of the training set
  naive.pred = matrix(0,nrow(test.set), ncol(test.set))
  for(j in 1:ncol(naive.pred)){
    naive.pred[,j] = rep(last.point.training[j], nrow(naive.pred))  
  }
  return(compute.rmse.test(naive.pred, test.set))
}
### Compute the rmse between two multivariate time series
compute.rmse.train <- function(X, Y){
  X = X[-1,]
  rmse = c()
  for(i in 1:ncol(X)){
    combine_xy = cbind(X[,i], Y[,i])
    rmse = c(rmse, sqrt(mean(unlist(lapply(1:nrow(combine_xy), 
                                           function(x, A) (A[x,1] - A[x,2])^2, combine_xy)))))
  }
  return(mean(rmse))
}
compute.rmse.test <- function(X, Y){
  rmse = c()
  for(i in 1:ncol(X)){
    combine_xy = cbind(X[,i], Y[,i])
    rmse = c(rmse, sqrt(mean(unlist(lapply(1:nrow(combine_xy), 
                                           function(x, A) (A[x,1] - A[x,2])^2, combine_xy)))))
  }
  return(mean(rmse))
}

ReadTimeSeries <- function(Nome){
  X = as.matrix(read.table(Nome))
  colnames(X) =  LETTERS[1:ncol(X)]
  return(X)
}
Standardizza <- function(X){
  ### This return y = (x-meanx)/stdx
  for(i in 1:ncol(X)){
    X[,i] = (X[,i]- mean(X[,i]))/sd(X[,i])
  }
  return(X)
}
Standardizza.test <- function(X, Y){
  ### X = test set
  ### Y = training set
  ### This return y = (x-meanY)/stdY
  for(i in 1:ncol(X)){
    X[,i] = (X[,i]- mean(Y[,i]))/sd(Y[,i])
  }
  return(X)
}
###########################
#### Here you compute the quality of the forecast as mean correlation coefficient
#### And we set to zero all those forecast that predict an extinction
MeanCorrelation <- function(TS, X){
  rho  = c()
  for(i in 1:ncol(X)){
   rho = c(rho, cor(TS[,i], X[,i]))
  }
  return(mean(rho))
}