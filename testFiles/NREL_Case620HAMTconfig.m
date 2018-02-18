%% EPLab version
EPLab_version = '1.8.1';

% Study Name
local.noms.etude = 'NREL-Case620HAMT-test';

%% INPUT/OUTPUT DEFINITION
% Nom du fichier idf de base. voir: modif_IDF()
simulation.IDF_initial = 'NREL_Case620PTACexp';

% Configuration statistique des variables d'entrées
% type(var:1/param:0/off:-1), nom, loi(R=en relatif), [moyenne écrat]/val_par_def, [min max]/{'txt1' 'txt2'} 
params.variables.infos = cell2struct(sortrows({
        % Model parameters
                0, 'ConductionAlgo', 'Discret', 4, {'ConductionTransferFunction' 'MoisturePenetrationDepthConductionTransferFunction' 'ConductionFiniteDifference' 'CombinedHeatAndMoistureFiniteElement'};
	            0, 'Timestep', 'Discret', 2, {'6', '60'};   %valeur {W}
		        0, 'RunPeriod', 'Discret', 2, {'1', '3'};   %valeur {W}			
		% Sizing parameters
                0, 'DoSizing', 'Discret', 1, {'No' 'Yes'};	     
                0, 'AirFlowRate', 'Discret', 2, {'0.504998', '0.500818'};     % 1=Seattle Boeing Field 
                0, 'CoollingCapacity', 'Discret', 2, {'8359.50', '8299.64'};  % 2=Singapore
                0, 'CoollingSensibleRatio', 'Discret', 2, {'0.798655', '0.798242'};   %
                0, 'HeatingCapacity', 'Discret', 2, {'6559.42', '0'};   %
        % Location parameters
                0, 'Orientation', 'Discret', 1, {0 180};     %valeur {-}
		% Material parameters   
                0, 'BrickEp', 'GaussianR', [0.12 10], [0.001 0.25];  %valeur {m}
                1, 'BrickCond', 'Gaussian', [0.684 0.218*1.96], [0.25 1.375];  %valeur {W/m-K}
                1, 'BrickDens', 'Gaussian', [1791.02 216.75*1.96], [1100 2400];  %valeur {kg/m3}
                1, 'BrickCp', 'Gaussian', [867.32 65.07*1.96], [700 1100];  %valeur {J/kg-K}
                1, 'BrickAbsoTherm', 'GaussianR', [0.9 10], [0.2 1];  %valeur {-}
                1, 'BrickAbsoSol', 'GaussianR', [0.3 10], [0.2 1];  %valeur {-}
                1, 'BrickAbsoVis', 'GaussianR', [0.7 10], [0.2 1];  %valeur {-}

			    1, 'BrickIsotherm', 'Uniform', [0.5 0.5], [0 1];   %valeur {-}
			    1, 'BrickPorosity', 'Uniform', [0.313 0.0636*1.96], [0.1 0.45];   %valeur {-}
			    0, 'BrickInitialWaterContent', 'Uniform', [0.0022 0.005], [0 0.01];   %valeur {kg/kg} --> valeur médiane a 60RH
			    1, 'BrickLiquidTransport', 'Uniform', [0.5 0.5], [0 1];   %valeur {-}
			    1, 'BrickVaporResistance', 'Uniform', [0.5 0.5], [0 1];   %valeur {-}
        % Building parameters
                1, 'Infiltration', 'UniformR', [0.5 20], [ ];   %valeur {1/hr}
			    1, 'EquipementSensible', 'UniformR', [200 10],[];   %valeur {W}
			    1, 'EquipementLatentOn', 'Uniform', [306.75 34.085], [270 360];   %valeur {W}
			    1, 'EquipementLatentOff', 'Uniform', [34.085 34.085], [0 70];   %valeur {W}   

                0, 'ThermostatHeating', 'UniformR', [20 5], [18 21];   %valeur {°C}
                0, 'ThermostatCooling', 'UniformR', [24 5], [22 28];   %valeur {°C}

               -1, 'WindowType', 'Discret', 1, {'Simple vitrage' 'Double vitrage' 'Double vitrage PE'};





},-1),...
{'actif', 'nom' 'loi' 'moments' 'limites'}, 2);


