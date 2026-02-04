#! /usr/bin/env python
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Patrice Dumas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


import sys
import argparse
import common_cired
import common_for_faostat

# %run ./compute_sectoral_SAM_coefficients.py tmpdir_agri/normalized_value_tables/other_tables.csv tmpdir_agri/normalized_value_tables/intermediate_consumptions.csv

parser = argparse.ArgumentParser('Compute SAM coefficients per unit of production')

parser.add_argument('--output-ratio-elements-file')
parser.add_argument('production_input_file')
parser.add_argument('input_file')

args = parser.parse_args()

delimiter = '|'

balance_element_header = common_for_faostat.balance_element_header
unit_header = common_for_faostat.unit_header

production_input = common_for_faostat.read_FAOSTAT_file(args.production_input_file, delimiter=delimiter)
if len(production_input[0]) != 1:
    sys.stderr.write(common_cired.encode_output_string("FATAL: more than one element for production: "+delimiter.join(sorted(production_input[0]))+"\n"))
    sys.exit(1)
for sectoral_production_element_name in production_input[0]:
    break
production_data = production_input[0][sectoral_production_element_name]
production_units = production_input[1][sectoral_production_element_name]

fd_in = open(args.input_file)
csv_reader = common_cired.UnicodeCsvReader(fd_in, delimiter=delimiter)
(input_header, line_nr) = common_cired.read_header_iterable(csv_reader)

input_location_header, input_item_header, input_year_header, input_sector_header = common_for_faostat.guess_headers(input_header)

idx_value = input_header.index(common_for_faostat.value_header)
idx_element = input_header.index(balance_element_header)
idx_unit = input_header.index(unit_header)

print(common_cired.encode_output_string(delimiter.join(input_header)))

ratios_elements = {}

while 1:
    (line_nr, converted_data, row) = common_cired.read_data_line(csv_reader, input_header, line_nr=line_nr, convert_numbers=False)
    if converted_data is not None:
        year = int(row[input_year_header])
        item_name = row[input_item_header]
        if input_sector_header is not None:
            sector = row[input_sector_header]
        else:
            sector = item_name
        location = row[input_location_header]
        production = production_data[location][year][sector]
        result_value = common_for_faostat.units_conversion_factor(row[unit_header], production_units[sector]) * float(converted_data[idx_value]) / production
        result_line = list(converted_data)
        result_line[idx_value] = common_for_faostat.round_result_output(result_value)
        result_line[idx_unit] = ''
        result_line[idx_element] = row[balance_element_header]+' per ' +sectoral_production_element_name
        ratios_elements[result_line[idx_element]] = [row[balance_element_header], sectoral_production_element_name]
        print(common_cired.encode_output_string(delimiter.join(result_line)))
    else:
        break

if args.output_ratio_elements_file is not None:
    common_for_faostat.print_ratio_elements(args.output_ratio_elements_file, ratios_elements, delimiter=delimiter)
