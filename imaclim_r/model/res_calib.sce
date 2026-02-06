// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

//calibration of residential energy usage, 7 usages:
// 1  Space heating
// 2  Space cooling
// 3  Fridges
// 4  Electric appliances
// 5  Lighting
// 6  Cooking
// 7  Water heating
nb_usage_res=7;

//indices definition
indice_chauffage=1;
indice_clim=2;
indice_frigo=3;
indice_electromenager=4;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
indice_eclairage=5;
indice_cuisine=6;
indice_chauffEau=7;

////China is divided into several sub-regions
reg_chine=6;

/////////////////////////////
//// no homogenous market
//elasticity of the logit for new equipment
Res_nu=2.5*ones(reg,1,nb_usage_res);

// for j=1:nb_usage_res,
// 	Res_nu(:,:,j)=[2;1;1;1;1;1;1;1;1;1;1;1];
// end

// income elasticity assumption for unitary energy services (commercial, useful energy) for the USA, per usage
Res_elast_USA_ini=[0.29;0.29;0.35;0.35;0.31;0.04;0.09];
// asymptote of unitary energy services (commercial, useful energy) for the USA, indices per usage
Res_indice_max_USA=[1.1;1.3;1.1;2;1.1;1.02;1.1];
// elasticity assumption for other regions
Res_elast_tot_ini=[1,1,1.5,2,1,0.3,0.5];
// asymptote of unitary energy services (commercial, useful energy), indices per usage, for other regions
Res_se_unit_min=[0.7;0.7;0.7;0.7;0.8;0.9;0.8];

// price elasticity of unitary energy services (commercial)
//Res_elast_prix=[-0.3;-0.3;-0.3;-0.3;-0.3;-0.1;-0.3];
//Res_elast_prix=[-0.38;-0.4;-0.4;-0.4;-0.4;-0.1;-0.36];
Res_elast_prix=[0;0;0;0;0;0;0];

// bound for efficiency of technology, by region, usage and commercial energy use
res_efficacite_max=ones(reg,nb_usage_res,4);
for k=1:reg,
    res_efficacite_max(k,:,:)=[
    0.4 0.8 0.8 1.2
    1 1 1 1.5
    1 1 1 2
    1 1 1 1.5
    1 1 1.5E12 7E14
    0.3 0.6 0.6 0.9
    0.4 0.7 0.7 1
    ];
    if k<5 then res_efficacite_max(k,:,:)=[
        0.6 0.9 0.9 1.3
        1 1 1 2
        1 1 1 3
        1 1 1 2.5
        1 1 1.5E12 7E14
        0.3 0.7 0.7 1
        0.5 0.8 0.8 1.1
        ];
    end			
end

// tracking high prices (for energy efficiency technologies)
res_prixhaut=zeros(reg,4);

///////////////////////////////////////////////////////////////
///////calibration////////////////////////////////////////////
/////////////////////////////////////////////////////////////
// see file calib_residentiel_v6_bio.xls & calibration courbes part bio.xls

Res_SH=[17062000000	1	2.7	0	1	2159	882	2.19993E-12	81.03857885	0	0	0.1	0	0	1	0	81.03857885	0	0	0	0	0.008798587	0.658503357	0.210301023	0.122397033	0.5	0.7	0.7	1	1.42605	76.2345375	24.34642286	9.9188816
1461000000	1	2	0	1	4493	171	1.67066E-12	10.96663677	0	0	0.1	0	0	1	0	10.96663677	0	0	0	0	0.001341008	0.562633981	0.139843154	0.296181857	0.5	0.7	0.7	1	0.0294127	8.814575	2.190870103	3.248118845
19193000000	1	2	0	1	3000	300	2.16832E-12	124.8498224	0	0	0.1	0	0	1	0	124.8498224	0	0	0	0	0.043315268	0.554893686	0.308623941	0.093167105	0.5	0.8	0.8	1	10.81580715	86.59797263	48.16455526	11.63189648
5966000000	1	1.7	0	1	1933	250	1.51081E-12	17.42307724	0	0	0.1	0	0	1	0	17.42307724	0	0	0	0	0.001978715	0.242276462	0.46050904	0.295235784	0.5	0.8	0.8	1	0.068950593	5.276501881	10.0293557	5.143915871
7052000000	1	2	0	1	4570	853	1.45349E-12	46.84264789	0	0	0.1	0	0	1	0	46.84264789	0	0	0	0	0.088185193	0.779545346	0.078900293	0.053369167	0.35	0.6	0.6	1	11.8023656	60.85994697	6.159831053	2.49995312
25470000000	1	2.6	0	1	2158	1046	3.7146E-13	20.41703199	0.56	95.4	0.07	6.678	0	1	0	13.73903199	0	0	0	0	0.597114278	0.204015022	0.104902021	0.09396868	0.3	0.6	0.6	1	27.3459072	4.67161485	2.402087037	1.291038694
7650000000	1	2	0	1	80	3120	1.06124E-12	0.649476671	0.58	5.25	0.06	0.315	0	1	0	0.334476671	0	0	0	0	0.301260789	0.023368859	0.266924868	0.408445483	0.3	0.5	0.5	1	0.335882353	0.015632677	0.178560283	0.136615486
1882000000	1	3.9	0	1	400	1700	1.80773E-13	0.136086149	0.23	0.3	0.08	0.024	0	1	0	0.112086149	0	0	0	0	0	0.072530514	0.344618762	0.582850724	0.35	0.6	0.6	1	0	0.013549443	0.064378317	0.065329493
3377000000	1	4	0	1	1100	1900	1.57772E-12	5.860773884	0	0	0.1	0	0	1	0	5.860773884	0	0	0	0	5.97191E-09	0.084485203	0.889032005	0.026482786	0.35	0.6	0.6	1	0.0000001	0.825247789	8.684025926	0.15520962
8905000000	1	2.7	0	1	300	2700	2.0512E-12	5.479791624	0.72	54.3	0.06	3.258	0	1	0	2.221791624	0	0	0	0	0.043976173	0.111478029	0.515338607	0.329207191	0.3	0.5	0.5	1	0.325686313	0.4953619	2.28995	0.73142978
16372000000	1	2.1	0	1	300	3300	8.8344E-13	4.339103857	0.45	31.5	0.06	1.89	0	1	0	2.449103857	0	0	0	0	0.417804152	0.144985171	0.368085824	0.069124853	0.3	0.5	0.5	1	3.4108192	0.710167482	1.802960825	0.169293944
3931000000	1	3	0	1	400	1700	3.33947E-13	0.52509889	0.23	1.5	0.07	0.105	0	1	0	0.42009889	0	0	0	0	0.02536936	0.474446726	0.194210778	0.305973136	0.35	0.6	0.6	1	0.0304504	0.332190905	0.135979554	0.128538975
];

