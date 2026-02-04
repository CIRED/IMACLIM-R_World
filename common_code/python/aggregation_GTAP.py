# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc, Patrice Dumas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

# -*- coding: utf-8 -*-
#
# aggregation_GTAP.py: functions for GTAP data parsing, aggregation, 
# and output. GTAP versions 6 and 8 have been tested, it is likely that
# GTAP 7 is working as well.  When exporting, can export separate
# csv file tables, and/or a file holding all the info for instance for 
# processing in python.
#
# Original author: Florian Leblanc

import csv
import os
import sys
import re
import numpy as np
import common_cired

#########################################################################################################
# Functions definition #
#########################################################################################################

significant_digit = 12

def round_result(input_data, significant_digit=significant_digit):
    return str(common_cired.round_figures(input_data, significant_digit))

# detect the delimiter of a file path
def detect_csv_file_delimiter(file_path):
    tfile = open(file_path, 'r')
    line = common_cired.decode_input_string(tfile.readline())
    if line.find('|') != -1:
        delim_char = '|'
    elif line.find(',') != -1:
        delim_char = ','
    elif line.find(';') != -1:
        delim_char = ';'
    else:
        delim_char = '\t'
    tfile.close()
    return delim_char

#----------------------------------------------------------------------------------
# FIXME not used anymore, remove
# get ordering of aggregated elements in refList, aggregation
# and order of aggregates from dict_path.  Return aggregation, and 
# aggregate names orders and file delimiter
def gen_csv2dict(dict_path, refList):
    d_delimiter = detect_csv_file_delimiter(dict_path)
    dict_data = open(dict_path, 'r')
    csv_reader = common_cired.UnicodeCsvReader(dict_data, delimiter=d_delimiter)
    aggregates_names_list = []
    aggregation_dict = {}
    common_cired.extract_aggregation_lines(csv_reader, aggregation_dict, aggregates_names_list, keep_order=True, allow_empty_aggregated=False)
    dict_data.close()
    return aggregation_dict, aggregates_names_list, d_delimiter

#----------------------------------------------------------------------------------
# FIXME not used anymore, remove
def GTAPcsv2Array(dataPath, varHeader):
    #convert the Gtap data exported into csv format..  (.ss) into an array
    originalHeader = ['CM04','SF01','SF02','SF03','BI01','BI02','BI03']
    newHeader = ['VALOUTPUT','NVFA','NVPA','NVGA','VALEXPORTS','VALIMPORTS','CIFDECOMP']
    datasource = open(dataPath, 'r')
    dataInput = np.genfromtxt(datasource, delimiter='xdk1kouL0l1!pop2M3rD3',names=None,skip_header=0,dtype=str,filling_values=0)
    datasource.close()
    shapeArray = list()
    #make the 1D later a specification. the function doesn't work for singleton
    # first we get the number of dimensions
    numLine = 0
    for iL in range(len(dataInput)):
        if varHeader in dataInput[iL]:
            numLine = iL +1
            dimensions = dataInput[iL].replace('   ',' ').replace('  ',' ').split(' ')[4]
            print('... loading '+str(dataInput[iL])+' ...')
            shapeStr = dimensions.split('x')    
            nbDim = len(shapeStr)
            for i in range(nbDim):
                shapeArray.append(float(shapeStr[i]))
            if 'BaseView' in dataPath:
                if varHeader in originalHeader:
                    varHeader = newHeader[originalHeader.index(varHeader)]
                else: sys.stderr.write('there is a problem, you didn''t declare in the lists originalHeader & newHeader the corresponding new header of the original Header '+varHeader+"\n")
            break
    # then the name of dimensions
    for iL in range(len(dataInput)-numLine):
        if varHeader in dataInput[iL+numLine]:
            dimension = dataInput[iL+numLine].split('(')[1].replace(')','')#can be use later to 'guess' dictionaries
            numLine = numLine + iL +1
            break
    # finally all the 2D arrays of the 2:end dimensions
    arrayOut= np.zeros(shapeArray,dtype=float) 
    for iL in range(len(dataInput)-numLine):
        match = re.search('^ *coefficient '+varHeader+r'\(([^)]+)\)', dataInput[iL+numLine])
        #if 'coefficient '+varHeader in dataInput[iL+numLine]:
        if match:
            dimensions_names = match.group(1)
            numLine = numLine + iL +1
            break
    #case of 1D
    if nbDim == 1:
        shapeArray.append(float(1))
        numLine = numLine - 1
    nbTables = 1 # number of 2D tables present in the .ss file to describe the varHeader data
    foundTables = 0 # iterators on found tables
    arrayIndices = list() # usefull to construct the 'indices' list of a 'n' dimension array, whatever n is
    arrayIndices.append('0')
    if nbDim > 1: # exception for 1D datas
        arrayIndices.append(':')
    for i in range(nbDim-2):
        nbTables = nbTables * shapeArray[nbDim-i-1]
        arrayIndices.append('0')
    for iL in range(len(dataInput)):
        if ((dataInput[iL+numLine].split('(')[0] == varHeader) & (dataInput[iL+numLine][0:1] != ' !')) | (nbDim == 1):
            foundTables = foundTables +1
            # store the found data table, line by line
            for dim1 in range(int(shapeArray[0])):
                arrayIndices[0] = str(dim1) # change the first dimension, line by line we said
                strIndices = str('[')
                for jt in range(len(arrayIndices)):
                    if jt != (len(arrayIndices)-1):
                        strIndices = strIndices + arrayIndices[jt] + ','
                    else:
                        strIndices = strIndices + arrayIndices[jt] + ']'
                listTemp = dataInput[iL+numLine+dim1+1].split('|') # store the data string
                lineTemp=[]
                for lin in range(int(shapeArray[1])):  # clean the data string
                    element = listTemp[lin+1].replace(' ','')
                    lineTemp.append(element)
                if nbDim ==1:# exception for 1D datas
                    lineTemp = float(lineTemp[0])
                exec('arrayOut' + strIndices + '=np.array(lineTemp)')
            if foundTables == nbTables:
                break
            # increment the array Indices vector
            incremented = False
            incrementedDim = 3
            while incremented == False: # for dim > 2
                arrayIndices[incrementedDim-1] = str(int(arrayIndices[incrementedDim-1]) + 1)
                if float(arrayIndices[incrementedDim-1]) == shapeArray[incrementedDim-1]: # for dim >3
                    arrayIndices[incrementedDim-1] = str('0')
                    incrementedDim = incrementedDim + 1
                else:
                    incremented = True
    dimensions_numbers = '*'.join([str(int(shape_nr)) for shape_nr in shapeArray])
    return arrayOut, dimensions_names, dimensions_numbers

#----------------------------------------------------------------------------------
# datasource is a file descriptor
# result variables_infos is a dictionary, keys are variable names and values:
# [dimensions_numbers_array, dimensions_names_array, variable_name, variable_prototype]
def parseGTAPssHeader(datasource, source_name='', line_nr=0):
    after_header = None
    in_header = False
    variables_infos = {}
    variable_header = None
    while True:
        next_line = common_cired.decode_input_string(datasource.readline().rstrip("\n\r"))
        line_nr += 1
        #print(after_header, in_header, variable_header, next_line)
        if not in_header and re.search('^ *! *.*HEADER.*ARRAY DIMENSIONS.*LONG NAME', next_line):
            after_header = True
        else:
            match_var_header = re.search('^ *! *([0-9]+) +([A-Z0-9]+) +([A-Z0-9:]+) +([0-9x]+)', next_line)
            if match_var_header:
                if after_header is None:
                    sys.stderr.write(common_cired.encode_output_string("WARNING: "+source_name+": "+str(line_nr)+": variable info not after a header: "+next_line+"\n"))
                if after_header:
                    in_header = True
                    after_header = False
                header_variable_name = match_var_header.group(2)
                dimensions_numbers = match_var_header.group(4)
                dimensions_numbers_array = [int(dim_number) for dim_number in dimensions_numbers.split('x')]
                variable_header = header_variable_name
                variables_infos[header_variable_name] = [dimensions_numbers_array, None, None, None]
            elif variable_header:
                # it is important to get prototypes variable names, which
                # corresponds to data and can be different from header
                data_variable_dimensions = None
                match_variable_prototype = None
                data_variable_name = None
                prototype_string = None
                header_variable_name = variable_header
                if len(variables_infos[header_variable_name][0]) == 1:
                    match_variable_prototype = re.search(r'^ *! *([A-Z0-9_]+) *$', next_line)
                    if match_variable_prototype:
                        data_variable_name = match_variable_prototype.group(1)
                        prototype_string = data_variable_name
                    else:
                        match_variable_prototype = re.search(r'^ *! *\(([^)]+)\) *$', next_line)
                        if match_variable_prototype:
                            prototype_string = '('+match_variable_prototype.group(1)+')'
                if not match_variable_prototype:
                    match_variable_prototype = re.search(r'^ *! *([A-Z0-9_]+)\(([^)]+)\)', next_line)
                    if match_variable_prototype:
                        data_variable_name = match_variable_prototype.group(1)
                        prototype_string = data_variable_name+'('+match_variable_prototype.group(2)+')'
                        data_variable_dimensions = match_variable_prototype.group(2).split(',')
                        if len(data_variable_dimensions) != len(variables_infos[header_variable_name][0]):
                            sys.stderr.write(common_cired.encode_output_string("WARNING: "+source_name+": "+str(line_nr)+": "+header_variable_name+": dimensions lengths do not match: ("+'x'.join(variables_infos[header_variable_name][0])+") "+str(len(variables_infos[header_variable_name][0]))+" != "+str(len(data_variable_dimensions))+"("+','.join(data_variable_dimensions)+"\n"))
                if match_variable_prototype:
                    variables_infos[header_variable_name][1] = data_variable_dimensions
                    variables_infos[header_variable_name][2] = data_variable_name
                    variables_infos[header_variable_name][3] = prototype_string
                else:
                    break
                variable_header = None
            elif in_header:
                break
    return variables_infos, line_nr

