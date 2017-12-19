function EPLab(FileConfig)
% EPLab - Analyse de sensibilité sur un modele de batiment E+
%
% Description
%   Permet de réaliser des analyses a partir d'un fichier de simulation
%   EnergyPlus modifié et/ou d'un fichier Météo.
%
% Requirements
% 
%   - Le fichier idf doit contenir les lignes suivantes :
%     Output:Surfaces:List,Details;% 
%     les Output définies dans la variable 'sorties' ci-dessous
%
%     Et optionnellement:
%     IDF,Output:IlluminanceMap,Eclairement,Zone 1,0.8,1,9,9,1,4,4;
%     IDF,OutputControl:IlluminanceMap:Style,Comma;
% 
%     Schedule:Compact,Work Eff Sch,Any Number,Through: 12/31,For: AllDays,Until: 24:00,0.0;
%     Schedule:Compact,Clothing Sch,Any Number,Through: 4/1,For: AllDays,Until: 24:00,1,Through: 9/30,For: AllDays,Until: 24:00,.5,Through: 12/31,For: AllDays,Until: 24:00,1;
%     Schedule:Compact,Air Velo Sch,Any Number,Through: 12/31,For: AllDays,Until: 24:00,0.137;
%     People,Name,Zone_name,ALWAYS on,People/Area,,0.04,,0.3,autocalculate,Activity Salle,0,No,,,Work Eff Sch,Clothing Sch,Air Velo Sch,Fanger,AdaptiveCEN15251,,,;
%
%
%   - La décomposition du modéle en polynomes du chaos nécessite la Toolbox de G. BLATMAN
%
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
%   17/11/2013  Last Change

% variables générales
%     local :       données générales redéfinies à chaque chargement
%     params :  	échantillonnage 'ne peut etre modifié'
%     simulation: 	etats des simulations
%     resultats :	extraction des résultats
%     analyse :  	analyse des résultats 

%{
A FAIRE:
 - Si climat doux et que il y a des jours en evo libre en hiver.
 la recherche des plages d'etude plante

 - Si le nombre de variable est trop important elle ne sont pas toutes
 affichées(à vérifier) dans le fichier csv. mais restent présentes dans le
 fichier eso. faire une extraction directement é partir du fichier eso
 
 - Gestion des erreurs 
    Ex: transmettre un message d'erreur si un idf ne c'est pas bien créé

 - Permettre la reprise d'une étude sans écraser les variables de
 configuration initiale (exemple ré-extraire les images avec les anciennes
 légendes)
 
 - Configuration statistique des variables choix entre 2 lois de probabilité (état initial/final)
%}


%% Chargement

format short; %format d'affichage des sorties MatLab(long: 16 chiffres)

% clear all
fclose('all');
delete(timerfind)   % clear all timer fonctions

% Vars=whos;
% PersistentVars=Vars(or([Vars.global],[Vars.persistent]));
% PersistentVarNames={PersistentVars.name};
% clear(PersistentVarNames{:});

global local
global params               % Variables générales
global simulation           % Variables de la simulation (pre-process)
global resultat
global geometrie  % a voir -> mettre dans une autre variable ?
global analyse              % Variables spécifiques à l'analyse réalisée (post-process)
global affichage
global legende

local=[]; params=[]; simulation=[]; resultat=[]; geometrie=[]; analyse=[]; affichage=[]; legende=[];

% Import des Toolbox
addpath(genpath(fullfile(pwd,'Toolbox')),'-begin')

% Chargement d'un fichier de configuration
if ~exist('FileConfig','var')
    [FileConfig,LocalPath] = uigetfile('*config*.m'); %,'Select file to open',LocalPath
    if isequal(FileConfig,0)
        error('Arrêt par l''utilisateur.')
    end
else
    [LocalPath,FileConfig,ext] = fileparts(FileConfig);
    if isempty(ext)
        [FileConfig,LocalPath] = uigetfile(fullfile(LocalPath,FileConfig,'*config*.m')); %,'Select file to open',LocalPath
        if isequal(FileConfig,0)
            error('Arrï¿½t par l''utilisateur.')
        end
    else
        FileConfig = [FileConfig,ext];
        if isempty(LocalPath), LocalPath=pwd; end
    end
    clear ext
end
if ~exist(fullfile(LocalPath,FileConfig),'file')
    error('Fichier de configuration non trouvé.')
end

% Lecture du fichier
if ~all(strcmp(strsplit(FileConfig,'.'),genvarname(strsplit(FileConfig,'.'))))
    error('Invalide file Name: %s',FileConfig)
end
FileConfig = fullfile(LocalPath,FileConfig);
run(FileConfig)

if ~strcmp(EPLab_version, '1.8.1')
    error('Wrong version of the config file.\nEPLab:\t1.8.1\nconfig:\t%s\n',EPLab_version)
end

%% Initialisation

% Recherche du fichier de sauvegarde
if exist(fullfile(LocalPath,local.noms.save) ,'file')
%=== Le fichier config est dans le repertoire de résultat ===
    params.rep_result=LocalPath;
    loc = strfind( LocalPath, [local.noms.result local.noms.etude]);
    if isempty(loc)
        error('Le nom du repertoire ne corespond pas au nom de l''étude')
    end
    load_file=true;
    LocalPath = LocalPath(1:loc-1);
    clear loc
else
%=== Le fichier config n'est pas dans un repertoire de résultat ===

    % Répertoires des résultats et des simulations
    params.rep_result=fullfile(LocalPath,[local.noms.result local.noms.etude]);
    params.rep_simul=fullfile(LocalPath,[local.noms.simul local.noms.etude]);

    % Vérification des sous-répertoires -> RAZ / Sauvegarde / Chargement
    exist_result = size(dir(params.rep_result),1)>2;
    exist_simul = size(dir(params.rep_simul),1)>3;
    if (exist_result || exist_simul)  
        %Des fichier sont présent dans les repertoires        
        %Lecture d'un autre fichier de configuration
        %Gestion du conflit du à la présence de données
        switch questdlg('Fichier(s) trouvé(s) dans le(s) répertoire(s) de travail.',sprintf('Conflit : %s', local.noms.etude), 'Faire une copie','Ecraser','Inclure infos locales','Inclure infos locales')
            case 'Inclure infos locales'
                % Les données sont utilisées avec le nouveux fichier de configuration, choix des options plus bas
                if ~exist(fullfile(params.rep_result, 'config.m.bak'), 'file')
                    % sauvegarde de la configuration de base
                    copyfile(fullfile(params.rep_result, 'config.m'),fullfile(params.rep_result, 'config_base.m.bak'));
                end
                load_file=true;
                copyfile(FileConfig,fullfile(params.rep_result, 'config.m'))

            case 'Ecraser'
                % Effacement des fichiers existant et nouvelle analyse
                if ~strcmp('Supprimer', questdlg('Confirmez l''éffacement des fichiers présent dans les répertoires.',sprintf('Conflit : %s', local.noms.etude), 'Supprimer','Stop','Stop'))
                    error('Arrêt par l''utilisateur.')
                end
                try
                    if exist_result, rmdir(params.rep_result,'s'), end
                    if exist_simul,  rmdir(params.rep_simul,'s'),  end
                end

            case 'Faire une copie'
                % Déplacement des fichiers existant et nouvelle analyse
    %A FAIRE: Mettre à jours les répertoires pour pouvoir lancer la sauvegarde directement
                if exist_result, movefile(params.rep_result, [params.rep_result '_' datestr(now, 'yymmdd-HHMM')]), end
                if exist_simul , movefile(params.rep_simul, [params.rep_simul '_' datestr(now, 'yymmdd-HHMM')]),   end
                if ~strcmp(questdlg('La simulation é été sauvegardée... Poursuivre ?',sprintf('Conflit : %s', local.noms.etude),'Oui','Non','Non'),'Oui')
                    error('Arrêt par l''utilisateur.')
                end

            otherwise
                error('Arrêt par l''utilisateur.')
        end
        clear selection
        
    end
    clear exist_simul exist_result
end

fprintf('\n\n\n======%s======\n',repmat('=',1,length(local.noms.etude)) );
fprintf('===== %s =====\n',local.noms.etude);
fprintf('======%s======\n\n',repmat('=',1,length(local.noms.etude)) );
fprintf('appel direct: EPLab(''%s'') \n',fullfile(params.rep_result, 'config.m') ); % FileConfig

