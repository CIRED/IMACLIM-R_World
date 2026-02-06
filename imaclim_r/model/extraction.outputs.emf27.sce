// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Nicolas Graves, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//conversion factors
usd2001_2005=1/0.907;
Mtoe_EJ=0.041868;
nbLines = 355;

//annees 2001-2005-2010-2020 etc
if current_time_im==1
    outputs_temp=zeros(nbLines*(reg+1),TimeHorizon);
end

for k=1:reg
    exec (MODEL+"outputs.region."+ETUDE+".sce");
end
// World values
for lineEMF = [1:133 144 157:168 177:225 231:246 249:303 322:340 344:355]
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(outputs_temp(nbLines*[0:11] + lineEMF,current_time_im)); 
end
// Price|Carbon 
lineEMF = 134;
weightLine = 113;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(outputs_temp(nbLines*[0:11] + weightLine,current_time_im) .* outputs_temp(nbLines*[0:11] + lineEMF,current_time_im))./sum(outputs_temp(nbLines*[0:11] + weightLine,current_time_im));
// Price|Crude Oil|Producer Price
lineEMF = 135;
weightLine = 11;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(outputs_temp(nbLines*[0:11] + weightLine,current_time_im) .* outputs_temp(nbLines*[0:11] + lineEMF,current_time_im))./sum(outputs_temp(nbLines*[0:11] + weightLine,current_time_im));
// Price|Natural Gas|Producer Price
lineEMF = 136;
weightLine = 14;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(outputs_temp(nbLines*[0:11] + weightLine,current_time_im) .* outputs_temp(nbLines*[0:11] + lineEMF,current_time_im))./sum(outputs_temp(nbLines*[0:11] + weightLine,current_time_im));
// Price|Coal|Producer Price
lineEMF = 137;
weightLine = 8;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(outputs_temp(nbLines*[0:11] + weightLine,current_time_im) .* outputs_temp(nbLines*[0:11] + lineEMF,current_time_im))./sum(outputs_temp(nbLines*[0:11] + weightLine,current_time_im));
// Price|Light Fuel Oil|Secondary Level
lineEMF = 138;
weightLine = 67;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(outputs_temp(nbLines*[0:11] + weightLine,current_time_im) .* outputs_temp(nbLines*[0:11] + lineEMF,current_time_im))./sum(outputs_temp(nbLines*[0:11] + weightLine,current_time_im));
// Price|Natural Gas|Secondary Level
lineEMF = 139;
weightLine = 69;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(outputs_temp(nbLines*[0:11] + weightLine,current_time_im) .* outputs_temp(nbLines*[0:11] + lineEMF,current_time_im))./sum(outputs_temp(nbLines*[0:11] + weightLine,current_time_im));
// Price|Coal|Secondary Level
lineEMF = 140;
weightLine = 75;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(outputs_temp(nbLines*[0:11] + weightLine,current_time_im) .* outputs_temp(nbLines*[0:11] + lineEMF,current_time_im))./sum(outputs_temp(nbLines*[0:11] + weightLine,current_time_im));
// Price|Secondary energy|Solids|Biomass
line_BIGCCS = 43;
line_BIGCC  = 44;
line_biofuels = 59;
prodBiomassSolidReg = ..
    + outputs_temp(nbLines*[0:11] + line_BIGCCS,current_time_im) ./ rho_elec_nexus(:,indice_BIS) ..
+ outputs_temp(nbLines*[0:11] + line_BIGCC,current_time_im) ./ rho_elec_nexus(:,indice_BIG);
lineEMF = 141;
indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
nanIndex = ~isnan(indexee);
if sum(prodBiomassSolidReg)~= 0
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(prodBiomassSolidReg(nanIndex) .* indexee(nanIndex)) ./ sum(prodBiomassSolidReg(nanIndex));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
// Price|Biomass|Primary Level
prodBiomassReg = outputs_temp(nbLines*[0:11]   + line_biofuels,current_time_im) ..
    + outputs_temp(nbLines*[0:11] + line_BIGCCS,current_time_im) ./ rho_elec_nexus(:,indice_BIS) ..
+ outputs_temp(nbLines*[0:11] + line_BIGCC,current_time_im) ./ rho_elec_nexus(:,indice_BIG);
lineEMF = 142;
indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
nanIndex = ~isnan(indexee);
if sum(prodBiomassReg)~= 0
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(prodBiomassReg(nanIndex) .* indexee(nanIndex)) ./ sum(prodBiomassReg(nanIndex));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
// Price|Electricity|Secondary Level
lineEMF = 143;
weightLine = 32;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(outputs_temp(nbLines*[0:11] + weightLine,current_time_im) .* outputs_temp(nbLines*[0:11] + lineEMF,current_time_im))./sum(outputs_temp(nbLines*[0:11] + weightLine,current_time_im));

