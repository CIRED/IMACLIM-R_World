// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas, Julie Rozenberg, Nicolas Graves, Adrien Vogt-Schilb
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/////////////////////////////////////////////////////////////////////////////////////////////////////
//		Preambule
/////////////////////////////////////////////////////////////////////////////////////////////////////
exec(".."+filesep()+"preamble.sce");

wasdone = check_wasdone(liste_savedir);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//on récupère des vecteurs avec les valeurs des indices pour chaque scenario
[ind_climat,ind_EEI,ind_CCS,ind_NUC,ind_ENR,ind_bioEnergy,ind_taxexo]=combi2indices((1:size(matrice_indices,1))',matrice_indices);
numIndClimat = 1;
m_combi = 1:size(wasdone,1)';
m_combi = m_combi(wasdone)';

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

data_input = [ 
"ECO2W"
"wp_coal"
"wp_oil"
"wp_gas"
"wp_elec"
"wp_Et"
"Qcoalw"
"Qoilw"
"Qgasw"
"QCTLw"
"Qbiofuelsw"
"TPESocde"
"TPESrow"
"TPESw"
"TFCocde"
"TFCrow"
"TFCw"
"IEocde"
"IErow"
"IEw"
"realGDPocde"
"realGDProw"
"realGDPw"
"Qelecw"
]';
 
/////////////////////////////////////////////////////////////////////////////////////////////////////
//							Creation des matrices m_data_input: 
//	pour chaque data_input on crée une matrice (get_nb_combis_etude(),50) qui contient tous les scenarios de combinaisons
/////////////////////////////////////////////////////////////////////////////////////////////////////

//ceci ne fonctionne pas, il faut reprendre

CSVDIR=MODEL+"matrices_csv"+filesep();  
mkdir(CSVDIR)
for data=data_input
	//si la matrice n'existe pas déjà dans matrices_csv on la fabrique et on la sauve
		execstr ("m_"+data+"=[];");
		for savedir=liste_savedir'
			if check_wasdone(savedir)
				combi=run_name2combi(savedir)
                ldsav(data,"",liste_savedir(combi,1));
				execstr ("m_"+data+"=[m_"+data+";"+data+"];");
			end
		end
mkcsv ("m_"+data, CSVDIR); 
end
mkcsv("m_combi", CSVDIR);


combi_names=["R2G7" "R2G6" "R2G1"]';
output=[];
for data=data_input
    execstr ("output=[output;[m_combi,data+emptystr(sum(wasdone),1),m_"+data+"]];");
end

output_AMPERE = [ ["" '' string(2000+(1:TimeHorizon+1))]; output];
mkcsv("output_AMPERE", CSVDIR);


