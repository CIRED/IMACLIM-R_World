// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


counterLine = 0 ;

varname = 'GDP|MER'; // billion billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)= GDP_MER_real(k)/ 1e3;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014/yr";
end;

varname = 'GDP|PPP'; // billion billion US$2010/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1)=GDP_PPP_constant(k)/ 1e3;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014/yr";
end;

varname = 'Investment'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(DeltaK(k,:).*pK(k,:))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Consumption|Households'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(DF(k,:).*p(k,:))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Consumption|Governments'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(DG(k,:).*p(k,:))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Value Added|Total'; //   billion US$2014/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(VA(k,:))/1000/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014/yr";
end;

varname = 'Value Added|Agriculture'; //   billion US$2014/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(VA(k,indice_agriculture))/1000/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014/yr";
end;

varname = 'Value Added|Fossil fuels'; //   billion US$2014/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(VA(k,indice_coal:indice_Et))/1000/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014/yr";
end;

varname = 'Value Added|Electricity'; //   billion US$2014/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(VA(k,indice_elec))/1000/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014/yr";
end;

varname = 'Value Added|Industries'; //   billion US$2014/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(VA(k,indice_industries))/1000/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014/yr";
end;

varname = 'Value Added|Construction'; //   billion US$2014/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(VA(k,indice_construction))/1000/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014/yr";
end;

varname = 'Value Added|Services'; //   billion US$2014/yr
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(VA(k,[transportIndexes indice_composite]))/1000/GDP_MER_nominal(k)*GDP_MER_real(k);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014/yr";
end;

varname = 'Employment|Total'; //   Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(labor_ILO(k,:))/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";
end;

varname = 'Employment|Agriculture'; //   Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = labor_ILO(k,indice_agriculture)/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";
end;

varname = 'Employment|Fossil fuels'; //   Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum( labor_ILO(k,indice_coal:indice_Et))/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";
end;

varname = 'Employment|Electricity'; //   Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = labor_ILO(k,indice_elec)/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";
end;

varname = 'Employment|Industries'; //   Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(labor_ILO(k,indice_industries))/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";
end;

varname = 'Employment|Construction'; //   Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = labor_ILO(k,indice_construction)/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";
end;

varname = 'Employment|Services'; //   Million full-time equivalent
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(labor_ILO(k,[transportIndexes indice_composite]))/1000000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Million full-time equivalent";
end;

varname = 'Production|Total'; //   Mtoe or pseudo-quantities
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Q(k,:));
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";
end;

varname = 'Production|Agriculture'; //   Mtoe or pseudo-quantities
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q(k,indice_agriculture);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";
end;

varname = 'Production|Fossil fuels'; //   Mtoe or pseudo-quantities
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Q(k,indice_coal:indice_Et));
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";
end;

varname = 'Production|Electricity'; //   Mtoe or pseudo-quantities
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q(k,indice_elec);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";
end;

varname = 'Production|Industries'; //   Mtoe or pseudo-quantities
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Q(k,indice_industries));
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";
end;

varname = 'Production|Construction'; //   Mtoe or pseudo-quantities
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q(k,indice_construction);
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";
end;

varname = 'Production|Services'; //   Mtoe or pseudo-quantities
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Q(k,[transportIndexes indice_composite]));
if current_time_im==yr_start & k==1; list_output_unit($+1) = "Mtoe or pseudo-quantities";
end;

varname = 'Production|Value|Total'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Q(k,:).*p(k,:))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Production|Value|Agriculture'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q(k,indice_agriculture).*p(k,indice_agriculture)/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Production|Value|Fossil fuels'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Q(k,indice_coal:indice_Et).*p(k,indice_coal:indice_Et))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Production|Value|Electricity'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q(k,indice_elec).*p(k,indice_elec)/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Production|Value|Industries'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Q(k,indice_industries).*p(k,indice_industries))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Production|Value|Construction'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q(k,indice_construction).*p(k,indice_construction)/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Production|Value|Services'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Q(k,[transportIndexes indice_composite]).*p(k,[transportIndexes indice_composite]))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Production|Value|Agroindustry'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Q(k,12).*p(k,12)/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;






varname = 'Trade|Value|Exports'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Exp(k,:).*p(k,:))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Exports|Agriculture'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Exp(k,indice_agriculture).*p(k,indice_agriculture)/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Exports|Fossil fuels'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Exp(k,indice_coal:indice_Et).*p(k,indice_coal:indice_Et))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Exports|Electricity'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Exp(k,indice_elec).*p(k,indice_elec)/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Exports|Industries'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Exp(k,indice_industries).*p(k,indice_industries))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Exports|Construction'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Exp(k,indice_construction).*p(k,indice_construction)/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Exports|Services'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Exp(k,[transportIndexes indice_composite]).*p(k,[transportIndexes indice_composite]))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;



varname = 'Trade|Value|Imports'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Imp(k,:).*wp)/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Imports|Agriculture'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Imp(k,indice_agriculture).*wp(indice_agriculture)/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Imports|Fossil fuels'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Imp(k,indice_coal:indice_Et).*wp(indice_coal:indice_Et))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Imports|Electricity'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Imp(k,indice_elec).*wp(indice_elec)/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Imports|Industries'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Imp(k,indice_industries).*wp(indice_industries))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Imports|Construction'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = Imp(k,indice_construction).*wp(indice_construction)/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

varname = 'Trade|Value|Imports|Services'; //   billion US$2014
counterLine =counterLine+ 1; if current_time_im==yr_start & k==1; list_output_str($+1) = varname; end;
outputs_temp(nbLines*(k-1)+counterLine,current_time_im+1) = sum(Imp(k,[transportIndexes indice_composite]).*wp([transportIndexes indice_composite]))/GDP_MER_nominal(k)*GDP_MER_real(k)/1000;
if current_time_im==yr_start & k==1; list_output_unit($+1) = "billion US$2014";
end;

