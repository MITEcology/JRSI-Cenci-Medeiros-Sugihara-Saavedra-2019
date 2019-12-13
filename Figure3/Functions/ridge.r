ridge_fit_ <- function(ts, targ_col, Embedding,theta, lambda,alp){
  Edim <- length(Embedding)
  coeff_names <- sapply(colnames(ts),function(x) paste("d", targ_col, "d", x, sep = ""))
  block <- cbind(ts[2:dim(ts)[1],targ_col],ts[1:(dim(ts)[1]-1),])
  norm_consts <- apply(block, 2, function(x) sd(x))
  block <- as.data.frame(apply(block, 2, function(x) (x-mean(x))/sd(x)))
  
  lib <- 1:dim(block)[1]
  pred <- 1:dim(block)[1]
  
  coeff <- array(0,dim=c(length(pred),Edim + 1))
  colnames(coeff) <- c('c0', coeff_names)
  coeff <- as.data.frame(coeff)
  
  
  
  lm_regularized <- function(y, x, ws, lambda, dimension, subset = seq_along(y)){
    x <- x[subset,]
    y <- y[subset]
    ws <- ws[subset]
    WWs = diag(ws)
    Xx = as.matrix(x)
    Xx = cbind(1, Xx)
    coeff <- solve(t(Xx) %*% WWs %*% Xx + lambda*nrow(Xx)*diag(1,dimension + 1)) %*% t(Xx) %*%(ws * y)
    coeff <- t(coeff)
    
    return(coeff)
  }
  
  fit_error = rep(0,length(pred))
  for (ipred in 1:length(pred)){
    libs = lib[-pred[ipred]]
    q <- matrix(as.numeric(block[pred[ipred],2:dim(block)[2]]),
                ncol=Edim, nrow=length(libs), byrow = T)
    distances <- sqrt(rowSums((block[libs,2:dim(block)[2]] - q)^2))
    Krnl = match.fun(Regression.Kernel)
    Ws = Krnl(distances, theta)
    fit <- lm_regularized(block[libs,1],block[libs,2:dim(block)[2]],Ws, lambda, Edim)
    coeff[ipred,] <- fit
  }
  return(coeff)
  
}

ridge_fit <- cmpfun(ridge_fit_)