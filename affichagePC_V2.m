function varargout = affichagePC_V2(varargin)

% affichagePC_V2 MATLAB code for affichagePC_V2.fig
%      affichagePC_V2, by itself, creates a new affichagePC_V2 or raises the existing
%      singleton*.
%
%      H = affichagePC_V2 returns the handle to a new affichagePC_V2 or the handle to
%      the existing singleton*.
%
%      affichagePC_V2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in affichagePC_V2.M with the given input arguments.
%
%      affichagePC_V2('Property','Value',...) creates a new affichagePC_V2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before affichagePC_V2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to affichagePC_V2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help affichagePC_V2

% Last Modified by GUIDE v2.5 18-Mar-2013 12:52:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @affichagePC_V2_OpeningFcn, ...
                   'gui_OutputFcn',  @affichagePC_V2_OutputFcn, ...
                   'gui_LayoutFcn',  @affichagePC_V2_LayoutFcn, ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before affichagePC_V2 is made visible.
function affichagePC_V2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to affichagePC_V2 (see VARARGIN)

% Choose default command line output for affichagePC_V2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

buttongroup_SelectionChangeFcn(0,0,handles)
%actualisation(0,0,handles)

% UIWAIT makes affichagePC_V2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = affichagePC_V2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sliders_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global params

id = str2num(regexprep(get(hObject,'Tag'), 'slider', ''));

if strcmpi(params.variables.infos(params.variables.vars_index(id)).loi, 'Discret')
    valeur = round(get(hObject,'Value'));
    set(hObject,'Value',valeur)
%    valeur = params.variables.infos(params.variables.vars_index(id)).limites{valeur};
%    set(findobj('Tag',sprintf('valeur%d',id)),'String', valeur(max(end-5,1):end))
    set(findobj('Tag',sprintf('valeur%d',id)),'String', sprintf('%d',valeur))
else
    valeur_bar = get(hObject,'Value');
    valeur = valeur_bar*diff(params.variables.infos(params.variables.vars_index(id)).limites)+params.variables.infos(params.variables.vars_index(id)).limites(1);
    valeur = round(valeur*100)/100;
    valeur = min( max(valeur, params.variables.infos(params.variables.vars_index(id)).limites(1)) ,params.variables.infos(params.variables.vars_index(id)).limites(2));
    valeur_bar = (  valeur-params.variables.infos(params.variables.vars_index(id)).limites(1)  )/diff(params.variables.infos(params.variables.vars_index(id)).limites);
    
    set(findobj('Tag',sprintf('valeur%d',id)),'String', sprintf('%g',valeur))
    set(hObject,'Value',valeur_bar)
