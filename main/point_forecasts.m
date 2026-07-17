%% ========================================================================
%                 vector autoregression point forecasts
% =========================================================================

  function data = point_forecasts(data)
  
%% load input

   n     = data.n                                                         ; % n° of variables
   y     = data.y                                                         ; % data matrix
   p     = data.p                                                         ; % n° of lags
   h     = data.h                                                         ; % forecast horizon
   v     = data.v                                                         ; % intercept vector
   A     = data.A                                                         ; % lag-polynomial 
   alpha = data.alpha                                                     ; % intercept for fiscal reaction function
   rho   = data.rho                                                       ; % coefficient for lagged debt in fiscal reaction function
   gamma = data.gamma                                                     ; % coefficient for output gap in fiscal reaction function
   mu    = data.mu                                                        ; % long-run values  
   eta   = data.eta                                                       ; % country fixed effect   
   d0    = data.d0                                                        ; % initial value for gross debt as % of gdp 
   pb0   = data.pb0                                                       ; % initial value for primary balance as % of gdp
   frc   = data.frc                                                       ; % domestic to total debt ratio  
   pers  = data.pers                                                      ; % persistance of primary balance
   rho2  = data.rho2                                                      ; % coefficient for lagged debt squared
   rho3  = data.rho3                                                      ; % coefficient for lagged debt cubed
   tg    = data.tg                                                        ; % coefficient for tot gap
   adr   = data.adr                                                       ; % data for adr forecast
   fadr  = data.fadr                                                      ; % data for fadr forecast
   adro  = data.adro                                                      ; % coefficient for adr old  
   fadro = data.fadro                                                     ; % coefficient for fadr old  
   okrc  = data.okrc                                                      ; % constant of other capital requirements process    
 
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
   
   %%  save annualized version of point forecasts   

   ha   = abs(h/4)                                                        ; % annualized forecast horizon
   
   % pre-sample value (for p = 1) 
   apfy =zeros(ha + 1, 4)                                                 ;  
   apfy(1,1) = (1+y(end,1)/100)*(1+y(end - 1,1)/100)*...
       (1+y(end - 2,1)/100)*(1+y(end - 3,1)/100)                          ;
   
   apfy(1,2) = (1+y(end,2)/100)*(1+y(end - 1,2)/100)*...
       (1+y(end - 2,2)/100)*(1+y(end - 3,2)/100)                          ;
   
   apfy(1,3) = mean(y(end - 3: end,3))                                    ;
   
   apfy(1,4) = (1+y(end,4)/100)*(1+y(end - 1,4)/100)*...
       (1+y(end - 2,4)/100)*(1+y(end - 3,4)/100)                          ;
   
   apfy(1,5) = mean(y(end - 3: end,5))                                    ;
   
   % annualize forecasts 
   for t = 4:4:h 
       apfy(t/4 + p,1) = (1+pfy(t + p,1)/100)*(1+pfy(t + p - 1,1)/100)*...
       (1+pfy(t + p - 2,1)/100)*(1+pfy(t + p - 3,1)/100)  -1              ; % compound domestic real interest rates annualy
   
       apfy(t/4 + p,2) = (1+pfy(t + p,2)/100)*(1+pfy(t + p - 1,2)/100)*...
       (1+pfy(t + p - 2,2)/100)*(1+pfy(t + p - 3,2)/100) -1               ; % compound foreign real interest rates annualy
   
       apfy(t/4 + p,3) = mean(pfy(t + p - 3: t + p,3))                    ; % mean of real effective exchange rate annualy
       
       apfy(t/4 + p,4) = (1+pfy(t + p,4)/100)*(1+pfy(t + p - 1,4)/100)*...     
       (1+pfy(t + p - 2,4)/100)*(1+pfy(t + p - 3,4)/100)   -1             ; % compound real growth annualy
   
       apfy(t/4 + p,5) = mean(pfy(t + p - 3: t + p,5))                    ; % mean of real effective exchange rate annualy
   end 
   
%% fiscal variable point forecasts  
   
%  allocate memory
   pfd = zeros(ha + 1,1)                                                  ;
   pfr = zeros(ha + 1,1)                                                  ;
   
%  initialize
   pfd(1) = d0                                                            ;
   pfr(1) = pb0                                                           ; 
   
%  loop through forecast horizon
   for t=1:ha
       
%          non-fiscal variables
           rd   = apfy(p + t,1)                                           ; % domestic interest rate (real)
           re   = apfy(p + t,2)                                           ; % external interest rate (real)
           drer = apfy(p + t,3) - apfy(p + t - 1,3)                       ; % effective exchage rate (real)
           g    = apfy(p + t,4)                                           ; % gdp growth (real)  
           totg = (apfy(p + t,5)/mu(end) - 1)  *100                        ; % tot (real) 
           
%          default probability 
           dprob = 0                                                      ;                
           if pfd(t) > 0 && pfd(t) < 100                                   
           debt_interp = [0 50 77.9 78.9 79.5 80.5 81.8 83.1 88.4 100 150];  
           prob_interp = [0 0 0.01 0.05 0.1  0.25 0.5  0.75 1 1 1]        ;
           debtq = pfd(t)                                                 ;
           dprob = interp1(debt_interp,prob_interp,debtq,'makima')        ;
           end
           if pfd(t) >= 100
               dprob = 1                                                  ;
           end    
           
%          risk premium    
           theta = 1                                                    ; % tasa de recuperación

%          coefiente aversión al riesgo CCRRA alhpa
%          alpha = 0 
           phi = 1/(1-dprob + dprob*theta)                                ;  
           
%          alpha = 1 
           %phi = theta ^(-p)                                             ;            
           
%          alpha = 2 
           %phi = 1 - p + p/theta                                         ;                         
      
%          fiscal reaction function inputs 
           gss = mu(end-1)                                                ; % long-run growth
           gap = g - gss                                                  ; % output gap
           
%          fiscal reaction function           
           pfr(t + 1) = alpha + rho * pfd(t) + gamma * gap + eta + pers * pfr(t) +tg * totg +...
           rho2 * pfd(t).^2 + rho3 * pfd(t).^3 + adro * adr(t)+ fadro * fadr(t);    
           
%          stock flow equation           
           pfd(t + 1) = ( ((1 + re) * (1 + drer) * (1 - frc) * pfd(t) + ...
                         (1 + rd) * frc * pfd(t)) * phi ) / (1 + g)   - ...
                          pfr(t + 1) + okrc                               ;
                      
                
                      
   end
   
 
%% save output
   
   data.pfy = pfy                                                         ;
   data.pfd = pfd                                                         ;
   data.pfr = pfr                                                         ;
   
   end
   