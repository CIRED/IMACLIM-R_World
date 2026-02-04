// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Aurélie Méjean
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// File used to calculate the reference GDP in PPP and in MER for IMACLIM regions

// GDP Med-medium-conv (MER) in billion 2005 USD, 26 regions (size = 26*21) (source: AMPERE)
// The 26 regions are: USA(1) JPN(2) EU15(3) EU12(4) RUS(5) MEA(6) CHN(7) IND(8) SSA(9) LAM(10) SEA(11) SAS(12) KOR(13) EEU(14) TUR(15) AUNZ(16) CAN(17) SAF(18) TWN(19) CAS(20) PAK(21) EFTA(22) NAF(23) IDN(24) MEX(25) BRA(26)
GDP_MER_26 =  csvread('GDP_MER_AMPERE.csv'); // MER GDP, 26 regions, 2000 - 2150 (every five years) 

//2005 MER to PPP fixed ratio (26*1)
MER_to_PPP_ratio_2005 = csvread('MER_to_PPP_2005_ratio.csv'); //2005 MER to PPP fixed ratio, 26 regions
MER_to_PPP_ratio_26 = MER_to_PPP_ratio_2005*ones(1,21);

// GDP Med-medium-conv (PPP) in billion 2005 USD, 26 regions
GDP_PPP_26 = GDP_MER_26.*MER_to_PPP_ratio_26;

// Regional aggregation from 26 regions to IMACLIM regions for GDP in PPP, over the whole period
// USA = USA
// CAN = CAN
// EUR = EFTA+EU12+EU15+TUR
// JANZ = AUNZ + JPN + KOR
// FSU = EEU+CAS+RUS
// CHN = CHN
// IND = IND
// BRA = BRA
// MEA = MEA
// AFR = NAF+SAF+SSA
// RAS = PAK+SAS+SEA+TWN+IDN
// RAL = LAM + MEX

GDP_PPP_data = zeros(12,21); //12 regions, 2000-2100

GDP_PPP_data(1,:)  = GDP_PPP_26(1,:); // USA
GDP_PPP_data(2,:)  = GDP_PPP_26(17,:); // CAN
GDP_PPP_data(3,:)  = GDP_PPP_26(3,:) + GDP_PPP_26(4,:) + GDP_PPP_26(22,:) + GDP_PPP_26(15,:); // EUR
GDP_PPP_data(4,:)  = GDP_PPP_26(2,:) + GDP_PPP_26(16,:) + GDP_PPP_26(13,:); // JANZ
GDP_PPP_data(5,:)  = GDP_PPP_26(5,:) + GDP_PPP_26(14,:) + GDP_PPP_26(20,:); // FSU
GDP_PPP_data(6,:)  = GDP_PPP_26(7,:); // CHN
GDP_PPP_data(7,:)  = GDP_PPP_26(8,:); // IND
GDP_PPP_data(8,:)  = GDP_PPP_26(26,:); // BRA
GDP_PPP_data(9,:)  = GDP_PPP_26(6,:); // MEA
GDP_PPP_data(10,:) = GDP_PPP_26(9,:) + GDP_PPP_26(18,:) + GDP_PPP_26(23,:); // AFR
GDP_PPP_data(11,:) = GDP_PPP_26(11,:) + GDP_PPP_26(12,:) + GDP_PPP_26(19,:) + GDP_PPP_26(21,:) + GDP_PPP_26(24,:); // RAS
GDP_PPP_data(12,:) = GDP_PPP_26(10,:) + GDP_PPP_26(25,:); // RAL

GDP_PPP_data_2005 = GDP_PPP_data(:,2);
GDP_PPP_data_2000 = GDP_PPP_data(:,1);

//Regional aggregation for GDP in MER in 2005
GDP_MER_data_2005 = zeros(12,1);

GDP_MER_data_2005(1)  = GDP_MER_26(1,2); // USA
GDP_MER_data_2005(2)  = GDP_MER_26(17,2); // CAN
GDP_MER_data_2005(3)  = GDP_MER_26(3,2) + GDP_MER_26(4,2) + GDP_MER_26(22,2) + GDP_MER_26(15,2); // EUR
GDP_MER_data_2005(4)  = GDP_MER_26(2,2) + GDP_MER_26(16,2) + GDP_MER_26(13,2); // JANZ
GDP_MER_data_2005(5)  = GDP_MER_26(5,2) + GDP_MER_26(14,2) + GDP_MER_26(20,2); // FSU
GDP_MER_data_2005(6)  = GDP_MER_26(7,2); // CHN
GDP_MER_data_2005(7)  = GDP_MER_26(8,2); // IND
GDP_MER_data_2005(8)  = GDP_MER_26(26,2); // BRA
GDP_MER_data_2005(9)  = GDP_MER_26(6,2); // MEA
GDP_MER_data_2005(10) = GDP_MER_26(9,2) + GDP_MER_26(18,2) + GDP_MER_26(23,2); // AFR
GDP_MER_data_2005(11) = GDP_MER_26(11,2) + GDP_MER_26(12,2) + GDP_MER_26(19,2) + GDP_MER_26(21,2) + GDP_MER_26(24,2); // RAS
GDP_MER_data_2005(12) = GDP_MER_26(10,2) + GDP_MER_26(25,2); // RAL

//Calculation of PPP to MER ratio for IMACLIM regions
PPP_to_MER_2005_IM = GDP_MER_data_2005./GDP_PPP_data_2005; //PPP_to_MER_2005_IM_AMPERE
PPP_to_MER_2005_IM_21 = PPP_to_MER_2005_IM*ones(1,21); // same vector repeated for all AMPERE years
 
//Calculation of MER GDP for IMACLIM regions
GDP_MER_data = GDP_PPP_data.*PPP_to_MER_2005_IM_21;

GDP_MER_data = GDP_MER_data * 1000; // now in million 2005 USD
GDP_PPP_data = GDP_PPP_data * 1000; // now in million 2005 USD

//Calculation of 2001 PPP GDP for IMACLIM regions in 2005 USD
grwth_PPP_2000to2005 = (GDP_PPP_data(:,2)./GDP_PPP_data(:,1))^(1/(2005-2000))-1;
GDP_PPP_2001_AMPERE_corr = GDP_PPP_data(:,1).*(1 + grwth_PPP_2000to2005);

//Calculation of 2001 MER GDP for IMACLIM regions in 2005 USD
grwth_MER_2000to2005 = (GDP_MER_data(:,2)./GDP_MER_data(:,1))^(1/(2005-2000))-1;
GDP_MER_2001_AMPERE_corr = GDP_MER_data(:,1).*(1 + grwth_MER_2000to2005);

//GDP_PPP_2001_AMPERE_corr is used in Extraction and is in million 2005 USD 

mkcsv 'GDP_PPP_2001_AMPERE'
mkcsv 'GDP_MER_2001_AMPERE'
// mkcsv 'GDP_MER_data'
// mkcsv 'GDP_PPP_data'
// mkcsv 'PPP_to_MER_2005_IM'