end
%actualisation(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function sliders_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox1.
function checkboxs_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
h_slider = findobj('Tag',regexprep(get(hObject,'Tag'), 'check', 'slider'));
h_valeur = findobj('Tag',regexprep(get(hObject,'Tag'), 'check', 'valeur'));

warning('ici')
%--> affichage du boutons si incertitude
h_button = findobj('Tag',regexprep(get(hObject,'Tag'), 'check', 'opt_incert'));


if get(hObject,'Value')
    etat = 'on';
else
    etat = 'off';
end
set(h_slider,'Visible', etat)
set(h_valeur,'Visible', etat)
set(h_button,'Visible', etat)

global params
id = str2num(regexprep(get(h_slider,'Tag'), 'slider', ''));
valeur = str2num(get(h_valeur,'String'));
if strcmpi(params.variables.infos(params.variables.vars_index(id)).loi, 'Discret')
    set(h_slider,'Value',round(valeur))
else
    valeur_bar = (  valeur-params.variables.infos(params.variables.vars_index(id)).limites(1)  )/diff(params.variables.infos(params.variables.vars_index(id)).limites);
    set(h_slider,'Value',valeur_bar)
end




%actualisation(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function axes_CreateFcn(hObject, ~, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1

% --- Executes on mouse press over axes background.
function axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global analyse
global resultat
id_sortie = str2double(regexp(get(hObject,'Tag'),'[0-9]+$','match'));
fprintf('sortie: S%d  -> ''%s''\n',id_sortie,analyse.legende{id_sortie})


if isfield(handles,'cfd_axe')    
    axes(handles.cfd_axe)
    cla
    cdfplot(get(get(hObject, 'Children'),'YData'))
end

%%%%%%%%%%%
%get(gca,'CurrentPoint')

% handle_l1 = line([50000 50000],[-200 400],'LineWidth',3,'Color','g', 'ButtonDownFcn', @(obj, evt) click_on_line(obj));
% setappdata(0,'handle_l1',handle_l1);
% handle_l2 = line([450000 450000],[-200 400],'LineWidth',3,'Color','g','ButtonDownFcn', @(obj, evt) click_on_line(obj));
% setappdata(0,'handle_l2',handle_l2);


function click_on_line(hObject)
% Change windows properties

set(ancestor(hObject, 'figure'), 'WindowButtonMotionFcn', @(obj, evt) move_line(hObject), 'WindowButtonUpFcn', @(obj, evt) release_line(obj));

function release_line(hObject)
% Change windows properties
set(hObject, 'WindowButtonMotionFcn', [], 'WindowButtonUpFcn', []);

function move_line(hObject)
% Get mouse pointer position
position = get(gca, 'CurrentPoint');
% Change line position
set(hObject, 'XData', [position(1), position(1)]);

% --- Executes when selected object changed in unitgroup.
function buttongroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

radiovalues = flipud(cell2mat(get(handles.radiobutton,'Value')));
id=find(radiovalues);
set(eval(sprintf('handles.check%d',id)),'Value', 0)
set(eval(sprintf('handles.slider%d',id)),'Visible', 'off' )
set(eval(sprintf('handles.valeur%d',id)),'Visible', 'off' )
% etat = {'on','off'};
% for k=1:length(radiovalues)
%         set(eval(sprintf('handles.slider%d',k)),'Visible', etat{radiovalues(k)+1} )
%         set(eval(sprintf('handles.valeur%d',k)),'Visible', etat{radiovalues(k)+1} )
% end


function toggle_incertitudes_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% identification des entrées imposées
h_check=flipud(findobj('-regexp','Tag','check'));
choix_fixe = logical(cell2mat(get(h_check,'Value')));
h_button=flipud(findobj('-regexp','Tag','opt_incert'));
if get(handles.incertitudes,'value')
    set(h_button(choix_fixe), 'Visible', 'on' );
else
    set(h_button, 'Visible', 'off' );
end






function toggle_analyse_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
types = {'RBD-FAST', 'RBD-SOBOL', 'Surf'};
num = find( strcmp(get(handles.type_analyse,'String'),types) )+1
if num>length(types), num =1; end

set(handles.type_analyse,'String', types{num})




% --- Creates and returns a handle to the GUI figure. 
function h1 = affichagePC_V2_LayoutFcn(policy)
% policy - create a new figure or use a singleton. 'new' or 'reuse'.

persistent hsingleton;
if strcmpi(policy, 'reuse') & ishandle(hsingleton)
    h1 = hsingleton;
    return;
end

global analyse
global resultat
global params
global legende

avis = 'No';
if ~isempty(analyse)
    avis = questdlg(sprintf('Lecture du fichier "%s" ?',params.titre), 'Chargement', 'Cancel');
end
if strcmp(avis,'No')
    uiopen('*analyse.mat')
elseif strcmp(avis,'Cancel')
    error('Arrêt par l''utilisateur.')
end

fprintf('Lecture du fichier "%s".\n',params.titre)

% Import des Toolbox
addpath(genpath(fullfile(pwd,'Toolbox')),'-begin')

maxi=0;  for m=legende.sorties_all(resultat.sorties_valide)', maxi = max(maxi,length(m{:}));  end
[selection,ok] = listdlg('Name', 'Sorties à étudier',...
                        'PromptString','Sélection des sorties :',...
                        'SelectionMode','multiple',...
                        'ListString',legende.sorties_all(resultat.sorties_valide),...
                        'InitialValue',[1:sum(resultat.sorties_valide)],...                        
                        'ListSize', [6*maxi 15*(length(legende.sorties_all(resultat.sorties_valide))+1)]);
clear maxi m
if ok==0
    error('Arrêt par l''utilisateur.')
end

resultat.sorties_valide_index = resultat.sorties_valide_index(selection);
resultat.sorties_valide(:)=false;
resultat.sorties_valide(resultat.sorties_valide_index)=true;

analyse.legende = legende.sorties_all(resultat.sorties_valide);

appdata = [];
appdata.GUIDEOptions = struct(...
    'active_h', [], ...
    'taginfo', struct(...
    'figure', 2, ...
    'radiobutton', 2, ...
    'slider', 2, ...
    'text', 4, ...
    'checkbox', 2, ...
    'activex', 2, ...
    'uipanel', 3), ...
    'override', 0, ...
    'release', 13, ...
    'resize', 'none', ...
    'accessibility', 'callback', ...
    'mfile', 1, ...
    'callbacks', 1, ...
    'singleton', 1, ...
    'syscolorfig', 1, ...
    'blocking', 0, ...
    'lastSavedFile', 'F:\Sauvegarde INES\Codes\MatLab\Perso\Version_12\affichagePC_V2.m', ...
    'lastFilename', 'F:\Sauvegarde INES\Codes\MatLab\Perso\Version_12\untitled1.fig');
appdata.lastValidTag = 'figure1';
appdata.GUIDELayoutEditor = [];
appdata.initTags = struct(...
    'handle', [], ...
    'tag', 'figure1');

h1 = figure(...
'Units','pixels',...
'PaperUnits',get(0,'defaultfigurePaperUnits'),...
'Color',[0.941176470588235 0.941176470588235 0.941176470588235],...
'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
'DockControls','off',...
'IntegerHandle','off',...
'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
'MenuBar','figure',... %none
'Name','affichagePC_V2',...
'NumberTitle','off',...
'PaperPosition',get(0,'defaultfigurePaperPosition'),...
'PaperSize',get(0,'defaultfigurePaperSize'),...
'PaperType',get(0,'defaultfigurePaperType'),...
'Resize','on',...
'HandleVisibility','callback',...
'UserData',[],...
'Tag','figure1',...
'Visible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

%%%%%%%%%%%%%%
% Taille de la fenetre
ecrans = get(0,'MonitorPositions');
ecrans = ecrans(end,:); %choix du dernier écran

bords = get(h1,'OuterPosition')-get(h1,'Position');
dim_fenetre = [ecrans(1:2) ecrans(3:4)-ecrans(1:2)]-bords;
set(h1,'Position',dim_fenetre);
%%%%%%%%%%%%%%%%%


appdata = [];
appdata.lastValidTag = 'uipanel1';

h2 = uibuttongroup(...
'Parent',h1,...
'Units','characters',...
'Title',{  'Variables' },...
'Tag','uipanel1',...
'Clipping','on',...
'SelectedObject',[],...
'SelectionChangeFcn',@(hObject,eventdata)affichagePC_V2('buttongroup_SelectionChangeFcn',get(hObject,'SelectedObject'),eventdata,guidata(get(hObject,'SelectedObject'))),...
'OldSelectedObject',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

marge_haut = 1.5;
marge_bas = 0.5;
inter_ligne = 0.5;
hauteur_ligne = 1;

curseur_depart = 2;
marge_fin = 2;
tabulation = 1;
tabulation2 = 0.5;
nb_ligne = params.variables.vars_nb;

saut_ligne = inter_ligne+hauteur_ligne;
hauteur_panel=marge_haut+marge_bas+(nb_ligne-1)*saut_ligne+hauteur_ligne*2;
prem_ligne = hauteur_panel-hauteur_ligne*2-marge_haut;


%max_long_name = size(char(legende.vars(:,2)),2);
for k=1:nb_ligne
    curseur=curseur_depart;
    
% Bouton + nom
    appdata = [];
    appdata.lastValidTag = 'radiobutton';
    largeur = 40;
    h21 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'Position',[curseur prem_ligne-(k-1)*saut_ligne curseur+largeur hauteur_ligne],...
    'String',legende.vars{k,2},...
    'Style','radiobutton',...
    'Tag','radiobutton',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );
    curseur = curseur+largeur+tabulation;
% Case à cocher
    appdata = [];
    appdata.lastValidTag = ['check' int2str(k)];
    largeur = 3;
    h22 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)affichagePC_V2('checkboxs_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[curseur prem_ligne-(k-1)*saut_ligne largeur hauteur_ligne],...
    'String',{  '' },...
    'Style','checkbox',...
    'Tag',['check' int2str(k)],...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );
    curseur = curseur+largeur;
% curseur à déplacer   
    appdata = [];
    appdata.lastValidTag = ['slider' int2str(k)];
    largeur = 50;
  h23 = uicontrol(...
    'Parent',h2,...
    'Visible','off',...
    'Units','characters',...
    'Position',[curseur prem_ligne-(k-1)*saut_ligne largeur hauteur_ligne],...
    'BackgroundColor',[0.9 0.9 0.9], 'CData',[],...
    'Callback',@(hObject,eventdata)affichagePC_V2('sliders_Callback',hObject,eventdata,guidata(hObject)),...
    'Style','slider',...
    'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)affichagePC_V2('sliders_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
    'UserData',[],...
    'Tag',['slider' int2str(k)]);
    curseur = curseur+largeur;

% valeur definie pas le curseur
    appdata = [];
    appdata.lastValidTag = ['valeur' int2str(k)];
    largeur = 8; %7
    h24 = uicontrol(...
    'Parent',h2,...
    'Visible','off',...
    'Units','characters',...
    'Position',[curseur prem_ligne-(k-1)*saut_ligne largeur hauteur_ligne],...
    'HorizontalAlignment', 'left',...
    'Style','text',...
    'Tag',['valeur' int2str(k)],...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );
    curseur = curseur+largeur+tabulation;
    
    if strcmpi(params.variables.infos(params.variables.vars_index(k)).loi, 'Discret')
        nb_step=length(params.variables.infos(params.variables.vars_index(k)).limites);
        set(h23,...
            'Min', 1,...
            'Max', nb_step,...
            'SliderStep', [1/nb_step 1/nb_step],...
            'Value', params.variables.infos(params.variables.vars_index(k)).moments)
 %       set(h24,'String', params.variables.infos(params.variables.vars_index(k)).limites(params.variables.infos(params.variables.vars_index(k)).moments) )
        set(h24,'String', sprintf('%d',params.variables.infos(params.variables.vars_index(k)).moments))

    else
        set(h23,...
            'Min', 0,...
            'Max', 1,...
            'SliderStep', [0.01 0.2],...
            'Value', 0.5)
        set(h24,...
            'String',  sprintf('%g',params.variables.infos(params.variables.vars_index(k)).moments(1))  )
    end

    
% Tableau des indices de sensibilité
    table_debut=curseur;
    largeur = 6;
    for l=1:sum(resultat.sorties_valide)

        appdata = [];
        appdata.lastValidTag = ['table' int2str(k) '-' int2str(l)];
        h25 = uicontrol(...
        'Parent',h2,...
        'Units','characters',...
        'Position',[curseur prem_ligne-(k-1)*saut_ligne largeur hauteur_ligne],...
        'String',{  num2str(0,'%2.f') },...
        'HorizontalAlignment', 'center',...
        'BackgroundColor', [0.75 0.75 0.75],...
        'Style','text',...
        'Tag',['table' int2str(k) '_' int2str(l)],...
        'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );
        curseur = curseur+largeur+tabulation2;
    end
    
    % incertitude
    appdata = [];
    appdata.lastValidTag = ['opt_incert' int2str(k)];
    h24 = uicontrol(...
    'Parent',h2,...
    'Visible','off',...
    'Units','characters',...
    'Position',[curseur prem_ligne-(k-1)*saut_ligne 2 hauteur_ligne],...
    'HorizontalAlignment', 'center',...
    'Style','pushbutton',...
    'Tag',['opt_incert' int2str(k)],...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata},...
    'Callback',@(hObject,eventdata)affichagePC_V2('opt_incert_Callback',hObject,eventdata,guidata(hObject)) );
    curseur_fin = curseur+2;
    
end
% Titres du tableau des indices
curseur = table_debut;
for l=1:sum(resultat.sorties_valide)
    h26 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'Position',[curseur prem_ligne+saut_ligne largeur hauteur_ligne],...
    'String',{ sprintf('S%d',l) },...
    'HorizontalAlignment', 'center',...
    'Style','text',...
    'Tag',['titreS' int2str(l)],...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

    curseur = curseur+largeur+tabulation2;
end

% repositionnement du cadre des variables
curseur = curseur_fin+marge_fin;
set(h2, 'Position', [curseur_depart marge_bas curseur hauteur_panel] );
curseur = curseur_depart*2+curseur;

% boutons de controle
hbout= uicontrol('Style', 'pushbutton',...
    'Parent',h1,...
    'String', 'Actualiser',...
    'Units','characters',...
    'Position', [curseur marge_bas 20 2],...
    'Callback', @(hObject,eventdata)affichagePC_V2('actualisation',hObject,eventdata,guidata(hObject))); 
   
hbout= uicontrol('Style', 'toggle',...
    'Parent',h1,...    
    'tag','incertitudes',...
    'String', 'Incertitudes',...
    'Units','characters',...
    'Position', [curseur marge_bas*2+2 20 2],...
    'Callback', @(hObject,eventdata)affichagePC_V2('toggle_incertitudes_SelectionChangeFcn',hObject,eventdata,guidata(hObject))); 
 

hbout= uicontrol('Style', 'pushbutton',...
    'Parent',h1,...    
    'tag','type_analyse',...
    'String', 'RBD-FAST',...
    'Units','characters',...
    'Position', [curseur marge_bas*3+4 20 2],...
    'Callback', @(hObject,eventdata)affichagePC_V2('toggle_analyse_SelectionChangeFcn',hObject,eventdata,guidata(hObject))); 
   
hnum= uicontrol('Style', 'edit',...
    'Parent',h1,...    
    'tag','nombre_essais',...
    'String', '200',...
    'Units','characters',...
    'Position', [curseur marge_bas*4+6 20 2]); 
   
curseur = curseur_depart*2+20+curseur;
% hbout= uicontrol('Style', 'pushbutton',...
%     'Parent',h1,...
%     'String', 'Recalculer',...
%     'Units','characters',...
%     'Position', [curseur_depart*2+curseur marge_bas*2+2 20 2],...
%     'Callback', @(hObject,eventdata)affichagePC_V2('actualisation_table',hObject,eventdata,guidata(hObject))); 


% determination des positions en pixel
set(h2, 'Units', 'pixels')
position = get(h2, 'Position');
set(h2, 'Units', 'characters')
set(hbout, 'Units', 'pixels')
positionbout = get(hbout, 'Position');
set(hbout, 'Units', 'characters')
taille = get(h1,'Position');


espace_gauche = 40;
espace_box = 50; %largeur des boxplot
espace_haut = 5;
espace_bas = 20;
inter_graph = 5; %défini aussi l'espace à droite


% Plot cumulative function distribution
appdata = [];
appdata.lastValidTag = ['sortie' int2str(k)];

debut = positionbout(1)+positionbout(3)+espace_gauche;
if (taille(3)-debut-inter_graph>200)
h_axe = axes(...
    'Parent',h1,...
    'Units','pixels',...
    'Position',[debut espace_bas taille(3)-debut-inter_graph position(4)-espace_bas],...
    'Color',get(0,'defaultaxesColor'),...
    'ColorOrder',get(0,'defaultaxesColorOrder'),...
    'FontSize',10,...
    'LooseInset',[0 0 0 0],...
    'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)affichagePC_V2('axes_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
 ...   'ButtonDownFcn',@(hObject,eventdata)affichagePC_V2('cfd_ButtonDownFcn',hObject,eventdata,guidata(hObject)),...
    'Tag',['cfd_axe'],...
    'NextPlot','replacechildren',...
    'UserData',[]);
%{
'TickDir',get(0,'defaultaxesTickDir'),...
'TickDirMode','manual',...
'XColor',get(0,'defaultaxesXColor'),...
'XLim',get(0,'defaultaxesXLim'),...
'XLimMode','manual',...
'XTick',[0 0.2 0.4 0.6 0.8 1],...
'XTickLabel',{  '0  '; '0.2'; '0.4'; '0.6'; '0.8'; '1  ' },...
'XTickLabelMode','manual',...
'XTickMode','manual',...
'YColor',get(0,'defaultaxesYColor'),...
'YLim',get(0,'defaultaxesYLim'),...
'YLimMode','manual',...
'YTick',[0 0.2 0.4 0.6 0.8 1],...
'YTickLabel',{  '0  '; '0.2'; '0.4'; '0.6'; '0.8'; '1  ' },...
'YTickLabelMode','manual',...
'YTickMode','manual',...
'ZColor',get(0,'defaultaxesZColor'),...
'ZLim',get(0,'defaultaxesZLim'),...
'ZLimMode','manual',...
'ZTick',[0 0.5 1],...
'ZTickLabel',blanks(0),...
'ZTickLabelMode','manual',...
'ZTickMode','manual',...
    %}
    h=plot(h_axe,0,'');
    
% 	legend(h_axe,sprintf('S%d: %s',k,analyse.legende{k}), 'Location', 'Best')
%     legend(h_axe,'boxoff')

end


% Positionnement des graphiques de sortie
nmax = ceil(sum(resultat.sorties_valide)/2);
haut = (taille(4)-position(2)-position(4)-espace_haut-espace_bas-inter_graph*(nmax-1))/nmax;
ligne = taille(4)-espace_haut;


taillegraph = [taille(3)/2-espace_gauche-espace_box-2*inter_graph, haut];

for k=1:nmax
    dispograph(k,:) = [espace_gauche, ligne-(haut+inter_graph)*k] ;
end
for k=nmax+1:sum(resultat.sorties_valide)
    dispograph(k,:) = [espace_gauche+taille(3)/2, ligne-(haut+inter_graph)*(k-nmax)];
end

dispobox = dispograph;
dispobox(:,1) = dispobox(:,1)+taillegraph(1)+inter_graph;
taillebox = [espace_box, haut];

% Evaluation du meta-modèle
%YPC = metamodelPC(analyse.PC_Infos,params.variables,200);

% création de graphiques vides
for k=1:sum(resultat.sorties_valide)

    appdata = [];
    appdata.lastValidTag = ['sortie' int2str(k)];
    
    h_axe = axes(...
        'Parent',h1,...
        'Units','pixels',...
        'Position',[dispograph(k,:),taillegraph],...
        'Color',get(0,'defaultaxesColor'),...
        'ColorOrder',get(0,'defaultaxesColorOrder'),...
        'FontSize',10,...
        'LooseInset',[0 0 0 0],...
        'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)affichagePC_V2('axes_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
        'ButtonDownFcn',@(hObject,eventdata)affichagePC_V2('axes_ButtonDownFcn',hObject,eventdata,guidata(hObject)),...
        'Tag',['sortie' int2str(k)],...
        'NextPlot','replacechildren',...
        'UserData',[]);
    %{
'TickDir',get(0,'defaultaxesTickDir'),...
'TickDirMode','manual',...
'XColor',get(0,'defaultaxesXColor'),...
'XLim',get(0,'defaultaxesXLim'),...
'XLimMode','manual',...
'XTick',[0 0.2 0.4 0.6 0.8 1],...
'XTickLabel',{  '0  '; '0.2'; '0.4'; '0.6'; '0.8'; '1  ' },...
'XTickLabelMode','manual',...
'XTickMode','manual',...
'YColor',get(0,'defaultaxesYColor'),...
'YLim',get(0,'defaultaxesYLim'),...
'YLimMode','manual',...
'YTick',[0 0.2 0.4 0.6 0.8 1],...
'YTickLabel',{  '0  '; '0.2'; '0.4'; '0.6'; '0.8'; '1  ' },...
'YTickLabelMode','manual',...
'YTickMode','manual',...
'ZColor',get(0,'defaultaxesZColor'),...
'ZLim',get(0,'defaultaxesZLim'),...
'ZLimMode','manual',...
'ZTick',[0 0.5 1],...
'ZTickLabel',blanks(0),...
'ZTickLabelMode','manual',...
'ZTickMode','manual',...
%}
    h=plot(h_axe,0,'');
    
	legend(h_axe,sprintf('S%d: %s',k,analyse.legende{k}), 'Location', 'Best')
    legend(h_axe,'boxoff')
    
    appdata = [];
    appdata.lastValidTag = ['boxplot' int2str(k)];
    
    h_axe = axes(...
        'Parent',h1,...
        'Units','pixels',...
        'Position',[dispobox(k,:),taillebox],...
        'Color',get(0,'defaultaxesColor'),...
        'ColorOrder',get(0,'defaultaxesColorOrder'),...
        'FontSize',10,...
        'LooseInset',[0 0 0 0],...
        'YTickLabel',{},...
        'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)affichagePC_V2('axes_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
        'Tag',['boxplot' int2str(k)],...
        'NextPlot','replacechildren',...
        'UserData',[]);
end

hsingleton = h1;





% --- Set application data first then calling the CreateFcn. 
function local_CreateFcn(hObject, eventdata, createfcn, appdata)

if ~isempty(appdata)
   names = fieldnames(appdata);
   for i=1:length(names)
       name = char(names(i));
       setappdata(hObject, name, getfield(appdata,name));
   end
end

if ~isempty(createfcn)
   if isa(createfcn,'function_handle')
       createfcn(hObject, eventdata);
   else
       eval(createfcn);
   end
end


% --- Handles default GUIDE GUI creation and callback dispatch
function varargout = gui_mainfcn(gui_State, varargin)

gui_StateFields =  {'gui_Name'
    'gui_Singleton'
    'gui_OpeningFcn'
    'gui_OutputFcn'
    'gui_LayoutFcn'
    'gui_Callback'};
gui_Mfile = '';
for i=1:length(gui_StateFields)
    if ~isfield(gui_State, gui_StateFields{i})
        error(message('MATLAB:guide:StateFieldNotFound', gui_StateFields{ i }, gui_Mfile));
    elseif isequal(gui_StateFields{i}, 'gui_Name')
        gui_Mfile = [gui_State.(gui_StateFields{i}), '.m'];
    end
end

numargin = length(varargin);

if numargin == 0
    % affichagePC_V2
    % create the GUI only if we are not in the process of loading it
    % already
    gui_Create = true;
elseif local_isInvokeActiveXCallback(gui_State, varargin{:})
    % affichagePC_V2(ACTIVEX,...)
    vin{1} = gui_State.gui_Name;
    vin{2} = [get(varargin{1}.Peer, 'Tag'), '_', varargin{end}];
    vin{3} = varargin{1};
    vin{4} = varargin{end-1};
    vin{5} = guidata(varargin{1}.Peer);
    feval(vin{:});
    return;
elseif local_isInvokeHGCallback(gui_State, varargin{:})
    % affichagePC_V2('CALLBACK',hObject,eventData,handles,...)
    gui_Create = false;
else
    % affichagePC_V2(...)
    % create the GUI and hand varargin to the openingfcn
    gui_Create = true;
end

if ~gui_Create
    % In design time, we need to mark all components possibly created in
    % the coming callback evaluation as non-serializable. This way, they
    % will not be brought into GUIDE and not be saved in the figure file
    % when running/saving the GUI from GUIDE.
    designEval = false;
    if (numargin>1 && ishghandle(varargin{2}))
        fig = varargin{2};
        while ~isempty(fig) && ~ishghandle(fig,'figure')
            fig = get(fig,'parent');
        end
        
        designEval = isappdata(0,'CreatingGUIDEFigure') || isprop(fig,'__GUIDEFigure');
    end
        
    if designEval
        beforeChildren = findall(fig);
    end
    
    % evaluate the callback now
    varargin{1} = gui_State.gui_Callback;
    if nargout
        [varargout{1:nargout}] = feval(varargin{:});
    else       
        feval(varargin{:});
    end
    
    % Set serializable of objects created in the above callback to off in
    % design time. Need to check whether figure handle is still valid in
    % case the figure is deleted during the callback dispatching.
    if designEval && ishghandle(fig)
        set(setdiff(findall(fig),beforeChildren), 'Serializable','off');
    end
else
    if gui_State.gui_Singleton
        gui_SingletonOpt = 'reuse';
    else
        gui_SingletonOpt = 'new';
    end

    % Check user passing 'visible' P/V pair first so that its value can be
    % used by oepnfig to prevent flickering
    gui_Visible = 'auto';
    gui_VisibleInput = '';
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        % Recognize 'visible' P/V pair
        len1 = min(length('visible'),length(varargin{index}));
        len2 = min(length('off'),length(varargin{index+1}));
        if ischar(varargin{index+1}) && strncmpi(varargin{index},'visible',len1) && len2 > 1
            if strncmpi(varargin{index+1},'off',len2)
                gui_Visible = 'invisible';
                gui_VisibleInput = 'off';
            elseif strncmpi(varargin{index+1},'on',len2)
                gui_Visible = 'visible';
                gui_VisibleInput = 'on';
            end
        end
    end
    
    % Open fig file with stored settings.  Note: This executes all component
    % specific CreateFunctions with an empty HANDLES structure.

    
    % Do feval on layout code in m-file if it exists
    gui_Exported = ~isempty(gui_State.gui_LayoutFcn);
    % this application data is used to indicate the running mode of a GUIDE
    % GUI to distinguish it from the design mode of the GUI in GUIDE. it is
    % only used by actxproxy at this time.   
    setappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]),1);
    if gui_Exported        
        gui_hFigure = feval(gui_State.gui_LayoutFcn, gui_SingletonOpt);

        % make figure invisible here so that the visibility of figure is
        % consistent in OpeningFcn in the exported GUI case
        if isempty(gui_VisibleInput)
            gui_VisibleInput = get(gui_hFigure,'Visible');
        end
        set(gui_hFigure,'Visible','off')

        % openfig (called by local_openfig below) does this for guis without
        % the LayoutFcn. Be sure to do it here so guis show up on screen.
