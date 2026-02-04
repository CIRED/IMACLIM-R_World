#!/bin/bash
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Ruben Bibas, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


hosts="arklems.files.wordpress.com,arklems.org"

aspire="wget -r -k -E -np -N -U mozilla --random-wait -H -D$hosts"
addFlags="-e robots=off"

# -H  pour spanner across les hosts
# -l 3  pour le depth
# -N ne retélécharge pas un fichier déjà téléchargé
# -I pour type fiels?

mkdir -p log
mkdir -p raw

$aspire http://www.euklems.net/ -P raw/euklems -o log/euklems.log &
$aspire http://www.rieti.go.jp/en/database/CIP2015/index.html -P raw/china -o log/china.log &
$aspire http://www.worldklems.net/data.htm -P raw/worldklems -o log/worldklems.log &
$aspire http://www.asiaklems.net/data/archive.asp -P raw/asiaklems -o log/asiaklems.log &
$aspire $addFlags https://arklemsenglish.wordpress.com/database/ -P raw/argentinaklems -o log/argentinaklems.log &

wget http://www.euklems.net/TCB/2018/Metholology_EUKLEMS_2017_revised.pdf .
