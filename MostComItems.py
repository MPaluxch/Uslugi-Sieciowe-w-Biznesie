# -*- coding: utf-8 -*-

import pandas as pd 
import os
import warnings
warnings.filterwarnings('ignore')


os.chdir()

sales_data = pd.read_csv('KNIME_Sales_Data.csv')

sales_data['Total.Price']

# drop it using duplicated() funct
data = sales_data[sales_data['Order.ID'].duplicated(keep=False)]
# create a new column
data['Grouped'] = sales_data.groupby('Order.ID')['Product'].transform(lambda x: ','.join(x))
# let's make a new variable
data = data[['Order.ID', 'Grouped']].drop_duplicates()

    
## Create dummy [0/1]
res1 = data      
res2 = res1.join(res1.pop('Grouped').str.get_dummies(','))    
res2 = res2.drop(columns=['Order.ID'])
    
## APRIORI algorithm ##
from efficient_apriori import apriori

## types of dummy values - [string with names of column when > 0]   
res2 = res2.mul(res2.columns).replace('',0)
res2.dtypes

## y - list of combination (products)
y = res2.values
y = [sub[~(sub==0)].tolist() for sub in y if sub [sub != 0].tolist()]

## create list with number of occurrences
trans = y
rules = apriori(trans, min_support = 0.000001, min_confidence = 0.99)
association_results = list(rules)
#print(association_results[0])
 

type(association_results[0][2])

## Dataframes with number of products in list
prodtogh2 = pd.DataFrame(list(association_results[0][2].items()))
prodtogh3 = pd.DataFrame(list(association_results[0][3].items()))
prodtogh4 = pd.DataFrame(list(association_results[0][4].items()))

prodtogh2 = prodtogh2.sort_values(1, ascending=False).head(10)
prodtogh3 = prodtogh3.sort_values(1, ascending=False).head(10)
prodtogh4 = prodtogh4.sort_values(1, ascending=False).head(10)