%        movegui(gui_hFigure,'onscreen');
    else
        gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        % If the figure has InGUIInitialization it was not completely created
        % on the last pass.  Delete this handle and try again.
        if isappdata(gui_hFigure, 'InGUIInitialization')
            delete(gui_hFigure);
            gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        end
    end
    if isappdata(0, genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]))
        rmappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]));
    end

    % Set flag to indicate starting GUI initialization
    setappdata(gui_hFigure,'InGUIInitialization',1);

    % Fetch GUIDE Application options
    gui_Options = getappdata(gui_hFigure,'GUIDEOptions');
    % Singleton setting in the GUI M-file takes priority if different
    gui_Options.singleton = gui_State.gui_Singleton;

    if ~isappdata(gui_hFigure,'GUIOnScreen')
        % Adjust background color
        if gui_Options.syscolorfig
            set(gui_hFigure,'Color', get(0,'DefaultUicontrolBackgroundColor'));
        end

        % Generate HANDLES structure and store with GUIDATA. If there is
        % user set GUI data already, keep that also.
        data = guidata(gui_hFigure);
        handles = guihandles(gui_hFigure);
        if ~isempty(handles)
            if isempty(data)
                data = handles;
            else
                names = fieldnames(handles);
                for k=1:length(names)
                    data.(char(names(k)))=handles.(char(names(k)));
                end
            end
        end
        guidata(gui_hFigure, data);
    end

    % Apply input P/V pairs other than 'visible'
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        len1 = min(length('visible'),length(varargin{index}));
        if ~strncmpi(varargin{index},'visible',len1)
            try set(gui_hFigure, varargin{index}, varargin{index+1}), catch break, end
        end
    end

    % If handle visibility is set to 'callback', turn it on until finished
    % with OpeningFcn
    gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
    if strcmp(gui_HandleVisibility, 'callback')
        set(gui_hFigure,'HandleVisibility', 'on');
    end

    feval(gui_State.gui_OpeningFcn, gui_hFigure, [], guidata(gui_hFigure), varargin{:});

    if isscalar(gui_hFigure) && ishghandle(gui_hFigure)
        % Handle the default callbacks of predefined toolbar tools in this
        % GUI, if any
        guidemfile('restoreToolbarToolPredefinedCallback',gui_hFigure); 
        
        % Update handle visibility
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);

        % Call openfig again to pick up the saved visibility or apply the
        % one passed in from the P/V pairs
        if ~gui_Exported
            gui_hFigure = local_openfig(gui_State.gui_Name, 'reuse',gui_Visible);
        elseif ~isempty(gui_VisibleInput)
            set(gui_hFigure,'Visible',gui_VisibleInput);
        end
        if strcmpi(get(gui_hFigure, 'Visible'), 'on')
            figure(gui_hFigure);
            
            if gui_Options.singleton
                setappdata(gui_hFigure,'GUIOnScreen', 1);
            end
        end

        % Done with GUI initialization
        if isappdata(gui_hFigure,'InGUIInitialization')
            rmappdata(gui_hFigure,'InGUIInitialization');
        end

        % If handle visibility is set to 'callback', turn it on until
        % finished with OutputFcn
        gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
        if strcmp(gui_HandleVisibility, 'callback')
            set(gui_hFigure,'HandleVisibility', 'on');
        end
        gui_Handles = guidata(gui_hFigure);
    else
        gui_Handles = [];
    end

    if nargout
        [varargout{1:nargout}] = feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    else
        feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    end

    if isscalar(gui_hFigure) && ishghandle(gui_hFigure)
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
    end
