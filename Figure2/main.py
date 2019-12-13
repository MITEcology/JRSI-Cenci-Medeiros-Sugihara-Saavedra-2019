#%%
import numpy as np
import pandas as pd
import importlib, os,sys
sys.path.append('Functions/')
import make_perturbed_data as pert
from forecast_function import lstm_forecast
from sklearn.metrics import mean_squared_error

importlib.reload(pert)

'''
First run
pyhton model_CR.py

then you can run this code (it will take a while)
'''



np.random.seed(5)
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
data  = np.loadtxt('ts.txt')
vcr = np.loadtxt('divergence.txt')
num_data_for_training = (300+1)
num_data_to_predict = 30
results_low = pd.DataFrame(columns = ['VCR', 't4', 't6', 't8', 't10', 't12', 't14', 't16', 't18', 't20'])
results_large = pd.DataFrame(columns = ['VCR', 't4', 't6', 't8', 't10', 't12', 't14', 't16', 't18', 't20'])
horizons = [4,6,8,10,12,14,16,18,20]

###### make model parameters
nu1 = 0.1; nu2 = 0.07;
C1 = 0.5; C2 = 0.5;
lambda1 = 3.2; lambda2 =2.9;
mu1 = 0.15; mu2 = 0.15;
kappa1 = 2.5; kappa2 = 2.;
Rstar = 0.3; k = 1.2;

### here sample two points one in the low and one in the high percentile
idx_low_percentile = np.where(vcr < np.quantile(vcr, 0.15))
idx_large_percentile = np.where(vcr > np.quantile(vcr, 0.85))



#%%
for tstart in range(1000):
    nu1_, nu2_, C1_, C2_, lambda_1_, lambda_2_, mu1_, mu2_, kappa1_, kappa2_, Rstar_, k_ = \
        pert.make_perturbed_parameter(nu1, nu2, C1, C2, lambda1, lambda2, mu1, mu2, kappa1, kappa2, Rstar,k, \
        min_sgm = 2, max_sgm = 7)

    check = 0
    while check == 0:
        idx_low = int(np.random.choice(np.squeeze(idx_low_percentile) , 1)  )
        idx_large = int(np.random.choice(np.squeeze(idx_large_percentile) , 1) )  
        if idx_low > num_data_for_training and idx_large > num_data_for_training:
            check = 1
    training_data_low = data[(idx_low-num_data_for_training ):(idx_low+1),:]
    training_data_large = data[(idx_large-num_data_for_training ):(idx_large+1),:]
    try:
        perturbed_test_data_low = pert.make_perturbed_data(nu1_, nu2_, C1_, C2_, lambda_1_, lambda_2_, mu1_, mu2_, kappa1_, kappa2_, Rstar_, k_,\
                                                    training_data_low[np.shape(training_data_low)[0]-1,0], \
                                                    training_data_low[np.shape(training_data_low)[0]-1,1],
                                                    training_data_low[np.shape(training_data_low)[0]-1,2],
                                                    training_data_low[np.shape(training_data_low)[0]-1,3],
                                                    training_data_low[np.shape(training_data_low)[0]-1,4])

        perturbed_test_data_large = pert.make_perturbed_data(nu1_, nu2_, C1_, C2_, lambda_1_, lambda_2_, mu1_, mu2_, kappa1_, kappa2_, Rstar_, k_,\
                                                    training_data_large[np.shape(training_data_large)[0]-1,0], \
                                                    training_data_large[np.shape(training_data_large)[0]-1,1],
                                                    training_data_large[np.shape(training_data_large)[0]-1,2],
                                                    training_data_large[np.shape(training_data_large)[0]-1,3],
                                                    training_data_large[np.shape(training_data_large)[0]-1,4])

        forecast_low = lstm_forecast(training_data_low, num_data_to_predict+1,do_cv = False)
        forecast_large = lstm_forecast(training_data_large, num_data_to_predict+1,do_cv = False)


        ###############################

        perturbed_test_data_low = perturbed_test_data_low[1:num_data_to_predict+1, :]
        rmse_s_low = np.array([np.sqrt(mean_squared_error(perturbed_test_data_low[0:n,:], forecast_low[0:n,:])) \
                            for n in horizons])
        results_low = results_low.append({'VCR': vcr[(idx_low)],
        't4': rmse_s_low[0],
        't6': rmse_s_low[1],
        't8': rmse_s_low[2],
        't10': rmse_s_low[3],
        't12': rmse_s_low[4],
        't14': rmse_s_low[5],
        't16': rmse_s_low[6],
        't18': rmse_s_low[7],
        't20': rmse_s_low[8]}, ignore_index = True)
        #################################

        perturbed_test_data_large = perturbed_test_data_large[1:num_data_to_predict+1, :]
        rmse_s_large = np.array([np.sqrt(mean_squared_error(perturbed_test_data_large[0:n,:], forecast_large[0:n,:])) \
                            for n in horizons])
        results_large = results_large.append({'VCR': vcr[(idx_large)],
        't4': rmse_s_large[0],
        't6': rmse_s_large[1],
        't8': rmse_s_large[2],
        't10': rmse_s_large[3],
        't12': rmse_s_large[4],
        't14': rmse_s_large[5],
        't16': rmse_s_large[6],
        't18': rmse_s_large[7],
        't20': rmse_s_large[8]}, ignore_index = True)
    except Exception:
        ex = None
    if tstart%50 == 0:
        print('Iteration:', tstart)
        ### Print preliminary results
        results_low.to_csv('Results_stable.csv')
        results_large.to_csv('Results_unstable.csv')
