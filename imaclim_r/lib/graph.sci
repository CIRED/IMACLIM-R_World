// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas, Adrien Vogt-Schilb
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function [] = graph(var,unit)
clf
binaryTest = m_ind_climat==1;
output = eval(var);
timeSpan = 1:50;
// plot(2000+timeSpan,output(:,timeSpan)/unit,'k','linewidth',3);
_hold on;
_plot(2000+timeSpan,output(~binaryTest,timeSpan)/unit,'k','linewidth',3);
_plot(2000+timeSpan,output(binaryTest,timeSpan)/unit,'r','linewidth',3);
_hold off;
_grid on;
title(var,'font_size',8);
set(gca(),'font_size',4);
xs2png(gcf(),'png'+filesep()+var);
endfunction
