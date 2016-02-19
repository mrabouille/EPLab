function [M,stock_M]=mould_VTT(M_0,T,RH,Sens_class,Surf_quality,timb_spec,Nt,dt)

%INPUT:
% champs de T (C) vecteur Nt
% champs de RH (%) vecteur Nt
% Sens_class sensibilite du materiau (1=resistant, 2=medium resistant, 3=sensitive,
% 4=very sensitive)
% Surf_quality qualite de la surface du materiau (0=sawn surface, 1= kiln
% dried quaqlity)
% timb_spec espece du bois (0= pine, 1= spruce)
% dt en seconde

% OUTPUT:
% indice de moisissure M

% attention la qualité de la surface et l'espèce ne sont pas pris en compte
% amélioration : inclure un paramètre sur le type de matériau (fction sensibilité) pour déterminer les paramètres

%definition des parametres
k1_stock=cell(4,2); %tableau 4,2, ligne=Sens_class, colonne=1,M<1 ou colonne=2,M>=1
k1_stock{4,1}=1;
k1_stock{3,1}=0.578;
k1_stock{2,1}=0.072;
k1_stock{1,1}=0.033;
k1_stock{4,2}=2;
k1_stock{3,2}=0.386;
k1_stock{2,2}=0.097;
k1_stock{1,2}=0.014;

A=cell(4,1); %tableau 4,2, ligne=Sens_class, colonne=1,M<1 ou colonne=2,M>=1
A{4,1}=1;
A{3,1}=0.3;
A{2,1}=0;
A{1,1}=0;

B=cell(4,1); %tableau 4,2, ligne=Sens_class, colonne=1,M<1 ou colonne=2,M>=1
B{4,1}=7;
B{3,1}=6;
B{2,1}=5;
B{1,1}=3;

C=cell(4,1); %tableau 4,2, ligne=Sens_class, colonne=1,M<1 ou colonne=2,M>=1
C{4,1}=2;
C{3,1}=1;
C{2,1}=1.5;
C{1,1}=1;

RH_crit=cell(4,1); %tableau 4,2, ligne=Sens_class, colonne=1,M<1 ou colonne=2,M>=1
RH_crit{4,1}=80;
RH_crit{3,1}=80;
RH_crit{2,1}=85;
RH_crit{1,1}=85;

%initialisartion
M=M_0;
stock_M=M;
M_max=A{Sens_class,1}+B{Sens_class,1}*((RH_crit{Sens_class,1}-RH(1))/(RH_crit{Sens_class,1}-100))-C{Sens_class,1}*((RH_crit{Sens_class,1}-RH(1))/(RH_crit{Sens_class,1}-100))^2;
k2=max(1-exp(2.3*(M-M_max)),0);
k1=k1_stock{Sens_class,1};

iter=1;
tps_decline=0;
while iter<Nt
    if RH(iter)>RH_crit{Sens_class,1}   %mould growth
        M=stock_M(end)+...
            dt*1/(7*24*10*360*exp(-0.68*log(max(0,T(iter)))-13.9*log(RH(iter))+0.14*timb_spec-0.33*Surf_quality+66.02))*k1*k2;
        %dt*1/(7*24*1200*exp(-0.68*log(T(iter))-13.9*log(RH(iter))+0.14*tim
        %b_spec-0.33*Surf_quality+66.02))*k1*k2;
        tps_decline=0;
    end
    if (M>0 && RH(iter)<RH_crit{Sens_class,1})  %mould decline (if started)
       tps_decline=tps_decline+dt/3600;
       if tps_decline<=6
           dM_0=-0.00133;
       elseif tps_decline<=24
           dM_0=0;
       elseif tps_decline>24
           dM_0=-0.000667;
       end
        M=stock_M(end)+dM_0*dt/3600;
        M=max(M,0);
%ici le parametre Ceff=1 (pas compris comment il marchait!)
    end;
    %stocage et incrementation
    stock_M=[stock_M M];
    iter=iter+1;
    %actualisation des coefficients
    M_max=A{Sens_class,1}+B{Sens_class,1}*((RH_crit{Sens_class,1}-RH(iter))/(RH_crit{Sens_class,1}-100))-C{Sens_class,1}*((RH_crit{Sens_class,1}-RH(iter))/(RH_crit{Sens_class,1}-100))^2;
    k2=max(1-exp(2.3*(M-M_max)),0);
    if M<1
        k1=k1_stock{Sens_class,1};
    elseif M>=1
        k1=k1_stock{Sens_class,2};
    end
    
    
end



