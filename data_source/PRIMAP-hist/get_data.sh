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
wget -e robots=off -r --no-parent -nd -A pdf -A csv 'https://zenodo.org/record/7585420#use-of-the-dataset-and-full-description/'
wget https://essd.copernicus.org/preprints/essd-2016-12/essd-2016-12.pdf
)

