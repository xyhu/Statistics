import os
import logging
import argparse
import time

import pandas as pd
import numpy as np
from sklearn.decomposition import PCA
from sklearn.model_selection import KFold
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor, BaggingRegressor, GradientBoostingRegressor
from sklearn.model_selection import train_test_split

import conf


LOG = logging.getLogger(__name__)

class Preprocess(object):
    def __init__(self):
        self.data = pd.read_csv(os.path.join(conf.DATA_PATH, 'train.csv'))
        self.data = self.data.sample(frac=0.2).reset_index()
        self.cat_names = [cat for cat in self.data.columns.values if 'cat' in cat]
        self.cont_names = [cont for cont in self.data.columns.values if 'cont' in cont]
        self.data_dummies = pd.get_dummies(self.data[self.cat_names])
        self.loss = self.data.loc[:, 'loss']
        self.data_cont = self.data.loc[:, self.cont_names]
        self.X = pd.concat([self.data_cont, self.data_dummies], axis=1)



    def pca_decomposition(self):
        pca = PCA(n_components=100, random_state=0)
        pca.fit(self.X)
        self.new_X = pd.DataFrame(pca.transform(self.X))
        return self.new_X, self.loss


    def kfold_cross_validation_split(self, n_splits=5):
        folds = KFold(n_splits=n_splits)
        self.train_test_index = pd.DataFrame(index=range(n_splits), columns=['train', 'test'])
        i = 0
        for train_index, test_index in folds.split(self.new_X.index.values):
            self.train_test_index.iloc[i, 0] = train_index
            self.train_test_index.iloc[i, 1] = test_index
            i += 1

        return self.train_test_index



class Models(object):
    def __init__(self):
        preprocessor = Preprocess()
        self.new_X, self.loss = preprocessor.pca_decomposition()
        self.train_test_index = preprocessor.kfold_cross_validation_split()
        self.methods = ['LinearRegression', 'RandomForestRegressor',
                        'BaggingRegressor', 'GradientBoostingRegressor']
        self.mae_df = pd.DataFrame(index=self.train_test_index.index
                                 , columns=self.methods)


    def tuning_gradient_boosting_n_estimators(self, X, Y, depth):
        n_estimators = 100
        gb = GradientBoostingRegressor(loss = 'lad', subsample=0.8, \
                    n_estimators=n_estimators, max_depth=depth, random_state=0)
        x = np.arange(n_estimators) + 1
        gb.fit(X, Y)
        cumsum = -np.cumsum(gb.oob_improvement_)
        oob_best_iter = x[np.argmin(cumsum)]
        return oob_best_iter

    def tuning_gradient_boosting_max_depth(self, X, Y):
        params_dict = {}
        depths = range(3, int(round(np.sqrt(X.shape[1])))+1)
        for depth in depths:
            params_dict[depth] = self.tuning_gradient_boosting_n_estimators(X, Y, depth)

        return params_dict

    def tuning_gradient_boosting(self, X, Y):
        result = {}
        X_train, X_test, y_train, y_test = train_test_split(X, Y, test_size=0.2, random_state=0)
        params_dict = self.tuning_gradient_boosting_max_depth(X_train, y_train)
        for depth, n_estimators in params_dict.iteritems():
            gb = GradientBoostingRegressor(loss = 'lad', max_depth=depth, n_estimators=n_estimators)
            gb.fit(X_train, y_train)
            result[(depth, n_estimators)] = np.mean(abs(y_test - gb.predict(X_test)))

        optimal_params = min(result, key=result.get)
        return optimal_params



    def fitting_one_method(self, method, num_predictors):
        first_d_X = self.new_X.loc[:, :(num_predictors-1)]
        Y = self.loss

        for row in self.train_test_index.iterrows():
            train_index = row[1]['train']
            test_index = row[1]['test']

            X_train = first_d_X.iloc[train_index]
            y_train = Y.iloc[train_index]
            if method == 'LinearRegression':
                model = LinearRegression()
            elif method == 'RandomForestRegressor':
                model = RandomForestRegressor(criterion='mae', max_features='sqrt', random_state=0, max_depth=3, n_jobs=-1)
            elif method == 'BaggingRegressor':
                model = BaggingRegressor(random_state=0, max_samples=0.8, max_features=0.5, n_jobs=-1)
            elif method == 'GradientBoostingRegressor':
                params = self.tuning_gradient_boosting(X_train, y_train)
                model = GradientBoostingRegressor(loss = 'lad', max_depth=params[0], n_estimators=params[1], random_state=0) #TODO: CV to tune paramters

            model.fit(X_train, y_train)
            y_pred = model.predict(first_d_X.iloc[test_index])
            self.mae_df.loc[row[0], method] = np.mean(abs(y_pred - Y.iloc[test_index]))
            LOG.info("cross validation on method {}, iter={}".format(method, row[0]))

    def fit(self, num_predictors):
        for method in self.methods:
            self.fitting_one_method(method, num_predictors)

        self.cv_mae = self.mae_df.mean()
        LOG.info("number of principal components: {}".format(num_predictors))
        LOG.info("-------- cv_mae -----------")
        LOG.info(self.cv_mae)
        LOG.info("-------- cv_mae std -----------")
        LOG.info(self.mae_df.std())


def main(num_predictors):
    result = []
    n_sim = 20
    if not isinstance(num_predictors, int):
        num_predictors = int(num_predictors)
    start = int(time.time())
    LOG.info("Started at: {}".format(start))
    for i in range(n_sim):
        modeler = Models()
        LOG.info("Modeler initialized")
        modeler.fit(num_predictors)
        result.append(modeler.cv_mae.to_frame())

    pd.concat(result).to_csv(os.path.join(conf.DATA_PATH, 'cv_mae_simulation{}_{}.csv'.format(n_sim, num_predictors)))

    end = time.time()
    time_used = (end - start)/60.0
    LOG.info("Ended at: {}".format(end))
    LOG.info("time used: {}".format(time_used))



if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('num_predictors', help='Select number of principal components')
    args = parser.parse_args()
    logging.basicConfig(filename=os.path.join(conf.DATA_PATH, 'capstone_%s.log' % args.num_predictors), level=logging.INFO, filemode='w')

    main(args.num_predictors)
