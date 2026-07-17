%% ========================================================================
%                  plot fitted values for var estimation
% =========================================================================

   function plot_fitted(data)
  
%% load inputs

   n      = data.n                                                        ; % n� of variables
   vnames = data.vnames                                                   ; % variable names 
   rnames = data.rnames                                                   ; % residual names
   dates  = data.dates                                                    ; % dates (non-adjusted sample)
   y      = data.y                                                        ; % actual values (non-adjusted sample)
   yhat   = data.yhat                                                     ; % fitted values (adjusted sample)
   p      = data.p                                                        ; % n� of lags
   sigu   = data.sigu                                                     ; % covariance matrix for innovations
   Tadj   = data.Tadj                                                     ; % sample size (adjusted)
   res    = data.res                                                      ; % residuals
   
%% plot data against fitted values

%  figure title
   figt = 'actual vs fitted values - var'                                 ;
   fig1 = figure('name',char(figt))                                       ;
   set(fig1,'Color','w')                                                  ;
   
%  loop through variables
   for i=1:n
       
%      select subplot
       subplot(2,3,i)
       
%      actual values
       plot(dates(p + 1:end),y(p + 1:end,i),'b-','linewidth',1.3)         ;
       hold on
       
%      fitted values  
       plot(dates(p + 1:end),yhat(:,i),'r-','linewidth',1.3)              ;
       
%      subplot axis and labels  
       axis tight
       grid on
       xticklabels(char(num2str(xticks')))
       set(gca,'fontsize',9,'ticklabelinterpreter','latex'                ... 
              ,'ticklabelinterpreter','latex')                            ;
         
%      subplot title  
       title(vnames(i),'fontsize',9,'interpreter','latex')         
       
   end
   
%  legend  
   leg = legend('Historical','Fitted Values')                         ;
         set(leg,'fontsize',9,'orientation','horizontal','box','off'      ...
         ,'position',[.3 .001 .4 .05],'interpreter','latex')              ;
      
%% pdf (fitted)

   figrat = 16 / 9                                                        ;
   thor   = 0.6                                                           ;
   ttop   = 0.05                                                          ;
   wplot  = 7                                                             ;
   hplot  = wplot/figrat                                                  ;
   fac    = 1 + thor/wplot                                                ;

   set(gcf,'paperposition',[0 - thor*fac 0 + ttop wplot + thor * 2 hplot + ttop]); 
   set(gcf,'papersize',[wplot hplot])                                     ; 

   set(findall(fig1,'Type','axes'),'Color','w','XColor','k','YColor','k','ZColor','k','GridColor',[0.15 0.15 0.15]);
   set(findall(fig1,'Type','text'),'Color','k')                           ;
   set(findall(fig1,'Type','Legend'),'TextColor','k','Color','w')         ;

   saveas(fig1,'fitted.pdf')

%% plot residuals

%  standard errors
   rese = sqrt(diag(sigu))                                                ;

%  figure title
   figt = 'residuals'                                                     ;
   fig2 = figure('name',char(figt))                                       ;
   set(fig2,'Color','w')                                                  ;
   
%  loop through variables
   for i=1:n   
   
%      select subplot
       subplot(2,3,i)
       
%      zero line
       h(1) = plot(dates(p + 1:end),zeros(1,Tadj),'k-','linewidth',1)     ;
              hold on
             
%      residuals  
       h(2) = plot(dates(p + 1:end),res(:,i),'b-','linewidth',1.3)        ; 
              hold on
              
%      +/- 1 standard error      
       h(3) = plot(dates(p + 1:end), rese(i) * ones(1,Tadj),'k--','linewidth',1); 
       h(4) = plot(dates(p + 1:end),-rese(i) * ones(1,Tadj),'k--','linewidth',1);    
       
%      subplot axis and labels  
       axis tight
       grid on
       xticklabels(char(num2str(xticks')))
       set(gca,'fontsize',9,'ticklabelinterpreter','latex'                ... 
              ,'ticklabelinterpreter','latex')                            ;
         
%      subplot title  
       title(rnames(i),'fontsize',9,'interpreter','latex')         
       
   end
   
%  legend  
   leg = legend(h([2 3]),'Residuals','+/- one standard error')            ;
         set(leg,'fontsize',9,'orientation','horizontal','box','off'      ...
                ,'position',[.3 .001 .4 .05],'interpreter','latex')       ;
      
%% pdf (residuals)

   figrat = 16 / 9                                                        ;
   thor   = 0.6                                                           ;
   ttop   = 0.05                                                          ;
   wplot  = 7                                                             ;
   hplot  = wplot/figrat                                                  ;
   fac    = 1 + thor/wplot                                                ;

   set(gcf,'paperposition',[0 - thor*fac 0 + ttop wplot + thor * 2 hplot + ttop]); 
   set(gcf,'papersize',[wplot hplot])                                     ; 

   set(findall(fig2,'Type','axes'),'Color','w','XColor','k','YColor','k','ZColor','k','GridColor',[0.15 0.15 0.15]);
   set(findall(fig2,'Type','text'),'Color','k')                           ;
   set(findall(fig2,'Type','Legend'),'TextColor','k','Color','w')         ;

   saveas(fig2,'residuals.pdf')
     
   end