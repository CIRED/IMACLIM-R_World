#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


set -e

wget -N https://pages.stern.nyu.edu/~adamodar/pc/archives/ctryprem19.xls --no-check-certificate

mkdir -p extracted/
(cd extracted/ && xls_to_csv_files.pl ../ctryprem19.xls)

