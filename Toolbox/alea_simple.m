function valeurs=alea_simple(varargin)
% Réalise un jet aléatoire pour chacune des variables
% 
% alea_simple(N, Type, definition)
%       N:          Nombre de jet
%       type:       Type de repartition probabiliste
%       definition: Définition de la répartition en fonction du type
   

RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
err=false;
if nargin==1
    if isnumeric(varargin{1})
        valeurs=randperm(varargin{1});
        return
    end
    err=true;
else
    if nargin==3
        N=varargin{1};
        type=varargin{2};
        definition=varargin{3};
        k=length(type);
        if k~=length(definition)
            err=true;
        end
    else
        err=true;
    end
end
if err, error('Entrées mal définies !'), end

valeurs=cell(N,k);

for i=1:k
    switch type{i}
        case {0,'Discret'}  % Intervale discret
            valeurs(:,i) = num2cell(randi( length(definition{i})-1 ,1,N) );
            
        case {1,'Uniform'}  % Intervale uniforme
            min = definition{i}(1);
            max = definition{i}(2);
            valeurs(:,i) = num2cell(min + (max-min)*rand(1,N));

        case {2,'Gaussian'}  % Intervale gaussienne
            moyenne = definition{i}(1);
            ecart_type = definition{i}(2);
            valeurs(:,i) = num2cell(moyenne + ecart_type*randn(1,N));
        otherwise
            error('Type de distribution non reconnu !')
    end
end