% Chargement d'une simulation précédente
if exist('load_file','var') && load_file
    fprintf('Reprise d''une analyse.\n');
    % Recherche du fichier de sauvegarde
    if ~exist(fullfile(params.rep_result,local.noms.save) ,'file')
        error(['Le fichier ''' local.noms.save ''' n''a pas été trouvé.'])
    end

    % Récupération l'avancement précédant
    load(fullfile(params.rep_result,local.noms.save), 'etape')
    liste_etapes= { '1/ Plan',...
                    '2/ Fichiers',...
                    '3/ Simulations',...
                    '4/ Extraction',...
                    '5/ Mise en forme',...
                    '6/ Analyse',...
                    '7/ Fin'};
    [etape,ok] = listdlg('ListString',liste_etapes(1:etape),...
                    'SelectionMode','single',...
                    'ListSize',[160 100],...
                    'InitialValue',etape,...
                    'PromptString','Selectionnez l''étape de départ:'); %#ok<NODEF>
    if ~ok, error('Arrêt par l''utilisateur.'), end    
    clear load_file liste_etapes ok

    % Chargement des données enregistrées

    if etape == 1
        % Reprise du début: pas de chargement de données sauvegardées
        INIT=true;
        params.rep_simul=fullfile(LocalPath,[local.noms.simul local.noms.etude]);
    end
    if etape >= 2
        % Chargement des données générales
        load(fullfile(params.rep_result,local.noms.save), 'params')
        % Mise à jour des répertoires 'résultats' et 'simulations'
        params.rep_result=fullfile(LocalPath,[local.noms.result local.noms.etude]);
        params.rep_simul=fullfile(LocalPath,[local.noms.simul local.noms.etude]);
        
        % ?
        if etape<3 && strcmp(params.EPW_type,'liste')
            if ~isfield(simulation.EPW,'plan')
                error('1'); end
            if isempty(cell2mat(strfind({params.variables.infos.nom},'METEO')))
                error('2'); end
        end
    if etape >= 3
        % Reprise pour simulations :
        % Infos sur les simulations déja produites
        load(fullfile(params.rep_result,local.noms.save), 'simulation')
    if etape >= 3
        if isfield(simulation,'etats')&& any(simulation.etats>1)
            % Reprise pour l'extraction: données dans le rep. simulation
            load(fullfile(params.rep_result,'commun.mat'))
        end
    if etape >= 5
        % Reprise pour mise en forme des indicateurs: données dans le rep. résultat
    if etape >= 6
        % Reprise pour analyse :
        % Chargement des donnés de simulation mise en forme
        load(fullfile(params.rep_result,local.noms.save), 'resultat', 'legende')
    if etape >= 7
        % Reprise pour exploitation (aprés création des images):
        % Chargement des résultats d'analyse
        load(fullfile(params.rep_result,local.noms.save), 'analyse')
    end
    end
    end
    end
    end
    end


else
    INIT=true;
end

if exist('INIT','var')  && INIT
    clear INIT
    % Initialisation d'une nouvelle étude
    etape=1;
    % Création du répertoire de résultat
    if ~exist( params.rep_result, 'dir')
        mkdir(params.rep_result)    
    end
    % Sauvegarde du fichier de configuration
    if ~strcmp(FileConfig, fullfile(params.rep_result, 'config.m') )
        copyfile(FileConfig,fullfile(params.rep_result, 'config.m'))
    end
    
    % Intégration de la météo dans le plan
    if strcmp(params.EPW_type,'liste')
        params.variables.infos(end+1) = struct('actif',1, 'nom','METEO', 'loi','Discret', 'moments',1, 'limites',{simulation.EPW.name});       
    end
    
    % Organisation des variables
    params.variables.vars_index = find([params.variables.infos.actif]==1);
    params.variables.vars_nb = length(params.variables.vars_index);
    params.variables.params_index = find([params.variables.infos.actif]==0);
    params.variables.params_nb = length(params.variables.params_index);
    params.variables.actif = sort([params.variables.vars_index, params.variables.params_index]);
    params.variables.actif_nb = length(params.variables.actif);

    save(fullfile(params.rep_result,local.noms.save))
end

% Définition du nom des variables et leurs unitées
legende.vars = cell(params.variables.actif_nb,3);
for k=1:params.variables.actif_nb
    rech = strcmp ({params.variables.infos(params.variables.actif(k)).nom}, local.vars_names(:,1));
    if all(~rech) error(sprintf(' La variable ''%s'' ne dispose pas de légende.\n Veuillez ajouter la ligne correspondante dans ''local.vars_names''.',params.variables.infos(params.variables.actif(k)).nom)); end
    %type: 1=nom_variable / 2=nom_long / 3= nom_court / 4= unit
    legende.vars{k,1} = sprintf('%s %s', local.vars_names{rech,2}, local.vars_names{rech,4} ); % légende complette
    legende.vars{k,2} = local.vars_names{rech,3};   % nom_court
    legende.vars{k,3} = local.vars_names{rech,4};   % unité
end
clear rech

% Valeurs par defaut
if ~isfield(resultat,'extract_lum'),    resultat.extract_lum = true;    end
if ~isfield(local,'verif_limites'),     local.verif_limites = true;     end
if ~isfield(local,'recap_plan'),        local.recap_plan = true;        end


% Vérification somaire des limites de variation locales
if ~local.verif_limites
    warning('Vérification annulée !')
else
    for k=params.variables.vars_index
        if ~isempty(params.variables.infos(k).limites)
            switch params.variables.infos(k).loi

                case {0,'Discret'} % Intervale discret uniforme
%                     if ~strcmp(params.variables.infos(k).nom, 'METEO')
                    if  params.variables.infos(k).moments(1)<1 ||  params.variables.infos(k).moments(1)>length(params.variables.infos(k).limites)
                        error(sprintf('La valeur définie est hors des limites d''étude.\nVérifier la variable : ''%s''',params.variables.infos(k).nom))
                    end
%                     end
                case {1,'Uniform',2,'Gaussian'}
                    centre = params.variables.infos(k).moments(1);
                    ecart = params.variables.infos(k).moments(2);
                    if params.variables.infos(k).limites(1)>centre-ecart || params.variables.infos(k).limites(2)<centre+ecart
                        error(sprintf([ 'Les variations sont trop proches des limites d''étude.\n',...
                                        'Vérifier la variable : ''%s''\n',...
                                        '%g < %g  || %g < %g' ],params.variables.infos(k).nom,...
                                        params.variables.infos(k).limites(1),centre-ecart,centre+ecart,params.variables.infos(k).limites(2)) )
                    end

                case {3,'UniformR',4,'GaussianR'}
                    centre = params.variables.infos(k).moments(1);
                    ecart = params.variables.infos(k).moments(1)*params.variables.infos(k).moments(2)/100;
                    if params.variables.infos(k).limites(1)>centre-ecart || params.variables.infos(k).limites(2)<centre+ecart
                        error(sprintf('Les variations sont trop proches des limites d''étude.\nVérifier la variable : ''%s''',params.variables.infos(k).nom))
                    end
            end
            clear centre ecart
        end
    end
end

% Vérification des éléments nécessaires aux simulations
if etape<4
    if ~exist( params.rep_simul, 'dir')
        mkdir(params.rep_simul)
    end

    switch upper(params.model)
        case {'E+','EP','ENERGYPLUS'}
            % Test Version E+
            IDF_dir = { fullfile(params.rep_result, sprintf('%s.idf',simulation.IDF_initial)),
                        fullfile(LocalPath, sprintf('%s.idf',simulation.IDF_initial)),
                        fullfile(pwd, sprintf('%s.idf',simulation.IDF_initial))};

            [Ep_dir,IDF_dir,simulation.version]=checkVersionEP(IDF_dir, Ep_dir);

            if ~str2double(simulation.version)>8
                error('Old releases of EnergyPlus are not supported since V8\nVersion: %s', simulation.version)
            end
            if str2double(simulation.version)>8.5
                error('Version non configurée: ''%s''',simulation.version)
            end
            % Copie RunEplus modifié dans le dossier de simulation
            modif_RunEplus(params.rep_simul, Ep_dir);
            
            
            % Test la presence de la ligne "Output:Surfaces:List, Details;"
            % dans le fichier idf (necessaire a la lecture de la geometrie)
            if isempty(  regexpi(fileread(IDF_dir), '(output\s*:\s*Surfaces\s*:\s*List\s*,\s*Details\s*;)') )
                % Ligne absente, ajout de la ligne
                fid = fopen(IDF_dir,'A');
                fprintf(fid,'\nOutput:Surfaces:List, Details;\n');
                fclose(fid);
            end
            
            
        case {'DOMUS'}