# fill dimensions_sizes and check too
def check_variables_dimension_sizes(variables_infos, dimensions_sizes):
    for variable_name in sorted(variables_infos):
        variable_dimension_sizes, variable_dimensions, variable_data_name, variable_prototype = variables_infos[variable_name]
        if variable_dimensions is not None:
            for dimension_idx, dimension_name in enumerate(variable_dimensions):
                if dimension_name not in dimensions_sizes:
                    dimensions_sizes[dimension_name] = variable_dimension_sizes[dimension_idx]
                elif dimensions_sizes[dimension_name] != variable_dimension_sizes[dimension_idx]:
                    sys.stderr.write(common_cired.encode_output_string("WARNING: "+variable_name+": "+dimension_name+": size differ "+str(dimensions_sizes[dimension_name])+" != "+str(variable_dimension_sizes[dimension_idx])+"\n"))

def _set_compare_dimension_values(dimensions_values, current_dimensions_values, source_name, line_nr, in_variable_from_header, location, dimension_name):
    if dimension_name not in dimensions_values:
        dimensions_values[dimension_name] = current_dimensions_values
    elif dimensions_values[dimension_name] != current_dimensions_values:
        sys.stderr.write(common_cired.encode_output_string("ERROR: "+source_name+": "+str(line_nr)+": "+in_variable_from_header+": "+location+": "+dimension_name+": dimension values different from reference\n"))
        current_dimensions = set(current_dimensions_values)
        reference_dimensions = set(dimensions_values[dimension_name])
        if len(current_dimensions) > len(reference_dimensions):
            sys.stderr.write(common_cired.encode_output_string("   current("+str(len(current_dimensions))+") - ref("+str(len(reference_dimensions))+"): "+"|".join(sorted(current_dimensions - reference_dimensions))+"; "+"|".join(sorted(reference_dimensions - current_dimensions))+"\n"))
        else:
            sys.stderr.write(common_cired.encode_output_string("   ref("+str(len(reference_dimensions))+") - current("+str(len(current_dimensions))+"): "+"|".join(sorted(reference_dimensions - current_dimensions))+"; "+"|".join(sorted(current_dimensions - reference_dimensions))+"\n"))
        return False
    return True