Res_SC=[17062000000	1	2.7	0.538461538	0.65	2159	882	1.63259E-12	15.96939938	0	0	0.1	0	0	1	0	15.96939938	0	0	0	0	0	0	0	1	1	1	1	1.15	0	0	0	13.88643424
1461000000	1	2	0.538461538	0.65	4493	171	1.35727E-12	0.220408064	0	0	0.1	0	0	1	0	0.220408064	0	0	0	0	0	0	0	1	1	1	1	1	0	0	0	0.220408064
19193000000	1	2	4	0.2	3000	300	1.2626E-12	1.45398706	0	0	0.1	0	0	1	0	1.45398706	0	0	0	0	0	0	0	1	1	1	1	1	0	0	0	1.45398706
5966000000	1	1.7	0.030927835	0.97	1933	250	1.77774E-12	2.571957935	0	0	0.1	0	0	1	0	2.571957935	0	0	0	0	0	0	0	1	1	1	1	1	0	0	0	2.571957935
7052000000	1	2	9	0.1	4570	853	4.67545E-13	0.281244726	0	0	0.1	0	0	1	0	0.281244726	0	0	0	0	0	0	0	1	1	1	1	0.9	0	0	0	0.31249414
25470000000	0.98	2.6	4.444444444	0.18	2158	1046	2.42297E-13	1.161934824	0	0	0.1	0	0	1	0	1.161934824	0	0	0	0	0	0	0	1	1	1	1	0.9	0	0	0	1.291038694
7650000000	0.43	2	1.547857662	0.16876924	80	3120	1.52617E-13	0.614769686	0	0	0.1	0	0	1	0	0.614769686	0	0	0	0	0	0	0	1	1	1	1	0.9	0	0	0	0.683077429
1882000000	0.95	3.9	9.555555556	0.09	400	1700	2.24612E-13	0.064676198	0	0	0.1	0	0	1	0	0.064676198	0	0	0	0	0	0	0	1	1	1	1	0.9	0	0	0	0.071862443
3377000000	0.91	4	0.1375	0.8	1100	1900	4.35418E-13	2.235018528	0	0	0.1	0	0	1	0	2.235018528	0	0	0	0	0	0	0	1	1	1	1	0.9	0	0	0	2.48335392
8905000000	0.34	2.7	0.921568627	0.176938776	300	2700	1.54737E-13	0.658286802	0	0	0.1	0	0	1	0	0.658286802	0	0	0	0	0	0	0	1	1	1	1	0.9	0	0	0	0.73142978
16372000000	0.51	2.1	2	0.17	300	3300	6.63559E-14	0.609458197	0	0	0.1	0	0	1	0	0.609458197	0	0	0	0	0	0	0	1	1	1	1	0.9	0	0	0	0.677175775
3931000000	0.85	3	3.722222222	0.18	400	1700	1.92346E-13	0.231370155	0	0	0.1	0	0	1	0	0.231370155	0	0	0	0	0	0	0	1	1	1	1	0.9	0	0	0	0.25707795
];

