function index = create_index(nb_tir,vars_nb,type_plan_LHS)
% index = create_index(1000,20,1);
%
%
%

rng shuffle
if nargin==0
    global params
    nb_tir = params.nb_tir;
    vars_nb = params.variables.vars_nb;
    type_plan_LHS = params.type_plan_LHS;    
end

if vars_nb==0
    index=false;
end

switch type_plan_LHS  % 0:sans 1:minimean10 2:minimax10
    case 0
        for i=1:variables.vars_nb
            index(:,i)=randperm(nb_tir);
        end
        
    case 1
        %fprintf('  --> Minimean x10.\n')
        A=zeros(nb_tir,vars_nb); %indexes aléatoires
        test_old=0;
        % Meilleur plan minimean parmi 10
        for l=1:10
            for i=1:vars_nb
                A(:,i)=randperm(nb_tir);
            end
            test=minidist(A,1);
            if test>test_old
                index=A;
                test_old=test;
            end
        end
        clear A test_old
        
    case 2
        fprintf('  --> Minimax x10.\n')
        A=zeros(nb_tir,vars_nb); %indexes aléatoires
        test_old=0;
        % Meilleur plan maximin parmi 10
        for l=1:10
            for i=1:vars_nb
                A(:,i)=randperm(nb_tir);
            end
            test=minidist(A,2);
            if test>test_old
                index=A;
                test_old=test;
            end
        end
        clear A test_old
        
        
    otherwise
        error('index non reconnu')
end
end


function C=minidist(A, opt)
% minidist - Calcul l'ecart de chaque point à son plus
% proche voisin pour produire un indicateur de dispertion.
%
%   opt=1   minimean: maximiser la moyenne des distances
%   opt=2   minimax:  maximiser la plus petite entre 2 points
%
% Description
%   Normalise les valeurs en fonction des éléments présent    
%   Pour chaque point, calcule la distance du plus proche voisin
%   Evalue les distances de tous les points pour formet un indicateur.
%
% Requirements
%   -none-
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
%   06/06/2013  Last Change

if ~exist('opt','var')
    opt=1;
end   

tailleA = size(A);
% Nomalisation
miniA = min(A,[],1);
maxiA = max(A,[],1);
A = bsxfun(@rdivide, bsxfun(@minus, A , miniA ) ,maxiA-miniA );

B=zeros(tailleA(1),1);
for k=1:tailleA(1) % k un point du plan
    % Recherche du plus proche voisin dans L2,
    % le point j qui minimise la distance d
    % d = sqrt(  (Xj -Xi)² + (Yj -Yi)² + (Zj -Zi)² + ... )
    B(k)= min ( sqrt( sum( ( bsxfun(@minus, A([1:k-1, k+1:end],:) , A(k,:)) ).^2 ,2) ) );
end
% B vecteur composé des distances au plus proche voisin de chaque point

if opt==1
    % Moyenne des distances
    % plus le résultat est grand plus les points sont dispercés
    C = mean(B);
elseif opt==2
    % Plus petite distance entre 2 points
    % plus le résultat est grand plus les points sont dispercés
    C = min(B);
else
    error('Valeur opt incorrecte')
end

end



