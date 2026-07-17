%% ========================================================================
%   Estimation of a Prudent Public Debt Level for Chile
%   MSc thesis project — Autonomous Fiscal Council (CFA), Chile
%
%                   Modelo de Sostenibilidad Fiscal
% =========================================================================
%
%  Autor: Benjamín Vergara
%  Fecha  : Septiembre 2022
%
%% housekeeping
 
   clear
   clc
   close all
   delete *.asv

%  work from this script's folder (portable, no absolute paths)
   cd(fileparts(mfilename('fullpath')))

%% data and utilities paths

   addpath('../utilities')
   data.file     = '../data/base var.xlsx'                                ;
   data.adr_file = '../data/age_dependency.xlsx'                          ;
   
%% settings

%  set seed for random number generator
   rng(18121991)
   
%  vector autogression
   data.p      = 1                                                        ; % lag order 
   data.fobs   = 2005.00                                                  ; % first observation in sample
   data.lobs   = 2019.25                                                  ; % last observation in sample
   data.vnames = {'$r_{t}^{d}$'                                           ; % variable names
                  '$r_{t}^{f}$'                                           ; 
                  '$reer_{t}$'                                            ; 
                  '$g_{t}$'                                               ;
                  '$tot_{t}$'}                                            ; 
                
              
   data.rnames = {'$\varepsilon_{t}^{rd}$'                                ; % residual names
                  '$\varepsilon_{t}^{re}$'                                ;
                  '$\varepsilon_{t}^{reer}$'                              ;  
                  '$\varepsilon_{t}^{g}$'                                 ;
                  '$\varepsilon_{t}^{tot}$'}                              ;                                         ;
                                  
%%  fiscal reaction function [preliminary values for Chile]

%  coefficients   
   data.pers   =  0.4887                                                  ; % persistance of primary balance
   data.rho    =  0.0277                                                  ; % coefficient for lagged debt
   data.gamma  =  0.1839                                                  ; % coefficient for output gap
   
   data.tg     =   0.5861                                                 ; % coefficient for tot gap
   data.adro   =  -0.0263                                                 ; % coefficient for age dependency ratio 
   data.fadro  =  -0.1281                                                 ; % coefficient for future age dependency ratio - old 
   
   b_inflation =  0                                                       ; % coefficient for inflation
   b_pol_stab  =  0                                                       ; % coefficient for political stability
   b_lib_dem   =  0                                                       ; % coefficient for liberal democracy
   b_reg_qual  =  0                                                       ; % coefficient for regulatory quality  
   
   data.rho2   =  0                                                       ; % coefficient for lagged debt squared
   data.rho3   =  0                                                       ; % coefficient for lagged debt cubed
   
   data.eta    =  2.4906 + 1.7471                                         ; % country fixed effect
   
   data.sigpbs =   1.94                                                   ; % std. error for primary balance shock
    
%%  stock-flow equation
   data.frc    =  1 - 0.38                                                ; % domestic to total debt ratio (1-0.38)
   data.d0     =  52                                                      ; % initial value for debt to gdp ratio (Debt del 2022) 38.27 (WEO Abril). 36.2  WEO October
   data.pb0    =  -1.4                                                    ; % initial value for primary balance as % of gdp (PB del 2022) -1.49 (WEO Abril) 0.9  WEO October
   
   %  intercept  
   inflation   =  3                                                       ; % constant input for inflation
   pol_stab    =  0.2672                                                  ; % constant input for political stability
   lib_dem     =  0.8174                                                  ; % constant input for liberal democracy index
   reg_qual    =  1.2668                                                  ; % constant input for regulatory quality
   
   data.alpha  =  b_inflation*inflation + b_pol_stab*pol_stab + ...
                  b_lib_dem*lib_dem + b_reg_qual*reg_qual                 ;
   
%  other capital requirements    
   data.sigokr = sqrt(0)                                                  ; % residual variance of other capital requirements 0.5279
   data.okrc   = 0                                                        ; % intercept for other capital requirements 0.4232

%  age dependency interpolation   
   data.interp   = 'makima'                                               ; % for trajectories with gradual stabilization use makima and 0 , 
   data.int_year = 0                                                      ; % for trajectories with instant stabilization use linear and 2 
   
%  simulation excercise
   data.h      =  104                                                      ; % forecast horizon, 4, 8, 12, 16...
   data.d      =  5000                                                    ; % random draws
   data.fcsig  = [.15 .3 .5 .75 .90 .95]                                ; % fan-chart significance levels   
   data.areac  = [0.2 0.2  0.2]                                             ; % color of area for highest signifiance level
   data.areas  =  0.03                                                    ; % tone reduction for next significance level
 
%  restrictions matrix                                                      
   data.zero_r = [ 0 0 0 0 0; ...                                           
                   1 0 1 1 1; ...
                   0 0 0 0 0; ...
                   0 0 0 0 0; ...
                   1 0 1 1 0]                                             ;
                  
   
%% run application
   
   data = prepare_sample(data)                                            ;
   
%  simulate economy
   data = var_estimation_restricted(data)                                 ; 
   data = var_simulation(data)                                            ;
   data = fiscal_simulation(data)                                         ;
   
%  simple graph   
   plot_fitted(data)
   plot_var_simulation(data)
   plot_fiscal_simulation(data) 

   max(data.ubr(:,6))
   max(data.ubd(:,6)) 

   
%%  double graph      
   data2 = data                                                           ;
   data2.d0 = 36.2                                                        ;
   data2.areac  = [0.5 0.5 1]                                             ;
   
%  change age dependency interpolation   
   data2.interp   = 'previous'                                            ; 
   data2.int_year = 2                                                     ;   

   data2 = prepare_sample(data2)                                          ;
   data2 = var_estimation_restricted(data2)                               ;  
   data2 = var_simulation(data2)                                          ;
   data2 = fiscal_simulation(data2)                                       ;
   
   plot_double_simulation(data,data2) 
   max(data2.ubr(:,6)) 
      
%%  triple graph  

   data3 = data                                                           ;
   data3.areac  = [0.5 0.5 1]                                             ;
   
%  age dependency interpolation   
   data3.interp   = 'linear'                                              ; 
   data3.int_year = 2                                                     ;   

   data3 = prepare_sample(data3)                                          ;
   data3 = var_estimation_restricted(data3)                               ; 
   data3 = var_simulation(data3)                                          ;
   data3 = fiscal_simulation(data3)                                       ;
   plot_triple_simulation(data,data2,data3)
 

   
   