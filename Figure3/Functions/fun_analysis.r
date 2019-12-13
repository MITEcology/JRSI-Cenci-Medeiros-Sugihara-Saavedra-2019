### This function perform the back testing and select the best threshold of separation
### output: matrix with stock names and optimum threshold
back.testing <- function(prd.vector, threshold, estimator)
{
  load(paste(getwd(), '/output_rData/Results.RData', sep = ''))
  pred.low.vcr.mean = pred.high.vcr.mean = 
    pred.low.vcr.sd = pred.high.vcr.sd = rep(0,ncol(prd.vector))
  
  pred.low.vcr.all = pred.high.vcr.all = list()
  for(horizon in 1:ncol(prd.vector))
  {
    idx.low = which(estimator < threshold)
    pred.low.vcr.mean[horizon] = mean(prd.vector[idx.low,horizon])
    pred.low.vcr.sd[horizon] = sd(prd.vector[idx.low,horizon])/sqrt(length(prd.vector[idx.low,horizon]))
    idx.high = which(estimator > threshold)
    pred.high.vcr.mean[horizon] = mean(prd.vector[idx.high,horizon])
    pred.high.vcr.sd[horizon] = sd(prd.vector[idx.high,horizon])/sqrt(length(prd.vector[idx.high,horizon]))
    ###
    pred.low.vcr.all[[horizon]] = prd.vector[idx.low,horizon]
    pred.high.vcr.all[[horizon]] = prd.vector[idx.high,horizon]
  }
  return(list(pred.low.vcr.mean = pred.low.vcr.mean, pred.low.vcr.sd = pred.low.vcr.sd, 
              pred.high.vcr.mean = pred.high.vcr.mean, pred.high.vcr.sd = pred.high.vcr.sd,
              pred.low.vcr.all = pred.low.vcr.all, pred.high.vcr.all = pred.high.vcr.all))
}
plot.results <- function(X)
{
  plot_ly(mtcars, x = c(1:5), color = I("black")) %>%
    add_lines(y = X$pred.low.vcr.mean,
              line = list(color = 'rgba(7, 164, 181, 1)'),
              name = "Small VCR") %>%
    add_ribbons(#data = augment(m),
      ymin = X$pred.low.vcr.mean - X$pred.low.vcr.sd,
      ymax = X$pred.low.vcr.mean + X$pred.low.vcr.sd,
      line = list(color = 'rgba(7, 164, 181, 0.05)'),
      fillcolor = 'rgba(7, 164, 181, 0.2)',
      name = "")%>%
    add_lines(y = X$pred.high.vcr.mean,
              line = list(color = 'rgba(155,10,10)'),
              name = "Large VCR") %>%
    add_ribbons(ymin = X$pred.high.vcr.mean - X$pred.high.vcr.sd,
                ymax = X$pred.high.vcr.mean + X$pred.high.vcr.sd,
                line = list(color = 'rgba(155,0,0)'),
                fillcolor = 'rgba(155,0,0)', name = '')
}
make.null.model <- function(X, H, idx,true.value)
{
  ### X = prediction.vector
  ### H = horizon
  ### idx = indeces to subset
  ### true.value = True RMSE
  num_it = 10000
  dist.rmse = rep(0,num_it)
  for(k in 1:num_it)
  {
    random.x = sample(X[,H])
    dist.rmse[k] = mean(random.x[idx])
  }
  p_value = length(dist.rmse[dist.rmse<true.value])/length(dist.rmse)
  plot(density(dist.rmse), xlab = 'RMSE', xlim = c(0,1), col = 'gray', lwd = 3)
  abline(v = true.value, col = 'blue', lwd = 2 )
  distribution = hist(dist.rmse, breaks = 50, plot = F)
  return(list(distribution = distribution, p_value = p_value))
}