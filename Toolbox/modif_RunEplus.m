function modif_RunEplus(rep, Ep_dir)
% modif_RunEplus - Configuration du fichier d'appel de E+
%
% Synopsis
%   modif_RunEplus(rep, Ep_dir)
%
% Description
%     Copie le RunEplus.bat dans le dossier de simulation 'rep' avec le
%     chemin d'installation de EnergyPlus défini par 'Ep_dir'
%
% Inputs ([]s are optional)
%   (string)    rep     Repertoire de destination du fichier modifié
%   (string)    Ep_dir  Répertoire d'instalation E+
%
%
% Examples
%   modif_RunEplus(params.rep_simul, Ep_dir); 
%
% Requirements
%   Le fichier RunEplus.bat initial doit etre présent sur le repertoire
%   courant

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
%   07/09/2012  First Edition


% ouverture des fichiers en lecture et en écriture
fid=fopen('RunEPlus.bat','r');
fod=fopen(fullfile(rep, 'RunEPlus.bat') ,'w');

% lecture de la premiere ligne
ligne  = fgets(fid);

% boucle jusqu'à trouver '%Ep_dir%'
while isempty ( strfind(ligne, char('%Ep_dir%')) )
    fprintf(fod,'%s',ligne);
    ligne  = fgets(fid);
end

% remplace par le bon chemin
fprintf(fod, regexprep(ligne, '%Ep_dir%', '%s') , char(Ep_dir) );

% copie le reste du fichier
ligne  = fgets(fid);
while ischar(ligne)
    fprintf(fod,'%s',ligne);
    ligne  = fgets(fid);
end

% ferme les fichiers
fclose(fid);
fclose(fod);


