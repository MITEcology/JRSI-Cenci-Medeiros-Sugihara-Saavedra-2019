library(plotly)
library(moments)
source('Functions/fun_analysis.r')

load(paste(getwd(), '/output_rData/Results.RData', sep = ''))
threshold.sequence = seq(0.1,0.5, 0.05)
p_values = matrix(NA, 5, length(threshold.sequence))
tmp = 1
mean.separation = list()
boxplots.low = list()
boxplots.high = list()
for(th in threshold.sequence)
{
  out = back.testing(prediction.vector, th, vcr.quantile.vector)
  boxplots.low[[tmp]] = matrix(unlist(out$pred.low.vcr.all), length(out$pred.low.vcr.all[[1]]), 5)
  boxplots.high[[tmp]] = matrix(unlist(out$pred.high.vcr.all), length(out$pred.high.vcr.all[[1]]), 5)
  mean.separation[[tmp]]  = cbind(c(1:5), out$pred.low.vcr.mean,
                                          out$pred.low.vcr.sd, out$pred.high.vcr.mean, 
                                          out$pred.high.vcr.sd)
  for(h in 1:5)
  {
    x = make.null.model(prediction.vector, h, floor(runif(length(out$pred.low.vcr.all[[h]]), 1, 
                                                          nrow(prediction.vector))),
                        out$pred.low.vcr.mean[h])
    p_values[h,tmp] = x$p_value
  }
  tmp = tmp + 1
}


### Make the txt file for plotting
make.plot.files = F
if(make.plot.files == TRUE)
{
  #### Mean separation at different threesholds (like Panel A in the main text)
  for(k in 1:length(mean.separation))
  {
    name.to.print = paste('txt_files_SI/sep_', k, '.txt', sep = '')
    write.table(mean.separation[[k]], file = name.to.print, row.names = F, col.names = F)
  }
  #### p-values analysis
  file.to.print = cbind(c(1:5), p_values)
  write.table(file.to.print, file = 'txt_files_SI/p_value_analysis_si.txt', row.names = F, col.names = F)
  #### Error distribution
  for(k in 1:length(boxplots.high))
  {
    name.to.print = paste('txt_files_SI/dist_low_', k, '.txt', sep = '')
    write.table(boxplots.low[[k]], file = name.to.print, row.names = F, col.names = F)
    name.to.print = paste('txt_files_SI/dist_high_', k, '.txt', sep = '')
    write.table(boxplots.high[[k]], file = name.to.print, row.names = F, col.names = F)
  }
}

