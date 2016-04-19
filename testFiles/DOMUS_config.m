%% EPLab version
EPLab_version = '1.8.1';

% Study Name
local.noms.etude = 'DomusTest';

%% INPUT/OUTPUT DEFINITION
% Nom du fichier idf de base. voir: modif_IDF()
simulation.IDF_initial = 'DomusTest';

% Configuration statistique des variables d'entrées
% type(var:1/param:0/off:-1), nom, loi(R=en relatif), [moyenne écrat]/val_par_def, [min max]/{'txt1' 'txt2'} 
params.variables.infos = cell2struct(sortrows({
                1, 'distancefenetre','Uniform', [0 0.25], []; % valeur {m} 
                1, 'longeur', 'Uniform', [0 0.9], []; % valeur {m}
                -1, 'distanceinter', 'Uniform', [0 0.125], []; % valeur {m}
                1, 'depassement', 'Uniform', [0 0.125], []; % valeur {m}
                -1, 'reflectance', 'Uniform', [0.5 0.3], [];   %valeur {}
},-1),...
{'actif', 'nom' 'loi' 'moments' 'limites'}, 2);


% Legende des variables
                %Nom,       Label Long,     Label Court,	Unités
local.vars_names=sortrows(	{
                'distancefenetre', 'distancefenetre', 'distancefenetre',' [m]';
                'longeur', 'longeur', 'longeur',' [m]'; 
                'distanceinter', 'distanceinter', 'distanceinter',' [m]'; 
                'depassement', 'depassement', 'depassement',' [m]'; 
                'reflectance', 'reflectance', 'reflectance',' []';
},3);


% Configuration statistique des entrées météo
% fichier 'unique' / multiples 'liste' / personalisé: 'plan' / appel module: 'module'           
params.EPW_type = 'none';
params.EPW.copie = false;

switch params.EPW_type
    case 'unique'
        simulation.EPW.name = {'USA_IL_Chicago-Midway.AP.725340_TMY3_3'};
        params.EPW.copie = true;
        simulation.EPW.path = 'C:\Users\almeida.paula\Desktop\preliminar\preliminarEP';
    case 'liste'
        simulation.EPW.name = {'USA_WA_Seattle-Boeing.Field.727935_TMY3',
                               'SGP_Singapore.486980_IWEC'};
        params.EPW.copie = true;