Res_RRF=[285318000	1	2.7	0	1	2159	882	6.08375E-08	17.3580428	0	0	0.1	0	0	1	0	17.3580428	0	0	0	0	0	0	0	1	1	1	1	1.25	0	0	0	13.88643424
31081900.39	1	2	0	1	4493	171	5.87823E-08	1.82706685	0	0	0.1	0	0	1	0	1.82706685	0	0	0	0	0	0	0	1	1	1	1	1.125	0	0	0	1.624059423
588185312.5	1	2	0	1	3000	300	4.63498E-08	27.26225738	0	0	0.1	0	0	1	0	27.26225738	0	0	0	0	0	0	0	1	1	1	1	2.5	0	0	0	10.90490295
204682734.4	1	1.7	0	1	1933	250	5.0066E-08	10.2476449	0	0	0.1	0	0	1	0	10.2476449	0	0	0	0	0	0	0	1	1	1	1	1.875	0	0	0	5.465410613
281111406.3	1	2	0	1	4570	853	1.38955E-08	3.90617675	0	0	0.1	0	0	1	0	3.90617675	0	0	0	0	0	0	0	1	1	1	1	1.25	0	0	0	3.1249414
1271850000	0.98	2.6	0.75	0.56	2158	1046	4.9848E-09	3.550356408	0	0	0.1	0	0	1	0	3.550356408	0	0	0	0	0	0	0	1	1	1	1	1	0	0	0	3.550356408
1032355000	0.43	2	0.954545455	0.22	80	3120	4.51138E-09	1.024616143	0	0	0.1	0	0	1	0	1.024616143	0	0	0	0	0	0	0	1	1	1	1	1	0	0	0	1.024616143
172386000	0.95	3.9	0.144578313	0.83	400	1700	9.13186E-09	1.306589866	0	0	0.1	0	0	1	0	1.306589866	0	0	0	0	0	0	0	1	1	1	1	1	0	0	0	1.306589866
168851343.8	0.91	4	0	0.91	1100	1900	2.5253E-08	3.8802405	0	0	0.1	0	0	1	0	3.8802405	0	0	0	0	0	0	0	1	1	1	1	1	0	0	0	3.8802405
814046437.5	0.34	2.7	0.7	0.2	300	2700	6.73883E-09	1.09714467	0	0	0.1	0	0	1	0	1.09714467	0	0	0	0	0	0	0	1	1	1	1	1	0	0	0	1.09714467
915417000	0.51	2.1	0.457142857	0.35	300	3300	5.2839E-09	1.692939436	0	0	0.1	0	0	1	0	1.692939436	0	0	0	0	0	0	0	1	1	1	1	1	0	0	0	1.692939436
347614531.3	0.85	3	0.118421053	0.76	400	1700	9.73091E-09	2.5707795	0	0	0.1	0	0	1	0	2.5707795	0	0	0	0	0	0	0	1	1	1	1	1	0	0	0	2.5707795
];

Res_APPL=[285318000	1	2.7	0	1	2159	882	1.39057E-07	39.6755264	0	0	0.1	0	0	1	0	39.6755264	0	0	0	0	0	0	0	1	1	1	1	1	0	0	0	39.6755264
31081900.39	1	2	0	1	4493	171	1.49288E-07	4.640169779	0	0	0.1	0	0	1	0	4.640169779	0	0	0	0	0	0	0	1	1	1	1	1	0	0	0	4.640169779
588185312.5	1	2	0	1	3000	300	7.31708E-08	43.03801698	0	0	0.1	0	0	1	0	43.03801698	0	0	0	0	0	0	0	1	1	1	1	1.6	0	0	0	26.89876061
204682734.4	1	1.7	0	1	1933	250	6.78541E-08	13.88857285	0	0	0.1	0	0	1	0	13.88857285	0	0	0	0	0	0	0	1	1	1	1	1.6	0	0	0	8.680358032
281111406.3	1	2	0	1	4570	853	1.60076E-08	4.499915616	0	0	0.1	0	0	1	0	4.499915616	0	0	0	0	0	0	0	1	1	1	1	0.9	0	0	0	4.99990624
1271850000	0.98	2.6	0	0.98	2158	1046	3.26278E-09	4.066771886	0	0	0.1	0	0	1	0	4.066771886	0	0	0	0	0	0	0	1	1	1	1	0.9	0	0	0	4.518635429
1032355000	0.43	2	0	0.43	80	3120	3.46222E-09	1.536924214	0	0	0.1	0	0	1	0	1.536924214	0	0	0	0	0	0	0	1	1	1	1	0.9	0	0	0	1.707693571
172386000	0.95	3.9	0	0.95	400	1700	1.29249E-08	2.116675583	0	0	0.1	0	0	1	0	2.116675583	0	0	0	0	0	0	0	1	1	1	1	0.9	0	0	0	2.351861759
168851343.8	0.91	4	0	0.91	1100	1900	3.00005E-08	4.609725714	0	0	0.1	0	0	1	0	4.609725714	0	0	0	0	0	0	0	1	1	1	1	0.9	0	0	0	5.12191746
814046437.5	0.34	2.7	0	0.34	300	2700	5.94603E-09	1.645717005	0	0	0.1	0	0	1	0	1.645717005	0	0	0	0	0	0	0	1	1	1	1	0.9	0	0	0	1.82857445
915417000	0.51	2.1	0	0.51	300	3300	4.07948E-09	1.904556866	0	0	0.1	0	0	1	0	1.904556866	0	0	0	0	0	0	0	1	1	1	1	0.9	0	0	0	2.116174295
347614531.3	0.85	3	0	0.85	400	1700	1.25288E-08	3.70192248	0	0	0.1	0	0	1	0	3.70192248	0	0	0	0	0	0	0	1	1	1	1	0.9	0	0	0	4.1132472
];

