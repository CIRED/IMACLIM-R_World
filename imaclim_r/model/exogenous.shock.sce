// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

////////////////////////////////
// Schock Covid
////////////////////////////////

if ~isfile( path_autocalibration+'/scale_impact_covid.csv')
    scale_impact_covid = ones(12,1);
else
    scale_impact_covid = csvRead( path_autocalibration+'/scale_impact_covid.csv',',');
end
scale_impact_covid( scale_impact_covid>1) = 1;

// shock in 2020
if current_time_im==(2020-base_year_simulation) & covid_crises_shock==%t
        scale_covid_indus = 1.20;
        scale_covid_transport = 0.985;
        Cap_covid = Cap;
        Cap=alphaK.*(K.^betaK);
        Cap( :, btp) = Cap( :, btp) .* scale_impact_covid;
        Cap( :, compo) = Cap( :, compo) .* scale_impact_covid;
        for isec=indice_transport_1:indice_transport_2
            Cap( :, isec) = Cap( :, isec) .* scale_impact_covid * scale_covid_transport;
        end
        for isec=indice_industries
            Cap( :, isec) = Cap( :, isec) .* min(scale_impact_covid * scale_covid_indus,1);
        end
        K = Cap ./ alphaK;
end