def parseGTAPData(datasource, variables_infos, source_name='', line_nr=0, dimensions_values=None):
    result = {}
    result_strings_values = {}
    if dimensions_values is None:
        dimensions_values = {}
    in_variable_from_header = None
    in_coefficient = None
    current_table_dimension_indices = None
    in_data = False
    in_matrix = None
    remaining_tables = None
    strings_values = None
    current_table_dimension_values = None
    while True:
        next_line = datasource.readline()
        if next_line == '':
            break
        next_line = common_cired.decode_input_string(next_line.rstrip("\n\r"))
        line_nr += 1
        if not in_data:
            #print(line_nr, in_data, in_variable_from_header, in_coefficient, current_table_dimension_indices, in_matrix, remaining_tables)
            #print(line_nr, in_data, in_variable_from_header, in_coefficient, current_table_dimension_indices, in_matrix, remaining_tables, current_table_dimension_values)
            #print("          %%%%%"+next_line)
            # ! Real array of size 57x87 from header "2IMP"
            # not that there can be spaces in the name in case the name is less than
            # 4 characters, for example:
            #  ! Real array of size 87 from header "POP "
            match_header = re.search('^ *!.* from header "([A-Z0-9_]+) *" *$', next_line)
            if match_header:
                if current_table_dimension_indices is not None:
                    if remaining_tables != 0:
                        sys.stderr.write(common_cired.encode_output_string("ERROR: "+source_name+": "+str(line_nr)+": "+in_variable_from_header+": missing remaining tables: "+str(remaining_tables)+"\n"))
                    current_table_dimension_indices = None
                in_variable_from_header = match_header.group(1)
                in_coefficient = None
                if in_variable_from_header not in variables_infos:
                    sys.stderr.write(common_cired.encode_output_string("ERROR: "+source_name+": "+str(line_nr)+": "+in_variable_from_header+": unknown variable from header name\n"))
                    return None
                variable_dimension_sizes, variable_dimensions, variable_data_name, variable_prototype = variables_infos[in_variable_from_header]
                if variable_dimensions is not None and len(variable_dimensions) > 2:
                    total_tables = 1
                    for dimension_size in variable_dimension_sizes[2:]:
                        total_tables *= dimension_size
                    remaining_tables = total_tables
                    current_table_dimension_indices = [0] * (len(variable_dimension_sizes) - 2)
                    # we increase when the first value arrives, then it will be 0
                    current_table_dimension_indices[0] = -1
                    current_table_dimension_values = [[]] * (len(variable_dimension_sizes) - 2)
                    result[in_variable_from_header] = np.zeros(variable_dimension_sizes, dtype=np.float)
                    result_table = result[in_variable_from_header]
            elif re.search('^ *coefficient +', next_line):
                coefficient_line_variable_prototype = re.sub('^ *coefficient +', '', next_line)
                coefficient_line_variable_prototype.rstrip()
                if not in_variable_from_header:
                    sys.stderr.write(common_cired.encode_output_string("ERROR: "+source_name+": "+str(line_nr)+": coefficient outside of variable from header: "+coefficient_line_variable_prototype+"\n"))
                else:
                    variable_prototype = variables_infos[in_variable_from_header][3]
                    if variable_prototype != coefficient_line_variable_prototype:
                        sys.stderr.write(common_cired.encode_output_string("ERROR: "+source_name+": "+str(line_nr)+": "+in_variable_from_header+": coefficient prototype differs from header "+variable_prototype+" != "+coefficient_line_variable_prototype+"\n"))
                in_coefficient = coefficient_line_variable_prototype
            elif in_variable_from_header is not None and variables_infos[in_variable_from_header][2] is not None and re.search('^ *!.* The matrix '+variables_infos[in_variable_from_header][2], next_line):
                # ! The matrix NVFA(%1,%2,"aus","domestic","mktexp")
                variable_dimension_sizes, variable_dimensions, variable_data_name, variable_prototype = variables_infos[in_variable_from_header]
                if len(variable_dimensions) < 3:
                    sys.stderr.write(common_cired.encode_output_string("WARNING: "+source_name+": "+str(line_nr)+": "+in_variable_from_header+": Matrix specification with less than 3 dimensions: "+next_line+"\n"))
                else:
                    match_matrix_spec = re.search('^ *!.* The matrix '+variables_infos[in_variable_from_header][2]+r'\(%1,%2,([^)]+)\)',next_line)
                    if not match_matrix_spec:
                        sys.stderr.write(common_cired.encode_output_string("ERROR: "+source_name+": "+str(line_nr)+": "+in_variable_from_header+": cannot parse matrix specification: "+next_line+"\n"))
                    else:
                        specified_variables = (match_matrix_spec.group(1)).split(",")
                        if len(specified_variables) != len(variable_dimensions) - 2:
                            sys.stderr.write(common_cired.encode_output_string("WARNING: "+source_name+": "+str(line_nr)+": "+in_variable_from_header+": Matrix specification with incorrect specified items ("+str(len(variable_dimensions) - 2)+"): "+match_matrix_spec.groups(1)+"\n"))
                        else:
                            specified_variables_values = [item_value.rstrip('"').lstrip('"') for item_value in specified_variables]
                            # initialize dimension values for the first table, except for the 
                            # first dimension which is set with the first increase of index
                            if current_table_dimension_indices[0] == -1:
                                for idx_specified_variables_value, specified_variables_value in enumerate(specified_variables_values[1:]):
                                    current_table_dimension_values[idx_specified_variables_value+1] = [specified_variables_value]
                            for idx_specified_variables_value, specified_variables_value in enumerate(specified_variables_values):
                                index_dimension = idx_specified_variables_value + 2
                                current_table_dimension_indices[idx_specified_variables_value] += 1
                                if current_table_dimension_indices[idx_specified_variables_value] + 1 > variable_dimension_sizes[index_dimension]:
                                    # if the dimension is over the size, reset and continue over
                                    # next dimension
                                    current_table_dimension_values[idx_specified_variables_value] = [specified_variables_value]
                                    current_table_dimension_indices[idx_specified_variables_value] = 0
                                else:
                                    # not over the size, collect dimension value and stop here
                                    current_table_dimension_values[idx_specified_variables_value].append(specified_variables_value)
                                    if current_table_dimension_indices[idx_specified_variables_value] + 1 == variable_dimension_sizes[index_dimension]:
                                        dimension_name = variable_dimensions[index_dimension]
                                        status_comparison = _set_compare_dimension_values(dimensions_values, list(current_table_dimension_values[idx_specified_variables_value]), source_name, line_nr, in_variable_from_header, 'multiple matrix', dimension_name)
                                        if not status_comparison:
                                             sys.stderr.write("BUG: correct code (check data)\n")
                                             print(line_nr, specified_variables_values, idx_specified_variables_value, index_dimension, current_table_dimension_values, current_table_dimension_indices)
                                             sys.exit(1)
                                    break
                            in_matrix = list(current_table_dimension_indices)
            elif re.search('^ *([0-9]+) +strings', next_line):
                # header for list of strings, in particular dimensions
                variable_dimension_sizes, variable_dimensions, variable_data_name, variable_prototype = variables_infos[in_variable_from_header]
                match_strings_nr = re.search('^ *([0-9]+) +strings', next_line)
                nr_strings_total = int(match_strings_nr.group(1))
                if len(variable_dimension_sizes) != 1 or variable_dimension_sizes[0] != nr_strings_total or variable_prototype is not None:
                    sys.stderr.write(common_cired.encode_output_string("ERROR: "+source_name+": "+str(line_nr)+": "+in_variable_from_header+": "+str(variable_dimension_sizes)+" not consistent with strings list: "+next_line+"\n"))
                strings_values = []
            elif strings_values is not None:
                match_strings_long_name = re.search('^ *"([^"]+)" *;', next_line)
                if not match_strings_long_name:
                    sys.stderr.write(common_cired.encode_output_string("ERROR: "+source_name+": "+str(line_nr)+": "+in_variable_from_header+": long strings name expected: "+next_line+"\n"))
                else:
                    strings_long_name = match_strings_long_name.group(1)
                    in_data = ['strings', strings_long_name, None, None]
                    match_set_name = re.search('^[Ss]et +([A-Z0-9_]+) +(.*)$', strings_long_name)
                    if match_set_name:
                        in_data[2] = match_set_name.group(1)
                        in_data[3] = match_set_name.group(2)
                #print("in_data", in_data)
                # it is important to skip data parsing with in_data set below
                continue
            elif re.search('^ *!', next_line):
                pass
            else:
                if in_variable_from_header is not None:
                    variable_dimension_sizes, variable_dimensions, variable_data_name, variable_prototype = variables_infos[in_variable_from_header]
                    if current_table_dimension_indices is not None and in_matrix is None:
                        if in_coefficient and remaining_tables == total_tables and re.search("^ *$", next_line):
                            # empty line after coefficient and before first matrix specification is ok
                            continue
                    if (current_table_dimension_indices is not None and in_matrix is not None) or (variable_dimensions is not None and len(variable_dimensions) == 2):
                        match_data = re.search('^ *'+variables_infos[in_variable_from_header][2]+r'\(', next_line)
                        if match_data:
                            if current_table_dimension_indices is not None:
                                in_data = ['multitable', in_matrix]
                                in_matrix = None
                            else:
                                in_data = ['matrix']
                                result[in_variable_from_header] = np.zeros(variable_dimension_sizes, dtype=np.float)
                                result_table = result[in_variable_from_header]
                            header_array = [header_item.strip() for header_item in next_line.split("|")]
                            # first is the prototype
                            header_array.pop(0)
                            # last is always empty
                            header_array.pop()
                            header_dimension_name = variable_dimensions[1]
                            _set_compare_dimension_values(dimensions_values, header_array, source_name, line_nr, in_variable_from_header, 'matrix header', header_dimension_name)
                            # it is important to skip data parsing with in_data set below
                            column_dimension_values = []
                            column_idx = 0
                            continue
                    else:
                        if variable_dimensions is None:
                            in_data = ['scalar']
                        else:
                            in_data = ['array']
                            column_dimension_values = []
                            column_idx = 0
                        result[in_variable_from_header] = np.zeros(variable_dimension_sizes, dtype=np.float)
                        result_table = result[in_variable_from_header]
                if not in_data:
                    sys.stderr.write(common_cired.encode_output_string("ERROR: "+source_name+": "+str(line_nr)+": unexpected line: "+next_line+"\n"))
                    print(line_nr, in_data, in_variable_from_header, in_coefficient, current_table_dimension_indices, in_matrix, remaining_tables)
                    raise
                #print("in_data", in_data)
        # get data right now for the array and scalar cases as we are already
        # in the data line
        if in_data:
            if re.search("^ *$", next_line) or (in_data[0] == 'strings' and  re.search("^ *!", next_line)):
                if current_table_dimension_indices is not None:
                    remaining_tables -= 1
                if in_data[0] == 'strings':
                    in_data_type, strings_name, set_variable, set_name = in_data
                    total_strings_nr = variables_infos[in_variable_from_header][0][0]
                    if len(strings_values) != total_strings_nr:
                        sys.stderr.write(common_cired.encode_output_string("ERROR: "+source_name+": "+str(line_nr)+": "+in_variable_from_header+": missing strings: "+str(total_strings_nr - len(strings_values))+"\n"))
                    remaining_strings = None
                    result_strings_values[strings_name] = strings_values
                    if set_variable is not None:
                        _set_compare_dimension_values(dimensions_values, strings_values, source_name, line_nr, in_variable_from_header, 'Set', set_variable)
                    strings_values = None
                elif in_data[0] != 'scalar':
                    data_col_nr = variables_infos[in_variable_from_header][0][0]
                    if len(column_dimension_values) != data_col_nr:
                        sys.stderr.write(common_cired.encode_output_string("ERROR: "+source_name+": "+str(line_nr)+": "+in_variable_from_header+": missing columns: "+str(data_col_nr - len(column_dimension_values))+"\n"))
                    _set_compare_dimension_values(dimensions_values, column_dimension_values, source_name, line_nr, in_variable_from_header, 'matrix columns', variables_infos[in_variable_from_header][1][0])
                    column_dimension_values = None
                if current_table_dimension_indices is None or remaining_tables == 0:
                    # if there are not all the dimension values in data, they 
                    # may not have been registered
                    if current_table_dimension_indices is not None:
                        for specified_dimension_idx in range(len(current_table_dimension_values)):
                            index_dimension = specified_dimension_idx + 2
                            dimension_name = variables_infos[in_variable_from_header][1][index_dimension]
                            dimension_size = variables_infos[in_variable_from_header][0][index_dimension]
                            if dimension_name not in dimensions_values:
                                not_specified_dimension_values_nr = dimension_size - len(current_table_dimension_values[specified_dimension_idx])
                                if not_specified_dimension_values_nr <= 0:
                                    sys.stderr.write(common_cired.encode_output_string("BUG: "+source_name+": "+str(line_nr)+": "+in_variable_from_header+": "+dimension_name+": unregistered with "+str(len(current_table_dimension_values[specified_dimension_idx]))+" >= "+str(dimension_size)+": "+str(current_table_dimension_values[specified_dimension_idx])+"\n"))
                                    sys.exit(1)
                                sys.stderr.write(common_cired.encode_output_string("ERROR: "+source_name+": "+str(line_nr)+": "+in_variable_from_header+": "+dimension_name+': '+str(not_specified_dimension_values_nr)+' dimensions not specified '+str(current_table_dimension_values[specified_dimension_idx])+"\n"))
                                sys.exit(1)
                    in_variable_from_header = None
                    current_table_dimension_indices = None
                    in_coefficient = None
                in_data = False
            elif in_data[0] == 'strings':
                strings_values.append(next_line.strip())
            else:
                data_array = [data_item.strip() for data_item in next_line.split("|")]
                if in_data[0] == 'scalar':
                    result_table[0] = data_array[0]
                else:
                    # last is always empty
                    data_array.pop()
                    dimension_value = data_array.pop(0)
                    data_array = [float(data_value) for data_value in data_array]
                    if in_data[0] == 'multitable':
                        result_table[tuple([column_idx, slice(None)] + in_data[1])] = data_array
                    elif in_data[0] == 'matrix':
                        result_table[column_idx,:] = data_array
                    elif in_data[0] == 'array':
                        result_table[column_idx] = data_array[0]
                    column_dimension_values.append(dimension_value)    
                    column_idx += 1
    return result, result_strings_values, dimensions_values

