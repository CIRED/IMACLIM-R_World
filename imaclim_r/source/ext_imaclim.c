// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Séverine Wiltgen, Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

#define __USE_DEPRECATED_STACK_FUNCTIONS__

/*
   For the IMACLIM-R model.

   Meant to be called from scilab (for fsolve).

   Call allocate_matrix once.
   Call set_params every time the params are changed;
   EconomyC is to be called by fsolve.

   in scilab, use help ilib_for_link

   To call directly economyC:
   res_eco = call('economyC',n,1,'i',x,2,'d','out',[1,n],3,'d');
   or
   res_eco = call('economyC',size(x0,'r'),1,'i',x0,2,'d','out',[1,n],3,'d');
   res_eco = call('economyC',size(x0,'r'),1,'i',x0,2,'d','out',[1,size(x0,'r')],3,'d');
   Testing with scilab

*/

#include "api_scilab.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
/* 
#include "/usr/lib/scilab-4.0/routines/stack-c.h" 
#include "C:\Program Files\scilab-4.0\routines\stack-c.h"
*/
#include "sciprint.h"



//functions TOC
//int find_hyperm(char* name, double ****matrix)
//int fill_2d_matrix(int *index, int* nb_row, int* nb_col, double* matrix, char* mat_name, int *status)
//int set_param()
//void economyC(int *n, double x[],double v[],int *iflag)
//void XeconomyC(int *nX, double xX[],double vX[],int *iflagX)


/* structure used for parameter hypermatrix filling */
struct hyperm {
    char* name;
    double ****matrix;
};

typedef struct hyperm hyperm;

int verbose_C=0;

int reg;
int sec;
int nb_use;
int iu_df;
int iu_dg;
int iu_di;
int new_Et_msh_computation;
int exo_pkmair_scenario;

int nb_secteur_conso;
int indice_energiefossile1;
int indice_energiefossile2;
int indice_construction;
int nbsecteurenergie;
int indice_composite;
int indice_mer;
int indice_air;
int indice_OT;
int indice_Et;
int indice_elec;
int indice_coal;
int indice_oil;
int indice_gas;
int nb_trans;
int indice_transport_1;
int indice_transport_2;
int indice_agriculture;
int nb_sectors_industry;
int indice_industries[8]; // NB: it should be nb_sectors_industry, but I don't know yet how to write it																								   
int nbsecteurcomposite;
int nb_secteur_utile;
int nbMKT;
int nX;

double wpTIaggloc;

/* matrices dont les valeurs sont passes en argument de la fonction */
double **Consoloc;
double *Tautomobileloc;
double *lambdaloc;
double *muloc;
double **ploc;
double **wloc;
double **Qloc;
double *Rdisploc;
double *TNMloc;
double *wpEnerloc;
double *taxMKT;

/* matrices intermediaires */
double **DFloc;
double *zloc;
double **numloc;
double *wploc;
double **FCCtemp;
double **FCCmarkup;
double **FCCmarkup_oil;
double *wpTIloc;
double **marketshare;
double **marketshareTI;
double *pindtemp;
double *GRBtemp;
double *NRBtemp;
double *mult_oil;
double *mult_gaz;
double *mult_coal;
double **DIloc;
double **QCdomtemp;
double **TAXCO2temp_dom;
double **TAXCO2temp_imp;
double **Imptemp;
double **Exptemp;
double **ExpTItemp;
double *TAXCO2temp;
double *tair;
double *tOT;
double *tautomobile;
double **xsi;
double **partDomDF;
double **partDomDG;
double **partDomDI;
double **partImpDF;
double **partImpDG;
double **partImpDI;

double *ItOT;
double *Itair;
double *Itautomobile;
double **Utility;
double *Household_budget;
double *Time_budget;
double **Market_clear;
double **Wages;
double *Energy_world_prices;
double *State_budget;
double *sumtaxtemp;
double *taxCItemp;
double **costs_CI;
double **Sector_budget;
double *emissions_gap;
double *E_CO2_MKT;

/* matrice de parametres */
double etaTI;
double etaEtnew;
double inertia_share;

double **alpha_partDF;
double *alphaCompositeauto;
double *pkmautomobileref;
double *weight_regional_tax;
double *alphaEtauto;
double *alphaelecauto;
double *alphaEtm2;
double *stockbatiment;
double *alphaelecm2;
double *alphaCoalm2;
double *alphaGazm2;
double **A;
double **A_CI;
double *L;
double *coef_Q_CO2_Et_prod;
double *QuotasRevenue;
double *CO2_obj_MKTparam;
double *CO2_untaxed;
double *areEmisConstparam; //todo :  change this to int (prob with allocate matrixe)
double *verbose;
double *shareBiomassTaxElec;
double *is_taxexo_MKTparam; //todo :  change this to int (prob with allocate matrixe)
double **whichMKT_reg_use;
double **alpha_partDG;
double **alpha_partDI;
double *alphaair;
double *alphaOT;
double *Rdisp;
double **aRD;
double **bRD;
double **cRD;
double **DG;
double **DIinfra;
double **DIprod;
double **DFref;
double *DFair_exo;
double **pArmDFref;
double **bn;
double **Cap;
double **coef_Q_CO2_DF;
double **coef_Q_CO2_DG;
double **coef_Q_CO2_DI;
double *bnair;
double *bnautomobile;
double *bnNM;
double *bnOT;
double *Tautomobile;
double *Tdisp;
double *TNMref;
double *toair;
double *toautomobile;
double *toNM;
double *toOT;
double **Ttax;
double **Conso;
double *aw;
double *bw;
double *cw;
double *divi; /* div is a C function, we use divi instead*/
double *partExpK;
double *partImpK;
double *IR;
double *pindref;
double *sigmatrans;
double *xsiT;
double **wref;
double **xtax;
double **xtaxref;
double *wpEnerref;
double **lll; /* l is used for indices, we use lll instead */
double **markup;
double **pref;
double **markupref;
double **markup_lim_oil;
double **mtax;
double **nit;
double **non_energ_sec;
double **pArmDG;
double **pArmDF;
double **pArmDI;
double **partDomDFref;
double **partDomDGref;
double **partDomDIref;
double **partDomDF_stock;
double **partDomDF_min;
double **partDomDG_stock;
double **partDomDI_stock;
double **qtax;
double **sigma;
double **taxCO2_DF;
double **taxCO2_DG;
double **taxCO2_DI;
double **taxDFdom;
double **taxDFimp;
double **taxDGdom;
double **taxDGimp;
double **taxDIdom;
double **taxDIimp;
double **energ_sec;
double **itgbl_cost_DFdom;
double **itgbl_cost_DGdom;
double **itgbl_cost_DIdom;
double **itgbl_cost_DFimp;
double **itgbl_cost_DGimp;
double **itgbl_cost_DIimp;
double **p_stock;
double **atrans;
double **btrans;
double **Captransport;
double **bmarketshareener;
double **ktrans;
double **weightTI;
double *weightEt_new;
double *eta;
double *etamarketshareener;
double *partTIref;
double **weight;
double **bDF;
double **bDG;
double **bDI;
double **etaDF;
double **etaDG;
double **etaDI;
double **betatrans;
double *ptc;
double *a4_mult_oil;
double *a3_mult_oil;
double *a2_mult_oil;
double *a1_mult_oil;
double *a0_mult_oil;
double *a4_mult_gaz;
double *a3_mult_gaz;
double *a2_mult_gaz;
double *a1_mult_gaz;
double *a0_mult_gaz;
double *a4_mult_coal;
double *a3_mult_coal;
double *a2_mult_coal;
double *a1_mult_coal;
double *a0_mult_coal;
double *index_test_temp; 
double ***partDomCI;
double ***partImpCI;
double ***bCI;
double ***CI;
double ***etaCI;
double ***itgbl_cost_CIdom;
double ***itgbl_cost_CIimp;
double ***taxCO2_CI;
double ***coef_Q_CO2_CI;
double ***pArmCI;
double ***partDomCIref;
double ***partDomCI_stock;
double ***partDomCI_min;
double ***taxCIdom;
double ***taxCIimp;
double ***alpha_partCI;

#define HYPERM_NR 13
/*pour les hypermatrices*/
hyperm hyperm_list[HYPERM_NR] = {
    { "bCI", &bCI },
    { "CI", &CI },
    { "etaCI", &etaCI },
    { "itgbl_cost_CIdom", &itgbl_cost_CIdom },
    { "itgbl_cost_CIimp", &itgbl_cost_CIimp },
    { "coef_Q_CO2_CI", &coef_Q_CO2_CI },
    { "taxCO2_CI", &taxCO2_CI },
    { "partDomCIref", &partDomCIref },
    { "partDomCI_stock", &partDomCI_stock },
    { "partDomCI_min", &partDomCI_min },
    { "taxCIdom", &taxCIdom },
    { "taxCIimp", &taxCIimp },
    { "alpha_partCI", &alpha_partCI }
};

#define allocate_matrix2d(matrix_name,dim1,dim2) \
    matrix_name = (double **) malloc(sizeof(double *) * dim1); \
for (k = 0;k < dim1;k++) \
{\
    matrix_name[k] = (double *) malloc(sizeof(double) * dim2);\
}

#define allocate_matrix3d(matrix_name,dim1,dim2,dim3) \
    matrix_name = (double ***) malloc(sizeof(double **) * dim1); \
for (k = 0;k < dim1;k++) \
{\
    matrix_name[k] = (double **) malloc(sizeof(double *) * dim2);\
    for (j = 0; j< dim2;j++) \
    {\
        matrix_name[k][j] = (double *) malloc(sizeof(double) * dim3); \
    }\
}

#define fill_matrix(matrix_name,dim1,dim2,val) \
    for (k = 0;k < dim1;k++) \
{\
    for (j = 0; j< dim2;j++) \
    {\
        matrix_name[k][j] = val; \
    }\
}

#define fill_vector(vec_name,dim,val) \
    for (k = 0;k < dim;k++) \
vec_name[k] = val;

// empty function - to have a good .so file title in scilab
int imaclim_static_cge()
{
	return 0;
}

/////////////////////////////////////////////////////////
// Allocation functions: scilab v6.0 and greater
//

// Function to convert a double vector into a double matrix
void vectorToMatrix(double* vector, int rows, int cols, double*** matrixPtr) {
    for (int i = 0; i < rows; ++i) {
        for (int j = 0; j < cols; ++j) {
            (*matrixPtr)[i][j] = vector[i + j * rows];
        }
    }
}

int assign_fromScilabVal_scalar_int(scilabEnv env, const char* var_str, int* var)
{
        SciErr sciErr;
        int** var_pointer = NULL;
	var_pointer = (int**)malloc(sizeof(int*));
        int n_row = 0;
        int n_col = 0;
        double* scalar_double       = NULL;
        sciErr = getVarAddressFromName( env, var_str, var_pointer);
        sciErr = getMatrixOfDouble( env, *var_pointer, &n_row, &n_col, &scalar_double);
        *var = (int)scalar_double[0]; 
	if (verbose_C==1) {
	    printf("Character: %s\n", var_str);
	    printf("   %s %i\n", var_str, var[0]);
	}
        return STATUS_OK;
}

int assign_fromScilabVal_scalar_double(scilabEnv env, const char* var_str, double* var)
{
        SciErr sciErr;
        int** var_pointer = NULL;
	var_pointer = (int**)malloc(sizeof(int*));
        int n_row = 0;
        int n_col = 0;
        double* scalar_double       = NULL;
        sciErr = getVarAddressFromName( env, var_str, var_pointer);
        sciErr = getMatrixOfDouble( env, *var_pointer, &n_row, &n_col, &scalar_double);
        *var = scalar_double[0]; 
	if (verbose_C==1) {
	    printf("Character: %s\n", var_str);
	    for (int i; i< n_row*n_col; ++i) {
	        printf("   %s %.2f \n", var_str, scalar_double[i]);
	    }
 	}
        return STATUS_OK;
}

int assign_fromScilabVal_vector_double(scilabEnv env, const char* var_str, double *var)
{
        SciErr sciErr;
        int** var_pointer = NULL;
	var_pointer = (int**)malloc(sizeof(int*));
	double* pdblReal        = NULL;
        int n_row = 0;
        int n_col = 0;
        sciErr = getVarAddressFromName( env, var_str, var_pointer);
        sciErr = getMatrixOfDouble( env, *var_pointer, &n_row, &n_col, &pdblReal);
    	for (int i = 0; i < n_row; ++i) {
        	for (int j = 0; j < n_col; ++j) {
            	    var[i + j * n_row] = pdblReal[i + j * n_row];
	    }
    	}
	if (verbose_C==1) {
	    printf("Character: %s\n", var_str);
	    for (int i; i< n_row*n_col; ++i) {
	        printf("   %s %.10f \n", var_str, var[i]);
	    }
	}
        return STATUS_OK;
}

int assign_fromScilabVal_vector_int(scilabEnv env, const char* var_str, int *var)
{
        SciErr sciErr;
        int** var_pointer = NULL;
        int n_row = 0;
	var_pointer = (int**)malloc(sizeof(int*));
        int n_col = 0;
	double* var_double = NULL;
        sciErr = getVarAddressFromName( env, var_str, var_pointer);
        sciErr = getMatrixOfDouble( env, *var_pointer, &n_row, &n_col, &var_double);
	// convert to int
	for (int j = 0; j < n_row*n_col; ++j) {
		var[j] = (int)var_double[j];
	}
        return STATUS_OK;
}

int assign_fromScilabVal_matrix_double(scilabEnv env, const char* var_str, double **var)
{
        SciErr sciErr;
        int** var_pointer = NULL;
	var_pointer = (int**)malloc(sizeof(int*));
	double* pdblReal        = NULL;
        int n_row = 0;
        int n_col = 0;
        sciErr = getVarAddressFromName( env, var_str, var_pointer);  
        sciErr = getMatrixOfDouble( env, *var_pointer, &n_row, &n_col, &pdblReal);
        vectorToMatrix(pdblReal, n_row, n_col, &var);
        return STATUS_OK;
}

// Function to convert a double vector into a double matrix
void vectorToHyperMatrix(double* vector, int* dims, int ndims, double**** matrixPtr) {
    for (int i = 0; i < dims[2]; ++i) {
        for (int j = 0; j < dims[1]; ++j) {
        	for (int k = 0; k < dims[0]; ++k) {
            		(*matrixPtr)[k][j][i] = vector[i * dims[1] * dims[0] + j * dims[0] + k];
		}
        }
    }
    if (verbose_C==1) {
        for (int i = 0; i < dims[2]; ++i) {
            for (int j = 0; j < dims[1]; ++j) {
        	for (int k = 0; k < dims[0]; ++k) {
			printf("        %i %i %i: %.2f\n", i, j, k, vector[i * dims[1] * dims[2] + j * dims[2] + k]);
			printf("        %i %i %i: %.6f\n", k+1, j+1, i+1, vector[i * dims[1] * dims[0] + j * dims[0] + k]);
			printf("        %i %i %i: %.2f\n", i, j, k, vector[i + dims[0] * j + dims[1] * dims[2] + k]);
		}
            } 
        }
    }			
}

