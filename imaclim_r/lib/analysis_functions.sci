// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Nicolas Graves, Thibault Briera, Adrien Vogt-Schilb, Julie Rozenberg, Céline Guivarch, Renaud Crassous, Henri Waisman, Olivier Sassi
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// scilab function that define mathematical fonctions
// (to manipulate of build temporal series, for example)

//TABLE OF CONTENTS
// discount
// mean_grow_rate
// gompertz_curve
// smooth_transition
// mob_mean
// rand_sort
// traj_from_points
// split_obj_MKT2reg
// new_lin_dlog
// lin_dlog
// MSH_limit_newtechno
// Modified_logit

function [y]=discount(vect,rate)
    //Discounted sum of stacked time series
    //rate is given as a % (rate=4 actually means discount rate is 0.04)
    vect_year=ones(size(vect,'r'),1)* ( 1:(size(vect,'c')));
    y=sum(vect.*ones(vect)./(ones(vect)+rate/100).^(vect_year-1),'c');
endfunction

function y=growth_rate(temp_stack)
    //temp_stack : stacked time series (n,TimeHorizon)
    //growth rate
    y = diff(temp_stack,1,2)./(temp_stack(:,1:$-1)+%eps)
    y(temp_stack(:,1:$-1)==0)=0;
endfunction


//Average growth rate  gr=mean_grow_rate(temp_stack[,t_st, [t_nd]])
function gr=mean_grow_rate(temp_stack,t_st, t_nd)
    //temp_stack : a matrix. Stacked temporal series 
    //t_nd :  optional. Last index taken into account (default is $-like)
    //t_st :  optional. First index taken into account (default is 1)
    
    //preamble
    if argn(2)<3
        t_nd = size(temp_stack,2)
        if argn(2)<2
            t_st = 1
        end
    end

    //actual work
    gr=exp ( log(temp_stack(:,t_nd)./temp_stack(:,t_st))./(t_nd-t_st))-1;
endfunction

function y=gompertz_curve(b,c,gdppc)
    //S shaped curve for the equipment rate
    //a is the saturation level
    //b control the delay before the take off period
    //c is the wealth multiplier
    //
    //guess: b = -6
    //c= - 0.25/k$

    y= exp(b*exp(c*gdppc))

endfunction

function y=smooth_transition(t_st,t_en,ser_1,ser_2,tol)
    //generates a smooth transition passing by (-inf, 0) (t_st, tol) ( t_en, (1-tol)) (inf, 1), where 0 is ser_1 and 1 is ser_2
    if argn(2)<5
        tol=5/100;
    end
	
    if or(size(ser_1)~=size(ser_2)) then
        error( 'smooth_transition: size don''t match.')
    end
    x=1:size(ser_1,'c');
    t_de = atanh(1-2*tol);
    coef=ones(size(ser_1,1),1)*(1+tanh(-t_de + (x-t_st)./(t_en-t_st)*2 * t_de))/2;
    y = (1-coef).*ser_1 + coef.* ser_2
endfunction

function y=mob_mean(x,n,optionString)
    //moving average
    // x: stacked time series matrix (nb_series*TimeHorizon)
    // n: interger of years
    // y: matrix of stacked time series, average on n
    // At the edges, the series are extended linearly
    if ~isdef('optionString')
        optionString = 'lin'
    end

    nn=(n-1)/2 //size of edges
    s=size(x,2) //horizontal size (temporal)
    y=zeros(size(x,1),s+nn) //output
    for j=1:size(x,1)
        //border treatment
        select optionString
        case 'lin' //lin: linear extrapolation
            xx=interpln ( [1:s; x(j,:)] , (1-nn):(s+nn)) 
        case 'cst' //constant extrapolation
            xx= [ x(j,1)*ones(1,nn) x(j,:) ones(1,nn)*x(j,$)];
        end
        for i=1:s
            y(j,nn+i)=sum( [zeros(1,i-1 ) ones(1,n) zeros(1,s-i)].*xx )/n; //mean on n years
        end
    end
    y=y(:,(1:s)+nn) //output
endfunction

function x=rand_sort(x)
    //Randomizes a matrix row by row
    n=size(x,2)
    for i=1:size(x,1)
        for k=1:(size(x,2)*4)
            i1=grand(1,1,'uin',1,n)
            i2=grand(1,1,'uin',1,n)
			
            tmp=x(i1);
            x(i,i1)=x(i2);
            x(i,i2)=tmp;
        end
    end
endfunction

function [y] = MSH_limit_newtechno(Tstart,Tniche,Tgrowth,Tmature,MSHmax,current_time)
    if Tstart == %inf
        y = 0;
    else
        y=interpln([[Tstart,Tstart+Tniche,Tstart+Tniche+Tgrowth,Tstart+Tniche+Tgrowth+Tmature,max(TimeHorizon+1,Tstart+Tniche+Tgrowth+Tmature)];..
        [0.005,max(0.005,MSHmax*0.05),MSHmax*0.9,MSHmax,MSHmax]],current_time);
        y=max(0,y);
    end
endfunction

function [y] = modified_logit(x,gammaML,varargin)
    shares = varargin(1)
    gamma_ML = gammaML*ones(x);
    nbtechno = size(x,"c");
    nbreg = size(x,"r");
    shares_w = zeros(nbreg,nbtechno);
    
    if  isempty(shares)
        
        y = x.^(-gamma_ML)./(sum(x.^(-gamma_ML),"c")*ones(1,nbtechno));
    else
        if  size(shares,1) >=2
            shares_w = shares; //allow for world weights/regional weights
        else
            shares_w = repmat(shares,nbreg,1);
        end
        
        y = shares_w.*(x.^(-gamma_ML))./(sum(shares_w.*(x.^(-gamma_ML)),"c")*ones(1,nbtechno));
    end

endfunction



function [y]= test_ML(x,varargin)
    shares = varargin
    if isempty(shares) 
        y = x
    else
        y = shares(1)
    end
    
endfunction