#----------------------------------------------------------------------------------
def GTAPsql2Array(dataPath,varHeader):
    #convert the Gtap data exported into the called 'sql format' by gtap..  (.csv) into an array
    #this function is not use anymore, because of missing lines (zeros value where missing, which is then a bullshit to parse
    datasource = open(dataPath,'r')
    iL=0
    lineStart=None
    lineStop = None
    success = 0
    for row in datasource:
        iL=iL+1
        if (row.split(',')[0] == '!Header: '+ varHeader):
            success = 1
            lineStart = iL+2
            description = row.split(',')[2]
            info = row.split(',')[1].replace(' dimensions: ','')
            print('... loading '+description.rstrip().replace('description: ','')+' ...')
            dimension = info.split(' ')[1].replace('[','').replace(']','')
            nbDim = len(dimension.split('*'))
            nbLines = 1
            newShape = []
            for nDim in range(nbDim):
                nbLines = nbLines * int(dimension.split('*')[nDim])
                newShape.append(int(dimension.split('*')[nbDim-1-nDim]))
            lineStop = lineStart + nbLines-1
            arrayOut = np.zeros(nbLines,dtype=float)
        if ((iL >= lineStart) & (iL <= lineStop)):
            arrayOut[iL-lineStart] =  float( row.split(',')[nbDim].rstrip())
        if iL > lineStop:
            break
    datasource.seek(0)
    arrayOut = arrayOut.reshape(newShape)
    arrayOut = np.transpose(arrayOut)
    if success ==0:
        print('no Header '+varHeader+' was found in the declared file')
    else:
        return arrayOut

#----------------------------------------------------------------------------------
def aggregate_variable_dimensions(variable_name, values_dict, data_dimensions, dimensions_aggregation_informations):
    list_dict_aggregation = []
    for dimension_name in data_dimensions[variable_name]:
        list_dict_aggregation.append(dimensions_aggregation_informations[dimension_name])
    return aggregateArray(values_dict[variable_name], list_dict_aggregation)

#----------------------------------------------------------------------------------
def aggregateArray(inputArray, listDictio):
    input_dim = inputArray.ndim
    # listDictio[i][0] is the i-th dictionary, listDictio[i][1] is the i-th dictionary names,listDictio[i][2] the non aggregated list of elet of dimension i, in original order
    dataAgreg = inputArray
    array_all_indices = []
    for dim in range(input_dim):
        array_all_indices.append(slice(None))
    # create the new output array by aggregated dimensions one by one
    for idx_dimension in range(input_dim):
        # if a dictionalry is None, no aggregation over that dimension
        if listDictio[idx_dimension] is None or listDictio[idx_dimension][0] is None:
            continue
        shapeNewArray = list(dataAgreg.shape)
        aggregates_dimensions_order = listDictio[idx_dimension][1]
        shapeNewArray[idx_dimension] = len(aggregates_dimensions_order)
        hyperShape = []
        for ind in range(len(shapeNewArray)):
            if ind != idx_dimension:
                hyperShape.append(shapeNewArray[ind])
        arrayTemp = np.zeros(shapeNewArray)
        aggregation_dict = listDictio[idx_dimension][0]
        for index_aggregate_dim, aggregate_dim in enumerate(aggregates_dimensions_order):
            # prepare a mask
            mask = np.in1d(listDictio[idx_dimension][2], aggregation_dict[aggregate_dim])
            if mask.any():
                # gather indices of the true elements in mask
                maskIndices = []
                for index_in_mask, mask_value in enumerate(mask):
                    if mask_value:
                        maskIndices.append(index_in_mask)
                # aggregate following the mask along the aggregation axis
                arTmp = np.zeros(hyperShape)
                np.take(dataAgreg,maskIndices,axis=idx_dimension).sum(axis=idx_dimension,out=arTmp)
                # prepare indexing with new aggregate index and
                # every values for all the other dimensions
                indices_of_aggregate_matrix = list(array_all_indices)
                indices_of_aggregate_matrix[idx_dimension] = index_aggregate_dim
                arrayTemp[tuple(indices_of_aggregate_matrix)] = arTmp
            elif listDictio[idx_dimension][0][aggregate_dim] != []:
                sys.stderr.write('WARNING: no mask for dimension: '+str(idx_dimension)+' with the category '+str(aggregate_dim)+"\n")
        dataAgreg = arrayTemp
    return dataAgreg

#----------------------------------------------------------------------------------
# FIXME not used anymore, remove
def aggregateGTAP(inputData, listDictio):
    aggregatedData = aggregateArray(inputData, listDictio)
    if abs(inputData.sum() - aggregatedData.sum()) > 1e-6:
        print('     ..Aggregation failed at an e-6 accuracy, difference is: '+round_result(abs(inputData.sum() - aggregatedData.sum())))
    return aggregatedData

#----------------------------------------------------------------------------------
# FIXME not used anymore, remove
def aggregateGTAP_variable_dimensions(variable_name, values_dict, data_dimensions, dimensions_aggregation_informations):
    aggregatedData = aggregate_variable_dimensions(variable_name, values_dict, data_dimensions, dimensions_aggregation_informations)
    inputData = values_dict[variable_name]
    if abs(inputData.sum() - aggregatedData.sum()) > 1e-6:
        print('     ..Aggregation failed at an e-6 accuracy, difference is: '+round_result(abs(inputData.sum() - aggregatedData.sum())))
    return aggregatedData

#----------------------------------------------------------------------------------
_dataDelimiterCode = 'dataDelimiterCode'
_dimensionDelimiterCode = 'dimensionDelimiterCode'

def export2D(varName, array, dimName, path):
    #export 2D arrays
    fileout = open(path + varName + '.csv', "w")
    dataout = common_cired.UnicodeCvsWriter(fileout, delimiter='|', lineterminator="\n")
    lineName = dimName[0]
    dataout.writerow([varName] + dimName[1])
    for i in range(len(lineName)):
        listTemp = list()
        listTemp.append(lineName[i])
        if len(dimName[1]) != 1:
            for j in range(len(array[i,:])):
                listTemp.append(round_result(array[i,j]))
        else:
            listTemp.append(round_result(array[i]))
        dataout.writerow(listTemp)
    fileout.close()

def export1D(varName, array, dimName, path):
    #export 1D arrays
    fileout = open(path + varName + '.csv', "w")
    dataout = common_cired.UnicodeCvsWriter(fileout, delimiter='|', lineterminator="\n")
    lineName = dimName[0]
    dataout.writerow([varName] + dimName[1])
    listTemp = list()
    listTemp.append(lineName)
    if len(dimName[1]) != 1:
        for j in range(len(array[:])):
            listTemp.append(round_result(array[j]))
    else:
        listTemp.append(round_result(array[0]))
    dataout.writerow(listTemp)
    fileout.close()

def filter_dimension_with_variables(dimensions_values, variables_dimensions, var_list=None):
    filtered_dimensions = set()
    if var_list is None:
        var_list = set(variables_dimensions)
    for variable_name in var_list:
        dimensions_string = variables_dimensions[variable_name]
        dimensions_array = dimensions_string.split('*')
        filtered_dimensions |= set(dimensions_array)
    filtered_dimensions_values = {}
    for filtered_dimension in filtered_dimensions:
        filtered_dimensions_values[filtered_dimension] = dimensions_values[filtered_dimension]
    return filtered_dimensions_values

