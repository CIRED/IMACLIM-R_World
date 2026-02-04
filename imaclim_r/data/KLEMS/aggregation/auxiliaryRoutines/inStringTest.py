# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

import re


A=['E','Gas_gdt','Elec','Inddemat_wtr']

B=['Gas']

print B[0]

regex = re.compile(B[0])


matches = [string for string in A if re.match(regex, string)]

print matches
print A.index(matches[0])
