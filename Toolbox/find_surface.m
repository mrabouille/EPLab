function [varargout]=find_surface(file,sorties)
%FIND_SURFACE Identification des surfaces à partir du fichier *.eio
%spécifié et modification des sorties demandées.
% 
% Rq: Le fichier idf devant avoir la clef : Output:Surfaces:List, Details;
%
%
%     file          : chemin complet du fichier eio
%     sorties       : variable de description des sorties demandées
% 
%     geometrie     : description des éléments des zones étudiées
%     sorties       : variable de description mise à jours avec les noms 
%                     des surfaces
% 
% 
% Composition des variables:
%
% geometrie.surfaces = {Id_zone, Id, Id_Parent, Nom, Type, Nom(Var),
%                       Orientation,Cond. Ext., Surf, Surface gross}
%     Pour les murs     :
%               Surf = surface de la parois net
%               Surface gross = surface brute avec fenetre(s) et porte(s)
%     Pour les vitrages :
%               Surf = surface vitrée
%               Surface gross = surface brute avec frame(s) et diviseur(s)
%
% geometrie.zones =    {Id_zone, Nom_zone, Nom(Var), Volume, Floor Area,
%                       Exterior Gross Wall Area, Exterior Window Area, 
%                       Nbs_Surfaces+SubSurfaces }
%      
%
% sorties =           { Variable_E+, Variable_locale, Echantillonnage; }
%       Variable_E+     : variable de sortie E+ avec un terme générique pour les noms            
%               %ZONE%      toutes les zones
%               %ZONECONF%  zones d'étude du PMV
%               %ZONEFAN%   zones ventillées mécaniquement
%               %SURFACE%   toutes les surfaces
%               %FENETRE%   les surface vitrées
%               %OPAQUE%    les autres surfaces non vitées
%       Variable locale : Nom de la variable locale de la sortie dans Matlab
% 
% Rq: Les noms génériques(ex: %ZONE%) sont mis à jours avec les vrais noms 
% définit dans la variable 'geometrie'. 
%
% Créé par Mickael Rabouille
%   23/05/2013  Last Change


%{
A FAIRE:

J'ai remplacé rapidement la fonction strread par textscan
et adapté la sortie avec A = A{1};
Il est peut etre plus interessant d'utiliser textscan pour scaner le
fichier complet (pas sur)...

Séparer les surfaces interieures des surfaces en contact avec l'exterieur
%}

% if (nargin < 2)
%     error('myApp:argChk', 'Wrong number of input arguments')
% else
%     force=logical(nargin==2);
%     %s'il n'y a pas de zones définies on force toutes les zones.
% end
global simulation

switch simulation.version
    case '6'
        test.conf=14;
        test.surfaces=25;
    case {'8','8.1','8.2'}   
        test.conf=[16,23]; % without or whith comfort model
        test.surfaces=27;
    case {'8.3'} 
        test.surfaces=27;
    otherwise
        error('Version non configurée')
end

nbs_param_surface = 10;  % nombre de colonnes des variables surfaces
geometrie.surfaces = cell(0,nbs_param_surface);
geometrie.zones = cell(0,8); % nombre de colonnes de la variable zone (4)

id_zone = 1;
id_surf = 1;

fid=fopen(file,'r');
ligne  = fgets(fid);

niveau = 0;
geometrie.fanzones=[];
geometrie.infiltzones=[];

while ischar(ligne)

    % Recherche des protection solaires ? [A FAIRE ?]
    % 'Shading_Surfaces'
    
    
    % Recherche les infos générales des zones
    if niveau<1 && ~isempty(strfind(ligne,' Zone Information,'))
        A = textscan(ligne(20:end),'%s', 'delimiter',',');
        A = A{1};
        if (size(A,1)~=29), error('Une mise à jour a dû changer le nombre de variables.'); end
