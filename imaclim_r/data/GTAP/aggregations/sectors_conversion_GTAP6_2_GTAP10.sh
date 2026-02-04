#!/bin/bash
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


sed -i -e 's/|omn/|oxt/g;
s/|isr/|ins/g;
s/|crp/|chm|bph|rpp/g;
s/|ele/|ele|eeq/g;
s/|osg/|osg|edu|hht/g;
s/|otp/|otp|whs/g;
s/|obs/|obs|rsa/g;
s/|trd/|trd|afs/g' $1
