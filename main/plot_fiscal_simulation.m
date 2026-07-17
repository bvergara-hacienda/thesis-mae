%% ========================================================================
%           plot monte-carlo simulation for fiscal variables
% =========================================================================

   function plot_fiscal_simulation(data)
  
%% load inputs

   h     = data.h                                                         ; % forecast horizon
   dates = data.dates                                                     ; % dates (non-adjusted sample)
   areas = data.areas                                                     ; % tone reduction for next significance level
   nb    = data.nb                                                        ; % n� of bands for fan-chart
   lbd   = data.lbd                                                       ; % lower bands for simulated debt paths
   ubd   = data.ubd                                                       ; % upper bands for simulated debt paths
   lbr   = data.lbr                                                       ; % lower bands for simulated fiscal reaction function paths
   ubr   = data.ubr                                                       ; % upper bands for simulated fiscal reaction function paths 
   fcsig = data.fcsig                                                     ; % fan-chart significance levels  
   pfd   = data.pfd                                                       ; % debt point forecasts
   pfr   = data.pfr                                                       ; % fiscal reaction function point forecasts
   
%% construct date vector

%  annual forecast horizon     
   h = abs(h/4)                                                           ;
   
%  allocate memory
   fdates = zeros(h + 1,1)                                                ;
   
%  initial value   
   fdates(1,1) = dates(end - 1,1)                                         ;
   
%  loop through forecast horizon   
   for i=2:h + 1
       fdates(i,1) = fdates(i - 1,1) + 1                                  ; 
   end
         
%% plot debt paths

%  figure title
   figt = 'simulated debt paths'                                          ;
   fig  = figure('name',char(figt))                                       ;
   set(fig,'Color','w')                                                   ;
                        
%  color of confidence bands 
   areac = data.areac                                                     ;
      
