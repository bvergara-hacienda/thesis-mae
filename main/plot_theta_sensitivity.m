%% ========================================================================
%     plot debt fan-chart for a given (alpha_spec, theta) combination
% =========================================================================
%
%  usage:
%     plot_theta_sensitivity(data)
%
%  data must be the output of fiscal_simulation_theta.m (it needs
%  data.alpha_spec and data.theta, in addition to the usual dbt/lbd/ubd/pfd
%  fields). saves a single-panel debt fan-chart as:
%     a<alpha_spec>_theta<theta>.pdf
%  e.g. a0_theta0.95.pdf, a1_theta0.9.pdf, etc.

   function plot_theta_sensitivity(data)

%% load inputs

   h          = data.h                                                    ; % forecast horizon
   dates      = data.dates                                                ; % dates (non-adjusted sample)
   areas      = data.areas                                                ; % tone reduction for next significance level
   nb         = data.nb                                                   ; % n° of bands for fan-chart
   lbd        = data.lbd                                                  ; % lower bands for simulated debt paths
   ubd        = data.ubd                                                  ; % upper bands for simulated debt paths
   fcsig      = data.fcsig                                                ; % fan-chart significance levels
   pfd        = data.pfd                                                  ; % debt point forecasts
   alpha_spec = data.alpha_spec                                           ; % risk-aversion specification (0 or 1)
   theta      = data.theta                                                ; % recovery rate

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
   figt = sprintf('simulated debt paths - alpha = %d, theta = %.2f',alpha_spec,theta) ;
   fig  = figure('name',figt)                                             ;
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

%  axis and labels
   axis tight
   grid on
   ylim([min([pfd;lbd(1:h+1,nb)])                                             ...
         min(max([pfd;ubd(1:h+1,nb)]),100+data.d0)])                      ;
   set(gca,'fontsize',9,'ticklabelinterpreter','latex'                    ...
          ,'ticklabelinterpreter','latex')                                ;

%  title
   title(sprintf('Simulated paths for $d_{t}$ ($\\alpha=%d$, $\\theta=%.2f$)',alpha_spec,theta), ...
         'fontsize',12,'interpreter','latex')

%  legend
   lnames = {['Projections with ',num2str(100 * fcsig(1:end - 1)),             ...
              ' and ' num2str(100 * fcsig(end))                           ...
              '\% monte-carlo simulated error bands']}                     ;

   leg    = legend(pl,lnames)                                             ;
            set(leg,'fontsize',9,'orientation','horizontal'               ...
                   ,'position',[.3 .001 .4 .05],'box','off'               ...
                   ,'interpreter','latex')                                ;

%% pdf

   figrat = 5 / 3                                                         ;
   thor   = 0.6                                                           ;
   ttop   = 0                                                             ;
   wplot  = 7                                                             ;
   hplot  = wplot/figrat                                                  ;
   fac    = 1 + thor/wplot                                                ;

   set(gcf,'paperposition',[0 - thor*fac 0 + ttop wplot + thor * 2 hplot + ttop]);
   set(gcf,'papersize',[wplot hplot])

   set(findall(fig,'Type','axes'),'Color','w','XColor','k','YColor','k','ZColor','k','GridColor',[0.15 0.15 0.15]);
   set(findall(fig,'Type','text'),'Color','k')                            ;
   set(findall(fig,'Type','Legend'),'TextColor','k','Color','w')          ;

%  filename, e.g. a0_theta0.95.pdf
   fname = sprintf('a%d_theta%s.pdf',alpha_spec,num2str(theta))           ;
   saveas(fig,fname)

   end
