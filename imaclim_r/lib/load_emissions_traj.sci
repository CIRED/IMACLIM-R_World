// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function y=load_emissions_traj(path, start_year)
    // function to load historical emissions trajectory from PRIMAP, Global Carbon Budget, Minx et al., 2022
    // the region is already in the right order on those data
    mat=csvRead(path,'|')
    i=find(mat(1,:)== start_year)
    y=mat(2:$,i:$);
endfunction
