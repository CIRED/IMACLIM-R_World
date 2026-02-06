#! /bin/sh
# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Rémi Prudhomme, Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


set -e

mkdir -p download

# download full series in single files, and not separated files for year / production / consumption sectors
# only download selected files of interest. The fule database is too big
(
cd download

wget -e robots=off -r --no-parent -nd -A zip --accept "v60_*" --accept "v6.0_*\.zip" -R "*nc\.zip" -R "*txt\.zip" -R "*IPCC\.zip" -R "*0.1x0.1*\.zip" -R "edgar_*" --reject-regex ".*[0-9]{4}_.[A-Za-z_|N20]*\.zip" 'http://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/EDGAR/datasets/v60_GHG/'
wget -e robots=off -r --no-parent -nd -A zip --accept "v42*timeseries*\.zip" --accept "v4.2*timeseries*\.zip" -R "*IPCC*\.zip" -R "*0.1x0.1*\.zip" -R "edgar_*" -R "*nc*\.zip" -R "*TOT*\.zip" 'http://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/EDGAR/datasets/v42/'
wget -e robots=off -r -l 2 -nd -N --no-parent -A zip 'http://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/EDGAR/datasets/v50_AP/'

#wget -N -r -np http://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/EDGAR/datasets/v60_GHG/ 
#wget http://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/EDGAR/datasets/v60_GHG/N2O/v60_GHG_N2O_1970_2018.zip
#wget http://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/EDGAR/datasets/v60_GHG/CH4/v60_GHG_CH4_1970_2018.zip
#wget http://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/EDGAR/datasets/v60_GHG/CO2_org_short-cycle_C/v60_GHG_CO2_org_short-cycle_C_1970_2018.zip
#wget http://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/EDGAR/datasets/v60_GHG/CO2_excl_short-cycle_org_C/v60_GHG_CO2_excl_short-cycle_org_C_1970_2018.zip
)

# Edgar to GTAP documentation
wget https://www.gtap.agecon.purdue.edu/resources/download/10041.pdf

# download IPCC GWP csv
wget https://github.com/openclimatedata/globalwarmingpotentials/archive/refs/heads/main.zip
unzip main.zip
rm main.zip

# download NH emissions for 2010
(cd download
wget https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/EDGAR/datasets/v81_FT2022_AP/NH3/TOTALS/emi_nc/v8.1_FT2022_AP_NH3_2010_TOTALS_emi_nc.zip

wget https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/EDGAR/datasets/v81_FT2022_AP/NOx/TOTALS/emi_nc/v8.1_FT2022_AP_NOx_2010_TOTALS_emi_nc.zip
)
