#%%
import heapq
import pylab as plt
from scipy import integrate,stats
import numpy as np
import scipy
import numdifftools as nd
import sys, random

################################################
nu1 = 0.1; nu2 = 0.07;
C1 = 0.5; C2 = 0.5;
lambda1 = 3.2; lambda2 =2.9;
mu1 = 0.15; mu2 = 0.15;
kappa1 = 2.5; kappa2 = 2.;
Rstar = 0.3; k = 1.2;
####
p1_0 = 0.006884225; p2_0 = 0.087265965; c1_0 = 0.002226393; c2_0 = 1.815199890; r_0 = 0.562017616;
T = 3000.;
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
def stampa_5(t_start, t_end, X, name, sampling_rate):
	f = open(name, 'w')
	for i in range(t_start, t_end):
		if i%sampling_rate == 0:
			f.write('%lf %lf %lf %lf %lf\n' % (X[i,0], X[i,1], X[i,2], X[i,3], X[i,4]))
	f.close()
	return 0
################################################
ts = integrate.odeint(dX_dt, X_f1, t)
first_trace = []
lle = []
sampling_rate = 150
idx = 0
f = open('divergence.txt', 'w')
g = open('ts.txt', 'w')
#%%
for i in range(0,ts.shape[0]):
        if i%sampling_rate == 0:
                g.write('%f %f %f %f %f\n' % (ts[i,0],ts[i,1],ts[i,2],ts[i,3],ts[i,4]))
                f_jacob = nd.Jacobian(dX_dt)(np.squeeze(np.asarray(ts[i,:])))
                first_trace.append(np.trace(f_jacob))
                f.write('%f\n' % first_trace[idx])
                idx+=1

f.close()
g.close()


#%%