Res_RL=[285318000	1	2.7	0	1	2159	882	9095384.774	2.59508E+15	0	0	0.1	0	0	1	0	2.59508E+15	0	0	0	0	0	0	0	1	1	1	1.16E+12	2.907E+14	0	0	0	8.92699344
31081900.39	1	2	0	1	4493	171	9092788.319	2.82621E+14	0	0	0.1	0	0	1	0	2.82621E+14	0	0	0	0	0	0	0	1	1	1	1.16E+12	2.707E+14	0	0	0	1.0440382
588185312.5	1	2	0	1	3000	300	7574665.764	4.45531E+15	0	0	0.1	0	0	1	0	4.45531E+15	0	0	0	0	0	0	0	1	1	1	1.16E+12	5.107E+14	0	0	0	8.72392236
204682734.4	1	1.7	0	1	1933	250	8813500.081	1.80397E+15	0	0	0.1	0	0	1	0	1.80397E+15	0	0	0	0	0	0	0	1	1	1	1.16E+12	3.507E+14	0	0	0	5.143915871
281111406.3	1	2	0	1	4570	853	1938919.115	5.45052E+14	0	0	0.1	0	0	1	0	5.45052E+14	0	0	0	0	0	0	0	1	1	1	1.16E+12	2.907E+14	0	0	0	1.87496484
1271850000	1	2.6	0	1	2158	1046	760037.9932	9.66654E+14	0	0	0.1	0	0	1	0	9.66654E+14	0	0	0	0	0	0	0.005765083	0.994234917	1	1	1.16E+12	2.707E+14	0	0	4.804174074	3.550356408
1032355000	1	2	0	1	80	3120	594085.2194	6.13307E+14	0	0	0.1	0	0	1	0	6.13307E+14	0	0	0	0	0	0	0.005065896	0.994934104	1	1	1.16E+12	2.707E+14	0	0	2.678404245	2.254155514
172386000	1	3.9	0	1	400	1700	1551812.636	2.67511E+14	0	0	0.1	0	0	1	0	2.67511E+14	0	0	0	0	0	0	0.008374861	0.991625139	1	1	1.16E+12	2.707E+14	0	0	1.931349505	0.9799424
168851343.8	1	4	0	1	1100	1900	5231391.437	8.83327E+14	0	0	0.1	0	0	1	0	8.83327E+14	0	0	0	0	0	0	0.0011404	0.9988596	1	1	1.16E+12	2.707E+14	0	0	0.868402593	3.25940202
814046437.5	1	2.7	0	1	300	2700	609698.9702	4.96323E+14	0	0	0.1	0	0	1	0	4.96323E+14	0	0	0	0	0	0	0.00267602	0.99732398	1	1	1.16E+12	2.707E+14	0	0	1.144975	1.82857445
915417000	1	2.1	0	1	300	3300	1052107.71	9.63117E+14	0	0	0.1	0	0	1	0	9.63117E+14	0	0	0	0	0	0	0.000760034	0.999239966	1	1	1.16E+12	2.707E+14	0	0	0.631036289	3.555172816
347614531.3	1	3	0	1	400	1700	2115669.897	7.35438E+14	0	0	0.1	0	0	1	0	7.35438E+14	0	0	0	0	0	0	0.006434385	0.993565615	1	1	1.16E+12	2.707E+14	0	0	4.079386607	2.699318475
];