int assign_fromScilabVal_hypermatrix_double(scilabEnv env, const char* var_str, double ***var)
{
        SciErr sciErr;
        int** var_pointer = NULL;
        var_pointer = (int**)malloc(sizeof(int*));
        double* pdblReal        = NULL;
        int n_row = 0;
        int n_col = 0;
	int* dims = NULL;
	int ndims = 0;
        sciErr = getVarAddressFromName( env, var_str, var_pointer);
        sciErr = getHypermatOfDouble( env, *var_pointer, &dims, &ndims, &pdblReal);
        if (ndims==3) {
	    if (verbose_C==1) { printf("Character: %s\n", var_str);}
            vectorToHyperMatrix(pdblReal, dims, ndims, &var);
	}
	//else {
	//    printf(" I DONT HAVE 3 NDIMS fr %s but %i\n", var_str, ndims);
	//}
        if (verbose_C==1) {
	    printf("Character: %s\n", var_str);
	    for (int i = 0; i < dims[1] * dims[2] * dims[0]; ++i ) {
		printf("    %s  at %i: %.2f\n", var_str, i, pdblReal[i]);
	    }
	}
        return STATUS_OK;
}

int initial_memory_allocation()
{
    int k,j;

    allocate_matrix2d(ploc,reg,sec);
    allocate_matrix2d(wloc,reg,sec);
    allocate_matrix2d(Qloc,reg,sec);

    allocate_matrix2d(Consoloc,reg,nb_secteur_conso);
    Tautomobileloc = (double *) malloc(sizeof(double) * reg);
    lambdaloc = (double *) malloc(sizeof(double) * reg);
    muloc = (double *) malloc(sizeof(double) * reg);
    Rdisploc = (double *) malloc(sizeof(double) * reg);
    TNMloc = (double *) malloc(sizeof(double) * reg);
    wpEnerloc = (double *) malloc(sizeof(double) * nbsecteurenergie);

    /*matrices intermediaires*/

    zloc = (double *) malloc(sizeof(double) * reg);
    pindtemp = (double *) malloc(sizeof(double) * reg);
    TAXCO2temp = (double *) malloc(sizeof(double) * reg);
    GRBtemp = (double *) malloc(sizeof(double) * reg);
    NRBtemp = (double *) malloc(sizeof(double) * reg);
    mult_oil = (double *) malloc(sizeof(double) * reg);
    mult_gaz = (double *) malloc(sizeof(double) * reg);
    mult_coal = (double *) malloc(sizeof(double) * reg);
    tair = (double *) malloc(sizeof(double) * reg);
    tOT = (double *) malloc(sizeof(double) * reg);
    tautomobile = (double *) malloc(sizeof(double) * reg);
    ItOT = (double *) malloc(sizeof(double) * reg);
    Itair = (double *) malloc(sizeof(double) * reg);
    Itautomobile = (double *) malloc(sizeof(double) * reg);
    wploc = (double *) malloc(sizeof(double) * sec);
    wpTIloc = (double *) malloc(sizeof(double) * nb_trans);
    Household_budget = (double *) malloc(sizeof(double) * reg);
    Time_budget = (double *) malloc(sizeof(double) * reg);
    Energy_world_prices = (double *) malloc(sizeof(double) * reg);
    State_budget = (double *) malloc(sizeof(double) * reg);
    sumtaxtemp = (double *) malloc(sizeof(double) * reg);
    taxCItemp = (double *) malloc(sizeof(double) * reg);

    emissions_gap = (double *) calloc(sizeof(double),nbMKT);
    E_CO2_MKT = (double *) calloc(sizeof(double),nbMKT);

    allocate_matrix2d(numloc,reg,sec);
    allocate_matrix2d(DIloc,reg,sec);
    allocate_matrix2d(QCdomtemp,reg,sec);
    allocate_matrix2d(TAXCO2temp_dom,reg,sec);
    allocate_matrix2d(TAXCO2temp_imp,reg,sec);
    allocate_matrix2d(Imptemp,reg,sec);
    allocate_matrix2d(Exptemp,reg,sec);
    allocate_matrix2d(ExpTItemp,reg,sec);
    allocate_matrix2d(DFloc,reg,sec);
    allocate_matrix2d(FCCtemp,reg,sec);
    allocate_matrix2d(FCCmarkup,reg,sec);
    allocate_matrix2d(FCCmarkup_oil,reg,sec);
    allocate_matrix2d(partImpDF,reg,sec);
    allocate_matrix2d(partImpDG,reg,sec);
    allocate_matrix2d(partImpDI,reg,sec);
    allocate_matrix2d(partDomDF,reg,sec);
    allocate_matrix2d(partDomDG,reg,sec);
    allocate_matrix2d(partDomDI,reg,sec);
    allocate_matrix2d(marketshare,reg,sec);
    allocate_matrix2d(Market_clear,reg,sec);
    allocate_matrix2d(Wages,reg,sec);
    allocate_matrix2d(costs_CI,reg,sec);
    allocate_matrix2d(Sector_budget,reg,sec);

    allocate_matrix2d(xsi,reg,sec-nbsecteurenergie-nb_trans+1);
    allocate_matrix2d(Utility,reg,(nb_secteur_conso+2));
    allocate_matrix2d(marketshareTI,reg,nb_trans);
    allocate_matrix3d(pArmCI,sec,sec,reg);

    /*matrices parametres*/

    alphaCompositeauto = (double *) malloc(sizeof(double) * reg);
    pkmautomobileref = (double *) malloc(sizeof(double) * reg);
    weight_regional_tax = (double *) malloc(sizeof(double) * reg);
    alphaEtauto = (double *) malloc(sizeof(double) * reg);
    alphaelecauto = (double *) malloc(sizeof(double) * reg);
    alphaEtm2 = (double *) malloc(sizeof(double) * reg);
    stockbatiment = (double *) malloc(sizeof(double) * reg);
    Tautomobile  = (double *) malloc(sizeof(double) * reg);
    Tdisp  = (double *) malloc(sizeof(double) * reg);
    TNMref  = (double *) malloc(sizeof(double) * reg);
    toair  = (double *) malloc(sizeof(double) * reg);
    DFair_exo  = (double *) malloc(sizeof(double) * reg);
    toautomobile  = (double *) malloc(sizeof(double) * reg);
    toNM  = (double *) malloc(sizeof(double) * reg);
    toOT  = (double *) malloc(sizeof(double) * reg);
    alphaelecm2 = (double *) malloc(sizeof(double) * reg);
    alphaCoalm2 = (double *) malloc(sizeof(double) * reg);
    alphaair = (double *) malloc(sizeof(double) * reg);
    ptc = (double *) malloc(sizeof(double) * reg);
    a4_mult_oil = (double *) malloc(sizeof(double) * reg);
    a3_mult_oil = (double *) malloc(sizeof(double) * reg);
    a2_mult_oil = (double *) malloc(sizeof(double) * reg);
    a1_mult_oil = (double *) malloc(sizeof(double) * reg);
    a0_mult_oil = (double *) malloc(sizeof(double) * reg);
    a4_mult_gaz = (double *) malloc(sizeof(double) * reg);
    a3_mult_gaz = (double *) malloc(sizeof(double) * reg);
    a2_mult_gaz = (double *) malloc(sizeof(double) * reg);
    a1_mult_gaz = (double *) malloc(sizeof(double) * reg);
    a0_mult_gaz = (double *) malloc(sizeof(double) * reg);
    a4_mult_coal = (double *) malloc(sizeof(double) * reg);
    a3_mult_coal = (double *) malloc(sizeof(double) * reg);
    a2_mult_coal = (double *) malloc(sizeof(double) * reg);
    a1_mult_coal = (double *) malloc(sizeof(double) * reg);
    a0_mult_coal = (double *) malloc(sizeof(double) * reg);
    index_test_temp = (double *) malloc(sizeof(double) * reg);
    alphaOT = (double *) malloc(sizeof(double) * reg);
    bnair = (double *) malloc(sizeof(double) * reg);
    bnautomobile = (double *) malloc(sizeof(double) * reg);
    bnNM = (double *) malloc(sizeof(double) * reg);
    bnOT= (double *) malloc(sizeof(double) * reg);
    alphaGazm2 = (double *) malloc(sizeof(double) * reg);
    Rdisp = (double *) malloc(sizeof(double) * reg);
    L = (double *) malloc(sizeof(double) * reg);
    coef_Q_CO2_Et_prod = (double *) malloc(sizeof(double) * reg);
    QuotasRevenue = (double *) malloc(sizeof(double) * reg);
    aw = (double *) malloc(sizeof(double) * reg);
    bw = (double *) malloc(sizeof(double) * reg);
    cw = (double *) malloc(sizeof(double) * reg);
    divi = (double *) malloc(sizeof(double) * reg);
    partExpK = (double *) malloc(sizeof(double) * reg);
    partImpK = (double *) malloc(sizeof(double) * reg);
    IR = (double *) malloc(sizeof(double) * reg);
    pindref = (double *) malloc(sizeof(double) * reg);
    sigmatrans = (double *) malloc(sizeof(double) * reg);
    xsiT = (double *) malloc(sizeof(double) * reg);
    weightEt_new = (double *) malloc(sizeof(double) * reg);
    wpEnerref  = (double *) malloc(sizeof(double) * nbsecteurenergie);

    eta  = (double *) malloc(sizeof(double) * (sec-nbsecteurenergie));

    etamarketshareener  = (double *) malloc(sizeof(double) * nbsecteurenergie);

    partTIref  = (double *) malloc(sizeof(double) * nb_trans);

    taxMKT = (double *) malloc(sizeof(double) * nbMKT);
    CO2_obj_MKTparam = (double *)  malloc(sizeof(double) * nbMKT);
    CO2_untaxed = (double *)  malloc(sizeof(double) * reg);
    areEmisConstparam = (double *) malloc(sizeof(double) * nbMKT);
    verbose = (double *) malloc(sizeof(double) * 1);
    shareBiomassTaxElec = (double *) malloc(sizeof(double) * 1);
    is_taxexo_MKTparam = (double *) calloc(sizeof(double) , nbMKT);
    allocate_matrix2d(whichMKT_reg_use, reg, nb_use);

    allocate_matrix2d(alpha_partDF,reg,nbsecteurenergie);
    allocate_matrix2d(itgbl_cost_DFdom,reg,nbsecteurenergie);
    allocate_matrix2d(itgbl_cost_DGdom,reg,nbsecteurenergie);
    allocate_matrix2d(itgbl_cost_DIdom,reg,nbsecteurenergie);
    allocate_matrix2d(itgbl_cost_DFimp,reg,nbsecteurenergie);
    allocate_matrix2d(itgbl_cost_DGimp,reg,nbsecteurenergie);
    allocate_matrix2d(itgbl_cost_DIimp,reg,nbsecteurenergie);
    allocate_matrix2d(p_stock,reg,nbsecteurenergie);
    allocate_matrix2d(bmarketshareener,reg,nbsecteurenergie);
    allocate_matrix2d(alpha_partDI,reg,nbsecteurenergie);
    allocate_matrix2d(alpha_partDG,reg,nbsecteurenergie);

    allocate_matrix2d(atrans,reg,nb_trans);
    allocate_matrix2d(btrans,reg,nb_trans);
    allocate_matrix2d(Captransport,reg,nb_trans);
    allocate_matrix2d(ktrans,reg,nb_trans);
    allocate_matrix2d(weightTI,reg,nb_trans);

    allocate_matrix2d(betatrans,reg,(nb_trans+1));
    allocate_matrix2d(weight,reg,(sec-nbsecteurenergie));
    allocate_matrix2d(bDF,reg,(sec-nbsecteurenergie));
    allocate_matrix2d(bDG,reg,(sec-nbsecteurenergie));
    allocate_matrix2d(bDI,reg,(sec-nbsecteurenergie));
    allocate_matrix2d(etaDF,reg,(sec-nbsecteurenergie));
    allocate_matrix2d(etaDG,reg,(sec-nbsecteurenergie));
    allocate_matrix2d(etaDI,reg,(sec-nbsecteurenergie));

    allocate_matrix2d(Conso,reg,nb_secteur_conso);

    allocate_matrix3d(bCI,sec-nbsecteurenergie,sec,reg);
    allocate_matrix3d(CI,sec,sec,reg);
    allocate_matrix3d(etaCI,sec-nbsecteurenergie,sec,reg);
    allocate_matrix3d(itgbl_cost_CIdom,nbsecteurenergie,sec,reg);
    allocate_matrix3d(itgbl_cost_CIimp,nbsecteurenergie,sec,reg);
    allocate_matrix3d(coef_Q_CO2_CI,sec,sec,reg);
    allocate_matrix3d(taxCO2_CI,sec,sec,reg);
    allocate_matrix3d(partDomCIref,sec,sec,reg);
    allocate_matrix3d(partDomCI_stock,sec,sec,reg);
    allocate_matrix3d(partDomCI_min,sec,sec,reg);
    allocate_matrix3d(taxCIdom,sec,sec,reg);
    allocate_matrix3d(taxCIimp,sec,sec,reg);
    allocate_matrix3d(alpha_partCI,nbsecteurenergie,sec,reg);
    allocate_matrix3d(partDomCI,sec,sec,reg);
    allocate_matrix3d(partImpCI,sec,sec,reg);

    allocate_matrix2d(A,reg,sec);
    allocate_matrix2d(A_CI,reg,sec);

    allocate_matrix2d(aRD,reg,sec);
    allocate_matrix2d(bRD,reg,sec);
    allocate_matrix2d(cRD,reg,sec);
    allocate_matrix2d(DG,reg,sec);
    allocate_matrix2d(DIinfra,reg,sec);
    allocate_matrix2d(DIprod,reg,sec);
    allocate_matrix2d(DFref,reg,sec);
    allocate_matrix2d(pArmDFref,reg,sec);
    allocate_matrix2d(bn,reg,sec);
    allocate_matrix2d(Cap,reg,sec);
    allocate_matrix2d(coef_Q_CO2_DF,reg,sec);
    allocate_matrix2d(coef_Q_CO2_DG,reg,sec);
    allocate_matrix2d(coef_Q_CO2_DI,reg,sec);
    allocate_matrix2d(wref,reg,sec);
    allocate_matrix2d(xtax,reg,sec);
    allocate_matrix2d(xtaxref,reg,sec);
    allocate_matrix2d(lll,reg,sec);
    allocate_matrix2d(markup,reg,sec);
    allocate_matrix2d(pref,reg,sec);
    allocate_matrix2d(markupref,reg,sec);
    allocate_matrix2d(markup_lim_oil,reg,sec);
    allocate_matrix2d(mtax,reg,sec);
    allocate_matrix2d(nit,reg,sec);
    allocate_matrix2d(non_energ_sec,reg,sec);
    allocate_matrix2d(pArmDG,reg,sec);
    allocate_matrix2d(pArmDF,reg,sec);
    allocate_matrix2d(pArmDI,reg,sec);
    allocate_matrix2d(energ_sec,reg,sec);
    allocate_matrix2d(partDomDFref,reg,sec);
    allocate_matrix2d(partDomDGref,reg,sec);
    allocate_matrix2d(partDomDIref,reg,sec);
    allocate_matrix2d(partDomDF_stock,reg,sec);
    allocate_matrix2d(partDomDF_min,reg,sec);
    allocate_matrix2d(partDomDG_stock,reg,sec);
    allocate_matrix2d(partDomDI_stock,reg,sec);
    allocate_matrix2d(qtax,reg,sec);
    allocate_matrix2d(sigma,reg,sec);
    allocate_matrix2d(Ttax,reg,sec);
    allocate_matrix2d(taxCO2_DF,reg,sec);
    allocate_matrix2d(taxCO2_DG,reg,sec);
    allocate_matrix2d(taxCO2_DI,reg,sec);
    allocate_matrix2d(taxDFdom,reg,sec);
    allocate_matrix2d(taxDFimp,reg,sec);
    allocate_matrix2d(taxDGdom,reg,sec);
    allocate_matrix2d(taxDGimp,reg,sec);
    allocate_matrix2d(taxDIdom,reg,sec);
    allocate_matrix2d(taxDIimp,reg,sec);

    return 0;
}                                                                                               