end

function gui_hFigure = local_openfig(name, singleton, visible)

% openfig with three arguments was new from R13. Try to call that first, if
% failed, try the old openfig.
if nargin('openfig') == 2
    % OPENFIG did not accept 3rd input argument until R13,
    % toggle default figure visible to prevent the figure
    % from showing up too soon.
    gui_OldDefaultVisible = get(0,'defaultFigureVisible');
    set(0,'defaultFigureVisible','off');
    gui_hFigure = openfig(name, singleton);
    set(0,'defaultFigureVisible',gui_OldDefaultVisible);
else
    gui_hFigure = openfig(name, singleton, visible);  
    %workaround for CreateFcn not called to create ActiveX
    if feature('HGUsingMATLABClasses')
        peers=findobj(findall(allchild(gui_hFigure)),'type','uicontrol','style','text');    
        for i=1:length(peers)
            if isappdata(peers(i),'Control')
                actxproxy(peers(i));
            end            
        end
    end
end

function result = local_isInvokeActiveXCallback(gui_State, varargin)

try
    result = ispc && iscom(varargin{1}) ...
             && isequal(varargin{1},gcbo);
catch
    result = false;
end

function result = local_isInvokeHGCallback(gui_State, varargin)

try
    fhandle = functions(gui_State.gui_Callback);
    result = ~isempty(findstr(gui_State.gui_Name,fhandle.file)) || ...
             (ischar(varargin{1}) ...
             && isequal(ishghandle(varargin{2}), 1) ...
             && (~isempty(strfind(varargin{1},[get(varargin{2}, 'Tag'), '_'])) || ...
                ~isempty(strfind(varargin{1}, '_CreateFcn'))) );
