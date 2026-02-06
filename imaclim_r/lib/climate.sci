// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc, Yann Gaucher
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

/// Adapted from FaIRv1.6.3 ///

function t1 = forcing_to_temperature(t0, q, d, f)
    // Calculate temperature from a given radiative forcing.
    // This follows the forcing-to-temperature function described in Millar et al. (2015; 2017).
  
    // Inputs:
    // t0: Temperature in timestep t-1
    // q: The matrix contributions to slow and fast temperature change (2-element array)
    // d: The slow and fast thermal response time constants (2-element array)
    // f: Radiative forcing (scalar or 1D array for multiple species)
  
    // Keywords:
    // e: Efficacy factor (default 1). If f is an array, e should have the same dimensions.  
    e = 1.0; // Default value for e

  
    t1 = t0 .* exp(-1.0 ./ d) + q .* (1.0 - exp((-1.0) ./ d)) .* sum(f .* e);
endfunction


function q = calculate_q(tcrecs, d, f2x, tcr_dbl, nt)
    // Calculate the q model coefficients from TCR and ECS.
    // See Eqs. (4) and (5) of Millar et al ACP (2017).
    // Inputs:
    // tcrecs  : 2-element array of TCR and ECS
    // d       : The slow and fast thermal response time constants
    // f2x     : Effective radiative forcing from a doubling of CO2
    // tcr_dbl : Time to a doubling of CO2 under 1% per year CO2 increase, in years
    // nt      : Number of timesteps
  
    k = 1.0 - (d ./ tcr_dbl) .* (1.0 - exp(-tcr_dbl ./ d));
  
    // Check dimensionality of tcrecs 
    q = (1.0 / f2x) .* (1.0 ./ (k(1) - k(2))) .* [tcrecs(:,1) - tcrecs(:,2) .* k(2),tcrecs(:,2) .* k(1) - tcrecs(:,1)];
endfunction

function IRFdiff = iirf_interp(alp_b)
    // Calculate iIRF based on the decay time constants
    irf_arr = alp_b * sum(a .* tau .* (1.0 - exp(-iirf_h ./ (tau .* alp_b))));
    // Difference between calculated and target iIRF
    IRFdiff = irf_arr - iirf;
endfunction

function Ddiff = Diirf_interp(alp_b) 
    // Calculate jacobian of iIRF based on the decay time constants
    iirf_arr = alp_b.* sum(a .* tau .* ( -iirf_h./(tau.*(alp_b**2)).*exp(-iirf_h ./ (tau .* alp_b))));
    // Difference between calculated and target iIRF
    Ddiff = iirf_arr - iirf;
endfunction

function [c1, c_acc1, carbon_boxes1, time_scale_sf] = carbon_cycle(e0, c_acc0, temp, r0, rc, rt, iirf_max, time_scale_sf0, a, tau, iirf_h, carbon_boxes0, c_pi, c0, e1)
    // Calculate the time-integrated airborne fraction
    iirf = min(r0 + rc * c_acc0 + rt * temp, iirf_max);
    // Solve for the scaling factor time_scale_sf using a root-finding algorithm
    time_scale_sf = fsolve(time_scale_sf0, iirf_interp, Diirf_interp);
    //    disp(time_scale_sf);
    // Update tau with the scaling factor
    tau_new = tau .* time_scale_sf;
  
    // Update the carbon stored in atmospheric reservoirs
    carbon_boxes1 = carbon_boxes0 .* exp(-1.0 ./ tau_new) + (a .* e1) ./ ppm_gtc;
    // Calculate the concentration of CO2
    c1 = sum(carbon_boxes1) + c_pi;
    // Update the cumulative airborne carbon anomaly
    c_acc1 = c_acc0 + 0.5 * (e1 + e0) - (c1 - c0) .* ppm_gtc;
endfunction

function F = co2_log(C, Cpi, F2x)
    F = F2x / log(2) * log(C / Cpi);
endfunction