def export_dimensions_tables_file(path, variables, variables_dimensions, dimension_values, export_var_list=None):
    #export all the variables in one file
    fileout = open(path, "w")
    dataout = common_cired.UnicodeCvsWriter(fileout, delimiter='|', lineterminator="\n")
    # - metadatas
    dataout.writerow(['delimiter','bar'])
    dataout.writerow([_dataDelimiterCode,'!HEADER!'])
    dataout.writerow([_dimensionDelimiterCode,'!DIMENSION!'])
    dataout.writerow(['dimension_header_info', 'name; size'])
    dataout.writerow(['data_header_info', 'name; dimensions; dimSizes'])
    dataout.writerow([''])
    # - dimensions
    for dimension_name in sorted(dimension_values):
        dimension_list = dimension_values[dimension_name]
        dataout.writerow(['!DIMENSION!', dimension_name, str(len(dimension_list))])
        dataout.writerow(['value'])
        for dimension_value in dimension_list:
            dataout.writerow([dimension_value])
        dataout.writerow([''])
    # - datas
    if export_var_list is None:
        export_var_list = sorted(variables)
    for variable_name in export_var_list:
        dimensions_string = variables_dimensions[variable_name]
        dimensions_array = dimensions_string.split('*')
        dimensions_sizes = [len(dimension_values[dimension_name]) for dimension_name in dimensions_array]
        results_dimensions = '*'.join([str(dimension_size) for dimension_size in dimensions_sizes])
        dataout.writerow(['!HEADER!',variable_name,dimensions_string,results_dimensions])
        dataout.writerow(dimensions_array+['value'])
        results = variables[variable_name]
        if dimensions_sizes != list(results.shape):
            sys.stderr.write("dimensions from infos different from shape: "+','.join([str(dim_size) for dim_size in dimensions_sizes])+' != '+','.join([str(dim_size) for dim_size in results.shape])+"\n")
        write_table_data(dataout, results, dimensions_array, dimension_values)
        dataout.writerow([''])
    fileout.close()

def write_table_data(dataout, results, dimensions_array, dimension_values, prefixed_array=[]):
    #print(variable_name, dimensions_array)
    for dim1_idx, dim1_item in enumerate(dimension_values[dimensions_array[0]]):
        if len(dimensions_array) == 1:
            dataout.writerow(prefixed_array+[dim1_item, round_result(results[dim1_idx])])
        else:
            for dim2_idx, dim2_item in enumerate(dimension_values[dimensions_array[1]]):
                if len(dimensions_array) == 2:
                    dataout.writerow(prefixed_array+[dim1_item, dim2_item, round_result(results[dim1_idx, dim2_idx])])
                else:
                    for dim3_idx, dim3_item in enumerate(dimension_values[dimensions_array[2]]):
                        if len(dimensions_array) == 3:
                            dataout.writerow(prefixed_array+[dim1_item, dim2_item, dim3_item, round_result(results[dim1_idx, dim2_idx, dim3_idx])])
                        else:
                            for dim4_idx, dim4_item in enumerate(dimension_values[dimensions_array[3]]):
                                if len(dimensions_array) == 4:
                                    dataout.writerow(prefixed_array+[dim1_item, dim2_item, dim3_item, dim4_item, round_result(results[dim1_idx, dim2_idx, dim3_idx, dim4_idx])])
                                else:
                                    for dim5_idx, dim5_item in enumerate(dimension_values[dimensions_array[4]]):
                                        if len(dimensions_array) == 5:
                                            dataout.writerow(prefixed_array+[dim1_item, dim2_item, dim3_item, dim4_item, dim5_item, round_result(results[dim1_idx, dim2_idx, dim3_idx, dim4_idx, dim5_idx])])
                                        else:
                                            sys.stderr(common_cired.encode_output_string("FATAL: "+varName+": "+dimensions_string+": too many dimensions\n"))
 
def filter_dimensions_and_export_dimensions_tables(output_file, dimensions_values, variables_values, variables_dimensions_info, var_list=None):
    extracted_dimensions_values = filter_dimension_with_variables(dimensions_values, variables_dimensions_info, var_list=var_list)
    export_dimensions_tables_file(output_file, variables_values, variables_dimensions_info, extracted_dimensions_values, export_var_list=var_list)
    return extracted_dimensions_values

#----------------------------------------------------------------------------------
dimension_file_export_map = {
  'REG': 'Region.csv',
  'SEC': 'Sector.csv',
  'FUEL': 'Fuel.csv',
  'ENER': 'Energy.csv',
}  

def exportSAM(varNamesList, dict_export_var, dimension_values, variables_dimensions, path):
    if path != '':
        path += '/'
    #export regions and sectors names (and fuel name)
    for dimension_name in dimension_values:
        if dimension_name in dimension_file_export_map:
            output_dimension_file = dimension_file_export_map[dimension_name]
        else:
            output_dimension_file = dimension_name+'.csv'
        fileout = open(path + output_dimension_file, "w")
        dataout = common_cired.UnicodeCvsWriter(fileout, delimiter='|', lineterminator="\n")
        dataout.writerow(dimension_values[dimension_name])
        fileout.close()
    
    #export the all SAM in 2D csv (one for each region if 3D)
    for varName in varNamesList:
        array = dict_export_var[varName]
        if variables_dimensions[varName] == 'SEC*SEC*REG':
            for region in range(len(dimension_values['REG'])):
                export2D(varName+'_'+dimension_values['REG'][region],array[:,:,region],[dimension_values['SEC'],dimension_values['SEC']],path)
        elif variables_dimensions[varName] == 'SEC*REG*REG':
            # note that for this variable is exported transposed
            for region in range(len(dimension_values['REG'])):
                export2D(varName+'_'+dimension_values['REG'][region],np.transpose(array[:,region,:]),[dimension_values['REG'],dimension_values['SEC']],path)
        elif variables_dimensions[varName] == 'FUEL*SEC*REG':
            for region in range(len(dimension_values['REG'])):
                export2D(varName+'_'+dimension_values['REG'][region],array[:,:,region],[dimension_values['FUEL'],dimension_values['SEC']],path)
        elif variables_dimensions[varName] == 'FUEL*REG*Activity_nonCO2_combustion':
            for region in range(len(dimension_values['REG'])):
                export2D(varName+'_'+dimension_values['REG'][region],array[:,region,:],[dimension_values['FUEL'],dimension_values['Activity_nonCO2_combustion']],path)
        elif variables_dimensions[varName] == 'FUEL_COMM*PROD_COMM*REG':
            for region in range(len(dimension_values['REG'])):
                export2D(varName+'_'+dimension_values['REG'][region],array[:,:,region],[dimension_values['FUEL_COMM'],dimension_values['PROD_COMM']],path)
        elif variables_dimensions[varName] == 'ENER*SEC*REG':
            for region in range(len(dimension_values['REG'])):
                export2D(varName+'_'+dimension_values['REG'][region],array[:,:,region],[dimension_values['ENER'],dimension_values['SEC']],path)
        elif variables_dimensions[varName] == 'SEC*REG':
            export2D(varName,np.transpose(array),[dimension_values['REG'],dimension_values['SEC']],path)
        elif variables_dimensions[varName] == 'FUEL*REG':
            export2D(varName,np.transpose(array),[dimension_values['REG'],dimension_values['FUEL']],path)
        elif variables_dimensions[varName] == 'FUEL_COMM*REG':
            export2D(varName,np.transpose(array),[dimension_values['REG'],dimension_values['FUEL_COMM']],path)
        elif variables_dimensions[varName] == 'REG':
            export1D(varName,np.transpose(array),[varName,dimension_values['REG']],path)
        elif variables_dimensions[varName] == 'SEC':
            export1D(varName,np.transpose(array),[varName,dimension_values['SEC']],path)
        else:
            print(varName+': '+variables_dimensions[varName]+': not handled for table export')

