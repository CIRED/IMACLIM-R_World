#!/bin/bash
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

pathToImg=/data/results/klems/docImg/imgWD
usr=bibas

scp -r $usr@poseidon.centre-cired.fr:/$pathToImg/. imgWDtest/
