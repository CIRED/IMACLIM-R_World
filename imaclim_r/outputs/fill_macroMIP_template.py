import pandas as pd
import pyam
import os
import shutil
import openpyxl as oxl
import numpy as np



dict_region={'WORLD':['World'],'EU28':['EUR'],'CHN':['CHN'], 'IND':['IND'],'USA':['USA'],'CAN':['CAN'],'RUS':['CIS'],'JPN':['JAN'],'SAR':['MDE'],'BRA':['BRA']}
# missing : 'KOR', 'REP'
list_year = np.arange(2015,2051,5)
list_sc = ['SUP_NPi_Default', 'SUP_2C_Default' ,'SUP_1p5C_Default','SUP_2C_Lab','SUP_2C_Lump','SUP_2C_VAT','SUP_2C_Prod','SUP_1p5C_Lab','SUP_1p5C_Lump','SUP_1p5C_VAT','SUP_1p5C_Prod']

# NB region
# NB GDP in MER
#Industries aggregated

list_var = ['GDP|MER', 'Employment|Total', 'Investment', 'Consumption|Governments', 'Consumption|Households','Production|Total','Trade|Value|Exports','Trade|Value|Imports']
list_var = list_var + ['','Production|Agriculture', 'Production|Fossil fuels', 'Production|Electricity',  'Production|Industries',  '', 'Production|Construction',  'Production|Services','']
list_var = list_var + ['','Employment|Agriculture', 'Employment|Fossil fuels', 'Employment|Electricity',  'Employment|Industries',  '', 'Employment|Construction',  'Employment|Services','']
list_var = list_var + ['','Trade|Value|Exports|Agriculture', 'Trade|Value|Exports|Fossil fuels', 'Trade|Value|Exports|Electricity',  '', 'Trade|Value|Exports|Industries',  'Trade|Value|Exports|Construction',  'Trade|Value|Exports|Services','']
list_var = list_var + ['','Trade|Value|Imports|Agriculture', 'Trade|Value|Imports|Fossil fuels', 'Trade|Value|Imports|Electricity', '', 'Trade|Value|Imports|Industries',  'Trade|Value|Imports|Construction',  'Trade|Value|Imports|Services']


input_excel = [elt for elt in os.listdir() if 'IMACLIM' in elt and '.xlsx' in elt][0]

template_excel = 'Template for data_T2.6.xlsx'
template_excel_output = '_IMACLIM.'.join(template_excel.split('.'))

shutil.copyfile( template_excel, template_excel_output)

data_loaded=False
if data_loaded==False:
    df= pyam.IamDataFrame(input_excel) 
    data_loaded = True

workbook = oxl.load_workbook(template_excel_output)

list_sc_run = [elt for elt in list_sc if elt in df.scenario]
list_var_2print = [elt for elt in list_var if elt != '']

# Excel informations
row_start=3+1
col_start=2+1

col_next_table = 11

i=0
for agg_reg, list_reg in dict_region.items():
    ws = workbook[agg_reg]
    for sc in list_sc_run:
        for var in list_var_2print:
            row = row_start + list_var.index(var)
            df_temp=df.filter(scenario=sc, variable=var,region=list_reg, year=list_year)
            if len(list_reg) >1:
                df_temp = df_temp.aggregate_region(var)
            val_year = df_temp.timeseries().values
            for i_year in range(val_year.shape[1]):
                col = col_start + list_sc.index(sc) * col_next_table + i_year
                ws.cell(row, col).value = val_year[0,i_year]
                i+=1

workbook.save(template_excel_output)

