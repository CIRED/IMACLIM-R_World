// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Thomas Le Gallic, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


//Incorporation in taxCI*** and taxDF*** of an excise duty on the prices of energy products. Pfinal = ( p_hors_taxe + exc) (1+vat))

pajtx=p;

//excise calibration fonction of WEM data
if current_time_im==1
    //WEM data
    //listesav=[ 'EXT_ref','VAT_ref','shDomtaxCI', 'shEXT_ref', 'VAT_TROD_GAO_12_n0', 'EXT_TROD_GAO_12_n0', 'shEXT_GAO'];
    listesav=[ 'shEXT_ref', 'shEXT_GAO'];
    ldsav( listesav,'calib');
	
    if nb_sectors_industry == 8 // DESAG_INDUSTRY: shEXT_ref needs to be computed for 19 sectors? Temporarily, we use the same values as for the whole industrial sector.
        for j=1:(nb_sectors_industry-1)
            shEXT_ref($+1,:,:)=shEXT_ref($,:,:);
        end
        for j=1:(nb_sectors_industry-1)
            shEXT_ref(:,$+1,:)=shEXT_ref(:,$,:);
        end
    end	
					
    for k=1:reg
        //Excise value fonction of the sahre of the excise in fiscality
        EXTdom_exo(:,:,k)=shEXT_ref(:,:,k).*(pajtx(k,:)'*ones(1,sec) ).* ( 1 + taxCIdom(:,:,k) );
        EXTimp_exo(:,:,k)=shEXT_ref(:,:,k).*(pajtx(k,:)'*ones(1,sec) ).* ( 1 + taxCIimp(:,:,k) );
		
        VATdom_exo(:,:,k)=((pajtx(k,:)'*ones(1,sec)) .* (1+taxCIdom(:,:,k) ))./( (pajtx(k,:)'*ones(1,sec)) + EXTdom_exo(:,:,k) ) -1;
        VATimp_exo(:,:,k)=((pajtx(k,:)'*ones(1,sec)) .* (1+taxCIimp(:,:,k) ))./( (pajtx(k,:)'*ones(1,sec)) + EXTimp_exo(:,:,k) ) -1;
    end                                                                                                         
	
    //particular case for refined products
    EXT_GAOdom = shEXT_GAO.*pajtx(:,indice_Et).*(1+taxDFdom(:,indice_Et) );
    EXT_GAOimp = shEXT_GAO.*pajtx(:,indice_Et).*(1+taxDFimp(:,indice_Et) );
	
    VAT_GAOdom = (pajtx(:,indice_Et) .* (1+ taxDFdom(:,indice_Et) ))./( pajtx(:,indice_Et) + EXT_GAOdom ) - 1;
    VAT_GAOimp = (pajtx(:,indice_Et) .* (1+ taxDFimp(:,indice_Et) ))./( pajtx(:,indice_Et) + EXT_GAOimp ) - 1;
	
    clear shEXT_ref shEXT_GAO
end

if current_time_im>1
    //Tax correection to simulate an excise
    //resolve the system (on tax_ima): p(1+tax_ima) = (p+exc)(1+vat)
    for k=1:reg
        taxCIdom (:,:,k)         = ( pajtx(k,:)'*ones(1,sec) + EXTdom_exo(:,:,k) ).* ( 1 + VATdom_exo(:,:,k) ) ./ ( pajtx(k,:)'*ones(1,sec) ) - 1;
        taxCIimp (:,:,k)         = ( pajtx(k,:)'*ones(1,sec) + EXTimp_exo(:,:,k) ).* ( 1 + VATimp_exo(:,:,k) ) ./ ( pajtx(k,:)'*ones(1,sec) ) - 1;
    end
	
    taxDFdom(:,indice_Et)=( pajtx(:,indice_Et) + EXT_GAOdom ) .* (1+ VAT_GAOdom) ./ (pajtx(:,indice_Et))-1;
    taxDFimp(:,indice_Et)=( pajtx(:,indice_Et) + EXT_GAOimp ) .* (1+ VAT_GAOimp) ./ (pajtx(:,indice_Et))-1;
	
end

clear pajtx
