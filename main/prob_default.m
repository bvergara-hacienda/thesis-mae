
% interpolación de función de probabilidad de default

% ensure figure is saved in the same folder as the other outputs
cd(fileparts(mfilename('fullpath')))

% definir datos
debt = [0 50 77.9 78.9 79.5 80.5 81.8 83.1 88.4 100 150];  
prob = [0 0 0.01 0.05 0.1  0.25 0.5  0.75 1 1 1];
debtq = 0:0.1:150;

% generar figura
figt = 'default probability'                                    ;
fig  = figure('name',char(figt));
set(fig,'Color','w')                                                     ;

% interpolar
vq1 = interp1(debt,prob,debtq,'makima');
plot(debt,prob,'o',debtq,vq1,'-');
hold on 
grid on         
set(gca,'fontsize',9,'ticklabelinterpreter','latex'                    ... 
          ,'ticklabelinterpreter','latex')                                ;
 
% titulo      
title('Default Probability, interpolated from Mendez-Vizcaino and Moreno-Arias (2021)','fontsize',12,'interpreter','latex')
xlim([60 99]);
xlabel('Public Debt-to-GDP Ratio','fontsize',12,'interpreter','latex');

   
   figrat = 5 / 3                                                        ;
   thor   = 0.6                                                           ;
   ttop   = 0                                                             ;
   wplot  = 7                                                             ;
   hplot  = wplot/figrat                                                  ;
   fac    = 1 + thor/wplot                                                ;

   set(gcf,'paperposition',[0 - thor*fac 0 + ttop wplot + thor * 2 hplot + ttop]); 
   set(gcf,'papersize',[wplot hplot]) 


% forzar fondo blanco y texto negro
set(findall(fig,'Type','axes'),'Color','w','XColor','k','YColor','k','ZColor','k','GridColor',[0.15 0.15 0.15]);
set(findall(fig,'Type','text'),'Color','k')                              ;
set(findall(fig,'Type','Legend'),'TextColor','k','Color','w')            ;

% guardar
saveas(fig,'default.pdf')




           