int import_parameters_fixed_scilab2C(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt opt, int nout, scilabVar* out)
{
    int m,n,lp;
    int k,j;

    // Get indexes from scialb before memory allocation
    assign_fromScilabVal_scalar_int( env, "reg",&reg);
    //	printf("   REGG %s %i\n", "reg", reg);
    assign_fromScilabVal_scalar_int( env, "sec",&sec);
    assign_fromScilabVal_scalar_int( env, "nb_secteur_conso",&nb_secteur_conso);
    assign_fromScilabVal_scalar_int( env, "indice_energiefossile1",&indice_energiefossile1);
    assign_fromScilabVal_scalar_int( env, "indice_energiefossile2",&indice_energiefossile2);
    assign_fromScilabVal_scalar_int( env, "indice_construction",&indice_construction);
    assign_fromScilabVal_scalar_int( env, "nbsecteurenergie",&nbsecteurenergie);
    assign_fromScilabVal_scalar_int( env, "indice_composite",&indice_composite);
    assign_fromScilabVal_scalar_int( env, "indice_mer",&indice_mer);
    assign_fromScilabVal_scalar_int( env, "indice_air",&indice_air);
    assign_fromScilabVal_scalar_int( env, "indice_OT",&indice_OT);
    assign_fromScilabVal_scalar_int( env, "indice_Et",&indice_Et);
    assign_fromScilabVal_scalar_int( env, "indice_elec",&indice_elec);
    assign_fromScilabVal_scalar_int( env, "indice_coal",&indice_coal);
    assign_fromScilabVal_scalar_int( env, "indice_oil",&indice_oil);
    assign_fromScilabVal_scalar_int( env, "indice_gas",&indice_gas);
    assign_fromScilabVal_scalar_int( env, "nb_trans",&nb_trans);
    assign_fromScilabVal_scalar_int( env, "indice_transport_1",&indice_transport_1);
    assign_fromScilabVal_scalar_int( env, "indice_transport_2",&indice_transport_2);
    assign_fromScilabVal_scalar_int( env, "indice_agriculture",&indice_agriculture);
    assign_fromScilabVal_scalar_int( env, "nb_sectors_industry",&nb_sectors_industry);
    assign_fromScilabVal_scalar_int( env, "nbsecteurcomposite",&nbsecteurcomposite);
    assign_fromScilabVal_scalar_int( env, "nb_secteur_utile",&nb_secteur_utile);
    assign_fromScilabVal_scalar_int( env, "nbMKT",&nbMKT);
    assign_fromScilabVal_scalar_int( env, "nb_use",&nb_use);
    assign_fromScilabVal_scalar_int( env, "iu_df",&iu_df);
    assign_fromScilabVal_scalar_int( env, "iu_dg",&iu_dg);
    assign_fromScilabVal_scalar_int( env, "iu_di",&iu_di);
    assign_fromScilabVal_scalar_int( env, "new_Et_msh_computation",&new_Et_msh_computation);
    assign_fromScilabVal_scalar_int( env, "exo_pkmair_scenario",&exo_pkmair_scenario);

    nX = reg*nb_secteur_conso+5*reg+3*reg*sec+5;

    // Memory Allocation
    initial_memory_allocation();

    // Assign fixed parameters
    assign_fromScilabVal_matrix_double( env, "DIprod",DIprod);
    assign_fromScilabVal_matrix_double( env,"DFref",DFref);
    assign_fromScilabVal_matrix_double( env,"pArmDFref",pArmDFref);
    assign_fromScilabVal_matrix_double( env,"xtaxref",xtaxref);
    assign_fromScilabVal_matrix_double( env,"wref",wref);
    assign_fromScilabVal_matrix_double( env,"pref",pref);
    assign_fromScilabVal_matrix_double( env,"markupref",markupref);
    assign_fromScilabVal_vector_int( env,"indice_industries",indice_industries);
    assign_fromScilabVal_vector_double( env,"pkmautomobileref",pkmautomobileref);
    assign_fromScilabVal_vector_double( env,"TNMref",TNMref);
    assign_fromScilabVal_vector_double( env,"wpEnerref",wpEnerref);
    assign_fromScilabVal_vector_double( env,"partTIref",partTIref);
    assign_fromScilabVal_vector_double( env,"pindref",pindref);

    return STATUS_OK;
}                                                                                               

int import_parameters_dynamic_scilab2C(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt opt, int nout, scilabVar* out)
{        
    int m,n,lp;
    int k,j;

    assign_fromScilabVal_vector_double( env,"partTIref",partTIref);
    assign_fromScilabVal_matrix_double( env,"DIprod",DIprod);
    assign_fromScilabVal_vector_double( env,"pindref",pindref);
    assign_fromScilabVal_scalar_double( env, "etaTI",&etaTI);
    assign_fromScilabVal_scalar_double( env, "etaEtnew",&etaEtnew);
    // 	    printf("  etaEtnew   %s %.2f \n", "etaEtnew", etaEtnew);
    assign_fromScilabVal_scalar_double( env, "inertia_share",&inertia_share);
    /*pour les matrix reg, sec*/
    assign_fromScilabVal_matrix_double( env,"A",A);
    assign_fromScilabVal_matrix_double( env,"A_CI",A_CI);
    assign_fromScilabVal_matrix_double( env,"aRD",aRD);
    assign_fromScilabVal_matrix_double( env,"bRD",bRD);
    assign_fromScilabVal_matrix_double( env,"cRD",cRD);
    assign_fromScilabVal_matrix_double( env,"DG",DG);
    assign_fromScilabVal_matrix_double( env,"DIinfra",DIinfra);
    assign_fromScilabVal_matrix_double( env,"bn",bn);
    assign_fromScilabVal_matrix_double( env,"Cap",Cap);
    assign_fromScilabVal_matrix_double( env,"coef_Q_CO2_DF",coef_Q_CO2_DF);
    assign_fromScilabVal_matrix_double( env,"coef_Q_CO2_DG",coef_Q_CO2_DG);
    assign_fromScilabVal_matrix_double( env,"coef_Q_CO2_DI",coef_Q_CO2_DI);
    // assign_fromScilabVal_matrix_double( env,"p",p);
    // assign_fromScilabVal_matrix_double( env,"w",w);
    assign_fromScilabVal_matrix_double( env,"Ttax",Ttax);

    assign_fromScilabVal_matrix_double( env,"xtax",xtax);

    assign_fromScilabVal_matrix_double( env,"l",lll);
    assign_fromScilabVal_matrix_double( env,"markup",markup);

    assign_fromScilabVal_matrix_double( env,"partDomDGref",partDomDGref);
    assign_fromScilabVal_matrix_double( env,"partDomDIref",partDomDIref);
    assign_fromScilabVal_matrix_double( env,"partDomDFref",partDomDFref);

    assign_fromScilabVal_matrix_double( env,"markup_lim_oil",markup_lim_oil);
    assign_fromScilabVal_matrix_double( env,"mtax",mtax);
    assign_fromScilabVal_matrix_double( env,"energ_sec",energ_sec);
    assign_fromScilabVal_matrix_double( env,"nit",nit);
    assign_fromScilabVal_matrix_double( env,"non_energ_sec",non_energ_sec);
    assign_fromScilabVal_matrix_double( env,"partDomDF_stock",partDomDF_stock);
    assign_fromScilabVal_matrix_double( env,"partDomDF_min",partDomDF_min);
    assign_fromScilabVal_matrix_double( env,"partDomDG_stock",partDomDG_stock);
    assign_fromScilabVal_matrix_double( env,"partDomDI_stock",partDomDI_stock);
    assign_fromScilabVal_matrix_double( env,"qtax",qtax);
    assign_fromScilabVal_matrix_double( env,"sigma",sigma);
    assign_fromScilabVal_matrix_double( env,"taxCO2_DF",taxCO2_DF);
    assign_fromScilabVal_matrix_double( env,"taxCO2_DG",taxCO2_DG);
    assign_fromScilabVal_matrix_double( env,"taxCO2_DI",taxCO2_DI);
    assign_fromScilabVal_matrix_double( env,"taxDFdom",taxDFdom);
    assign_fromScilabVal_matrix_double( env,"taxDFimp",taxDFimp);
    assign_fromScilabVal_matrix_double( env,"taxDGdom",taxDGdom);
    assign_fromScilabVal_matrix_double( env,"taxDGimp",taxDGimp);
    assign_fromScilabVal_matrix_double( env,"taxDIdom",taxDIdom);
    assign_fromScilabVal_matrix_double( env,"taxDIimp",taxDIimp);

    /*pour les matrix reg, 1*/
    assign_fromScilabVal_vector_double( env,"alphaCompositeauto",alphaCompositeauto);
    assign_fromScilabVal_vector_double( env,"weight_regional_tax",weight_regional_tax);

    assign_fromScilabVal_vector_double( env,"alphaEtauto",alphaEtauto);
    assign_fromScilabVal_vector_double( env,"alphaelecauto",alphaelecauto);
    assign_fromScilabVal_vector_double( env,"alphaEtm2",alphaEtm2);
    assign_fromScilabVal_vector_double( env,"stockbatiment",stockbatiment);
    assign_fromScilabVal_vector_double( env,"alphaelecm2",alphaelecm2);
    assign_fromScilabVal_vector_double( env,"alphaCoalm2",alphaCoalm2);
    assign_fromScilabVal_vector_double( env,"alphaGazm2",alphaGazm2);
    assign_fromScilabVal_vector_double( env,"L",L);
    assign_fromScilabVal_vector_double( env,"coef_Q_CO2_Et_prod",coef_Q_CO2_Et_prod);
    assign_fromScilabVal_vector_double( env,"QuotasRevenue",QuotasRevenue);
    assign_fromScilabVal_vector_double( env,"alphaair",alphaair);
    assign_fromScilabVal_vector_double( env,"ptc",ptc);
    assign_fromScilabVal_vector_double( env,"a4_mult_oil",a4_mult_oil);
    assign_fromScilabVal_vector_double( env,"a3_mult_oil",a3_mult_oil);
    assign_fromScilabVal_vector_double( env,"a2_mult_oil",a2_mult_oil);
    assign_fromScilabVal_vector_double( env,"a1_mult_oil",a1_mult_oil);
    assign_fromScilabVal_vector_double( env,"a0_mult_oil",a0_mult_oil);
    assign_fromScilabVal_vector_double( env,"a4_mult_gaz",a4_mult_gaz);
    assign_fromScilabVal_vector_double( env,"a3_mult_gaz",a3_mult_gaz);
    assign_fromScilabVal_vector_double( env,"a2_mult_gaz",a2_mult_gaz);
    assign_fromScilabVal_vector_double( env,"a1_mult_gaz",a1_mult_gaz);
    assign_fromScilabVal_vector_double( env,"a0_mult_gaz",a0_mult_gaz);
    assign_fromScilabVal_vector_double( env,"a4_mult_coal",a4_mult_coal);
    assign_fromScilabVal_vector_double( env,"a3_mult_coal",a3_mult_coal);
    assign_fromScilabVal_vector_double( env,"a2_mult_coal",a2_mult_coal);
    assign_fromScilabVal_vector_double( env,"a1_mult_coal",a1_mult_coal);
    assign_fromScilabVal_vector_double( env,"a0_mult_coal",a0_mult_coal);
    assign_fromScilabVal_vector_double( env,"alphaOT",alphaOT);
    assign_fromScilabVal_vector_double( env,"Rdisp",Rdisp);
    assign_fromScilabVal_vector_double( env,"bnair",bnair);
    assign_fromScilabVal_vector_double( env,"bnautomobile",bnautomobile);
    assign_fromScilabVal_vector_double( env,"bnNM",bnNM);
    assign_fromScilabVal_vector_double( env,"bnOT",bnOT);
    assign_fromScilabVal_vector_double( env,"Tautomobile",Tautomobile);
    assign_fromScilabVal_vector_double( env,"Tdisp",Tdisp);

    assign_fromScilabVal_vector_double( env,"toair",toair);
    assign_fromScilabVal_vector_double( env,"DFair_exo",DFair_exo);
    assign_fromScilabVal_vector_double( env,"toautomobile",toautomobile);
    assign_fromScilabVal_vector_double( env,"toNM",toNM);
    assign_fromScilabVal_vector_double( env,"toOT",toOT);

    assign_fromScilabVal_vector_double( env,"eta",eta);
    assign_fromScilabVal_vector_double( env,"etamarketshareener",etamarketshareener);

    assign_fromScilabVal_vector_double( env,"aw",aw);
    assign_fromScilabVal_vector_double( env,"bw",bw);
    assign_fromScilabVal_vector_double( env,"cw",cw);
    assign_fromScilabVal_vector_double( env,"div",divi);
    assign_fromScilabVal_vector_double( env,"partExpK",partExpK);
    assign_fromScilabVal_vector_double( env,"partImpK",partImpK);
    assign_fromScilabVal_vector_double( env,"IR",IR);

    assign_fromScilabVal_vector_double( env,"sigmatrans",sigmatrans);
    assign_fromScilabVal_vector_double( env,"xsiT",xsiT);
    assign_fromScilabVal_vector_double( env,"weightEt_new",weightEt_new);
    // 	    printf("  weightEt_new   %s %.2f \n", "weightEt_new", weightEt_new[11]);

    /*pour les matrix 2d autres que reg, sec*/
    assign_fromScilabVal_matrix_double( env,"alpha_partDF",alpha_partDF);
    assign_fromScilabVal_matrix_double( env,"alpha_partDG",alpha_partDG);
    assign_fromScilabVal_matrix_double( env,"alpha_partDI",alpha_partDI);
    assign_fromScilabVal_matrix_double( env,"itgbl_cost_DFdom",itgbl_cost_DFdom);
    assign_fromScilabVal_matrix_double( env,"itgbl_cost_DGdom",itgbl_cost_DGdom);
    assign_fromScilabVal_matrix_double( env,"itgbl_cost_DIdom",itgbl_cost_DIdom);
    assign_fromScilabVal_matrix_double( env,"itgbl_cost_DFimp",itgbl_cost_DFimp);
    assign_fromScilabVal_matrix_double( env,"itgbl_cost_DGimp",itgbl_cost_DGimp);
    assign_fromScilabVal_matrix_double( env,"itgbl_cost_DIimp",itgbl_cost_DIimp);
    assign_fromScilabVal_matrix_double( env,"p_stock",p_stock);
    // 	    printf("  P_STOCK   %s %.2f \n", "p_stock", p_stock[11][2]);
    assign_fromScilabVal_matrix_double( env,"bmarketshareener",bmarketshareener);

    assign_fromScilabVal_matrix_double( env,"atrans",atrans);
    assign_fromScilabVal_matrix_double( env,"btrans",btrans);
    assign_fromScilabVal_matrix_double( env,"Captransport",Captransport);
    assign_fromScilabVal_matrix_double( env,"ktrans",ktrans);
    assign_fromScilabVal_matrix_double( env,"weightTI",weightTI);
    assign_fromScilabVal_matrix_double( env,"xsi",xsi);
    assign_fromScilabVal_matrix_double( env,"weight",weight);
    assign_fromScilabVal_matrix_double( env,"bDF",bDF);
    assign_fromScilabVal_matrix_double( env,"bDG",bDG);
    assign_fromScilabVal_matrix_double( env,"bDI",bDI);
    assign_fromScilabVal_matrix_double( env,"etaDF",etaDF);
    assign_fromScilabVal_matrix_double( env,"etaDG",etaDG);
    assign_fromScilabVal_matrix_double( env,"etaDI",etaDI);
    assign_fromScilabVal_matrix_double( env,"betatrans",betatrans);
    assign_fromScilabVal_matrix_double( env,"Conso",Conso);

    assign_fromScilabVal_hypermatrix_double( env, "bCI", bCI);
    assign_fromScilabVal_hypermatrix_double( env, "etaCI", etaCI);
    assign_fromScilabVal_hypermatrix_double( env, "itgbl_cost_CIdom", itgbl_cost_CIdom);
    assign_fromScilabVal_hypermatrix_double( env, "itgbl_cost_CIimp", itgbl_cost_CIimp);
    assign_fromScilabVal_hypermatrix_double( env, "partDomCIref", partDomCIref);
    assign_fromScilabVal_hypermatrix_double( env, "partDomCI_stock", partDomCI_stock);
    assign_fromScilabVal_hypermatrix_double( env, "partDomCI_min", partDomCI_min);
    assign_fromScilabVal_hypermatrix_double( env, "taxCIdom", taxCIdom);
    assign_fromScilabVal_hypermatrix_double( env, "taxCIimp", taxCIimp);
    assign_fromScilabVal_hypermatrix_double( env, "alpha_partCI", alpha_partCI);
    assign_fromScilabVal_hypermatrix_double( env, "taxCO2_CI", taxCO2_CI);
    assign_fromScilabVal_hypermatrix_double( env, "coef_Q_CO2_CI", coef_Q_CO2_CI);
    assign_fromScilabVal_hypermatrix_double( env, "CI", CI);
    // 	    printf("  CI   %s %.2f \n", "CI", CI[5][4][11]);

    assign_fromScilabVal_vector_double( env,"taxMKT",taxMKT);
    assign_fromScilabVal_matrix_double( env,"whichMKT_reg_use",whichMKT_reg_use);
    assign_fromScilabVal_vector_double( env,"CO2_obj_MKTparam",CO2_obj_MKTparam);
    assign_fromScilabVal_vector_double( env,"CO2_untaxed",CO2_untaxed);
    assign_fromScilabVal_vector_double( env,"areEmisConstparam",areEmisConstparam);
    assign_fromScilabVal_vector_double( env,"verbose",verbose);
    assign_fromScilabVal_vector_double( env,"shareBiomassTaxElec",shareBiomassTaxElec);
    assign_fromScilabVal_vector_double( env,"is_taxexo_MKTparam",is_taxexo_MKTparam);
    return STATUS_OK;
}

