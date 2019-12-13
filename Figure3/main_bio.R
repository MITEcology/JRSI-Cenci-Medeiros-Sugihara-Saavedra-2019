rm(list=ls(all=TRUE)) 
suppressMessages(library(Matrix))
suppressMessages(library(parallel))
suppressMessages(library(compiler))
suppressMessages(library(lars))
suppressMessages(library(elasticnet))
suppressMessages(library(psych))
options(warn=-1)
#####################################################################################
source('Functions/Auxiliar.r')
source('Functions/elastic_net_fit.r')
source('Functions/LOOCV.r')
source('Functions/KernelFunctions.r')
source('Functions/fast_prediction.r')
source('Functions/fun.r')
source('Functions/single_update.r')
source('Functions/training_and_predicting.r')
###########################################
############## Real Time Predictability ###
###########################################
run = T
save = T
####
ModelName = 'New_Zeland_ts'
FileName = paste('data.folder/',ModelName, '.txt', sep = '')
###################################
logspace <- function(d1, d2, n) exp(log(10)*seq(d1, d2, length.out=n)) 
############# Choose the kernel
Kernel.Options = c('Exponential.Kernel', 'Epanechnikov.Kernel', 'TriCubic.Kernel')
Regression.Kernel = Kernel.Options[1]
############# Parameters for cross validation
lambda = logspace(-3,0,15)                       
tht = logspace(-1,1.2, 15)         
parameters_on_grid = expand.grid(tht, lambda)     
### Read Time series
d = as.matrix(read.table(FileName, header= F))
############################# Prepare your data to compute the original VCR
##### select training set
length.training = 150
original.training.length = 150
starting.length = length.training
#### Preserve training for the interactions
d.original = as.matrix(d[1:length.training, ])
original.Embedding = LETTERS[1:ncol(d.original)]
colnames(d.original) = original.Embedding
TargetList = original.Embedding
Embedding =  TargetList = original.Embedding
d.training = Standardizza(d.original)
RegressionType = 'ELNET_fit'
alpha = 1.
if(run == T){
  out = training.function(alpha, d.training, TargetList, Embedding, 
                          parameters_on_grid, RegressionType)
  BestCoefficients = out$coefficenti
  BestParameters = out$regularization.parameters
  if(save == T){
    save(BestCoefficients, BestParameters, file = 'output_Training/Training_Results.RData')
  }
}else{
  wd = getwd()
  file.to.load = paste(wd, '/output_Training/Training_Results.RData', sep = '')
  load(file.to.load) 
}

########################################################################
prediction.vector = c()
naive.prediction = c()
vcr.quantile.vector = c()
#####
length.testing = 5
max.iteration = nrow(d)-original.training.length-5
volume.contraction.rate = VCR(BestCoefficients$J)
volume.contraction.rate = unlist(smooth.spline(volume.contraction.rate)['y'])
#####
get.where.in.quantile <- function(x,perc) ecdf(x)(perc)
tmp=2
for (it in 1:max.iteration){
  interval.quantile.vcr = ((length(volume.contraction.rate) - 60):length(volume.contraction.rate))

  ot = prediction.function(BestCoefficients, BestParameters$BestTH,BestParameters$BestLM, d.training, 
                           length.testing, it, d.original, d)
  pred = ot$pred
  true.test = ot$true.test
  prediction.vector = rbind(prediction.vector, ot$rmse.test)  
  naive.prediction = rbind(naive.prediction, ot$rmse.naive)
 
  vcr.quantile.vector = c(vcr.quantile.vector,
                          get.where.in.quantile(
                          volume.contraction.rate[interval.quantile.vcr],
                          volume.contraction.rate[length(volume.contraction.rate)]))
  ##### Now take the new value from the data and fit the new coefficient
  d.training = update.training.set(starting.length, d, it)
  if(it%%50==0){
    tmp = tmp + 1
    cat('Train again ...')
    Embedding = TargetList = colnames(d.training)
    out = training.function(alpha, d.training, TargetList, Embedding, 
                            parameters_on_grid, RegressionType)
    BestCoefficients = out$coefficenti
    BestParameters = out$regularization.parameters
    cat(' Done\n')
  } else{
    length.training = nrow(d.training)
    new.fit = next.Jacobian(d.training[(1+it):nrow(d.training), ], TargetList, Embedding, BestParameters$BestTH,BestParameters$BestLM, 
                       alpha)
    BestCoefficients$J[length(BestCoefficients$J)+1] = new.fit$J
    BestCoefficients$c0 = rbind(BestCoefficients$c0, new.fit$c0)
  }
  volume.contraction.rate = VCR(BestCoefficients$J)
  volume.contraction.rate = unlist(smooth.spline(volume.contraction.rate)['y'])
}



save(prediction.vector, naive.prediction, 
     vcr.quantile.vector, volume.contraction.rate, file = 'output_rData/Results.RData')
