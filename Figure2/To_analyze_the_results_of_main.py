#%%
import numpy as np
from statsmodels.distributions.empirical_distribution import ECDF
import matplotlib.pylab as plt
import matplotlib
import pandas as pd
import seaborn as sns
def make_empirical_cdf(X, Y, horizon, titolo,col,nome,make_file):
    '''
    Make the ratio of the empirical cumulative distribution functions for Figure 2
    '''

    rapporto = X[:,horizon]/Y[:,horizon]
    ecdf_ = ECDF(np.squeeze(np.asarray(rapporto)))
    ####
    plt.semilogy(ecdf_.x, 1-ecdf_.y, lw = 2, color = col, label = titolo)
    plt.xlabel('Ratio of RMSE', fontsize = xfont)
    plt.ylabel('1-CDF', fontsize = yfont)
    plt.xlim([0.0001, max(rapporto)+1])
    plt.legend(loc='upper right', frameon=False, prop={'size': 30})
    if make_file == True:
            f = open(nome,'w')
            for k in range(len(ecdf_.x)):
                    f.write('%f %f\n' % (ecdf_.x[k], (1.-ecdf_.y[k])))
            f.close()
#%%
if __name__ == "__main__":
    stable_name = 'Results_stable.csv'
    unstable_name = 'Results_unstable.csv'    
        
    
    #%%
    matplotlib.rcParams.update({'font.size': 22})
    st = pd.read_csv(stable_name, sep = ',')
    ust = pd.read_csv(unstable_name, sep = ',')
    yfont = 30
    xfont = 30
    legend_size = 24
    ##########
    lb = ['6  step ahead', '12 step ahead', '18 step ahead']
    horizon_list = ['t6', 't12', 't18']
    label = r'$\frac{\epsilon_{\mathrm{small}_\mathcal{V}} - \epsilon_{\mathrm{large}_\mathcal{V}}}{\epsilon_{\mathrm{small}_\mathcal{V}} + \epsilon_{\mathrm{large}_\mathcal{V}}}$'
    clr = ['navy', 'darkorange', 'c']
    hs = ['t4', 't6', 't8', 't10', 't12', 't14', 't16', 't18', 't20']
    num = [n for n in range(4,21) if n%2 == 0]
    plt.figure(figsize = (20,12))
    fake_num = [n for n in range(0,36) if n%4 == 0]
    c1 = 'royalblue'
    c2 = 'orangered'
    
    plt.subplot(221)
    bp1 = plt.boxplot(st[hs].transpose(), boxprops=dict(facecolor=c1, color=c1),
                medianprops=dict(color='k'), 
                flierprops=dict(color=c1, markeredgecolor=c1, marker='o', markerfacecolor=c1), patch_artist=True, positions=np.array(fake_num)-0.5,widths=1)
    bp2 = plt.boxplot(ust[hs].transpose(), boxprops=dict(facecolor=c2, color=c2),
                medianprops=dict(color='k'), 
                flierprops=dict(color=c2, markeredgecolor=c2, marker='o', markerfacecolor=c2), patch_artist=True, positions=np.array(fake_num)+0.5,widths=1)
    plt.xlim([-2,34])
    plt.ylim([0,1])
    plt.xticks(fake_num, num)
    plt.xlabel('Forecasting horizon', fontsize = xfont)
    plt.ylabel('RMSE', fontsize = yfont)
    plt.legend([bp1["boxes"][0], bp2["boxes"][0]], ['Small VCR', 'Large VCR'], loc='upper left', bbox_to_anchor=(0,1.05))

    ########## 
    mean = []
    std = []
    v = []
    for H in hs:
          var = (st[H]-ust[H]) /(st[H]+ust[H])
          v.append(var)
    plt.subplot(222)
    plt.boxplot(v, patch_artist=True, boxprops=dict(facecolor='seagreen', color='seagreen'), 
                medianprops=dict(color='k'))
    plt.axhline(y = 0, c = 'k', linestyle = '--', linewidth = 3)
    plt.xlabel('Forecasting horizon', fontsize = xfont)
    plt.ylabel(label, fontsize = yfont+20)      
    plt.tight_layout() 
    plt.xticks([n for n in range(1, len(v)+1)], num)
    plt.gca().get_xticklabels()[1].set_color(clr[0])
    plt.gca().get_xticklabels()[4].set_color(clr[1])
    plt.gca().get_xticklabels()[7].set_color(clr[2])

    ########## 
    plt.subplot(223)
    count = 0
    for horizon in horizon_list:
        var1 = (st[horizon]-ust[horizon]) / (st[horizon]+ust[horizon])
        sns.distplot(var1,\
                 hist_kws=dict(cumulative=True),\
                 kde_kws=dict(cumulative=True), label = str(lb[count]), color = clr[count])
        x = ECDF(np.squeeze(np.asarray(var1)))
        plt.axvline(x = 0, linewidth = 3, linestyle = '--', c = clr[count])
        plt.axhline(y = x.y[np.where(x.x > 0.)[0][0]], linewidth = 3, linestyle = '--', c =clr[count])
        plt.scatter(0,x.y[np.where(x.x > 0.)[0][0]], s = 200, c = clr[count])
        count+=1
    plt.axhline(y = 0.5, c = 'r', linestyle = '-.')
    plt.xlabel(label, fontsize = xfont+20)      
    plt.yticks([0, 0.25, 0.5,0.75,1.])
    plt.gca().get_yticklabels()[2].set_color('red')
    plt.legend(loc = 'upper left', frameon=False,  prop={'size': legend_size})
    plt.ylabel('CDF', fontsize = yfont)
    ##########
    plt.subplot(224)
    st = np.array(pd.read_csv(stable_name, sep = ','))
    ust = np.array(pd.read_csv(unstable_name, sep = ','))

    make_empirical_cdf(st,ust,5, r'$1 - \mathrm{CDF}(\frac{\epsilon_{\mathrm{small}\mathcal{V}}}{\epsilon_{\mathrm{large}\mathcal{V}}})$', 'b', 'A' , False)
    make_empirical_cdf(ust,st,5, r'$1 - \mathrm{CDF}(\frac{\epsilon_{\mathrm{large}\mathcal{V}}}{\epsilon_{\mathrm{small}\mathcal{V}}})$', 'k', 'A', False)


    plt.tight_layout()


# %%
