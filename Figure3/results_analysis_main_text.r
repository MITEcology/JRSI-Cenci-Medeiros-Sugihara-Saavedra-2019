library(plotly)
library(moments)
source('Functions/fun_analysis.r')

load(paste(getwd(), '/output_rData/Results.RData', sep = ''))
out = back.testing(prediction.vector, 0.15, vcr.quantile.vector)
plt <- plot.results(out)
plt
par(mfrow = c(3,2))
for(h in 1:5)
{
  x = make.null.model(prediction.vector, h, floor(runif(length(out$pred.low.vcr.all[[h]]), 1, nrow(prediction.vector))),
                      out$pred.low.vcr.mean[h])
  cat('Horizon:' ,h ,' --> sd at small VCR:', sd(out$pred.low.vcr.all[[h]]),
      ' --> p-value:', x$p_value, '\n')
  cat('Horizon:' ,h ,' --> sd at large VCR:', sd(out$pred.high.vcr.all[[h]]), '\n')
}
par(mfrow = c(1,1))



### Make the txt file for plotting
make.plot.files = F
if(make.plot.files == TRUE)
{
  hh = 1 ### Fix horizon for the Figures
	### Panel A
	panel.a.file = cbind(c(1:5), out$pred.low.vcr.mean,out$pred.low.vcr.sd, out$pred.high.vcr.mean, out$pred.high.vcr.sd)
 	write.table(panel.a.file, file = 'txt_files/PanelA.txt', row.names = F, col.names = F)
	
	### Panel B

  x = make.null.model(prediction.vector, hh, floor(runif(length(out$pred.low.vcr.all[[hh]]), 1, nrow(prediction.vector))),
      		            out$pred.low.vcr.mean[hh])
	panel.b.file = cbind(x$distribution$mids, x$distribution$density)
	write.table(panel.b.file, file = 'txt_files/PanelB.txt', row.names = F, col.names = F)
	write.table(out$pred.low.vcr.mean[hh], file = 'txt_files/line_panelB.txt', row.names = F, col.names = F)

	### Panel C
	density.high = density(out$pred.high.vcr.all[[hh]])
	density.low = density(out$pred.low.vcr.all[[hh]])
	panel.c.file = cbind(density.low$x, density.low$y, density.high$x, density.high$y)
	write.table(panel.c.file, file = 'txt_files/PanelC.txt', row.names = F, col.names = F)
  small_output = matrix(0, nrow = length(out$pred.low.vcr.all[[3]]),
                      ncol = 5)
  colnames(smalle_output) = c('1','2','3','4','5')
  large_output = matrix(0, nrow = length(out$pred.high.vcr.all[[3]]),
                      ncol = 5)
  colnames(large_output) = c('1','2','3','4','5')
	for(hh in 1:5)
  {
    large_output[,hh] = out$pred.high.vcr.all[[hh]]
    small_output[,hh] = out$pred.low.vcr.all[[hh]]
    
  }
  write.table(large_output, file = 'txt_files/DistributionAtLargeVCR.txt', col.names = F, row.names = F)
  write.table(small_output, file = 'txt_files/DistributionAtSmallVCR.txt', col.names = F,row.names = F)
	}