catch
    result = false;
end



function actualisation(hObject, eventdata, handles)
global analyse
global resultat
global params

set(hObject,'Enable', 'off')
set(hObject,'String', 'En cours ...')
nb_echantillons = round(str2num (get(handles.nombre_essais,'String')));
nb_echantillons = nb_echantillons(1);
if isempty(nb_echantillons) || nb_echantillons<150
    nb_echantillons=200;
elseif rem(nb_echantillons,2)~=0
    nb_echantillons=nb_echantillons+mod(nb_echantillons,2);
end
set(handles.nombre_essais,'String', nb_echantillons)

num_valiable = find(flipud(cell2mat(get(handles.radiobutton,'Value'))));

% identification des entrées imposées
h_check=flipud(findobj('-regexp','Tag','check'));
choix_fixe = logical(cell2mat(get(h_check,'Value')));

% Attribution des valeurs définies
h_valeur=flipud(findobj('-regexp','Tag','valeur'));
X_valeur = str2num(char(get(h_valeur(choix_fixe),'String')));
X_fixe = NaN(1,params.variables.vars_nb);
X_fixe(choix_fixe)=X_valeur;


% analyse de sensibilité
switch get(handles.type_analyse,'String')
    case {'Surf'}
          keyboard
        global legende
        %%
    id1 = 1;
    id2 = 3;
    s1 = 3; % Tout=7   Flux=8   Tin=6   legende.sorties_all(resultat.sorties_valide)
        S = find(resultat.sorties_valide)
        s1 = S(s1) 
        
        titre = strrep(legende.sorties_all{s1},'ace HotMonth','.')
        legende.vars([id1 id2],2)
        
        
        
        redPCinfo = analyse.PC_Infos(s1);
        redPCinfo.sorties_valide = 1;
        
        nume = 30;
    nb_echantillons = nume^2;
 
    figure
    clear h
    A = [0 0.9 0;
         0 0.6 0;
         0 0.3 0]
    %
     lim = [Inf -Inf];
 colormap(1-gray)
     for aa= 1:size(A,1)
    subplot(size(A,1),1,aa)
    
        % eval avec invertitude
        var_locale = 0;
        X = LHS(nb_echantillons, create_index(nb_echantillons,params.variables.vars_nb,params.type_plan_LHS), params.variables.infos(params.variables.vars_index), var_locale);

        [X1,X2] = meshgrid(min(X(:,id1)):(max(X(:,id1))-min(X(:,id1)))/(nume-1):max(X(:,id1)),min(X(:,id2)):(max(X(:,id2))-min(X(:,id2)))/(nume-1):max(X(:,id2)));     
        
        % eval sans incertitude
        if true
        X = str2num(char(get(h_valeur,'String')))';
        X = A(aa,:)
        X = repmat(X,nb_echantillons,1);
        end
        
        X(:,id1) = X1(:);
        X(:,id2) = X2(:);          

        YPC = metamodelPC(redPCinfo,params.variables,X);
        Z =reshape(YPC, size(X1));
        


  