#----------------------------------------------------------------------------------
def exportSAM_tableformat(dict_export_var, dimension_values, variables_dimensions, list_endowments_var, path):
    if path != '':
        path += '/'
    # export the SAM in an input-output table format, in .csv
    for region in range(len(dimension_values['REG'])):
        fileout = open(path + "aggregated_inputoutput_table_"+dimension_values['REG'][region]+".csv", "w")
        dataout = common_cired.UnicodeCvsWriter(fileout, delimiter='|', lineterminator="\n")
        # first the "uses" in lines
        # first header
        list_first_header = ['', '', 'CI_imp_cor', 'CI_imp_cor', 'CI_dom_cor', 'CI_dom_cor', 'CI_tot', 'C_hsld_imp_cor', 'C_hsld_dom_cor', 'C_hsld_tot', 'C_AP_imp_cor', 'C_AP_dom_cor', 'C_AP_tot', 'FCBF_imp_cor', 'FCBF_dom_cor', 'FCBF_tot', 'Exp_cor','Exp_trans_cor', 'Exp_tot', 'Emploi_tot'] 
        dataout.writerow( list_first_header)
        # second header
        list_second_header = list_first_header
        index =-1
        for ii in range(2):
            for sector_in in range(len(dimension_values['SEC'])):
                index += 1
                list_second_header[index] = dimension_values['SEC'][ sector_in]
            index += 1
            list_second_header[index] = 'Sub_Total'
        dataout.writerow( list_second_header)
        # CI_imp in line
        list_subtotals_uses = list()
        subtotal_CI_ressource = list()
        for sector_in in range(len(dimension_values['SEC'])): 
            total_uses = 0
            list_row_out = ['CI_imp_cor', dimension_values['SEC'][sector_in] ]
            # CI_imp on column
            CI_tot = 0
            sub_total = 0
            for sector_out in range(len(dimension_values['SEC'])):
                value = dict_export_var['CI_imp_cor'][sector_in,sector_out,region]
                list_row_out.append( value)
                sub_total += value
            list_row_out.append(sub_total)
            if sector_in == 0:
                subtotal_CI_ressource = [elt for elt in list_row_out[ 2:(len(dimension_values['SEC'])+1+1+1)]]
            else:
                for ii in range( len(dimension_values['SEC'])+1):
                    subtotal_CI_ressource[ ii] = subtotal_CI_ressource[ ii] + list_row_out[ ii+2]
            # CI_dom on column
            CI_tot += sub_total
            sub_total = 0
            for sector_out in range(len(dimension_values['SEC'])):
                value = dict_export_var['CI_dom_cor'][sector_in,sector_out,region]
                list_row_out.append( value)
                sub_total += value
            list_row_out.append(sub_total)
            CI_tot += sub_total
            list_row_out.append( CI_tot)
            total_uses += CI_tot
            # C_hsld, C_AP_ FBCF
            for var in ['C_hsld', 'C_AP', 'FBCF']:
                sub_total = 0
                value = dict_export_var[ var+'_imp_cor'][sector_in,region]
                list_row_out.append(value)
                sub_total += value
                value = dict_export_var[ var+'_dom_cor'][sector_in,region]
                list_row_out.append(value)
                sub_total += value
                list_row_out.append(sub_total)
            total_uses += sub_total
            # Exp
            sub_total = 0
            value = dict_export_var[ 'Exp_cor'][sector_in,region]
            list_row_out.append(value)
            sub_total += value
            value = dict_export_var[ 'Exp_trans_cor'][sector_in,region]
            list_row_out.append(value)
            sub_total += value
            list_row_out.append(sub_total)
            # total uses
            total_uses += sub_total
            list_row_out.append(total_uses)
            dataout.writerow( list_row_out)
            if sector_in == 0:
                list_subtotals_uses = [elt for elt in list_row_out]
            else:
                for ii in range(len(list_subtotals_uses)-2):
                    list_subtotals_uses[ ii +2] = list_subtotals_uses[ ii +2] + list_row_out[ii+2]
        dataout.writerow( ['CI_imp_cor', 'Sub_Total'] + list_subtotals_uses)
        #######################""
        # Now resources 
        # CI_dom
        resource_tot = list()
        sub_total_row = list()
        for sector_in in range(len(dimension_values['SEC'])):
            list_row_out = ['CI_dom_cor', dimension_values['SEC'][ sector_in]]
            sub_totol_col = 0
            for sector_out in range(len(dimension_values['SEC'])):
                value = dict_export_var[ 'CI_dom_cor'][sector_in,sector_out,region]
                list_row_out.append( value)
                sub_totol_col += value
                if len( sub_total_row) < len(dimension_values['SEC']):
                    sub_total_row.append( value)
                else:
                    sub_total_row[ sector_out] = sub_total_row[ sector_out] + value
            list_row_out.append( sub_totol_col)
            if len( sub_total_row) == len(dimension_values['SEC']):
                sub_total_row.append( sub_totol_col)
            else:
                sub_total_row[ -1] = sub_total_row[ -1] + sub_totol_col
            dataout.writerow( list_row_out)
        dataout.writerow( ['CI_dom_cor', 'Sub_total'] + sub_total_row)
        for ii in range(len(subtotal_CI_ressource)):
            subtotal_CI_ressource[ ii ] = subtotal_CI_ressource[ ii ] + sub_total_row[ii]
        dataout.writerow( ['', 'CI_tot'] + subtotal_CI_ressource)
        resource_tot = [elt for elt in subtotal_CI_ressource]
        # VA
        sub_total_row = list()
        list_var = [elt for elt in list_endowments_var if 'T_' not in elt]
        for var in list_var:
            list_row_out = ['VA', var]
            sub_totol_col = 0
            for sector_out in range(len(dimension_values['SEC'])):
                value = dict_export_var[ var][sector_out,region]
                list_row_out.append( value)
                sub_totol_col += value
                if len( sub_total_row) < len(dimension_values['SEC']):
                    sub_total_row.append( value)
                else:
                    sub_total_row[ sector_out] = sub_total_row[ sector_out] + value
            list_row_out.append( sub_totol_col)
            if len( sub_total_row) == len(dimension_values['SEC']):
                sub_total_row.append( sub_totol_col)
            else:
                sub_total_row[ -1] = sub_total_row[ -1] + sub_totol_col
            dataout.writerow( list_row_out)
        dataout.writerow( ['VA', 'VA_tot'] + sub_total_row)
        for ii in range(len(resource_tot)):
            resource_tot[ii] += sub_total_row[ii]
        # M
        sub_total_row = list()
        for var in ['Imp_cor', 'Imp_trans_cor']:
            list_row_out = ['M', var]
            sub_totol_col = 0
            for sector_out in range(len(dimension_values['SEC'])):
                value = dict_export_var[ var][sector_out,region]
                list_row_out.append( value)
                sub_totol_col += value
                if len( sub_total_row) < len(dimension_values['SEC']):
                    sub_total_row.append( value)
                else:
                    sub_total_row[ sector_out] = sub_total_row[ sector_out] + value
            list_row_out.append( sub_totol_col)
            if len( sub_total_row) == len(dimension_values['SEC']):
                sub_total_row.append( sub_totol_col)
            else:
                sub_total_row[ -1] = sub_total_row[ -1] + sub_totol_col
            dataout.writerow( list_row_out)
        dataout.writerow( ['M', 'M_tot'] + sub_total_row)
        for ii in range(len(resource_tot)):
            resource_tot[ii] += sub_total_row[ii]
        # Tax
        sub_total_row = list()
        list_var = ['T_prod']+[elt for elt in list_endowments_var if 'T_' in elt]
        for var in list_var:
            list_row_out = ['Tax', var]
            sub_totol_col = 0
            for sector_out in range(len(dimension_values['SEC'])):
                value = dict_export_var[ var][sector_out,region]
                list_row_out.append( value)
                sub_totol_col += value
                if len( sub_total_row) < len(dimension_values['SEC']):
                    sub_total_row.append( value)
                else:
                    sub_total_row[ sector_out] = sub_total_row[ sector_out] + value
            list_row_out.append( sub_totol_col)
            if len( sub_total_row) == len(dimension_values['SEC']):
                sub_total_row.append( sub_totol_col)
            else:
                sub_total_row[ -1] = sub_total_row[ -1] + sub_totol_col
            dataout.writerow( list_row_out)
        dataout.writerow( ['Tax', 'Tax_tot'] + sub_total_row)
        for ii in range(len(resource_tot)):
            resource_tot[ii] += sub_total_row[ii]

        # Now resources 
        subtotal_CI_ressource = list()
        # T_CI_dom
        sub_total_row = list()
        for sector_in in range(len(dimension_values['SEC'])):
            list_row_out = ['T_CI_dom_cor', dimension_values['SEC'][ sector_in]]
            sub_totol_col = 0
            for sector_out in range(len(dimension_values['SEC'])):
                value = dict_export_var[ 'T_CI_dom_cor'][sector_in,sector_out,region]
                list_row_out.append( value)
                sub_totol_col += value
                if len( sub_total_row) < len(dimension_values['SEC']):
                    sub_total_row.append( value)
                else:
                    sub_total_row[ sector_out] = sub_total_row[ sector_out] + value
            list_row_out.append( sub_totol_col)
            if len( sub_total_row) == len(dimension_values['SEC']):
                sub_total_row.append( sub_totol_col)
            else:
                sub_total_row[ -1] = sub_total_row[ -1] + sub_totol_col
            dataout.writerow( list_row_out)
        dataout.writerow( ['T_CI_dom', 'Sub_total'] + sub_total_row)
        subtotal_CI_ressource = [elt for elt in sub_total_row]
        for ii in range(len(resource_tot)):
            resource_tot[ii] += sub_total_row[ii]

        # T_CI_imp
        sub_total_row = list()
        for sector_in in range(len(dimension_values['SEC'])):
            list_row_out = ['T_CI_imp_cor', dimension_values['SEC'][ sector_in]]
            sub_totol_col = 0
            for sector_out in range(len(dimension_values['SEC'])):
                value = dict_export_var[ 'T_CI_imp_cor'][sector_in,sector_out,region]
                list_row_out.append( value)
                sub_totol_col += value
                if len( sub_total_row) < len(dimension_values['SEC']):
                    sub_total_row.append( value)
                else:
                    sub_total_row[ sector_out] = sub_total_row[ sector_out] + value
            list_row_out.append( sub_totol_col)
            if len( sub_total_row) == len(dimension_values['SEC']):
                sub_total_row.append( sub_totol_col)
            else:
                sub_total_row[ -1] = sub_total_row[ -1] + sub_totol_col
            dataout.writerow( list_row_out)
        dataout.writerow( ['T_CI_imp_cor', 'Sub_total'] + sub_total_row)
        for ii in range(len(subtotal_CI_ressource)):
            subtotal_CI_ressource[ ii ] = subtotal_CI_ressource[ ii ] + sub_total_row[ii]
        for ii in range(len(resource_tot)):
            resource_tot[ii] += sub_total_row[ii]
        dataout.writerow( ['', 'Tax_tot'] + subtotal_CI_ressource)

        # T_FBCF, T_Hsld, T_AP
        for elt in ['FBCF', 'Hsld', 'AP']:
            sub_total_row = list()
            for var in ['T_'+elt+'_dom_cor', 'T_'+elt+'_imp_cor']:
                list_row_out = ['T'+elt, var]
                sub_totol_col = 0
                for sector_out in range(len(dimension_values['SEC'])):
                    value = dict_export_var[ var][sector_out,region]
                    list_row_out.append( value)
                    sub_totol_col += value
                    if len( sub_total_row) < len(dimension_values['SEC']):
                        sub_total_row.append( value)
                    else:
                        sub_total_row[ sector_out] = sub_total_row[ sector_out] + value
                list_row_out.append( sub_totol_col)
                if len( sub_total_row) == len(dimension_values['SEC']):
                    sub_total_row.append( sub_totol_col)
                else:
                    sub_total_row[ -1] = sub_total_row[ -1] + sub_totol_col
                dataout.writerow( list_row_out)
            dataout.writerow( ['T'+elt, 'T_'+elt+'_tot'] + sub_total_row)
        for ii in range(len(resource_tot)):
            resource_tot[ii] += sub_total_row[ii]
        # T Imp Exp
        sub_total_row = list()
        for var in ['T_Imp_cor', 'T_Exp_cor', 'Auto_TMX']:
            list_row_out = ['TMtax', var]
            sub_totol_col = 0
            for sector_out in range(len(dimension_values['SEC'])):
                value = dict_export_var[ var][sector_out,region]
                list_row_out.append( value)
                sub_totol_col += value
                if len( sub_total_row) < len(dimension_values['SEC']):
                    sub_total_row.append( value)
                else:
                    sub_total_row[ sector_out] = sub_total_row[ sector_out] + value
            list_row_out.append( sub_totol_col)
            if len( sub_total_row) == len(dimension_values['SEC']):
                sub_total_row.append( sub_totol_col)
            else:
                sub_total_row[ -1] = sub_total_row[ -1] + sub_totol_col
            dataout.writerow( list_row_out)
        dataout.writerow( ['TMtax', 'T_M_tax_tot'] + sub_total_row)
        for ii in range(len(resource_tot)):
            resource_tot[ii] += sub_total_row[ii]
        dataout.writerow( ['Ressource','Ressource_tot']+ resource_tot)

        fileout.close()
    return 0

