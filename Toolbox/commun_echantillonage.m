function commun_echantillonage
% commun_echantillonage gère les différents types d'échantillonages disponible
%
% La variable params contient toute les informations nécéssaire:
%     o Les infos d'échantillonnage 
%         params.type_ech : Identifiant du type d'échantillonnage
%         params.nb_tir :   Nombre de simulation
%     o Les variables/paramètres à analyser
%         params.variables.infos = { type, nom, loi, moments, plage }


% type(var:1/param:0/off:-1),
% nom, loi(R=en relatif),
% [moyenne écrat]/val_par_def,
% [min max]/{'txt1' 'txt2'} 


%             Type      : Type d'entrée (1=variable / 0=paramètre cst. / -1=déactivée)
%             Nom       : Nom de la variable à remplacer dans le fichier idf
%             Loi       : Loi de distribution (R= définition relative des moments)
%             Moments   : Informations sur la loi
%                           0- Discret uniforme / Moments = Id valeur par défaut
%                           1- Uniforme / Moments = [moyenne variation]
%                           2- Gaussienne / Moments = [moyenne variation]
%                           3- UniformeR / Moments = [moyenne %variation]
%                           4- GaussienneR / Moments = [moyenne %variation]
%             Params    : Paramètres de la répartition
%     o Le plan des simulation à réaliser
%     o Les E/S suprementaires nécéssaire à l'analyse
%     o La matrice des resultats
%
% Identifiants des type d'analyses présentes:
%     0 - Simulation simple du fichier de base
%     1 - Aléa
%     2 - ASL
%     3 - Random Balance Designs - FAST


% 
% SOUMISSIONNAIRE :
% Mickael Rabouille (création)
% 
% Version du 06/09/2012
% A FAIRE:
% 
%

global params
global analyse

if analyse.type_etude==5 % SOBOL
    fprintf('  --> Le type d''étude est: 5 (Indices de SOBOL)\n')
    params.nb_tir = ceil(params.nb_tir/2);
end


