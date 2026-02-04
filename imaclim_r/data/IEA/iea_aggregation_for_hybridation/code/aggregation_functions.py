# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Nicolas Graves, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import itertools

def read_aggregation_rules(aggregation_rules_path):
    """
    This function reads the aggregation rules layed out in aggregation_rules_path, 
    and returns the corresponding list. 
    """
    aggregation_rules = collections.defaultdict(list)
    with open(aggregation_rules_path,newline='') as csvfile:
        reader = csv.reader(csvfile, delimiter='|')
        for row in reader:
            if row[0][0] != '#':
                hd,*tl = row
                for elt in tl:
                    aggregation_rules[hd].append(elt)

    return aggregation_rules


def aggregate_flows(aggregation_rules_path,aggregate_from_df,complete_rules=False):
    """
    This function reads the aggregation rules layed out in aggregation_rules_path, 
    and applies them (adds the new aggregation flows/lines and drops old flows/lines)
    to the dataframe aggregate_to_df.
    """  
    #
    #Reading aggregation rules and importing them as a list. 
    if type(aggregation_rules_path)==str:
        aggregation_list = list(read_aggregation_rules(aggregation_rules_path).items())
    elif type(aggregation_rules_path) == collections.defaultdict:
        aggregation_list = list(aggregation_rules_path.items())
    else:
        raise NameError("First argument aggregation_rules_path is ill-defined: not a collections.defaultdict nor a str path")
    #
    # Complete aggregation rules with missing element
    if complete_rules:
        elt_in_extended = [elt for elt in itertools.chain.from_iterable( [ext for agg, ext in aggregation_list])]
        all_elt = aggregate_from_df.index.get_level_values('Flow').unique().tolist()
        #aggregation_list = aggregation_list + [[elt,elt] for elt in all_elt if not elt in elt_in_extended]
        aggregation_list = aggregation_list + [(elt,elt) for elt in all_elt if not elt in elt_in_extended]
    #Creating new flows.
    aggregate_to_df = pd.DataFrame()
    for aggregated,extended in aggregation_list:
        temp_mat = aggregate_from_df.loc[(slice(None),slice(None),extended),:].groupby(['Region','Year']).sum(min_count=1)
        temp_mat['Flow'] = aggregated
        temp_mat.set_index('Flow', append=True, inplace=True)

        aggregate_to_df = aggregate_to_df.append(temp_mat)
        #if aggregated not in aggregate_to_df.index:
    return aggregate_to_df 
        #else:
        #aggregate_to_df.loc[tpt_index]=tpt

    #Extracting only useful flows.
    #if aggregate_df_index_ref is None:
    #    return_index = pd.MultiIndex.from_arrays([len(aggregation_list)*list_years,len(list_years)*list(map(lambda x: x[0],aggregation_list))],names=('Year','Flow'))
    #    print(return_index)
    #    return aggregate_to_df.reindex(index=return_index)
    #else : 
    #    try :
    #        return aggregate_to_df.reindex(index=aggregate_df_index_ref)
    #    except ValueError:
    #        print('The aggregation is not correct : missing lines/flows.')
    #        raise
    #return aggregate_to_df
    #return 0
    

def aggregate_products(aggregation_rules_path, aggregate_from_df,aggregate_to_df,complete_rules=False):
    """
    This function reads the aggregation rules layed out in aggregation_rules_path, 
    and applies them (adds the new aggregation products/columns and drops old products/columns)
    to the dataframe aggregate_to_df.
    """
    #Reading aggregation rules and importing them as a list.
    if type(aggregation_rules_path)==str:
        aggregation_list = list(read_aggregation_rules(aggregation_rules_path).items())
    elif type(aggregation_rules_path) == collections.defaultdict:
        aggregation_list = list(aggregation_rules_path.items())
    else:
        raise NameError("First argument aggregation_rules_path is ill-defined: not a collections.defaultdict nor a str path")
    #
    # Complete aggregation rules with missing element
    if complete_rules:
        elt_in_extended = [elt for elt in itertools.chain.from_iterable( [ext for agg, ext in aggregation_list])]
        all_elt = aggregate_from_df.columns
        #aggregation_list = aggregation_list + [[elt,[elt]] for elt in all_elt if not elt in elt_in_extended]
        aggregation_list = aggregation_list + [ (elt,[elt]) for elt in all_elt if not elt in elt_in_extended]
    #Creating new products. 
    for aggregated,extended in aggregation_list:
        aggregate_to_df[aggregated]=pd.DataFrame(aggregate_from_df[extended].sum(axis='columns',min_count=1))
        #if len(extended)>1:
        #    aggregate_to_df[aggregated]=pd.DataFrame(aggregate_from_df[extended].sum(axis='columns',min_count=1))
        #else:
        #    aggregate_to_df[aggregated]=aggregate_from_df[extended]
    #
    #Extracting only useful flows.
    #if aggregate_df_columns_ref is None:
    #    return_columns=list(map(lambda x: x[0],aggregation_list))
    #    return aggregate_to_df[return_columns]
    #else:
    #    try :
    #        return aggregate_to_df.reindex(columns=aggregate_df_columns_ref)
    #    except ValueError:
    #        print('The aggregation is not correct : missing columns/products.')
    #        raise
    #return aggregate_to_df
    return 0

def set_pandas_display_options() -> None:
    """Set pandas display options."""
    # Ref: https://stackoverflow.com/a/52432757/
    display = pd.options.display
    display.max_columns = 1000
    display.max_rows = 1000
    display.max_colwidth = 199
    display.width = None
    display.precision = 3  # set as needed
    display.float_format = '{:,.3f}'.format


def distribute_flow_one_product(origin_flow, target_flows, target_product):
    """
    Distribute the origin_flow according to the pro-rata among target_flows for one product.
    This product is the one in the pd.Series in target_flows. This operation is in place. 
    This function returns the potential countries for which there is null data for all flows, for
    later special treatments.
    "web" is assumed to be a global variable. 
    The function can potentially be easily improved for use with a pd.DataFrame and for applying
    a key for each product. 
    """
    #For countries without energy industries nor industries identified, we save the countries
    # to return them in the end. 
    test = target_flows.abs().sum(level=['Region','Year'])
    countries_non_specified = test.loc[test ==0].reset_index()['Region'].to_list() 
    countries_specified = test.loc[test !=0].reset_index()['Region'].to_list() 
     
    target_flows.drop(countries_non_specified, level='Region', inplace=True)
    
    shares = (target_flows.abs()/target_flows.abs().sum(level=['Region','Year'])).sort_index(level='Region').copy()
    
    #Only  useful for second alternative in the next loop.
    shares = shares.reset_index()
    origin_flow = origin_flow.reset_index()

    
    for region in countries_specified:
        for flow in set(target_flows.reset_index()['Flow'].to_list()):
            # This version should work, unidentified bug. 
            # web.loc[(region,slice(None),flow),:] -= shares.loc[(region,slice(None),flow),:].to_numpy()[0][0]*origin_flow.loc[(region,slice(None),slice(None)),:].to_numpy()
            # Both next alternatives work, but they are awfully slow, need to find an improvement. 
            # web.loc[(region,slice(None),flow),:] -= shares.reset_index().set_index('Region').loc[region].reset_index().set_index('Flow').loc[flow][target_product]*origin_flow.loc[(region,slice(None),slice(None)),:].to_numpy()
            web.loc[(region,slice(None),flow),target_product] += shares[(shares['Region']==region)&(shares['Flow']==flow)][target_product].to_numpy()[0]*origin_flow[(origin_flow['Region']==region)][target_product].to_numpy()[0]
            
    return countries_non_specified