%colormap(flipud(colormap ('bone')))
    
        % eval de la variance produite pax les incertitudes
        if ~get(handles.incertitudes,'value')
%            surf(X1,X2,Z)
  %          pcolor(X1,X2,Z)
   if Z(1)>10,   v1 = [0:5:100]; v2= [0:10:100]; else, Z=Z*1000; v1 = [0:10:160]; v2 = [0:20:160]; end
  
            [C,hc] = contourf(X1,X2,Z,v1)
            hlab = clabel(C,hc,v2,'LabelSpacing',300);
            set(hlab,'BackgroundColor',[1 1 1],'Margin',0.1)
        %    http://fr.mathworks.com/help/matlab/ref/contour-properties.html
            
h(aa) = gca;           
set(h(aa),'xlim', [0 0.10], 'XTick', 0:0.02:0.10, 'XTickLabel', 0:2:10)
m = get(h(aa),'Clim');
lim = [min(m(1),lim(1)) max(m(2),lim(2))];

        else
            C=zeros(size(Z));
            var_locale = 1;
            N=50;
            for i=1:numel(X1)
                X = LHS(N, create_index(N,params.variables.vars_nb,params.type_plan_LHS), params.variables.infos(params.variables.vars_index), var_locale);
                X(:,id1) = X1(i);
                X(:,id2) = X2(i);
                C(i)=diff(quantile(metamodelPC(redPCinfo,params.variables,X),[0.05 0.95]));
            end
            
            surf(X1,X2,Z,C)
        end
      %  colorbar
     end
        annotation('textbox', [0,0,0.1,0.1],'String', titre);

     set(h,'Clim', lim)