//LCOE|Electricity|Coal|w CCS   US$2005/MWh
lineEMF = 145;
if sum(prod_elec_techno(:,technoCoalWCCS)) ~= 0
    indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
    nanIndex = ~isnan(indexee);
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(sum(prod_elec_techno(nanIndex,technoCoalWCCS),2) .* indexee(nanIndex))./sum(prod_elec_techno(nanIndex,technoCoalWCCS));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
//LCOE|Electricity|Coal|w/o CCS   US$2005/MWh
lineEMF = 146;
if sum(prod_elec_techno(:,technoCoalWOCCS)) ~= 0
    indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
    nanIndex = ~isnan(indexee);
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(sum(prod_elec_techno(nanIndex,technoCoalWOCCS),2) .* indexee(nanIndex))./sum(prod_elec_techno(nanIndex,technoCoalWOCCS));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
//LCOE|Electricity|Gas|w CCS   US$2005/MWh
lineEMF = 147;
if sum(prod_elec_techno(:,technoGasWCCS)) ~= 0
    indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
    nanIndex = ~isnan(indexee);
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(sum(prod_elec_techno(nanIndex,technoGasWCCS),2) .* indexee(nanIndex))./sum(prod_elec_techno(nanIndex,technoGasWCCS));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
//LCOE|Electricity|Gas|w/o CCS   US$2005/MWh
lineEMF = 148;
if sum(prod_elec_techno(:,technoGasWOCCS)) ~= 0
    indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
    nanIndex = ~isnan(indexee);
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(sum(prod_elec_techno(nanIndex,technoGasWOCCS),2) .* indexee(nanIndex))./sum(prod_elec_techno(nanIndex,technoGasWOCCS));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
//LCOE|Electricity|Nuclear   US$2005/MWh
lineEMF = 149;;
if sum(prod_elec_techno(:,technoNuke)) ~= 0
    indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
    nanIndex = ~isnan(indexee);
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(sum(prod_elec_techno(nanIndex,technoNuke),2) .* indexee(nanIndex))./sum(prod_elec_techno(nanIndex,technoNuke));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
//LCOE|Electricity|Non-Biomass Renewables   US$2005/MWh
lineEMF = 150;
if sum(prod_elec_techno(:,technoNonBiomassRen)) ~= 0
    indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
    nanIndex = ~isnan(indexee);
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(sum(prod_elec_techno(nanIndex,technoNonBiomassRen),2) .* indexee(nanIndex))./sum(prod_elec_techno(nanIndex,technoNonBiomassRen));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
//LCOE|Electricity|Solar|Marginal   US$2005/MWh
lineEMF = 151;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
//LCOE|Electricity|Solar|Average   US$2005/MWh
lineEMF = 152;
if sum(prod_elec_techno(:,technoSolar)) ~= 0
    indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
    nanIndex = ~isnan(indexee);
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(sum(prod_elec_techno(nanIndex,technoSolar),2) .* indexee(nanIndex))./sum(prod_elec_techno(nanIndex,technoSolar));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
//LCOE|Electricity|Wind|Marginal   US$2005/MWh
lineEMF = 153;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
//LCOE|Electricity|Wind|Average   US$2005/MWh
lineEMF = 154;
if sum(prod_elec_techno(:,technoWind)) ~= 0
    indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
    nanIndex = ~isnan(indexee);
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(sum(prod_elec_techno(nanIndex,technoWind),2) .* indexee(nanIndex))./sum(prod_elec_techno(nanIndex,technoWind));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
//LCOE|Electricity|Biomass|w/ CCS   US$2005/MWh
lineEMF = 155;
if sum(prod_elec_techno(:,indice_BIS)) ~= 0
    indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
    nanIndex = ~isnan(indexee);
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(sum(prod_elec_techno(nanIndex,indice_BIS),2) .* indexee(nanIndex))./sum(prod_elec_techno(nanIndex,indice_BIS));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
//LCOE|Electricity|Biomass|w/o CCS   US$2005/MWh
lineEMF = 156;
if sum(prod_elec_techno(:,indice_BIG)) ~= 0
    indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
    nanIndex = ~isnan(indexee);
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(sum(prod_elec_techno(nanIndex,indice_BIG),2) .* indexee(nanIndex))./sum(prod_elec_techno(nanIndex,indice_BIG));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
// Capital Cost|Electricity|Coal|IGCC|w/o CCS  $/kW
lineEMF = 169;
if sum(prod_elec_techno(:,indice_ICG)) ~= 0
    indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
    nanIndex = ~isnan(indexee);
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(sum(prod_elec_techno(nanIndex,indice_ICG),2) .* indexee(nanIndex))./sum(prod_elec_techno(nanIndex,indice_ICG));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
// Efficiency|Electricity|Coal|IGCC|w/o CCS efficiency
lineEMF = 170;
if sum(prod_elec_techno(:,indice_ICG)) ~= 0
    indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
    nanIndex = ~isnan(indexee);
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(sum(prod_elec_techno(nanIndex,indice_ICG),2) .* indexee(nanIndex))./sum(prod_elec_techno(nanIndex,indice_ICG));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
// Capital Cost|Electricity|Gas|CC|w/o CCS  $/kW
lineEMF = 171;
if sum(prod_elec_techno(:,indice_GGC)) ~= 0
    indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
    nanIndex = ~isnan(indexee);
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(sum(prod_elec_techno(nanIndex,indice_GGC),2) .* indexee(nanIndex))./sum(prod_elec_techno(nanIndex,indice_GGC));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
// Efficiency|Electricity|Gas|CC|w/o CCS    efficiency
lineEMF = 172;
if sum(prod_elec_techno(:,indice_GGC)) ~= 0
    indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im); 
    nanIndex = ~isnan(indexee);
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(sum(prod_elec_techno(nanIndex,indice_GGC),2) .* indexee(nanIndex))./sum(prod_elec_techno(nanIndex,indice_GGC));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
// Capital Cost|Electricity|Solar|PV   $/kW
lineEMF = 173;
if sum(prod_elec_techno(:,technoPV)) ~= 0
    indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
    nanIndex = ~isnan(indexee);
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(sum(prod_elec_techno(nanIndex,technoPV),2) .* indexee(nanIndex))./sum(prod_elec_techno(nanIndex,technoPV));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
// Capital Cost|Electricity|Solar|CSP    $/kW
lineEMF = 174;
if sum(prod_elec_techno(:,indice_CSP)) ~= 0
    indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
    nanIndex = ~isnan(indexee);
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(sum(prod_elec_techno(nanIndex,indice_CSP),2) .* indexee(nanIndex))./sum(prod_elec_techno(nanIndex,indice_CSP));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
// Capital Cost|Electricity|Nuclear $/kW
lineEMF = 175;
if sum(prod_elec_techno(:,technoNuke)) ~= 0
    indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
    nanIndex = ~isnan(indexee);
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(sum(prod_elec_techno(nanIndex,technoNuke),2) .* indexee(nanIndex))./sum(prod_elec_techno(nanIndex,technoNuke));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
// Capital Cost|Electricity|Wind onshore $/kW
lineEMF = 176;
if sum(prod_elec_techno(:,indice_WND)) ~= 0
    indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
    nanIndex = ~isnan(indexee);
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(sum(prod_elec_techno(nanIndex,indice_WND),2) .* indexee(nanIndex))./sum(prod_elec_techno(nanIndex,indice_WND));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
// LCOE|Liquids|Oil US$2005/MWh
lineEMF = 226;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
// LCOE|Liquids|Biomass|w/ CCS    US$2005/MWh
lineEMF = 227;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
// LCOE|Liquids|Biomass|w/o CCS   US$2005/MWh
lineEMF = 228;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
// LCOE|Liquids|Coal|w/ CCS US$2005/MWh
lineEMF = 229;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
// LCOE|Liquids|Coal|w/o CCS US$2005/MWh
lineEMF = 230;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
// Price|Secondary energy|Liquids|Biomass USD2005/GJ
prodBiomassLiquidReg = outputs_temp(nbLines*[0:11]   + line_biofuels,current_time_im);
lineEMF = 247;
indexee = outputs_temp(nbLines*[0:11] + lineEMF,current_time_im);
nanIndex = ~isnan(indexee);
if sum(prodBiomassLiquidReg(nanIndex)) ~= 0 & or(nanIndex)
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(prodBiomassLiquidReg(nanIndex) .* indexee(nanIndex)) ./ sum(prodBiomassLiquidReg(nanIndex));
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
//Price|Agriculture|Non-Energy Crops|Index    Index (2005 = 1)
lineEMF = 248;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = wp(agri) / wpref(agri);
//Price|Final Energy|Industry|Solids|Coal|w/ Taxes    US$2005/GJ
lineEMF = 304;
outSec = coal;
weights = squeeze(CI(outSec,indus,:)) .* Q(:,indus);
outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(weights .* outputs_temp(nbLines*[0:11] + lineEMF,current_time_im)) ./ sum(weights);
//Price|Final Energy|Industry|Solids|Biomass|w/ Taxes US$2005/GJ
lineEMF = 305;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
//Price|Final Energy|Industry|Liquids|w/ Taxes    US$2005/GJ
lineEMF = 306;
outSec = et;
weights = squeeze(CI(outSec,indus,:)) .* Q(:,indus);
outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(weights .* outputs_temp(nbLines*[0:11] + lineEMF,current_time_im)) ./ sum(weights);
//Price|Final Energy|Industry|Gases|w/ Taxes  US$2005/GJ
lineEMF = 307;
outSec = gaz;
weights = squeeze(CI(outSec,indus,:)) .* Q(:,indus);
outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(weights .* outputs_temp(nbLines*[0:11] + lineEMF,current_time_im)) ./ sum(weights);
//Price|Final Energy|Industry|Electricity|w/ Taxes    US$2005/GJ
lineEMF = 308;
outSec = elec;
weights = squeeze(CI(outSec,indus,:)) .* Q(:,indus);
outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(weights .* outputs_temp(nbLines*[0:11] + lineEMF,current_time_im)) ./ sum(weights);
//Price|Final Energy|Industry|Hydrogen|w/ Taxes   US$2005/GJ
lineEMF = 309;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
//Price|Final Energy|Industry|Heat|w/ Taxes   US$2005/GJ
lineEMF = 310;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
//Price|Final Energy|Residential and Commercial|Solids|Coal|w/ Taxes  US$2005/GJ
lineEMF = 311;
outSec = coal;
weights = squeeze(CI(outSec,compo,:)) .* Q(:,compo)+DF(:,outSec);
outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(weights .* outputs_temp(nbLines*[0:11] + lineEMF,current_time_im)) ./ sum(weights);
//Price|Final Energy|Residential and Commercial|Solids|Biomass|w/ Taxes   US$2005/GJ
lineEMF = 312;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
//Price|Final Energy|Residential and Commercial|Liquids|w/ Taxes  US$2005/GJ
lineEMF = 313;
outSec = et;
weights = squeeze(CI(outSec,compo,:)) .* Q(:,compo)+DF(:,outSec);
outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(weights .* outputs_temp(nbLines*[0:11] + lineEMF,current_time_im)) ./ sum(weights);
//Price|Final Energy|Residential and Commercial|Gases|w/ Taxes    US$2005/GJ
lineEMF = 314;
outSec = gaz;
weights = squeeze(CI(outSec,compo,:)) .* Q(:,compo)+DF(:,outSec);
outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(weights .* outputs_temp(nbLines*[0:11] + lineEMF,current_time_im)) ./ sum(weights);
//Price|Final Energy|Residential and Commercial|Electricity|w/ Taxes  US$2005/GJ
lineEMF = 315;
outSec = elec;
weights = squeeze(CI(outSec,compo,:)) .* Q(:,compo)+DF(:,outSec);
outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(weights .* outputs_temp(nbLines*[0:11] + lineEMF,current_time_im)) ./ sum(weights);
//Price|Final Energy|Residential and Commercial|Hydrogen|w/ Taxes US$2005/GJ
lineEMF = 316;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
//Price|Final Energy|Residential and Commercial|Heat|w/ Taxes US$2005/GJ
lineEMF = 317;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
//Price|Final Energy|Transportation|Liquids|w/ Taxes  US$2005/GJ
lineEMF = 318;
outSec = et;
weights = sum(squeeze(CI(outSec,transportIndexes,:))' .* Q(:,transportIndexes),2);
outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(weights .* outputs_temp(nbLines*[0:11] + lineEMF,current_time_im)) ./ sum(weights);
//Price|Final Energy|Transportation|Gases|w/ Taxes    US$2005/GJ
lineEMF = 319;
outSec = gaz;
weights = sum(squeeze(CI(outSec,transportIndexes,:))' .* Q(:,transportIndexes),2);
if or(weights>0)
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(weights .* outputs_temp(nbLines*[0:11] + lineEMF,current_time_im)) ./ sum(weights);
else
    outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
end
//Price|Final Energy|Transportation|Hydrogen|w/ Taxes US$2005/GJ
lineEMF = 320;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
//Price|Final Energy|Transportation|Electricity|w/ Taxes  US$2005/GJ
lineEMF = 321;
outSec = elec;
weights = sum(squeeze(CI(outSec,transportIndexes,:))' .* Q(:,transportIndexes),2);
outputs_temp(nbLines*reg+lineEMF,current_time_im) = sum(weights .* outputs_temp(nbLines*[0:11] + lineEMF,current_time_im)) ./ sum(weights);
//Resource|Average Extraction Cost|Coal   US$2005/GJ
lineEMF = 341;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
//Resource|Average Extraction Cost|Oil    US$2005/GJ
lineEMF = 342;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;
//Resource|Average Extraction Cost|Gas    US$2005/GJ
lineEMF = 343;
outputs_temp(nbLines*reg+lineEMF,current_time_im) = %nan;


// =============================================== //

execstr(" outputs_"+ETUDE+" = outputs_temp;");
mkcsv( 'outputs_'+ETUDE ); 
