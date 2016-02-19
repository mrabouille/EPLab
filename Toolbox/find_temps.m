function [dates]=find_temps(file)
%{
Créé par Mickael Rabouille
Version du 11/07/2012

NOTES:

== Listing des surfaces ==
Identification des données temporelles à partir du fichier *.csv spécifié
pour utiliser la simulation de base le paramètre est:
fullfile(simul_rep,sprintf('%1$s%2$d\\%1$s%2$d.csv',simul_nom,0))

A FAIRE:
Vérifier la difference de temps entre les 2 premieres lignes
si pas horaire ou journalier

%}

%{
Identification des données temporelles à partir du fichier *.csv de la
simulation de base


%}

fid = fopen(file);
if fid == -1, error(file), end
A = textscan(fid, '%s %*[^\n]', 'HeaderLines',1 , 'Delimiter',',' , 'BufSize' , 16000);
% textscan(fid, ' %2d/%2d %2d:%2d:%2d %*[^\n]', 'HeaderLines',1 , 'Delimiter','' , 'BufSize' , 16000 , 'CollectOutput' , 1);
fclose(fid);

%Récupération des dates sous forme de matrice [yyyy  mm dd HH MM SS]
dates.vec = datevec(A{1}, 'mm/dd  HH:MM:SS');
%dates horaires sous forme de nombre
dates.h = datenum(dates.vec);

dates.id_j_h1 = find(dates.vec(:,4)==1); %première heure du jour
dates.id_j_h24 = find(~dates.vec(:,4)); %derniere heure du jour

%dates journalieres sous forme de nombre
dates.j = datenum( dates.vec(dates.id_j_h1,:) );

%Nombre de jours de simulation
dates.nb_j=size(dates.j,1);

%Nombre d'heures de simulation
dates.nb_h=size(dates.h,1);

end