% Détails de la variable A
%{
1	Zone Name
2	North Axis {deg}
3,4,5	Origin X,Y,Z-Coordinate {m}
6,7,8	Centroid X,Y,Z-Coordinate {m}
9	Type
10	Zone Multiplier
11	Zone List Multiplier
12,13	Minimum/Maximum X {m}
14,15	Minimum/Maximum Y {m}
16,17	Minimum/Maximum Z {m}
18	Ceiling Height {m}
19	Volume {m3}
20	Zone Inside Convection Algorithm {Simple-Detailed-CeilingDiffuser-TrombeWall}
21	Zone Outside Convection Algorithm {Simple-Detailed-Tarp-MoWitt-DOE-2-BLAST}
22	Floor Area {m2}
23	Exterior Gross Wall Area {m2}
24	Exterior Net Wall Area {m2}
25	Exterior Window Area {m2}
26	Number of Surfaces
27	Number of SubSurfaces
28	Number of Shading SubSurfaces
29	Part of Total Building Area
%}

        % Id de la zone, Nom de la zone, Nom de la variable, Volume, Floor Area, Exterior Gross Wall Area, Exterior Window Area, Nombres de surfaces+SubSurfaces
        geometrie.zones(id_zone,:) = [id_zone A(1) genvarname(A(1)) str2double(A(19)) str2double(A(22)) str2double(A(23)) str2double(A(25)) str2double(A(26))+str2double(A(27))];
        id_zone=id_zone+1;    

        ligne  = fgets(fid);
        continue
    end


    % Recherche les zones de confort
    if niveau<2 && ~isempty(strfind(ligne,' People Internal Gains,'))
        niveau=1;
        A = textscan(ligne(25:end),'%s', 'delimiter',',');
        A = A{1};
        
        if (all(size(A,1)~=test.conf))
            disp(file)
            error('Une mise à jour de E+ à changer le nombre de variables. Les informations extraites doivent être vérifiées.');
        end
