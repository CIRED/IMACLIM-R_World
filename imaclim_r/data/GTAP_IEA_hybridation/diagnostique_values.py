# =============================================
# Contact: <imaclim.r.world@gmail.com>
# Licence: AGPL-3.0
# Authors:
#     Florian Leblanc
#     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
# =============================================


version="origin" #hybridized
version="hybridized"

if version == "origin":
    version2output = input_data_sam.copy()
else:
    version2output = output_data_sam_hybrid.copy()

reg = 'usa'
sec = 'gas_gdt'

"""
sec = 'wtp'
reg= 'jpn' 
reg = 'aus'
reg= 'jpn' 
"""
reg_Im= 'CIS' 
sec='coa'

reg_Im= 'EUR' 
sec_Im='Agriculture'

ind_reg = input_dimensions_values_sam['REG'].index(reg)
ind_sec = input_dimensions_values_sam['SEC'].index(sec)
# alt ind_mer JAN

ind_reg = [input_dimensions_values_sam['REG'].index(reg) for reg in dict_Im_region[reg_Im]]
ind_sec = [input_dimensions_values_sam['SEC'].index(sec) for sec in dict_Im_sector[sec_Im]]

# Uses:
for var in ['CI_imp', 'CI_dom', 'C_hsld_dom', 'C_hsld_imp', 'C_AP_dom', 'C_AP_imp', 'FBCF_dom', 'FBCF_imp', 'Exp', 'Exp_trans']:
    if len(version2output[var].shape)==3:
        print(var, reg_Im, sec_Im, version2output[var].sum(axis=1)[ind_sec,:][:, ind_reg].sum())
    else:
        print(var, reg_Im, sec_Im, version2output[var][ind_sec,:][:, ind_reg].sum())

# resources:
# Uses:
for var in ['CI_imp', 'CI_dom', 'AddedValue', 'Imp', 'Imp_trans', 'T_prod', 'T_AddedValue', 'T_CI_dom', 'T_CI_imp', 'T_Hsld_dom', 'T_Hsld_imp', 'T_AP_dom', 'T_AP_imp', 'T_FBCF_imp', 'T_FBCF_dom', 'T_Exp', 'T_Imp', 'Auto_TMX']:
    if len(version2output[var].shape)==3:
        print(var, reg_Im, sec_Im, version2output[var].sum(axis=0)[ind_sec,:][:, ind_reg].sum())
    else:
        print(var, reg_Im, sec_Im, version2output[var][ind_sec,:][:, ind_reg].sum())


#off_mgr_pros_Im(1,4), clerks_Im(1,4), service_shop_Im(1,4), ag_othlowsk_Im(1,4), tech_aspros_Im(1,4)
#output_data_sam_hybrid['AddedValue'][:,21,0]
