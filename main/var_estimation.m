%% ========================================================================
%                   vector autoregression estimation
% =========================================================================

  function data = var_estimation(data)
  
%% load input

   T = data.T                                                             ; % sample size
   n = data.n                                                             ; % n° of variables
   y = data.y                                                             ; % data matrix
   p = data.p                                                             ; % n° of lags

%% degrees of freedom

   Tadj = T - p                                                           ; % adjusted sample size (excludes lagged observations)
   df   = Tadj - n * p - 1                                                ; % degrees of freedom for estimation

%  case df < 0
   if df < 0
       error(['degrees of freedom (df) need to > 0: df = ' num2str(df)])
   end
  
%% construction of Y, y and Z
%  for technical note see: lutkepohl (2005), new introduction to multiple 
%                          time series analysis, page 70.

%  construction of yvec
   Y    = y(p + 1:end,:)'                                                 ;   
   yvec = vec(Y)                                                          ;

%  contruction of Z
   Z = ones(T - p,1)                                                      ; 

   for i=1:p
       Z = [Z y(p - i+1:end-i,:)]                                         ;
   end
   
   Z = Z'                                                                 ; 
   
%% multivariate least squares estimator
%  for technical note see: lutkepohl (2005), new introduction to multiple 
%                          time series analysis, pages 71-72 and 80.

   beta     =  kron((Z * Z') \ Z , eye(n)) * yvec                         ; % coefficients (vectorized)
   B        = (Y * Z') / (Z * Z')                                         ; % coefficients (matrix form)
   yhat     = (B * Z)'                                                    ; % fitted values
   res      =  Y' - yhat                                                  ; % residuals
   sigu     =  res' * res / df                                            ; % covariance matrix for residuals
   gammavar =  Z * Z' / Tadj                                              ; % covariance matrix for variables
   Bcov     =  kron(gammavar^(-1) , sigu) / Tadj                          ; % covariance matrix for parameters
   Bse      =  sqrt(diag(Bcov))                                           ; % std. error vector for paramters
  
%% companion form matrix
%  for technical note see: lutkepohl (2005), new introduction to multiple 
%                          time series analysis, page 15.

   big1  = eye(n * p - n,n * p - n)                                       ;
   big0  = zeros(n * p - n,n)                                             ;
   Acomp = [B(:,2:end);big1 big0]                                         ;
  
%% stability 
%  for technical note see: lutkepohl (2005), new introduction to multiple 
%                          time series analysis, pages 16-17.

   if max(abs(eig(Acomp))>= 1) == 1
      stab = 0                                                            ;
      disp('estimated var coefficients unstable.')
   else
      stab = 1                                                            ;
      disp('estimated var coefficients stable.')
   end  
  
%% t-statistics and p-values
%  for technical note see: lutkepohl (2005), new introduction to multiple 
%                          time series analysis, page 80.

   tstat  = B./ reshape(Bse,n,n * p + 1)                                  ;
   onemat = ones(n,n * p + 1)                                             ;
   pval   = 2 * (onemat - tcdf(abs(tstat),df))                            ;
   
%% A and v matrices (used in simulation)

%  intercept vector
   v = B(:,1)                                                             ;  
   
%  lag-polynomial   
   A    = zeros(n,n,p)                                                    ;  
   cont = 1                                                               ; 
   
   for i=2:n:1 + n * p
       A(:,:,cont) = B(:,i:i + n - 1)                                     ;
       cont        = cont + 1                                             ;
   end   
   
%% long-run values

%  allocate memory
   aux = zeros(n)                                                         ;   

%  loop through lags
   for i=1:p
       aux = aux + A(:,:,i)                                               ;
   end
   
%  unconditional mean vector
   mu = (eye(n) - aux)^(-1) * v                                           ;
   
%% save output

   data.Tadj     = Tadj                                                   ; 
   data.df       = df                                                     ;
   data.beta     = beta                                                   ;
   data.B        = B                                                      ;
   data.yhat     = yhat                                                   ;
   data.res      = res                                                    ;
   data.sigu     = sigu                                                   ;
   data.gammavar = gammavar                                               ;
   data.Bcov     = Bcov                                                   ;
   data.Bse      = Bse                                                    ;
   data.Acomp    = Acomp                                                  ;
   data.stab     = stab                                                   ;
   data.tstat    = tstat                                                  ;
   data.pval     = pval                                                   ;
   data.v        = v                                                      ;
   data.A        = A                                                      ;
   data.mu       = mu                                                     ;
   data.Z        = Z                                                      ;
   
  end