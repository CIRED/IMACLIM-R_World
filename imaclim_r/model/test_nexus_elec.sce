// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

output_invcost_elec=zeros(reg*techno_elec,TimeHorizon);

//nomenclature
// indice_PFC=1; 	Super Critical pulverised coal
// indice_PSS=2; 	Super Critical pulverised coal with sequestration
// indice_ICG=3; 	Integrated Coal Gasification with Combined Cycle
// indice_CGS=4; 	Integrated Coal Gasification with Combined Cycle with sequestration
// indice_LCT=5; 	Lignite-powered Conventional Thermal
// indice_CCT=6; 	Coal-powered Conventional Thermal
// indice_OCT=11;	Oil-powered Conventional Thermal
// indice_GCT=7; 	Gas-powered Conventional Thermal
// indice_GGT=8; 	Gas-powered Gas Turbine in Combined Cycle
// indice_OGC=12;	Oil-powered Gas Turbine in Combined Cycle
// indice_GGS=9; 	Gas-powered Gas Turbine in Combined Cycle with sequestration
// indice_GGC=10;	Gas-powered Gas Turbine in Combined Cycle
// indice_HYD=13;	Conventional, large-size hydroelectricity
// indice_NUC=14;	Conventional Light-Water nuclear Reactor
// indice_NND=15;	New Nuclear Design
// indice_CHP=16;   Combined Heat and Power (small to medium-size cogeneration in industry)
// indice_SHY=17;   Small Hydro
// indice_WND=18;   Wind turbines
// indice_WNO=19;   Wind turbines offshore
// indice_CSP=20;   Solar Power Plants (thermal technologies for network electricity production) 
// indice_CPV=21;   Decentralised building integrated PV systems with network connection
// indice_RPV=22;   PV systems for Decentralised rural electrification in DCs
// indice_BF2=23;   Biofuels, conventional technologies (woodfuels, elec. from wastes, biofuels)
// indice_BGT=24;   Biomass gasification for electricity production in GT
// indice_BIG=25;   Natural gas Fuel-Cells for stationary uses
// indice_HFC=26;   Hydrogen Fuel-Cells for stationary uses

// indice_PFC=1; 	Super Critical pulverised coal
// indice_PSS=2; 	Super Critical pulverised coal with sequestration
// indice_ICG=3; 	Integrated Coal Gasification with Combined Cycle
// indice_CGS=4; 	Integrated Coal Gasification with Combined Cycle with sequestration
// indice_LCT=5; 	Lignite-powered Conventional Thermal
// indice_CCT=6; 	Coal-powered Conventional Thermal
// indice_GCT=7; 	Gas-powered Conventional Thermal
// indice_GGT=8; 	Gas-powered Gas Turbine in Combined Cycle
// indice_GGS=9; 	Gas-powered Gas Turbine in Combined Cycle with sequestration
// indice_GGC=10;	Gas-powered Gas Turbine in Combined Cycle
// indice_OCT=11;	Oil-powered Conventional Thermal
// indice_OGC=12;	Oil-powered Gas Turbine in Combined Cycle
// indice_HYD=13;	Conventional, large-size hydroelectricity
// indice_NUC=14;	Conventional Light-Water nuclear Reactor
// indice_NND=15;	New Nuclear Design
// indice_CHP=16;   Combined Heat and Power (small to medium-size cogeneration in industry)
// indice_SHY=17;   Small Hydro
// indice_WND=18;   Wind turbines
// indice_WNO=19;   Wind turbines offshore
// indice_CSP=20;   Solar Power Plants (thermal technologies for network electricity production) 
// indice_CPV=21;   Decentralised building integrated PV systems with network connection
// indice_RPV=22;   PV systems for Decentralised rural electrification in DCs
// indice_BF2=23;   Biofuels, conventional technologies (woodfuels, elec. from wastes, biofuels)
// indice_BGT=24;   Biomass gasification for electricity production in GT
// indice_BIG=25;   Natural gas Fuel-Cells for stationary uses
// indice_HFC=26;   Hydrogen Fuel-Cells for stationary uses



for k=1:reg
    for k_time=1:T
        output_invcost_elec(techno_elec*(k-1)+indice_PFC,k_time)=CINV_MW(k,indice_PFC,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_PSS,k_time)=CINV_MW(k,indice_PSS,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_ICG,k_time)=CINV_MW(k,indice_ICG,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_CGS,k_time)=CINV_MW(k,indice_CGS,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_LCT,k_time)=CINV_MW(k,indice_LCT,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_CCT,k_time)=CINV_MW(k,indice_CCT,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_OCT,k_time)=CINV_MW(k,indice_OCT,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_GCT,k_time)=CINV_MW(k,indice_GCT,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_GGT,k_time)=CINV_MW(k,indice_GGT,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_OGC,k_time)=CINV_MW(k,indice_OGC,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_GGS,k_time)=CINV_MW(k,indice_GGS,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_GGC,k_time)=CINV_MW(k,indice_GGC,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_HYD,k_time)=CINV_MW(k,indice_HYD,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_NUC,k_time)=CINV_MW(k,indice_NUC,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_NND,k_time)=CINV_MW(k,indice_NND,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_CHP,k_time)=CINV_MW(k,indice_CHP,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_SHY,k_time)=CINV_MW(k,indice_SHY,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_WND,k_time)=CINV_MW(k,indice_WND,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_WNO,k_time)=CINV_MW(k,indice_WNO,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_CSP,k_time)=CINV_MW(k,indice_CSP,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_CPV,k_time)=CINV_MW(k,indice_CPV,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_RPV,k_time)=CINV_MW(k,indice_RPV,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_BF2,k_time)=CINV_MW(k,indice_BF2,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_BGT,k_time)=CINV_MW(k,indice_BGT,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_BIG,k_time)=CINV_MW(k,indice_BIG,k_time);
        output_invcost_elec(techno_elec*(k-1)+indice_HFC,k_time)=CINV_MW(k,indice_HFC,k_time);
    end
end

fprintfMat(SAVEDIR+'output_invcost_elec'+'.tsv',output_invcost_elec);

//cost of ENR per MWh
CINV(:,indice_NND+1:$)./(Load_factor_ENR*1000+0.00000000001)
