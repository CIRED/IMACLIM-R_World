// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Adrien Vogt-Schilb, Nicolas Graves, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================


function out=getcars(salstock,regs,technos,time)
    //compute sells and stock of cars at year i, by regions, technology and given years
    //salstock =='sale' or 'stock'

    //init

    //Cars stock that are effectively in the car parc, spread across regions and technology
    // stock_car_ventile = zeros ( reg, nb_techno_cars, TimeHorizon+1);
    global stock_car_ventile
    if stock_car_ventile==[]
        ldsav( 'stock_car_ventile')
    end

    ////car generation by region, technology and year of sales
    global stockVintageAutoTechno
    if stockVintageAutoTechno==[]
        ldsav( 'stockVintageAutoTechno'); //stockVintageAutoTechno=zeros(reg,nb_techno_cars,TimeHorizon+1);
    end

    //checking the argument salestock
    if salstock =='sale'
        mat = stockVintageAutoTechno;
    elseif salstock =='stock'
        mat = stock_car_ventile;
    else
        error ( 'wrong salstock')
    end
    
    //time check
    if argn(2)<4
        time =1:TimeHorizon+1
    end    
    //time check
    if argn(2)<4
        if argn(2)<3
            technos =1:nb_techno_cars
        end
        //time check
        if argn(2)<2
            regs =1:reg
        end
    
        for i=1:size(time,'*')
            out(:,i)=matrix(mat(regs,technos,time(i))',-1,1)
        end
    end
endfunction