Res_RK=[285318000	1	2.7	0	1	2159	882	2.0683E-08	5.901226389	0	0	0.07	0	0	1	0	5.901226389	0	0	0	0	0	0.391467357	0.154712054	0.453820588	0.25	0.5	0.6	0.9	0	4.620275	1.521651429	2.97566448
31081900.39	1	2	0	1	4493	171	2.28999E-08	0.711772	0	0	0.07	0	0	1	0	0.711772	0	0	0	0	0	0.375272325	0.184683025	0.440044649	0.25	0.5	0.6	0.9	0	0.534216667	0.21908701	0.348012733
588185312.5	1	2	0	1	3000	300	2.35156E-08	13.83152485	0	0	0.07	0	0	1	0	13.83152485	0	0	0	0	0	0.536649679	0.321436645	0.141913676	0.25	0.5	0.6	0.9	0	14.84536674	7.409931579	2.18098059
204682734.4	1	1.7	0	1	1933	250	1.87031E-08	3.828208385	0	0	0.07	0	0	1	0	3.828208385	0	0	0	0	0.007004352	0.390524422	0.224559108	0.377912118	0.25	0.5	0.6	0.9	0.107256478	2.990017733	1.432765101	1.60747371
281111406.3	1	2	0	1	4570	853	1.76195E-08	4.953030045	0	0	0.07	0	0	1	0	4.953030045	0	0	0	0	0	0.819161152	0.095665311	0.085173537	0.25	0.4	0.5	0.9	0	10.14332449	0.947666316	0.46874121
1271850000	1	2.6	0	1	2158	1046	8.76116E-09	11.14288566	0.56	84.8	0.07	5.936	0	1	0	5.206885658	0	0	0	0	0.612718629	0.041869307	0.221437891	0.123974174	0.2	0.35	0.4	0.8	15.9517792	0.62288198	2.882504444	0.806899184
1032355000	1	2	0	1	80	3120	1.51893E-08	15.68075967	0.58	143.5	0.06	8.61	0	1	0	7.070759668	0	0	0	0	0.095006016	0.007738117	0.858613488	0.038642379	0.2	0.35	0.4	0.8	3.358823529	0.156326766	15.17762406	0.341538714
172386000	1	3.9	0	1	400	1700	1.25811E-08	2.16880293	0.23	6.075	0.08	0.486	0	1	0	1.68280293	0	0	0	0	0	0.019726693	0.918158375	0.062114932	0.2	0.35	0.4	0.8	0	0.094846104	3.86269901	0.130658987
168851343.8	1	4	0	1	1100	1900	2.0824E-08	3.516164468	0	0	0.07	0	0	1	0	3.516164468	0	0	0	0	0	0.410726985	0.51864623	0.070626785	0.2	0.35	0.35	0.8	0	4.126238947	5.210415556	0.31041924
814046437.5	1	2.7	0	1	300	2700	5.63684E-09	4.588650082	0.72	54.3	0.06	3.258	0	1	0	1.330650082	0	0	0	0	0.004895146	0.086863139	0.688370303	0.219871412	0.2	0.35	0.4	0.8	0.032568631	0.330241267	2.28995	0.36571489
915417000	1	2.1	0	1	300	3300	4.85138E-09	4.441031625	0.45	31.5	0.06	1.89	0	1	0	2.551031625	0	0	0	0	0.05348141	0.389738201	0.424054521	0.132725868	0.2	0.35	0.4	0.8	0.68216384	2.840669929	2.704441237	0.423234859
347614531.3	1	3	0	1	400	1700	1.42356E-08	4.94851297	0.23	16.5	0.07	1.155	0	1	0	3.79351297	0	0	0	0	0	0.214541962	0.731243814	0.054214223	0.2	0.35	0.4	0.8	0	2.325336335	6.934957232	0.25707795
];

