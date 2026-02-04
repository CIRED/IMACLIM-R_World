#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


mkdir -p csv

for f in download/www.ilo.org/ilostat-files/WEB_bulk_download/indicator/*.gz; do gzip -d -k $f ; done
for f in download/www.ilo.org/ilostat-files/WEB_bulk_download/indicator/*.csv; do mv $f csv/; done