#----------------------------------------------------------------------------------
def read_dimensions_tables_file(file_path, selected_variables=None):
    delimiter = common_cired.find_csv_metadata_delimiter(file_path)
    fd_dimensions_tables_file = open(file_path)
    csv_reader = common_cired.UnicodeCsvReader(fd_dimensions_tables_file, delimiter=delimiter)
    metadata, metadata_lines, line_nr = common_cired.read_metadata_iterable(csv_reader)
    dataDelimiterCode = metadata[_dataDelimiterCode][0]
    dimensionDelimiterCode = metadata[_dimensionDelimiterCode][0]
    #print(dataDelimiterCode, dimensionDelimiterCode)
    dimensions = {}
    results = {}
    results_dimensions = {}
    dimensions_indices = {}
    in_serie = None
    header_in_serie = None
    while True:
        try:
            input_data = next(csv_reader)
        except StopIteration:
            break
        line_nr += 1
        if header_in_serie:
            in_serie = header_in_serie
            header_in_serie = None
            #sys.stderr.write("header_in_serie\n")
        elif in_serie:
            if len(input_data) == 0 or input_data[0] == '':
                #sys.stderr.write("end in_serie "+in_serie[2]+"\n")
                if in_serie[1] != 0:
                    sys.stderr.write(common_cired.encode_output_string("ERROR: "+file_path+": "+str(line_nr)+": "+in_serie[2]+": "+str(in_serie[1])+" difference data size and data header\n"))
                if in_serie[0] == 'dimension':
                    dimension_name = in_serie[2]
                    dimensions_indices[dimension_name] = {}
                    for dimension_item_index, dimension_item in enumerate(dimensions[dimension_name]):
                        dimensions_indices[dimension_name][dimension_item] = dimension_item_index
                in_serie = None
            else:
                in_serie[1] -= 1
                if in_serie[0] == 'dimension':
                    dimensions[in_serie[2]].append(input_data[0])
                    #sys.stderr.write("dim\n")
                else:
                    variable_name = in_serie[2]
                    if selected_variables is not None and variable_name not in selected_variables:
                        continue
                    #sys.stderr.write("data\n")
                    variable_dimensions_indices = in_serie[3]
                    selectors_nr = len(variable_dimensions_indices)
                    if len(input_data) < selectors_nr + 1:
                        sys.stderr.write(common_cired.encode_output_string("ERROR: "+file_path+": "+str(line_nr)+": unexpected data line size, expected "+str(selectors_nr + 1)+": "+delimiter.join(input_data)+"\n"))
                    else:
                        result_indices = []
                        indices_found = True
                        data_value = input_data[selectors_nr]
                        for selector_index, dimension_indices in enumerate(variable_dimensions_indices):
                            selector_item = input_data[selector_index]
                            if selector_item not in dimension_indices:
                                 sys.stderr.write(common_cired.encode_output_string("ERROR: "+file_path+": "+str(line_nr)+": "+selector_item+": not found in "+in_serie[4][selector_index]+"\n"))
                                 indices_found = False
                            else:
                                 result_indices.append(dimension_indices[selector_item])
                        if indices_found and data_value != '':
                            results[variable_name][tuple(result_indices)] = float(data_value)
        elif input_data[0] == dimensionDelimiterCode:
            #sys.stderr.write("dimensionDelimiterCode\n")
            if in_serie is not None:
                sys.stderr.write(common_cired.encode_output_string("WARNING: "+file_path+": "+str(line_nr)+": dimension delimiter within data?\n"))
                in_serie = None
            # second element is a count of the number of lines that
            # should be found
            header_in_serie = ['dimension', int(input_data[2]), input_data[1]]
            dimensions[input_data[1]] = []
        elif input_data[0] == dataDelimiterCode:
            if in_serie is not None:
                sys.stderr.write(common_cired.encode_output_string("WARNING: "+file_path+": "+str(line_nr)+": data delimiter within data?\n"))
                in_serie = None
            #print(input_data)
            variable_name = input_data[1]
            #sys.stderr.write("dataDelimiterCode: "+variable_name+"\n")
            variable_dimensions_indices = []
            variable_dimensions_names = input_data[2].split('*')
            variable_dimensions_numbers = [int(dimension_nr) for dimension_nr in input_data[3].split('*')]
            data_counter = 1
            variable_dimensions_dimension_numbers = []
            for dimension_idx, dimension in enumerate(variable_dimensions_names):
                if dimension not in dimensions_indices:
                    sys.stderr.write(common_cired.encode_output_string("WARNING: "+file_path+": "+str(line_nr)+": "+variable_name+": "+dimension+": dimension not found\n"))
                    return None
                else:
                    if variable_dimensions_numbers[dimension_idx] != len(dimensions_indices[dimension]):
                        sys.stderr.write(common_cired.encode_output_string("WARNING: "+file_path+": "+str(line_nr)+": "+variable_name+": "+dimension+": numbers not matching "+str(variable_dimensions_numbers[dimension_idx])+" != "+str(len(dimensions_indices[dimension]))+"\n"))
                    variable_dimensions_indices.append(dimensions_indices[dimension])
                    variable_dimensions_dimension_numbers.append(len(dimensions_indices[dimension]))
                    data_counter *= len(dimensions_indices[dimension])
            if selected_variables is None or variable_name in selected_variables:
                results[variable_name] = np.zeros(variable_dimensions_dimension_numbers, dtype=np.float)
            results_dimensions[variable_name] = variable_dimensions_names
            header_in_serie = ['data', data_counter, variable_name, variable_dimensions_indices, variable_dimensions_names]
        else:
            sys.stderr.write(common_cired.encode_output_string("WARNING: "+file_path+": "+str(line_nr)+": unknown case\n"))
    fd_dimensions_tables_file.close()
    return results, dimensions, results_dimensions