%%
          
    case {'RBD-FAST'}   
%         for p=1:100
%         nb_echantillions = 10*p;
        
        % evaluation du meta-modèle
        if get(handles.incertitudes,'value')
            %INCERTITUDES
            type_plan_LHS=1;  % 0:sans 1:minimax10 
            X = LHS(nb_echantillons, create_index(nb_echantillons,params.variables.vars_nb,type_plan_LHS), params.variables.infos(params.variables.vars_index), X_fixe);
            YPC = metamodelPC(analyse.PC_Infos,params.variables,X);
        else
            %PAS DE VARIATION
            [YPC,X] = metamodelPC(analyse.PC_Infos,params.variables,nb_echantillons,X_fixe);
        end
        
        SI=rbd_fast(1,1,8,[],YPC(:,resultat.sorties_valide),X);
        
        
    case {'RBD-SOBOL'}
              
        % evaluation du meta-modèle
        if get(handles.incertitudes,'value')
            %INCERTITUDES
            X = LHS(nb_echantillons/2, create_index(nb_echantillons/2,params.variables.vars_nb,type_plan_LHS), params.variables.infos(params.variables.vars_index), X_fixe);
            YPC = metamodelPC(analyse.PC_Infos,params.variables,X);
        else
            %PAS DE VARIATION
            [YPC,X] = metamodelPC(analyse.PC_Infos,params.variables,nb_echantillons/2,X_fixe);
        end
        
        
        SI = zeros(params.variables.vars_nb,sum(resultat.sorties_valide));
        X_suite = zeros(size(X));
        Y1=YPC(:,resultat.sorties_valide);

        for i=1:params.variables.vars_nb
            index_rbd_sobol(:,i)=randperm(nb_echantillons/2);
            X_suite(:,i)=X(index_rbd_sobol(:,i),i);
        end
        YPC_suite = metamodelPC(analyse.PC_Infos,params.variables,X_suite);
        YB= YPC_suite(:,resultat.sorties_valide);

        V = var((Y1-YB)/sqrt(2),0,1);
        for i=1:params.variables.vars_nb
            [~,tri]=sort(index_rbd_sobol(:,i));
            Y2=YB(tri,:);
            SI(i,:)= mean(Y1.*(Y2-YB),1)./V;
        end

        YPC = [YPC; YPC_suite];
        X=[X;X_suite];

    otherwise
            error('Type d''analyse non reconnue')
        
end


if ~get(handles.incertitudes,'value')
    SI(choix_fixe,:)=NaN;
end

if ~any(analyse.PC_Infos(1).vars_discet(~choix_fixe))
    SI(analyse.PC_Infos(1).vars_discet,:)=NaN;
else    
    %variable discrete présente    
    id = find(analyse.PC_Infos(1).vars_discet, 1, 'first');
    nbs_niv = length(params.variables.infos(id).limites);
    n=floor(nb_echantillons/nbs_niv);
    filtre = NaN(n,nbs_niv);
    for k=1:nbs_niv
        % Selectionne les données correspondantes au niveau                        
        A = find(X(:,id)==k); 
        if size(A,1)<n
            n = size(A,1);
            filtre = filtre(1:n,:);
        end
        filtre(:,k) = A(1:n);

    end
   % fontsize = 16;
    markersize = 10;
    if true %colors
        col=hsv(nbs_niv);
        form = {'.','.','.','.'};
    else
        col=zeros(nbs_niv);
        form = {'^','s','o','.'};
    end
end
%keyboard
for k=1:sum(resultat.sorties_valide)
    % mise a jour table
    for l=1:params.variables.vars_nb
        h =eval(['handles.table' int2str(l) '_' int2str(k)]);
        set(h, 'String', sprintf('%2.0f',SI(l,k)*100))  %'%2.1f%%'
        if SI(l,k)<0.05
            set(h, 'BackgroundColor', get(0,'DefaultUicontrolBackgroundColor'))
        elseif isnan(SI(l,k))
            set(h, 'BackgroundColor', get(0,'DefaultUicontrolBackgroundColor'))
        else
            set(h, 'BackgroundColor', [1 (1-SI(l,k))*1.05 0])
        end        
    end
    
    % mise a jour graph
    h_axe=eval(['handles.sortie' int2str(k)]);
    axes(h_axe)
    
    if exist('filtre','var')
        %variable discrete présente  
        
        for niv=1:nbs_niv
            h=plot(X(filtre(:,niv),num_valiable),YPC(filtre(:,niv),resultat.sorties_valide_index(k)),'.');
            set (h,'color','k', 'LineStyle','none', 'Marker',form{niv},'MarkerSize',markersize, 'Color',col(niv,:))
            hold on %la fct se répéte mais la fig préc est écrasée. 
        end
        hold off
    else
        h=plot(X(:,num_valiable),YPC(:,resultat.sorties_valide_index(k)),'.');
        %set(h,'HitTest','off')
    end

    if var(X(:,num_valiable))>10^10
        set(gca,'XLim',[min(X(:,num_valiable)) max(X(:,num_valiable))], 'FontSize', 10);
    end
    set(gca,'YLim',scaling(YPC(:,resultat.sorties_valide_index(k))), 'FontSize', 10);