% Les modifications appostées par Lais Lagos             
%{        
   > where is the idf you are looking for ? (list of possible path)
           IDF_dir = { fullfile(params.rep_result, sprintf('%s.idf',simulation.IDF_initial)),
                       fullfile(LocalPath, sprintf('%s.idf',simulation.IDF_initial)),
                       fullfile(pwd, sprintf('%s.idf',simulation.IDF_initial))}; 
   > where is the domus.exe // Le domus.exe on vérifie le fichier config.m
            Domus_dir = 

   > compare  DomusVersion and IdfVersion ... and by the way, test which path is the good one
           [pass,Domus_dir]=checkVersionEP(IDF_dir, Domus_dir);

usefull? i think you only have to check the idf and the domus path 
Mickael vous pouvez vérifier cette partie du programme,vérification est
valable, pour vérificar le chemin?

Domus_dir = Domus_dir{1}
           if ~exist(fullfile(Domus_dir, 'Domus.exe'),'file')
               error('Arrêt Domus.')
               
           if isequal(Domus_dir,0)
             error('Arrêt par l''utilisateur.')
           end
          else
            if ~exist('IDF_dir','var') 
               [IDF_dir,LocalPath] = uigetfile('*config*.m');
             if isequal(IDF_dir,0)
                error('Fichier de configuration non trouvé.')
        end

    ... and then, if no idf/domus -> error   else   select paths
%}

            error('Tem que definir o modelo !')
        
        otherwise
            error('Modele non reconnu')
    end
    
    % Test fichiers Météo
    if ~any(strcmp(params.EPW_type,{'none','module'}))
        % Recherche dans les repertoires : Path / Local / EnergyPlus
        if ~isfield(simulation.EPW,'path') || ~exist ( fullfile (simulation.EPW.path, [simulation.EPW.name{1} '.epw']) ,'file' )
        % Si il n'y pas de path personalisé ou si le path est invalide
        % Teste les autres répertoires
            if isfield(simulation.EPW,'path') && ~isempty(simulation.EPW.path)
                error(['Le fichier météo non présent ! Vérifiez la variable ''simulation.EPW.path''.\n'...
                    'Répertoire :\t%s\nFichier :\t%s\n'],...
                    fullfile ( simulation.EPW.path),...
                    [simulation.EPW.name{1} '.epw']);
            elseif exist ( fullfile (LocalPath, [simulation.EPW.name{1} '.epw']) ,'file' )
                simulation.EPW.path = fullfile (LocalPath);    
            elseif exist ( fullfile (pwd, [simulation.EPW.name{1} '.epw']) ,'file' )
                simulation.EPW.path = fullfile (pwd);
            elseif exist ( fullfile ( Ep_dir,'WeatherData', [simulation.EPW.name{1} '.epw']) ,'file' )
                simulation.EPW.path = fullfile ( Ep_dir,'WeatherData');
            else
                error(['Le fichier météo ''%s'' n''a pas été trouvé. Défenissez la variable ''simulation.EPW.path''.\n'...
                    'Ou les répertoires suivants :\n  %s\n  %s\n  %s'],...
                    [simulation.EPW.name{1} '.epw'],...
                    fullfile(LocalPath),...
                    fullfile(pwd),...
                    fullfile(Ep_dir,'WeatherData'));
            end
        end
        % Test des autres fichiers au même emplacement
        for k=2:length(simulation.EPW.name)
            if ~exist ( fullfile ( simulation.EPW.path, [simulation.EPW.name{k} '.epw']) ,'file' )
                
                error(['Le fichier météo suivant n''a pas été trouvé !\n',...
                    'Répertoire :\t%s\nFichier :\t%s\n'],...
                    fullfile ( simulation.EPW.path),...
                    [simulation.EPW.name{k} '.epw']);
            end
        end
        
        % Copie les fichiers dans le repertoire de simulation
        if params.EPW.copie && ~strcmp(simulation.EPW.path, params.rep_simul)
            fprintf('Copie locale du/des fichier(s) EPW.\n');
            for k=1:length(simulation.EPW.name)
                copyfile(fullfile(simulation.EPW.path, [simulation.EPW.name{k} '.epw']),params.rep_simul);
            end
            % Efface le path cas plus nécessaire (copie locale)
            simulation.EPW.path = [];  
        
        elseif strcmp(simulation.EPW.path, fullfile(Ep_dir,'WeatherData'))
            % Efface le path cas plus nécessaire (version du répertoire de travail energyplus)
            simulation.EPW.path = [];
        end
    end
end

clear Ep_dir


%% 1 Plan de simulation 

if (etape>1)
    fprintf('Utilisation du plan existant.\n');
else
    params.titre=local.noms.etude;
    fprintf('Génération du plan de simulation.\n');
    
    
    
    % Appel de la fonction d'échantillinnage
    commun_echantillonage;
    
    % Liste des simulations à réaliser
    % Rq: Ajout ultérieur des fichiers météo
    params.liste_fichier = cell(params.nb_tir,2);
    for k = 1:params.nb_tir
        params.liste_fichier(k,1) = {sprintf('%s%d',local.noms.data,k)};
    end

    etape=2;
    save(fullfile(params.rep_result,local.noms.save))
end

%% Récap

fprintf('Nombre de simulation : %d\n', params.nb_tir);

