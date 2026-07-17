
% steady state debt

% ensure figure is saved in the same folder as the other outputs
cd(fileparts(mfilename('fullpath')))

% parameters
rd    = (1 + 0.1681/100)^4 -1                                             ;
rf    = (1 - 0.1246/100)^4 -1                                             ;
g     = (1 + 0.8994/100)^4 -1                                             ;
theta = 0.38                                                              ;      
r   = theta * (1 + rf) + (1-theta)* (1+ rd) -1                            ;

% demographic parameters 
% 23.42 + 40.92 (inmediate stabilization)
% 23.42 + 50    (gradual stabilization)
adr   = 67.39                                                             ; 
adrold=   40.95 + 23.42                                                   ;

% fiscal reaction function coefficients
delta =    0.5411                                                         ;
rho   =    0.0323                                                         ;
b_adr =    0                                                              ;
b_fadr=   -0.0001                                                         ;
alpha =   -1.8947                                                         ;
mu    =    2.1261                                                         ;

% steady state debt
d = (1+g)*(alpha + b_adr*adr + b_fadr*adrold + mu)/( (1-delta)*(r-g) -rho*(1+g)  )


%% steady state debt function   

%  grid size
   n = 1000                                                               ;

%  grids
   rhogrid    = linspace(0,0.1,n)'                                        ;% rho
   adrgrid  = linspace(-0.05,0.05,n)'                                     ;% beta adr
   varphigrid = linspace(1.7,1.8,n)'                                      ;% efecto fijo
   phigrid    = linspace(0.45,0.55,n)'                                    ;% persistencia

%  allocate memory
   drho    = zeros(n,1)                                                   ;
   dadr    = zeros(n,1)                                                   ;
   dvarphi = zeros(n,1)                                                   ;
   dphi    = zeros(n,1)                                                   ;

%  steady-state debt functions
   for i=1:n

%      rho function
       rhoi    = rhogrid(i)                                               ;
       drho(i) = (1+g)*(alpha + b_adr*adr + b_fadr*adrold + mu)/( (1-delta)*(r-g) -rhoi*(1+g)  );

%      adr function
       b_adri    = adrgrid(i)                                           ;
       dadr(i) = (1+g)*(alpha + b_adri*adr + b_fadr*adrold + mu)/( (1-delta)*(r-g) -rho*(1+g)  );

%      varphi function (fe)
       varphii    = varphigrid(i)                                         ;
       dvarphi(i) = (1+g)*(alpha + b_adr*adr + b_fadr*adrold + varphii)/( (1-delta)*(r-g) -rho*(1+g)  );
       
%      cs function
       phii    = phigrid(i)                                               ;
       dphi(i) = (1+g)*(alpha + b_adr*adr + b_fadr*adrold + mu)/( (1-phii)*(r-g) -rho*(1+g)  ); 

   end

%% plots

%  figure title
   fig = figure('name','comparative statics')                             ;
   set(fig,'Color','w')                                                   ;

%  gather data
   grid_all = [rhogrid adrgrid varphigrid phigrid]                        ;
   par_all  = [drho    dadr    dvarphi    dphi   ]                        ;

%  subplot names  
   names = {'$\rho$'                                                      ;
            '$\beta_{ADR}$'                                               ;
            '$\mu$'                                                       ;
            '$\delta$'}                                                   ;

%  loop through parameters                                                            
   for j=1:4

%      select assign subplot      
       subplot(2,2,j)  

%      subplot settings
       hold on
       grid on
       box on

%      plot debt function       
       plot(grid_all(:,j),par_all(:,j),'b-','linewidth',2)                ;

%      subplot title  
       title(names{j},'fontsize',14,'interpreter','latex')          
           
%      axis      
       set(gca,'fontsize',14,'ticklabelinterpreter','latex') 
       axis tight       

   end

%% create pdf 

   fig_ratio = 1.5                                                        ;
   thor      = 1.65                                                       ;
   ttop      = 0.0                                                        ;
   wplot     = 16                                                         ;
   hplot     = wplot / fig_ratio                                          ;
   f         = 1 + thor / wplot                                           ;
 
   set(gcf,'paperposition',[0-thor*f 0+ttop wplot+thor*2 hplot+ttop])     ; 
   set(gcf,'paperposition',[0-thor*f 0+ttop wplot+thor*2 hplot+ttop])     ; 
   set(gcf,'papersize',[wplot hplot])                                     ; 
  
   set(findall(fig,'Type','axes'),'Color','w','XColor','k','YColor','k','ZColor','k','GridColor',[0.15 0.15 0.15]);
   set(findall(fig,'Type','text'),'Color','k')                            ;
   set(findall(fig,'Type','Legend'),'TextColor','k','Color','w')          ;

   saveas(fig,'comparative statics.pdf')

%% ========================================================================    

