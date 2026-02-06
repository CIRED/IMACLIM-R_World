# -*- coding: utf-8 -*-
#
# usefull fonction for pandas
#
# Original author: Florian Leblanc
# date first creation: 10-08-2021

import pandas as pd
from functools import partial, reduce

#-----------------------------------------------------------------------------------------------------------
# function to move all values of a column as columns index
def df_set_column_values_as_columns_indexes( df_in, column_name_as_index, column_name_for_value):
    # reset index in case there is a multiindex
    if isinstance(df_in.index, pd.MultiIndex):
        df_in = df_in.reset_index()
    # column value need to be last column
    new_col = [ col for col in df_in.columns if col != column_name_for_value]
    new_col.insert( len( df_in.columns)-1, column_name_for_value)
    df_in = df_in[ new_col]
    # set column values as index
    dfs = [ df_in.loc[ df_in[ column_name_as_index] == var].drop([ column_name_as_index], axis=1).rename(columns={ column_name_for_value: var}) for var in list(set( df_in[ column_name_as_index])) ]
    merge = partial(pd.merge, on= [elt for elt in df_in.keys() if elt not in [ column_name_as_index, column_name_for_value]], how='outer')
    return reduce(merge, dfs)

#-----------------------------------------------------------------------------------------------------------
# function to move all indexes of columns as values in a single column
def df_set_columns_indexes_as_column_values( df_in, columns_index, new_col_index, value_index='value'):
    pd_merge_list = list()
    for elt_select in columns_index:
        df = df_in[ [elt for elt in df_in.keys() if (not elt in columns_index) or elt==elt_select]].rename(columns={ elt_select: value_index})
        df[new_col_index] = elt_select
        pd_merge_list.append( df)
    merge = partial(pd.merge, on= [elt for elt in df_in.keys() if not elt in columns_index]+[value_index, new_col_index], how='outer')
    return reduce(merge, pd_merge_list)
#-----------------------------------------------------------------------------------------------------------
# function to change type of a column and sort it. 
def change_type_N_sort( df, col, newtype, ascending=True):
    df=df.astype({col:newtype}, ascending)
    # rename cost column when there were several occurences in the original import
    return df.sort_values(by=[col])
#-----------------------------------------------------------------------------------------------------------

