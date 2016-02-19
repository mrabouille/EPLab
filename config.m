% Protection
local.date = now;
%% Paramètres de simulation

% Paramètres généraux de simulation
local.noms.etude = 'maketdeux_4';
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
simulation.IDF_initial = 'maquete_2_simples';

% Repertoire d'instalation EnergyPlus (!! finir avec un '\' !!)
Ep_dir = {'D:\EnergyPlusV8-1-0\',
          'C:\EnergyPlusV8-1-0\'};
% Les modifications appostées par Lais   
Domus_dir = {'D:\Domus - Eletrobras\',
             'C:\Domus - Eletrobras\'};

% Configuration de l'échantillonnage et de l'analyse (voir: commun_analyse() )
params.nb_tir=200;     % 300(2) -> 7h30

params.type_ech=4;      % 1:random_global 3:RBD_global 4:LHS-local 5:LHS_global 6:Halton_local 7:Halton_global 8:LPTau_local  9:LPTau_global
params.type_plan_LHS=1;     % 0:sans 1:minimean10 2:minimax10

local.recap_plan = true;    % compare les variations initiales au variations du plan 

analyse.type_etude=3;  % 0 rien / 2 PC / 3 RBD  /  5 sobol

analyse.bootstrap = false;
analyse.bootstrap_param.ech = params.nb_tir;
analyse.bootstrap_param.rep = 1000;
analyse.bootstrap_param.save = true;

%analyse.RDB.force=false;    % outrepasse les vérifications de l'analyses
analyse.RDB.harmonics=10;


resultat.extract_lum=false;

resultat.plage(1).nom = 'day';
% resultat.plage(1).debut = '21/03';
% resultat.plage(1).fin = '21/03';
resultat.plage(1).temporel = true;
% 
% resultat.plage(2).nom = 'Annual';
% resultat.plage(2).debut = '01/01';
% resultat.plage(2).fin = '31/12';


% resultat.plage(1).nom = 'Summer week';
% resultat.plage(1).debut = '07/06';
% resultat.plage(1).fin = '10/06'; %14
% resultat.plage(1).temporel = true;
% 
% resultat.plage(2).nom = 'Winter week';
% resultat.plage(2).debut = '29/12'; %24
% resultat.plage(2).fin = '31/12';
% 
% resultat.plage(3).nom = 'Annual';
% resultat.plage(3).debut = '01/01';
% resultat.plage(3).fin = '31/12';


% Configuration statistique des entrées météo
% fichier 'unique' / multiples 'liste' / personalisé: 'plan' / appel module: 'module'           
params.EPW_type = 'module';
params.EPW.copie = true;

%USA_NY_New.York-LaGuardia.AP.725030_TMY3
%USA_FL_Miami-Opa.Locka.AP.722024_TMY3
%USA_AK_Anchorage.702730_TMY2
%ECU_Quito.840710_IWEC
%PR_Curitiba

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
       %simulation.EPW.name = {'ECU_Quito.840710_IWEC'};
       % simulation.EPW.name = {'USA_FL_Miami-Opa.Locka.AP.722024_TMY3'};
       %simulation.EPW.name = {'USA_AK_Anchorage.702730_TMY2'};
       % simulation.EPW.name = {'USA_NY_New.York-LaGuardia.AP.725030_TMY3'};
        simulation.EPW.name = {'PR_Curitiba'};
        simulation.EPW.path = 'D:\Users\almeida.paula\Desktop\maquetdeux';%pwd;  ou C:\Users\Jeanne\Dropbox\Ana_Lea_Jeanne\Version_17
        params.EPW.copie = false;
        % A définir:
        % simulation.EPW.path, simulation.EPW.name, simulation.EPW.plan, simulation.EPW.index
end


% Configuration statistique des variables d'entrées
%                 type(var:1/param:0/off:-1), nom, loi(R=en relatif), [moyenne écrat]/val_par_def, [min max]/{'txt1' 'txt2'} 
params.variables.infos = cell2struct(sortrows({ 
    % variable simple : 3
        1, 'orientation', 'Uniform', [0 5], []; %valeur {deg}  % attention hemisphere nord ; 90 --> EST; 180--> SUD; 270--> OUEST
 %QUITO
%         1, 'latitude', 'Uniform', [-0.15 1], []; % valeur {deg}
%         1, 'longitude','Uniform', [-78.48 1], [];  %valeur {deg}
%         1, 'altitude','Uniform', [2812 30], []; %valeur {m}
        
 %MIAMI
%         1, 'latitude', 'Uniform', [25.90 1], []; % valeur {deg}
%         1, 'longitude','Uniform', [-80.28 1], [];  %valeur {deg}
%         1, 'altitude','Uniform', [35 30], []; %valeur {m}
%         
 %ANCHORAGE
%        1, 'latitude', 'Uniform', [61.17 1], []; % valeur {deg}
%        1, 'longitude','Uniform', [-150.02 2], [];  %valeur {deg}
%        1, 'altitude','Uniform', [35 30], []; %valeur {m}
%
 %NEW YORK        
%         1, 'latitude', 'Uniform', [40.78 1], []; % valeur {deg}
%         1, 'longitude','Uniform', [-73.88 1], [];  %valeur {deg}
%         1, 'altitude','Uniform', [35 30], []; %valeur {m}
%         
 %CURITIBA        
        1, 'latitude', 'Uniform', [-25.43 1], []; % valeur {deg}
        1, 'longitude','Uniform', [-49.2 1], [];  %valeur {deg}
        1, 'altitude','Uniform', [935 30], []; %valeur {m}
    % variable geometrie : 4
        1, 'masquehauteur','Uniform', [0 0.05], []; % valeur {m} 
        1, 'masquelargeur','Uniform', [0 0.005], []; % valeur {m} 
    % variable modele
        0, 'timestep', 'Discret', 4, {'1','2','3','4','5','6','7','8','9','10','11','12'};	
%        0,'heure','Discret',1,{'-3','-5','-9'}; % Quito, MIami, NY : 2 : -5; curitiba :-3; anchorage : -9;
        
        %variable geometrie : 4 a definir
        
    
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
         'orientation', 'orientation', 'orientation',' [Degré]'; 
        'latitude', 'latitude', 'latitude',' [Degré]'; 
        'longitude', 'longitude', 'longitude',' [Degré]'; 
        'altitude', 'altitude', 'altitude',' [m]'; 
         
         'masquehauteur','masquehauteur','masquehauteur','[m]';
         'masquelargeur','masquelargeur','masquelargeur','[m]';
         'timestep','timestep','timestep','[-]';
         'heure','heure','heure','[h]';
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
    % surface ombragée
    0,'%SURFACE%:Surface Outside Face Sunlit Area [m2](TimeStep)', 'donnees.surface.sunlit_area(:,%SURFID%)';
    0,'%SURFACE%:Surface Outside Face Sunlit Fraction [](TimeStep)', 'donnees.surface.sunlit_fraction(:,%SURFID%)';
    
    % temperature surface
    1,'%SURFACE%:Surface Inside Face Temperature [C](TimeStep)', 'donnees.surface.T_inside(:,%SURFID%)';
    1,'%SURFACE%:Surface Outside Face Temperature [C](TimeStep)', 'donnees.surface.T_outside(:,%SURFID%)';
    
    % quantité soleil
    0,'%SURFACE%:Surface Outside Face Incident Beam Solar Radiation Rate per Area [W/m2](TimeStep)', 'donnees.surface.Beam_radiation_area(:,%SURFID%)';
    
    % temperature air interieur
    1,'%ZONE%:Zone Mean Air Temperature [C](TimeStep)', 'donnees.zone.T_air(:,%ZONEID%)'; 
    

    %     % Températures / Confort
%     1,'Environment:Site Outdoor Air Drybulb Temperature [C](Daily)','donnees.simple.T_ext';
% 
% 	1,'%SURFACE%:Surface Inside Face Temperature [C](Hourly)','donnees.surface.T_surf_int(:,%SURFID%)';
%     0,'%OPAQUE%:HAMT Surface Inside Face Relative Humidity [%](Hourly)','donnees.surface.HR_surf_int(:,%SURFID%)';
%     0,'%OPAQUE%:EMPD Surface Inside Face Relative Humidity [%](Hourly)','donnees.surface.HR_surf_int(:,%SURFID%)';
%     
%     0,'%OPAQUE%:Surface Inside Face Conduction Heat Gain Rate [W](Daily)','donnees.surface.E_cond_int_pos(:,%SURFID%)';  
%     1,'%OPAQUE%:Surface Inside Face Conduction Heat Loss Rate [W](Daily)','donnees.surface.E_cond_int_neg(:,%SURFID%)';  
%     1,'%OPAQUE%:Surface Outside Face Conduction Heat Gain Rate [W](Daily)','donnees.surface.E_cond_ext_pos(:,%SURFID%)';  
%     1,'%OPAQUE%:Surface Outside Face Conduction Heat Loss Rate [W](Daily)','donnees.surface.E_cond_ext_neg(:,%SURFID%)';  
%     
%     1,'%ZONE%:Zone Operative Temperature [C](Hourly)','donnees.zone.T_operative(:,%ZONEID%)';
%     1,'%ZONE%:Zone Mean Air Temperature [C](Hourly)','donnees.zone.T_int(:,%ZONEID%)';
%     1,'%ZONE%:Zone Air Relative Humidity [%](Hourly)','donnees.zone.RH_int(:,%ZONEID%)';
%     
%     % Bilan sur l'air
%     1,'%ZONE%:Zone Air Heat Balance Internal Convective Heat Gain Rate [W](Daily)','donnees.zone.P_int(:,%ZONEID%)';
%     1,'%ZONE%:Zone Air Heat Balance Surface Convection Rate [W](Daily)','donnees.zone.P_surf(:,%ZONEID%)';
%     1,'%ZONE%:Zone Air Heat Balance Outdoor Air Transfer Rate [W](Daily)','donnees.zone.P_out(:,%ZONEID%)';
%     1,'%ZONE%:Zone Air Heat Balance System Air Transfer Rate [W](Daily)','donnees.zone.P_sys_air(:,%ZONEID%)';
%     1,'%ZONE%:Zone Air Heat Balance System Convective Heat Gain Rate [W](Daily)','donnees.zone.P_sys_conv(:,%ZONEID%)';
%    
%     % Fan Electric Power [W]
%  %  'RESISTANCE:Heating Coil Electric Power [W](Hourly)','donnees.E_elec_sys';
%     1,'%ZONE%:Zone Air System Sensible Heating Energy [J](Daily)','donnees.zone.E_heat(:,%ZONEID%)';
%     1,'%ZONE%:Zone Air System Sensible Cooling Energy [J](Daily)','donnees.zone.E_cool(:,%ZONEID%)';
%     % Consomations Electriques
%     1,'Whole Building:Facility Total Purchased Electric Energy [J](Hourly)','donnees.E_elec_tot';
%      
%     % Transfert des parois (Flux convectif de l'air vers la face interieure) (!SIGNES et Versions!)
%    -1,'%SURFACE%:Surface Inside Face Convection Heat Gain Energy [J](Hourly)','donnees.surface.E_conv(:,%SURFID%)';  
%     % Transfert des fenêtres ext (Flux total (cond + ray) trasmit dans la zone par fenetre) 
%    -1,'%WINDOW%:Surface Window Heat Gain Energy [J](Daily)','donnees.surface.E_win_gain(:,%SURFID%)';
%    -1,'%WINDOW%:Surface Window Heat Loss Energy [J](Daily)','donnees.surface.E_win_loss(:,%SURFID%)'; 
%     % part rayonnement (informatif)
%    -1,'%WINDOW%:Surface Window Transmitted Solar Radiation Energy [J](Daily)','donnees.surface.E_win_ray(:,%SURFID%)'; 
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
