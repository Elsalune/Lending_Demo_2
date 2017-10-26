'''
Prediction script: takes learn_base as input and outputs a predictive model.
'''

import numpy as np
import pandas as pd

from xgboost import XGBClassifier
from sklearn.ensemble import RandomForestClassifier

from sklearn.base import TransformerMixin
from sklearn.preprocessing import FunctionTransformer
from sklearn.pipeline import make_pipeline

from sklearn.preprocessing import Imputer

from sklearn.model_selection import cross_val_score

from sklearn.externals import joblib

from transformerclasses import ColumnSelector

print("Load Data")
train_data = pd.read_feather("../inputs/learn_base.feather")

print("Filter Data")
train_data = train_data.loc[train_data['loan_status'].isin(['Fully Paid', 'Charged Off'])]
train_data = train_data.assign(diff_financed=np.abs(train_data['loan_amnt'] - train_data['funded_amnt']))
train_data = train_data.loc[train_data['diff_financed'] < 1, :]

print("Features creation")
train_data = train_data.assign(easy_loan_status=np.where(train_data['loan_status'] == 'Fully Paid', 0, 1))
train_data = train_data.assign(has_desc=np.where(train_data['desc'].isnull(), 0, 1))

num_features = ['loan_amnt', 'int_rate', 'installment', 'annual_inc', 'has_desc', 'dti', 'delinq_2yrs']
cat_features = ['grade', 'home_ownership', 'verification_status', 'purpose']
all_features = num_features + cat_features

X = train_data.drop(['easy_loan_status'], axis=1)
y = train_data['easy_loan_status']

rf_params = {'n_estimators': 150,
             'max_depth': 5,}

rf_pipeline = make_pipeline(
	ColumnSelector(all_features),
	FunctionTransformer(pd.get_dummies, validate=False, kw_args={'dummy_na': True}),
	Imputer(strategy='median'),
	RandomForestClassifier(**rf_params),
	)

print("Evaluating rf CV scores")
rf_cv_scores = cross_val_score(rf_pipeline, X, y, scoring='roc_auc')

print("The rf ROC AUC scores are:")
print(rf_cv_scores)

xgb_params = {'max_depth': 10, 
              'learning_rate': 0.1,
              'n_estimators': 500,
              'lambda': 0.8,}

xgb_pipeline = make_pipeline(
	ColumnSelector(all_features),
	FunctionTransformer(pd.get_dummies, validate=False, kw_args={'dummy_na': True}),
	Imputer(strategy='median'),
	XGBClassifier(**xgb_params),
	)

print("Evaluating xgb CV scores")
xgb_cv_scores = cross_val_score(xgb_pipeline, X, y, scoring='roc_auc')

print("The xgb ROC AUC scores are:")
print(xgb_cv_scores)
#joblib.dump(rf_pipeline, '../models/rf_pipe.pkl')