%  confidence intervals       
   for j=nb:-1:1
       shadedplot(fdates',lbd(1:h+1,j)',ubd(1:h+1,j)',areac)              ;
       areac = areac - areas                                              ;
       hold on
   end
       
%  point forecasts
   pl = plot(fdates,pfd,'r-','linewidth',1.3)                             ;                                                       
        hold on         

%  debt trajectory number 1
   pl = plot(fdates,data.dbt(:,1),'linewidth',1.3)                ;                                                       
        hold on          
        
                            
%  axis and labels  
   axis tight
   grid on         
   ylim([min([pfd;lbd(1:h+1,nb)])                                             ...
         min(max([pfd;ubd(1:h+1,nb)]),100+data.d0)])                      ;    
   set(gca,'fontsize',9,'ticklabelinterpreter','latex'                    ... 
          ,'ticklabelinterpreter','latex')                                ;
      
%  title  
   title('Simulated paths for $d_{t}$','fontsize',12,'interpreter','latex')               
            
%  legend  
   lnames = {['forecasts with ',num2str(100 * fcsig(1:end - 1)),          ...
              ' and ' num2str(100 * fcsig(end))                           ...
              '\% monte-carlo simulated error bands']}                    ; 
           
   leg    = legend(pl,lnames)                                             ;
            set(leg,'fontsize',9,'orientation','horizontal'               ...
                   ,'position',[.3 .001 .4 .05],'box','off'               ...
                   ,'interpreter','latex')                                ;
               
%% pdf (debt simulation)

   figrat = 10 / 9                                                        ;
   thor   = 0.6                                                           ;
   ttop   = 0                                                             ;
   wplot  = 4                                                             ;
   hplot  = wplot/figrat                                                  ;
   fac    = 1 + thor/wplot                                                ;

   set(gcf,'paperposition',[0 - thor*fac 0 + ttop wplot + thor * 2 hplot + ttop]); 
   set(gcf,'papersize',[wplot hplot])                                     ; 

   set(findall(fig,'Type','axes'),'Color','w','XColor','k','YColor','k','ZColor','k','GridColor',[0.15 0.15 0.15]);
   set(findall(fig,'Type','text'),'Color','k')                            ;
   set(findall(fig,'Type','Legend'),'TextColor','k','Color','w')          ;

   saveas(fig,'debt.png')
   
%% plot fiscal reaction function paths

%  figure title
   figt = 'simulated primary balance paths'                               ;
   fig  = figure('name',char(figt))                                       ;
   set(fig,'Color','w')                                                   ;
                        
%  color of confidence bands 
   areac = data.areac                                                     ;
      
%  confidence intervals       
   for j=nb:-1:1
       shadedplot(fdates(1:end)',lbr(1:h+1,j)',ubr(1:h+1,j)',areac)       ;
       areac = areac - areas                                              ;
       hold on
   end
       
%  point forecasts
   pl = plot(fdates(1:end),pfr(1:end),'r-','linewidth',1.3)               ;                                                       
        hold on    

%  debt trajectory number 1
   pl = plot(fdates,data.frf(:,1),'b-','linewidth',1.3)                   ;                                                       
        hold on         
                            
%  axis and labels  
   axis tight
   ylim([min([pfr(1:h+1);lbr(1:h+1,nb)])                                  ...
         min(max([pfr;ubr(1:h+1,nb)]),10+data.pb0)])                      ;       
   grid on         
   set(gca,'fontsize',9,'ticklabelinterpreter','latex'                    ... 
          ,'ticklabelinterpreter','latex')                                ;
      
%  title  
   title('Simulated paths for $p_{t}$','fontsize',12,'interpreter','latex')               
            
%  legend  
   lnames = {['forecasts with ',num2str(100 * fcsig(1:end - 1)),          ...
              ' and ' num2str(100 * fcsig(end))                           ...
              '\% monte-carlo simulated error bands']}                    ; 
           
   leg    = legend(pl,lnames)                                             ;
            set(leg,'fontsize',9,'orientation','horizontal'               ...
                   ,'position',[.3 .001 .4 .05],'box','off'               ...
                   ,'interpreter','latex')                                ;   
   
%% pdf (fiscal reaction function simulation)

   figrat = 10 / 9                                                        ;
   thor   = 0.6                                                           ;
   ttop   = 0                                                             ;
   wplot  = 4                                                             ;
   hplot  = wplot/figrat                                                  ;
   fac    = 1 + thor/wplot                                                ;

   set(gcf,'paperposition',[0 - thor*fac 0 + ttop wplot + thor * 2 hplot + ttop]); 
   set(gcf,'papersize',[wplot hplot])                                     ; 
   
   set(findall(fig,'Type','axes'),'Color','w','XColor','k','YColor','k','ZColor','k','GridColor',[0.15 0.15 0.15]);
   set(findall(fig,'Type','text'),'Color','k')                            ;
   set(findall(fig,'Type','Legend'),'TextColor','k','Color','w')          ;

   saveas(fig,'frf.png')
                 
 %% plot both 
 
 
%  figure title
   figt = 'simulated debt paths'                                          ;
   fig  = figure('name',char(figt));
   set(fig,'Color','w')                                                   ;
   
%  select subplot
   subplot(1,2,1)
                        
%  color of confidence bands 
   areac = data.areac                                                     ;
      
%  confidence intervals       
   for j=nb:-1:1
       shadedplot(fdates',lbd(1:h+1,j)',ubd(1:h+1,j)',areac)              ;
       areac = areac - areas                                              ;
       hold on
   end
   
       
%  debt trajectory number 1
%   pl = plot(fdates,data.dbt(:,1),'g-','linewidth',1.3)                   ;
 %  hold on 
  % pl = plot(fdates,data.dbt(:,302),'b-','linewidth',1.3)                   ;  
   %   hold on                    
               
%  point forecasts
   pl = plot(fdates,pfd,'r-','linewidth',1.3)                             ;                                                       
        hold on      
      
%  axis and labels  
   axis tight
   grid on         
   ylim([min([pfd;lbd(1:h+1,nb)])                                             ...
         min(max([pfd;ubd(1:h+1,nb)]),100+data.d0)])                      ;                                         ;    
   set(gca,'fontsize',9,'ticklabelinterpreter','latex'                    ... 
          ,'ticklabelinterpreter','latex')                                ;
      
%  title  
   title('Simulated paths for $d_{t}$','fontsize',12,'interpreter','latex')               
                                                           

%  legend  
   lnames = {['Projections with ',num2str(100 * fcsig(1:end - 1)),             ...
              ' and ' num2str(100 * fcsig(end))                           ...
              '\% monte-carlo simulated error bands']}                     ;
           
   leg    = legend(pl,lnames)                                             ;
            set(leg,'fontsize',9,'orientation','horizontal'               ...
                   ,'position',[.3 .001 .4 .05],'box','off'               ...
                   ,'interpreter','latex')                                ;   
   
   
   
%  select subplot
   subplot(1,2,2)
                        
%  color of confidence bands 
   areac = data.areac                                                     ;
      
%  confidence intervals       
  for j=nb:-1:1
       shadedplot(fdates(1:end)',lbr(1:h+1,j)',ubr(1:h+1,j)',areac)       ;
       areac = areac - areas                                              ;
       hold on
   end
       

        
%  debt trajectory number 1
 %  pl = plot(fdates,data.frf(:,1),'g-','linewidth',1.3)                   ; 
 %  hold on 
 %  pl = plot(fdates,data.frf(:,302),'b-','linewidth',1.3)                   ;
  %      hold on    
        
        
%  point forecasts
   pl = plot(fdates(1:end),pfr(1:end),'r-','linewidth',1.3)               ;                                                       
        hold on         
                            
%  axis and labels  
   axis tight
   ylim([min([pfr(1:h+1);lbr(1:h+1,nb)])                                  ...
         min(max([pfr;ubr(1:h+1,nb)]),10+data.pb0)])                      ;      
   grid on         
   set(gca,'fontsize',9,'ticklabelinterpreter','latex'                    ... 
          ,'ticklabelinterpreter','latex')                                ;
      
%  title  
   title('Simulated paths for $pb_{t}$','fontsize',12,'interpreter','latex')               
            
%  legend  
           
   leg    = legend(pl,lnames)                                             ;
            set(leg,'fontsize',9,'orientation','horizontal'               ...
                   ,'position',[.3 .001 .4 .05],'box','off'               ...
                   ,'interpreter','latex')                                ;   
   %% pdf (fiscal reaction function simulation)

   figrat = 21 / 8                                                        ;
   thor   = 0.6                                                           ;
   ttop   = 0                                                             ;
   wplot  = 7                                                             ;
   hplot  = wplot/figrat                                                  ;
   fac    = 1 + thor/wplot                                                ;

   set(gcf,'paperposition',[0 - thor*fac 0 + ttop wplot + thor * 2 hplot + ttop]); 
   set(gcf,'papersize',[wplot hplot])                                     ; 
   
   set(findall(fig,'Type','axes'),'Color','w','XColor','k','YColor','k','ZColor','k','GridColor',[0.15 0.15 0.15]);
   set(findall(fig,'Type','text'),'Color','k')                            ;
   set(findall(fig,'Type','Legend'),'TextColor','k','Color','w')          ;

   saveas(fig,'fiscal_sim.pdf')
 
 
 
   end