% Détails de la variable A (en v8)
%{
1	Name
2	Schedule Name
3	Zone Name
4	Zone Floor Area {m2}
5	# Zone Occupants
6	Number of People {}
7	People/Floor Area {person/m2}
8	Floor Area per person {m2/person}
9	Fraction Radiant
10	Fraction Convected
11	Sensible Fraction Calculation
12	Activity level
13	ASHRAE 55 Warnings
14	Carbon Dioxide Generation Rate
15	Nominal Minimum Number of People
16	Nominal Maximum Number of People
17	MRT Calculation Type
---only if comfort model---
18	Work Efficiency
19	Clothing
20	Air Velocity
21	Fanger Calculation
22	Pierce Calculation
23	KSU Calculation
%}

        % Recherche la zone concernée
        rech = find(strcmp(geometrie.zones(:,2),A{3}));
        if isempty(rech), error('La zone décrite pour de confort n''a pas été trouvée !'); end
        id_zone =geometrie.zones{rech,1};

        switch simulation.version
            case '6'
                % Id de la zone, Schedule Name, Fanger Calculation=0, Pierce Calculation=0, KSU Calculation=0
                geometrie.confzones(id_zone,:) = [id_zone A(1) 0 0 0];
            case {'8','8.1','8.2'}
                % Id de la zone, Schedule Name, Fanger Calculation, Pierce Calculation, KSU Calculation
                if size(A,1)==test.conf(1)
                    geometrie.confzones(id_zone,:) = [id_zone A(1) num2cell(zeros(1,3))];
                elseif size(A,1)==test.conf(2)
                    geometrie.confzones(id_zone,:) = [id_zone A(1) num2cell(strcmp(A(21:23),'Yes'))'];
                else
                    error('Problème')
                end
            otherwise
                error('Version non configurée')
        end
        
        ligne  = fgets(fid);
        continue        
    end

    if niveau>1 && ~isfield(geometrie,'confzones')
        if size(geometrie.zones,1)==1
            geometrie.confzones = num2cell([geometrie.zones{1,1} zeros(1,4)]);
            
        else
            maxi=0;  for m=geometrie.zones(:,2)', maxi = max(maxi,length(m{:}));  end
            [selection,ok] = listdlg('Name', 'Zones d''étude',...
                                    'PromptString','Choix des zone à étudier :',...
                                    'SelectionMode','multiple',...
                                    'ListString',geometrie.zones(:,2),...
                                    'ListSize', [8*maxi+20 15*(length(geometrie.zones(:,2))+1)]);
             if ok==0
                 error('Arrêt par l''utilisateur.')
             end
             geometrie.confzones = num2cell([selection' zeros(length(selection),4)]);
             clear maxi m ok selection
        end
    end
    
    % Recherche les zones d'éclairement
    if niveau<3 && ~isempty(strfind(ligne,'Daylighting:Illuminance Maps:Detail,'))
        niveau=2;
        A = textscan(ligne(37:end),'%s', 'delimiter',',');
        A = A{1};
        if (size(A,1)~=11), error('Une mise à jour a dû changer le nombre de variables.'); end
% Détails de la variable A
%{
1	Name
2	Zone
3	XMin {m}
4	XMax {m}
5	Xinc {m}
6	#X Points
7	YMin {m}
8	YMax {m}
9	Yinc {m}
10	#Y Points
11	Z {m}
%}

        % Recherche et enregistrement de la zone concernée
        rech = find(strcmp(geometrie.zones(:,2),A{2}));
        if isempty(rech), error('La zone décrite pour l''éclairement n''a pas été trouvée !'); end
        id_zone = geometrie.zones{rech,1};

        % Id de la zone, Name, #X Points, #Y Points
        geometrie.lightzones(id_zone,:) = [id_zone A(1) str2double(A(6)) str2double(A(10))];

        ligne  = fgets(fid);
        continue
    end

    
        % Recherche les zones d'infiltrations
    if niveau<4 && ~isempty(strfind(ligne,' ZoneInfiltration Airflow Stats,'))
        niveau=3;
        A = textscan(ligne(34:end),'%s', 'delimiter',',');
        A = A{1};
        if (size(A,1)~=13), error('Une mise à jour a dû changer le nombre de variables.'); end
% Détails de la variable A
%{
1	Name
2	Schedule Name
3	Zone Name
4	Zone Floor Area {m2}
5	# Zone Occupants
6	Design Volume Flow Rate {m3/s}
7	Volume Flow Rate/Floor Area {m3/s/m2}
8	Volume Flow Rate/Exterior Surface Area {m3/s/m2}
9	ACH - Air Changes per Hour
10	Equation A - Constant Term Coefficient {}
11	Equation B - Temperature Term Coefficient {1/C}
12	Equation C - Velocity Term Coefficient {s/m}
13	Equation D - Velocity Squared Term Coefficient {s2/m2}
%}

        % Recherche et enregistrement de la zone concernée
        rech = find(strcmp(geometrie.zones(:,2),A{3}));
        if isempty(rech), error('La zone décrite pour la ventilation n''a pas été trouvée !'); end
        geometrie.infiltzones = [geometrie.infiltzones; geometrie.zones{rech,1}];

        ligne  = fgets(fid);
        continue
    end
    
    
    

    % Recherche les zones ventilées
    if niveau<5 && ~isempty(strfind(ligne,' ZoneVentilation Airflow Stats,'))
        niveau=4;
        A = textscan(ligne(33:end),'%s', 'delimiter',',');
        A = A{1};
        if (size(A,1)~=22), error('Une mise à jour a dû changer le nombre de variables.'); end
% Détails de la variable A
%{
1	Name
2	Schedule Name
3	Zone Name
4	Zone Floor Area {m2}
5	# Zone Occupants
6	Design Volume Flow Rate {m3/s}
7	Volume Flow Rate/Floor Area {m3/s/m2}
8	Volume Flow Rate/person Area {m3/s/person}
9	ACH - Air Changes per Hour
10	Fan Type {Exhaust;Intake;Natural}
11	Fan Pressure Rise {Pa}
12	Fan Efficiency {}
13	Equation A - Constant Term Coefficient {}
14	Equation B - Temperature Term Coefficient {1/C}
15	Equation C - Velocity Term Coefficient {s/m}
16	 Equation D - Velocity Squared Term Coefficient {s2/m2}
17	Minimum Indoor Temperature{C}/Schedule
18	Maximum Indoor Temperature{C}/Schedule
19	Delta Temperature{C}/Schedule
20	Minimum Outdoor Temperature{C}/Schedule
21	Maximum Outdoor Temperature{C}/Schedule
22	Maximum WindSpeed{m/s}
%}

        % Recherche et enregistrement de la zone concernée
        rech = find(strcmp(geometrie.zones(:,2),A{3}));
        if isempty(rech), error('La zone décrite pour la ventilation n''a pas été trouvée !'); end
        geometrie.fanzones = [geometrie.fanzones; geometrie.zones{rech,1}];

        ligne  = fgets(fid);
        continue
    end
    
    
    % Recherche les details des surfaces
    if isempty(strfind(ligne,'Zone_Surfaces'))
        ligne  = fgets(fid);
        continue
    else
        A = textscan(ligne(15:end),'%s', 'delimiter',',');
        A = A{1};
        if (size(A,1)~=2), error('Une mise à jour a dû changer le nombre de variables.'); end

        % Recherche la zone concernée
        rech = find(strcmp(geometrie.zones(:,2),A{1}));
        
        
        if isfield(geometrie,'confzones')
            % Ne prend en compte que les zones ou une théorie sur le confort est
            % présente et zappe les autre !
            
            % (sauf si aucune zone de conf n'est presente)     
            
            if isempty(rech) || ~any(cell2mat(geometrie.confzones(:,1))==rech)
                % La zone n'est pas etudiée pas le modèle de confort
                ligne=fgets(fid);
                continue;
            end
        end
      
    
        id_zone =geometrie.zones{rech,1};
 
        % Création de la variable surface        
        geometrie.surfaces = cat (1, geometrie.surfaces, cell(geometrie.zones{id_zone,8}, nbs_param_surface) );
        
        % Recherche des surfaces (murs fenetre porte plancher toiture)
        ligne  = fgets(fid);
        for i=1:geometrie.zones{id_zone,8}
            A = textscan(ligne,'%s', 'delimiter',',');
            A = A{1};
            if (length(A)~=test.surfaces), error('Une mise à jour a dû changer le nombre de variables.'); end
            if version==6
                A(10:27)=A(8:25);
                A(6:8)=A(5:7);
            end
% Détails de la variable A
%{
1	! <HeatTransfer/Shading/Frame/Divider_Surface>
2	Surface Name
3	Surface Class
4	Base Surface
5	Heat Transfer Algorithm
6	Construction/Transmittance Schedule
7	Nominal U (w/o film coefs)/Min Schedule Value
8	Nominal U (with film coefs)/Max Schedule Value
9	Solar Diffusing

pour les murs :
10	Area (Net) :  Sunlit Calc moins les cadres ext des fenetres
11	Area (Gross) : surface brute entrée dans E+
12	Area (Sunlit Calc) : surface brute moins les sous surfaces

pour les fenetre :
10	Area (Net) : surface brute du vitrage
11	Area (Gross) : surface brute entrée dans E+ (vitre + diviseurs)
12	Area (Sunlit Calc) = Area (Gross)
            
pour les frames
10	Area (Net) : surface brute entrée dans E+
11	Area (Gross) : surface brute entrée dans E+
12	Area (Sunlit Calc) = *
  
13	Azimuth(Orientation)
14	Tilt(Inclinaison)
15	~Width
16	~Height
17	Reveal
18	<ExtBoundCondition>
19	<ExtConvCoeffCalc>
20	<IntConvCoeffCalc>
21	<SunExposure>
22	<WindExposure>
23	ViewFactorToGround
24	ViewFactorToSky
25	ViewFactorToGround-IR
26	ViewFactorToSky-IR
27	#Sides

%}


            if strcmpi (A(3), 'Window')
                id_parent = id_mur;                
                surface = str2double(A(10));      %surface net
                surface_tot = str2double(A(10));  %surface net à laquelle on va ajouter les frames
                ligne  = fgets(fid);
                
                B = textscan(ligne,'%s', 'delimiter',',');
                B = B{1};
                while strcmpi (B(3), 'Frame') || strcmpi (B(3), 'Divider:DividedLite')
                    surface_tot = surface_tot + str2double(B(10));
                    ligne  = fgets(fid);
                    B = textscan(ligne,'%s', 'delimiter',',');
                    B = B{1};
                end
            elseif strcmpi (A(3), 'Door')
                id_parent = id_mur;
                surface = str2double(A(10));      %surface net
                surface_tot = str2double(A(10));  %surface net
                ligne  = fgets(fid);
            else
                id_mur = id_surf;
                id_parent = 0;
                surface = str2double(A(10));      %surface net
                surface_tot = str2double(A(11)); %gross
                ligne  = fgets(fid);
            end
            % id_zone, id_surf, id_parent, Surface Name, Surface Class,  Surface varname, Azimuth(Orientation), ExtBoundCondition, surface, surface_tot];
            geometrie.surfaces(id_surf, :)= [id_zone id_surf id_parent A(2:3)' genvarname(A(2)) A(13) A(18) surface surface_tot];
            id_surf = id_surf+1;
            
        end

    end
end


fclose(fid);
clear fid
clear ligne



% Recherche des surfaces extérieures
geometrie.ext=false(id_surf-1,1);
for i=1:id_surf-1
    % contact direct avec l'exterrieur
    if strcmpi(geometrie.surfaces(i,8),'ExternalEnvironment')
        geometrie.ext(i)=true;
    elseif strcmpi(geometrie.surfaces(i,8),'Ground')
        geometrie.ext(i)=true;
    else
        rech = strmatch(geometrie.surfaces{i,8},geometrie.surfaces(:,4));
        % contact avec une zone non étudié (pas de modèle de confort)    
        if isnumeric(rech)
            geometrie.ext(rech)=true;
        end
    end
end

% Verification: zone chauffée = zone ventillée
%NON

% Types
geometrie.floor = strcmp(geometrie.surfaces(:,5), 'Floor');
geometrie.roof = strcmp(geometrie.surfaces(:,5), 'Roof');

geometrie.window = strcmp(geometrie.surfaces(:,5), 'Window');
geometrie.opaque = ~strcmp(geometrie.surfaces(:,5), 'Window');
geometrie.wall = strcmp(geometrie.surfaces(:,5), 'Wall');
geometrie.door = strcmp(geometrie.surfaces(:,5), 'Door');

% Orientation
verticaux = ~or(geometrie.roof,geometrie.floor);
angles = str2double(geometrie.surfaces(:,7));

geometrie.nord = verticaux & or(angles<=45,angles>=315);
geometrie.est = verticaux & and(angles>45,angles<135);
geometrie.sud = verticaux & and(angles>=135,angles<=225);
geometrie.ouest =  verticaux & and(angles>225,angles<315);

varargout{1} = geometrie;

% Effacement des sorties innutiles
for k=size(sorties,1):-1:1
    if sorties{k,1}==-1
        sorties(k,:)=[];
    end
end

% Modification de la matrice sorties: Intégration du nom des surfaces
for  i=sort(find(strncmp(sorties(:,2), '%ZONE%', 6)), 'descend')'
    for j=geometrie.zones'
        s1 = regexprep(sorties(i,2), '%ZONE%', j{2});
        s2 = regexprep(sorties(i,3), '%ZONEID%', num2str(j{1}));
        s2 = regexprep(s2, '%ZONE%', j{3});
        sorties(end+1,:) = [sorties(i,1) s1 s2]; %#ok<AGROW>
    end
    sorties(i,:) = [];
end

for  i=sort(find(strncmp(sorties(:,2), '%ZONECONF%', 6)), 'descend')'
    for j=geometrie.confzones'
        if isempty(j{1}), continue, end
        s1 = regexprep(sorties(i,2), '%ZONECONF%', j{2});
        s2 = regexprep(sorties(i,3), '%ZONEID%', num2str(j{1}));
        s2 = regexprep(s2, '%ZONE%', geometrie.zones{j{1},3});
        sorties(end+1,:) = [sorties(i,1) s1 s2]; %#ok<AGROW>
    end
    sorties(i,:) = [];
end

for  i=sort(find(strncmp(sorties(:,2), '%ZONEINF%', 6)), 'descend')'
    for j=geometrie.infiltzones'
        s1 = regexprep(sorties(i,2), '%ZONEINF%', geometrie.zones{j,2});
        s2 = regexprep(sorties(i,3), '%ZONEID%', num2str(j));
        s2 = regexprep(s2, '%ZONE%', geometrie.zones{j,3});
        sorties(end+1,:) = [sorties(i,1) s1 s2]; %#ok<AGROW>
    end
    sorties(i,:) = [];
end

for  i=sort(find(strncmp(sorties(:,2), '%ZONEFAN%', 6)), 'descend')'
    for j=geometrie.fanzones'
        s1 = regexprep(sorties(i,2), '%ZONEFAN%', geometrie.zones{j,2});
        s2 = regexprep(sorties(i,3), '%ZONEID%', num2str(j));
        s2 = regexprep(s2, '%ZONE%', geometrie.zones{j,3});
        sorties(end+1,:) = [sorties(i,1) s1 s2]; %#ok<AGROW>
    end
    sorties(i,:) = [];
end

for  i=sort(find(strncmp(sorties(:,2), '%SURFACE%', 9)), 'descend')'
    for j=geometrie.surfaces'
        s1 = regexprep(sorties(i,2), '%SURFACE%', j{4});
        s2 = regexprep(sorties(i,3), '%SURFID%', num2str(j{2}));            
        s2 = regexprep(s2, '%SURFACE%', j{6});
        sorties(end+1,:) = [sorties(i,1) s1 s2]; %#ok<AGROW>
    end
    sorties(i,:) = [];
end

for  i=sort(find(strncmp(sorties(:,2), '%OPAQUE%', 8)), 'descend')'
    for j=geometrie.surfaces(geometrie.opaque,:)'
        s1 = regexprep(sorties(i,2), '%OPAQUE%', j{4});
        s2 = regexprep(sorties(i,3), '%SURFID%', num2str(j{2}));   
        s2 = regexprep(s2, '%OPAQUE%', j{6});
        sorties(end+1,:) = [sorties(i,1) s1 s2];
    end
    sorties(i,:) = [];
end

for  i=sort(find(strncmp(sorties(:,2), '%WINDOW%', 8)), 'descend')'
    for j=geometrie.surfaces(geometrie.window,:)'
        s1 = regexprep(sorties(i,2), '%WINDOW%', j{4});
        s2 = regexprep(sorties(i,3), '%SURFID%', num2str(j{2}));   
        s2 = regexprep(s2, '%WINDOW%', j{6});
        sorties(end+1,:) = [sorties(i,1) s1 s2];
    end
end

for  i=sort(find(~cellfun(@isempty,strfind(sorties(:,3), '%SURFID%'))), 'descend')'
    s2 = regexprep(sorties(i,3), '%SURFID%', num2str( geometrie.surfaces{ strcmp(strtok(sorties(i,2),':'),geometrie.surfaces(:,4)), 2} ));
    sorties(end+1,:) = [sorties(i,1:2) s2];
    sorties(i,:) = [];
end

varargout{2}=sorties;

