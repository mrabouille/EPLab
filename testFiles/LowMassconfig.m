%% Paramètres de simulation

% Paramètres généraux de simulation
local.noms.etude = 'LowMass_3Var_MinMax_LPT_Salvador';
local.nb_proc=1;
local.start_simul=false;    % Demarre automatiquement les simulations
local.test_delay=30;       % Intervale en sec. entre les tests sur les résultats de simulation

% Création des images
local.images.export=false;      % active l'export entrées / sorties
local.images.export2=false;     % active l'export sorties / sorties
local.images.colors=false;
local.images.visible = 'off';   % affiche les courbes (ralenti)
local.images.nbs_point = 0;   % limite le nombre de points des graphs, off=0
local.images.random = false;    % randomise les points choisis
local.images.fontsize = 16;
local.images.markersize = 15;

% Nom du fichier idf de base. voir: modif_IDF()
simulation.IDF_initial = 'LowMass';

params.model = 'EnergyPlus';
% Repertoire d'instalation EnergyPlus (!! finir avec un '\' !!)
Ep_dir = {'D:\EnergyPlusV8-3-0\',
          'C:\EnergyPlusV8-3-0\'};

% Configuration de l'échantillonnage et de l'analyse (voir: commun_analyse() )
params.nb_tir=600;     % 300(2) -> 7h30

params.type_ech=4;      % 1:random_global 3:RBD_global 4:LHS-local 5:LHS_global 6:Halton_local 7:Halton_global 8:LPTau_local  9:LPTau_global
params.type_plan_LHS=1;     % 0:sans 1:minimean10 2:minimax10

local.recap_plan = true;    % compare les variations initiales au variations du plan 

analyse.type_etude=3;  % 0 rien / 2 PC / 3 RBD  /  5 sobol

analyse.bootstrap = false;
analyse.bootstrap_param.ech = params.nb_tir;
analyse.bootstrap_param.rep = 1000;
analyse.bootstrap_param.save = true;

%analyse.RBD.force=false;    % outrepasse les vérifications de l'analyses
%analyse.RBD.harmonics=10;


resultat.extract_lum=false;
% DEFINIR PLAGE


resultat.plage(1).nom = 'HotMonth';
resultat.plage(1).debut = '10/02';
resultat.plage(1).fin = '12/03';
resultat.plage(1).temporel = false;

resultat.plage(2).nom = 'ColdMonth';
resultat.plage(2).debut = '12/08';
resultat.plage(2).fin = '11/09';
resultat.plage(2).temporel = false;
        
    
% Configuration statistique des entrées météo
% fichier 'unique' / multiples 'liste' / personalisé: 'plan' / appel module: 'module'           
params.EPW_type = 'unique';
params.EPW.copie = true;


switch params.EPW_type
    case 'unique'
        simulation.EPW.name = {'PR_Curitiba'};
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


% Configuration statistique des variables d'entrées
%                 type(var:1/param:0/off:-1), nom, loi(R=en relatif), [moyenne écrat]/val_par_def, [min max]/{'txt1' 'txt2'} 
params.variables.infos = cell2struct(sortrows({ 
    % materiaux isolant
        1, 'isol_ep', 'UniformR', [0.05 10], [0.0001 0.10]; 
        -1, 'isol_cond', 'UniformR', [0.049 10], []; 
        -1, 'isol_dens','UniformR', [265.0000 10], [];  
        -1, 'isol_spec','UniformR', [836.8000 10], []; 
        -1, 'isol_emis', 'UniformR', [0.9000 10], []; 
        -1, 'isol_absSol', 'UniformR', [0.7000 10], []; 
        -1, 'isol_absVis','UniformR', [0.7000 10], [];  
        
   % materiaux metal   
        -1, 'met_ep', 'UniformR', [0.0015 10], []; 
        -1, 'met_cond', 'UniformR', [45.006 10], []; 
        -1, 'met_dens','UniformR', [7680.0000 10], [];  
        -1, 'met_spec','UniformR', [418.4000 10], []; 
        -1, 'met_emis', 'UniformR', [0.9000 10], []; 
        -1, 'met_absSol', 'UniformR', [0.7000 10], []; 
        -1, 'met_absVis','UniformR', [0.3000 10], [];  
   % materiaux membrane
        -1, 'memb_ep', 'UniformR', [0.0095 10], []; 
        -1, 'memb_cond', 'UniformR', [0.1600 10], []; 
        -1, 'memb_dens','UniformR', [1121.2900 10], [];  
        -1, 'memb_spec','UniformR', [1460.0000 10], []; 
        1, 'memb_emis', 'UniformR', [0.8000 10], [0.2 0.9]; 
        1, 'memb_absSol', 'UniformR', [0.7000 10], [0.2 0.9]; 
        -1, 'memb_absVis','UniformR', [0.7000 10], [];        
        
   % setpoint
   
        0, 'setpoint','UniformR', [24 5], [22 28]; 
      % 0, 'setpoint', 'Discret', 6, {'20','21','22','23','24','25','26','27'};	 
      
%         % variable simple
%                 0, 'ConductionAlgo', 'Discret', 4, {'ConductionTransferFunction' 'MoisturePenetrationDepthConductionTransferFunction' 'ConductionFiniteDifference' 'CombinedHeatAndMoistureFiniteElement'};
% 	            0, 'Timestep', 'Discret', 2, {'6', '60'};   %valeur {W}
% 
% 		% variable geometrie
%                 0, 'DoSizing', 'Discret', 1, {'No' 'Yes'};	     
%                 0, 'AirFlowRate', 'Discret', 2, {'0.504998', '0.500818'};     % 1=Seattle Boeing Field 
%                 0, 'CoollingCapacity', 'Discret', 2, {'8359.50', '8299.64'};  % 2=Singapore
%                 0, 'CoollingSensibleRatio', 'Discret', 2, {'0.798655', '0.798242'};   %
%                 0, 'HeatingCapacity', 'Discret', 2, {'6559.42', '0'};   %
%         % Location parameters
%                 1, 'Infiltration', 'UniformR', [0.5 20], [ ];   %valeur {1/hr}
%                 0, 'Orientation', 'Discret', 1, {0 180};     %valeur {-}
%         % Material parameters   
%                 0, 'BrickEp', 'GaussianR', [0.12 10], [0.001 0.25];  %valeur {m}
%                 1, 'BrickCond', 'Gaussian', [0.684 0.218*1.96], [0.25 1.375];  %valeur {W/m-K}
%                 1, 'BrickDens', 'Gaussian', [1791.02 216.75*1.96], [1100 2400];  %valeur {kg/m3}
%                 1, 'BrickCp', 'Gaussian', [867.32 65.07*1.96], [700 1100];  %valeur {J/kg-K}
%                 1, 'BrickAbsoTherm', 'GaussianR', [0.9 10], [0.2 1];  %valeur {-}
%                 1, 'BrickAbsoSol', 'GaussianR', [0.3 10], [0.2 1];  %valeur {-}
%                 1, 'BrickAbsoVis', 'GaussianR', [0.7 10], [0.2 1];  %valeur {-}
% 
% 			    1, 'BrickIsotherm', 'Uniform', [0.5 0.5], [0 1];   %valeur {-}
% 			    1, 'BrickPorosity', 'Uniform', [0.313 0.0636*1.96], [0.1 0.45];   %valeur {-}
% 			    0, 'BrickInitialWaterContent', 'Uniform', [0.0022 0.005], [0 0.01];   %valeur {kg/kg} --> valeur médiane a 60RH
% 			    1, 'BrickLiquidTransport', 'Uniform', [0.5 0.5], [0 1];   %valeur {-}
% 			    1, 'BrickVaporResistance', 'Uniform', [0.5 0.5], [0 1];   %valeur {-}
%         % Building parameters                 
% 			    1, 'EquipementSensible', 'UniformR', [200 10],[];   %valeur {W}
% 			    1, 'EquipementLatentOn', 'Uniform', [306.75 34.085], [270 360];   %valeur {W}
% 			    1, 'EquipementLatentOff', 'Uniform', [34.085 34.085], [0 70];   %valeur {W}   
% 
%                 0, 'ThermostatHeating', 'UniformR', [20 5], [18 21];   %valeur {°C}
%                 0, 'ThermostatCooling', 'UniformR', [24 5], [22 28];   %valeur {°C}
% 
%                -1, 'WindowType', 'Discret', 1, {'Simple vitrage' 'Double vitrage' 'Double vitrage PE'};
                 },-1),...
                 {'actif', 'nom' 'loi' 'moments' 'limites'}, 2);

            
            
% Informations générales sur les variables
                %Nom,       Label,      LabelCourt,         Unités
local.vars_names=sortrows({ 
        'isol_ep', 'isol_ep', 'isol_ep', '[]';
        'isol_cond','isol_cond','isol_cond','[]' ; 
        'isol_dens','isol_dens' ,'isol_dens' ,'[]';  
        'isol_spec','isol_spec','isol_spec', '[]'; 
        'isol_emis', 'isol_emis','isol_emis', '[]'; 
        'isol_absSol', 'isol_absSol', 'isol_absSol', '[]'; 
        'isol_absVis', 'isol_absVis', 'isol_absVis', '[]';   
        'met_ep', 'met_ep', 'met_ep', '[]'; 
        'met_cond', 'met_cond', 'met_cond', '[]'; 
        'met_dens', 'met_dens',  'met_dens', '[]';  
        'met_spec','met_spec', 'met_spec', '[]'; 
        'met_emis', 'met_emis', 'met_emis',' []'; 
        'met_absSol',  'met_absSol',  'met_absSol', '[]'; 
        'met_absVis', 'met_absVis',  'met_absVis',' []';  
        'memb_ep', 'memb_ep', 'memb_ep', '[]'; 
        'memb_cond', 'memb_cond', 'memb_cond', '[]'; 
        'memb_dens','memb_dens', 'memb_dens', '[]';  
        'memb_spec','memb_spec', 'memb_spec', '[]'; 
        'memb_emis', 'memb_emis', 'memb_emis', '[]'; 
        'memb_absSol', 'memb_absSol', 'memb_absSol', '[]'; 
        'memb_absVis', 'memb_absVis',  'memb_absVis', '[]';         
        'setpoint','setpoint','setpoint', '[]';

%                 'METEO','Météo','Météo','[]';
%                 
% 				'AirFlowRate', 'AirFlowRate', 'System AirFlowRate', '[m^3/s]';
% 				'CoollingCapacity', 'CoollingCapacity', 'CoollingCapacity', '[W]';
% 				'CoollingSensibleRatio', 'CoollingSensibleRatio', 'CoollingSensibleRatio', '[]';
% 				'HeatingCapacity', 'HeatingCapacity', 'HeatingCapacity', '[W]';
% 				
% 				'ConductionAlgo', 'HeatBalanceAlgorithm', 'Conduction Algorithm Method', '[]';
% 				'Timestep', 'Timestep', 'Timestep', '[]';
%                 'DoSizing', 'DoSizing', 'DoSizing', '[]';
%     
%                 'BrickEp', 'Brick Thickness', 'Brick Thickness', '[m]';
%                 'BrickCond', 'Brick Conductivity', 'Brick Conductivity', '[W/m-K]';
%                 'BrickDens', 'Brick Density', 'Brick Density', '[kg/m^3]';
%                 'BrickCp', 'Brick Specific Heat', 'Brick Specific Heat', '[J/kg-K]';
%                 'BrickAbsoTherm', 'Brick Thermal Absorptance', 'Brick Thermal Absorptance', '[-]';
%                 'BrickAbsoSol', 'Brick Solar Absorptance', 'Brick Solar Absorptance', '[-]';
%                 'BrickAbsoVis', 'Brick Visible Absorptance', 'Brick Visible Absorptance', '[-]';
% 
%                 'BrickMoistDepth', 'BrickMoisturePenetrationDepth', 'Brick Moisture Penetration Depth', '[m]';
%                 'BrickIsotherm', 'BrickSorptionIsotherm', 'Brick Sorption Isotherm', '[-]';
%                 'BrickPorosity', 'BrickPorosity', 'Brick Porosity', '[m^3/m^3]';
%                 'BrickInitialWaterContent', 'BrickInitialWaterContent', 'Brick Initial Water Content', '[kg/kg]';
% 				'BrickLiquidTransport', 'BrickMoistureDiffusivity', 'Brick Liquid Transport', '[-]';
% 				'BrickVaporResistance', 'BrickVaporResistance', 'Brick Vapor Diffusion Resistance', '[]';
% 
% 				'EquipementSensible', 'EquipementSensible', 'Sensible load', '[W]';
% 				'EquipementLatentOn', 'EquipementLatentOcc', 'Latent load with occ', '[W]';
% 				'EquipementLatentOff', 'EquipementLatentRed', 'Latent load without occ', '[W]';
% 				'Infiltration', 'AirRenewal', 'Air Renewal', '[1/hr]';
% 
% 				'ThermostatHeating', 'HeatingSetPoint', 'Heating Set Point', '[°C]';
% 				'ThermostatCooling', 'CoolingSetPoint', 'Cooling Set Point', '[°C]';
% 
% 
% 			
%                 'Orientation', 'Building Orientation', 'Building Orientation', '[-]';
%                 'Tsol', 'Température du sol', '', '[-]';
%                 'albedo', 'Albedo', '', '[-]';
%                 'WindowType', 'WindowType', 'Window Type', '[-]';
           },3);

            
% Définition des sorties observables (voir: find_surface() )
%       Option:      1:Actif     0:optionnel     -1:Innactif
%       %ZONE%=Nom_zone         %ZONEID%=Id_zone        %ZONECONF%=Nom_zone_occup       %ZONEID%=ID_zone
%       %SURFACE%=Nom_surface	%OPAQUE%=Nom_mur        %WINDOW%=Nom_fenetre            %SURFID%=ID_surface
sorties = {
    % Températures / Confort
   -1,'Environment:Site Outdoor Air Drybulb Temperature [C](Daily)','donnees.simple.T_ext';
   
    1,'Environment:Site Outdoor Air Drybulb Temperature [C](Hourly)','donnees.site.T_air';
    1,'Environment:Site Outdoor Air Humidity Ratio [kgWater/kgDryAir](Hourly)','donnees.site.w';
    1,'Environment:Site Outdoor Air Relative Humidity [%](Hourly)','donnees.site.RH';
    1,'Environment:Site Sky Temperature [C](Hourly)','donnees.site.T_sky';
    1,'Environment:Site Diffuse Solar Radiation Rate per Area [W/m2](Hourly)','donnees.site.Rad_diff';
    1,'Environment:Site Direct Solar Radiation Rate per Area [W/m2](Hourly)','donnees.site.Rad_dir';
    1,'Environment:Site Precipitation Depth [m](Hourly)','donnees.site.Precipitation';


	% Transfert des parois (!SIGNES et Versions!)
   -1,'%SURFACE%:Surface Inside Face Convection Heat Gain Energy [J](Hourly)','donnees.surface.E_conv_int(:,%SURFID%)';
 %  -1,'%SURFACE%:Surface Outside Face Convection Heat Gain Energy [J](Hourly)','donnees.surface.E_conv_out(:,%SURFID%)';

   -1,'%OPAQUE%:Surface Inside Face Conduction Heat Gain Rate [W](Daily)','donnees.surface.P_cond_int_pos(:,%SURFID%)';  
   -1,'%OPAQUE%:Surface Inside Face Conduction Heat Loss Rate [W](Daily)','donnees.surface.P_cond_int_neg(:,%SURFID%)';  
   -1,'%OPAQUE%:Surface Outside Face Conduction Heat Gain Rate [W](Daily)','donnees.surface.P_cond_ext_pos(:,%SURFID%)';  
   -1,'%OPAQUE%:Surface Outside Face Conduction Heat Loss Rate [W](Daily)','donnees.surface.P_cond_ext_neg(:,%SURFID%)';  

	1,'%OPAQUE%:Surface Inside Face Conduction Heat Transfer Rate [W](Hourly)','donnees.surface.P_cond_int_h(:,%SURFID%)';  
	1,'%OPAQUE%:Surface Average Face Conduction Heat Gain Rate [W](Hourly)','donnees.surface.P_avg_cond_pos_h(:,%SURFID%)';  %positive indicates heat flowing toward the thermal zone
	1,'%OPAQUE%:Surface Average Face Conduction Heat Loss Rate [W](Hourly)','donnees.surface.P_avg_cond_neg_h(:,%SURFID%)';  
	1,'%OPAQUE%:Surface Heat Storage Gain Rate [W](Hourly)','donnees.surface.P_avg_storage_pos_h(:,%SURFID%)';  
	1,'%OPAQUE%:Surface Heat Storage Loss Rate [W](Hourly)','donnees.surface.P_avg_storage_neg_h(:,%SURFID%)';  

    1,'BUILDING_ROOF:Surface Outside Face Convection Heat Gain Rate [W](Hourly)','donnees.surface.P_conv_ext_h(:,%SURFID%)';
	1,'BUILDING_ROOF:Surface Outside Face Incident Solar Radiation Rate per Area [W/m2](Hourly)','donnees.surface.Ps_rad_solar_inc_ext_h(:,%SURFID%)';  
	1,'BUILDING_ROOF:Surface Outside Face Solar Radiation Heat Gain Rate [W](Hourly)','donnees.surface.P_rad_solar_abs_ext_h(:,%SURFID%)';  
	1,'BUILDING_ROOF:Surface Outside Face Net Thermal Radiation Heat Gain Rate [W](Hourly)','donnees.surface.P_rad_therm_ext_h(:,%SURFID%)';  

    1,'%SURFACE%:Surface Inside Face Temperature [C](Hourly)','donnees.surface.T_surf_int(:,%SURFID%)';
	1,'%SURFACE%:Surface Outside Face Temperature [C](Hourly)','donnees.surface.T_surf_out(:,%SURFID%)';
   -1,'%OPAQUE%:HAMT Surface Inside Face Relative Humidity [%](Hourly)','donnees.surface.HR_surf_int(:,%SURFID%)';
   -1,'%OPAQUE%:EMPD Surface Inside Face Relative Humidity [%](Hourly)','donnees.surface.HR_surf_int(:,%SURFID%)';


    % Bilan sur l'air
   -1,'%ZONE%:Zone Air Heat Balance Internal Convective Heat Gain Rate [W](Daily)','donnees.zone.P_int(:,%ZONEID%)';
   -1,'%ZONE%:Zone Air Heat Balance Surface Convection Rate [W](Daily)','donnees.zone.P_surf(:,%ZONEID%)';
   -1,'%ZONE%:Zone Air Heat Balance Outdoor Air Transfer Rate [W](Daily)','donnees.zone.P_out(:,%ZONEID%)';
   -1,'%ZONE%:Zone Air Heat Balance System Air Transfer Rate [W](Daily)','donnees.zone.P_sys_air(:,%ZONEID%)';
   -1,'%ZONE%:Zone Air Heat Balance System Convective Heat Gain Rate [W](Daily)','donnees.zone.P_sys_conv(:,%ZONEID%)';

   -1,'%ZONE%:Zone Operative Temperature [C](Hourly)','donnees.zone.T_operative(:,%ZONEID%)';
    1,'%ZONE%:Zone Air Temperature [C](Hourly)','donnees.zone.T_int(:,%ZONEID%)';
    1,'%ZONE%:Zone Air Relative Humidity [%](Hourly)','donnees.zone.RH_int(:,%ZONEID%)';


    % Consomations Electriques
   -1,'Whole Building:Facility Total Purchased Electric Energy [J](Hourly)','donnees.E_elec_tot';
   -1,'RESISTANCE:Heating Coil Electric Power [W](Hourly)','donnees.E_elec_sys';

    % System
   -1,'%ZONE%:Zone Air System Sensible Heating Energy [J](Daily)','donnees.zone.E_heat(:,%ZONEID%)';
   -1,'%ZONE%:Zone Air System Sensible Cooling Energy [J](Daily)','donnees.zone.E_cool(:,%ZONEID%)';
    
   -1,'%ZONE% PTAC:Zone Packaged Terminal Air Conditioner Sensible Cooling Rate [W](Hourly)','donnees.zone.E_coolSensible(:,%ZONEID%)';
   -1,'%ZONE% PTAC:Zone Packaged Terminal Air Conditioner Latent Cooling Rate [W](Hourly)','donnees.zone.E_coolLatent(:,%ZONEID%)';
   -1,'%ZONE% PTAC:Zone Packaged Terminal Air Conditioner Total Cooling Rate [W](Hourly)','donnees.zone.E_coolTotal(:,%ZONEID%)';
   %OR !!!
    1,'%ZONE% IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Sensible Heating Rate [W](Hourly)','donnees.zone.E_heatSensible(:,%ZONEID%)';
    1,'%ZONE% IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Latent Heating Rate [W](Hourly)','donnees.zone.E_heatLatent(:,%ZONEID%)';
    1,'%ZONE% IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Total Heating Rate [W](Hourly)','donnees.zone.E_heatTotal(:,%ZONEID%)';
    1,'%ZONE% IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Sensible Cooling Rate [W](Hourly)','donnees.zone.E_coolSensible(:,%ZONEID%)';
    1,'%ZONE% IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Latent Cooling Rate [W](Hourly)','donnees.zone.E_coolLatent(:,%ZONEID%)';
    1,'%ZONE% IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Total Cooling Rate [W](Hourly)','donnees.zone.E_coolTotal(:,%ZONEID%)';
     
    % Transfert des fenêtres ext (Flux total (cond + ray) trasmit dans la zone par fenetre) 
   -1,'%WINDOW%:Surface Window Heat Gain Energy [J](Daily)','donnees.surface.E_win_gain(:,%SURFID%)';
   -1,'%WINDOW%:Surface Window Heat Loss Energy [J](Daily)','donnees.surface.E_win_loss(:,%SURFID%)'; 
    % part rayonnement (informatif)
   -1,'%WINDOW%:Surface Window Transmitted Solar Radiation Energy [J](Daily)','donnees.surface.E_win_ray(:,%SURFID%)'; 
    };



% Nom des differents fichiers/répertoires
local.noms.data = 'simul_';
local.noms.result= 'resultats_';
local.noms.simul = 'simulations_';
local.noms.image = 'images';
local.noms.save = 'analyse.mat';
local.noms.toolsPath = 'Toolbox';

% Paramètres d'affichage
affichage.largeur=100;      % Largeur de la fenetre de commande
