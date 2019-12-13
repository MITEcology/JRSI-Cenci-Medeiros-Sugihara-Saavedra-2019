import numpy as np
import pandas as pd
from scipy.stats import ttest_ind, skew
import matplotlib.pylab as plt
stable = np.loadtxt('txt_files/DistributionAtSmallVCR.txt') #np.array(pd.read_table('txt_files/DistributionAtSmallVCR.txt'))
unstable = np.loadtxt('txt_files/DistributionAtLargeVCR.txt') #np.array(pd.read_table('txt_files/DistributionAtLargeVCR.txt'))



columns = [0,1,2,3,4]
df = pd.DataFrame(columns = ['RMSE at Small VCR', 'RMSE at Large VCR', 'p-value of t-test'])
print('{:<12s}{:<12s}{:<12s}'.format('Mean (S)', 'Mean (U)', 'T-test'))
for column in columns:
    print('{:<12.2f}{:<12.2f}{:<12.4f}'.format(np.mean(stable[:,column]), np.mean(unstable[:,column]), ttest_ind(stable[:,column], unstable[:,column])[1]))
    df = df.append({'RMSE at Small VCR': np.mean(stable[:,column]), \
                    'RMSE at Large VCR': np.mean(unstable[:,column]), \
                    'p-value of t-test': ttest_ind(stable[:,column], unstable[:,column])[1]}, ignore_index = True)
print(df.to_latex())
plt.plot([np.mean(stable[:, column]) for column in columns], linewidth = 3, label = 'Stable')
plt.plot([np.mean(unstable[:, column]) for column in columns], linewidth = 3, label = 'Unstable')
plt.show()
