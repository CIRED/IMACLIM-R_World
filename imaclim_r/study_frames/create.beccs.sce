// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//creates a matrix with the combi number and the indices
combi=0;
for ind_climat = [0 550]
    for ind_EEI = [0]
        for ind_CCS = [0 1]
            for ind_NUC = [1]
                for ind_ENR = [1]
                    for ind_bioEnergy = [0 1]
                        for ind_recycling = [0 1 2]
                            for ind_infra = [0 1]
                                for ind_traj = [0 1]
                                    combi = combi+1;
                                    matrice_indices(combi,:) = [ combi,ind_climat,ind_EEI,ind_CCS,ind_NUC,ind_ENR,ind_bioEnergy,ind_recycling,ind_infra,ind_traj];
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
