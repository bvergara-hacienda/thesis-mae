%% ========================================================================
%                   vector autoregression estimation
% =========================================================================

%% description
%
% usage:
%   [data,info] = var_estimation(data,info)
%
% reference: 
%   lutkepohl (2005), new introduction to multiple time series analysis, pp. 69-80.
%

  function data = var_estimation_restricted(data)
  
%% load input

   T = data.T                                                             ; % sample size
   n = data.n                                                             ; % n° of variables
   y = data.y                                                             ; % data matrix
   p = data.p                                                             ; % n° of lags
   h = data.h                                                             ; %horizonte                      
   zero_r = data.zero_r                                                   ; %matriz restricciones                     
%
%% constant term 
  
  % constant term
  cons = ones(T+h,1)                                                      ;
  trend   = []                                                            ;
  dummies = []                                                            ;
  
  % deterministic terms matrix
  det_terms_full = [cons trend dummies]                                   ;
  det_terms      = det_terms_full(1:end-h,:)                              ;
  det_terms_f    = det_terms_full(end-h+1:end,:)                          ;
  n_det          = size(det_terms_full,2)                                 ;
 
  
  %% check for block exogeneity restrictions
 
% n° of restrictions (deterministc terms do not allow restrictions)
  zero_r = [zeros(n*n_det,1);vec(zero_r(:,1:n*p))] ;
  M        = sum(sum(zero_r))                                             ;

    if M == 0
      disp('model estimated with ols.')
    else
      disp('model estimated with egls.')
    end
  
% check if function name for printed messages
  [f_info,~] = dbstack                                                    ;
  f_size     = size(f_info,1)                                             ;
%% degrees of freedom

   Tadj = T - p                                                           ; % adjusted sample size (excludes lagged observations)
   df   = Tadj - n * p - 1                                                ; % degrees of freedom for estimation

%  case df < 0
   if df < 0
       error(['degrees of freedom (df) need to > 0: df = ' num2str(df)])
   end
   %% construction of Y, y and Z
% for technical note see page 70.

% construction of y_vec
  Y = y(p+1:end,:)'                                                       ;   
  y_vec = vec(Y)                                                          ;

% contruction of Z
  Z = det_terms(p:end-1,:)                                                ;
  for i=1:p
     Z = [Z y(p-i+1:end-i,:)]                                             ;
  end

  Z = Z'                                                                  ;