% Legende des variables
                %Nom,       Label Long,     Label Court,	Unités
local.vars_names=sortrows(	{
                'METEO','Météo','Météo','[]';
                'RunPeriod','RunPeriod','RunPeriod','[]';
                
				'AirFlowRate', 'System AirFlowRate', 'AirFlowRate', '[m^3/s]';
				'CoollingCapacity', 'CoollingCapacity', 'CoollingCapacity', '[W]';
				'CoollingSensibleRatio', 'CoollingSensibleRatio', 'CoollingSensibleRatio', '[]';
				'HeatingCapacity', 'HeatingCapacity', 'HeatingCapacity', '[W]';
				
				'ConductionAlgo', 'Conduction Algorithm Method', 'HeatBalanceAlgorithm', '[]';
				'Timestep', 'Timestep', 'Timestep', '[]';
                'DoSizing', 'DoSizing', 'DoSizing', '[]';
    
                'BrickEp', 'Brick Thickness', 'Brick Thickness', '[m]';
                'BrickCond', 'Brick Conductivity', 'Brick Conductivity', '[W/m-K]';
                'BrickDens', 'Brick Density', 'Brick Density', '[kg/m^3]';
                'BrickCp', 'Brick Specific Heat', 'Brick Specific Heat', '[J/kg-K]';
                'BrickAbsoTherm', 'Brick Thermal Absorptance', 'Brick Thermal Absorptance', '[-]';
                'BrickAbsoSol', 'Brick Solar Absorptance', 'Brick Solar Absorptance', '[-]';
                'BrickAbsoVis', 'Brick Visible Absorptance', 'Brick Visible Absorptance', '[-]';

                'BrickMoistDepth', 'Brick Moisture Penetration Depth', 'BrickMoisturePenetrationDepth', '[m]';
                'BrickIsotherm', 'Brick Sorption Isotherm', 'BrickSorptionIsotherm', '[-]';
                'BrickPorosity', 'Brick Porosity', 'BrickPorosity', '[m^3/m^3]';
                'BrickInitialWaterContent', 'Brick Initial Water Content', 'BrickInitialWaterContent', '[kg/kg]';
				'BrickLiquidTransport', 'Brick Liquid Transport', 'BrickMoistureDiffusivity', '[-]';
				'BrickVaporResistance', 'Brick Vapor Diffusion Resistance','BrickVaporResistance',  '[]';

				'EquipementSensible', 'Sensible load', 'EquipementSensible', '[W]';
				'EquipementLatentOn', 'Latent load with occ', 'EquipementLatentOcc', '[W]';
				'EquipementLatentOff', 'Latent load without occ', 'EquipementLatentRed', '[W]';
				'Infiltration', 'Air Renewal', 'AirRenewal', '[1/hr]';

				'ThermostatHeating', 'Heating Set Point', 'HeatingSetPoint', '[°C]';
				'ThermostatCooling', 'Cooling Set Point', 'CoolingSetPoint', '[°C]';

                'Orientation', 'Building Orientation', 'Building Orientation', '[-]';
                'Tsol', 'Température du sol', 'Température du sol', '[-]';
                'albedo', 'Albedo', 'Albedo', '[-]';
                'WindowType', 'WindowType', 'Window Type', '[-]';




},3);


% Configuration statistique des entrées météo
% fichier 'unique' / multiples 'liste' / personalisé: 'plan' / appel module: 'module'           
params.EPW_type = 'unique';
params.EPW.copie = true;

switch params.EPW_type
    case 'unique'
        simulation.EPW.name = {'SGP_Singapore.486980_IWEC'};
        params.EPW.copie = true;