#----------------------------------------------------------------------------------
def ExtractEndowmentTables(endowments_list, AddedValue, T_AddedValue):
    
    results = {}
    for elt in endowments_list:
        if elt == 'UnskLab': # for gtap 7 and 8, we changed the name according to gtap 6, for code retro-compatibility
            elt_name = 'UnSkLab'
        elif elt == 'NatlRes': # for gtap 7 and 8, we changed the name according to gtap 6, for code retro-compatibility
            elt_name =  'NatRes'
        else:
            elt_name = elt
        results[elt_name] = AddedValue[endowments_list.index(elt),:,:]
        results['T_' + elt_name] = T_AddedValue[endowments_list.index(elt),:,:]

    return results

#----------------------------------------------------------------------------------
def SAM_Uses(SAM_dict):
    return SAM_dict['CI_imp'].sum(axis=1) + SAM_dict['CI_dom'].sum(axis=1) + SAM_dict['C_hsld_dom'] + SAM_dict['C_hsld_imp'] + SAM_dict['C_AP_dom'] + SAM_dict['C_AP_imp'] + SAM_dict['FBCF_dom'] + SAM_dict['FBCF_imp'] + SAM_dict['Exp'] + SAM_dict['Exp_trans']

#----------------------------------------------------------------------------------
def SAM_Resources(SAM_dict, Auto_TMX=None):
    if Auto_TMX is None:
        if 'Auto_TMX' in SAM_dict:
            Auto_TMX = SAM_dict['Auto_TMX']
        else:
            Auto_TMX = 0.
    return SAM_dict['CI_imp'].sum(axis=0) + SAM_dict['CI_dom'].sum(axis=0) + SAM_dict['AddedValue'].sum(axis=0) + SAM_dict['Imp'] + SAM_dict['Imp_trans'] + SAM_dict['T_prod'] + SAM_dict['T_AddedValue'].sum(axis=0) + SAM_dict['T_CI_dom'].sum(axis=0) + SAM_dict['T_CI_imp'].sum(axis=0) + SAM_dict['T_Hsld_dom'] + SAM_dict['T_Hsld_imp'] + SAM_dict['T_AP_dom'] + SAM_dict['T_AP_imp'] + SAM_dict['T_FBCF_imp'] + SAM_dict['T_FBCF_dom'] + SAM_dict['T_Exp'] + SAM_dict['T_Imp'] + Auto_TMX

#----------------------------------------------------------------------------------
# Exp_trans_sect should have 0 in places corresponding to other sectors than 
# transports
def CheckSAMBalance(SAM_dict, Auto_TMX=None, postfix=''):
    if Auto_TMX is None:
        if 'Auto_TMX' in SAM_dict:
            Auto_TMX = SAM_dict['Auto_TMX']
        else:
            Auto_TMX = 0.
    Uses = SAM_Uses(SAM_dict)
    Resources = SAM_Resources(SAM_dict, Auto_TMX=Auto_TMX) 

    Balance = Resources - Uses

    # Balances of imports and domestic production matrix
    Balance_Imp = SAM_dict['Imp'] + SAM_dict['Imp_trans'] + SAM_dict['T_Imp']  + SAM_dict['T_Hsld_imp'] + SAM_dict['T_AP_imp'] + SAM_dict['T_FBCF_imp'] - (SAM_dict['CI_imp'].sum(axis=1) + SAM_dict['C_hsld_imp'] + SAM_dict['C_AP_imp']+ SAM_dict['FBCF_imp'])
    # Note that Balance_Dom + Balance_Imp = Balance
    Balance_Dom = SAM_dict['CI_imp'].sum(axis=0) + SAM_dict['CI_dom'].sum(axis=0) + SAM_dict['AddedValue'].sum(axis=0) + SAM_dict['T_prod'] + SAM_dict['T_AddedValue'].sum(axis=0) + SAM_dict['T_CI_dom'].sum(axis=0) + SAM_dict['T_CI_imp'].sum(axis=0) + SAM_dict['T_Hsld_dom'] + SAM_dict['T_AP_dom'] + SAM_dict['T_FBCF_dom'] + SAM_dict['T_Exp'] + Auto_TMX - (SAM_dict['CI_dom'].sum(axis=1) + SAM_dict['C_hsld_dom'] + SAM_dict['C_AP_dom'] + SAM_dict['FBCF_dom'] + SAM_dict['Exp_trans'] + SAM_dict['Exp'])

    # check that production is equal to sum of resources (excluding
    # tax on production and without taxes on uses).
    Check_Prod = SAM_dict['CI_imp'].sum(axis=0) + SAM_dict['CI_dom'].sum(axis=0) + SAM_dict['AddedValue'].sum(axis=0) + SAM_dict['T_AddedValue'].sum(axis=0) + SAM_dict['T_CI_dom'].sum(axis=0) + SAM_dict['T_CI_imp'].sum(axis=0) - SAM_dict['Prod']

    print('CI_imp'+postfix+':'+round_result(SAM_dict['CI_imp'].sum()))
    print('CI_dom'+postfix+':'+round_result(SAM_dict['CI_dom'].sum()))
    print('C_hsld_dom'+postfix+':'+round_result(SAM_dict['C_hsld_dom'].sum()))
    print('C_hsld_imp'+postfix+':'+round_result(SAM_dict['C_hsld_imp'].sum()))
    print('C_AP_dom'+postfix+':'+round_result(SAM_dict['C_AP_dom'].sum()))
    print('C_AP_imp'+postfix+':'+round_result(SAM_dict['C_AP_imp'].sum()))
    print('FBCF_dom'+postfix+':'+round_result(SAM_dict['FBCF_dom'].sum()))
    print('FBCF_imp'+postfix+':'+round_result(SAM_dict['FBCF_imp'].sum()))
    print('Exp_trans'+postfix+':'+round_result(SAM_dict['Exp_trans'].sum()))
    print('Exp'+postfix+':'+round_result(SAM_dict['Exp'].sum()))
    
    print('\nAddedValue'+postfix+':'+round_result(SAM_dict['AddedValue'].sum()))
    print('Imp'+postfix+':'+round_result(SAM_dict['Imp'].sum()))
    print('Imp_trans'+postfix+':'+round_result(SAM_dict['Imp_trans'].sum()))
    print('T_prod'+postfix+':'+round_result(SAM_dict['T_prod'].sum()))
    print('T_AddedValue'+postfix+':'+round_result(SAM_dict['T_AddedValue'].sum()))
    print('T_CI_dom'+postfix+':'+round_result(SAM_dict['T_CI_dom'].sum()))
    print('T_CI_imp'+postfix+':'+round_result(SAM_dict['T_CI_imp'].sum()))
    print('T_CI_tot'+postfix+':'+round_result(SAM_dict['T_CI_imp'].sum() + SAM_dict['T_CI_dom'].sum()))
    print('T_Hsld_dom'+postfix+':'+round_result(SAM_dict['T_Hsld_dom'].sum()))
    print('T_Hsld_imp'+postfix+':'+round_result(SAM_dict['T_Hsld_imp'].sum()))
    print('T_FBCF_imp'+postfix+':'+round_result(SAM_dict['T_FBCF_imp'].sum()))
    print('T_FBCF_dom'+postfix+':'+round_result(SAM_dict['T_FBCF_dom'].sum()))
    print('T_AP_imp'+postfix+':'+round_result(SAM_dict['T_AP_imp'].sum()))
    print('T_AP_dom'+postfix+':'+round_result(SAM_dict['T_AP_dom'].sum()))
    print('T_Imp'+postfix+':'+round_result(SAM_dict['T_Imp'].sum()))
    print('T_Exp'+postfix+':'+round_result(SAM_dict['T_Exp'].sum()))
    
    print('\nResources'+postfix+':'+round_result(Resources.sum()))
    print('Uses'+postfix+':'+round_result(Uses.sum()))
    print('Balance'+postfix+':'+round_result(Balance.sum()))
    print('\nBalance_Imp'+postfix+':'+round_result(Balance_Imp.sum()))
    print('Balance_Dom'+postfix+':'+round_result(Balance_Dom.sum()))
    print('\nProd'+postfix+':'+round_result(SAM_dict['Prod'].sum()))
    print('Check_Prod'+postfix+':'+round_result(Check_Prod.sum()))

    print("\nThe error"+postfix+" between Resources and Uses in the all world is : "+round_result((Balance).sum()/Uses.sum())+' %')
    #import code; namespace = globals().copy(); namespace.update(locals()); code.interact(local=namespace); sys.exit()
    print("SAMs are balanced at the regional scales only (which means it isn't symetrical) with an error of (by region): \n"+str([round_result(region_value) for region_value in (Balance).sum(axis=0)/Uses.sum(axis=0)])+' %')
    return Resources, Uses, Balance, Balance_Imp, Balance_Dom