switch params.type_ech
    case -2  % N simulations simples du fichier de base (N = params.nb_tir)
        fprintf('-> Utilisation du fichier .idf de base.\n')
        params.plan=nan(1,params.variables.params_nb+params.variables.vars_nb);
        return
        
    case -1  % N simulations avec les paramètres fixés (N = params.nb_tir)
        fprintf('-> Pas de variations mais intégration des paramètres.\n')
        params.plan=nan(1,params.variables.vars_nb);
        
    case 0  % N simulations avec les médianes (N = params.nb_tir)
        fprintf('-> Pas de variations mais intégration des paramètres.\n')
        params.plan=repmat(cellfun(@(X) X(1), {params.variables.infos(params.variables.vars_index).moments}), params.nb_tir,1);
       
    case 1  % N simulations aléatoires
        fprintf('-> Variations aléatoires simples.\n')
        params.plan=alea_simple(params.nb_tir, {params.variables.infos(params.variables.vars_index).loi}, {params.variables.infos(params.variables.vars_index).moments});
        
    case 2  %ASL
        if any(strcmpi({params.variables.infos(params.variables.vars_index).loi}, 'Discret'))
            error('Type de distribution ''Discret'' invalide !')
        end
        fprintf('-> ASL(clara): variation d''un facteur à la foi (N=%d).\n',params.variables.vars_nb)
        fprintf('  --> Le nombre d''éssais sera fixé à: %d\n', params.variables.vars_nb+1);
        if ~isfield(params, 'facteur_ASL')
            params.facteur_ASL = 1+input('Facteur de variation à définir [+/-10%] : ')/100;
        end
        if isempty(params.facteur_ASL) error('Arrêt par l''utilisateur.'); end
        
        [params.plan,params.nb_tir]=asl(0,{params.variables.infos(params.variables.vars_index).moments},params.facteur_ASL);
        
    case 3  %RBD
        fprintf('-> Random Balance Designs.\n')
        keyboard
        if ~isfield(analyse,'RBD_force')
            analyse.RBD_force=false;    % outrepasse les vérifications de l'analyses
        end
        [params.plan,params.index_rbd_fast]=rbd_fast(0,analyse.RBD_force,params.nb_tir, params.entrees_IDF.vars(:,3), params.entrees_IDF.vars(:,4));
        
    case 4  % LHS_local
        fprintf('-> Latin Hypercube Sampling (local).\n')
        [params.plan,index]=LHS(params.nb_tir, create_index(), params.variables.infos(params.variables.vars_index), true);
        
    case 5  % LHS_global
        fprintf('-> Latin Hypercube Sampling (global -> uniforme).\n')
        [params.plan,index]=LHS(params.nb_tir, create_index(), params.variables.infos(params.variables.vars_index), false);

    case 6  % Suite de Halton
        fprintf('-> Halton Speudo-Random Sequence (local).\n')
        [params.plan,index]=pseudo_rand('halton',params.nb_tir, params.variables.infos(params.variables.vars_index), true);
        
    case 7  % Suite de Halton
        fprintf('-> Halton Speudo-Random Sequence (global).\n')
        [params.plan,index]=pseudo_rand('halton',params.nb_tir, params.variables.infos(params.variables.vars_index), false);
     
	case 8  % Suite de Sobol
        fprintf('-> LPTau/Sobol Speudo-Random Sequence (local).\n')
        if params.variables.vars_nb<=51
            method = 'lptau51';
        elseif params.variables.vars_nb<=370
            method = 'lptau370';
        else
            error('oversize')
        end
        [params.plan,index]=pseudo_rand(method,params.nb_tir, params.variables.infos(params.variables.vars_index), true);
        
    case 9  % Suite de Sobol
        fprintf('-> LPTau/Sobol Speudo-Random Sequence (global).\n')
        if params.variables.vars_nb<=51
            method = 'lptau51';
        elseif params.variables.vars_nb<=370
            method = 'lptau370';
        else
            error('oversize')
        end
        [params.plan,index]=pseudo_rand(method,params.nb_tir, params.variables.infos(params.variables.vars_index), false);
        
        
	case 10  % MORRIS
        fprintf('-> Screening MORRIS (global -> uniforme).\n')
        
        if analyse.type_etude~=6
            error('Le type d''étude doit correspondre à la méthode du Screening de MORRIS.')
        end
        if ~isfield(params,'MORRIS_diag')
            params.MORRIS_diag = false;         %graph de diag
        end
        
        if ~isfield(params,'MORRIS_finalTrajs')
            params.nb_tir = params.nb_tir + mod(params.nb_tir,params.variables.vars_nb+1);
            params.MORRIS_finalTrajs = params.nb_tir/(params.variables.vars_nb+1);
        else
            params.nb_tir = params.MORRIS_finalTrajs*(params.variables.vars_nb+1);
        end
        
        
        if ~isfield(params,'MORRIS_initialTrajs')
            params.MORRIS_initialTrajs = 10*params.MORRIS_finalTrajs;   %initial set of traj to compute
        end
        if ~isfield(params,'MORRIS_levels')
            params.MORRIS_levels = 4;           %number of levels for each input
        end
        if ~isfield(params,'MORRIS_groupMat')
            params.MORRIS_groupMat=[];      %group of inputs size(NumFact,NumGroups)
        end
        
        if any(strcmpi({params.variables.infos(params.variables.vars_index).loi}, 'Discret'))
            error('Type de distribution ''Discret'' invalide !')
        end
        
        params.MORRIS_sampledTraj = Morris_Optimized_Groups(params.variables.vars_nb,params.MORRIS_initialTrajs,params.MORRIS_levels,params.MORRIS_finalTrajs,params.MORRIS_groupMat,params.MORRIS_diag);
        
        params.plan = zeros(size(params.MORRIS_sampledTraj));
        for i=params.variables.vars_index
            limites=params.variables.infos(i).limites;
            if numel(limites)~=2
                error('Les limites de la variable ''%s'' sont mal définies !',params.variables.infos(i).nom)
            end
            params.plan(:,i) = limites(1) + (limites(2)-limites(1))*params.MORRIS_sampledTraj(:,i);
        end
        
        
    otherwise
        error(sprintf('Echantillonage "%d" non défini.',params.type_ech))
end


if analyse.type_etude==5 % SOBOL
    % Préparation du second jeux de simulation
    
    % Permutations et création des index 
    for i=1:params.variables.vars_nb
        params.index_rbd_sobol(:,i)=randperm(params.nb_tir);
        suite_plan(:,i)=params.plan(params.index_rbd_sobol(:,i),i);
    end

    if params.variables.vars_nb~=0
        params.plan = vertcat(params.plan,suite_plan);
    else
        params.index_rbd_sobol = zeros(params.nb_tir,0);
        params.plan = vertcat(params.plan,params.plan);
    end

    params.nb_tir = params.nb_tir*2;
end

%=== Ajout des paramètres au plan ===

% Méthode de variation des paramètre ???
% --> par defaut valeur de base: mediane
for i=params.variables.params_index
    params.plan= horzcat(params.plan, repmat(params.variables.infos(i).moments(1),size(params.plan,1),1) );
end


% % TEST DU PLAN !!!
% global legende
% for k=1:size(params.plan,2)
%     id = params.variables.actif(k);
%     figure
%     hist(params.plan(:,k))
%     title(sprintf('%s - %s (%f - %f)', legende.vars{k,2}, params.variables.infos(id).loi, params.variables.infos(id).moments ))
% end
% keyboard
% close all


