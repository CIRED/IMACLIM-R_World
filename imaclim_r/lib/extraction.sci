// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Nicolas Graves, Adrien Vogt-Schilb, Céline Guivarch, Olivier Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


function out=getcars(salstock,regs,technos,time)
//renvoie les ventes ou les stocks à l'année i des voitures, dans les regions, des technos, et les années données
//salstock =='sale' ou 'stock'

//init

    //Stock des voitures effectivement présentes dans le par à l'année i, ventilé par région et techno
    // stock_car_ventile = zeros ( reg, nb_techno_cars, TimeHorizon+1);
    global stock_car_ventile
    if stock_car_ventile==[]
        ldsav( 'stock_car_ventile')
    end

    ////Générations de voitures par region, technologie et année de vente
    global stockVintageAutoTechno
    if stockVintageAutoTechno==[]
        ldsav( 'stockVintageAutoTechno'); //stockVintageAutoTechno=zeros(reg,nb_techno_cars,TimeHorizon+1);
    end

    //verification de l'arg salestock
    if salstock =='sale'
        mat = stockVintageAutoTechno;
    elseif salstock =='stock'
        mat = stock_car_ventile;
    else
        error ( 'wrong salstock')
    end
    
    //verif du time
    if argn(2)<4
        time =1:TimeHorizon+1
    end    
    //verif du time
    if argn(2)<3
        technos =1:nb_techno_cars
    end
    //verif du time
    if argn(2)<2
        regs =1:reg
    end
    
    for i=1:size(time,'*')
        out(:,i)=matrix(mat(regs,technos,time(i))',-1,1)
    end

endfunction
