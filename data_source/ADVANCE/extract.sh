# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Thibault Briera
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


#extract .zip file

directory=download

mkdir extracted 

(cd extracted 
cp ../$directory/ScienceDirect_files_16Apr2021_09-53-31.113.zip ScienceDirect_files_16Apr2021_09-53-31.113.zip
unzip ScienceDirect_files_16Apr2021_09-53-31.113.zip
rm ScienceDirect_files_16Apr2021_09-53-31.113.zip
)