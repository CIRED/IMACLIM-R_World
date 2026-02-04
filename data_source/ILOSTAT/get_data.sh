#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Patrice Dumas
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


mkdir -p download

cd download

(
wget -N https://www.ilo.org/ilostat-files/Documents/ILOSTAT_BulkDownload_Guidelines.pdf
#wget -N https://www.ilo.org/ilostat-files/Documents/description_ECO_EN.pdf
#wget -N https://www.ilo.org/ilostat-files/Documents/description_HRS_EN.pdf
wget -N http://www.ilo.ch/wcmsp5/groups/public/---dgreports/---stat/documents/normativeinstrument/wcms_087481.pdf
#https://www.ilo.org/ilostat-files/WEB_bulk_download/html/bulk_modelled_estimates.html
#wget -r -N -l 3 --include '/ilostat-files/WEB_bulk_download' 'https://www.ilo.org/ilostat/faces/oracle/webcenter/portalapp/pagehierarchy/Page30.jspx?_afrLoop=3726269753106533&_afrWindowMode=0&_afrWindowId=9xprb31en_1#!%40%40%3F_afrWindowId%3D9xprb31en_1%26_afrLoop%3D3726269753106533%26_afrWindowMode%3D0%26_adf.ctrl-state%3D9xprb31en_77'
rm -f www.ilo.org/ilostat-files/WEB_bulk_download/html/bulk_main.html
wget -r -N -A html,gz,csv -e robots=off --limit-rate=300k --random-wait https://www.ilo.org/ilostat-files/WEB_bulk_download/html/bulk_main.html

# CITI rev-4 classification - p51
wget -N https://unstats.un.org/unsd/publication/seriesm/seriesm_4rev4f.pdf
)