/*function [y] = economy(x);*/
void economyC(int *n, double x[],double v[],int *iflag)
{
    int k, j, l, i;
    int m = 0;
    int m_out;
    double sum, sum1, sum2, sum3, sum4;

    //ne pas "optimiser" l'ordre des boucles, il faut que ce soit dans le bon ordre pour scilab!
    for (j=0; j<nb_secteur_conso; j++)
    {
        for (k=0; k<reg; k++)
        {
            Consoloc[k][j] = x[m];
            m++;
        }
    }

    /*    wr_sci(Consoloc,"sci_rc",sci_rc,reg,nb_secteur_conso); */
    for (k=0; k<reg; k++)
    {
        Tautomobileloc[k] = x[m];
        m++;
    }

    for (k=0; k<reg; k++)
    {
        lambdaloc[k] = x[m];
        m++;
    }

    for (k=0; k<reg; k++)
    {
        muloc[k] = x[m];
        m++;
    }

    //ne pas "optimiser" l'ordre des boucles, il faut que ce soit dans le bon ordre pour scilab!
    for (j=0; j<sec; j++)
    {
        for (k=0; k<reg; k++)
        {
            ploc[k][j] = x[m];
            m++;
        }
    }

    for (j=0; j<sec; j++)
    {
        for (k=0; k<reg; k++)
        {
            wloc[k][j] = x[m];
            m++;
        }
    }

    for (j=0; j<sec; j++)
    {
        for (k=0; k<reg; k++)
        {
            Qloc[k][j] = x[m];
            m++;
        }
    }
    for (k=0; k<reg; k++)
    {
        Rdisploc[k] = x[m];
        m++;
    }

    for (k=0; k<reg; k++)
    {
        TNMloc[k] = x[m];
        m++;
    }

    for (j=0; j<nbsecteurenergie; j++)
    {
        wpEnerloc[j] = x[m];
        m++;
    }

    //rienloc = x[m]; penser a rendre m plus petit

    /*    m++;*/
    /*a la fin verifier que *n vaut comme m*/

    //if (*n != m+1)
    //printf ("Scilab passed %d, put in vector: %d\n", *n ,m+1);

    fill_matrix(Utility,reg,(nb_secteur_conso+2),0);
    fill_vector(Household_budget,reg,0);
    fill_vector(Time_budget,reg,0);
    fill_matrix(Sector_budget,reg,sec,0);
    fill_matrix(Market_clear,reg,sec,0);
    fill_matrix(Wages,reg,sec,0);
    fill_vector(Energy_world_prices,nbsecteurenergie,0);
    fill_vector(State_budget,reg,0);

    /* 
       DFloc=DFinduite(Consoloc,Tautomobileloc);
       */

    /* FIXME que fait ce code ?? Ne faudrait-il pas faire autrement en distinguant
       entree et sortie, l'entree n'etant pas modifiee ? 
       */
    for (k=0; k<reg; k++)
    {
        if (Rdisploc[k] <= 0)  
            Rdisploc[k]=0.00001;
        if (Tautomobileloc[k] <= bnautomobile[k]) 
            {
            Tautomobileloc[k]=bnautomobile[k] + 0.0000001;
            // sciprint("Tautomobileloc[%i]=bn ",k+1);
            }
        if (TNMloc[k] <= bnNM[k]) 
            {
            TNMloc[k] = bnNM[k] + 0.0000001;
            // sciprint("TNM[%i] = bn, ",k+1);
            }
        for (j=0; j<sec; j++)
        {
            if (Qloc[k][j]<= 0) 
                Qloc[k][j] = 0.000001;
            if (wloc[k][j]<= 0) 
                wloc[k][j] = 0.0000001;

            if (ploc[k][j]<= 0) 
                ploc[k][j] = 0.0000001;
        }
        for (j=0; j<2; j++)
            /*eventuellement changer les indices de 1 a 2 par des param*/
            /* FIXME dans le code originel il y a des indices */

            if (Consoloc[k][indice_composite-5-1]<=bn[k][indice_composite-1]) 
                Consoloc[k][indice_composite-5-1] =bn[k][indice_composite-1] + 0.000001;
        if (Consoloc[k][indice_construction-5-1]<=bn[k][indice_construction-1]) 
            Consoloc[k][indice_construction-5-1] =bn[k][indice_construction-1] + 0.000001;
        if (Consoloc[k][indice_agriculture-5-1]<=bn[k][indice_agriculture-1]) 
            Consoloc[k][indice_agriculture-5-1] =bn[k][indice_agriculture-1] + 0.000001;
		int i;
			for (i=0; i<nb_sectors_industry; i++) /*ToBeChecked: It seems that indices start to 0 in C?*/
			{
				if (Consoloc[k][indice_industries[i]-5-1]<=bn[k][indice_industries[i]-1]) 
				Consoloc[k][indice_industries[i]-5-1] =bn[k][indice_industries[i]-1] + 0.000001;
			}
        if (Consoloc[k][indice_air-5-1]<=0) 
            Consoloc[k][indice_air-5-1] = 0.000001;
        if (Consoloc[k][indice_mer-5-1]<=bn[k][indice_mer-1]) 
            Consoloc[k][indice_mer-5-1] =bn[k][indice_mer-1] + 0.000001;
        if (Consoloc[k][indice_OT-5-1]<=bnOT[k]) 
            Consoloc[k][indice_OT-5-1] =bnOT[k] + 0.000001;

    }
    if (exo_pkmair_scenario >0)
    {
        for (k=0; k<reg; k++)
        {
            Consoloc[k][indice_air-nbsecteurenergie-1] = DFair_exo[k];
        }
    }
    for (j=0; j<nbsecteurenergie; j++)
    {
        if (wpEnerloc[j]<=0) 
            wpEnerloc[j] = 0.0000001;
    }

    for (k=0; k<reg; k++)
    {
        for (j=indice_energiefossile1-1; j<indice_energiefossile2; j++)
        {
            DFloc[k][j] = DFref[k][j] ;
        }

        DFloc[k][indice_construction-1] = Consoloc[k][indice_construction-nbsecteurenergie-1] ;

        DFloc[k][indice_composite-1] = 
            Consoloc[k][indice_composite-nbsecteurenergie-1] +
            Tautomobileloc[k]*alphaCompositeauto[k]*pkmautomobileref[k]/100;
        DFloc[k][indice_mer-1] = Consoloc[k][indice_mer-nbsecteurenergie-1] ;
        DFloc[k][indice_air-1] = Consoloc[k][indice_air-nbsecteurenergie-1] ;
        DFloc[k][indice_OT-1] = Consoloc[k][indice_OT-nbsecteurenergie-1] ;
        DFloc[k][indice_agriculture-1] = Consoloc[k][indice_agriculture-nbsecteurenergie-1] ;
		int i;
		for (i=0; i<nb_sectors_industry; i++)
		{
        DFloc[k][indice_industries[i]-1] = Consoloc[k][indice_industries[i]-nbsecteurenergie-1] ;
        }
		DFloc[k][indice_Et-1] = Tautomobileloc[k]*alphaEtauto[k]*pkmautomobileref[k]/100
            + alphaEtm2[k]*stockbatiment[k] ;


        DFloc[k][indice_elec-1] = alphaelecm2[k]*stockbatiment[k] + Tautomobileloc[k]*alphaelecauto[k]*pkmautomobileref[k]/100;

        DFloc[k][indice_coal-1] = alphaCoalm2[k]*stockbatiment[k] ;

        DFloc[k][indice_gas-1] = alphaGazm2[k]*stockbatiment[k] ;
    }

    /*    wr_sci_rs(DFloc); */
    /*    wr_sci_rs(DFref);*/

    /*
       zloc=1-(sum(A.*l.*Qloc,"c")./L);
       */

    for (k=0; k<reg; k++)
    {
        sum=0;
        for (j=0; j<sec; j++) 
        {
            sum += A[k][j]*lll[k][j]*Qloc[k][j];
        }
        zloc[k] = 1 - (sum/L[k]);
    }

    /*    
          wr_sci_vec(zloc,"sci_r",sci_r,reg); 
          */

    /*arrete ici pour verifs.*/

    /*
       numloc=ploc(:,indice_composite)*ones(1,sec);
       */

    /* FIXME au final numlock = ones(reg,sec) */
    for (k=0; k<reg; k++)
    {
        for (j=0; j<sec; j++)
        {
            numloc[k][j]=ploc[1-1][indice_composite - 1];
        }
    }


    /*    wr_sci_vec(Rdisploc,"sci_r",sci_r,reg); */

    /*            printf("%15.10g ", marketshare[k][j+nbsecteurenergie]);*/
    /*            printf("%15.10g ", reg);*/
    /*    for (j=0;j<12;j++)
          index_test_temp[j]=reg; */
    /*wr_sci_vec(index_test_temp,"sci_r",sci_r,reg); */

    for (k=0; k<reg; k++)
    {
        for (j=0; j<sec; j++)
        {
            FCCtemp[k][j] = aRD[k][j] + bRD[k][j] * tanh(cRD[k][j] * (Qloc[k][j]*A[k][j]/Cap[k][j] - 1));
        }
    }
    /*    
          wr_sci_rs(FCCtemp); 
          */
    /*wr_sci(Consoloc,"sci_rc",sci_rc,reg,nb_secteur_conso);*/
    for (k=0; k<reg; k++)
    {
        for (j=0; j<sec; j++)
        {
            FCCmarkup[k][j]= 1.;
        }
    }

    for (k=0; k<reg; k++)
    {
        for (j=0; j<sec; j++)
            /*            FCCmarkup[k][j]=(markupref[k][j]+(1-markupref[k][j])/0.008*pow((Qloc[k][j]/Cap[k][j]-0.8),3))/markup[k][j];
                          FCCmarkup=((markup_lim_oil-markupref)/(1-0.8).*(Q./Cap-0.8*ones(reg,sec))+markupref)./markup; */
        {
            FCCmarkup[k][j]=((markup_lim_oil[k][j]-markupref[k][j])/(1-0.8)*(Qloc[k][j]*A[k][j]/Cap[k][j]-0.8) 

                    +markupref[k][j])/markup[k][j];
        }

    }

    for (k=0; k<reg; k++)
    {
        for (j=0; j<sec; j++)
        {
            FCCmarkup_oil[k][j]= 1;
        }

    }

    for (k=0; k<reg; k++)

    {    
        FCCmarkup_oil[k][indice_oil-1]=FCCmarkup[k][indice_oil-1];

    }
    /* ------secteurs non energetiques-----------*/

    for (j=0; j < sec - nbsecteurenergie; j++)
    {
        sum = 0;
        for (k=0; k<reg; k++)
        {
            sum += pow(weight[k][j], eta[j]) * 
                pow(ploc[k][j + nbsecteurenergie]*
                        (1+xtax[k][j + nbsecteurenergie]), 1-eta[j]);
        }
        wploc[j+nbsecteurenergie] = pow(sum, (1/(1-eta[j])));
    }

    for (j=0; j<nb_trans; j++)
    {
        sum = 0;
        for (k=0; k<reg; k++)
            sum += pow(weightTI[k][j], etaTI) *
                pow(ploc[k][j+indice_transport_1-1], (1-etaTI));
        wpTIloc[j] = pow(sum, (1/(1-etaTI)));

    }
    wpTIaggloc=0;
    for (j=0; j<nb_trans; j++)
        wpTIaggloc += (wpTIloc[j]*partTIref[j]);
    for (k=0; k<reg; k++)
    {
        for (j=0; j<sec - nbsecteurenergie; j++)
            pArmDF[k][j+nbsecteurenergie] = pow(pow(bDF[k][j],etaDF[k][j])*
                    pow((ploc[k][j+nbsecteurenergie]*
                            (1+taxDFdom[k][j+nbsecteurenergie])),(1-etaDF[k][j]))+
                    pow((1-bDF[k][j]),etaDF[k][j]) * pow(( wploc[j+nbsecteurenergie] * 
                            (1+mtax[k][j+nbsecteurenergie]) + wpTIaggloc * 
                            nit[k][j+nbsecteurenergie]) *
                        (1 + taxDFimp[k][j+nbsecteurenergie]),(1-etaDF[k][j]))    
                    ,(1/(1-etaDF[k][j])));
    }

    for (k=0; k<reg; k++)
    {
        for (j=0; j<sec - nbsecteurenergie; j++)
            pArmDG[k][j+nbsecteurenergie] = pow(pow(bDG[k][j],etaDG[k][j])*
                    pow((ploc[k][j+nbsecteurenergie]*
                            (1+taxDGdom[k][j+nbsecteurenergie])),(1-etaDG[k][j]))+
                    pow((1-bDG[k][j]),etaDG[k][j]) * pow(( wploc[j+nbsecteurenergie] * 
                            (1+mtax[k][j+nbsecteurenergie]) + wpTIaggloc * 
                            nit[k][j+nbsecteurenergie]) *
                        (1 + taxDGimp[k][j+nbsecteurenergie]),(1-etaDG[k][j]))    
                    ,(1/(1-etaDG[k][j])));

    }

    for (k=0; k<reg; k++)
    {
        for (j=0; j<sec - nbsecteurenergie; j++)
            pArmDI[k][j+nbsecteurenergie] = pow(pow(bDI[k][j],etaDI[k][j])*
                    pow((ploc[k][j+nbsecteurenergie]*
                            (1+taxDIdom[k][j+nbsecteurenergie])),(1-etaDI[k][j]))+
                    pow((1-bDI[k][j]),etaDI[k][j]) * pow(( wploc[j+nbsecteurenergie] * 
                            (1+mtax[k][j+nbsecteurenergie]) + wpTIaggloc * 
                            nit[k][j+nbsecteurenergie]) *
                        (1 + taxDIimp[k][j+nbsecteurenergie]),(1-etaDI[k][j]))    
                    ,(1/(1-etaDI[k][j])));

    }

    for (k=0; k<reg; k++)
    {
        for (j=0; j<sec - nbsecteurenergie; j++)
        {
            partDomDF[k][j+nbsecteurenergie] = 
                pow(bDF[k][j],etaDF[k][j]) * pow((pArmDF[k][j+nbsecteurenergie] 
                            /(ploc[k][j+nbsecteurenergie] * (1 + taxDFdom[k][j+nbsecteurenergie]))),
                        etaDF[k][j]);

            partImpDF[k][j+nbsecteurenergie] =
                pow((1-bDF[k][j]),etaDF[k][j]) *
                pow ((pArmDF[k][j+nbsecteurenergie] / ((wploc[j+nbsecteurenergie]
                                    * (1 + mtax[k][j+nbsecteurenergie]) +wpTIaggloc * 
                                    nit[k][j+nbsecteurenergie]) * 
                                (1 + taxDFimp[k][j+nbsecteurenergie]))),
                        etaDF[k][j]);

            partDomDG[k][j+nbsecteurenergie] = 
                pow(bDG[k][j],etaDG[k][j]) * pow((pArmDG[k][j+nbsecteurenergie] 
                            /(ploc[k][j+nbsecteurenergie] * 
                                (1 + taxDGdom[k][j+nbsecteurenergie]))),etaDG[k][j]);
            partImpDG[k][j+nbsecteurenergie] =
                pow((1-bDG[k][j]),etaDG[k][j]) *
                pow ((pArmDG[k][j+nbsecteurenergie] / ((wploc[j+nbsecteurenergie]
                                    * (1 + mtax[k][j+nbsecteurenergie]) +wpTIaggloc * 
                                    nit[k][j+nbsecteurenergie]) * 
                                (1 + taxDGimp[k][j+nbsecteurenergie]))),
                        etaDG[k][j]);

            partDomDI[k][j+nbsecteurenergie] = 
                pow(bDI[k][j],etaDI[k][j]) * pow((pArmDI[k][j+nbsecteurenergie] 
                            /(ploc[k][j+nbsecteurenergie] * 
                                (1 + taxDIdom[k][j+nbsecteurenergie]))),etaDI[k][j]);

            partImpDI[k][j+nbsecteurenergie] =
                pow((1-bDI[k][j]),etaDI[k][j]) *
                pow ((pArmDI[k][j+nbsecteurenergie] / ((wploc[j+nbsecteurenergie]
                                    * (1 + mtax[k][j+nbsecteurenergie]) +wpTIaggloc * 
                                    nit[k][j+nbsecteurenergie]) * 
                                (1 + taxDIimp[k][j+nbsecteurenergie]))),
                        etaDI[k][j]);

        }
    }

    for (k=nbsecteurenergie; k<sec; k++)
    {
        for (j=0; j<sec; j++)
        {
            for (l=0; l<reg; l++)
            {
                //le terme taxCO2_CI[k][j][l]*coef_Q_CO2_CI[k][j][l] est la pour la biomasse dans l'elec. A voir si le caractere heterogene de l'agri va poser probleme
                pArmCI[k][j][l] =
                    pow (
                            pow(
                                bCI[k-nbsecteurenergie][j][l],
                                etaCI[k-nbsecteurenergie][j][l]
                               )
                            * pow (
                                (ploc[l][k] *(1 + taxCIdom[k][j][l]))+taxCO2_CI[k][j][l]*numloc[l][k]*coef_Q_CO2_CI[k][j][l],
                                (1-etaCI[k-nbsecteurenergie][j][l])
                                )
                            + pow(
                                (1-bCI[k-nbsecteurenergie][j][l]), 
                                etaCI[k-nbsecteurenergie][j][l]
                                ) 
                            * pow(
                                (wploc[k] * (1+ mtax[l][k]) + nit [l][k] * wpTIaggloc) * (1 + taxCIimp[k][j][l])+taxCO2_CI[k][j][l]*numloc[l][k]*coef_Q_CO2_CI[k][j][l],
                                (1-etaCI[k-nbsecteurenergie][j][l]))
                            , (1/(1-etaCI[k-nbsecteurenergie][j][l]))
                        );

                // if (k==indice_agriculture-1 &&j==indice_elec-1 && !(pArmCI[k][j][l]>0) )
                // {

                // }

            }
        }
    }

    for (k=nbsecteurenergie; k<sec; k++)
    {
        for (j=0; j<sec; j++)
        {
            for (l=0; l<reg; l++)
            {
                partDomCI[k][j][l] = 
                    pow(bCI[k-nbsecteurenergie][j][l], etaCI[k-nbsecteurenergie][j][l]) 
                    * pow((pArmCI[k][j][l] / (ploc[l][k] * (1 + taxCIdom[k][j][l]))), etaCI[k-nbsecteurenergie][j][l]);

            }
        }
    }

    for (k=nbsecteurenergie; k<sec; k++)
    {
        for (j=0; j<sec; j++)
        {
            for (l=0; l<reg; l++)
            {
                partImpCI[k][j][l] = pow((1-bCI[k-nbsecteurenergie][j][l]), etaCI[k-nbsecteurenergie][j][l]) 
                    * pow((pArmCI[k][j][l] / ((wploc[k] * (1+mtax[l][k])+ 
                                        nit[l][k] * wpTIaggloc) * (1 + taxCIimp[k][j][l]))),
                            etaCI[k-nbsecteurenergie][j][l]);
            }
        }
    }

    for (j=0; j<sec - nbsecteurenergie; j++)
    {
        sum = 0;
        for (k=0; k<reg; k++)
            sum += 
                pow(weight[k][j],eta[j]) * pow((ploc[k][j+nbsecteurenergie]         
                            *(1+xtax[k][j+nbsecteurenergie])),(1-eta[j]));

        for (k=0; k<reg; k++)
        {
            marketshare[k][j+nbsecteurenergie] = 
                pow(weight[k][j],eta[j]) * pow(pow(ploc[k][j+nbsecteurenergie] * 
                            (1+xtax[k][j+nbsecteurenergie]),(1-eta[j]))/sum,
                        (eta[j]/(eta[j]-1)));
            /*            printf("%15.10g ", marketshare[k][j+nbsecteurenergie]);*/
        }
        /*      printf("\n%15.10g \n", sum);*/
    }

    for (j=0; j<nb_trans; j++)
    {
        sum = 0;
        for (k=0; k<reg; k++)
            sum += pow(weightTI[k][j],etaTI) * 
                pow(ploc[k][j+indice_transport_1-1], (1-etaTI));
        for (k=0; k<reg; k++)
            marketshareTI[k][j] = pow(weightTI[k][j], etaTI)
                * pow((pow(ploc[k][j+indice_transport_1-1], (1-etaTI))/sum),
                        (etaTI/(etaTI-1)));
    }

    /*wr_sci_rs(partDomDF);*/
    /*wr_sci_rs(nit)*/
    /*wr_sci(alpha_partDF,"sci_rc",sci_rc,reg,nb_secteur_conso);*/
    /*printf("\n%15.10g \n", wpTIaggloc);*/
    for (k=0; k<reg; k++)
    {
        for (j=0; j<nbsecteurenergie; j++)
        {

            partDomDF[k][j] = pow(ploc[k][j]*(1+taxDFdom[k][j])+
                    itgbl_cost_DFdom[k][j]*ploc[k][j]/pref[k][j],
                    alpha_partDF[k][j]) / (pow(ploc[k][j]*(1+taxDFdom[k][j])+ 
                            itgbl_cost_DFdom[k][j]*ploc[k][j]/pref[k][j],
                            alpha_partDF[k][j]) + pow((wpEnerloc[j]*(1+mtax[k][j])+
                                    wpTIaggloc*nit[k][j])*(1+taxDFimp[k][j])+itgbl_cost_DFimp[k][j]*wpEnerloc[j]/wpEnerref[j],alpha_partDF[k][j]));        

            partDomDG[k][j] = pow(((ploc[k][j]*(1+taxDGdom[k][j]))+
                        itgbl_cost_DGdom[k][j]*ploc[k][j]/pref[k][j]),
                    alpha_partDG[k][j]) / (pow(((ploc[k][j]*(1+taxDGdom[k][j]))+ 
                                itgbl_cost_DGdom[k][j]*ploc[k][j]/pref[k][j]),
                            alpha_partDG[k][j]) + pow((wpEnerloc[j]*(1+mtax[k][j])+
                                    wpTIaggloc*nit[k][j])*(1+taxDGimp[k][j])+itgbl_cost_DGimp[k][j]*wpEnerloc[j]/wpEnerref[j],alpha_partDG[k][j]));        

            partDomDI[k][j] = pow(((ploc[k][j]*(1+taxDIdom[k][j]))+
                        itgbl_cost_DIdom[k][j]*ploc[k][j]/pref[k][j]),
                    alpha_partDI[k][j]) / (pow(((ploc[k][j]*(1+taxDIdom[k][j]))+ 
                                itgbl_cost_DIdom[k][j]*ploc[k][j]/pref[k][j]),
                            alpha_partDI[k][j]) + pow((wpEnerloc[j]*(1+mtax[k][j])+
                                    wpTIaggloc*nit[k][j])*(1+taxDIimp[k][j])+itgbl_cost_DIimp[k][j]*wpEnerloc[j]/wpEnerref[j],alpha_partDI[k][j]));        
        }

    }
    /*wr_sci_rs(partDomDF)*/
    for (k=0; k<reg; k++)
    {
        mult_oil[k]=(a4_mult_oil[k]*pow(Qloc[k][indice_oil-1]*A[k][indice_oil-1]/Cap[k][indice_oil-1],4)+ a3_mult_oil[k]*pow(Qloc[k][indice_oil-1]*A[k][indice_oil-1]/Cap[k][indice_oil-1],3) +a2_mult_oil[k]*pow(Qloc[k][indice_oil-1]*A[k][indice_oil-1]/Cap[k][indice_oil-1],2)+a1_mult_oil[k]*(Qloc[k][indice_oil-1]*A[k][indice_oil-1]/Cap[k][indice_oil-1])+a0_mult_oil[k]);
        if ((Qloc[k][indice_oil-1]*A[k][indice_oil-1]/Cap[k][indice_oil-1])>0.999)
        {
            mult_oil[k]=(a4_mult_oil[k]*pow(0.999,4)+ a3_mult_oil[k]*pow(0.999,3) +a2_mult_oil[k]*pow(0.999,2)+a1_mult_oil[k]*(0.999)+a0_mult_oil[k]);
        }
        if (mult_oil[k]<0.000001)
        {
            mult_oil[k]=0.000001;
        }
    }
    for (k=0; k<reg; k++)
    {
        mult_gaz[k]=(a4_mult_gaz[k]*pow(Qloc[k][indice_gas-1]*A[k][indice_gas-1]/Cap[k][indice_gas-1],4)+ a3_mult_gaz[k]*pow(Qloc[k][indice_gas-1]*A[k][indice_gas-1]/Cap[k][indice_gas-1],3) +a2_mult_gaz[k]*pow(Qloc[k][indice_gas-1]*A[k][indice_gas-1]/Cap[k][indice_gas-1],2)+a1_mult_gaz[k]*(Qloc[k][indice_gas-1]*A[k][indice_gas-1]/Cap[k][indice_gas-1])+a0_mult_gaz[k]);
        if ((Qloc[k][indice_gas-1]*A[k][indice_gas-1]/Cap[k][indice_gas-1])>0.999)
        {
            mult_gaz[k]=(a4_mult_gaz[k]*pow(0.999,4)+ a3_mult_gaz[k]*pow(0.999,3) +a2_mult_gaz[k]*pow(0.999,2)+a1_mult_gaz[k]*(0.999)+a0_mult_gaz[k]);
        }
        if (mult_gaz[k]<0.000001)
        {
            mult_gaz[k]=0.000001;
        }
    }

    for (k=0; k<reg; k++)
    {
        mult_coal[k]=(a4_mult_coal[k]*pow(Qloc[k][indice_coal-1]*A[k][indice_coal-1]/Cap[k][indice_coal-1],4)+ a3_mult_coal[k]*pow(Qloc[k][indice_coal-1]*A[k][indice_coal-1]/Cap[k][indice_coal-1],3) +a2_mult_coal[k]*pow(Qloc[k][indice_coal-1]*A[k][indice_coal-1]/Cap[k][indice_coal-1],2)+a1_mult_coal[k]*(Qloc[k][indice_coal-1]*A[k][indice_coal-1]/Cap[k][indice_coal-1])+a0_mult_coal[k]);
        if ((Qloc[k][indice_coal-1]*A[k][indice_coal-1]/Cap[k][indice_coal-1])>0.999)
        {
            mult_coal[k]=(a4_mult_coal[k]*pow(0.999,4)+ a3_mult_coal[k]*pow(0.999,3) +a2_mult_coal[k]*pow(0.999,2)+a1_mult_coal[k]*(0.999)+a0_mult_coal[k]);
        }
        if (mult_coal[k]<0.000001)
        {
            mult_coal[k]=0.000001;
        }
    }

    for (k=0; k<reg; k++)
    {
        partDomDF[k][indice_elec-1] = partDomDFref[k][indice_elec-1];
        partDomDG[k][indice_elec-1] = partDomDGref[k][indice_elec-1];
        partDomDI[k][indice_elec-1] = partDomDIref[k][indice_elec-1];
        /*partDomDF[k][indice_Et-1] = partDomDFref[k][indice_Et-1];*/
        /*partDomDG[k][indice_Et-1] = partDomDGref[k][indice_Et-1];*/
        /*partDomDI[k][indice_Et-1] = partDomDIref[k][indice_Et-1];*/
        /*on rajoute le mult_oil*/
        if (mult_oil[k]<1)
        {
            partDomDF[k][indice_oil-1]=mult_oil[k]*partDomDF[k][indice_oil-1];
            partDomDG[k][indice_oil-1]=mult_oil[k]*partDomDG[k][indice_oil-1];
            partDomDI[k][indice_oil-1]=mult_oil[k]*partDomDI[k][indice_oil-1];
        }
        if (mult_oil[k]<0)
        {
            partDomDF[k][indice_oil-1]=0;
            partDomDG[k][indice_oil-1]=0;
            partDomDI[k][indice_oil-1]=0;
        }

        if (mult_gaz[k]<1)
        {
            partDomDF[k][indice_gas-1]=mult_gaz[k]*partDomDF[k][indice_gas-1];
            partDomDG[k][indice_gas-1]=mult_gaz[k]*partDomDG[k][indice_gas-1];
            partDomDI[k][indice_gas-1]=mult_gaz[k]*partDomDI[k][indice_gas-1];
        }
        if (mult_gaz[k]<0)
        {
            partDomDF[k][indice_gas-1]=0;
            partDomDG[k][indice_gas-1]=0;
            partDomDI[k][indice_gas-1]=0;
        }

        if (mult_coal[k]<1)
        {
            partDomDF[k][indice_coal-1]=mult_coal[k]*partDomDF[k][indice_coal-1];
            partDomDG[k][indice_coal-1]=mult_coal[k]*partDomDG[k][indice_coal-1];
            partDomDI[k][indice_coal-1]=mult_coal[k]*partDomDI[k][indice_coal-1];
        }
        if (mult_coal[k]<0)
        {
            partDomDF[k][indice_coal-1]=0;
            partDomDG[k][indice_coal-1]=0;
            partDomDI[k][indice_coal-1]=0;
        }
    }

    for (k=0; k<reg; k++)
    {
        for (j=0; j<nbsecteurenergie; j++)
        {

            partDomDF[k][j]=partDomDF[k][j]*inertia_share+partDomDF_stock[k][j]*(1-inertia_share);
            partDomDG[k][j]=partDomDG[k][j]*inertia_share+partDomDG_stock[k][j]*(1-inertia_share);
            partDomDI[k][j]=partDomDI[k][j]*inertia_share+partDomDI_stock[k][j]*(1-inertia_share);
            // Here we introduce sovereignty policies.
            partDomDF[k][j] = fmax(partDomDF_min[k][j], partDomDF[k][j]);
        }
    }

    for (k=0; k<reg; k++)
    {
        for (j=0; j<nbsecteurenergie; j++)
        {
            partImpDF[k][j] = 1 - partDomDF[k][j];
            partImpDG[k][j] = 1 - partDomDG[k][j];
            partImpDI[k][j] = 1 - partDomDI[k][j];
        }
    }

    for (k=0; k<nbsecteurenergie; k++)
    {
        for (j=0; j<sec; j++)
        {
            for (l=0; l<reg; l++)
            {
                partDomCI[k][j][l] = pow((ploc[l][k] * (1+ 
                                taxCIdom[k][j][l]) + itgbl_cost_CIdom[k][j][l] * 
                            ploc[l][k]/pref[l][k] ), alpha_partCI[k][j][l]) /
                    ((pow((ploc[l][k] * (1+
                                         taxCIdom[k][j][l]) + itgbl_cost_CIdom[k][j][l] * 
                           ploc[l][k]/pref[l][k] ), alpha_partCI[k][j][l]))
                     + pow((wpEnerloc[k] * (1+ mtax[l][k]) + nit[l][k] *
                             wpTIaggloc) * (1 + taxCIimp[k][j][l])+ itgbl_cost_CIimp[k][j][l] * 
                         wpEnerloc[k]/wpEnerref[k],alpha_partCI[k][j][l])); 

            }
        }
    }
    /*wr_sci_rs(partDomDF);*/
    /*wr_sci_rs(partDomDF);*/
    for (j=0; j<sec; j++)
    {
        for (l=0; l<reg; l++)
        {
            partDomCI[indice_elec-1][j][l] = partDomCIref[indice_elec-1][j][l];
            partDomCI[indice_Et-1][j][l] = partDomCIref[indice_Et-1][j][l];

            if (mult_oil[l]<1)
            {
                partDomCI[indice_oil-1][j][l]=mult_oil[l]*partDomCI[indice_oil-1][j][l];
            }

            if (mult_oil[l]<0)
            {
                partDomCI[indice_oil-1][j][l]=0;
            }
            if (mult_gaz[l]<1)
            {
                partDomCI[indice_gas-1][j][l]=mult_gaz[l]*partDomCI[indice_gas-1][j][l];
            }

            if (mult_gaz[l]<0)
            {
                partDomCI[indice_gas-1][j][l]=0;
            }

            if (mult_coal[l]<1)
            {
                partDomCI[indice_coal-1][j][l]=mult_coal[l]*partDomCI[indice_coal-1][j][l];
            }

            if (mult_coal[l]<0)
            {
                partDomCI[indice_coal-1][j][l]=0;
            }

        }
    }

    for (k=0; k<nbsecteurenergie; k++)
    {
        for (j=0; j<sec; j++)
        {
            for (l=0; l<reg; l++)
            {
                partDomCI[k][j][l]=partDomCI[k][j][l]*inertia_share+partDomCI_stock[k][j][l]*(1-inertia_share);
            
                // Apply the lower bound (sovereignty constraint)
                partDomCI[k][j][l] = fmax(partDomCI_min[k][j][l], partDomCI[k][j][l]);

            }
        }
    }

    for (k=0; k<nbsecteurenergie; k++)
    {
        for (j=0; j<sec; j++)
        {
            for (l=0; l<reg; l++)
            {
                partImpCI[k][j][l] = 1 -  partDomCI[k][j][l];

            }
        }
    }

    for (j=0; j<nbsecteurenergie; j++)
    {
        sum = 0;
        for (k=0; k<reg; k++)
        {
            if (j==3 & new_Et_msh_computation==1)
                sum += weightEt_new[k] * pow( new_Et_msh_computation * taxCO2_DF[k][j]* coef_Q_CO2_Et_prod[k] * numloc[k][j]+ploc[k][j]*(1+xtax[k][j]), etaEtnew) ;
            else
                sum += bmarketshareener[k][j]*pow(((ploc[k][j]*(1+xtax[k][j]))/
                        (p_stock[k][j]*(1+xtaxref[k][j]))) , etamarketshareener[j]);

        }
        for (k=0; k<reg; k++)
        {
            if (j==3 & new_Et_msh_computation==1)
                marketshare[k][j] = weightEt_new[k] * pow( new_Et_msh_computation * taxCO2_DF[k][j]* coef_Q_CO2_Et_prod[k] * numloc[k][j]+ploc[k][j]*(1+xtax[k][j]), etaEtnew) / sum ;
            else
                marketshare[k][j] = bmarketshareener[k][j] * 
                pow((ploc[k][j]*(1+xtax[k][j]))/
                        (p_stock[k][j]*(1+xtaxref[k][j])),etamarketshareener[j])/sum ;
            /*        printf("%15.10g ", marketshare[k][j]);*/
        }
        /*                 printf("\n%15.10g \n", sum);*/
    }
    sum1=0;
    for (k=0; k<reg; k++)
    {
        if (mult_oil[k]<1)
        {
            marketshare[k][indice_oil-1]=mult_oil[k]*marketshare[k][indice_oil-1];
        }
        if (marketshare[k][indice_oil-1]<0.00000001)
        {
            marketshare[k][indice_oil-1]=0.00000001;
        }
        sum1+=marketshare[k][indice_oil-1];
    }

    for (k=0; k<reg; k++)
    {
        marketshare[k][indice_oil-1]=marketshare[k][indice_oil-1]/sum1;
    }

    sum1=0;
    for (k=0; k<reg; k++)
    {
        if (mult_gaz[k]<1)
        {
            marketshare[k][indice_gas-1]=mult_gaz[k]*marketshare[k][indice_gas-1];
        }
        if (marketshare[k][indice_gas-1]<0.00000001)
        {
            marketshare[k][indice_gas-1]=0.00000001;
        }

        sum1+=marketshare[k][indice_gas-1];
    }

    for (k=0; k<reg; k++)
    {
        marketshare[k][indice_gas-1]=marketshare[k][indice_gas-1]/sum1;
    }

    sum1=0;
    for (k=0; k<reg; k++)
    {
        if (mult_coal[k]<1)
        {
            marketshare[k][indice_coal-1]=mult_coal[k]*marketshare[k][indice_coal-1];
        }
        if (marketshare[k][indice_coal-1]<0.00000001)
        {
            marketshare[k][indice_coal-1]=0.00000001;
        }

        sum1+=marketshare[k][indice_coal-1];
    }

    for (k=0; k<reg; k++)
    {
        marketshare[k][indice_coal-1]=marketshare[k][indice_coal-1]/sum1;
    }

    /*
       for (k=0 ; k<reg; k++)
       {
       for (j=0; j<sec;j++)
       printf("%15.10g ",  marketshare[k][j]);
       printf("\n");
       }
       */
    /*
       wr_sci_rs(marketshare)
       */

    /*
       wr_sci_vec(etamarketshareener,"sci_r",sci_r,nbsecteurenergie)
       */


    for (j=0; j<nbsecteurenergie; j++)
        wploc[j] = wpEnerloc[j];

    for (k=0; k<reg; k++)
    {
        for (j=0; j<nbsecteurenergie; j++)
        {
            pArmDF[k][j] = ploc[k][j] * (1 + taxDFdom[k][j]) *
                (1-partImpDF[k][j]) + ((wpEnerloc[j] * (1 + mtax[k][j]) +
                            wpTIaggloc * nit[k][j]) * (1 + taxDFimp[k][j])) * 
                partImpDF[k][j] + taxCO2_DF[k][j] * coef_Q_CO2_DF[k][j] * 
                numloc[k][j];
            //fprintf (fp, "taxCO2_DF[%i][%i]:%g \n",k,j,taxCO2_DF[k][j]);  

            pArmDG[k][j] = ploc[k][j] * (1 + taxDGdom[k][j]) *
                (1-partImpDG[k][j]) + ((wpEnerloc[j] * (1 + mtax[k][j]) +
                            wpTIaggloc * nit[k][j]) * (1 + taxDGimp[k][j])) * 
                partImpDG[k][j] + taxCO2_DG[k][j] * coef_Q_CO2_DG[k][j] * 
                numloc[k][j];

            pArmDI[k][j] = ploc[k][j] * (1 + taxDIdom[k][j]) *
                (1-partImpDI[k][j]) + ((wpEnerloc[j] * (1 + mtax[k][j]) +
                            wpTIaggloc * nit[k][j]) * (1 + taxDIimp[k][j])) * 
                partImpDI[k][j] + taxCO2_DI[k][j] * coef_Q_CO2_DI[k][j] * 
                numloc[k][j];

        }
    }
    /*wr_sci_rs(partImpDF);*/

    for (k=0; k<nbsecteurenergie; k++)
    {
        for (j=0; j<sec; j++)
        {
            for (l=0; l<reg; l++)
            {
                pArmCI[k][j][l] = 
                    ploc [l][k] * (1 + taxCIdom[k][j][l])* (1 - partImpCI[k][j][l]) 
                    + (wpEnerloc[k] * (1 + mtax[l][k])+ nit[l][k] * wpTIaggloc) * (1+taxCIimp[k][j][l]) * partImpCI[k][j][l] 
                    + (taxCO2_CI[k][j][l]* coef_Q_CO2_CI[k][j][l] * numloc[l][k]);
            }
        }
    }

    for (k=0; k<reg; k++)
    {
        for (j=0; j<sec; j++)
            pArmDF[k][j] = pArmDF[k][j] * (1+Ttax[k][j]);
    }

    /*
       wr_sci_rs(pArmDI);
       */

    /*---------indice de prix de consommation des menages------*/
    /*pindtemp=(sum(pArmDF.*DFloc,'c')./sum(pArmDFref.*DFloc,'c').*sum(pArmDF.*DFref,'c')./sum(pArmDFref.*DFref,'c'))^(1/2); */
    for (k=0; k<reg; k++)
    {
        pindtemp[k]=0;
        sum1=0;
        sum2=0;
        sum3=0;
        sum4=0;
        for (j=0; j<sec; j++)
        {    
            sum1 += pArmDF[k][j] * DFloc[k][j];
            sum2 += pArmDFref[k][j] * DFloc[k][j];
            sum3 += pArmDF[k][j] * DFref[k][j];
            sum4 += pArmDFref[k][j] * DFref[k][j];
            pindtemp[k]=pow((sum1/sum2)*(sum3/sum4),0.5);
        }

    }

    /*wr_sci_vec(pindtemp,"sci_r",sci_r,reg); */
    /*wr_sci_rs(pArmDF);*/

    for (k=0; k<reg; k++)
    {    
        sum = 0;
        for (j=0; j<sec; j++)
        {
            sum += ploc[k][j] * Qloc[k][j] * markup[k][j] * FCCmarkup_oil[k][j] *
                (FCCtemp[k][j] * energ_sec[k][j] + non_energ_sec[k][j]);
        }
        GRBtemp[k] = Rdisploc[k] * (1-IR[k]) * (1- ptc[k]) + (1-divi[k]) * sum;
    }

    sum = 0;
    for (k=0; k<reg; k++)
        sum += GRBtemp[k] * partExpK[k];
    for (k=0; k<reg; k++)
        NRBtemp[k] = GRBtemp[k] * (1-partExpK[k]) + partImpK[k] * sum;

    for (k=0; k<reg; k++)
    {    
        sum = 0;
        for (j=0; j<sec; j++)
            sum += DIinfra[k][j] * pArmDI[k][j];

        sum1 =0;
        for (j=0; j<sec; j++)
            sum1 += DIprod[k][j] * pArmDI[k][j]; 
        for (j=0; j<sec; j++)
            DIloc[k][j] = DIinfra[k][j] + DIprod[k][j] * (NRBtemp[k] -  sum) / sum1;
    }

    for (l=0; l<reg; l++)
    {    
        for (j=0; j<sec; j++)
        {
            QCdomtemp[l][j] = 0;
            for (k =0; k<sec; k++)
            {
                QCdomtemp[l][j] += A_CI[l][k] * 
                    Qloc[l][k] * CI[j][k][l] *partDomCI[j][k][l]; 
            }
            QCdomtemp[l][j] += DFloc[l][j] * partDomDF[l][j] 
                + DG[l][j] * partDomDG[l][j] 
                + DIloc[l][j] * partDomDI[l][j];
        }
    }

    for (l=0; l<reg; l++)
    {
        for (j=0; j<sec; j++)
        {
            Imptemp[l][j] = 0;
            for (k =0; k<sec; k++)
            {
                Imptemp[l][j] += A_CI[l][k] *
                    Qloc[l][k] * CI[j][k][l] *partImpCI[j][k][l];
            }
            Imptemp[l][j] += DFloc[l][j] * partImpDF[l][j] 
                + DG[l][j] * partImpDG[l][j] 
                + DIloc[l][j] * partImpDI[l][j];
        }
    }

    /*
       wr_sci_rs(Imptemp);
       */

    for (j=0; j<sec; j++)
    {
        sum = 0;
        for (k=0; k<reg; k++)
            sum += Imptemp[k][j] ;
        for (k=0; k<reg; k++)
            Exptemp[k][j] = marketshare[k][j] * sum ;
    }

    /*
       wr_sci_rs(Exptemp);
       */

    for (k=0; k<reg; k++)
    {
        for (j=0; j<sec; j++)
            ExpTItemp[k][j] = 0;
    }

    sum = 0;
    for (k=0; k<reg; k++)
    {
        for (j=0; j<sec; j++)
            sum += (Imptemp[k][j] * nit[k][j]) ;
    }
    for (k=0; k<reg; k++)
    {        
        for (j=0; j<nb_trans; j++)
        {
            /*        printf("%15.10g ", sum);*/
            ExpTItemp[k][indice_transport_1-1+j] = marketshareTI[k][j] * sum * partTIref[j];
        }
    }
    /*
       wr_sci_rs(ExpTItemp);
       */
    /*
       wr_sci(marketshareTI,"sci_rt",sci_rt,reg,nb_trans);
       */
    for (l=0; l<reg; l++)
    {
        sum =0;
        for (j=0; j<sec; j++)
        {
            for (k =0; k<sec; k++)
                sum += ploc[l][j] * taxCIdom[j][k][l]
                    * partDomCI[j][k][l] * CI[j][k][l] 
                    * Qloc[l][k] * A_CI[l][k];
        }

        sum1 =0; 
        for (j=0; j<sec; j++)
        {
            for (k =0; k<sec; k++)
                sum1 += (wploc[j] * (1+ mtax[l][j]) 
                        + nit[l][j] * wpTIaggloc) * taxCIimp[j][k][l] 
                    * partImpCI[j][k][l] * CI[j][k][l] 
                    * Qloc[l][k] * A_CI[l][k];
        }
        taxCItemp[l] = sum + sum1;
    }

    /*
       wr_sci_vec(taxCItemp,"sci_r",sci_r,reg);
       */
    for (l=0; l<reg; l++)
    {    
        for (j=0; j<sec; j++)
        {
            TAXCO2temp_dom[l][j] = 0;
            for (k =0; k<sec; k++)
            {
                TAXCO2temp_dom[l][j] += A_CI[l][k] * 
                    Qloc[l][k] * CI[j][k][l] *partDomCI[j][k][l]*taxCO2_CI[j][k][l]*coef_Q_CO2_CI[j][k][l]*numloc[l][j]; 
            }
            TAXCO2temp_dom[l][j] += DFloc[l][j] * partDomDF[l][j] * taxCO2_DF[l][j] * coef_Q_CO2_DF[l][j] * numloc[l][j]
                + DG[l][j] * partDomDG[l][j] * taxCO2_DG[l][j] * coef_Q_CO2_DG[l][j] * numloc[l][j]
                + DIloc[l][j] * partDomDI[l][j] * taxCO2_DI[l][j] * coef_Q_CO2_DI[l][j] * numloc[l][j];
        }
    }

    for (l=0; l<reg; l++)
    {
        for (j=0; j<sec; j++)
        {
            TAXCO2temp_imp[l][j] = 0;
            for (k =0; k<sec; k++)
            {
                TAXCO2temp_imp[l][j] += A_CI[l][k] *
                    Qloc[l][k] * CI[j][k][l] *partImpCI[j][k][l]*taxCO2_CI[j][k][l]*coef_Q_CO2_CI[j][k][l]*numloc[l][j];
            }
            TAXCO2temp_imp[l][j] += DFloc[l][j] * partImpDF[l][j] * taxCO2_DF[l][j] * coef_Q_CO2_DF[l][j] * numloc[l][j] 
                + DG[l][j] * partImpDG[l][j] * taxCO2_DG[l][j] * coef_Q_CO2_DG[l][j] * numloc[l][j] 
                + DIloc[l][j] * partImpDI[l][j] * taxCO2_DI[l][j] * coef_Q_CO2_DI[l][j] * numloc[l][j];
        }
    }

    for (k=0; k<reg; k++)
    {    
        TAXCO2temp[k] = 0;
        for (j=0; j<sec; j++)
        {
            TAXCO2temp[k] += TAXCO2temp_imp[k][j]+TAXCO2temp_dom[k][j];    
        }

        //The State gets back the product of the carbon sequestration subsidy (minus the tax then)
        TAXCO2temp[k] -= (1-shareBiomassTaxElec[0])* CI[indice_elec-1][indice_elec-1][k] * coef_Q_CO2_CI[indice_elec-1][indice_elec-1][k]
            * taxCO2_CI[indice_elec-1][indice_elec-1][k] * numloc[k][indice_elec-1] * Qloc[k][indice_elec-1];

    }
    /*
       wr_sci_rs(QCdomtemp);
       */
    for (k=0; k<reg; k++)
    {
        sum = 0;
        for (j=0; j<sec; j++)
        {
            sum += (Exptemp[k][j] * ploc[k][j] * xtax[k][j] + 
                    (ploc[k][j] * taxDFdom[k][j] * partDomDF[k][j] +( wploc[j] *
                                                                      (1+mtax[k][j]) + wpTIaggloc * nit[k][j]) * taxDFimp[k][j] * 
                     partImpDF[k][j]) * DFloc[k][j] + ( ploc[k][j] * taxDGdom[k][j] *
                         partDomDG[k][j] + (wploc[j] * (1+mtax[k][j]) + wpTIaggloc * 

                             nit[k][j]) * taxDGimp[k][j] *   partImpDG[k][j]) * DG[k][j] +
                    ( ploc[k][j] * taxDIdom[k][j] *  partDomDI[k][j] + (wploc[j] *
                                                                        (1+mtax[k][j]) + wpTIaggloc * nit[k][j]) * taxDIimp[k][j] * 
                      partImpDI[k][j]) * DIloc[k][j] + wploc[j] * mtax[k][j] *
                    Imptemp[k][j] + Qloc[k][j] * ploc[k][j] * qtax[k][j] / (1 + 
                        qtax[k][j]) + DFloc[k][j] * pArmDF[k][j] * Ttax[k][j] / (1 +
                            Ttax[k][j]) + A[k][j] * Qloc[k][j] * wloc[k][j] * lll[k][j] *sigma[k][j] *    
                    (energ_sec[k][j] + FCCtemp[k][j] * non_energ_sec[k][j]) );

        }
        sumtaxtemp[k] = taxCItemp[k] + TAXCO2temp[k] +sum ; 
    }
    /*
       wr_sci_vec(sumtaxtemp,"sci_r",sci_r,reg);
       */
    /* fonction a renvoyer a scilab*/

    for (k=0 ; k<reg; k++)

    {
        tair[k] = toair[k] * (atrans[k][0] * pow((pkmautomobileref[k] / 100 * 
                        alphaair[k] * Consoloc[k][indice_air - nbsecteurenergie -1] / 
                        Captransport[k][0]),ktrans[k][0]) + btrans[k][0]);
    }

    for (k=0 ; k<reg; k++)

    {
        tOT[k] = toOT[k] * (atrans[k][1] * pow((pkmautomobileref[k] / 100 * 
                        alphaOT[k] * Consoloc[k][indice_OT - nbsecteurenergie -1] / 
                        Captransport[k][1]),ktrans[k][1]) + btrans[k][1]);
    }

    for (k=0 ; k<reg; k++)

    {
        tautomobile[k] = toautomobile[k] * (atrans[k][2] * pow((pkmautomobileref[k] 
                        / 100 * Tautomobileloc[k] / Captransport[k][2]),ktrans[k][2]) + btrans[k][2]);
    }
    /*
       wr_sci_rs(bn);
       */
    /*
       wr_sci(xsi,"sci_rt",sci_rt,reg,nb_trans);
       */
    for (k=0 ; k<reg; k++)
    {
        Utility[k][indice_construction-nbsecteurenergie-1] = (Consoloc[k][indice_construction - nbsecteurenergie -1] - bn[k][indice_construction -1]) 
            * lambdaloc[k] * pArmDF[k][indice_construction -1] - xsi[k][0];
        Utility[k][indice_composite-nbsecteurenergie-1] = (Consoloc[k][indice_composite - nbsecteurenergie -1] - bn[k][indice_composite-1]) 
            * lambdaloc[k] * pArmDF[k][indice_composite-1] - xsi[k][1];
        Utility[k][indice_agriculture-nbsecteurenergie-1] = (Consoloc[k][indice_agriculture - nbsecteurenergie -1] - bn[k][indice_agriculture-1]) 
            * lambdaloc[k] * pArmDF[k][indice_agriculture-1] - xsi[k][3];
		int i;
        for (i=0 ; i<nb_sectors_industry; i++)
		{
		Utility[k][indice_industries[i]-nbsecteurenergie-1] = (Consoloc[k][indice_industries[i] - nbsecteurenergie -1] - bn[k][indice_industries[i]-1]) 
            * lambdaloc[k] * pArmDF[k][indice_industries[i]-1] - xsi[k][4+i];
        }
        Utility[k][indice_mer-nbsecteurenergie-1] = (Consoloc[k][indice_mer - nbsecteurenergie -1] - bn[k][indice_mer-1]) * lambdaloc[k] * pArmDF[k][indice_mer-1] - xsi[k][2];
        if (exo_pkmair_scenario ==0)
            Utility[k][indice_air-nbsecteurenergie-1] = xsiT[k] * betatrans[k][0] * pow(alphaair[k], -sigmatrans[k]) * pow((Consoloc[k][indice_air - nbsecteurenergie -1] - bnair[k]), (-sigmatrans[k]-1)) + (betatrans[k][0] *  pow( alphaair[k] * (Consoloc[k][indice_air - nbsecteurenergie-1] - bnair[k]),-sigmatrans[k])+ betatrans[k][1] * pow(alphaOT[k] * (Consoloc[k][indice_OT - nbsecteurenergie-1] - bnOT[k]),-sigmatrans[k]) + betatrans[k][2] * pow((Tautomobileloc[k] - bnautomobile[k]), -sigmatrans[k]) +betatrans[k][3] * pow((TNMloc[k] - bnNM[k]),-sigmatrans[k])) * (-lambdaloc[k] * pArmDF[k][indice_air-1] - muloc[k] * pkmautomobileref[k] / 100 * alphaair[k] * tair[k]);
        else
            Utility[k][indice_air-nbsecteurenergie-1] = 0;

        Utility[k][indice_OT-nbsecteurenergie-1] = xsiT[k] * betatrans[k][1] * pow(alphaOT[k], -sigmatrans[k]) * pow((Consoloc[k][indice_OT - nbsecteurenergie -1] - bnOT[k]), (-sigmatrans[k]-1)) + (betatrans[k][0] *  pow( (alphaair[k] * (Consoloc[k][indice_air - nbsecteurenergie -1] - bnair[k])),-sigmatrans[k])+ betatrans[k][1] * pow((alphaOT[k] * (Consoloc[k][indice_OT - nbsecteurenergie -1] - bnOT[k])),-sigmatrans[k]) + betatrans[k][2] * pow((Tautomobileloc[k] - bnautomobile[k]), -sigmatrans[k]) +betatrans[k][3] * pow((TNMloc[k] - bnNM[k]),-sigmatrans[k])) * (-lambdaloc[k] * pArmDF[k][indice_OT -1] - muloc[k] * pkmautomobileref[k] / 100 * alphaOT[k] * tOT[k]);

        Utility[k][nb_secteur_conso+1-1] = xsiT[k] * betatrans[k][2] * pow((Tautomobileloc[k] - bnautomobile[k]), (-sigmatrans[k]-1)) + (betatrans[k][0] *  pow( (alphaair[k] * (Consoloc[k][indice_air - nbsecteurenergie -1] - bnair[k])),-sigmatrans[k])+ betatrans[k][1] * pow((alphaOT[k] * (Consoloc[k][indice_OT - nbsecteurenergie-1] - bnOT[k])),-sigmatrans[k]) + betatrans[k][2] * pow((Tautomobileloc[k] - bnautomobile[k]), -sigmatrans[k]) + betatrans[k][3] * pow((TNMloc[k] - bnNM[k]),-sigmatrans[k])) * (-lambdaloc[k] * (alphaEtauto[k] * pArmDF[k][indice_Et -1]+ alphaelecauto[k] * pArmDF[k][indice_elec -1] + alphaCompositeauto[k] *  pArmDF[k][indice_composite -1]) * pkmautomobileref[k] / 100 - muloc[k] * pkmautomobileref[k] / 100 * tautomobile[k]);

        Utility[k][nb_secteur_conso+2-1] = xsiT [k] * betatrans[k][3] * pow((TNMloc[k] - bnNM[k]), (-sigmatrans[k]-1)) + (betatrans[k][0] *  pow( (alphaair[k] * (Consoloc[k][indice_air - nbsecteurenergie -1] - bnair[k])),-sigmatrans[k])+ betatrans[k][1] * pow((alphaOT[k] * (Consoloc[k][indice_OT - nbsecteurenergie -1] - bnOT[k])),-sigmatrans[k]) + betatrans[k][2] * pow((Tautomobileloc[k] - bnautomobile[k]), -sigmatrans[k]) + betatrans[k][3] * pow((TNMloc[k] - bnNM[k]),-sigmatrans[k])) * ( - muloc[k] * pkmautomobileref[k] / 100 * toNM[k]);

    }

    for (k=0 ; k<reg; k++)
    {
        sum = 0;
        for (j=0; j<sec ;j++)
            sum += DFloc[k][j] * pArmDF[k][j];

        Household_budget[k] = ptc[k] - sum / (Rdisploc[k] * (1 - IR[k]));
    }

    for (k=0 ; k<reg; k++)
    {
        Itair[k] = toair[k] * (atrans[k][0] * pow(((pkmautomobileref[k] / 100) * 
                        alphaair[k] * Consoloc[k][indice_air - nbsecteurenergie -1] / 
                        Captransport[k][0]),(ktrans[k][0] + 1)) * Captransport[k][0] / 
                (ktrans[k][0] + 1) + btrans[k][0] *(pkmautomobileref[k] / 100) * 
                alphaair[k] * Consoloc[k][indice_air - nbsecteurenergie -1]);
    }

    for (k=0 ; k<reg; k++)
    {
        ItOT[k] = toOT[k] * (atrans[k][1] * pow(((pkmautomobileref[k] / 100) * 
                        alphaOT[k] * Consoloc[k][indice_OT - nbsecteurenergie -1] /
                        Captransport[k][1]),(ktrans[k][1] + 1)) * Captransport[k][1] /
                (ktrans[k][1] + 1) + btrans[k][1] *(pkmautomobileref[k] / 100) *
                alphaOT[k] * Consoloc[k][indice_OT - nbsecteurenergie -1]);
    }

    for (k=0 ; k<reg; k++)
    {
        Itautomobile[k] = toautomobile[k] * (atrans[k][2] * 
                pow(((pkmautomobileref[k] / 100) * Tautomobileloc[k]  / 
                        Captransport[k][2]),(ktrans[k][2] + 1)) * Captransport[k][2] /
                (ktrans[k][2] + 1) + btrans[k][2] *(pkmautomobileref[k] / 100) *
                Tautomobileloc[k]);
    }

    for (k=0 ; k<reg; k++)
    {
        Time_budget[k] = 1 - (Itautomobile[k] + Itair[k] +ItOT[k] + 
                pkmautomobileref[k] / 100 * TNMloc[k] * toNM[k]) / Tdisp[k];
    }

    for (l=0; l<reg; l++)
    {
        for (j=0 ; j<sec; j++)
        { 
            costs_CI[l][j] = 0;
            for (k=0 ; k<sec; k++)
            {
                costs_CI[l][j]    += (pArmCI[k][j][l] *
                        CI[k][j][l]);

            }
        }
    }

    for (k=0 ; k<reg; k++)
    {
        for (j=0 ; j<sec; j++)
        {
            if (j==indice_elec-1)
            {

                Sector_budget[k][j] = 
                    (
                     (
                        A_CI[k][j] *(costs_CI[k][j] 
                      - (1-shareBiomassTaxElec[0]) * CI[j][j][k] * coef_Q_CO2_CI[j][j][k] * taxCO2_CI[j][j][k] * numloc[k][j])  //prelevement de la subvention, ie de la (-tax)
                      + A[k][j] *wloc[k][j] * lll[k][j] * (1+ sigma[k][j]) * (energ_sec[k][j] + FCCtemp[k][j] * 
                          non_energ_sec[k][j])
                     )    
                     + markup[k][j] *FCCmarkup_oil[k][j] * ploc[k][j]  * (energ_sec[k][j] + non_energ_sec[k][j])
                    ) * (1+ qtax[k][j])
                    - ploc[k][j] ; //ressources
                // if (k==2 && rand()<0.3)
                // {
                // sciprint("costs_CI[eur][elec]=%g  subvention=%g\n",costs_CI[k][j], - CI[j][j][k] * coef_Q_CO2_CI[j][j][k] * taxCO2_CI[j][j][k] * numloc[k][j]);
                // }

            }
            else
            {
                Sector_budget[k][j] = ( A_CI[k][j]*costs_CI[k][j] + A[k][j]*wloc[k][j] * lll[k][j] * (1+ sigma[k][j]) * (energ_sec[k][j] + FCCtemp[k][j] * 
                                non_energ_sec[k][j]) + markup[k][j] *FCCmarkup_oil[k][j] * ploc[k][j]
                        * (energ_sec[k][j] + non_energ_sec[k][j])) * (1+ qtax[k][j])
                    - ploc[k][j];
            }
        }
    }


    for (k=0 ; k<reg; k++)
    {
        for (j=0 ; j<sec; j++)
        {    
            Market_clear[k][j] = (QCdomtemp[k][j] + Exptemp[k][j] + 
                    ExpTItemp[k][j]) / Qloc[k][j] -1;
        }
    }

    for (k=0 ; k<reg; k++)
    {
        for (j=0 ; j<sec; j++)
            Wages[k][j] =  1 - pindtemp[k] * wref[k][j] * 
                (aw[k] + bw[k] * tanh(cw[k]*zloc[k])) 
                / (pindref[k] * wloc[k][j]);
    }

    for (j=0 ; j<nbsecteurenergie; j++)
    {
        sum = 0;    
        for (k=0 ; k<reg; k++)
            sum += Exptemp[k][j] * ploc[k][j] * (1 + xtax[k][j]);
        sum1 =0;
        for (k=0 ; k<reg; k++)
            sum1 += (Imptemp[k][j]);

        Energy_world_prices[j] = wpEnerloc[j] - sum / sum1 ;
    }

    for (k=0 ; k<reg; k++)
    {
        sum = 0;
        sum1 =0;
        sum2 =0;
        for (j=0 ; j<sec; j++)
        {
            sum += pArmDG[k][j] * DG[k][j];
        }
        for (j=0 ; j<sec; j++)
        {
            sum1 += (A[k][j] * wloc[k][j] * lll[k][j] *Qloc[k][j] * 
                    (energ_sec[k][j] + FCCtemp[k][j] *non_energ_sec[k][j]));
        }
        for (j=0 ; j<sec; j++)
        {
            sum2 += ploc[k][j] * Qloc[k][j] * markup[k][j]* FCCmarkup_oil[k][j] *(
                    FCCtemp[k][j] * energ_sec[k][j] + non_energ_sec[k][j]);
        }
        State_budget[k] = (Rdisploc[k] * (1-IR[k]) + sum - sumtaxtemp[k] - QuotasRevenue[k]
                - sum1 - divi[k] * sum2) /Rdisploc[k];  
    }

    /*Valeurs renvoyees a scilab par v*/
    m_out = 0;
    for (j=0 ; j<nb_secteur_conso+2; j++)
    {
        for (k=0 ; k<reg; k++)
        {
            v[m_out] = Utility[k][j];
            m_out++;
        }
    }
    for (k=0 ; k<reg; k++)
    {
        v[m_out] = Household_budget[k];
        m_out++;
    }

    for (k=0 ; k<reg; k++)
    {
        v[m_out] =  Time_budget[k];
        m_out++;
    }

    for (j=0 ; j<sec; j++)
    {
        for (k=0 ; k<reg; k++)
        {
            v[m_out] = Sector_budget[k][j];
            m_out++;
        }
    }

    for (j=0 ; j<sec; j++)
    {
        for (k=0 ; k<reg; k++)
        {
            v[m_out] = Market_clear[k][j];
            m_out++;
        }
    }

    for (j=0 ; j<sec; j++)
    {
        for (k=0 ; k<reg; k++)
        {
            v[m_out] =  Wages[k][j];
            m_out++;
        }
    }

    //v[m_out] = 0; //price_simplex
    //m_out++;

    for (j=0 ; j<nbsecteurenergie; j++)
    {
        v[m_out] =  Energy_world_prices[j];
        m_out++;
    }

    for (k=0 ; k<reg; k++)
    {
        v[m_out] = State_budget[k];
        m_out++;
    }

    if (verbose[0]==1)
    {
        for (j=0 ; j<nb_secteur_conso+2; j++)
        {sciprint("Utility        %i :[%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g]\n\n",j,Utility[0][j],Utility[1][j],Utility[2][j],Utility[3][j],Utility[4][j],Utility[5][j],Utility[6][j],Utility[7][j],Utility[8][j],Utility[9][j],Utility[10][j],Utility[11][j]);}
        sciprint("Household_budget :[%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g]\n\n",Household_budget[0],Household_budget[1],Household_budget[2],Household_budget[3],Household_budget[4],Household_budget[5],Household_budget[6],Household_budget[7],Household_budget[8],Household_budget[9],Household_budget[10],Household_budget[11]);
        sciprint("Time_budget      :[%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g]\n\n",Time_budget[0],Time_budget[1],Time_budget[2],Time_budget[3],Time_budget[4],Time_budget[5],Time_budget[6],Time_budget[7],Time_budget[8],Time_budget[9],Time_budget[10],Time_budget[11]);
        for (j=0 ; j<sec; j++)
        {sciprint("Sector_budge   %i :[%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g]\n\n",j,Sector_budget[0][j],Sector_budget[1][j],Sector_budget[2][j],Sector_budget[3][j],Sector_budget[4][j],Sector_budget[5][j],Sector_budget[6][j],Sector_budget[7][j],Sector_budget[8][j],Sector_budget[9][j],Sector_budget[10][j],Sector_budget[11][j]);}
        for (j=0 ; j<sec; j++)
        {sciprint("Market_clear   %i :[%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g]\n\n",j,Market_clear[0][j],Market_clear[1][j],Market_clear[2][j],Market_clear[3][j],Market_clear[4][j],Market_clear[5][j],Market_clear[6][j],Market_clear[7][j],Market_clear[8][j],Market_clear[9][j],Market_clear[10][j],Market_clear[11][j]);}
        for (j=0 ; j<sec; j++)
        {sciprint("Wages          %i :[%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g]\n\n",j,Wages[0][j],Wages[1][j],Wages[2][j],Wages[3][j],Wages[4][j],Wages[5][j],Wages[6][j],Wages[7][j],Wages[8][j],Wages[9][j],Wages[10][j],Wages[11][j]);}
        {sciprint("State_budget   %i :[%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g]\n\n",j,State_budget[0],State_budget[1],State_budget[2],State_budget[3],State_budget[4],State_budget[5],State_budget[6],State_budget[7],State_budget[8],State_budget[9],State_budget[10],State_budget[11]);}
        sciprint("wpEner           :[%g,%g,%g,%g,%g]\n\n",Energy_world_prices[0],Energy_world_prices[1],Energy_world_prices[2],Energy_world_prices[3],Energy_world_prices[4],Energy_world_prices[5]);
    }
    /* last m_out++ doesn't correspond with a value in the v vector */

    //        if (m != m_out - 1)
    //                printf ("In: %d values, out: %d values\n", m, m_out-1);


    // fclose(fp);

}

