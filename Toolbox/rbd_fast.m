function varargout=rbd_fast(etat,force,varargin)
% rbd_fast - Random Balance Designs For the estimation of first order indices
%
% Synopsis
%   [plan, index] = rbd_fast(etat,nb_tir,type,paramètres)
%
%
% Description
%
% Inputs ([]s are optional)
%   (<Type>) <Variable Name> <Explanation>
%
% Outputs ([]s are optional)
%   (<Type>) <Variable Name> <Explanation>
%
% Examples
%   <Example Code>
%
% See also
%   <See Also Function Name>
%
% Requirements
%   <Function Name> (<Toolbox Name>)
%
%=================================================
% etat=0 mise en place du plan
%   [plan, index]=rbd_fast(etat,force,nb_tir,type,paramètres)
%
%       nb_tir     : Nombre d'evaluation du modèle
%       type       : Type de ddp des variables
%       parametres : Paramètres de variation des variables
%
%       plan       : Plan d'evaluation du modèle
%       index      : Ordres initiaux des variables (nb_tir, nb_variable)
%
%=================================================
% etat=1 analyse des indices du 1er ordre
%
%   si=rbd_fast(etat,force,harmonics,index,sortie)
% 
%       harmonics : Nombre d'harmonics a prendre en compte (M=6)
%       index     : Ordres initiaux des variables (nb_tir, nb_variable)
%       sortie    : Matrice des sorties (nb_tir, nb_sortie)
%
%       si        : Indices de sensibilité  (nb_variable, nb_sortie)
%
%
%   si=rbd_fast(etat,force,harmonics,[],sortie,plan)
% 
%       harmonics : Nombre d'harmonics a prendre en compte (M=6)
%       index     : (reste vide) []
%       sortie    : Matrice des sorties (nb_tir, nb_sortie)
%       plan      : variables d'entrée du modèle 
%
%       si        : Indices de sensibilité  (nb_variable, nb_sortie)
%
%

% 
% References
%   Tarantola S., Gatelli, D. and T. Mara (2006) 
%   Random Balance Designs for the Estimation of First Order 
%   Global Sensitivity Indices, Reliability Engineering and System Safety, 91:6, 717-727
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
%   20/06/2012  First Edition
%   07/03/2013  Some minor errors corrected

% A FAIRE:
% faire d'autre échantillionnages ?


if etat==0    
    N = varargin{1}; % nb_tir = total number of model evaluations
    type = varargin{2};
    parametres = varargin{3};    

    if N<212
        if force
            warning('Le nombre de simulation semble insuffisant.');
        else
            texte = sprintf(['Nombre de simulations (%d) faible !\nMinimum de '...
                '212 simulations requis.\nN=2(M+L) avec L~100 et M=6.'],N);
            selection = questdlg(texte,'Attention ...',...
                'Augmenter','Laisser','Stop','Stop');

            switch selection
                case 'Augmenter'
                    N=212;
                case 'Stop'
                    error('Arrêt par l''utilisateur.')
            end
            clear selection
        end
    end

    
    
    k = size(type,1); % number of model inputs

    plan=cell(N,k); % plan de simulation
    index=zeros(N,k); %indexes aléatoires
    
    %rand('seed',sum(100*clock))
    %RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
    rng shuffle

    % discretisation de l'intervale [-pi;pi] en N+1 valeurs
    s0(:)=(-pi:2*pi/N:pi);
    % indexes aléatoires entre 1 et N
    for z=1:k;
        index(:,z)=randperm(N);  
    end
    % attribution des valeur aux index:
    % -> N valeurs "aléatoires" entre [-pi;pi[
    s=s0(index);
    % échantillonage uniforme dans [0; 1] de toute les variables
    s=.5+asin(sin(s))/pi;

    % attribution des valeurs
    for i=1:k
        switch type{i}

            case 0
                discret = parametres{i};
                niv = length(discret);  

                s2=1+floor(s(:,i)*(niv)); % OK jusqu'a 10 niveaux
                s2(s2>niv)=niv;
                %s2=1+round(s(:,i)*(niv-1));
                plan(:,i)=discret(s2);
                
            case 1
                xmax = parametres{i}(1);
                xmin = parametres{i}(2);
                plan(:,i)=num2cell(xmin + s(:,i)*(xmax-xmin));

        end
    end

    varargout{1}=plan;
    varargout{2}=index;
    
else %==============================================
    
    M=varargin{1}; %number of harmonics considered for the Fast Fourier Transform
    s=varargin{2}; %matrice index des variations (nb_tir, nb_variable)
    y=varargin{3}; %matrice des résultats (nb_tir, nb_sortie)
    
    if isempty(s) && ~isempty(varargin{4})
        variation=varargin{4};
        [N, k] = size(variation); % N = total number of evaluations % k = number of model inputs
    else
        variation=[];
        [N, k] = size(s);
    end
    
    sic=zeros(k,size(y,2)); % vecteurs colonnes de variance (nb_variable, nb_sortie)

    if N<(2*M+100)
        if force
            warning('Nombre de simulation insufisantes pour une analyse correcte');
        else
            error('Nombre de simulation insufisantes pour une analyse correcte');
        end
    end

    lamda=(2*M)/N;
    for i=1:k	
        
        if isempty(variation)
            % ---- reordering of y wrt ith index
            [~,ind]=sort(s(:,i),'descend');
            yr=y(ind,:);
        else
            % ---- reordering of y wrt ith variable
            [~,ind]=sort(variation(:,i));
            ind=ind([1:2:N N-mod(N,2):-2:1]);
            yr=y(ind,:);
        end
        
        
        %-----calculation spe1 at integer frequency
		%Densité spectrale de la réponse -> théorème de Parseval: le carré
		%de la Transformée de Fourier d'une variable correspond à la
		%décomposition de la variance dans le domaine fréquentiel.
		densite=(abs(fft(yr))).^2/(N*(N-1));
        %normalisation par N-1 pour corespondre à la définition non biaisée
        %de la variance. On a ainsi la meme définition que var(yr)
		V=sum(densite(2:end,:),1);   %somme du spectre sans la constante
%        [V-var(yr,0,1)]
        
        SI=2*sum(densite(2:M+1,:),1)./V;
        
        % Correction du biais de la méthode
        %les coef de Fourrier de la variable (dans les basses fréquences) 
        %incluent une partie de l'effet des autres variables (bruit blanc)
        %il est donc nécessaire de retrancher une partie de cette variance
        SIc(i,:)=SI-lamda/(1-lamda)*(1-SI);
        
        
        if false             	
            subplot(k,3,i*3-2); plot(variation(:,i),y,'.')
            subplot(k,3,i*3-1); plot ([yr variation(ind,i)]);
            subplot(k,3,i*3); plot(densite(2:4*M));
        end

    end
    varargout{1}=SIc;
    
    return
end
