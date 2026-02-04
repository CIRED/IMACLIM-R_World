#! /usr/bin/env python
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Patrice Dumas, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


import sys
import os
import argparse
import copy
import numpy as np
import common_cired
import aggregation_GTAP

# %run ./extract_GTAP.py GTAP_raw/GTAP6/ss/ ./results/extracted_GTAP6/

parser = argparse.ArgumentParser('extract GTAP data')

parser.add_argument('data_dir')
parser.add_argument('output_dir')

args = parser.parse_args()

dataPath = args.data_dir
outputdir = args.output_dir

common_cired.mkdir_exists(outputdir)

sets_file = dataPath +'gsdset.ss'
fd_sets = open(sets_file)
sets_variables_infos, sets_line_nr = aggregation_GTAP.parseGTAPssHeader(fd_sets, sets_file)

gsdvole_file = dataPath +'gsdvole.ss'
if os.path.isfile(gsdvole_file):
    fd_gsdvole = open(gsdvole_file)
    gsdvole_variables_infos, gsdvole_line_nr = aggregation_GTAP.parseGTAPssHeader(fd_gsdvole, gsdvole_file)
else:
    gsdvole_variables_infos = None

CO2_file = dataPath +'gsdemiss.ss'
if os.path.isfile(CO2_file):
    fd_CO2 = open(CO2_file)
    CO2_variables_infos, CO2_line_nr = aggregation_GTAP.parseGTAPssHeader(fd_CO2, CO2_file)
else:
    CO2_variables_infos = None


basedata_file = dataPath +'gsddat.ss'
fd_basedata = open(basedata_file)
basedata_variables_infos, basedata_line_nr = aggregation_GTAP.parseGTAPssHeader(fd_basedata, basedata_file)

baseview_file = dataPath +'gsdview.ss'
fd_baseview = open(baseview_file)
baseview_variables_infos, baseview_line_nr = aggregation_GTAP.parseGTAPssHeader(fd_baseview, baseview_file)

dimensions_sizes = {}
aggregation_GTAP.check_variables_dimension_sizes(sets_variables_infos, dimensions_sizes)
aggregation_GTAP.check_variables_dimension_sizes(basedata_variables_infos, dimensions_sizes)
aggregation_GTAP.check_variables_dimension_sizes(baseview_variables_infos, dimensions_sizes)
if gsdvole_variables_infos is not None:
    aggregation_GTAP.check_variables_dimension_sizes(gsdvole_variables_infos, dimensions_sizes)
if CO2_variables_infos is not None:
    aggregation_GTAP.check_variables_dimension_sizes(CO2_variables_infos, dimensions_sizes)

print('Data '+sets_file)
# sets explicitly defined: [u'TRAD_COMM', u'ENDW_COMM', u'REG', u'CGDS_COMM']
sets_result, sets_strings, dimensions_values = aggregation_GTAP.parseGTAPData(fd_sets, sets_variables_infos, source_name=sets_file, line_nr=sets_line_nr)

if gsdvole_variables_infos is not None:
    print('Data '+gsdvole_file)
    gsdvole_result, gsdvole_strings, dimensions_values = aggregation_GTAP.parseGTAPData(fd_gsdvole, gsdvole_variables_infos, source_name=gsdvole_file, line_nr=gsdvole_line_nr, dimensions_values=dimensions_values)
else:
    gsdvole_result = None
    gsdvole_variables_infos = None

print('Data '+basedata_file)
basedata_result, basedata_strings, dimensions_values = aggregation_GTAP.parseGTAPData(fd_basedata, basedata_variables_infos, source_name=basedata_file, line_nr=basedata_line_nr, dimensions_values=dimensions_values)

print('Data '+baseview_file)
baseview_result, baseview_strings, dimensions_values = aggregation_GTAP.parseGTAPData(fd_baseview, baseview_variables_infos, source_name=baseview_file, line_nr=baseview_line_nr, dimensions_values=dimensions_values)

if CO2_variables_infos is not None:
    print('Data '+CO2_file)
    CO2_result, CO2_strings, dimensions_values = aggregation_GTAP.parseGTAPData(fd_CO2, CO2_variables_infos, source_name=CO2_file, line_nr=CO2_line_nr, dimensions_values=dimensions_values)
else:
    CO2_result = None

#----------------------------------------------------------------------------------

extracted_variables = {}
variables_dimensions_info = {}
for variables_result, variables_infos in [[basedata_result, basedata_variables_infos], [baseview_result, baseview_variables_infos], [gsdvole_result, gsdvole_variables_infos], [CO2_result, CO2_variables_infos]]:
    if variables_result is not None:
        for variable_name in variables_infos:
            variable_dimension_sizes, variable_dimensions, variable_data_name, variable_prototype = variables_infos[variable_name]
            if variable_dimensions is not None:
                dimensions_names = '*'.join(variable_dimensions)
                variables_dimensions_info[variable_name] = dimensions_names
                extracted_variables[variable_name] = variables_result[variable_name]

output_file = outputdir+"GTAP_tables.csv"
print('output in '+output_file)

extracted_dimensions_values = aggregation_GTAP.filter_dimensions_and_export_dimensions_tables(output_file, dimensions_values, extracted_variables, variables_dimensions_info, var_list=sorted(extracted_variables))

#----------------------------------------------------------------------------------
print('\n\n         ***** THE END OF EVERYTHING ******:')