Res_HW=[285318000	1	2.7	0	1	2159	882	9.56495E-08	27.29052033	0	0	0.07	0	0	1	0	27.29052033	0	0	0	0	0	0.550223798	0.122666519	0.327109682	0.4	0.5	0.55	0.9	0	30.0317875	6.086605714	9.9188816
31081900.39	1	2	0	1	4493	171	9.38075E-08	2.915714314	0	0	0.07	0	0	1	0	2.915714314	0	0	0	0	0	0.595464431	0.11807727	0.286458298	0.4	0.5	0.55	0.9	0	3.472408333	0.625962887	0.928033956
588185312.5	1	2	0	1	3000	300	5.541E-08	32.5913219	0	0	0.07	0	0	1	0	32.5913219	0	0	0	0	0.026353713	0.32074834	0.318302653	0.334595294	0.45	0.65	0.7	1	1.90867185	16.08248063	14.81986316	10.90490295
204682734.4	1	1.7	0	1	1933	250	7.15507E-08	14.64520139	0	0	0.07	0	0	1	0	14.64520139	0	0	0	0	0.018126059	0.421537884	0.472527161	0.087808896	0.45	0.65	0.7	1	0.589910629	9.497703386	9.886079195	1.285978968
281111406.3	1	2	0	1	4570	853	3.37204E-08	9.47917732	0	0	0.07	0	0	1	0	9.47917732	0	0	0	0	0.087888235	0.579617891	0.109970825	0.22252305	0.4	0.5	0.55	0.9	2.0827704	10.98860154	1.895332632	2.34370605
1271850000	1	2.6	0	1	2158	1046	4.38035E-09	5.571150825	0.56	31.8	0.07	2.226	0	1	0	3.345150825	0	0	0	0	0.23843139	0.125688006	0.430848203	0.205032401	0.35	0.45	0.5	0.85	2.2788256	0.93432297	2.882504444	0.806899184
1032355000	1	2	0	1	80	3120	3.17641E-09	3.279180106	0.58	26.25	0.06	1.575	0	1	0	1.704180106	0	0	0	0	0.413895772	0.051598892	0.26194456	0.272560776	0.35	0.45	0.5	0.85	2.015294118	0.195408457	0.892801415	0.546461943
172386000	1	3.9	0	1	400	1700	9.5681E-09	1.649405958	0.23	1.125	0.08	0.09	0	1	0	1.559405958	0	0	0	0	0	0.010165954	0.206419363	0.783414683	0.35	0.45	0.5	0.85	0	0.035228553	0.643783168	1.437248853
168851343.8	1	4	0	1	1100	1900	5.58691E-08	9.433568885	0	0	0.07	0	0	1	0	9.433568885	0	0	0	0	0	0.511757494	0.460272567	0.02796994	0.35	0.45	0.5	0.85	0	10.72822126	8.684025926	0.31041924
814046437.5	1	2.7	0	1	300	2700	8.64495E-09	7.037390058	0.72	72.4	0.06	4.344	0	1	0	2.693390058	0	0	0	0	0.021161103	0.110350574	0.637658291	0.230830032	0.35	0.45	0.5	0.85	0.162843156	0.660482533	3.434925	0.73142978
915417000	1	2.1	0	1	300	3300	8.64863E-09	7.917103394	0.45	63	0.055	3.465	0	1	0	4.452103394	0	0	0	0	0.214511949	0.251232661	0.404968318	0.129287071	0.35	0.45	0.5	0.85	2.72865536	2.485586188	3.605921649	0.677175775
347614531.3	1	3	0	1	400	1700	1.40732E-08	4.892040448	0.23	12	0.07	0.84	0	1	0	4.052040448	0	0	0	0	0	0.442698169	0.503374369	0.053927462	0.35	0.45	0.5	0.85	0	3.98629086	4.079386607	0.25707795
];


Res_tot=zeros(reg,33,nb_usage_res);

Res_tot(:,:,indice_chauffage)=Res_SH;
Res_tot(:,:,indice_clim)=Res_SC;
Res_tot(:,:,indice_frigo)=Res_RRF;
Res_tot(:,:,indice_electromenager)=Res_APPL;
Res_tot(:,:,indice_eclairage)=Res_RL;
Res_tot(:,:,indice_cuisine)=Res_RK;
Res_tot(:,:,indice_chauffEau)=Res_HW;

////////variable extraction

////volume variable (m2 for heating and air conditioning, population for other usage)
Res_Mref=Res_tot(:,1,:);

////general variables: identical for the 7 usage

//FINI coefficient (alpha = (1+Gini)/(1-Gini))
Res_alpharef=Res_tot(:,3,indice_chauffage);

//correction because of climate change: heating and cooling days
Res_HDDref=Res_tot(:,6,indice_chauffage);
Res_CDDref=Res_tot(:,7,indice_chauffage);
Res_climat=ones(reg,1,nb_usage_res);
Res_climat(:,:,indice_chauffage)=Res_HDDref;
Res_climat(:,:,indice_clim)=Res_CDDref;

////access rate to use equipment
Res_muref=Res_tot(:,2,:);

//equipment rate
Res_lambdaref=Res_tot(:,5,:);

//Gini equipment
Res_betaref=Res_tot(:,4,:);

////////// "non comemercial" energies

//Traditional energy
//share of population (or m2 for heating) using traditional biomass (zero for all following usage: space cooling, fridges, electric appliances et lighting)
Res_part_bioref=Res_tot(:,10,:);
//Final energy demand for traditional biomass, per usage
Res_DEF_bioref=Res_tot(:,11,:);
//total final energy demand for traditional biomass, per usage
Res_DEF_bio_totref=Res_DEF_bioref(:,:,indice_chauffage)+Res_DEF_bioref(:,:,indice_clim)+Res_DEF_bioref(:,:,indice_frigo)+Res_DEF_bioref(:,:,indice_electromenager)+Res_DEF_bioref(:,:,indice_eclairage)+Res_DEF_bioref(:,:,indice_cuisine)+Res_DEF_bioref(:,:,indice_chauffEau);
//Biomass efficiency
Res_rho_bioref=Res_tot(:,12,:);
//Energy services (usefull energy) for traditional biomass
Res_SE_bioref=Res_tot(:,13,:);

//modern energy (renewable)
//final energy demand for renewables (per usage)
Res_DEF_enrref=Res_tot(:,14,:);
//efficiencyh of renewables
Res_rho_enrref=Res_tot(:,15,:);
//energy services (usefull energy) for renewables
Res_SE_enrref=Res_tot(:,16,:);

