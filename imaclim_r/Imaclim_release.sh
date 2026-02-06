# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


releasename=trunk
revision_data_Imaclim=33246
revsionNLU=27182

svn checkout file:///data/repositories/svnroot/Imaclim/ImaclimRWorld/trunk_v2.0/ $releasename

(cd $releasename &&

# Import and unzip datas
#cp /data/public_results/ImaclimR/input_data/input_data-Imaclim2.0-r${revision_data_Imaclim}_NLU-r${revsionNLU}.zip .
#unzip input_data-Imaclim-r${revisionImaclim}_NLU-r${revsionNLU}.zip
#rm input_data-Imaclim-r${revisionImaclim}_NLU-r${revsionNLU}.zip
unzip -o /data/public_results/ImaclimR/input_data/input_data-Imaclim2.0-r${revision_data_Imaclim}.zip
#(cd externals/land-use/ && unzip input_data-dumas-*.zip)
#rm externals/land-use/input_data-dumas-*.zip

# compile C librairies for Imaclim
sh l compile

# Import Oscar model
#wget https://github.com/tgasser/OSCAR/archive/v2.2.2.tar.gz 
#mv v2.2.2.tar.gz externals/
#tar -zxvf externals/v2.2.2.tar.gz
#(cd externals/ && tar -zxvf v2.2.2.tar.gz && mv OSCAR-2.2.2 OSCAR)
#rm externals/v2.2.2.tar.gz

# Patch external models
#patch -p0 -i patch_nlu_Imaclim.patch
#(cd externals/ && patch -p0 -i ../patch_oscar_Imaclim.patch)
)
