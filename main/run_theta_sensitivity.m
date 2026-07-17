%% ========================================================================
%     risk premium sensitivity analysis - alpha x theta grid
% =========================================================================
%
%  reproduces figures:
%     a0_theta0.9.pdf   (alpha_spec = 0, theta = 0.90)
%     a0_theta0.95.pdf  (alpha_spec = 0, theta = 0.95)
%     a1_theta0.9.pdf   (alpha_spec = 1, theta = 0.90)
%     a1_theta0.95.pdf  (alpha_spec = 1, theta = 0.95)
%
%  requirements:
%     run main.m first, up to (and including) the base run:
%        data = prepare_sample(data)
%        data = var_estimation_restricted(data)
%        data = var_simulation(data)
%     i.e. everything needed BEFORE fiscal_simulation(data) is called.
%     'data' must therefore already be in the workspace when you run this
%     script.

%  ensure output is saved in the same folder as the other figures
   cd(fileparts(mfilename('fullpath')))

%  grid of scenarios
   alpha_grid = [0 1]                                                     ;
   theta_grid = [0.90 0.95]                                               ;

%  loop through all combinations
   for a = alpha_grid
       for th = theta_grid

           fprintf('running alpha_spec = %d, theta = %.2f ...\n',a,th)    ;

           data_s = fiscal_simulation_theta(data,a,th)                    ;
           plot_theta_sensitivity(data_s)                                 ;

       end
   end

   fprintf('done. check a0_theta0.9.pdf, a0_theta0.95.pdf, a1_theta0.9.pdf and a1_theta0.95.pdf\n') ;
