import os

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.decomposition import PCA
from matplotlib import cm

import conf

#### Read in Data
data = pd.read_csv(os.path.join(conf.DATA_PATH, 'train.csv'))
test_data = pd.read_csv(os.path.join(conf.DATA_PATH, 'test.csv'))
#### Exploration
# check if ID is unique identifier
data.id.nunique() == len(data)

# check if there are missing values: No
pd.isnull(data).sum(1).describe()

# convert categorical data into dummy variables
cat_names = [cat for cat in data.columns.values if 'cat' in cat]
cont_names = [cont for cont in data.columns.values if 'cont' in cont]
len(cat_names) # 116
len(cont_names) # 14
data_dummies = pd.get_dummies(data[cat_names])
loss = data.loc[:, 'loss']
data_cont = data.loc[:, cont_names]

means_dummy = data_dummies.mean()
means_dummy.describe()

data_cont.describe()
means_cont = data_cont.mean()
means_cont.describe()
corr_cont = data_cont.corr()

loss.describe()
#### Visualization
#### 1. correlation matrix
sns.set(style="white")
mask = np.zeros_like(corr_cont, dtype=np.bool)
mask[np.triu_indices_from(mask)] = True

# Set up the matplotlib figure
f, ax = plt.subplots(figsize=(11, 9))

# Generate a custom diverging colormap
cmap = sns.diverging_palette(220, 10, as_cmap=True)

# Draw the heatmap with the mask and correct aspect ratio
sns.heatmap(corr_cont, mask=mask, cmap=cmap, vmax=1,
            square=True, xticklabels=True, yticklabels=True,
            linewidths=.5, cbar_kws={"shrink": .5}, ax=ax)
plt.savefig(os.path.join(conf.DATA_PATH, 'cont_corr_matrix.png'))


#### 2. y vs x's
pca = PCA(n_components=100, random_state=0)
X = pd.concat([data_cont, data_dummies], axis=1)
X.shape
pca.fit(X)
print(pca.explained_variance_ratio_)
"""
>>> print(pca.explained_variance_ratio_)
[ 0.08161849  0.06941195  0.04611102  0.03709806  0.03244523  0.02947181
  0.02725041  0.02540259  0.02012516  0.01807992  0.01735476  0.01658555
  0.01514561  0.01460562  0.01373697  0.01138071  0.01086017  0.01051255
  0.00981733  0.00929887]
"""
first100 = pca.explained_variance_ratio_
sum(first100)
# 84.3% in total
plt.plot(range(1,101), first100, marker='o')
plt.ylabel("Proportion of Variance Explained")
plt.xlabel("PCA component")
plt.title("Scree plot for the first 100 components (account for total of {}% variances)".format(round(sum(first100)*100)))
plt.savefig(os.path.join(conf.DATA_PATH, 'scree_plot.png'))

new_X = pd.DataFrame(pca.transform(X))

plt.plot(new_X[:, 0], loss)
plt.savefig(os.path.join(conf.DATA_PATH, 'scree_plot.png'))



# 2d histogram using numpy
for i in range(99):
    plt.hexbin(new_X[i]*10000, loss, gridsize=200, cmap=cm.jet, bins=None)
    plt.axis([(new_X[i]*10000).min(), (new_X[i]*10000).max(), loss.min(), int(np.percentile(loss, 99))])
    plt.xlabel("component {} (values multiplied by 10000 for plotting)".format(i+1))
    plt.ylabel("Loss (capped at 99th percentile)")
    plt.title("Loss vs component")
    cb = plt.colorbar()
    cb.set_label('frequency')
    plt.savefig(os.path.join(conf.DATA_PATH, 'loss_vs_component{}.png'.format(i+1)))
    plt.clf()

# benchmark cacluation: null model,using average as prediction
avg_loss = np.mean(loss)
np.mean(abs(loss - avg_loss))

test_pred = pd.DataFrame({'id': test_data.id, 'loss': avg_loss})
test_pred.to_csv(os.path.join(conf.DATA_PATH, 'test_pred_null.csv'), index=False)

# Cv mae plot
num_predictors = 20
cv_mae = pd.read_csv(os.path.join(conf.DATA_PATH, 'cv_mae_{}.csv'.format(num_predictors)), index_col='Repetition')
cv_mae_sd = cv_mae.std()
cv_mae_mean = cv_mae.mean()
sns.set_style("whitegrid")
sns.barplot(data=cv_mae)
plt.title("Comparison of Methods using 100 Principal Components with 5-fold Cross Validation")
plt.ylabel("Average of cross-validated MAE over 10 times of sampling")
plt.savefig(os.path.join(conf.DATA_PATH, 'cv_mae_comparison_{}.png'.format(num_predictors)))
