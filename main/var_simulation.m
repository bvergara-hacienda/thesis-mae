%% ========================================================================
%                   vector autoregression simulation
% =========================================================================

  function data = var_simulation(data)
  
%% load input

   n     = data.n                                                         ; % n° of variables
   y     = data.y                                                         ; % data matrix
   p     = data.p                                                         ; % n° of lags
   h     = data.h                                                         ; % forecast horizon
   d     = data.d                                                         ; % n° of random draws
   sigu  = data.sigu                                                      ; % covariance matrix for innovations
   v     = data.v                                                         ; % intercept vector
   A     = data.A                                                         ; % lag-polynomial
   fcsig = data.fcsig                                                     ; % fan-chart significance levels   
   
%% simulate var

%  allocate memory
   mcf = zeros(h + 1,n,d)                                                 ; % monte-carlo forecasts
   mc  = zeros(h + p,n,d)                                                 ; % monte-carlo sample
   
%  generate waitbar
   wb = waitbar(0,'simulating var, please wait...')                       ;   
   
%  monte carlo simulation 
   for k = 1:d
       
%      update waitbar  
       waitbar(k/d,wb)                                                    ;     
       
%      add pre-sample values      
       mc(1:p,:,k) = y(end - p + 1:end,:)                                 ;  
       
%      draw gaussian shocks       
       shks = mvnrnd(zeros(n,1),sigu,h)                                   ;
       
%      simulated paths
       for t=1:h
         
%          deterministic term
           mc(t + p,:,k) = v'                                             ;
              
%          autoregressive terms
           for j=1:p
                  mc(t + p,:,k) = (mc(t + p,:,k)' +                       ... 
                                   A(:,:,j) * mc(t + p - j,:,k)')'        ;
           end
           
%          random terms
           mc(t + p,:,k) = mc(t + p,:,k) + shks(t,:)                      ;
           
       end       
       
%      save path (includes 1st pre-sample value)
       mcf(:,:,k) = mc(p:end,:,k)                                         ;
         
   end
   
%  close waitbar
   close(wb)       
    
%% confidence bands

%  n° of bands for fan-chart
   nb = numel(fcsig)                                                      ; 
   
%  allocate memory   
   lbf = zeros(h + 1,n,nb)                                                ; % lower bands for simulated paths
   ubf = zeros(h + 1,n,nb)                                                ; % upper bands for simulated paths

%  loop through var variables
   for j=1:n
       
%      loop through fan-chart bands       
       for k=1:nb
           lbf(:,j,k) = prctile(squeeze(mcf(:,j,:))',100 * (1 - fcsig(k)) / 2,1)';
           ubf(:,j,k) = prctile(squeeze(mcf(:,j,:))',100 * (1 + fcsig(k)) / 2,1)';
       end
   end   

   
   
%% save output

   data.mcf = mcf                                                         ;
   data.lb  = lbf                                                         ;
   data.ub  = ubf                                                         ;
   data.nb  = nb                                                          ;
   data.lbf = lbf                                                         ;
   data.ubf = ubf                                                         ;
   
   end