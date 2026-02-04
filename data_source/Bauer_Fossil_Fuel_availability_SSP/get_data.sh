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

#data paper
wget -N --output-document=Bauer_FF_data_availability.pdf http://pure.iiasa.ac.at/id/eprint/13980/1/Data%20on%20fossil%20fuel%20availability%20for%20Shared%20Socioeconomic%20Pathways.pdf
#companion methodology paper
#https://doi.org/10.1016/j.energy.2016.05.088
#not publicly available, downloaded in manual/ under name bauer_assessing_FF_availability_methodology.pdf

#data
#SSP1 coal
wget -N --output-document=coal_ssp1.xlsx https://ars.els-cdn.com/content/image/1-s2.0-S235234091630703X-mmc2.xlsx

#SSP2 coal
wget -N --output-document=coal_ssp2.xlsx https://ars.els-cdn.com/content/image/1-s2.0-S235234091630703X-mmc3.xlsx

#SSP3 coal
wget -N --output-document=coal_ssp3.xlsx https://ars.els-cdn.com/content/image/1-s2.0-S235234091630703X-mmc4.xlsx

#SSP4 coal
wget -N --output-document=coal_ssp4.xlsx https://ars.els-cdn.com/content/image/1-s2.0-S235234091630703X-mmc5.xlsx

#SSP5 coal 
wget -N --output-document=coal_ssp5.xlsx https://ars.els-cdn.com/content/image/1-s2.0-S235234091630703X-mmc6.xlsx

#SSP1 oil&gas
wget -N --output-document=oil_gas_ssp1.xlsx https://ars.els-cdn.com/content/image/1-s2.0-S235234091630703X-mmc7.xlsx

#SSP2 oil&gas
wget -N --output-document=oil_gas_ssp2.xlsx https://ars.els-cdn.com/content/image/1-s2.0-S235234091630703X-mmc8.xlsx

#SSP3 oil&gas
wget -N --output-document=oil_gas_ssp3.xlsx https://ars.els-cdn.com/content/image/1-s2.0-S235234091630703X-mmc9.xlsx

#SSP4 oil&gas
wget -N --output-document=oil_gas_ssp4.xlsx https://ars.els-cdn.com/content/image/1-s2.0-S235234091630703X-mmc10.xlsx

#SSP5 oil&gas
wget -N --output-document=oil_gas_ssp5.xlsx https://ars.els-cdn.com/content/image/1-s2.0-S235234091630703X-mmc11.xlsx

)
