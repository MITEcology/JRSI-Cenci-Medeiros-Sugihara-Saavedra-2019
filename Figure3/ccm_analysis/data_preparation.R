rm(list = ls())
library(lubridate)
library(openair)
library(Hmisc)
stampa = T
#########
d = as.matrix(read.table('NewZeland.txt', header = T))[,c(2:5)]
name.species = colnames(d)
d = matrix(as.numeric(d), nrow(d), ncol(d))
colnames(d) = name.species
d = d[1:248,]
####################
stampa = T
if(isTRUE(stampa)){
  write.table(d, file = 'population_time_series.txt', row.names = F)
}

###########
###################################################################################
### Here I am taking the parameters at the time at which variables are sampled
###################################################################################
temperature.data = as.matrix(read.table('temp_data.txt', header = T))
wavewind.data = as.matrix(read.table('Wave_Wind.txt', header = T))
abundance.data = as.matrix(read.table('NewZeland.txt', header = T))
######
abundance.data.column = dmy(abundance.data[,1])
temperature.data.column = mdy(temperature.data[,1])
wavewind.data.column = mdy(wavewind.data[,1])
###### Take the date at which all parameters and variables were sampled 
wavewind.data.column = wavewind.data.column[wavewind.data.column %in% abundance.data.column ]
temperature.data.column = temperature.data.column[ temperature.data.column %in% wavewind.data.column ]
abundance.data.column = abundance.data.column[ abundance.data.column %in% temperature.data.column ]
######
idx = which(mdy(temperature.data[,1])%in%temperature.data.column)
temperature.data = as.numeric(temperature.data[idx,2])
idx = which(mdy(wavewind.data[,1]) %in% wavewind.data.column)
wave.data = as.numeric(wavewind.data[idx,2])
wind.data = as.numeric(wavewind.data[idx,3])
idx = which(dmy(abundance.data[,1])%in%abundance.data.column)
abundance.data = matrix(as.numeric(abundance.data[idx,c(2:5)]), length(wave.data),4)
time.variable = abundance.data.column
rm(list= ls()[!(ls() %in% c('temperature.data', 'wind.data', 'wave.data',
                            'abundance.data', 'time.variable'))])
all.together = data.frame(abundance.data, temperature.data, wave.data, wind.data)
####################
stampa = T
if(isTRUE(stampa)){
  colnames(all.together) = c('Barnacles', 'Algae', 'Mussels', 'Rock', 
                               'T', 'Wave', 'Wind')
  write.table(all.together, file = 'subset_by_day.txt', row.names = F)
}
###################################################################################
#### Average parameters at the months at which abundance were sampled
###################################################################################
rm(list = ls())
average.temperature = as.matrix(read.table('temperature_mm.txt', header = F))[,2]
average.wave = as.matrix(read.table('Waves_mm.txt', header = F))[,2]
abundance.data = matrix(as.numeric(as.matrix(read.table('NewZeland.txt', header = T))[1:248,c(2:5)]), length(average.wave),4)
########################################################################
all.together = data.frame(abundance.data, average.temperature, average.wave)
stampa = T
if(isTRUE(stampa)){
  colnames(all.together) = c('Barnacles', 'Algae', 'Mussels', 'Rock', 
                             'T', 'Wave')
  write.table(all.together, file = 'average_by_month.txt', row.names = F)
}
###################################################################################
#### divergence - temperature - waves
###################################################################################
rm(list = ls())
d1 = as.matrix(read.table('time_series_of_divergence.txt'))[,2]
d2 = as.matrix(read.table('temperature_mm.txt'))[,2]
d3 = as.matrix(read.table('Waves_mm.txt'))[,2]
to.print = cbind(d1,d2,d3)
colnames(to.print) = c('divergence', 'temperature', 'Waves')
stampa = T
if(isTRUE(stampa)){
  write.table(to.print, file = 'divergence_environment.txt', row.names = F)
}
