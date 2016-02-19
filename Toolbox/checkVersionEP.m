function [pass,appDir,idFile]=checkVersionEP(file, appDir)
% Changes
%   03/12/2013  Création


idFile='';
        
if iscell(appDir)
    for k=1:length(appDir)
        [pass,~,idFile]=checkVersionEP(file, appDir{k});
        if pass>=1
            appDir = appDir{k};
            return
        end
    end
    return
end

if iscell(file)
    for k=1:length(file)
        [pass,~,idFile]=checkVersionEP(file{k}, appDir);        
        if pass==1
            pass=k;
            return
        end
    end
    return
end


% Test le chemin vers le fichier idf
file = fullfile(file);
if ~exist(file,'file')
    pass=-1;
    return
    %error('Le fichier idf n''a pas été trouvé à l''emplacement indiqué :\n%s',file)
end    


% Test le chemin vers EnergyPlus
appVer = fullfile(appDir,'Energy+.idd');
if ispc    
    if ~exist ( appVer,'file' )
        pass=-1;
        return
        %error('Le fichier de version EnergyPlus n''a pas été trouvé à l''emplacement indiqué :\n%s',appDir)
    end
elseif isunix
    error ('Linux ?!')        
else
    error ('OS mystère ?!')
end
 

% Recherche de la version du fichier
fid = fopen(file,'r');
ligne  = fgets(fid);
while ischar(ligne)
    if ( strfind(ligne, char('Version')) )
        k=0;
        while true
            idFile = regexp(ligne,'([0-9.]+)','match','once');
            if length(idFile)>0
                break
            end
            ligne  = fgets(fid);
            if k>9
                error('Version non trouvée !')
            else
                k=k+1;
            end
        end
    end
    ligne  = fgets(fid);
end
fclose(fid);



% Recherche de la version du programme
fid = fopen(appVer,'r');
idApp = regexp(fgets(fid),'[0-9.]+','match','once');
fclose(fid);

%strfind(idApp,idFile)
pass = strncmpi(idApp,idFile,min(length(idApp),length(idFile)));
if pass~=1
    keyboard
    pass=-1
    appDir='';
    idFile='';
end

end


