%% ========================================================================
%     simulation for fiscal variables - risk premium sensitivity analysis
% =========================================================================
%
%  this is the same monte-carlo simulation as fiscal_simulation.m, but it
%  lets the recovery rate (theta) and the CRRA risk-aversion specification
%  (alpha_spec) be set by the caller, instead of hard-coding theta = 1 and
%  the alpha = 0 formula for phi. it is used to reproduce the risk-premium
%  sensitivity figures:
%
%     a0_theta0.9.pdf   -> alpha_spec = 0, theta = 0.90
%     a0_theta0.95.pdf  -> alpha_spec = 0, theta = 0.95
%     a1_theta0.9.pdf   -> alpha_spec = 1, theta = 0.90
%     a1_theta0.95.pdf  -> alpha_spec = 1, theta = 0.95
%
%  usage:
%     data_s = fiscal_simulation_theta(data, alpha_spec, theta)
%
%  inputs:
%     data       : struct produced after running prepare_sample,
%                  var_estimation_restricted and var_simulation (i.e. the
%                  same 'data' used right before calling fiscal_simulation)
%     alpha_spec : CRRA risk-aversion specification for the sovereign risk
%                  premium phi:
%                    0 -> phi = 1 / (1 - dprob + dprob*theta)
%                    1 -> phi = theta ^ (-dprob)
%     theta      : sovereign debt recovery rate, e.g. 0.90 or 0.95
%                  (theta = 1 means no haircut / risk-free, which is the
%                  baseline case used in fiscal_simulation.m)

   function data = fiscal_simulation_theta(data,alpha_spec,theta)

%% load input

   d0     = data.d0                                                       ; % initial value for gross debt as % of gdp
   pb0    = data.pb0                                                      ; % initial value for primary balance as % of gdp
   mcf    = data.mcf                                                      ; % simulated paths for non-fiscal variables
   frc    = data.frc                                                      ; % domestic to total debt ratio
   p      = data.p                                                        ; % n° of lags
   y      = data.y                                                        ; % data matrix
   v      = data.v                                                        ; % intercept vector
   A      = data.A                                                        ; % lag-polynomial
   h      = data.h                                                        ; % forecast horizon
   d      = data.d                                                        ; % n° of random draws
   n      = data.n                                                        ; % n° of variables
   alpha  = data.alpha                                                    ; % intercept for fiscal reaction function
   rho    = data.rho                                                      ; % coefficient for lagged debt in fiscal reaction function
   gamma  = data.gamma                                                    ; % coefficient for output gap in fiscal reaction function
   mu     = data.mu                                                       ; % long-run values
   sigpbs = data.sigpbs                                                   ; % std. error for primary balance shock
   nb     = data.nb                                                       ; % n° of bands for fan-chart
   fcsig  = data.fcsig                                                    ; % fan-chart significance levels
   eta    = data.eta                                                      ; % country fixed effect
   pers   = data.pers                                                     ; % persistance of primary balance
   rho2   = data.rho2                                                     ; % coefficient for lagged debt squared
   rho3   = data.rho3                                                     ; % coefficient for lagged debt cubed
   tg     = data.tg                                                       ; % coefficient for tot gap
   adr    = data.adr                                                      ; % coefficient for age dependency ratio - old
   fadr   = data.fadr                                                     ; % coefficient for future age dependency ratio - old
   adro   = data.adro                                                     ; % coefficient for adr old
   fadro  = data.fadro                                                    ; % coefficient for fadr old
   okrc   = data.okrc                                                     ; % constant of other capital requirements process
   sigokr = data.sigokr                                                   ; % residual variance of other capital requirements

%  check risk-aversion specification
   if ~ismember(alpha_spec,[0 1])
       error('alpha_spec must be 0 or 1.')
   end

%% non-fiscal variable point forecasts

%  allocate memory
   pfy        = zeros(h + p,n)                                            ;
   pfy(1:p,:) = y(end - p + 1:end,:)                                      ;