%    set(gca,'YLim',[min(1.1*min(YPC(:,resultat.sorties_valide_index(k))),0) max(1.1*max(YPC(:,resultat.sorties_valide_index(k))), 0)], 'FontSize', 10);
	legend(h_axe,sprintf('S%d: %s',k,analyse.legende{k}), 'Location', 'Best')
    legend(h_axe,'boxoff')
    
    h_axe=eval(['handles.boxplot' int2str(k)]);
    axes(h_axe)
    cla
    h=aboxplot(YPC(:,resultat.sorties_valide_index(k)));
    %h=aboxplot([YPC(:,resultat.sorties_valide_index(k)),YPC(:,resultat.sorties_valide_index(k))]);
    %set(h,'HitTest','off')
    
    set(gca,'YLim',scaling(YPC(:,resultat.sorties_valide_index(k))), 'FontSize', 10);
%    set(gca,'YLim',[min(1.1*min(YPC(:,resultat.sorties_valide_index(k))),0) max(1.1*max(YPC(:,resultat.sorties_valide_index(k))), 0)], 'FontSize', 10);
    
   % j=j+1;
 %   datacursormode on
 
end
set(hObject,'String', 'Actualiser')
set(hObject,'enable', 'on')



function actualisation_table(hObject, eventdata, handles)
global analyse
global params

nb_echantillions=200;

% identification des entrées imposées
h_check=flipud(findobj('-regexp','Tag','check'));
choix_fixe = logical(cell2mat(get(h_check,'Value')));

% atribution des valeurs définies
X_fixe = NaN(1,params.variables.vars_nb);
% h_valeur=flipud(findobj('-regexp','Tag','slider'));
% X_valeur = get(h_valeur(choix_fixe),'Value');
% if iscell(X_valeur)
%     X_valeur = cell2mat(X_valeur);
% end
h_valeur=flipud(findobj('-regexp','Tag','valeur'));
X_valeur = str2num(char(get(h_valeur(choix_fixe),'String')));
X_fixe(choix_fixe)=X_valeur;

keyboard
warning('dev en cours !!!')
fhandle = @(x) metamodelPC(analyse.PC_Infos,params.variables,x,X_fixe);


PC_Infos = PCE_Blatman('local', X_fixe, fhandle)



[YPC,X] = metamodelPC(analyse.PC_Infos,params.variables,nb_echantillions,X_fixe);
% Création d'un metamodèle local

% evaluation du meta-modèle
[YPC,X] = metamodelPC(analyse.PC_Infos,params.variables,nb_echantillions,X_fixe);

for k=1:sum(resultat.sorties_valide)
    
    
    h_axe=eval(['handles.sortie' int2str(k)]);
    axes(h_axe)
    h=plot(X(:,num_valiable),YPC(:,resultat.sorties_valide_index(k)),'.');
    %set(h,'HitTest','off')
    
    if var(X(:,num_valiable))>0.0001
        set(gca,'XLim',[min(X(:,num_valiable)) max(X(:,num_valiable))], 'FontSize', 10);
    end
    set(gca,'YLim',[min(1.2*min(YPC(:,resultat.sorties_valide_index(k))),0) max(1.2*max(YPC(:,resultat.sorties_valide_index(k))), 0)], 'FontSize', 10);

    
    h_axe=eval(['handles.boxplot' int2str(k)]);
    axes(h_axe)
    h=aboxplot([YPC(:,resultat.sorties_valide_index(k)),YPC(:,resultat.sorties_valide_index(k))]);
    %set(h,'HitTest','off')
    
    set(gca,'YLim',[min(1.2*min(YPC(:,resultat.sorties_valide_index(k))),0) max(1.2*max(YPC(:,resultat.sorties_valide_index(k))), 0)], 'FontSize', 10);
    
   % j=j+1;
 %   datacursormode on
end


function BoutonCurseur_Callback(hObject, eventdata, handles)
% hObject    handle to BoutonCurseur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%affichage des courbes
handle_l1 = line([50000 50000],[-200 400],'LineWidth',3,'Color','g', 'ButtonDownFcn', @(obj, evt) click_on_line(obj));
setappdata(0,'handle_l1',handle_l1);
handle_l2 = line([450000 450000],[-200 400],'LineWidth',3,'Color','g','ButtonDownFcn', @(obj, evt) click_on_line(obj));
setappdata(0,'handle_l2',handle_l2);



function opt_incert_Callback(hObject, eventdata, handles)
% hObject    handle to BoutonCurseur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%affichage des courbes

global params
global legende

id = str2num(regexprep(get(hObject,'Tag'), 'opt_incert', ''));

if strcmp(params.variables.infos(params.variables.vars_index(id)).loi,'Discret')
    set(hObject, 'Visible','off')
    return
end

hvaleur = findobj('Tag',sprintf('valeur%d',id));

def = {params.variables.infos(params.variables.vars_index(id)).loi num2str(get(hvaleur, 'String')), num2str(params.variables.infos(params.variables.vars_index(id)).moments(2)) };
prompt = {'Loi', 'Moyenne' , 'Ecart'};
dlg_title = legende.vars{id,2};
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer)
    return
end
switch lower(answer{1})
%     case {0,'discret'}
%         answer(1)='Discret';
    case {1,'uniform'}
        params.variables.infos(params.variables.vars_index(id)).loi='Uniform';
    case {2,'gaussian'}
        params.variables.infos(params.variables.vars_index(id)).loi='Gaussian';
    case {3,'uniformr'}
        params.variables.infos(params.variables.vars_index(id)).loi='UniformR';
    case {4,'gaussianr'}
        params.variables.infos(params.variables.vars_index(id)).loi='GaussianR';
    otherwise
        opt_incert_Callback(hObject, eventdata, handles)
        return
end
answer=str2double(answer(2:3));
if isnumeric(answer)
    params.variables.infos(params.variables.vars_index(id)).moments(1) = min( max(answer(1), params.variables.infos(params.variables.vars_index(id)).limites(1)) ,params.variables.infos(params.variables.vars_index(id)).limites(2));
    params.variables.infos(params.variables.vars_index(id)).moments(2) = answer(2);
else
    opt_incert_Callback(hObject, eventdata, handles)
    return
end

set(hvaleur,'String', sprintf('%g',params.variables.infos(params.variables.vars_index(id)).moments(1)))
valeur_bar = (  params.variables.infos(params.variables.vars_index(id)).moments(1)-params.variables.infos(params.variables.vars_index(id)).limites(1)  )/diff(params.variables.infos(params.variables.vars_index(id)).limites);
set(findobj('Tag',sprintf('slider%d',id)),'Value',valeur_bar)
    




