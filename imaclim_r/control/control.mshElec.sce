// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

disp([..
["MSH";regnames],..
["730 "      ; string(squeeze(ceil( MSH_730_elec(:,23)*1000)/10))],..
["2190"      ; string(squeeze(ceil(MSH_2190_elec(:,23)*1000)/10))],..
["3650"      ; string(squeeze(ceil(MSH_3650_elec(:,23)*1000)/10))],..
["5110"      ; string(squeeze(ceil(MSH_5110_elec(:,23)*1000)/10))],..
["6570"      ; string(squeeze(ceil(MSH_6570_elec(:,23)*1000)/10))],..
["8030"      ; string(squeeze(ceil(MSH_8030_elec(:,23)*1000)/10))],..
["8760"      ; string(squeeze(ceil(MSH_8760_elec(:,23)*1000)/10))],..
["730_seq"   ; string(squeeze(ceil( MSH_730_elec(:,24)*1000)/10))],..
["2190_seq"  ; string(squeeze(ceil(MSH_2190_elec(:,24)*1000)/10))],..
["3650_seq"  ; string(squeeze(ceil(MSH_3650_elec(:,24)*1000)/10))],..
["5110_seq"  ; string(squeeze(ceil(MSH_5110_elec(:,24)*1000)/10))],..
["6570_seq"  ; string(squeeze(ceil(MSH_6570_elec(:,24)*1000)/10))],..
["8030_seq"  ; string(squeeze(ceil(MSH_8030_elec(:,24)*1000)/10))],..
["8760_seq"  ; string(squeeze(ceil(MSH_8760_elec(:,24)*1000)/10))]..
]);