%       simulation.EPW.path = '';
 
    case 'plan'
        simulation.EPW.path = 'D:\Jeanne\Documents\AS_Reunion_2012\Fichier_meteo\Fichier_EPW\Chol_3_janv\fichier';
        simulation.EPW.name = arrayfun(@(x)sprintf('test%i',x),[1:params.nb_tir]','uniformOutput',false);
%         simulation.EPW.plan = load('plan.mat'); OU  simulation.EPW.plan = 'D:\Documents\...\index.mat';
%         simulation.EPW.index =load('index.mat'); OU simulation.EPW.index ='D:\Documents\...\index.mat';
    case 'module'        
        simulation.EPW.name = {'USA_NY_New.York-LaGuardia.AP.725030_TMY3'};
        simulation.EPW.path = 'C:\Users\jeanne.goffart\Dropbox\Ana_Lea_Jeanne\Version_17\';%pwd;  ou C:\Users\Jeanne\Dropbox\Ana_Lea_Jeanne\Version_17
        params.EPW.copie = false;
        % A définir:
        % simulation.EPW.path, simulation.EPW.name, simulation.EPW.plan, simulation.EPW.index
end



% Définition des sorties observables (voir: find_surface() )
%       Option:      1:Actif     0:optionnel     -1:Innactif
%       %ZONE%=Nom_zone         %ZONEID%=Id_zone        %ZONECONF%=Nom_zone_occup       %ZONEID%=ID_zone
%       %SURFACE%=Nom_surface	%OPAQUE%=Nom_mur        %WINDOW%=Nom_fenetre            %SURFID%=ID_surface
sorties = {
    % Températures / Confort
	-1,'Environment:Site Outdoor Air Drybulb Temperature [C](Daily)','donnees.simple.T_ext';

	% Transfert des parois (!SIGNES et Versions!)
	-1,'%SURFACE%:Surface Inside Face Convection Heat Gain Energy [J](Hourly)','donnees.surface.E_conv_int(:,%SURFID%)';
	-1,'%SURFACE%:Surface Outside Face Convection Heat Gain Energy [J](Hourly)','donnees.surface.E_conv_out(:,%SURFID%)';

	-1,'%OPAQUE%:Surface Inside Face Conduction Heat Gain Rate [W](Daily)','donnees.surface.P_cond_int_pos(:,%SURFID%)';  
	-1,'%OPAQUE%:Surface Inside Face Conduction Heat Loss Rate [W](Daily)','donnees.surface.P_cond_int_neg(:,%SURFID%)';  
	-1,'%OPAQUE%:Surface Outside Face Conduction Heat Gain Rate [W](Daily)','donnees.surface.P_cond_ext_pos(:,%SURFID%)';  
	-1,'%OPAQUE%:Surface Outside Face Conduction Heat Loss Rate [W](Daily)','donnees.surface.P_cond_ext_neg(:,%SURFID%)';  

	-1,'%OPAQUE%:Surface Inside Face Conduction Heat Transfer Rate [W](Hourly)','donnees.surface.P_cond_int_h(:,%SURFID%)';  
	-1,'%OPAQUE%:Surface Average Face Conduction Heat Gain Rate [W](Hourly)','donnees.surface.P_avg_cond_pos_h(:,%SURFID%)';  %positive indicates heat flowing toward the thermal zone
	-1,'%OPAQUE%:Surface Average Face Conduction Heat Loss Rate [W](Hourly)','donnees.surface.P_avg_cond_neg_h(:,%SURFID%)';  
	-1,'%OPAQUE%:Surface Heat Storage Gain Rate [W](Hourly)','donnees.surface.P_avg_storage_pos_h(:,%SURFID%)';  
	-1,'%OPAQUE%:Surface Heat Storage Loss Rate [W](Hourly)','donnees.surface.P_avg_storage_neg_h(:,%SURFID%)';  

	-1,'%SURFACE%:Surface Inside Face Temperature [C](Hourly)','donnees.surface.T_surf_int(:,%SURFID%)';
	-1,'%SURFACE%:Surface Outside Face Temperature [C](Hourly)','donnees.surface.T_surf_out(:,%SURFID%)';
	-1,'%OPAQUE%:HAMT Surface Inside Face Relative Humidity [%](Hourly)','donnees.surface.HR_surf_int(:,%SURFID%)';
	-1,'%OPAQUE%:EMPD Surface Inside Face Relative Humidity [%](Hourly)','donnees.surface.HR_surf_int(:,%SURFID%)';

	% Bilan sur l'air
	-1,'%ZONE%:Zone Air Heat Balance Internal Convective Heat Gain Rate [W](Daily)','donnees.zone.P_int(:,%ZONEID%)';
	-1,'%ZONE%:Zone Air Heat Balance Surface Convection Rate [W](Daily)','donnees.zone.P_surf(:,%ZONEID%)';
	-1,'%ZONE%:Zone Air Heat Balance Outdoor Air Transfer Rate [W](Daily)','donnees.zone.P_out(:,%ZONEID%)';
	-1,'%ZONE%:Zone Air Heat Balance System Air Transfer Rate [W](Daily)','donnees.zone.P_sys_air(:,%ZONEID%)';
	-1,'%ZONE%:Zone Air Heat Balance System Convective Heat Gain Rate [W](Daily)','donnees.zone.P_sys_conv(:,%ZONEID%)';

	-1,'%ZONE%:Zone Operative Temperature [C](Hourly)','donnees.zone.Toperative(:,%ZONEID%)';
	-1,'%ZONE%:Zone Air Temperature [C](Hourly)','donnees.zone.Tas(:,%ZONEID%)';
	-1,'%ZONE%:Zone Air Relative Humidity [%](Hourly)','donnees.zone.RH(:,%ZONEID%)';
    -1,'%ZONE%:Zone Air Humidity Ratio [](Hourly)','donnees.zone.w(:,%ZONEID%)';

	% Consomations Electriques
	-1,'Whole Building:Facility Total Purchased Electric Energy [J](Hourly)','donnees.E_elec_tot';

	% Consomations Systeme
	-1,'%ZONE%:Zone Air System Sensible Heating Rate [W](Hourly)','donnees.zone.E_heat.Sensible(:,%ZONEID%)';
	-1,'%ZONE%:Zone Air System Sensible Cooling Rate [W](Hourly)','donnees.zone.E_cool.Sensible(:,%ZONEID%)';
	-1,'%ZONE% IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Sensible Heating Rate [W](Hourly)','donnees.zone.E_heat.Sensible(:,%ZONEID%)';
	-1,'%ZONE% IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Latent Heating Rate [W](Hourly)','donnees.zone.E_heat.Latent(:,%ZONEID%)';
	-1,'%ZONE% IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Total Heating Rate [W](Hourly)','donnees.zone.E_heat.Total(:,%ZONEID%)';
	-1,'%ZONE% IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Sensible Cooling Rate [W](Hourly)','donnees.zone.E_cool.Sensible(:,%ZONEID%)';
	-1,'%ZONE% IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Latent Cooling Rate [W](Hourly)','donnees.zone.E_cool.Latent(:,%ZONEID%)';
	-1,'%ZONE% IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Total Cooling Rate [W](Hourly)','donnees.zone.E_cool.Total(:,%ZONEID%)';
    -1,'%ZONE% PTAC:Zone Packaged Terminal Air Conditioner Sensible Heating Rate [W](Hourly)','donnees.zone.E_heat.Sensible(:,%ZONEID%)';
    -1,'%ZONE% PTAC:Zone Packaged Terminal Air Conditioner Latent Heating Rate [W](Hourly)','donnees.zone.E_heat.Latent(:,%ZONEID%)';
    -1,'%ZONE% PTAC:Zone Packaged Terminal Air Conditioner Total Heating Rate [W](Hourly)','donnees.zone.E_heat.Total(:,%ZONEID%)';
    -1,'%ZONE% PTAC:Zone Packaged Terminal Air Conditioner Sensible Cooling Rate [W](Hourly)','donnees.zone.E_cool.Sensible(:,%ZONEID%)';
    -1,'%ZONE% PTAC:Zone Packaged Terminal Air Conditioner Latent Cooling Rate [W](Hourly)','donnees.zone.E_cool.Latent(:,%ZONEID%)';
    -1,'%ZONE% PTAC:Zone Packaged Terminal Air Conditioner Total Cooling Rate [W](Hourly)','donnees.zone.E_cool.Total(:,%ZONEID%)';

	% Transfert des fenêtres ext (Flux total (cond + ray) trasmit dans la zone par fenetre) 
	-1,'%WINDOW%:Surface Window Heat Gain Energy [J](Daily)','donnees.surface.E_win_gain(:,%SURFID%)';
	-1,'%WINDOW%:Surface Window Heat Loss Energy [J](Daily)','donnees.surface.E_win_loss(:,%SURFID%)'; 
	% part rayonnement (informatif)
	-1,'%WINDOW%:Surface Window Transmitted Solar Radiation Energy [J](Daily)','donnees.surface.E_win_ray(:,%SURFID%)'; 
    
    %Estudo da MARGAUX
    1,'MAIN:Daylighting Reference Point 1 Illuminance [lux](Hourly)','donnees.zone.D_1(:,1)';
    1,'MAIN:Daylighting Reference Point 2 Illuminance [lux](Hourly)','donnees.zone.D_2(:,1)'; 
    1,'LIGHT1:Lights Electric Power [W](Hourly)','donnees.zone.L_E_P(:,1)';
   -1,'MAIN:DemandEndUseComponentsSummary [lux](Hourly)','donnees.zone.Demand(:,1)';
    1,'MAIN IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Total Cooling Rate [W](Hourly)','donnees.zone.R_cool(:,1)';
    1,'MAIN IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Total Heating Rate [W](Hourly)','donnees.zone.R_heat(:,1)';
  
    
};


%% SAMPLING DEFINITION
% Configuration de l'échantillonnage et de l'analyse (voir: commun_analyse() )
params.nb_tir=2;

params.type_ech=4;      % 4:LHS-local 6:Halton_local 8:LPTau_local      //  1:random_global 3:RBD_global 5:LHS_global 7:Halton_global 9:LPTau_global  !!! global = [min max] of the 'limites' field & all uniform(used to find a solution)
params.type_plan_LHS=1;     % 0:sans 1:minimean10 2:minimax10

local.recap_plan = true;    % compare les variations initiales aux variations du plan 


%% SIMULATION DEFINITION
simulation.model = 'DOMUS';
% Repertoire(s) d'instalation EnergyPlus (!! finir avec un '\' !!)
simulation.model_dir = {'C:\EnergyPlusV8-3-0\'
          'C:\EnergyPlusV8-4-0\'
          'C:\EnergyPlusV8-5-0\'
          'C:\Program Files (x86)\Domus - Eletrobras'
          'D:\DOMUS'
};

local.nb_proc=7;
local.auto_start=false; 	% Demarre automatiquement les simulations
local.test_delay=20;	% Intervale en sec. entre les tests sur les résultats de simulation



%% OUTPUT SHAPING

% Study ranges
resultat.plage(1).nom = 'Annual';
resultat.plage(1).debut = '01/01';
resultat.plage(1).fin = '31/01';

% resultat.plage(2).nom = 'HotMonth';
% resultat.plage(2).debut = '01/07';
% resultat.plage(2).fin = '31/07';

resultat.range_temporal = 0;	%To run a temporal analysis define ID of the range, // '-1' = all ranges

resultat.extract_lum=false;

%% RESUTS EXPORT
% Saving of all indicateur results
resultat.save = false;      % save the values calculated
resultat.save_path = '';    % path or mat-file to save the values (several studies can be added in the same file)


% Création des images  (Not for temporal analysis)
local.images.export=true;      % active l'export entrées / sorties
local.images.export2=true;     % active l'export sorties / sorties

local.images.colors=false;
local.images.visible = 'off';   % affiche les courbes (ralenti)
local.images.nbs_point = 0;     % limite le nombre de points des graphs, off=0
local.images.random = false;    % randomise les points choisis
local.images.fontsize = 16;
local.images.markersize = 15;


%% SENSITIVITY ANALYSIS DEFINITION
% type d'Analyse
analyse.type_etude=3;  % 0 rien / 2 PC / 3 RBD / 5 sobol

% Specific properties: RBDFAST
analyse.RBD.force=true;    % outrepasse les vérifications de l'analyses
% analyse.RBD.harmonics=10;

% Convergence graph
analyse.convergence = false;     % only for RBDFAST & Not for temporal analysis
analyse.convergence_param.step = 10;  % increase of simulation number
analyse.convergence_param.input = 0;  % check in params.variables.actif // '0' = all inputs
analyse.convergence_param.output = 0; % check in resultat.sorties_valide & legende.sorties_all; // '0' = variance max output's

% Bootstrap analysis
analyse.bootstrap = false;
analyse.bootstrap_param.ech = params.nb_tir;
analyse.bootstrap_param.rep = 1000;
analyse.bootstrap_param.save = true;



%% OTHER DEFINITIONS
% Nom des differents fichiers/répertoires
local.noms.data = 'simul_';
local.noms.result= 'resultats_';
local.noms.simul = 'simulations_';
local.noms.image = 'images';
local.noms.save = 'analyse.mat';
local.noms.indicateurs = 'results_indicateur.mat';

% Paramètres d'affichage
affichage.largeur=100;      % Largeur de la fenetre de commande
