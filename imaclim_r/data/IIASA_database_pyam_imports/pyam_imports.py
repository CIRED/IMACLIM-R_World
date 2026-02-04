# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


#####################
# import librairies
import matplotlib.pyplot as plt
import pandas as pd
import pyam
import os

####################
database='ar6-public'
#database='iamc15'
df = pyam.read_iiasa(
            database,
            model='IMACLIM-NLU 1.0',
            variable=['Primary Energy|Biomass|Traditional'],
            #region='World',
            #    region='USA',
            #    meta=['category']
        )

df_temp=df.filter(scenario='EMF33_tax_hi_none', year=2015)
#for reg in df_temp.region:
"""    
>>> df_temp.timeseries()
                                                                                                                                   2100
model           scenario          region                                             variable                           unit           
IMACLIM-NLU 1.0 EMF33_tax_hi_none Asian countries except Japan                       Primary Energy|Biomass|Traditional EJ/yr  15.87100
                                  Brazil                                             Primary Energy|Biomass|Traditional EJ/yr   3.00200
                                  Canada                                             Primary Energy|Biomass|Traditional EJ/yr   1.73000
                                  China                                              Primary Energy|Biomass|Traditional EJ/yr   7.56700
                                  Countries from the Reforming Ecomonies of the F... Primary Energy|Biomass|Traditional EJ/yr   2.75200
                                  Countries of the Middle East and Africa            Primary Energy|Biomass|Traditional EJ/yr   7.89875
                                  European Union (28 member countries)               Primary Energy|Biomass|Traditional EJ/yr   5.63900
                                  India                                              Primary Energy|Biomass|Traditional EJ/yr   4.00100
                                  Latin American countries                           Primary Energy|Biomass|Traditional EJ/yr   5.65200
                                  OECD90 and EU (and EU candidate) countries         Primary Energy|Biomass|Traditional EJ/yr  12.82580
                                  United States of America                           Primary Energy|Biomass|Traditional EJ/yr   4.47200
                                  World                                              Primary Energy|Biomass|Traditional EJ/yr  45.00000
"""

#Tradiotional_biomass_EJ = [4.47200, 1.73000, 5.63900, 0, 2.75200, 7.56700, 4.00100, 3.00200, 0, 7.89875, 15.87100-7.56700-4.00100, 5.65200-3.00200];
#Tradiotional_biomass_EJ(4) = 45.00000 - sum(Tradiotional_biomass_EJ)
# Tradiotional_biomass_EJ  =
#    4.472    1.73    5.639    0.98525    2.752    7.567    4.001    3.002    0.    7.89875    4.303    2.65 

"""
USA
CAN
EUR
JAN
CIS
CHN
IND
BRA
MDE
AFR
RAS
RAL
"""

#['Argentina', 'Asian countries except Japan', 'Asian countries except Japan (R6)', 'Australia', 'Brazil', 'Canada', 'Chile', 'China', 'Colombia', 'Countries from the Reforming Ecomonies of the Former Soviet Union', 'Countries from the Reforming Ecomonies of the Former Soviet Union (R6)', 'Countries of Latin America and the Caribbean', 'Countries of South Asia; primarily India', 'Countries of Sub-Saharan Africa', 'Countries of Sub-Saharan Africa (R6)', 'Countries of centrally-planned Asia; primarily China', 'Countries of the Middle East (R6)', 'Countries of the Middle East and Africa', 'Countries of the Middle East; Iran, Iraq, Israel, Saudi Arabia, Qatar, etc.', 'Eastern and Western Europe (i.e., the EU28)', 'European Union (28 member countries)', 'India', 'Indonesia', 'Japan', 'Latin American countries', 'Latin American countries (R6)', 'Mexico', 'North America; primarily the United States of America and Canada', 'OECD90 and EU (and EU candidate) countries', 'OECD90 and EU (and EU candidate) countries (R6)', 'Other countries of Asia', 'Pacific OECD', 'Pakistan', 'Reforming Economies of Eastern Europe and the Former Soviet Union; primarily Russia', 'Rest of the World (R10)', 'Rest of the World (R5)', 'Rest of the World (R6)', 'Russia', 'Saudi Arabia', 'South Africa', 'South Korea', 'Thailand', 'Turkey', 'United Kingdom', 'United States of America', 'Vietnam?', 'World']

""""
'United States of America':'USA'
'Canada':'CAN'
'European Union (28 member countries)'

'Countries of the Middle East (R6)'
'Countries of the Middle East; Iran, Iraq
, Israel, Saudi Arabia, Qatar, etc.'
'Brazil'
 'China'
'Countries from the Reforming Ecomonies of the Former Soviet Union'
'India'
'Countries of Sub-Saharan Africa'

'Latin American countries (R6)'
'World'
"""
