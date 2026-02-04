#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


mkdir -p download

(cd download &&

(
wget -N http://www.cepii.fr/DATA_DOWNLOAD/baseline/v2.0/EconMap_2.4_reference.xls
wget -N http://www.cepii.fr/DATA_DOWNLOAD/baseline/v2.0/EconMap_2.4.xls
wget -N http://www.cepii.fr/DATA_DOWNLOAD/baseline/v2.0/EconMap_2.4_csv.rar
unrar x EconMap_2.4_csv.rar
)
)


mkdir -p documentation
(cd documentation &&
(
wget -N http://www.cepii.fr/PDF_PUB/wp/2012/wp2012-03.pdf
wget -N http://www.cepii.fr/PDF_PUB/wp_nts/2012/wp2012-03.pdf -O wp2012-03_nts.pdf
wget -N https://onlinelibrary-wiley-com.inshs.bib.cnrs.fr/doi/epdf/10.1111/ecot.12023
wget -N http://www.cepii.fr/DATA_DOWNLOAD/mage/SSP_scenarios_2.4.pdf
)
)
