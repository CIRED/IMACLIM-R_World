// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thibault Briera, Adrien Vogt-Schilb, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function [costBIGCC_withTax,costBIGCCS_withTax,costBIGCC_noTax,costBIGCCS_noTax,breakEvenTax,Qbiomass_exaJ] = ..
    computeBiomassCost(supplyCurve,prodBiomass,rho_elec_nexus,emissions,emissionsCCS,croyance_taxe,taxCO2_CI_biomass,exogenousMaxQ,isReal,priceCap)
    // prodBiomass is a matrix (reg,nTechnoBiomass) in MWh
    // rho_elec_nexus is a matrix (reg,nTechnoBiomass)
    // costBIGCC is in M$/Mtep

    Qbiomass_tep = prodBiomass ./ rho_elec_nexus / tep2MWh; // size = (reg,nTechnoBiomass)
    Qbiomass_GJ  = Qbiomass_tep / gj2tep;
    Qbiomass_exaJ = Qbiomass_GJ  / exa2giga; 

    totalQbiomass = sum(Qbiomass_GJ);

    if totalQbiomass > exogenousMaxQ
        resourcePrice = 100000;
    elseif totalQbiomass > supplyCurve($,2)
        resourcePrice = 100000;
    elseif totalQbiomass <= supplyCurve(1,2)
        resourcePrice = supplyCurve(1,1);
    else
        resourcePrice = interp1(supplyCurve(:,2),supplyCurve(:,1),totalQbiomass,"linear");
    end

    if isReal
        resourcePrice = min(resourcePrice,priceCap);
    end

    costBIGCC_noTax     =squeeze(repmat(resourcePrice /(gj2tep/1e6)*dollar2MDollar, reg, 1,expectations.duration));
    costBIGCCS_noTax   = squeeze(repmat(resourcePrice /(gj2tep/1e6)*dollar2MDollar, reg, 1,expectations.duration));
    
    costBIGCC_withTax  =  costBIGCC_noTax + shareBiomassTaxElec * ( emissions   .* matrix(taxCO2_CI_biomass,reg,expectations.duration));
    costBIGCCS_withTax = costBIGCCS_noTax+ shareBiomassTaxElec * ( emissionsCCS   .* matrix(taxCO2_CI_biomass,reg,expectations.duration));

    // breakEvenTax = fsolve(matrix(taxCO2_CI_biomass(:,:,:,1),reg,1)*1e6,cfuel);
    // breakEvenTax = - (resourcePrice /(gj2tep/1e6)) ./ emissionsCCS;
    breakEvenTax =0;
endfunction
    

function [costBIGCC_withTax,costBIGCCS_withTax,costBIGCC_noTax,costBIGCCS_noTax,breakEvenTax,Qbiomass_exaJ] = ..
    computeBiomassCost_NLU(supplyCurve,prodBiomass,rho_elec_nexus,emissions,emissionsCCS,croyance_taxe,taxCO2_CI_biomass,exogenousMaxQ,isReal,priceCap)
    // prodBiomass is a matrix (reg,nTechnoBiomass) in MWh
    // rho_elec_nexus is a matrix (reg,nTechnoBiomass)
    // costBIGCC is in M$/Mtep

    Qbiomass_tep = prodBiomass ./ rho_elec_nexus / tep2MWh; // size = (reg,nTechnoBiomass)
    Qbiomass_GJ  = Qbiomass_tep / gj2tep;
    Qbiomass_exaJ = Qbiomass_GJ  / exa2giga;

    totalQbiomass = sum(Qbiomass_GJ,"c");

    resourcePrice = bioelec_costs_NLU * gj2tep;
    costBIGCC_noTax    = ( bioelec_costs_NLU*1e6)*dollar2MDollar ;
    costBIGCCS_noTax   = costBIGCC_noTax;
    costBIGCC_withTax  =  costBIGCC_noTax + shareBiomassTaxElec * ( emissions    .* croyance_taxe .* matrix(taxCO2_CI_biomass,reg,1));
    costBIGCCS_withTax = costBIGCCS_noTax + shareBiomassTaxElec * ( emissionsCCS .* croyance_taxe .* matrix(taxCO2_CI_biomass,reg,1));
    breakEvenTax = fsolve(matrix(taxCO2_CI_biomass,reg,1)*1e6,cfuel);
    // breakEvenTax = - (resourcePrice /(gj2tep/1e6)) ./ emissionsCCS;

endfunction


function cfuelOut = cfuel(taxCO2CIbiomass)
    cfuelOut = resourcePrice /(gj2tep/1e6)+ emissionsCCS .* taxCO2CIbiomass + elecBiomassInitial.processCost * tep2kwh;
    // 0 = resourcePrice /(gj2tep/1e6)+ emissionsCCS .* taxCO2CIbiomass;
    // emissionsCCS .* taxCO2CIbiomass = - resourcePrice /(gj2tep/1e6);
    // taxCO2CIbiomass = - (resourcePrice /(gj2tep/1e6)) ./ emissionsCCS;
endfunction