function [T, restart_out_val] = update_temp(emissions, other_rf, restart_in)
    // Constants
    ppm_gtc = 2.1288833966171903    ; // GtC/ppm
    // Model parameters
    q = [0.33, 0.41];
    //tcrecs = [1.6, 2.75]; //Standard values from FaIRv1.6.3
    tcrecs = [1.79,3.2] // Median constrained values (Leach et al. 2021, GMD)
    d = [239, 4.1];
    F2x = 3.71;
    tcr_dbl = 69.661;
    a = [0.2173, 0.224, 0.2824, 0.2763];
    tau = [1.000e+06, 3.944e+02, 3.654e+01, 4.304e+00];
    r0 = 35.0;
    rc = 0.019;
    rt = 4.165;
    iirf_max = 97.0;
    iirf_h = 100.0;
    C_pi = [278.];
    e=1;
    // Dimensions and initializations
    ngas = 1;
    nF = 1;
    nt = 1;
    carbon_boxes_shape = size(a, '*'); // Number of carbon boxes
    thermal_boxes_shape = size(d, '*'); // Number of thermal boxes
    scale = ones( 1);

    q = calculate_q(tcrecs, d, F2x, tcr_dbl, nt);
  
    // Allocate intermediate and output arrays
    F = 0;
    C_acc = 0;
    T_j = zeros( thermal_boxes_shape);
    T = zeros( 1);
    C_0 = C_pi; // Copy pre-industrial concentrations
    C = 0;
    R_i = zeros(carbon_boxes_shape);

    // Extract restart values
    R_minus1 = restart_in(1);
    T_j_minus1 = restart_in(2);
    C_acc_minus1 = restart_in(3);
    E_minus1 = restart_in(4);
    time_scale_sf = restart_in(5);
    // Emissions for CO2 only mode
    emissions0 = emissions(1);
    co2_minus1 = sum(R_minus1) + C_0(1);
    // Call carbon_cycle function
    [C, C_acc, R_i, time_scale_sf] = carbon_cycle(E_minus1, C_acc_minus1, sum(T_j_minus1), r0, rc, rt, iirf_max, time_scale_sf, a, tau, iirf_h, R_minus1, C_pi(1), co2_minus1, emissions0);
    // Calculate forcings from concentrations
    F = co2_log(C, C_pi(1), F2x) + other_rf;
    F = F * scale(1);
    // Calculate temperature response
    T_j = T_j_minus1 .* exp(-1.0 ./ d) + q .* (1.0 - exp((-1.0) ./ d)) .* sum(F.* e);
    T(1) = sum(T_j(:));

    // Prepare restart output
    E_minus1 = emissions($); // Last emission value
    restart_out_val = list(R_i($, :), T_j($, :), C_acc($), E_minus1, time_scale_sf);
    if verbose >=1
        message('        For last period, global emissions (GtC): '+ emissions0+', Global temperature Change='+T(1)+' °C')
    end
endfunction

/// DAMAGE FUNCTIONS ///



function damage = COACCH_R(b1,b2,T) //no damages on the energy sector
    T=T-0.6; //Provide global mean temperature (impacts coefficients are already region-dependent) //COACCH is parameterized with regard to the 1986-2005 level of warming, hence the 0.6°C offset
    T0=1.16-0.6; //TODO maybe change to have productivity loss = 0 in 2014 (for consistency with the model calibration)
    damage=ones(reg,sec)
    secdam=(b1*T+b2*T^2-(b1*T0+b2*T0.^2))/100; //same damage for non-energy sectors within a region
    for s = nbsecteurenergie+1:sec
        damage(:,s)=secdam;
    end
endfunction

function damage = Damage_Dasg(he,le,T) // Damage function on labor supply from shouro dasgupta. Here we assume that damages affect labour productivity because it is not possible to target labor supply in a sector-specific way.
    HE=[1 1 1 1 1 1 0 0 0 0 1 0]; // High exposure sectors are all energy sectors, construction & agriculture
    LE=[0 0 0 0 0 0 1 1 1 1 0 1]; // Low exposure sectors are  all transport sectors, services & industry.
    damage=he(:,1)*(HE.*T')+he(:,2)*(HE.*T'^2)+le(:,1)*(LE.*T')+le(:,2)*(LE.*T'^2);
endfunction 


function damage = COACCH_R_Energ(b1,b2,T) //damages for all sectors
    T=T-0.6; //Provide global mean temperature (impacts coefficients are already region-dependent) //COACCH is parameterized with regard to the 1986-2005 level of warming, hence the 0.6°C offset
    T0=1.16-0.6; //TODO maybe change to have productivity loss = 0 in 2014 (for consistency with the model calibration)
    damage=ones(reg,sec)
    secdam=(b1*T+b2*T^2-(b1*T0+b2*T0.^2))/100; //same damage for all sectors within a region
    for s = 1:sec
        damage(:,s)=secdam;
    end
endfunction
