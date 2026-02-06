// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

EI = [];
nonEnergSectors = (nbsecteurenergie+1):sec;
energSectors    = 1:nbsecteurenergie;
EI_ref=zeros(reg,sec);
for region=1:reg
    for sect=nonEnergSectors
        EI_ref(region,sect)=sum(CI(energSectors,sect,region))./p(region,sect);
        EI_ref = EI_ref + (EI_ref== 0) .* ones(EI_ref);
    end
end

if ind_NLU_EI == 1 // coupling with the nexus land-use, only the disaggregated agriFoodProcess sector
    EI_ref(:,agri)=sum(alphaIC_agriFoodProcess(energSectors,:)',"c")./p_agriFoodProcess;
end

leaderEvolution	= cff_lea*ones(1,sec);// = EI_leader(t+1)/EI_leader(t) must be =<1

Y = cff_y * ones(reg,sec); //0.01 * ones(reg,sec);// a bout de X années, il reste EI(leader,t0+X)/finalLevel-EI(suiveur,t0+X)=Y*(EI(leader,t0)/finalLevel-EI(suiveur,t0))
// 3. Definition of parameters values
// 2.1. Asymptotic level of catch up
// finalLevel 	= 0.8 * finalLevel; // Asymptote = EIleader(t_inf) / level must be <1 but not too low
finalLevel      = fin_lev*ones(1,sec);
testCoherence = (ones(reg,sec)==ones(reg,sec));
EI_lead_ref        = zeros(sec,1);
EIleadt0plusX   = zeros(sec,1);
leader		= zeros(sec,1);
// finalLevel	= ones(reg,sec);
// 2. Selection of the leader for each region and sector
//Country leaders definition for each sector
for sect = nonEnergSectors
    [unused,leader(sect)]=min(EI_ref([1:4],sect));
    EI_lead_ref(sect)       = EI_ref(leader(sect),sect,1);
    EIleadt0plusX(sect)  = EI_lead_ref(sect)*leaderEvolution(sect).^XRef(leader(sect),sect);
    testCoherence(:,sect)   = EI_lead_ref(sect) ./ finalLevel(:,sect) < EI_ref(:,sect); // Check that asymptotic energy intensity value is indeed lower than the reference one. 
    testCoherence(leader(sect),sect) = %t; 
end
if ~and(testCoherence) & verbose >=1
    warning( 'CIener: L''asymptote est superieure a la valeur initiale');
end

// Hypothesis : In case of coupling with the Nexus land-use (ind_NLU>0), of pIndEnerRef of the agriFoodProcess sector is supposed to be the same as the aggregated agricultural sector (the idea here is that recalculating pArmCI and pArmCIref for the disaggregated agriFoodProcess sector is too fastidious for the desired indicator)
pIndEnerRef = compPIndEner(pArmCI,pArmCIref,CI,CIref);

EEI_newVintage   = zeros(reg,sec,TimeHorizon+1);
AEEI_allVintages = zeros(reg,sec,TimeHorizon+1);
AEEI_newVintage  = zeros(reg,sec,TimeHorizon+1);

// Calibration of the coefficient used to boost energy efficiency improvement in the service sector
if ~isdef('EI_comp_boost')
    EI_comp_boost = 2; // Default value
end