%  loop through forecast horizon
   for t=1:h

%     deterministic term
      pfy(t + p,:) = v'                                                   ;

%     autoregressive terms
      for j=1:p
          pfy(t + p,:) = (pfy(t + p,:)' + A(:,:,j) * pfy(t + p - j,:)')'  ;
      end

   end

%  save point forecasts including 1st pre-sample value
   pfy = pfy(p:end,:)                                                     ;


   %%  annualized simulations

%  annualized forecast horizon
   ha   = abs(h/4)                                                        ;

%  allocate memory
   amcf = zeros(ha + 1, n, d)                                             ;

%  add pre-sample values (for p = 1)
   for k = 1:d
       amcf(1,1,k) = (1+y(end,1)/100)*(1+y(end - 1,1)/100)*...
           (1+y(end - 2,1)/100)*(1+y(end - 3,1)/100)                      ;
       amcf(1,2,k) = (1+y(end,2)/100)*(1+y(end - 1,2)/100)*...
           (1+y(end - 2,2)/100)*(1+y(end - 3,2)/100)                      ;
       amcf(1,3,k) = mean(y(end - 3:end,3))                               ;
       amcf(1,4,k) = (1+y(end,4)/100)*(1+y(end - 1,4)/100)*...
           (1+y(end - 2,4)/100)*(1+y(end - 3,4)/100)                      ;
       amcf(1,5,k) = mean(y(end - 3:end,5))                               ;
   end

%  annualization
   for k = 1:d
       for t = 4:4:h
           amcf(t/4 + p,1,k) = (1+mcf(t + p,1,k)/100)*(1+mcf(t + p - 1,1,k)/100)*...
           (1+mcf(t + p - 2,1,k)/100)*(1+mcf(t + p - 3,1,k)/100)  - 1        ; % compound real interest rates annualy

           amcf(t/4 + p,2,k) = (1+mcf(t + p,2,k)/100)*(1+mcf(t + p - 1,2,k)/100)*...
           (1+mcf(t + p - 2,2,k)/100)*(1+mcf(t + p - 3,2,k)/100)  - 1     ; % compound real interest rates annualy

           amcf(t/4 + p,3,k) = mean(mcf(t + p - 3: t + p,3,k))            ; % mean of real effective exchange rate annualy

           amcf(t/4 + p,4,k) = (1+mcf(t + p,4,k)/100)*(1+mcf(t + p - 1,4,k)/100)*...
           (1+mcf(t + p - 2,4,k)/100)*(1+mcf(t + p - 3,4,k)/100)   - 1    ; % compound real growth annualy

           amcf(t/4 + p,5,k) = mean(mcf(t + p - 3: t + p,5,k))             ; % mean of tot annualy
       end
   end

%% simulate fiscal variables

%  allocate memory
   mcd = zeros(ha + 1,d)                                                  ; % gross debt to gdp
   mcr = zeros(ha + 1,d)                                                  ; % primary balance to gdp

%  initial values
   mcd(1,:) = d0                                                          ; % gross debt
   mcr(1,:) = pb0                                                         ; % fiscal reaction function

%  generate waitbar
   wb = waitbar(0,sprintf('simulating fiscal variables (alpha = %d, theta = %.2f), please wait...',alpha_spec,theta)) ;

%  annualized periods
   ha = abs(h/4)                                                          ;

%  monte carlo simulation
   for k = 1:d

%      update waitbar
       waitbar(k/d,wb)                                                    ;

%      simulated paths
       for t=1:ha

%          non-fiscal variables
           rd   = amcf(t + 1,1,k)                                         ; % domestic interest rate (real)
           re   = amcf(t + 1,2,k)                                         ; % external interest rate (real)
           drer = amcf(t + 1,3,k) - amcf(t,3,k)                           ; % effective exchage rate (real)
           g    = amcf(t + 1,4,k)                                         ; % gdp growth (real)
           totg = (amcf(t + 1,5,k)/mu(end) - 1 )*100                      ; % tot index (real)

