// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Adrien Vogt-Schilb, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

if ~isdef("SAVEDIR")
    exec (".."+filesep()+"preamble.sce");
    SAVEDIR = uigetdir(OUTPUT,"SAVEDIR please") 
end

/// Keeping some .tsv saved variables because they are sometimes used in others runs

combi = run_name2combi(SAVEDIR);
[ind_climat,ind_EEI,ind_CCS,ind_NUC,ind_ENR,ind_bioEnergy]=combi2indices(combi);

wasdone = isfile(SAVEDIR+"\save\IamDoneFolks.dat")


//////////////////////////////////////////// carbon tax
nbMKT = get_nbMKT(combi);

carbonTax = zeros(nbMKT,TimeHorizon+1);
if ind_climat
    carbonTax = sg_get_var("taxMKT");
end
mksav 'carbonTax'

/////////CO2 emissions


//CO2 emi per region
for k=1:reg
    ECO2reg(k,:) = sum(sg_get_var("E_reg_use",k),"r");
end

//CO2 emi per use
for u=1:nb_use
    ECO2W_use(u,:) = sum(sg_get_var("E_reg_use",:,u),"r");
end

emi_usage = [usenames, ECO2W_use];
mkcsv emi_usage

/////////Macro

GDP     = sgv("GDP");
GDP_MER_nominal = sgv("GDP_MER_nominal");
GDP_MER_real    = sgv("GDP_MER_real");
GDP_PPP_constant   = sgv("GDP_PPP_constant");


execstr("outputs_"+ETUDE+"=csvRead("""+SAVEDIR+"outputs_"+ETUDE+fit_combi(combi)+".csv"",""|"",[],[],[],""/\/\//"");");
yearlySmoothOutputs= customSmooth(evstr("outputs_"+ETUDE));
yearlyOutputs= evstr("outputs_"+ETUDE);

if do_smooth_outputs==%t
    execstr("sel_outputs_"+ETUDEOUTPUT+" = yearlySmoothOutputs(:, year_to_select)");
else
    execstr("sel_outputs_"+ETUDEOUTPUT+" = yearlyOutputs(1:(13*nbLines), year_to_select)");
end
mkcsv("sel_outputs_"+ETUDEOUTPUT);
mkcsv("sel_outputs_"+ETUDEOUTPUT,OUTPUT);


