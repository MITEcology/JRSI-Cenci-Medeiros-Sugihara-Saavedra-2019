VCR <- function(X){
  div = rep(0,length(X))
    for(k in 1:length(X)){
      div[k] = tr(X[[k]])
  }
  return(div)
}

make.forecast <- function(Jacobian, best.theta,best.lambda,train.set, forecast.horizon){
  predizione = fast.out.of.sample(Jacobian, 
                                      best.theta,
                                      best.lambda, 
                                      train.set, forecast.horizon)
  prd = predizione$out_of_samp
  return(prd)
}
update.training.set <- function(original.length, original.data, iteration){

  length.training = original.length + iteration
  #### Preserve training for the interactions
  new.train = as.matrix(original.data[1:length.training, ])
  original.Embedding = LETTERS[1:ncol(new.train)]
  colnames(new.train) = original.Embedding
  TargetList = original.Embedding
  Embedding =  TargetList = original.Embedding
  train.set = Standardizza(new.train)
  return(train.set)
}



update.plot <- function(vol, max.it, titolo){
  rbPal <- colorRampPalette(c('blue','red'))
  colori <- rbPal(100)[as.numeric(cut(vol,breaks = 100))]
  plot(vol, pch = 20, lty = 1, xlab = 'Time', ylab = 'VCR',
       ylim = c(min(vol), max(vol)))
  lines(vol, lty = 1, col = 'black')
}