%          default probability
           dprob = 0                                                      ;
           if mcd(t,k) > 0 && mcd(t,k) < 100
           debt_interp = [0 50 77.9 78.9 79.5 80.5 81.8 83.1 88.4 100 150];
           prob_interp = [0 0 0.01 0.05 0.1  0.25 0.5  0.75 1 1 1]        ;
           debtq = mcd(t,k)                                               ;
           dprob = interp1(debt_interp,prob_interp,debtq,'makima')        ;
           end
           if mcd(t,k) >= 100
               dprob = 1                                                  ;
           end

%          risk premium (recovery rate theta is now a function input)

%          coeficiente aversion al riesgo CRRA alpha (alpha_spec is a function input)
           if alpha_spec == 0
               phi = 1/(1-dprob + dprob*theta)                            ; % alpha = 0
           else
               phi = theta ^(-dprob)                                      ; % alpha = 1
           end

%          fiscal reaction function inputs
           shk = sigpbs*randn                                             ; % primary balance gaussian shock (equivalent to mvnrnd(0,sigpbs^2), much faster for a scalar draw)
           gss = mu(end - 1)                                              ; % long-run growth
           gap = g - gss                                                  ; % output gap

%          fiscal reaction function
           mcr(t + 1,k) = alpha + rho * mcd(t,k) + gamma * gap + eta + shk + tg * totg +  ...
           pers * mcr(t,k) + rho2 * mcd(t,k).^2 + rho3 * mcd(t,k).^3 + adro * adr(t) +  ...
           fadro *fadr(t);

%          other capital requirements
           osk = sigokr*randn                                             ; % other capital requirements gaussian shock (equivalent to mvnrnd(0,sigokr^2), much faster for a scalar draw)
           okr = okrc + osk                                               ;

           % stock flow equation
           mcd(t + 1,k) =(((1 + re) * (1 + drer) * (1 - frc) * mcd(t,k) + ...
                           (1 + rd) * frc * mcd(t,k)) * phi  )/ (1 + g)   - ...
                           mcr(t + 1,k) + okr                             ;
       end

   end

%  close waitbar
   close(wb)

%% confidence bands

%  allocate memory
   lbd = zeros(ha + 1,nb)                                                 ; % lower bands for simulated debt paths
   ubd = zeros(ha + 1,nb)                                                 ; % upper bands for simulated debt paths
   lbr = zeros(ha + 1,nb)                                                 ; % lower bands for simulated fiscal reaction function paths
   ubr = zeros(ha + 1,nb)                                                 ; % upper bands for simulated fiscal reaction function paths

%  loop through fan-chart bands
   for k=1:nb
       lbd(:,k) = prctile(mcd',100 * (1 - fcsig(k)) / 2,1)'               ;
       ubd(:,k) = prctile(mcd',100 * (1 + fcsig(k)) / 2,1)'               ;
       lbr(:,k) = prctile(mcr',100 * (1 - fcsig(k)) / 2,1)'               ;
       ubr(:,k) = prctile(mcr',100 * (1 + fcsig(k)) / 2,1)'               ;
   end

%  point forecast is the mean of all simulations
   pfd = median(mcd',1)                                                   ;
   pfr = median(mcr',1)                                                   ;
   pfd = pfd'                                                             ;
   pfr = pfr'                                                             ;

%% save output

   data.dbt        = mcd                                                  ;
   data.frf        = mcr                                                  ;
   data.lbd        = lbd                                                  ;
   data.ubd        = ubd                                                  ;
   data.lbr        = lbr                                                  ;
   data.ubr        = ubr                                                  ;
   data.pfd        = pfd                                                  ;
   data.pfr        = pfr                                                  ;
   data.pfy        = pfy                                                  ;
   data.alpha_spec = alpha_spec                                           ;
   data.theta      = theta                                                ;

   end
