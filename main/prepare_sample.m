%% ========================================================================
%                           prepare sample
% =========================================================================

   function data = prepare_sample(data)
  
%% load input

%  database location
   file = data.file                                                       ;
   adr_file = data.adr_file                                               ;
   
%  var estimation sample 
   fobs = data.fobs                                                       ;
   lobs = data.lobs                                                       ;
   h = data.h                                                             ;
   h = h/4                                                                ;
   
%  data and dates
   raw      = xlsread(file)                                               ; % raw database
   yraw     = raw(:,2:end)                                                ; % raw data
   datesraw = raw(:,1)                                                    ; % raw dates
   Traw     = size(datesraw,1)                                            ; % raw sample size
   
   adrx     = xlsread(adr_file)                                           ; % raw adr database
   
   % interpolaci�n
   
   % guardar datos 
   years   = adrx(:, 1)                                                   ;
   adr_t   = adrx(:, 2)                                                   ;
   adr_o   = adrx(:, 3)                                                   ;
   adr_y   = adrx(:, 4)                                                   ;
   
   % puntos de consulta
   years_f = 1960:1:2019+h+20                                             ;
   
   
   % interpolaci�n variables demogr�ficas 
   interp = data.interp                                                   ;
   int_year = data.int_year                                               ;
   adr_o_interp = interp1(years(1:end-int_year),adr_o(1:end-int_year),years_f(1:end-int_year), interp, 'extrap');
   adr_y_interp = interp1(years(1:end-int_year),adr_y(1:end-int_year),years_f(1:end-int_year), 'previous', 'extrap');
   adr_t_interp = adr_y_interp+adr_o_interp                               ;        

   adr = adr_o_interp(60:end) +adr_y_interp(60:end);                    
   fadr   =  adr_o_interp(60+20:end);
   
  %% Para Gr�fico 
   
  % interpolaci�n lineal
   adr_o_interp_lin = interp1(years(1:end-2),adr_o(1:end-2),years_f(1:end-2), 'linear', 'extrap');
   adr_y_interp_lin = interp1(years(1:end-2),adr_y(1:end-2),years_f(1:end-2), 'previous', 'extrap');
   adr_t_interp_lin = adr_y_interp_lin+adr_o_interp_lin;    
  
    % interpolaci�n previous
   adr_o_interp_pre = interp1(years(1:end-2),adr_o(1:end-2),years_f(1:end-2), 'previous', 'extrap');
   adr_y_interp_pre = interp1(years(1:end-2),adr_y(1:end-2),years_f(1:end-2), 'previous', 'extrap');
   adr_t_interp_pre = adr_y_interp_pre+adr_o_interp_pre;    
   
   
   % graficar
   figt = 'simulated adr paths'                                           ;
   fig  = figure('name',char(figt));
   set(fig,'Color','w')                                                   ;
  
   pl = plot(years(1:end-2),adr_y(1:end-2),'bo',years_f(1:end-int_year),adr_y_interp, 'b:.', ...
       years_f(1:end-2),adr_y_interp_lin,'b:.',years_f(1:end-2),adr_y_interp_pre,'b:.')  ;
   hold on
   pl = plot(years(1:end-2),adr_o(1:end-2),'ro',years_f(1:end-int_year),adr_o_interp,'r:.', ...
       years_f(1:end-2),adr_o_interp_lin,'r:.',years_f(1:end-2),adr_o_interp_pre,'r:.')  ;
   hold on
   pl = plot(years(1:end-2),adr_t(1:end-2),'go',years_f(1:end-int_year),adr_t_interp,'g:.', ...
       years_f(1:end-2),adr_t_interp_lin,'g:.',years_f(1:end-2),adr_t_interp_pre,'g:.') ;
   hold on
   
   grid on         
   set(gca,'fontsize',12,'ticklabelinterpreter','latex'                    ... 
          ,'ticklabelinterpreter','latex')                                ;
      
%  axis and labels  
   axis tight     
   grid on         
   set(gca,'fontsize',12,'ticklabelinterpreter','latex'                    ... 
          ,'ticklabelinterpreter','latex')                                ;      
       
%  title  
   title('Dependency Ratio','fontsize',14,'interpreter','latex')
   
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

   saveas(fig,'adr.pdf')
   
   h = data.h                                                             ;
   h = h/4                                                                ;
    

   
   %fadr    = adr_o_interp(60+20:end) ./ adr_y_interp(60+20:end)          ;  
   %fadr   = adr_o_interp(60+20:end);% + adr_y_interp(60+20:end)          ;

   

%% generate sample

%  estimation sample
   smp   = (1:Traw)'                                                      ;
   smp   = (smp(datesraw == fobs) : smp(datesraw == lobs))'               ; % sample indexes
   dates = datesraw(smp)                                                  ; % sample dates
   y     = yraw(smp,:)                                                    ; % sample data matrix
   
%  n� observations and variables
   [T,n] = size(y)                                                        ; 
   
%% save output

   data.datesraw = datesraw                                               ;
   data.yraw     = yraw                                                   ;
   data.Traw     = Traw                                                   ;
   data.dates    = dates                                                  ;
   data.y        = y                                                      ;
   data.T        = T                                                      ;
   data.n        = n                                                      ;
   data.adr      = adr                                                    ;
   data.fadr     = fadr                                                   ;

      
   end