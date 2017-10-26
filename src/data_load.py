''' 
This script imports raw, parses dates, cast categories.
'''

import os
import numpy as np
import pandas as pd

def load_data(file_path):
    ''' 
    This function loads at given path.
    Then dates are parsed, categories are casted.
    '''
    dtype = {
    'desc': 'object',
    'verification_status_joint': 'category',
    'grade': 'category',
    'emp_length': 'category',
    'home_ownership': 'category',
    'verification_status': 'category',
    'loan_status': 'category',
    'pymnt_plan': 'category',
    'purpose': 'category',
    'initial_list_status': 'category',
    'application_type': 'category',
    }

    dates_to_parse = [
    'earliest_cr_line',
    'issue_d',
    'last_pymnt_d',
    'next_pymnt_d',
    'last_credit_pull_d'
    ]
    
    data = (pd.read_csv(file_path, dtype=dtype,
                        parse_dates=dates_to_parse)
              .assign(term=lambda x: x['term'].str.extract('(\d+)', 
                      expand=False).astype(int))
              .dropna(axis=1, how='all'))
    
    return(data)

def learn_score_split(df):
    '''
    Separate train and score data based on issue_d.
    Limit dates are hard coded and depend on the time span of
    the observations.
    '''
    closed_short_loans_mask = ((data['issue_d'] < np.datetime64('2012-06-01'))
                               & (data['term'] == 36))
    closed_long_loans_mask = ((data['issue_d'] < np.datetime64('2010-06-01')) 
                               & (data['term'] == 60))
    closed_loans_mask = closed_short_loans_mask | closed_long_loans_mask

    learn_base = df.loc[closed_loans_mask, :].reset_index() # reset_index necessary to write to feather format
    score_base = df.loc[~ closed_loans_mask, :].reset_index()

    return learn_base, score_base


if __name__ == "__main__":
    print("Start loading data. Go have a coffee if you are on a DXC computer.")
    data = load_data("../inputs/loan.csv")
    print("Data loaded.")

    print("learn score split")
    learn_base, score_base = learn_score_split(data)

    print("Write learn_base to feather format.")
    learn_base.to_feather("../inputs/learn_base.feather")

    print("Write score_base to feather format")
    score_base.to_feather("../inputs/score_base.feather")
    print("All done !")
