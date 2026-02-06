// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Thomas Le Gallic
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

////////////////////////////////
// Schock Covid
////////////////////////////////

// end of covid crisis in 2021
if current_time_im==(2021-base_year_simulation) & covid_crises_shock==%t
    Cap( :, btp) = Cap( :, btp) + Cap_covid( :, btp) .* (1- scale_impact_covid );
    Cap( :, compo) = Cap( :, compo) + Cap_covid( :, compo) .* (1- scale_impact_covid );
    Cap( :, indus) = Cap( :, indus) + Cap_covid( :, indus) .* repmat((1- min(scale_impact_covid*scale_covid_indus) ),nb_regions,nb_sectors_industry);
    for isec=indice_transport_1:indice_transport_2
        Cap( :, isec) = Cap( :, isec) + Cap_covid( :, isec) .* (1- scale_impact_covid * scale_covid_transport);
    end
    for jj=1:size(Capvintagecomposite,"c")
        Capvintagecomposite(:,jj) = Capvintagecomposite(:,jj)  .* (1 - (1- scale_impact_covid) ); 
        Capvintageindustries(:,1:nb_sectors_industry,jj)  = Capvintageindustries(:,1:nb_sectors_industry,jj)  .* repmat((1 - (1- scale_impact_covid)),1,nb_sectors_industry);
    end
    K = Cap ./ alphaK;
end        

