function varargout=asl(etat,varargin)
% ASL réalise une analyse de sensibilité locale. Les variables sont
% modifiées à tour de rôle selon un facteur défini.
% 
% etat=0 mise en place du plan
% 
%   [plan, nb_tir]=asl(etat,variables,facteur)
% 
% etat=1 analyse 
% 
%   si=asl(etat,)

if etat==0  
    
    variables = cell2mat(varargin{1}');
    variables = variables(:,1);
    facteur = varargin{2};
    nb_tir=length(variables);
    
%    for i=1:nb_tir, if ~isnumeric(variables{i}), error('Entrée non numérique présente !'), end, end;
%    variables=mean(cell2mat(variables),2);
    
    
    plan(1:nb_tir,:) = repmat(variables',nb_tir,1); %plan avec les valeur initiales
    plan(1:nb_tir+1:end) = variables.*facteur; %modification d'un facteur à la fois

    % ajout d'une simulation de base
    plan = vertcat(variables',plan);
    nb_tir=nb_tir+1;
    
    varargout{1}=num2cell(plan);
    varargout{2}=nb_tir;
else
    
    
    
end






