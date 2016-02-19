function [plan,index]=pseudo_rand(seq,N,Var_infos,X_fixe)
% pseudo_rand - R�alise un jet al�atoire pour chacune des variables selon
% une sequence pseudo al�atoire d�finie
%
% Description
%   [plan, index]=pseudo_rand(seq,nb_tir,type,parametres)
%
%       seq        : Nom de la s�quence utilis�e
%       N          : Nombre d'�valuation du mod�le
%       type       : Type de ddp des variables
%       parametres : Parametres de variation des variables
%
%       plan       : Plan d'�valuation du mod�le
%       index      : S�quences initiales g�n�r�es (nb_tir, nb_variable)
%  
%
% Requirements
%   lptau51seq(), lptau370seq(), haltonseq()
% References
%   -none-
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
%   20/02/2014  Modification de toutes les lois en uniformes (global)
%   29/11/2013  Update
%   26/10/2013  Cr�ation
%
%

% TO DO LIST
%   Lors de la g�n�ration des gaussiennes, en fonction de la moyenne les 
%   valeurs peuvent sortir de la plage de validit� des variables.
%   --> Donner la possibilit� de tonquer les r�sultats. Ex:Val. n�gatives 
%

k = length(Var_infos); % Nombre de variables

plan=zeros(N,k); % plan de simulation

switch seq
    case 'lptau51'
        index = lptau51seq(N,k);
        
    case 'lptau370'
        index = lptau370seq(N,k);
        
    case 'halton'
        index = haltonseq(N,k);
end

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

% G�n�ration des �chantillions
for i=1:k
    
    if local(i)
        %LOCALE
        parametres=Var_infos(i).moments;
        
        if ~isnan(X_fixe(i))
            parametres(1)=X_fixe(i);
        end
        

        switch Var_infos(i).loi
            case {0,'Discret'} % Intervale discret uniforme
                %NON PAS d'incertitudes sur les entr�es discretes
                plan(:,i)=parametres;
                
            case {1,'Uniform'} % Intervale uniforme
                moyenne = parametres(1);
                variation = parametres(2);
                
                valeurs = 2*index(:,i)-1;  %pseudo al�atoire entre ]-1;1[
                plan(:,i)=moyenne + variation*(valeurs);
                
            case {2,'Gaussian'} % Intervale gaussienne
                moyenne = parametres(1);
                ecart_type = parametres(2)/1.96; % !Taux de confiance 95%!
                
                plan(:,i) = norminv(index(:,i),moyenne,ecart_type);
                test_limites()
                
                
            case {3,'UniformR'} % Intervale uniforme
                moyenne = parametres(1);
                ecart_relatif = parametres(2)/100; % Ex: +/- 10%
                
                valeurs = 2*index(:,i)-1;  %pseudo al�atoire entre ]-1;1[
                
                % Loi uniforme dans ]min;max[
                plan(:,i)=moyenne + abs(moyenne*ecart_relatif)*(valeurs);
                
            case {4,'GaussianR'} % Intervale gaussienne
                moyenne = parametres(1);
                ecart_type = abs(parametres(2)/100*moyenne)/1.96; % Ex: parametres(2) +/- 10%
                
                % G�n�ration de la loi
                % Taux de confiance:
                %             99 % -> 2.58
                %             95 % -> 1.96
                %             90 % -> 1.64
                plan(:,i) = norminv(index(:,i),moyenne,ecart_type);
                test_limites()
                
            otherwise
                error(sprintf('Le type de la variable %s n''est pas reconnu !',Var_infos(i).nom))
        end
        
    else
        
        %Global
        if numel(Var_infos(i).limites)~=2 && ~strcmp(Var_infos(i).loi,'Discret')
            error('Les limites de la variable ''%s'' sont mal d�finies !',Var_infos(i).nom)
        end
        parametres=Var_infos(i).limites;

        
        switch Var_infos(i).loi
            case {0,'Discret'} % Intervale discret uniforme
                niv_max = length(parametres);
                
                niv=1+floor(index(:,i)*niv_max); %OK jusqu'a 10 niveaux
                niv(niv>niv_max)=niv_max;
                % index des valeurs dans le plan
                plan(:,i)=niv;
                
                %plot(index(:,i), interval, 'x')
                %subplot(2,1,1),hist(index(:,i)),subplot(2,1,2),hist(interval,[1:niv]),
                %subplot(1,1,1) %(clear)
                
            case {1,'Uniform',2,'Gaussian',3,'UniformR',4,'GaussianR'} % Tout Uniforme !
                
                mini = parametres(1);
                maxi = parametres(2);
                
                plan(:,i)= mini + (maxi-mini)*index(:,i);
                
            otherwise
                error('type de variable non reconnu !')
        end
        %====TEST====
        %     plot(index(:,i), plan(:,i), 'x')
        %     pause
        %     subplot(2,1,1),hist(index(:,i)),subplot(2,1,2),hist(plan(:,i)),
        %     pause
        %     subplot(1,1,1) %--> clear
        %============
    end
end

    function test_limites()
        
        if ~isempty(Var_infos(i).limites)
            hors_lim = sum(or(plan(:,i)<Var_infos(i).limites(1), plan(:,i)>Var_infos(i).limites(2)));
            if hors_lim>0
                error(sprintf('Attention la loi de probabilit� de la variable ''%s'' sort des limites d�finies (%d pts)!\n [min max] = [%1.3g %1.3g]\n Limites  =  [%1.3g %1.3g]',Var_infos(i).nom, hors_lim, min(plan(:,i)), max(plan(:,i)), Var_infos(i).limites))
            end
        end
    end

end