#%%
import heapq
import pylab as plt
from scipy import integrate,stats
import numpy as np
import scipy
import numdifftools as nd
import sys, random
import pandas as pd


def make_perturbed_parameter(nu1, nu2, C1, C2, lambda1, lambda2, mu1, mu2, kappa1, kappa2, Rstar, k, min_sgm = 1, max_sgm = 5):
    ####### Randomly perturbed
    K = random.randint(5,10)
    N = 12 - K
    sample = np.array([0] * N + [1] * K )
    np.random.shuffle(sample)
    sgm = random.uniform(min_sgm,max_sgm)
    ###
    nu1_ = 0.1 + np.random.normal(0,nu1/sgm)*sample[0]; nu2_ = 0.07 + np.random.normal(0,nu2/sgm)*sample[1];
    C1_ = 0.5 + np.random.normal(0,C1/sgm)*sample[2]; C2_ = 0.5 + np.random.normal(0,C2/sgm)*sample[3];
    lambda1_ = 3.2 + np.random.normal(0,lambda1/sgm)*sample[4]; lambda2_ =2.9 + np.random.normal(0,lambda2/sgm)*sample[5];
    mu1_ = 0.15 + np.random.normal(0,mu1/sgm)*sample[6]; mu2_ = 0.15 + np.random.normal(0,mu2/sgm)*sample[7];
    kappa1_ = 2.5 + np.random.normal(0,kappa1/sgm)*sample[8]; kappa2_ = 2. + np.random.normal(0,kappa2/sgm)*sample[9];
    Rstar_ = 0.3 + np.random.normal(0,Rstar/sgm)*sample[10]; k_ = 1.2 + np.random.normal(0,k/sgm)*sample[11];
    return(nu1_, nu2_, C1_, C2_, lambda1_, lambda2_, mu1_, mu2_, kappa1_, kappa2_, Rstar_, k_)
def make_perturbed_data(nu1_, nu2_, C1_, C2_, lambda1_, lambda2_, mu1_, mu2_, kappa1_, kappa2_, Rstar_, k_, p1_0, p2_0, c1_0, c2_0, r_0):


    ######## Auxiliar Functions ####################
    def Uptake(var_x, L, KI):
        return(L*var_x/(KI + var_x))
    def dX_dt_2(X, t = 0):
        dydt = np.array([nu1_*Uptake(X[2], lambda1_, C1_)*X[0] - nu1_*X[0],
                         nu2_*Uptake(X[3], lambda2_, C2_)*X[1] - nu2_*X[1],
                         mu1_*Uptake(X[4], kappa1_, Rstar_)*X[2] - mu1_*X[2] - nu1_*Uptake(X[2], lambda1_, C1_)*X[0],
                         mu2_*Uptake(X[4], kappa2_, Rstar_)*X[3] - mu2_*X[3] - nu2_*Uptake(X[3], lambda2_, C2_)*X[1],
                         X[4]*(1 - X[4]/k_) -  mu1_*Uptake(X[4], kappa1_, Rstar_)*X[2] - mu2_*Uptake(X[4], kappa2_, Rstar_)*X[3]])
        return(dydt)

    T = 100;
    dt = 0.01;
    n_steps = T/dt;
    t = np.linspace(0, T, n_steps)
    X_f1 = np.array([p1_0, p2_0, c1_0, c2_0, r_0])
    ######## Auxiliar Functions ####################
    def Uptake(var_x, L, KI):
        return(L*var_x/(KI + var_x))
    ################################################
    def dX_dt(X, t = 0):
        dydt = np.array([nu1*Uptake(X[2], lambda1, C1)*X[0] - nu1*X[0],
                         nu2*Uptake(X[3], lambda2, C2)*X[1] - nu2*X[1],
                         mu1*Uptake(X[4], kappa1, Rstar)*X[2] - mu1*X[2] - nu1*Uptake(X[2], lambda1, C1)*X[0],
                         mu2*Uptake(X[4], kappa2, Rstar)*X[3] - mu2*X[3] - nu2*Uptake(X[3], lambda2, C2)*X[1],
                         X[4]*(1 - X[4]/k) -  mu1*Uptake(X[4], kappa1, Rstar)*X[2] - mu2*Uptake(X[4], kappa2, Rstar)*X[3]])
        return(dydt)
    ################################################
    ts = integrate.odeint(dX_dt_2, X_f1, t)
    first_trace = []
    lle = []
    sampling_rate = 150
    idx = 0
    perturbed_data = pd.DataFrame()
    #%%
    for i in range(0,ts.shape[0]):
            if i%sampling_rate == 0:
                    perturbed_data = perturbed_data.append({'A': ts[i,0], \
                            'B': ts[i,1], \
                            'C': ts[i,2], \
                            'D': ts[i,3], \
                            'E': ts[i,4]}, ignore_index = True)
    return(np.array(perturbed_data))


    #%%