/////////energy services
//energy services (usefull energy) given by "commercial" energies (tradional biomass and renewables excluded), per usage
Res_SE_comref=Res_tot(:,17,:);
//total energy services (usefull energy), per usage
Res_SE_totref=Res_tot(:,9,:);
//total unitary energy services
//per volume variable, to the equipment rate, and corrected by heating or cooling days
Res_SE_unitref=Res_tot(:,8,:);
//unitary energy services for biomass
//per volume variable (number of person, or m2, which uses biomass), to the equipment rate, and corrected by heating or cooling days
for k=1:reg,
    for j=1:nb_usage_res,
        if Res_part_bioref(k,1,j)==0 then Res_SE_unit_bioref(k,1,j)=0;
        else Res_SE_unit_bioref(k,1,j)=Res_SE_bioref(k,1,j)./(Res_part_bioref(k,1,j).*Res_Mref(k,1,j).*Res_climat(k,1,j).*Res_lambdaref(k,1,j));
        end
    end
end		
//unitary energy services  for commercial energy users
///per volume variable (number of person, or m2, which uses comemrcial energy)to the equipment rate, and corrected by heating or cooling days
Res_SE_unit_comref=Res_SE_comref./((1-Res_part_bioref).*Res_Mref.*Res_climat.*Res_lambdaref);

///////////////fixed technology costs
//Res_CFref=zeros(reg,4,7);
//for j=1:4,
//	Res_CFref(:,j,:)=Res_tot(:,17+j,:);
//end

/////////////share in the equipment parc, of the different technologies
Res_shref=zeros(reg,4,nb_usage_res);
for j=1:4,
    Res_shref(:,j,:)=Res_tot(:,21+j,:);
end

Res_sh_coalref=Res_tot(:,22,:);
Res_sh_gasref=Res_tot(:,23,:);
Res_sh_oilref=Res_tot(:,24,:);
Res_sh_elecref=Res_tot(:,25,:);

/////////////technology efficiency
Res_rhoref=zeros(reg,4,nb_usage_res);
for j=1:4,
    Res_rhoref(:,j,:)=Res_tot(:,25+j,:);
end

Res_rho_coalref=Res_tot(:,26,:);
Res_rho_gasref=Res_tot(:,27,:);
Res_rho_oilref=Res_tot(:,28,:);
Res_rho_elecref=Res_tot(:,29,:);

/////////////final energy demand per usage
Res_DEFref=zeros(reg,4,nb_usage_res);
for j=1:4,
    Res_DEFref(:,j,:)=Res_tot(:,29+j,:);
end

Res_DEF_coalref=Res_tot(:,30,:);
Res_DEF_gasref=Res_tot(:,31,:);
Res_DEF_oilref=Res_tot(:,32,:);
Res_DEF_elecref=Res_tot(:,33,:);


////////////finale energy demand by energy type, sum over usage
Res_DEF_coal_totref=Res_DEF_coalref(:,:,indice_chauffage)+Res_DEF_coalref(:,:,indice_clim)+Res_DEF_coalref(:,:,indice_frigo)+Res_DEF_coalref(:,:,indice_electromenager)+Res_DEF_coalref(:,:,indice_eclairage)+Res_DEF_coalref(:,:,indice_cuisine)+Res_DEF_coalref(:,:,indice_chauffEau);
Res_DEF_gas_totref=Res_DEF_gasref(:,:,indice_chauffage)+Res_DEF_gasref(:,:,indice_clim)+Res_DEF_gasref(:,:,indice_frigo)+Res_DEF_gasref(:,:,indice_electromenager)+Res_DEF_gasref(:,:,indice_eclairage)+Res_DEF_gasref(:,:,indice_cuisine)+Res_DEF_gasref(:,:,indice_chauffEau);
Res_DEF_oil_totref=Res_DEF_oilref(:,:,indice_chauffage)+Res_DEF_oilref(:,:,indice_clim)+Res_DEF_oilref(:,:,indice_frigo)+Res_DEF_oilref(:,:,indice_electromenager)+Res_DEF_oilref(:,:,indice_eclairage)+Res_DEF_oilref(:,:,indice_cuisine)+Res_DEF_oilref(:,:,indice_chauffEau);
Res_DEF_elec_totref=Res_DEF_elecref(:,:,indice_chauffage)+Res_DEF_elecref(:,:,indice_clim)+Res_DEF_elecref(:,:,indice_frigo)+Res_DEF_elecref(:,:,indice_electromenager)+Res_DEF_elecref(:,:,indice_eclairage)+Res_DEF_elecref(:,:,indice_cuisine)+Res_DEF_elecref(:,:,indice_chauffEau);
//total final energy demand (sum over energy type)
Res_DEF_totref=Res_DEF_coal_totref+Res_DEF_gas_totref+Res_DEF_oil_totref+Res_DEF_elec_totref;

Res_alpha=Res_alpharef;

Res_SE_unit=Res_SE_unitref;
Res_SE_unit_bio=Res_SE_unit_bioref;
Res_SE_unit_com=Res_SE_unit_comref;

Res_beta=Res_betaref;

Res_DEF_bio=Res_DEF_bioref;
Res_DEF_bio_tot=Res_DEF_bio_totref;
Res_SE_bio=Res_SE_bioref;
Res_part_bio=Res_part_bioref;

