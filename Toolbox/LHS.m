function [plan,index]=LHS(N,index,Var_infos,X_fixe)
% LHS_global - Réalise un jet aléatoire pour chacune des variables selon LHS
% 10 essai sont réalisés pour obtenir un Plan maximin 
%
% Description
%   [plan, index]=LHS_simple(nb_tir,type,parametres)
%
%       N          : Nombre d'évaluation du modèle
%       type       : Type de ddp des variables
%       parametres : Parametres de variation des variables
%       X_fixe     : Fixe une incertitude aux variables
%
%       plan       : Plan d'evaluation du modèle
%       index      : Ordres initiaux des variables (nb_tir, nb_variable)
%  
%   10 jets aléatoire sont réalisés
%
% X_fixe  vecteur NaN || Fase || Empty  -> etude globale uniforme
%         True -> etude locale avec les moyennes prédéfinies
%         vecteur avec les valeurs -> etude locale aux points definis (NaN=globale)
%
% Requirements
%   minimax()
% References
%   -none-
%   Code personel basé sur la théorie
%
% Authors
%   Mickael RABOUILLE <mickael.rabouille(at)gmail.com>
%
% License
%   The program is free for non-commercial academic use. Please 
%   contact the authors if you are interested in using the software
%   for commercial purposes. The software must not modified or
%   re-distributed without prior permission of the authors.
%
% Changes
%   12/06/2013  Ajout du test sur la distribution de l'index
%   04/01/2013  Création
%
%

%Var_infos= params.variables.infos(params.variables.vars_index);

k = length(Var_infos); % Nombre de variables

plan=zeros(N,k); % plan de simulation

%RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
rng shuffle


if isempty(X_fixe) || (length(X_fixe)==1 && X_fixe==false) || all(isnan(X_fixe))
    % etude globale
    local=zeros(1,k);
    
elseif  length(X_fixe)==1 && X_fixe==true 
    % etude locale
    local=ones(1,k);
    X_fixe=nan(1,k);
else
    % etude mixte
    if length(X_fixe)~=k
        error('Taille ''X_fixe'' incorecte !')
    end
    local=~isnan(X_fixe);
end

% Génération des échantillions
for i=1:k
    
    if local(i)
        %LOCALE        
        parametres=Var_infos(i).moments;
        if numel(parametres)~=2 && ~(strcmp(Var_infos(i).loi, 'Discret') || Var_infos(i).loi(1)==0)
            error('Vérifiez les informations de la variables: %s', Var_infos(i).nom)
        end
        if ~isnan(X_fixe(i))
            parametres(1)=X_fixe(i);
        end
        
        switch Var_infos(i).loi
            case {0,'Discret'} % Intervale discret uniforme
                
                %NON PAS d'incertitudes sur les entrées discretes
                %                 niv = parametres;
%                 interval=1+floor((index(:,i)-1)/(N-1)*(niv)); %OK jusqu'a 10 niveaux
%                 interval(interval>niv)=niv;
%                 % index des valeurs dans le plan            
%                 plan(:,i)=interval;
                plan(:,i)=parametres;
                warning('PAS d''incertitudes sur les entrées discretes dans ce type d''analyse\nVariable: %s',Var_infos(i).nom)

            case {1,'Uniform'} % Intervale uniforme
                moyenne = parametres(1);
                variation = parametres(2);

                interval = (1:N)-rand(1,N);
                valeurs = moyenne-variation + 2*variation/N*(interval);
                plan(:,i)=valeurs(index(:,i));

            case {2,'Gaussian'} % Intervale gaussienne                
                moyenne = parametres(1);
                ecart_type = parametres(2)/1.96; % !Taux de confiance 95%!

                
                interval = norminv(0:1/(N+2):1,moyenne,ecart_type);
                differences=diff(interval(2:end-1));
                valeurs = interval(2:end-2)+(rand(1,N)-0.5).*differences;
                if isnan(valeurs(1)),keyboard,end
                test_limites()
                
                plan(:,i)=valeurs(index(:,i));

            case {3,'UniformR'} % Intervale uniforme
                moyenne = parametres(1);
                ecart_relatif = parametres(2)/100; % Ex: +/- 10%

                % Loi uniforme ]-1;1[ avec jet aléatoire entre les intervales 
                interval = ((1:N)-rand(1,N))*2/N-1;

                % Loi uniforme dans ]min;max[
                valeurs = moyenne + abs(moyenne*ecart_relatif)*(interval);
                plan(:,i)=valeurs(index(:,i));

            case {4,'GaussianR'} % Intervale gaussienne
                moyenne = parametres(1);
                ecart_type = abs(parametres(2)/100*moyenne)/1.96; % Ex: parametres(2) +/- 10%

                % Génération de la loi
                % Taux de confiance:
    %             99 % -> 2.58
    %             95 % -> 1.96
    %             90 % -> 1.64
                interval = norminv(0:1/(N+2):1,moyenne,ecart_type);
                % Calcul de la difference autour de chaque intervale
                % (Sauf '1' et 'end' qui sont Inf.)
                differences=diff(interval(2:end-1));
                % Loi avec jet aléatoire uniforme entre les intervales équiprobables
                valeurs = interval(2:end-2)+(rand(1,N)-0.5).*differences;
                if isnan(valeurs(1)),keyboard,end
                test_limites()
                plan(:,i)=valeurs(index(:,i));
                
            otherwise
                error(sprintf('Le type de la variable %s n''est pas reconnu !',Var_infos(i).nom))
        end
    
    else
        
        %Global
        if numel(Var_infos(i).limites)~=2  && ~(strcmp(Var_infos(i).loi, 'Discret') || Var_infos(i).loi(1)==0)
            error('Les limites de la variable ''%s'' sont mal définies !',Var_infos(i).nom)
        end
        parametres=Var_infos(i).limites;
        
        switch Var_infos(i).loi

            case {0,'Discret'} % Intervale discret uniforme
                niv_max = length(parametres);  

                niv=1+floor((index(:,i)-1)/(N-1)*(niv_max)); %OK jusqu'a 10 niveaux
                niv(niv>niv_max)=niv_max;
                % index des valeurs dans le plan
                plan(:,i)=niv;       

            case {1,'Uniform',2,'Gaussian',3,'UniformR',4,'GaussianR'}
                mini = parametres(1);
                maxi = parametres(2);

                interval = (1:N)-rand(1,N);
                valeurs = mini + (maxi-mini)/N*(interval);
                plan(:,i)=valeurs(index(:,i));

            otherwise
                error('type de variable non reconnu !')
        end
    
    
    end
    
    
end

    function test_limites()
        
        if ~isempty(Var_infos(i).limites)
            hors_lim = [find(valeurs<Var_infos(i).limites(1)) find(valeurs>Var_infos(i).limites(2))];
            aie = 0;
            nb_aie = length(hors_lim);
            while ~isempty(hors_lim)
                aie=aie+1;
                interval = norminv(0:1/(length(hors_lim)+2):1,moyenne,ecart_type);
                differences=diff(interval(2:end-1));
                valeurs(hors_lim) = interval(2:end-2)+(rand(1,length(hors_lim))-0.5).*differences;
                hors_lim = [find(valeurs<Var_infos(i).limites(1)) find(valeurs>Var_infos(i).limites(2))];
            end
            if aie>0
                warning(sprintf('Attention la loi de probabilité de la variable ''%s'' à été tronquée %d fois (%d pts)!',Var_infos(i).nom, aie, nb_aie))
            end
        end
    end

end
