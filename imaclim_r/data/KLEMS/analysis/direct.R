# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Liesbeth Defosse
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================

sep=.Platform$file.sep

KLEMS     <- normalizePath("..")
DATA      <- paste(KLEMS    , "aggregation" , "intermediate" , sep=sep)
DATAD     <- paste(KLEMS    , "aggregation" , "input"        , sep=sep)
ANALYSIS  <- paste(KLEMS    , "analysis"    ,            sep=sep)
SUMMARIZE <- paste(ANALYSIS , "description" ,            sep=sep)
PLOT      <- paste(ANALYSIS , "plots"       ,            sep=sep)
REGRESS   <- paste(ANALYSIS , "regression"  ,            sep=sep)
PCA       <- paste(ANALYSIS , "pca"         ,            sep=sep)
CA        <- paste(ANALYSIS , "ca"          ,            sep=sep)
MFA       <- paste(ANALYSIS , "mfa"          ,           sep=sep)