Res_mu=Res_muref;
Res_lambda=Res_lambdaref;
Res_lambda_prev=Res_lambda;

Res_M=Res_Mref;

Res_SE_tot=Res_SE_totref;
Res_SE_com=Res_SE_comref;

//average efficiency
Res_rho_coal=Res_rho_coalref;
Res_rho_gas=Res_rho_gasref;
Res_rho_oil=Res_rho_oilref;
Res_rho_elec=Res_rho_elecref;

Res_rho_coal_prev=Res_rho_coalref;
Res_rho_gas_prev=Res_rho_gasref;
Res_rho_oil_prev=Res_rho_oilref;
Res_rho_elec_prev=Res_rho_elecref;

//efficiency of new equipment
Res_rho_coal_exo=Res_rho_coalref;
Res_rho_gas_exo=Res_rho_gasref;
Res_rho_oil_exo=Res_rho_oilref;
Res_rho_elec_exo=Res_rho_elecref;

//share of eneryg in total equipment
Res_sh_coal=Res_sh_coalref;
Res_sh_gas=Res_sh_gasref;
Res_sh_oil=Res_sh_oilref;
Res_sh_elec=Res_sh_elecref;

//share of energy in new equipment
Res_part_coal_prev=Res_sh_coal;
Res_part_gas_prev=Res_sh_gas;
Res_part_oil_prev=Res_sh_oil;
Res_part_elec_prev=Res_sh_elec;

//final energy demand
Res_DEF_coal=Res_DEF_coalref;
Res_DEF_gas=Res_DEF_gasref;
Res_DEF_oil=Res_DEF_oilref;
Res_DEF_elec=Res_DEF_elecref;

Res_DEF_coal_tot=Res_DEF_coal_totref;
Res_DEF_gas_tot=Res_DEF_gas_totref;
Res_DEF_oil_tot=Res_DEF_oil_totref;
Res_DEF_elec_tot=Res_DEF_elec_totref;
Res_DEF_tot=Res_DEF_totref;

////share of population living under 2$ per day
Res_F2dollarsref=(2*365.*ones(reg,1)./Res_alpharef./(Rdispref./Ltot0.*1000000)).^(ones(reg,1)./(Res_alpharef-ones(reg,1)));
Res_F2dollars=Res_F2dollarsref;

//curve calibration giving the relation between the share of people using traditional biomass
// and the share of population living with less than 2$ per day
// form: part_bio=gamma*(F2dollars-a)^beta
Res_gamma_bioref=[1;1;1;1;1;1.12;0.8;0.8;1;1.12;1;1.12];
Res_beta_bioref=[0.7;0.7;0.7;0.7;0.7;0.7;0.7;0.7;0.7;0.7;0.7;0.7];
for j=1:nb_usage_res,
    Res_a_bioref(:,j)=Res_F2dollarsref-(Res_part_bioref(:,j)./Res_gamma_bioref).^(ones(reg,1)./Res_beta_bioref);
end
                           
////number of users per usage and per energy 
Res_N_coal=Res_sh_coalref.*(1-Res_part_bioref).*Res_Mref;
Res_N_gas=Res_sh_gasref.*(1-Res_part_bioref).*Res_Mref;
Res_N_oil=Res_sh_oilref.*(1-Res_part_bioref).*Res_Mref;
Res_N_elec=Res_sh_elecref.*(1-Res_part_bioref).*Res_Mref;

//energy efficiency of housing 
res_effHabitat=ones(reg,1,nb_usage_res);

//energy consumption per m2
alphaCoalm2ref=Res_DEF_coal_tot./stockbatimentref;
alphaGazm2ref=Res_DEF_gas_totref./stockbatimentref;
alphaEtm2ref=Res_DEF_oil_totref./stockbatimentref;
alphaelecm2ref=Res_DEF_elec_totref./stockbatimentref;

alphaCoalm2=alphaCoalm2ref;
alphaGazm2=alphaGazm2ref;
alphaEtm2=alphaEtm2ref;
alphaelecm2=alphaelecm2ref;

//real prices (to the composite price of each region)
for k=1:reg,
    p_prev_resid(k,:)=pArmDFref(k,:);
end	

///cost calibration, fixed and intangible, for technologies (average over similar energy consumption)
///to reproduce market shares
Res_CFref=zeros(reg,4,nb_usage_res);

Res_CF_coalref=Res_CFref(:,1,:);
Res_CF_gasref=Res_CFref(:,2,:);
Res_CF_oilref=Res_CFref(:,3,:);
Res_CF_elecref=Res_CFref(:,4,:);

Res_CF_coal=Res_CF_coalref;
Res_CF_gas=Res_CF_gasref;
Res_CF_oil=Res_CF_oilref;
Res_CF_elec=Res_CF_elecref;

//collective services (for heating in China)
SE_collectif=zeros(reg,1,nb_usage_res);
