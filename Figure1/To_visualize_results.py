#%%
import numpy as np
from statsmodels.distributions.empirical_distribution import ECDF
import matplotlib.pylab as plt
import matplotlib
import pandas as pd
import seaborn as sns

'''
VCR analysis
'''

def make_empirical_cdf(X, Y,titolo,col,nome,make_file):
    '''
    Make the ratio of the empirical cumulative distribution functions for Figure 2
    '''

    rapporto = X/Y
    rapporto = rapporto[rapporto!=np.inf]
    ecdf_ = ECDF(np.squeeze(np.asarray(rapporto)))
    ####
    plt.semilogy(ecdf_.x, 1-ecdf_.y, lw = 2, color = col, label = titolo)
    plt.xlabel('Ratio of RMSE', fontsize = 28)
    plt.ylabel('1-CDF', fontsize = 28)
    plt.xlim([0.0001, max(rapporto)+1])
    plt.legend(loc='upper right', frameon=False, fontsize = 36)
    if make_file == True:
            f = open(nome,'w')
            for k in range(len(ecdf_.x)):
                    f.write('%f %f\n' % (ecdf_.x[k], (1.-ecdf_.y[k])))
            f.close()
#%%
if __name__ == "__main__":
    
    file_options = ['CR', 'd', 'lv']
    save_fig = False
    for n in [0]:
        data_name = file_options[n]+'.txt'
        tmp = pd.DataFrame(np.loadtxt(data_name), columns = ['Stable dist', 'Unstable dist', 'Stable RMSE', 'Unstable RMSE'])
    
        
        matplotlib.rcParams.update({'font.size': 22})
        plt.rc('font',**{'family':'sans-serif','sans-serif':['Roman']})
        #plt.rc('text', usetex=True)
        ##########
        label = r'$\frac{\epsilon_{\mathrm{small}_\mathcal{V}} - \epsilon_{\mathrm{large}_\mathcal{V}}}{\epsilon_{\mathrm{small}_\mathcal{V}} + \epsilon_{\mathrm{large}_\mathcal{V}}}$'
       
        st = tmp['Stable RMSE']
        ust = tmp['Unstable RMSE']
        ########## Left Panel
        if n == 0:
            plt.figure(figsize = (14,14))
        else:
            plt.figure(figsize = (20,6))
        if n == 0:
            plt.subplot(221)
        else:
            plt.subplot(131)
        var1 = ((st-ust) / (st+ust)).dropna()
        sns.kdeplot(var1,linewidth = 3, color='r', shade=True, label = '')
        plt.axvline(x = 0, linewidth = 2, linestyle = '-.', c = 'k')
        plt.axvline(x = var1.mean(), linewidth = 3, linestyle = '--', c = 'r')
        plt.xlabel(label, fontsize  = 40)
        plt.ylabel('PDF', fontsize = 28)
        #if n == 0:
            #plt.text(-1.1, 1.22, expected_label+'='+str(round(var1.mean(), 2)),
            #bbox={'facecolor': 'white', 'alpha': 0.5, 'pad': 10}, fontsize = 21)
        
        
        ########## Right Panel
        if n == 0:
            plt.subplot(222)
        else:
            plt.subplot(132)
        sns.distplot(var1,\
                 hist_kws=dict(cumulative=True),\
                 kde_kws=dict(cumulative=True), color = 'b')
        x = ECDF(np.squeeze(np.asarray(var1)))
        plt.axvline(x = 0, linewidth = 3, linestyle = '--', c = 'b')
        plt.axhline(y = x.y[np.where(x.x > 0.)[0][0]], linewidth = 3, linestyle = '--', c = 'b')
        plt.scatter(0,x.y[np.where(x.x > 0.)[0][0]], s = 200, c = 'b')
        plt.axhline(y = 0.5, c = 'r', linestyle = '-.')
        plt.xlabel(label, fontsize = 40)      
        plt.yticks([0, 0.25, 0.5,0.75,1.])
        plt.gca().get_yticklabels()[2].set_color('red')
        plt.ylabel('CDF', fontsize = 28)
        ##########
        if n == 0:
            plt.subplot(212)
        else:
            plt.subplot(133)
        st = np.loadtxt(data_name)[:,2]
        ust = np.loadtxt(data_name)[:,3]
        idx = np.where((st > 0 ) | (ust > 0))[0]  
        st = st[idx]
        ust = ust[idx]
        
        make_empirical_cdf(st,ust, r'$1 - \mathrm{CDF}(\frac{\epsilon_{\mathrm{small}_\mathcal{V}}}{\epsilon_{\mathrm{large}_\mathcal{V}}})$', 'b', 'A' , False)
        make_empirical_cdf(ust,st, r'$1 - \mathrm{CDF}(\frac{\epsilon_{\mathrm{large}_\mathcal{V}}}{\epsilon_{\mathrm{small}_\mathcal{V}}})$', 'k', 'A', False)

    
        plt.tight_layout()

        if save_fig:
            if n == 0:
                plt.savefig('../Model_'+file_options[n]+'.pdf', dpi = 300, bbox_inches = "tight")
            else:
                plt.savefig('PanelC/Model_'+file_options[n]+'.pdf', dpi = 300, bbox_inches = "tight")
