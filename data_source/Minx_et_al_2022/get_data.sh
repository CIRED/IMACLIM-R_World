#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


/data/software/anaconda3/envs/MostUpdated/bin/zenodo_get -o download/ -d https://doi.org/10.5281/zenodo.6483002
/data/software/anaconda3/envs/MostUpdated/bin/zenodo_get -c https://doi.org/10.5281/zenodo.6483002 > zenodo_ref.bib

wget https://essd.copernicus.org/articles/13/5213/2021/essd-13-5213-2021.pdf
wget https://essd.copernicus.org/articles/13/5213/2021/essd-13-5213-2021.bib
