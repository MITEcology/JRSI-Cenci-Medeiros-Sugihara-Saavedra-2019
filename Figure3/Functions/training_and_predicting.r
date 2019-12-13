training.function <- function(alpha, ts, trg.list, em, para, regression.type){
  Lavoratori = detectCores() - 1
  cl <- makeCluster(Lavoratori, type = "FORK")
  RegressionType = 'ELNET_fit'
  output = BestModelLOOCV(cl, ts, trg.list, em, para, regression.type, alpha)
  elements = output$BestCoefficients
  Parameters = output$BestParameters
  stopCluster(cl)
  return(list(coefficenti = elements, regularization.parameters = Parameters))
}

prediction.function <- function(J, tht,lmd, ts, horizon, iter, ts.original, all.data){
  
  pred = make.forecast(J, tht,lmd, ts,horizon)
  true.test = Standardizza.test(as.matrix(all.data[(original.training.length+iter):(original.training.length+iter+horizon-1), ]), 
                                as.matrix(ts.original))
  rmse.test = unlist(lapply(1:horizon, function(x, X,Y) sqrt(mean( (X[1:x, ] - Y[1:x, ])^2 )),
                            true.test, pred))
  #########
  naive.forecast = matrix(0, horizon, ncol(ts))
  for(k in 1:ncol(naive.forecast)){
    naive.forecast[,k] = rep(ts[nrow(ts)], horizon)
  }
  rmse.naive = unlist(lapply(1:horizon, function(x,X,Y)sqrt(mean((X[1:x, ] - Y[1:x, ])^2)), true.test, naive.forecast))
  
  return(list(pred = pred, true.test = true.test, rmse.test = rmse.test, rmse.naive = rmse.naive))
}