void economyXC(int *n, double x[],double v[],int *iflag)
{  

    int k, j, l;
    double sum_CO2_MKT;
	
    //extrait taxMKT de x
    for (j=0 ; j<nbMKT; j++)
    {
        //Marche a taxe endogene et non fatallower
        if (areEmisConstparam[j])
        {
            taxMKT[j]=x[nX+j];
        }
        //marche a taxe endogene mais pas areEmisConstparam
        else if (!(is_taxexo_MKTparam[j]))
        {
            taxMKT[j]=0;
        }
    }
    //[taxCO2_DF, taxCO2_DG, taxCO2_DI, taxCO2_CI]=expand_tax
    for (l=0; l<reg; l++)
    {
        for (j=0 ; j<sec; j++)
        { 
            for (k=0 ; k<sec; k++)
            {
                //on coupe la taxe sur les autoconso FF  : taxCO2_CI(1:nbsecteurenergie,[indice_coal indice_gas indice_oil],1:reg)=0;
                if ( j<indice_gas && k<nbsecteurenergie ) 
                {
                    taxCO2_CI[k][j][l]=0;
                }
                else
                {
                    //intuition :  taxCO2_CI(petrole, services, europe ) : l'europe taxe les services quand ils brulent du petrole. Dans quel marche sont les services europeens?
                    taxCO2_CI[k][j][l]=weight_regional_tax[l] * taxMKT[(int)(whichMKT_reg_use[l][j])-1];
                }

            }

            taxCO2_DF[l][j] = weight_regional_tax[l] * taxMKT[(int)(whichMKT_reg_use[l][iu_df-1])-1];
            taxCO2_DG[l][j] = weight_regional_tax[l] * taxMKT[(int)(whichMKT_reg_use[l][iu_dg-1])-1]; 
            taxCO2_DI[l][j] = weight_regional_tax[l] * taxMKT[(int)(whichMKT_reg_use[l][iu_di-1])-1];
        }
    }

    // fp = fopen("myfile.txt","a");

    //runs economy avec les valeurs de la taxe
    economyC(n,x,v,iflag);

    fill_vector(E_CO2_MKT,nbMKT,0);

    //calcule les emissions de CO2
    for (l=0; l<reg; l++)
    {    
        for (j=0; j<sec; j++)
        {
            for (k =0; k<sec; k++)
            {
                E_CO2_MKT[(int)(whichMKT_reg_use[l][j])-1] += Qloc[l][j] * CI[k][j][l] *coef_Q_CO2_CI[k][j][l]; 
            }
            E_CO2_MKT[(int)(whichMKT_reg_use[l][iu_df-1])-1] += DFloc[l][j] * coef_Q_CO2_DF[l][j] ;
            E_CO2_MKT[(int)(whichMKT_reg_use[l][iu_dg-1])-1] += DG[l][j] * coef_Q_CO2_DG[l][j] ;
            E_CO2_MKT[(int)(whichMKT_reg_use[l][iu_di-1])-1] += DIloc[l][j] * coef_Q_CO2_DI[l][j] ;
        }
    }

    for (j=0 ; j<nbMKT; j++)
    {
        sum_CO2_MKT = CO2_obj_MKTparam[j];
	for (l=0; l<reg; l++)
	{
		if (whichMKT_reg_use[l][iu_df-1] == 1)
		{
			sum_CO2_MKT += CO2_untaxed[l];
		}
	}
        //le marche est contraint et n'est pas un fatalower 
        if (areEmisConstparam[j] )
        {
            v[nX+j]=E_CO2_MKT[j]/sum_CO2_MKT-1;
        }
        else
        {
            v[nX+j]=0;
        }
    }

}
