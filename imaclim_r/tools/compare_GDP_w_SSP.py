#! /data/software/mambaforge/mambaforge//envs/MostUpdated/bin/python
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


import pandas as pd
import csv
import collections
from numpy import genfromtxt
import numpy as np
import os
import sys
import pyam
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

path_ssp = "../data/UNO_n_SSP_population/results/GDP_ssp_IMACLIM_region.csv"
path_output_imaclim = "../outputs/011_base_2025_04_28_15h29min42s/IMACLIM_navigate_outputs_SUP_NPi_Default.xlsx"
ssp="SSP2"

model = "OECD_ENV-Growth_2023" #"IIASA_GDP_2023" # OECD_ENV-Growth_2023

# load ssp dataframe
ssp_gdp = pd.read_csv("../data/UNO_n_SSP_population/results/GDP_ssp_IMACLIM_region_"+model+"_"+ssp+".csv")

#########################################
# load scenarios

CPI_2017_to_2010 =    0.8944465  

list_xlsx_file = [elt for elt in os.listdir(path_output_imaclim) if '.xlsx' in elt and 'IMACLIM' in elt]
df=pyam.concat( [pyam.IamDataFrame(path_output_imaclim+x) for x in list_xlsx_file])

#sc2select = ["SUP_NPi_Default" + i for i in ["_base","_trunk_V2.0","_noChange_AFR"]]
df = df.filter(variable="GDP|PPP")

df = df.convert_unit("billion US$2010/yr", to="billion USD_2017/yr",factor=1e3 / CPI_2017_to_2010)

##########################################
dff = pyam.concat( [df, ssp_gdp])

pp = PdfPages('GDP_comparison.pdf')

plt.close('all')
for reg in dff.region:
    #plt.clf()
    #fig = plt.figure() # no need to call plt.figure() with pandas
    df2plot = dff.filter(region=reg)
    df2plot.plot(color="scenario", title="GDP|PPP - "+reg)
    # print 2100 difference
    a=df2plot.filter(year=2100, scenario='NoPolicy_Default').timeseries().values[0,0]
    b=df2plot.filter(year=2100, scenario=ssp).timeseries().values[0,0]
    print(reg, "The difference is (%): ", round((a-b)/b*100,2))   

def save_multi_image(filename):
    pp = PdfPages(filename)
    fig_nums = plt.get_fignums()
    figs = [plt.figure(n) for n in fig_nums]
    for fig in figs[::-1]:
        fig.savefig(pp, format='pdf')
    pp.close()

filename = "GDP_comparison.pdf"
save_multi_image(filename)