%         simulation.EPW.path = 'D:\Documents\Fichier_meteo';
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

	0,'%OPAQUE%:Surface Inside Face Conduction Heat Gain Rate [W](Daily)','donnees.surface.P_cond_int_pos(:,%SURFID%)';  
	1,'%OPAQUE%:Surface Inside Face Conduction Heat Loss Rate [W](Daily)','donnees.surface.P_cond_int_neg(:,%SURFID%)';  
	1,'%OPAQUE%:Surface Outside Face Conduction Heat Gain Rate [W](Daily)','donnees.surface.P_cond_ext_pos(:,%SURFID%)';  
	1,'%OPAQUE%:Surface Outside Face Conduction Heat Loss Rate [W](Daily)','donnees.surface.P_cond_ext_neg(:,%SURFID%)';  

	-1,'%OPAQUE%:Surface Inside Face Conduction Heat Transfer Rate [W](Hourly)','donnees.surface.P_cond_int_h(:,%SURFID%)';  
	-1,'%OPAQUE%:Surface Average Face Conduction Heat Gain Rate [W](Hourly)','donnees.surface.P_avg_cond_pos_h(:,%SURFID%)';  %positive indicates heat flowing toward the thermal zone
	-1,'%OPAQUE%:Surface Average Face Conduction Heat Loss Rate [W](Hourly)','donnees.surface.P_avg_cond_neg_h(:,%SURFID%)';  
	-1,'%OPAQUE%:Surface Heat Storage Gain Rate [W](Hourly)','donnees.surface.P_avg_storage_pos_h(:,%SURFID%)';  
	-1,'%OPAQUE%:Surface Heat Storage Loss Rate [W](Hourly)','donnees.surface.P_avg_storage_neg_h(:,%SURFID%)';  

	1,'%SURFACE%:Surface Inside Face Temperature [C](Hourly)','donnees.surface.T_surf_int(:,%SURFID%)';
	-1,'%SURFACE%:Surface Outside Face Temperature [C](Hourly)','donnees.surface.T_surf_out(:,%SURFID%)';
	0,'%OPAQUE%:HAMT Surface Inside Face Relative Humidity [%](Hourly)','donnees.surface.HR_surf_int(:,%SURFID%)';
	0,'%OPAQUE%:EMPD Surface Inside Face Relative Humidity [%](Hourly)','donnees.surface.HR_surf_int(:,%SURFID%)';

	% Bilan sur l'air
	1,'%ZONE%:Zone Air Heat Balance Internal Convective Heat Gain Rate [W](Daily)','donnees.zone.P_int(:,%ZONEID%)';
	1,'%ZONE%:Zone Air Heat Balance Surface Convection Rate [W](Daily)','donnees.zone.P_surf(:,%ZONEID%)';
	1,'%ZONE%:Zone Air Heat Balance Outdoor Air Transfer Rate [W](Daily)','donnees.zone.P_out(:,%ZONEID%)';
	1,'%ZONE%:Zone Air Heat Balance System Air Transfer Rate [W](Daily)','donnees.zone.P_sys_air(:,%ZONEID%)';
	1,'%ZONE%:Zone Air Heat Balance System Convective Heat Gain Rate [W](Daily)','donnees.zone.P_sys_conv(:,%ZONEID%)';

	1,'%ZONE%:Zone Operative Temperature [C](Hourly)','donnees.zone.Toperative(:,%ZONEID%)';
	1,'%ZONE%:Zone Mean Air Temperature [C](Hourly)','donnees.zone.Tas(:,%ZONEID%)';
	1,'%ZONE%:Zone Air Relative Humidity [%](Hourly)','donnees.zone.RH(:,%ZONEID%)';
    1,'%ZONE%:Zone Air Humidity Ratio [](Hourly)','donnees.zone.w(:,%ZONEID%)';

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
    0,'%ZONE% PTAC:Zone Packaged Terminal Air Conditioner Sensible Heating Rate [W](Hourly)','donnees.zone.E_heat.Sensible(:,%ZONEID%)';
    0,'%ZONE% PTAC:Zone Packaged Terminal Air Conditioner Latent Heating Rate [W](Hourly)','donnees.zone.E_heat.Latent(:,%ZONEID%)';
    0,'%ZONE% PTAC:Zone Packaged Terminal Air Conditioner Total Heating Rate [W](Hourly)','donnees.zone.E_heat.Total(:,%ZONEID%)';
    1,'%ZONE% PTAC:Zone Packaged Terminal Air Conditioner Sensible Cooling Rate [W](Hourly)','donnees.zone.E_cool.Sensible(:,%ZONEID%)';
    1,'%ZONE% PTAC:Zone Packaged Terminal Air Conditioner Latent Cooling Rate [W](Hourly)','donnees.zone.E_cool.Latent(:,%ZONEID%)';
    1,'%ZONE% PTAC:Zone Packaged Terminal Air Conditioner Total Cooling Rate [W](Hourly)','donnees.zone.E_cool.Total(:,%ZONEID%)';
	
	% Transfert des fenêtres ext (Flux total (cond + ray) trasmit dans la zone par fenetre) 
	-1,'%WINDOW%:Surface Window Heat Gain Energy [J](Daily)','donnees.surface.E_win_gain(:,%SURFID%)';
	-1,'%WINDOW%:Surface Window Heat Loss Energy [J](Daily)','donnees.surface.E_win_loss(:,%SURFID%)'; 
	% part rayonnement (informatif)
	-1,'%WINDOW%:Surface Window Transmitted Solar Radiation Energy [J](Daily)','donnees.surface.E_win_ray(:,%SURFID%)'; 
};


