function varargout=metamodelPC(PC_Infos,varargin)
% metamodelPC réalise des evaluations du metamodèle créé à partir des
% polynomes du chaos, communique avec la ToolBox de G. Blatman. 
%
%[YPC,X]=metamodelPC(PC_Infos,N[,'Echanti'])
%Produit des évaluations aléatoires du modèle en accord avec les polynomes
%Attention aux entrées discretes !
%
%[YPC,X]=metamodelPC(PC_Infos,Variables,Valeurs[,X_fixe])
%Evalue le modèle pour les valeurs données
%
%[YPC,X]=metamodelPC(PC_Infos,Variables,N[,X_fixe,'Echanti'])
%Produit des évaluations aléatoires du modèle en accord avec le polynome
%
%
% PC_Infos = infos sur le modèle voir: PCE_Blatman()
%     .gPC
%     .InputRV
%     .Coefs
% N = nombre de jet à réaliser
% Echanti = type de jet aléatoire
%               utilise une fonction de la toolbox
%               les valeur pouvant etre prises sont:
%                     - 'MCS': Monte Carlo , 'LHS': Latin Hypercube 
%                     - 'S': Sobol' (quasi-random sequences)
%                   (les sequences 'F': Faure et 'H': Halton sont)
%                   (également présentes dans la fonction mais je n'ai)
%                   (pas copier les fichiers nécessaires.)
% Variables = info sur les variables voir: main.m
% Valeurs = plan à évaluer
% X_fixe = vecteur composé les données à fixer
%               doit etre de meme taille que le nombre de variable
%               les entrées non fixées sont représentées par "NaN" 
%

% References
%     *** chaos adaptatif : G. Blatman and B.Sudret ,An adaptive algorithm
%     to build up sparse polynomial chaos expansions for stochastic finite
%     element analysis
%     *** algo LARS G. Blatman and B.Sudret, Adaptive sparse polynomial
%     chaos expansion based on {L}east {A}ngle {R}egression
%     *** Utilisation en analyse de sensibilité G. Blatman and B.Sudret,
%     Efficient computation of global sensitivity indices using sparse
%     polynomial chaos expansions
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
%   05/03/2013  First Edition
%   12/03/2013  Last Change

% A FAIRE:
% si la repartition n'est pas uniforme, le mini et le maxi ne sont pas définis
% le passage entre U et X n'est alors plus bon ...
% verifier si U corespond bien a une repartition gaussinne
% alors -> U*var+mean=X  -> (X-mean)/var

% Les valeur du plan qui doit etre evaluer ne sont pas verifié
% il faut faire comme pour Val_fix mais avec une matrice

error(nargchk(2,4,nargin)) %narginchk(2,4)
%addpath(genpath(fullfile(cd,local.noms.toolsPath)),'-begin')
if ~isstruct(PC_Infos)
        error('arguments PC_Infos')
end

% Recherche des donnés des varables
% (dans le premier polynome valide)
InputRV = PC_Infos(find(PC_Infos(1).sorties_valide,1)).InputRV;

% Création d'échantillions aléatoires en accord avec le polynome
% (pas de variables spécifiées)
if isnumeric(varargin{1})
    N=varargin{1};
    if nargin>2
        Options = varargin{2};
        testOptions(Options)
    else
        Options = 'LHS';
    end
    
    warning('off','MATLAB:oldPfileVersion')
    [U,X] = Sampling(N,InputRV,Options);
    warning('on','MATLAB:oldPfileVersion')

    
% Personalisation d'un échantillionnage
% Utilisation des variables
elseif isstruct(varargin{1})
    
    error(nargchk(3,4,nargin))%narginchk(3,4)

    Variables = varargin{1};

	% Convertir le plan de simulation pour le polynome
    if ~isscalar(varargin{2})
        
        X = varargin{2};
        if nargin==4
            keyboard
            X_temp = repmat(varargin{3},size(X,1),1);
            X_temp(:,find(isnan(varargin{3}))) = X;
            X=X_temp;
        end
        N = size(X,1);
        if size(X,2)~=Variables.vars_nb
            error('La taille du plan ne correspond pas au nombre de variable')
        end

        % verifier les min max pour que les valeur restent dans la plage de
        % définition du polynome? vérification deja faire pas la fonction ?

        U= X_to_U_gPC(X,InputRV);
    else
        N = varargin{2};

        % Lectude des options
        for i=3:nargin-1
            if ischar(varargin{i}) && ~exist('Options','var')
                Options=varargin{i};
                testOptions(Options)
            end
            if isnumeric(varargin{i}) && ~exist('X_fixe','var')                
                if length(varargin{i})==length(InputRV)
                    X_fixe = varargin{i}(:)';
                else
                    error('Le nombre de valeurs fixées n''est pas égal au nombre de variables.\n')
                end
            end
        end
        if ~exist('Options','var'),  Options = 'LHS'; end
        if ~exist('X_fixe','var'), X_fixe = nan(1,Variables.vars_nb); end
        
        
        [U,X] = Sampling(N,InputRV,Options);
        if  any(PC_Infos(1).vars_discet)
            
            for k=find(PC_Infos(1).vars_discet)
                X(:,k) = round( X(:,k) );  %*length(Variables.infos(k).limites)
            end
            U = X_to_U_gPC(X,InputRV);
        end

        U_fixe = X_to_U_gPC(X_fixe,InputRV);
        for k=find(~isnan(X_fixe))
            U(:,k)=U_fixe(k);
            X(:,k)=X_fixe(k);
        end



%       vérifier les bornes !
        %mini = min(X,[],2)';
        %maxi = max(X,[],1)';

    end
end

% boucle sur chaque PC
if length(PC_Infos)==1
    varargout{1}(:,PC_Infos.sorties_valide) = gPCEval(PC_Infos.gPC,PC_Infos.InputRV,PC_Infos.Coefs,U);
else
    for k=1:length(PC_Infos)
        % Evaluate the PC metamodel at the sample points
        if isempty(PC_Infos(k).gPC) continue, end
        varargout{1}(:,k) = gPCEval(PC_Infos(k).gPC,PC_Infos(k).InputRV,PC_Infos(k).Coefs,U);
    end
end
varargout{2}=X;

function testOptions(Options)
validOptions = {'MCS','LHS','S'}; %'F', 'H'
bogusFields = setdiff(Options,validOptions);
if ~isempty(bogusFields)
    error('MATLAB:metamodelPC:InvalidOption' ,'Option "%s" non valide.',bogusFields{1});
end

