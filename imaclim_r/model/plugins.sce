// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Adrien Vogt-Schilb, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// diagnostic of scenarios
exec (MODEL+"diagnostic.sce");


if ind.monitor
    exec(CONTROL+"control.emissions.sce");
    exec(CONTROL+"control.costCI.sce");
    exec(CONTROL+"control.equilibrium.sce");
    exec(CONTROL+"control.elec.sce");
    exec(CONTROL+"control.markup.sce");
    exec(CONTROL+"control.biomass.sce");
    exec(CONTROL+"control.mshElec.sce");
end

//Inequalities module
if ind_inequality == 1
    exec(MODEL+"nexus.inequalities.sce");
end

exec(MODEL+"extraction.outputs."+ETUDEOUTPUT+".sce");
//exec(MODEL+"extraction.outputs.ar5.sce");

if (modulo(current_time_im,10) == 0)|(current_time_im==TimeHorizon)
    sg_save();
    mksav("investment");
    mksav("stock_car_ventile");

    write(LOGDIR+"memory-"+current_time_im+".csv",checkMemory());
end