%% multivariate ls estimator
% for technical note see pages 71-72.

  beta = kron((Z*Z')\Z,eye(n))*y_vec                                      ;
  B    = (Y*Z')/(Z*Z')                                                    ;

%% yhat values and residuals

  yhat = (B*Z)'                                                           ;
  res    = Y'-yhat                                                        ;
%% residuals and variables covariance matrix 
% For technical note see page 80.

  sigu = res'*res/df                                                      ;     % covar matrix of residuals
  gammavar   = Z*Z'/Tadj                                                  ;     % covar matrix of variables (ML estimator)

%% multivariate egls estimator

  if M ~= 0
   % construction of r and gammavar_hat_i matrices
     aux1 = n*(n*p+n_det)                                                 ;
     aux2 = 1                                                             ;
     R    = zeros(aux1,aux1-M)                                            ;
     for i=1:aux1
        if zero_r(i)==0
           R(i,aux2) = 1                                                  ;
           aux2      = aux2+1                                             ;
        end
    end

  % initialize termination criteria
    conv_crit_i = 1000                                                    ;
    conv_crit   = 1e-6                                                    ;
    count_i     = 1                                                       ;
    max_it      = 100                                                     ;

  % initialize sigma and beta
    sigu_i = sigu                                                         ;
    beta_i    = beta                                                      ;

  % egls loop
    while (count_i<=max_it) && (conv_crit_i>conv_crit)
        gammavar_hat_i = (R'*kron(Z*Z',sigu_i^(-1))*R)\....
                       R'*kron(Z,sigu_i^(-1))*y_vec ;   % (r=0 => z=y)
        beta_old    = beta_i                                              ;
        beta_i      = R*gammavar_hat_i                                    ;
        B_i         = reshape(beta_i,n,n_det+n*p)                         ;
        yhat_i    = (B_i*Z)'                                              ;
        res_i       = Y'-yhat_i                                           ;
        mu_i        = repmat(mean(res_i),Tadj,1)                          ;  
        sigu_i   = (res_i-mu_i)'*(res_i-mu_i)/Tadj                        ;
        conv_crit_i = norm(beta_i-beta_old)/norm(beta_old)                ;
        count_i     = count_i + 1                                         ;
    end
    
  % check covergence criterion
    
    if conv_crit_i > conv_crit
        if f_size == 3
            disp('egls estimation did not converge.')
        else
            disp([blanks(25) 'egls estimation did not converge.'])
        end
    else
        if f_size == 3
            disp(['egls estimation converged after ' num2str(count_i) ' iterations.'])
        else
            disp([blanks(25) 'egls estimation converged after ' num2str(count_i) ' iterations.'])
        end
    end

    
  % rename estimated parameters and variables
    yhat    = yhat_i                                                      ;
    res     = res_i                                                       ;
    beta    = beta_i                                                      ;
    B       = B_i                                                         ;   
    sigu    = sigu_i                                                      ;         
   
  % save R in output
    data.R = R; 
  
  end

%% A and v matrices

  v    = B(:,1:n_det)                                                     ;
  A    = zeros(n,n,p)                                                     ;
  cont = 1                                                                ;
  for i=n_det+1:n:n_det+n*p
      A(:,:,cont) = B(:,i:i+n-1)                                          ;
      cont = cont + 1                                                     ;
  end

%% variance matrix and std errors (parameters)

% case ols
  if M == 0
      Bcov = kron(gammavar^(-1),sigu)/Tadj                                ;    
      Bse  = sqrt(diag(Bcov))                                             ;          
  end

% case egls
  if M ~= 0
      Bcov = (R*((R'*kron(gammavar,sigu^(-1))*R)^(-1))*R')/Tadj           ;   
      Bse  = sqrt(diag(Bcov))                                             ; 
  end

%% companion form matrix
% for technical note see page 15.

  big_eye  = eye(n*p-n,n*p-n)                                             ;
  big_zero = zeros(n*p-n,n)                                               ;
  Acomp    = [B(:,n_det+1:end);big_eye big_zero]                          ;

%% stab 
% for technical note see pages 16-17.

  if max(abs(eig(Acomp))>=1) == 1
      stab = 0;
      if f_size == 3
          disp('estimated var coefficients unstable.')
      else
          disp([blanks(25) 'estimated var coefficients unstable.'])
      end  
  else
      stab = 1;
      if f_size == 3
          disp('estimated var coefficients stable.')
      else
          disp([blanks(25) 'estimated var coefficients stable.'])
      end 
  end

%% t-ratios and p-values
% for technical note see page 80.
  t_test_conf = 0.05;
  tstat  = B./reshape(Bse,n,n*p+n_det)                                    ;
  cv_t_test = tinv(1-t_test_conf/2,df)                                    ;
  ones_mat  = ones(n,n*p+n_det)                                           ;
  pval  = 2*(ones_mat-tcdf(abs(tstat),df))                                ;

 %%  unconditional mean vector
 
%  allocate memory
   aux = zeros(n)                                                         ;   

%  loop through lags
   for i=1:p
       aux = aux + A(:,:,i)                                               ;
   end
   
   mu = (eye(n) - aux)^(-1) * v                                           ; 
  
%% output
  
  % originales
  data.Tadj        = Tadj                  ; %
  data.stab        = stab                  ; % 
  data.df          = df                    ; %
  data.beta        = beta                  ; %
  data.yhat        = yhat                  ; % 
  data.res         = res                   ; %
  data.sigu        = sigu                  ; % 
  data.gammavar    = gammavar              ; % 
  data.B           = B                     ; %
  data.A           = A                     ; %
  data.v           = v                     ; %
  data.Bcov        = Bcov                  ; %
  data.Bse         = Bse                   ; %
  data.Acomp       = Acomp                 ; %
  data.Z           = Z                     ; %
  data.tstat       = tstat                 ; %  
  data.pval        = pval                  ; %
  data.mu          = mu                    ; %
  
  % adicionales
  data.M           = M                     ; 
  data.n_det       = n_det                 ; 
  data.y_vec       = y_vec                 ; 
  data.cv_t_test   = cv_t_test             ;
  data.det_terms   = det_terms             ;
  data.det_terms_f = det_terms_f           ;
  
end