fprintf('Listing des variables :\n');
align = 'center';
if local.recap_plan
  
    sep = repmat('  |  ',3 ,1);
    for k=params.variables.vars_index
        if strcmp(params.variables.infos(k).loi, 'Discret')
            continue
        end
        fprintf('\n\n%d - %s :  %s\n',k,params.variables.infos(k).nom, params.variables.infos(k).loi)
        texte = [strjust(char({'','Donnée','Estimation'}'), align)];
        
        if strncmp(params.variables.infos(k).loi,'Discret',7)
            for l=1:length(params.variables.infos(k).limites)
                texte = [texte sep strjust(char({['[' num2str(l) ']'],['''' params.variables.infos(k).limites{l} ''''],num2str(sum(params.plan(:,k)==l))}), align)];
            end
        else
            if isempty(params.variables.infos(k).limites)
                texte = [texte sep strjust(char({'Limites','-Non Déf.-',num2str([min(params.plan(:,k)) max(params.plan(:,k))],'%-5.3g  %5.3g')}'), align)];
            else
                texte = [texte sep strjust(char({'Limites',num2str([params.variables.infos(k).limites; [min(params.plan(:,k)) max(params.plan(:,k))] ],'%-5.3g  %5.3g')}'), align)];
            end
            
            if strncmp(params.variables.infos(k).loi,'Gaussian',8)
                [moy,sig] = normfit(params.plan(:,k));
                sig = sig*1.96;
            else %if strncmp(params.variables.infos(k).loi,'Uniform',7)
                moy = mean(params.plan(:,k));
                sig = (max(params.plan(:,k))-min(params.plan(:,k)))/2;
            end
            if params.variables.infos(k).loi(end)=='R', sig=sig/abs(moy)*100; end
            texte = [texte sep strjust(char({'Variations',num2str([params.variables.infos(k).moments;[moy sig] ],'%-5.3g  %5.3g')}'), align)];
        end
        disp(texte)
        if isnan(moy), keyboard, end
    end
    disp(' ')
    % sep = repmat('  |  ',params.variables.vars_nb+1 ,1);
    % texte = sep;
    % texte = [texte strjust(char({'NOM',params.variables.infos(params.variables.vars_index).nom}'), align)];
    % texte = [texte sep];
    % texte = [texte strjust(char({'LOI',params.variables.infos(params.variables.vars_index).loi}'), align)];
    % texte = [texte sep];
    % texte = [texte strjust(char(num2str(vertcat(params.variables.infos(params.variables.vars_index).limites))), align)];
    % texte = [texte sep];
    % disp(texte)

    clear align sep texte moy sig
end
%% 2 Création des fichiers de simulation

if (etape>2)
    fprintf('Utilisation des fichiers de simulation.\n');
    if size(dir(params.rep_result),1)<=2;
        error('Accune simulation trouvée');
    end
else

    % == Gestion des fichiers EPW ==
       
    switch params.EPW_type
        case 'none'   %fichier unique
            params.liste_fichier(:,2) = {' '};
        case 'unique'   %fichier unique
            params.liste_fichier(:,2) = fullfile(simulation.EPW.path,simulation.EPW.name(1));
            simulation.EPW.plan = ones(params.nb_tir,1);
            
        case 'liste'    %fichier multiple -> intégration dans l'échantillonnage /incomplet
                        
            warning('DEBUG: la météo est la derniere variation, a recoder en mieux')
            % une variable météo à été ajouté, les fichier météo sont variés selon cette entré  
            simulation.EPW.plan = params.plan(:,params.variables.vars_nb);
            
   %         voir si ca suffi ou faire :
%             params.plan(:,end)=[]
%             params.variables.vars_index(end) = [];
%             params.variables.vars_nb = params.variables.vars_nb-1;
%             params.variables.actif(end) = [];
%             params.variables.actif_nb = params.variables.actif_nb-1;

            % noms des fichier à appeller pour chaque simulation
            for k = 1:params.nb_tir
                params.liste_fichier(k,2) = fullfile(simulation.EPW.path,simulation.EPW.name(simulation.EPW.plan(k)) );
            end
       
        case 'plan'     %plan existant
                
            if analyse.type_etude~=0 % Si une étude doit etre faite
                if analyse.type_etude~=5
                    error('L''analyse avec variables METEO doit etre de type Sobol par groupe.')
                end
                
                % Lecture des index
                if ~isvector(simulation.EPW.index)
                    s=load(fullfile(simulation.EPW.index));
                    fieldnames(s)
                    keyboard
                    simulation.EPW.index = cell2mat(struct2cell(s))';
                end
                
                if params.type_ech<1 % Pas de variation des entrées statiques
                    if ~isfield(simulation.EPW,'index')
                        error('Informations insuffisantes pour réaliser une étude.')
                    end
                    %ajout des index
                    params.index_rbd_sobol =  simulation.EPW.index;
                else
                    %ajout des index aux index deja existant
                    params.index_rbd_sobol =  horzcat(params.index_rbd_sobol,   simulation.EPW.index  );
                end
            end
            
            % simulation.EPW.plan = 1:length(simulation.EPW.name);
            % params.liste_fichier(:,2) = fullfile(simulation.EPW.path,simulation.EPW.name);
            
            
            % Si il y a un plan on mélange les simulations
            if ~isfield(simulation.EPW,'plan')
                simulation.EPW.plan = 1:length(simulation.EPW.name);
                params.plan = simulation.EPW.plan;
            end
            for k = 1:params.nb_tir
                params.liste_fichier(k,2) = {fullfile(simulation.EPW.path,simulation.EPW.name{simulation.EPW.plan(k)})};
            end
            
            
        case 'module'   %appel d'une fonction /incomplet
            error('module non codé !')    
            % Appel du module météo
            %//
            %// couplage incomplet !
            % simulation.EPW.path  = localisation des fichiers créé
            % simulation.EPW.name = {'fichier1', 'fichier2', 'fichier3'}
            % simulation.EPW.index = ;
            %//
        otherwise
            error('pas normal :(')
    end  

    % == Création des fichiers IDF ==
    if isfield(params,'plan')
        fprintf('Génération des fichiers idf.\n');

        if size(params.plan,1) == 1 || params.variables.vars_nb==0
            IDF_copie = fullfile(params.rep_simul, sprintf('%s.idf',params.liste_fichier{1,1}));
            modif_IDF( IDF_dir, IDF_copie, params.variables.infos(params.variables.actif),params.plan(1,:),true,[]);

            if params.nb_tir>1
                IDF_dir = IDF_copie;
                for i=2:params.nb_tir
                    modif_IDF(IDF_dir,fullfile(params.rep_simul, sprintf('%s.idf',params.liste_fichier{i,1})));
                    barre_avancement(i)
                end   
            end
        else
            for i=1:params.nb_tir
                IDF_copie = fullfile(params.rep_simul, sprintf('%s.idf',params.liste_fichier{i,1}));
                modif_IDF( IDF_dir, IDF_copie, params.variables.infos(params.variables.actif),params.plan(i,:),i==1,i);
                barre_avancement(i)
            end
        end
        clear IDF_base IDF_copie

    else
        error('Aucun plan de simulation trouvé');
    end
    
    etape=3;
    save(fullfile(params.rep_result,local.noms.save))
end

%% 3 Simulations


if (etape>3)
    fprintf('Utilisation des resultats de simulation.\n');
    if size(dir(params.rep_result),1)<=2;
        error('Auccun fichier de donné trouvé');
    end
    
else
    if ~isfield(simulation,'etats')
        simulation.etats = zeros(params.nb_tir,1);
    else
        fprintf('Recherche des simulations inachevées.\n');
        % Test de la validité des simulations incorrectes
        [simulation.etats, simulation.time] = test_sim(params.model,params.rep_simul,params.liste_fichier,simulation.etats);
    end
    if any(simulation.etats>0)
        switch questdlg('Relprise d''une anayse !',sprintf('Conflit : %s', local.noms.etude),'Tout simuler','Tout tester','Reprise','Reprise')
            case 'Tout simuler'
                % Recherche la présense de résultats avec le nom des simulations
                folders = dir(fullfile(params.rep_simul,sprintf('%1$s*',local.noms.data)));
                % autre solution voir: http://www.mathworks.com/matlabcentral/fileexchange/16216
                if any([folders.isdir])
                    % Filtre les répertoires
                    folders = folders([folders(:).isdir]);                
                    switch questdlg('Que faire des fichier présent ?','Des résultats de simulation sont présent.','Effacer','Sauvegarder','Sauvegarder')
                        case 'Effacer'
                            fprintf('Effacement des simulations existantes.\n');
                            try
                                cellfun(@(x) rmdir(fullfile(params.rep_simul,x),'s'),{folders.name})
                            catch err
                                warning(err.identifier, '-> Certaines simulations n''ont pu être éffacées.') %err.message
                                clear err
                            end

                        case 'Sauvegarder'
                            fprintf('Sauvegarde des simulations existantes.\n');

                            rep_dest = fullfile(params.rep_simul,'save'); n=1;
                            while isdir(rep_dest)
                                n=n+1;
                                rep_dest=fullfile(params.rep_simul,['save(' int2str(n) ')']);
                            end
                            mkdir(rep_dest)
                            cellfun(@(x) movefile(fullfile(params.rep_simul,x),rep_dest),{folders.name})
                        otherwise
                            error('Arrêt par l''utilisateur.')
                    end
                end
                simulation.etats = zeros(params.nb_tir,1);
                
            case 'Tout tester'                
                fprintf('Test des simulations.\n');
                % Test de la validité des simulations
                
                if any(simulation.etats>1) && strcmp('Oui',questdlg(sprintf('Voulez vous conserver les précédantes données extraites (%d/%d)?',sum(simulation.etats>1),length(simulation.etats)),sprintf('Conflit : %s', local.noms.etude),'Oui','Non','Oui'))
                    [simulation.etats, simulation.time]= test_sim(params.model,params.rep_simul,params.liste_fichier,simulation.etats.*(simulation.etats>=2));
                else
                    [simulation.etats, simulation.time] = test_sim(params.model,params.rep_simul,params.liste_fichier);
                end                
                % RAZ des simulations incorrectes
                simulation.etats(simulation.etats==-1)=0;

            case 'Reprise'
                % Suite...
            otherwise
                error('Arrêt par l''utilisateur.')
        end
    end    
          
        
        % Effacement des repertoires devant comptenir les nouvelles simulations
        % (pas très utile cas E+ écrasera les fichiers présent)
%         try
%             cellfun(@(x) rmdir(fullfile(params.rep_simul,x),'s'),cellstr(params.liste_fichier(   cellfun(@(x) isdir(fullfile(params.rep_simul,x)),cellstr(params.liste_fichier(simulation.etats==0)) )   )) )
%         end
    
    
    id_simul = find(simulation.etats<=0);
    nb_simul = length(id_simul);
    if nb_simul==0
        fprintf('-> Aucune simulation à réaliser.\n');
    else
        % Lance les simulations dans des fenetres dos
        fprintf('Simulation.\n-> %d fichier(s) en %d lot(s).\n',nb_simul, min(nb_simul,local.nb_proc));
        switch upper(params.model)
            case {'E+','EP','ENERGYPLUS'}
                EplusMulti(params.rep_simul, params.liste_fichier(id_simul,:) ,local.nb_proc,local.auto_start);
            case {'DOMUS'}
                % Les modifications appostées par Lais Lagos 
                
            % > you have to add the 'Domus_dir' in the function
%                DomusMulti(params.rep_simul, local.IDF_dir ,local.nb_proc,local.auto_start);
                error('Tem que definir o modelo !')
        
            otherwise
                error('Modele non reconnu')
        end
        etape=4;
        save(fullfile(params.rep_result,local.noms.save))

        if isfield(local, 'auto_start') && local.auto_start==false
            dos(sprintf('Explorer /e,/select,%s &',fullfile(params.rep_simul,'SimMulti.bat')));
            error('Fin de création des fichiers ''*.bat''. Veuilliez lancer les simulations.');
        end
        

        % == Test (de fin) des simulations ==
        t = timer('StartDelay', 0, 'Period', local.test_delay, 'ExecutionMode', 'fixedDelay', 'TasksToExecute', 10^10);
        t.TimerFcn = { @test_fin, local.test_delay };
        t.ErrorFcn = { @(~,~) disp('Oups') };
        fprintf('   Attente des résultats... (Ctr+c pour forcer le démarrage)\n');
        % barre_avancement('RAZ')
        affichage.nb_tir = nb_simul;
        
        start(t)

%         while strcmp(t.Running,'on')
%             pause(t.Period)
%         end

        wait(t)
        if strcmp(t.Running,'on')
            stop(t)
        end
        clear t test_fin
        
    end    
    clear nb_simul id_simul
    
    if any(simulation.etats==-1)
        id_err = find(simulation.etats==-1)
        fprintf('ATTENTION !!! Les %d simulations suivantes se sont terminées avec des erreurs:\n', length(id_err));
        disp(id_err)
        clear id_err
        if simulation.etats(1)==-1
            error('Arrêt: Echec de la 1ere simulation.')
        end       
    end    
    
    etape=4;
    save(fullfile(params.rep_result,local.noms.save))

end
clear type_simul

%% 4 Extraction des sorties

if (etape>4)
    fprintf('Utilisation des données formatées.\n');
else
    
    [simulation.etats, simulation.time] = test_sim(params.model,params.rep_simul,params.liste_fichier,(simulation.etats>1)*2);
    
    % test des simulations pour l'extraction
    [simulation.etats, simulation.time] = test_sim(params.model,params.rep_simul,params.liste_fichier,(simulation.etats>1)*2);
    
    if any(simulation.etats>1)
        if strcmp('Oui',questdlg(sprintf('%d simulations sur %d sont déjà extraites. Réextraire tout ?',sum(simulation.etats>1),length(simulation.etats)),sprintf('Conflit : %s', local.noms.etude),'Oui','Non','Non'))
            % Réextraction : Test de la validité des simulations
            ancien_etats = simulation.etats;
            [simulation.etats, simulation.time] = test_sim(params.model,params.rep_simul,params.liste_fichier);
            if any((simulation.etats<1) & (ancien_etats>1))
                % Stop, certaine simulations sont manquante alors que leurs
                % données ont déjà été extraites
                error('%d simulation(s) sur %d sont introuvables alors que leurs données ont déjà été extraites.\nVeuillez relancer l''etape ''simulations'' ou ne pas réextraire les fichiers !',sum((simulation.etats<1) & (ancien_etats>1)),length(simulation.etats))
            end
            clear ancien_etats
        end
    end    
    affichage.nb_tir = sum(simulation.etats<=1);
    
    if any(simulation.etats<1)
        id_incorr = find(simulation.etats<1);
        nb_incorr = length(id_incorr);
        fprintf('   %d simulations ne sont pas correctes.\n', nb_incorr)
        
        col=10;
        lign = 5;
        for k=1:ceil(min(nb_incorr,lign*col)/col)
            fprintf([repmat('\t% d',1,col) '\n'],id_incorr((col*(k-1)+1):min(col*k,end)))
        end
        if length(id_incorr)>lign*col
            fprintf('\t ...')
        end
        clear col lign
        disp(' ')
        
        
        if ~strcmp('Oui',questdlg(sprintf('%d simulation(s) sur %d sont incorrectes. Continuer ?',nb_incorr,length(simulation.etats)),sprintf('Conflit : %s', local.noms.etude),'Oui','Non','Non'))
            error('Arrêt par l''utilisateur. Veuillez relancer l''étape ''simulations'' !')
        end
        
        affichage.nb_tir = affichage.nb_tir-nb_incorr;
        clear id_incorr nb_incorr
    end

    
    
    switch upper(params.model)
        
        case {'E+','EP','ENERGYPLUS'}
        %% ENERGYPLUS
            % == Informations de base ==
            % une simulation a t elle dégà été extraite ?
            if ~any(simulation.etats>1)
                fprintf('Extraction des informations générales\n');

                % selection de la 1ere simulation valide
                k = find(simulation.etats==1,1, 'first');

                % Surfaces et mise à jour des sorties
                [geometrie, sorties_ext] = find_surface(fullfile(params.rep_simul,sprintf('%1$s\\%1$s.eio',params.liste_fichier{k})), sorties);

                % Vecteurs temporels
                dates = find_temps(fullfile(params.rep_simul,sprintf('%1$s\\%1$s.csv',params.liste_fichier{k})));

                % Enregistrement des données
                save(fullfile(params.rep_result,'commun.mat'),'geometrie','sorties_ext','dates' )

                clear k
            end

            etape=5;
            save(fullfile(params.rep_result,local.noms.save),'etape', '-append')

            % == Informations spécifiques ==
            fprintf('Extraction des données de simulation\n');

        clear extract_csv % efface la variable persistante pour afficher les warning a chaque run

            for id=find(simulation.etats==1)'

                % Indice de la simulation étudiée
                IDF_courant = params.liste_fichier{id};

                file =fullfile(params.rep_simul,sprintf('%1$s\\%1$s.csv',IDF_courant));
        try
                donnees_brut=extract_csv(file,dates,sorties_ext,resultat.extract_lum);
        catch exception
            etape=4;
            save(fullfile(params.rep_result,local.noms.save),'etape', '-append')
            
            fclose('all');
            disp(file)
            rethrow(exception)
        end
                resSimul=pre_traitement(params,dates,geometrie,donnees_brut,resultat.extract_lum);

                % Enregistrement des données
                save(fullfile(params.rep_result,[IDF_courant '.mat']),'resSimul')

                simulation.etats(id)=2;
                save(fullfile(params.rep_result,local.noms.save),'simulation', '-append')

                barre_avancement('PLUS')                         
            end
            clear donnees_brut id

            %SUPPRESSION DES FICHIERS DE SIMULATION ??
            

        case {'DOMUS'}
            %% DOMUS
            
            error('Tem que definir o modelo !')
  %{          
            
            % == Informations de base ==
            % une simulation a t elle dégà été extraite ?
            if ~any(simulation.etats>1)
                fprintf('Extraction des informations générales\n');

                % selection de la 1ere simulation valide
                k = find(simulation.etats==1,1, 'first');

                % Vecteurs temporels
> you have to make your own   search 'Supported File Formats' in the documetation
                dates = find_temps(fullfile(params.rep_simul,sprintf('%1$s\\%1$s.csv',params.liste_fichier{k})));

                % Enregistrement des données
                save(fullfile(params.rep_result,'commun.mat'),'dates' )

                clear k
            end
            
           > you have at least 1 good simulation, you can active the next step (make this just one time) 
            etape=5;
            save(fullfile(params.rep_result,local.noms.save),'etape', '-append')

            
            
            % == Informations spécifiques ==
            
            fprintf('Extraction des données de simulation\n');
            
    > for each simulation id  with  etats==1       
            for id=find(simulation.etats==1)'

                % Indice de la simulation étudiée
                IDF_courant = params.liste_fichier{id};
            
> path of the results files
                file =fullfile(params.rep_simul,sprintf('%1$s\\%1$s.csv',IDF_courant));

> what must be done if a 'sim2' is here ????
            
            
           >> for each datafile (you have to define these files !!!)
                
               > and read them
                add datas into 'donnees'
               'donnees' is a stucture !!!  search 'structures' in the documetation
            
           >>  end datafile loop
            
           > save thhe datas
            save(fullfile(params.rep_result,[IDF_courant '.mat']),'donnees')
            
           > no error -> update the state of the current simuation 
            simulation.etats(id)=2;   % 0=no extract /  1= simulation OK  / 2= simulation extracted
           
           > save the state of the current id
            save(fullfile(params.rep_result,local.noms.save),'simulation', '-append')
            

            
    end simulation id loop
  %}          
        otherwise
            error('Modele non reconnu')
    end
    
    
    
    
end

%% 5 Mise en forme des sorties

if any(simulation.etats<2)
    %des simulations sont invalides
    nb_incorr = sum(simulation.etats<2);
    if ~strcmp('Oui',questdlg(sprintf('%d simulation(s) n''ont pas été extraite(s). Poursuivre ?',nb_incorr),sprintf('Conflit : %s', local.noms.etude),'Oui','Non','Non'))
        error('Arrêt par l''utilisateur.')
    end
    warning('%d simulation(s) n''ont pas été extraite(s) !',nb_incorr)
    
    affichage.nb_tir = params.nb_tir - nb_incorr;
    clear nb_incorr
end

if (etape>5)
    fprintf('Utilisation de la matrice de sortie.\n');
else
    fprintf('Lecture des plages d''étude\n');
    for k=1:length(resultat.plage)
        % Plage d'étude
        date = [ datenum(resultat.plage(k).debut, 'dd/mm');  
                 datenum(resultat.plage(k).fin, 'dd/mm') ] + datenummx(0,0,0,dates.vec(1,4),dates.vec(1,5),dates.vec(1,6));

        id_debut = find( dates.j==date(1) );
        id_fin = find( dates.j==date(2) );
        
        if isempty(id_debut) || isempty(id_fin) || length(id_debut)~=length(id_fin)
            error('Une des limite de la plage ''%s'' n''a pas été trouvée.\n  Limites: du %s au %s\n  Plage:   du %s au %s', resultat.plage(k).nom, datestr(dates.j(1),1),  datestr(dates.j(end),1),  datestr(date(1),1),  datestr(date(2),1) );
        end
        rep = length(id_debut);
        
        date_format=cellstr(datestr([date],'dd/mm'));
        fprintf('-> Période de la plage ''%s'': du %s au %s.\n', resultat.plage(k).nom, date_format{1:2});

        resultat.plage(k).index=false(dates.nb_j,1);
        
        if rep>1                   
            [rep,ok] = listdlg('Name', sprintf('Conflit : %s', local.noms.etude),...
                'PromptString','Année(s) à étudier :',...
                'SelectionMode','multiple',...
                'ListString', num2str([1:rep]','%d') ,...
                'InitialValue',[rep],...  
                'ListSize', [150 30+15*(rep-1)]);
            if ok==0
                error('Arrêt par l''utilisateur.')
            end
        end   
        
        for l=rep
            if id_debut(l)>id_fin(l)  %si la période commence en fin d'année
                resultat.plage(k).index(id_debut(l):(l*dates.nb_j/rep) )=true;
                resultat.plage(k).index( ((l-1)*dates.nb_j/rep+1):id_fin(l))=true;
            else
                resultat.plage(k).index(id_debut(l):id_fin(l))=true;
            end
        end

        resultat.plage(k).index_h=reshape(repmat(resultat.plage(k).index',24,1),[],1);
    end
    clear id_debut id_fin date rep date_format
    
    % Check range_temporal validity
    if ~isfield(resultat,'range_temporal')
        resultat.range_temporal = 0;
    elseif resultat.range_temporal > length(resultat.plage)
        error('The ID (%d) is out of range. Check the value of resultat.range_temporal',resultat.range_temporal)
    end
    
    % SAVING: Initialisation
    if isfield(resultat,'save') && resultat.save
        
        if resultat.range_temporal==0
            res_type = 'Datas';
        else
            res_type = 'Datas_temporal';
        end

        if isempty(resultat.save_path)
            resultat.save_path = params.rep_result;
        end
        [~,~,ext] = fileparts(resultat.save_path);
        if isempty(ext)
            resultat.save_path = fullfile(resultat.save_path,local.noms.indicateurs);
        elseif ~strcmp(ext,'.mat')
            error('Wrong extension, check ''resultat.save_path'':\n%s',resultat.save_path)
        end
        clear ext
        
        studyVarName = genvarname(regexprep(local.noms.etude,'[^A-Za-z_0-9\s]','_'));
        studyPlageName = genvarname(regexprep({resultat.plage.nom},'[^A-Za-z_0-9\s]','_'));
        
        if exist(resultat.save_path,'file')
            load(resultat.save_path,'Result_indicateur')
            if isfield(Result_indicateur,studyVarName) && isfield(Result_indicateur.(studyVarName),res_type)
                if ~strcmp('Yes',questdlg(sprintf('This Study have been saved before.\nDo you want erase the previous values?'),local.noms.etude,'Yes','No','No'))
                    error('Arrêt par l''utilisateur.')
                end
            end
            Result_indicateur.(studyVarName).(res_type) = [];
        end
        Result_indicateur.(studyVarName).(res_type) = struct('Plage',{resultat.plage.nom});
        
    end
    
    fprintf('Mise en forme des résultats\n');
    
    % Clear previous extacted information
    resultat.sorties=[];    
    liste_choix=[];
    if isfield(legende,'sorties')
        legende = rmfield(legende,'sorties');
    end
   
    for id=find(simulation.etats==2)'
        
        IDF_courant = params.liste_fichier{id};
        load(fullfile(params.rep_result,[IDF_courant '.mat']))
        
        indicateurs=etude_indicateurs(resSimul,resultat.plage, resultat.range_temporal);
     
        if isempty(liste_choix)
            % listing des noms présents dans la legende
            if resultat.range_temporal==0
                % listing reduit par type d'indicateur
                liste=listnoms(legende.indicateurs(1),'','indicateurs(1)');
                liste_noms = listnoms(legende.indicateurs(1),'','indicateurs');
            else
                % For temporal analysis, we take all of the indicators of
                % all the ranges and clean the list.
                [liste,liste_idplage]=listnoms(legende.indicateurs,'','indicateurs');
                valid = ~eval(['[' strjoin( cellstrjoin({'test_unused(' ');'},liste)') ']'] );
                liste = liste(valid);
                liste_idplage = liste_idplage(valid);
                liste_noms=eval( strcat( '[', strjoin(strcat( 'legende.', liste)',',\n'), ']')   );
            end
            
            % selection des sorties désirées
%selection = persobox( str2mat(liste_noms))
            maxi=0;  for m=liste_noms', maxi = max(maxi,length(m{:}));  end
            while true                
            
                [selection,ok] = listdlg('Name', 'Sorties à étudier',...
                                        'PromptString','Sélection des sorties :',...
                                        'SelectionMode','multiple',...
                                        'ListString',liste_noms,...
                                        'ListSize', [10+6*maxi 15*(length(liste_noms)+1)]);
                if ok==0
                    error('Arrêt par l''utilisateur.')
                end
                
                if resultat.range_temporal==0
                    % listing integrant toutes les plages d'étude
                    liste_choix=cell(0,1);
                    for k=1:length(legende.indicateurs)
                        liste_choix = vertcat(liste_choix, strrep(liste(selection), '(1)', sprintf('(%d)',k)) );
                    end
                    break
                    
                elseif length(selection)==1
                % For temporal analysis, we allow only one output.
                    selected_range = liste_idplage(selection);
                    liste_choix = liste(selection);
                    break
                else
                    uiwait(warndlg('For temporal analysis, we allow only one output.','!! Warning !!'))
                end
            end
            
            % Liste de toutes des legendes de sortie les sorties
            legende.sorties_all=eval( strcat( '[', strjoin(strcat( 'legende.', liste_choix)',',\n'), ']')   );
            
            clear maxi m liste liste_noms valid ok selection
        end
        
        % Selection des sorties
        resultat.sorties(id,:)=eval( strcat( '[', strjoin(liste_choix',';\n'), ']')   );
        
        % SAVING: add simulation values
        if isfield(resultat,'save') && resultat.save
            if resultat.range_temporal>0
                % only one range is studied
                plageSet=resultat.range_temporal;
            else
                plageSet=1:length(resultat.plage);
            end
            for k=plageSet
                for idv=fieldnames(indicateurs(k))'
                    if isfield(Result_indicateur.(studyVarName).(res_type),idv)
                        Result_indicateur.(studyVarName).(res_type)(k).(idv{:}) = cat(1,Result_indicateur.(studyVarName).(res_type)(k).(idv{:}), getfield(indicateurs(k), idv{:})' );
                    else
                        Result_indicateur.(studyVarName).(res_type)(k).(idv{:}) = getfield(indicateurs(k), idv{:})';
                    end
                end
            end
        end

        barre_avancement('PLUS')
    end
    
    % SAVING: save file
    if isfield(resultat,'save') && resultat.save
        Result_indicateur.(studyVarName).Legende = legende.indicateurs;
        Result_indicateur.(studyVarName).plan = params.plan;
        save(resultat.save_path,'Result_indicateur')
        clear res_type studyVarName studyPlageName Result_indicateur idv
    end
    
    if resultat.range_temporal==-1
        resultat.range_temporal = selected_range;
    end
    clear plageSet liste_choix selected_range


    etape=6;    
    save(fullfile(params.rep_result,local.noms.save))

end


%% Selection des sorties parmi les données valides
if ~(etape>6)

    if ~(resultat.range_temporal==0)
        resultat.sorties_valide=true(1,size(resultat.sorties,2));
        resultat.sorties_valide_index = 1:size(resultat.sorties,2);
        analyse.legende_sorties_valide = legende.sorties_all;
    else
        % Recherche des sorties ayant une dispertion non négligeable
        resultat.sorties_valide = var(resultat.sorties)>=0.0001;
        resultat.sorties_valide_index = find(resultat.sorties_valide);

        maxi=0;  for m=legende.sorties_all(resultat.sorties_valide)', maxi = max(maxi,length(m{:}));  end
        [selection,ok] = listdlg('Name', 'Sorties à étudier',...
                                'PromptString','Sélection des sorties :',...
                                'SelectionMode','multiple',...       'InitialValue',[1 4 11 14],...  
                                'ListString',legende.sorties_all(resultat.sorties_valide),...
                                'ListSize', [10+6*maxi 15*(sum(resultat.sorties_valide)+1)]);

        if ok==0
            error('Arrêt par l''utilisateur.')
        end

        resultat.sorties_valide_index = resultat.sorties_valide_index(selection);
        resultat.sorties_valide(:)=false;
        resultat.sorties_valide(resultat.sorties_valide_index)=true;

        analyse.legende_sorties_valide = legende.sorties_all(resultat.sorties_valide);

        clear maxi m ok selection
    end
    
    analyse.legende_sorties = legende.sorties_all;
    analyse.legende_entrees = legende.vars(params.variables.vars_index,:);
end


    
%% Images

if local.images.export && resultat.range_temporal==0
    fprintf('Enregistrement des images - entrées / sorties.\n');
    
    % Choix des points
    points = find(simulation.etats==2);
    if ~isfield(local.images, 'nbs_point') || local.images.nbs_point == 0
        local.images.nbs_point = params.nb_tir;
    end    
    nb_point = min(length(points),local.images.nbs_point);
    if local.images.random
        points = points(randperm(length(points)));
    end 
    points = points(1:nb_point);
    
    
    % Création du répertoire de destination
    rep_image = fullfile(params.rep_result,local.noms.image); n=1;
    while isdir(rep_image)
        n=n+1;
        rep_image=fullfile(params.rep_result,[local.noms.image '(' int2str(n) ')']);
    end
    mkdir(rep_image); 
   
    % Def. de la barre d'avancement
    affichage.nb_tir = sum(resultat.sorties_valide)*params.variables.vars_nb;
    barre_avancement(0)
    
    % Affichage (ou pas) des figures lors de leur création
    hFig=figure('Visible',local.images.visible);
    
    % Recherche la première entrée discrète
    var_discrete = find(strcmpi({params.variables.infos(params.variables.vars_index).loi},'Discret'),1);
    if ~isempty(var_discrete)
        % Choix des couleurs (ou noir et blanc) et des marqueurs en
        % fonction du nombre de nivaux
        var_nbs_niv=length(params.variables.infos(params.variables.vars_index(var_discrete)).limites);
        if local.images.colors
            col=hsv(var_nbs_niv);
            form = {'.','.','.','.'};
        else
            col=zeros(var_nbs_niv);
            form = {'^','s','o','.'};
        end
    end
    
    % Création des figures
    % Boucle sur les sorties
    for j=1:size(resultat.sorties,2)
        % Si sortie non pertinante -> sortie suivante
        if ~resultat.sorties_valide(j), continue, end;
        
        % Boucle sur les variables
        for i=1:params.variables.vars_nb
            set(groot,'CurrentFigure',hFig);
%            fprintf('paramètre: %d   //  sortie: %d\n%s\n',i,j,sprintf('%s - %s',legende.sorties_all{j},legende.vars{i,1}));
  
            % S'il n'y a pas d'entrée discrete
            if isempty(var_discrete)
                % plot de toutes les données
                h=plot([params.plan(points,i)],resultat.sorties(points,j),'.');
                set (h,'color','k', 'LineStyle','none', 'MarkerSize',local.images.markersize)
                        
            else
            % S'l y a au moins une entrée discrete
            
                % Si la variable actuelle est discrete la sortie n'est pas affichée selon les X croissant
                if strcmpi(params.variables.infos(params.variables.vars_index(i)).loi,'Discret')
                    % Boucle sur chaque niveau (de la variable discrète)     
                    loc_nbs_niv=length(params.variables.infos(params.variables.vars_index(i)).limites);
                    filtre = NaN(round(nb_point/loc_nbs_niv),loc_nbs_niv);
                    m=nb_point;
                    for k=1:loc_nbs_niv
                        % Selectionne les données correspondantes au niveau                        
                        A = points([params.plan(points,var_discrete)]==k);
                        m=min(m,size(A,1));
                        filtre(1:m,k) = A(1:m);
                    end
                    % ne garde que le nombre de donné corespondante au niveu le moins nombreux
                    filtre = filtre(1:m,:);
                    cla                    
                    h=aboxplot(reshape(resultat.sorties(filtre,j),[],loc_nbs_niv),'labels',params.variables.infos(params.variables.vars_index(i)).limites);
                        
                    set(get(gca,'Xlabel'),'String',legende.vars{i,1}, 'FontSize', local.images.fontsize)
                    legend('off')

                else
                    % Boucle sur chaque niveau (de la variable discrète)
                    for k=1:var_nbs_niv
                        % Selectionne les données correspondantes au niveau
                        filtre = points([params.plan(points,var_discrete)]==k);

                        h=plot([params.plan(filtre,i)],resultat.sorties(filtre,j));                  

                        % Mise en forme
                        set(gca,'XLim',sort(params.variables.infos(params.variables.vars_index(i)).limites));  
                        set (h,'color','k', 'LineStyle','none', 'Marker',form{k},'MarkerSize',local.images.markersize, 'Color',col(k,:))
                        hold on %la fct se répéte mais la fig préc est écrasée.
                    end
                    %legend(regexprep(params.variables.infos(params.variables.vars_index(multi)).moments(2:end), '_', ' '),'Location','Best','Orientation','vertical')
                    legend(gca,params.variables.infos(params.variables.vars_index(var_discrete)).limites,'Location','Best','Orientation','vertical')
                    hold off
                end

            end
            
            if ~strcmpi({params.variables.infos(params.variables.vars_index(i)).loi},'Discret')
                    set(gca,'XLim',[min(params.plan(:,i)) max(params.plan(:,i))]);
%                 if isempty(params.variables.infos(params.variables.vars_index(i)).limites)
%                 else
%                     set(gca,'XLim',sort(params.variables.infos(params.variables.vars_index(i)).limites));
%                 end
                set(get(gca,'Xlabel'),'String',legende.vars{i,1}, 'FontSize', local.images.fontsize)
            end
            set(get(gca,'Ylabel'),'String',legende.sorties_all{j}, 'FontSize', local.images.fontsize)
            set(gca, 'YLim',scaling(resultat.sorties(points,j)), 'FontSize', local.images.fontsize, 'YGrid', 'on');

            title(sprintf('%s - %s',legende.sorties_all{j},legende.vars{i,1}))
            
            saveas(hFig, fullfile(rep_image,sprintf('%d-%d.jpg',j,i)) )
            save_fig(hFig, fullfile(rep_image,sprintf('%d-%d.fig',j,i)) )
            
            barre_avancement('PLUS');
        end  
    end
    close(hFig)
    clear i j n h hFig dossier nbs_niv
    
end


%% Images 2 (entre les sorties)

if local.images.export2 && resultat.range_temporal==0
    fprintf('Enregistrement des images - sorties / sorties.\n');
    if sum(resultat.sorties_valide)<2
        warning('You have to select more than one output to have some results.');
    else
        % Choix des points
        points = find(simulation.etats==2);
        if ~isfield(local.images, 'nbs_point') || local.images.nbs_point == 0
            local.images.nbs_point = params.nb_tir;
        end    
        nb_point = min(length(points),local.images.nbs_point);
        if local.images.random
            points = points(randperm(length(points)));
        end 
        points = points(1:nb_point);


        % Création du répertoire de destination
        rep_image = fullfile(params.rep_result,[local.noms.image '_sorties']); n=1;
        while isdir(rep_image)
            n=n+1;
            rep_image=fullfile(params.rep_result,[local.noms.image '_sorties' '(' int2str(n) ')']);
        end
        mkdir(rep_image); 

        % Def. de la barre d'avancement
        affichage.nb_tir = factorial(sum(resultat.sorties_valide))/(2*factorial(sum(resultat.sorties_valide)-2));
        barre_avancement(0)

        % Affichage (ou pas) des figures lors de leur création
        hFig=figure('Visible',local.images.visible);    

        % Recherche la première entrée discrète
        var_discrete = find(strcmpi({params.variables.infos(params.variables.vars_index).loi},'Discret'),1);
        if ~isempty(var_discrete)
            % Choix des couleurs (ou noir et blanc) et des marqueurs en
            % fonction du nombre de nivaux
            var_nbs_niv=length(params.variables.infos(params.variables.vars_index(var_discrete)).limites);
            if local.images.colors
                col=hsv(var_nbs_niv);
                form = {'.','.','.','.'};
            else
                col=zeros(var_nbs_niv);
                form = {'^','s','o','.'};
            end
        end

        % Création des figures
        % Boucle sur les sorties axe x
        for i=1:size(resultat.sorties,2)  %  [11,11+size(resultat.sorties,2)/2,13,26]      
            % Si sortie non pertinante -> sortie suivante
            if ~resultat.sorties_valide(i), continue, end;

            % Boucle sur les sorties axe y
            for j=i+1:size(resultat.sorties,2)
                % Si sortie non pertinante -> sortie suivante
                if i==j || ~resultat.sorties_valide(j), continue, end;            

    %            fprintf('sortie1: %d   //  sortie2: %d\n%s\n',i,j,sprintf('%s - %s',legende.sorties_all{j},legende.sorties_all{i}));

                % S'il n'y a pas d'entrée discrete
                if isempty(var_discrete)
                    % plot de toutes les données
                    h=plot(resultat.sorties(points,i),resultat.sorties(points,j),'.');
                    set (h,'color','k', 'LineStyle','none', 'MarkerSize',local.images.markersize)

                else
                % S'il y a au moins une entrée discrete            

                    % Boucle sur chaque niveau (de la variable discrète)
                    for k=1:var_nbs_niv
                        % Selectionne les données correspondantes au niveau
                        filtre = points([params.plan(points,var_discrete)]==k);

                        h=plot(resultat.sorties(filtre,i),resultat.sorties(filtre,j));                  

                        % Mise en forme
                        set (h,'color','k', 'LineStyle','none', 'Marker',form{k},'MarkerSize',local.images.markersize, 'Color',col(k,:))
                        hold on %la fct se répéte mais la fig préc est écrasée.
                    end
                    %legend(regexprep(params.variables.infos(params.variables.vars_index(multi)).moments(2:end), '_', ' '),'Location','Best','Orientation','vertical')
                    legend(gca,params.variables.infos(params.variables.vars_index(var_discrete)).limites,'Location','Best','Orientation','vertical')
                    hold off

                end


                set(get(gca,'Xlabel'),'String',legende.sorties_all{i}, 'FontSize', local.images.fontsize)
                set(get(gca,'Ylabel'),'String',legende.sorties_all{j}, 'FontSize', local.images.fontsize)
                set(gca,'XLim',scaling(resultat.sorties(points,i)), 'FontSize', local.images.fontsize, 'XGrid', 'on');
                set(gca,'YLim',scaling(resultat.sorties(points,j)), 'FontSize', local.images.fontsize, 'YGrid', 'on');

                title(sprintf('%s - %s',legende.sorties_all{i},legende.sorties_all{j}))
                saveas(h, fullfile(rep_image,sprintf('%d-%d.jpg',i,j)) )

                barre_avancement('PLUS');
            end  
        end
        close(hFig)
        clear i j n h hFig dossier nbs_niv
        barre_avancement('FIN')
    end
end


%% 6 Appel de la fonction d'analyse

% [simulation.etats, simulation.time] = test_sim(params.model,params.rep_simul,params.liste_fichier);
% resultat.sorties= simulation.time;
% resultat.sorties_valide = 1;


if (etape>6)
    fprintf('Utilisation des résultats d''analyse.\n');
else    
    if any(simulation.etats<2)
        warning('%d simulation(s) n''ont pas été extraite(s) !',sum(simulation.etats<2))
    end
    
    fprintf('Analyse des résultats\n');

    commun_analyse;
    
    etape=7;
    save(fullfile(params.rep_result,local.noms.save))

end

%% 7 Graphiques

bilan.name = params.titre;
%bilan.inputs = rmfield(params.variables.infos(params.variables.vars_index),'actif'); 
bilan.inputs = params.variables.infos(params.variables.actif); 
bilan.plan = params.plan;
bilan.legende.inputs = legende.vars;
bilan.legende.outputs = legende.sorties_all;
bilan.datas = resultat.sorties;
bilan.SIoutputs = resultat.sorties_valide;
if isfield(analyse,'SI_rbdfast')
    SI= analyse.SI_rbdfast;
elseif isfield(analyse,'SI_sobol')
    SI= analyse.SI_sobol;
elseif isfield(analyse,'PC_Infos')
    error('To be defined')
else
    SI=[];
end
bilan.SI = SI;      % SI is used after

assignin('base','bilan',bilan)

disp('END')
fprintf('\n\n=== %s ===\n',local.noms.etude);
disp('List of the inputs:')
disp(analyse.legende_entrees(:,1))

disp('List of the outputs:')
disp(analyse.legende_sorties_valide)


disp('Means Values')
disp(analyse.M)
disp('Variance Values')
disp(analyse.V)
if isfield(analyse,'SI_rbdfast')
    disp('Sensitivity Index Values (RBD-FAST Method)')
    disp(analyse.SI_rbdfast)
end
if isfield(analyse,'SI_sobol')
    disp('Sensitivity Index Values (Sobol Method)')
    disp(analyse.SI_sobol)
end

if ~(resultat.range_temporal==0)
    % Création du répertoire de destination
    rep_image = fullfile(params.rep_result,[local.noms.image '_temporal']); n=1;
    while isdir(rep_image)
        n=n+1;
        rep_image=fullfile(params.rep_result,[local.noms.image '_temporal' '(' int2str(n) ')']);
    end
    mkdir(rep_image);
    
    % Selection of the range
    k=resultat.range_temporal;
    
    
    % ====== Sensitity analysis results ======
    
    % Select time step
    if      size(SI,2) == 24
        donne_dates = dates.h(1:24);
    elseif      size(SI,2) == sum(resultat.plage(k).index_h)
        donne_dates=dates.h(resultat.plage(k).index_h);
    elseif  size(SI,2) == sum(resultat.plage(k).index)
        donne_dates=dates.j(resultat.plage(k).index);
    elseif  size(SI,2) == length(dates.h)
        donne_dates=dates.h;
    elseif  size(SI,2) == length(dates.j)
        donne_dates=dates.j;
    end
    
    SI(:,isnan(SI(1,:)))=0;
    SI(SI(:)<0)=0;                  % can I ?

    % Select only the relevant outputs
    if size(SI,1)>5
        filtre = find(max(SI,[],2)>0.1);
    else
        filtre = 1:size(SI,1);
    end

    % Sort according the mean effect
    [~,I] = sort(mean(SI(filtre,:),2),'descend');
    filtre = filtre(I);

    h=figure;
    if false    %Plot lines
        hold on
        plot(donne_dates, sum(SI(filtre,:),1), 'LineWidth', 2)
        plot(donne_dates,SI(filtre,:)')
        hold off
        legend({'Total',analyse.legende_entrees{filtre,1}})
    else        %Plot stacked area
        area(donne_dates,SI(filtre,:)')
        legend(analyse.legende_entrees{filtre,1})
    end
    
    if max(sum(SI(filtre,:),1))>1.15
        set(gca,'Ylim',[0, max(sum(SI(filtre,:),1))])
    else
        set(gca,'Ylim',[0, 1.15])
    end
    
    title(analyse.legende_sorties)
    
    if donne_dates(end)-donne_dates(1)<=2 %less than 2 day of datas
        set(gca,'XTick',1/24+[donne_dates(1):2/24:donne_dates(end)])
        datetick('x','HH','keepticks')           
        xlabel('hour')
    else
        datetick('x','dd/mm','keepticks')
    end    
    set(gca,'Xlim',[donne_dates(1), donne_dates(end)])
    set(gca,'XGrid','on')
    
    saveas(h, fullfile(rep_image,sprintf('%s-plage%d(INDICES).jpg',strtok(analyse.legende_sorties{:}),k)) )
    saveas(h, fullfile(rep_image,sprintf('%s-plage%d(INDICES).fig',strtok(analyse.legende_sorties{:}),k)) )

    
    % ====== Uncertainty analysis results ======    

    % Include a reference simulation ???
%    REFSIMUL = [];

    A=quantile(resultat.sorties,[.025 .25 .50 .75 .975]);
    disp('Temporal uncertainty analysis results')
    disp('Interquartile moyen')
    disp(nanmean(A(4,:)-A(2,:))  )
    disp('Taux interquartile moyen')
    disp(nanmean((A(4,:)-A(2,:))./(A(4,:)+A(2,:))) )
    
    
    h=figure;
    hold on
    plot(donne_dates, max(resultat.sorties,[],1),  'LineStyle',':')
    plot(donne_dates, A(1,:),  'LineStyle','-.')
    plot(donne_dates, A(2,:),  'LineStyle','--')
    plot(donne_dates, A(3,:),  'LineStyle','-', 'LineWidth', 2)    
%   plot(donne_dates, REFSIMUL, 'color','red', 'LineStyle','-', 'LineWidth', 2)
    plot(donne_dates, A(4,:),  'LineStyle','--')
    plot(donne_dates, A(5,:),  'LineStyle','-.')
    plot(donne_dates, min(resultat.sorties,[],1),  'LineStyle',':')
    hold off   
    
    if donne_dates(end)-donne_dates(1)<=2 %less than 2 day of datas
        set(gca,'XTick',1/24+[donne_dates(1):2/24:donne_dates(end)])
        datetick('x','HH','keepticks')           
        xlabel('hour')
    else
        datetick('x','dd/mm','keepticks')
    end    
    set(gca,'Xlim',[donne_dates(1), donne_dates(end)])
    
    set(gca,'XGrid','on')
    legend({'100%','95%','50%','Mediane'})  %  , 'Reference'
    title(analyse.legende_sorties)
    saveas(h, fullfile(rep_image,sprintf('%s-plage%d(QUANTILES).jpg',strtok(analyse.legende_sorties{:}),k)) )
    saveas(h, fullfile(rep_image,sprintf('%s-plage%d(QUANTILES).fig',strtok(analyse.legende_sorties{:}),k)) )

end


% Save sensitivity index results for MetaModel
if false
    for s=1:length(analyse.PC_Infos)
        if isempty(analyse.PC_Infos(s).GSA)
            A(:,s) = nan
            continue
        end
        A(:,s) = [  analyse.PC_Infos(s).GSA.SobolInd{1}
                sum(analyse.PC_Infos(s).GSA.SobolInd{1})
                analyse.PC_Infos(s).GSA.TotalSobolInd
                sum(analyse.PC_Infos(s).GSA.TotalSobolInd)
                0
                0
                1-analyse.PC_Infos(s).ErrorEstimates.Q2];
    end
    if s< size(resultat.sorties,2)
    	A(:,end+1:size(resultat.sorties,2))=nan
    end
    A(end-2,:) = mean(resultat.sorties)
    A(end-1,:) = var(resultat.sorties)
end



% Code for Temporal analysis of RBD FAST
% See also end of EPLab\Toolbox\commun_analyse.m
if false
    warning('Tambouille perso !!!!!!!!')
    % utilisation des variances via les indices:    
    analyse.VI_rbdfast = bsxfun(@times, analyse.SI_rbdfast, analyse.V);
    % utilisation des signs:
    analyse.VI_rbdfast(:,1) = analyse.VI_rbdfast(:,1).*analyse.signe(:,1);
    for a=2:size(analyse.VI_rbdfast,2)
        analyse.VI_rbdfast(:,a) = analyse.VI_rbdfast(:,a-1) + analyse.VI_rbdfast(:,a).*analyse.signe(:,a);
    end

end

disp('For more information, type ''global analyse'' and look at the content of the variable ''analyse''.')
fprintf('To reload the analysis: EPLab(''%s'')\n\n',fullfile(params.rep_result, 'config.m') ); % FileConfig')


end


function x = test_unused(x)
% test for unused temporal indicator
    x = isempty(x) || ( length(x)==1 && x(1)==0 ); % || any(x>0)
end