%% SAMPLING DEFINITION
% Configuration de l'échantillonnage et de l'analyse (voir: commun_analyse() )
params.nb_tir=400;

params.type_ech=4;     % 4:LHS-local 6:Halton_local 8:LPTau_local      
                        % 1:random_global 3:RBD_global 5:LHS_global
                        % 7:Halton_global 9:LPTau_global 10:MORIS_global
                        % -->global = [min max] of the 'limites' field & all uniform(used to find a solution)
                        
params.type_plan_LHS=1;     % 0:sans 1:minimean10 2:minimax10

local.recap_plan = true;    % compare les variations initiales aux variations du plan 


%% SIMULATION DEFINITION
params.model = 'EnergyPlus';
% Repertoire(s) d'instalation EnergyPlus (!! finir avec un '\' !!)
Ep_dir = {'C:\EnergyPlusV8-3-0\',
          'C:\EnergyPlusV8-4-0\',
          'C:\EnergyPlusV8-5-0\'
};

local.nb_proc=7;
local.auto_start=false; 	% Demarre automatiquement les simulations
local.test_delay=20;	% Intervale en sec. entre les tests sur les résultats de simulation



%% OUTPUT SHAPING

% Study ranges
resultat.plage(1).nom = 'Week';
resultat.plage(1).debut = '29/12';
resultat.plage(1).fin = '31/12';

% resultat.plage(2).nom = 'Annual';
% resultat.plage(2).debut = '01/01';
% resultat.plage(2).fin = '31/12';

resultat.range_temporal = 0;	%To run a temporal analysis define ID of the range, // '-1' = all ranges

resultat.extract_lum=false;

%% RESUTS EXPORT
% Saving of all indicateur results
resultat.save = false;      % save the values calculated
resultat.save_path = '';    % path or mat-file to save the values (several studies can be added in the same file)


% Création des images  (Not for temporal analysis)
local.images.export=false;      % active l'export entrées / sorties
local.images.export2=false;     % active l'export sorties / sorties

local.images.colors=false;
local.images.visible = 'off';   % affiche les courbes (ralenti)
local.images.nbs_point = 0;   % limite le nombre de points des graphs, off=0
local.images.random = false;    % randomise les points choisis
local.images.fontsize = 16;
local.images.markersize = 15;


%% SENSITIVITY ANALYSIS DEFINITION
% type d'Analyse
analyse.type_etude=3;  % 0:rien 2:PCE_MetaModel 3:RBD-FAST 5:sobol 6:MORIS

% Specific properties: RBDFAST
% analyse.RBD.force=false;    % outrepasse les vérifications de l'analyses
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
