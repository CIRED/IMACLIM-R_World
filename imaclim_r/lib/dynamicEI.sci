// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Julie Rozenberg
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function EI = dynamicEI (iter, iterNumber, nonEnergSectors, energSectors, reg, EI)
	// FUNCTION HEADER
	// Author	: Ruben Bibas
	// Date		: 06/2/2009
	// Title	: dynamicEI.sci
	// Inputs	: I1. iter 				: current iteration number
	//		: I2. iterNumber			: total iteration number
	//		: I3. nonEnergSectors = indice_BTP:sec;	: indexes of non energy sectors
	//		: I4. energSectors = 1:5;		: indexes of energy sectors
	//		: I5. reg				: number of regions
	// Outputs	: O1. EI				: todo à écrire
	
	
	// PREAMBLE: INPUTS VALIDITY TESTS
	[nl, nr] = argn(0);
	if ~(nr==6&nl==1) then
	    error("Call with:  EI = dynamicEI(iter, iterNumber, nonEnergSectors, energSectors, reg)");
	end
	if type(iter) ~= 1 then
	    error("Expecting a real input, got a " + typeof(iter));
	end
	if size(iter, "*") ~= 1 then
	    sz = size(iter);
	    error("Expecting a scalar, got a " ..
	      + sz(1) + "x" + sz(2) + " matrix")
	end
	if type(iterNumber) ~= 1 then
	    error("Expecting a real input, got a " + typeof(iter));
	end
	if size(iterNumber, "*") ~= 1 then
	    sz = size(iterNumber);
	    error("Expecting a scalar, got a " ..
	      + sz(1) + "x" + sz(2) + " matrix")
	end
	if type(nonEnergSectors) ~= 1 then
	    error("Expecting a real input, got a " + typeof(iter));
	end
	//todo: test à écrire
	if type(energSectors) ~= 1 then
	    error("Expecting a real input, got a " + typeof(iter));
	end
	//todo: test à écrire
	if type(reg) ~= 1 then
	    error("Expecting a real input, got a " + typeof(iter));
	end
	if size(reg, "*") ~= 1 then
	    sz = size(reg);
	    error("Expecting a scalar, got a " ..
	      + sz(1) + "x" + sz(2) + " matrix")
	end
	
	
	regions = [1:reg];
    // FUNCTION BODY
	if iter==1 then
		// First iteration:
		// 1. Variables creation
		EI		= ones(reg,sec,iterNumber);
		// 4. Definition of reference values
		//Energy intensity of production in all sectors
		EI(:,:,iter)    = EI_ref(:,:);
		timeOffset	= zeros(reg,sec);
		for region = regions
			for sect = nonEnergSectors
				X(region,sect) = PindEnerToX_n(pIndEner,region,sect)
				//X(region,sect) = 15;
			end
		end
		
		// 2.2. Speed of catch up
		muEi = zeros(reg,sec);

		for region = regions
			for sect = [6,7,11,12]
                if (iter<25)&(region>4)&(~testCoherence(region,sect)) then
                    leadObjective = EIleadt0(sect);
                else leadObjective = EIleadt0plusX(sect);
                end
                //calibreMu(level,leadEv,EIt0,EIleadt0,EIleadt0plusX,offset,X,Y,iter)
                muEi(region,sect)		= calibreMu_n(finalLevel(sect),..
                leaderEvolution(sect)   ,..
                EI_ref(region,sect)     ,..
                EIleadt0(sect)          ,..
                leadObjective           ,..
                timeOffset(region,sect) ,..
                X(region,sect)          ,..
                Y(region,sect)          ,..
                iter); // Correspond à en X années, j'ai fait Y% du chemin entre 2001 et asymptote donc muEi = f(X,Y)
							// et on voudra à la fin Y = g(P_indEner) pour avoir leaderEvolution = h(P_indEner)
			end
		end
		
	else
		regions = 1:reg;
		timeOffset	= zeros(reg,sec);
		// Iterations 2 to N
		// Evolution for each sector
		muEi = zeros(reg,sec);
        
		for region = regions
			for sect = [6,7,11,12]
			if (iter<25)&(region>4)&(~testCoherence(region,sect)) then
                    leadObjective = EIleadt0(sect);
                else leadObjective = EIleadt0plusX(sect);
                end
                X(region,sect) = PindEnerToX_n(pIndEner,region,sect);
                //calibreMu(level,leadEv,EIt0,EIleadt0,EIleadt0plusX,offset,X,Y,iter)
                muEi(region,sect)		= calibreMu_n(finalLevel(sect),..
                leaderEvolution(sect)   ,..
                EI_ref(region,sect)     ,..
                EIleadt0(sect)          ,..
                leadObjective           ,..
                timeOffset(region,sect) ,..
                X(region,sect)          ,..
                Y(region,sect)          ,..
                1); // Correspond à en X années, j'ai fait Y% du chemin entre 2001 et asymptote donc muEi = f(X,Y)
							// et on voudra à la fin Y = g(P_indEner) pour avoir leaderEvolution = h(P_indEner)
			end
		end
		//disp(X,'X');
		//disp(muEi,'muEi');
		for sect = nonEnergSectors
			// 1. Evolution of the leader
			EI(leader(sect),sect,iter)	= EI(leader(sect), sect, iter-1) * PindEner2leaderEv(pIndEner,leader(sect),sect, leaderEvolution(sect));
			// 2. Followers catch up
			for region=regions([1:leader(sect)-1,leader(sect)+1:reg])
				EI(region, sect, iter) = EI(region, sect, iter-1) * leaderEvolution(sect) / finalLevel(sect)...
				* (finalLevel(sect)*muEi(region,sect)^(iter-timeOffset(region,sect))+..
			 	   EI(leader(sect), sect, iter-1)/ EI(region, sect, iter-1) * (1-muEi(region,sect)^(iter-timeOffset(region,sect))));
			end
		end
		
	end
endfunction;
