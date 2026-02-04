#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Nicolas Graves
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


mkdir -p download


(
cd download

#This data  comes with a combination of an incomplete primary data paper, 
#and a model paper completing holes. 
#We extract data from the model, primary data is commented below. 

#pdf model paper
wget --output-document=deetman_buildings_2020.pdf https://dspace.library.uu.nl/bitstream/handle/1874/394620/1_s2.0_S0959652619335280_main.pdf

#supplementary material of the paper, model outputs
wget -N https://ars.els-cdn.com/content/image/1-s2.0-S0959652619335280-mmc2.xlsx

#incomplete primary data paper
#not available publicly 
#https://doi.org/10.1016/j.jclepro.2019.119146

#primary incomplete data
#wget -N https://ars.els-cdn.com/content/image/1-s2.0-S0959652619340168-mmc2.xlsx
)
