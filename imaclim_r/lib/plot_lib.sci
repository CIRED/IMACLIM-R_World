// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Julie Rozenberg, Adrien Vogt-Schilb
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function plotreg(mat,regs,pos)
// plot comprehensible de series regionales en une seule ligne
// plotreg(L, [regs, [pos]])
// L: matrice imaclim reg*something
// regs: optionel. vecteur. indice des regions à prendre en compte. par default, 1:reg.
// pos: optionel (3 par defaut). a quel endroit mettre la boite de legend. voir help legend.
// pour posistioner la legend à la main, mettre pos=5. Mais faites help legend pour comprendre.

if argn(2)<3
    pos=3
end
if argn(2)<2
    regs=1:reg
end
  
  plot(mat(regs,:)')
  legend(regnames(regs),pos)
endfunction

function nice_plot ( title_str,xlabs_str, ylabs_str, is2030)
//Nice (but quite specific) format plot function
//Met un gros titre, une etiquette des x, une etiquette des y
// Tous les arguments sont optionels
//examples
// nice_plot  (sans argument) : ecrit les années à partir de 2000 sur les X
//nice_plot ('hy') : x axes and plot title 
//nice_plot( 'world price', 'dollars per baril') :  cool x axe, cool y axe, plot title
//nice_plot( 'world price', 'dollars per baril', %f) :  NO x axe, cool y axe, plot title

	a=get("current_axes")
	a.font_size=4;
	//a.font_style=8;
	if argn(2)<4
		is2030=%f;
	end
	if argn(2)<3
		ylabs_str='';
	end
	if argn(2)<2
		xlabs_str='';
	end
	if argn(2)<1
		title_str='';
	end

	xlabs(xlabs_str,is2030);
	ylabs('');
	bigtitle(title_str);
    xgrid(31)
    
    plot(0)
    xset('wdim',580*.9,510*0.85)
endfunction

function xlabs(str,is2030)
//Draw '2000 2005 ... 2050' in the x axes. works only with an apropriate sized plot
//called by nice_plot
	a=get("current_axes")
	if ~isdef ( 'is2030')
		is2030=%f;
	end
    
    if argn(2)<1
        str = '';
    end
    
    a.x_label.font_size=2;
	
	if str==''
		a.x_label.text='';
		//a.x_label.font_style=8;
		if ~is2030
			a.x_ticks.labels= string( [2000:5:2050]' );
			a.x_ticks.labels= [ '2000' '' '2010' '' '2020' '' '2030' '' '2040' '' '2050' ]
		else
			a.x_ticks.labels= string( [2000:5:2030]' );
		end
	else
		a.x_label.text=str;
		//a.x_label.font_style=8;
	end
endfunction

function ylabs(str)
//Writes str as the y_label on a plot
//Called by nice_plot

	a=get("current_axes")
	//a.y_label.font_style=8;
	a.y_label.font_size=4;
	a.y_label.text=str;
endfunction

function  bigtitle(str)
//Plot title with a reasonable font size

	a=get("current_axes")
	//a.title.font_style=8;
	a.title.text=str;
	a.title.font_size=5;
endfunction


function curve_style(mycolor,mystyle,mythickness,mystylestyle)
//Choose color and style (line or mark)
//The two first arguments are compulsory, the others are optional
//To see the color list, help color_list
//mystyle is 'mark' or 'line'
//mythickness is the thickness of the line or mark
//mystylestyle is the style of the line (see help line_style) or the mark (see help mark_style)

	if ~isdef ( 'mycolor')
		mycolor='navy blue';
	end
	if ~isdef ( 'mystyle')
		mystyle='line';
	end
	if ~isdef ( 'mythickness')
		mythickness=3;
	end
	if ~isdef ( 'mystylestyle')
		mystylestyle=1;
	end
	if type(mythickness) 	~= 1	then error("Expecting a real input, got a " + typeof(mythickness));		end
	if type(mystylestyle) 	~= 1	then error("Expecting a real input, got a " + typeof(mystylestyle));		end
	if type(mycolor) 	~= 10	then error("Expecting a string input, got a " + typeof(mycolor));		end
	if type(mystyle) 	~= 10	then error("Expecting a string input, got a " + typeof(mystyle));		end
	e=gce();
	p=e.children;
	if mystyle=='line'
		p.mark_mode = "off";
		p.line_mode = "on";
		p.line_style = mystylestyle;
		p.foreground = color(mycolor);
		p.thickness = mythickness;
	elseif mystyle=='mark'
		p.mark_mode = "on";
		p.line_mode = "off";
		p.mark_size_unit = "point";
		p.mark_style = mystylestyle;
		p.mark_foreground = color(mycolor);
		p.mark_background = color(mycolor);
		p.mark_size = mythickness;
	else
		disp ( 'error in curve_style, mystyle should be ''line'' or ''mark''');
	end
	
endfunction

function plot_percentiles(mat,per,mycolor)
//plots a median and the percentiles that you wish from a group of data
//per can be one number between 0 and 1 or a matrix of numbers between 0 and 1 if you want to plot
//several percentiles (on the same curve)
//ex: plot_percentiles(m_wp_oil_n(:,2:$),[0.75 0.95],'spring green')
//be careful, the function already transposes the matrix that you want to plot, so don't do it twice.

	if per(1)>1 & per(1)<0 then disp ( 'error, second argument should be a matrix of reals between 0 and 1'); end
	mediane_vect=median (mat,'r');
	size_vect=size(mat,'r');
	mat_tmp=gsort (mat,'r','i');
	plot (mediane_vect')
	curve_style(mycolor,'line',3,1);
	if per==[0] then return end		
	for i=1:size(per,'*')
		execstr ( 'per_1'+i+'=mat_tmp(floor(per(i)*size_vect),:)');
		execstr ( 'per_2'+i+'=mat_tmp($-floor(per(i)*size_vect),:)');
		execstr( 'plot(per_1'+i+''')');
		curve_style(mycolor,'line',1,2);
		execstr( 'plot(per_2'+i+''')');
		curve_style(mycolor,'line',1,2);
	end
endfunction

function plot_percentiles2(mat,per,mycolor,mystyle)
	if per(1)>1 & per(1)<0 then disp ( 'error, second argument should be a matrix of reals between 0 and 1'); end
	mediane_vect=median (mat,'r');
	size_vect=size(mat,'r');
	mat_tmp=gsort (mat,'r','i');
	plot (mediane_vect')
	curve_style(mycolor,'line',3,1);
	if mycolor~='black'
		plot (mediane_vect')
		curve_style(mycolor,'mark',6,mystyle);
	end
	if per==[0] then return end		
	for i=1:size(per,'*')
		execstr ( 'per_1'+i+'=mat_tmp(floor(per(i)*size_vect),:)');
		execstr ( 'per_2'+i+'=mat_tmp($-floor(per(i)*size_vect),:)');
		execstr( 'plot(per_1'+i+''')');
		curve_style(mycolor,'line',1,1);
		if mycolor~='black'
			execstr( 'plot(per_1'+i+''')');
			curve_style(mycolor,'mark',2,mystyle);
		end
		execstr( 'plot(per_2'+i+''')');
		curve_style(mycolor,'line',1,1);
		if mycolor~='black'
			execstr( 'plot(per_2'+i+''')');
			curve_style(mycolor,'mark',2,mystyle);
		end
	end
endfunction

function plot_bin(var,unit,binaryString,timeSpan)
//Plot la variable dont le nom est m_var en deux couleurs en fonction de la valeur de binaryString
//demander de l'aide à Adrien

    output = eval('m_' + var)/unit;

    if argn(2)<4
        timeSpan =:
    end
    
if argn(2)<3
            binaryString = '[]';
end

    binaryTest = eval(binaryString)
        
    clf
    if sum(~binaryTest) //evite les erreurs pour cause de matrice vide
        plot(output(~binaryTest,timeSpan)','k','thickness',2);
    end
   
    if sum(binaryTest)
        plot(output(binaryTest,timeSpan)','r','thickness',2);
    end
    
    if binaryTest==[]
         plot(output(:,timeSpan)','thickness',3);
    end
    
    nice_plot ( var+' '+binaryString,'',string(unit))
    xs2png(gcf(),'png'+filesep()+var);
endfunction

function plot_means(var,unit, varargin)
//plot des spaguettis gris avec des gros traits de couleurs.
//var : string. Il faut qu'une matrice m_ existe avec le meme nom.
//unit : nombre. unité des m_var
//varargin : liste de string contenant le nom des tests.
//demander un exemple a adrien

    output = eval('m_' + var)/unit;

    clf();
    plot(output','thickness',2);
    
    if argn(2)<2
        unit=1
    end
    
    
    if length(varargin)>0
      curve_style('gray','line',2)
    end
    
    nice_plot ( var,'',string(unit))
       
    color_list = [ 'blue' 'scilab red2' 'scilab green3' 'orange' 'scilab magenta3' ]
    
    nam_mofis = ''    
    for ipm=1:length(varargin)
        which = evstr(varargin(ipm))
        plot( mean(output(which,:),'r'),'thickness',4);
        curve_style(color_list(ipm))
        nam_mofis = nam_mofis+varargin(ipm)+'_'
    end
    xs2png(gcf(),var+'_shows_'+nam_mofis);
endfunction

function plot_pastout(var,unit,binaryString,varargin)
//meme chose que plot_means mais en ne gardant qu'une sous partie des m_series
// hc plot_means

    output = eval('m_' + var)/unit;
        timeSpan =:
       
    if argn(2)<3
            binaryString = '[]';
    end

    binaryTest = eval(binaryString)
        
    clf   
    if sum(binaryTest) //si pas vide
        plot(output(binaryTest,timeSpan)','thickness',2);
    end
    
    //si ya des means derriere, alors on met ceux la en gris
    if length(varargin)>0
      curve_style('gray','line',2)
    end
    
    color_list = [ 'blue' 'scilab red2' 'scilab green3' 'orange' 'scilab magenta3' ]
    
    nam_mofis = ''    
    for ipm=1:length(varargin)
        which = evstr(varargin(ipm))
        plot( mean(output(binaryTest & which,:),'r'),'thickness',4);
        curve_style(color_list(ipm))
        nam_mofis = nam_mofis+varargin(ipm)+'_'
    end
    
    nice_plot ( var,'',string(unit))
    xs2png(gcf(),var+'_ONLY_'+binaryString+'_shows_'+nam_mofis);

endfunction
