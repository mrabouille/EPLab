function [appDir,idfFile,appVer]=checkVersionEP(file, appDir)
% Changes
%   03/12/2013  Création
%   01/04/2016  Avoid recursive call
%               Add more detailed error messages


if ~iscell(appDir)
    appDir = {appDir};
end
if ~iscell(file)
    file = {file};
end


% Test le chemin vers les fichiers idf (use the fist valid file)
filePass = 0;
for k=1:length(file)
    if exist(file{k},'file')
        filePass = 1;
        idfFile = file{k};
        break
    end 
end
if ~filePass
    error(['Le fichier idf n''a pas été trouvé aux emplacements indiqués:' sprintf('\n%s',file{:})])
end

% Recherche de la version du fichier idf
fid = fopen(idfFile,'r');
ligne  = fgets(fid);
while ischar(ligne)
    if ( regexpi(ligne, '^\s*Version\s*,') ) % <space or not>version<space or not>,
        
        % version<space or not>,<space or not><A NUMBER><space or not>;
        idfVer = regexpi(ligne, 'Version\s*,\s*([0-9.]+)\s*;','tokens','once'); 
        if ~isempty(idfVer)
            idfVer = idfVer{1};
        else
            %There is no number at this line, check nexts
            ligne  = strtrim(fgets(fid));
            % skip any empty or comment line
            while isempty(ligne) || ligne(1)=='!'
                ligne  = strtrim(fgets(fid));
            end
            idfVer = regexp(ligne,'([0-9.]+)','match','once');
            if isempty(idfVer)
                error('Version non trouvée pour le fichier\n%s',file)
            end
        end
        
        break % end the loop
    end
    ligne  = fgets(fid);
end
fclose(fid);




% Test les chemins vers EnergyPlus
appDirPass = appDir;
appVer = cell(length(appDir),1);
for k=length(appDirPass):-1:1
    appFile = fullfile(appDirPass{k},'Energy+.idd');
    if ~exist( appFile,'file' )
        appDirPass(k)=[];
        appVer(k)=[];
    else        
        % Recherche de la version du programme
        fid = fopen(appFile,'r');
        appVer{k} = regexp(fgets(fid),'[0-9.]+','match','once');
        fclose(fid);
    end
end
if isempty(appDirPass)
    error(['Aucun fichier de version EnergyPlus (*.idd) n''a été trouvé aux emplacements indiqués :' sprintf('\n%s',appDir{:})])
end


% Select corresponding version
if strcmp(idfVer,'.')
    % BESTEST Case: use the latest version
    appVerSplit = regexp(appVer,'[.]','split');
    appVerNum = zeros(length(appVer),max(cellfun(@length, appVerSplit)));
    for k=1:length(appVer)
        appVerNum(k,1:length(appVerSplit{k})) = cellfun(@(y) str2num(y),appVerSplit{k});
    end
    [~,I] = sortrows(appVerNum);
    [~,idMax] = max(I);
    
    appVer = regexp(appVer{idMax},'^\d+[.]\d+','match');
    appDir = appDirPass{idMax};
else
    % Normal Case: find the first match
    match = cellfun(@(x) strncmpi(x,idfVer, min(length(x),length(idfVer)) ) ,appVer);
    if ~any(match)
        error(['La version du fichier idf (%s) ne correspond a aucune version d''EnergyPlus renseigné(s).' sprintf('\n --> %s',appVer{:})],idfVer)
    end    
    appDir = appDirPass{find(match , 1, 'first') };
end


