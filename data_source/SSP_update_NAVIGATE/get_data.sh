#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


set -e

mkdir -p download
(
cd download
wget https://www.navigate-h2020.eu/wp-content/uploads/2022/11/scenarios_for_navigate_63.xlsx
wget https://www.navigate-h2020.eu/wp-content/uploads/2022/02/navigate_gdp_info2.pdf
)
