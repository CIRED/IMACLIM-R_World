# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Thibault Briera
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

OECD_DAC_data=$OECD_DAC/download
R -f "./main_oecd_process_full.R" --args $OECD_DAC