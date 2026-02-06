// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

if size(is_taxexo_MKT,"*")~=nbMKT | size(is_quota_MKT,"*")~=nbMKT
    error("is_taxexo_MKT,*)~=nbMKT | size(is_quota_MKT,*)~=nbMKT")
end

if max(whichMKT_reg_use)<>nbMKT
    error ("wrong whichMKT_reg_use")
end

if or(is_quota_MKT&is_taxexo_MKT)
    error ("a MKT is both price-constrained and quantity-constrained")
end

if or(size(whichMKT_reg_use) ~= [reg,nb_use])
    error("incorrect size for whichMKT_reg_use");
end
