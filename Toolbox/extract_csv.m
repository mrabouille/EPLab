function donnees=extract_csv(file,dates,sorties,extract_lum) %#ok<INUSL>
%   13/02/2014  Ajout de l'éclairement
%   23/05/2013  Last Change


%cherche 'Output:Variable,' dans IDF
%puis tant que ya pas 3 valeurs
%	supp les commentaires, apres '!'
%	cherche une autre valeur à la suite
%	si valeur présente strtroke(, ou ;) 
%		prend la valeur 
%		et continue
%	sinon 
%		ligne suivante
%		et continue
%		
%au final 3 valeurs avec 
%localisation, nom, precision
%		
%		
%analyse CSV
%extrait les noms
%
%si localisation == '*'
%restraindre la recherche
%'Surface Window' -> fenetre
%'Surface' -> opaque
%'Zone' -> zones
%'Facility' -> Whole Building
%
%si par trouver reprendre sur toutes les variables
%
%si tjr pas
%	erreur
%
%	
%Output:Variable,RESISTANCE,  Heating Coil Electric Power , Hourly;     
%devient
%RESISTANCE:Heating Coil Electric Power [W](Hourly)
%
%'localisation':'nom'+...(precision)
%

persistent first
if isempty(first)
    first=true;
else
    first=false;
end
    
if nargin<4
    extract_lum=true;
else
    extract_lum = logical(extract_lum);
end

% == Lecture du fichier de sortie ==

fid = fopen(file,'r');
if fid == -1, error('Ouverture impossible du fichier:\n%s', file), end
legende_csv=textscan(fgets(fid),'%s','delimiter',',');
fclose(fid);
legende_csv = strtrim( legende_csv{1}(2:end) );
datas_csv = csvread(file, 1, 1);

out_test= cell(size(legende_csv));

erreur.etat = false;
erreur.manque = cell(1,0);
erreur.multi = cell(2,0);
for l=sorties'
    out_test(:) = l(2);
    result = find(strcmp(out_test, legende_csv));

    % Vérification qu'il y a au moins une réponse
    if isempty(result)
        if l{1}
            erreur.etat = true;
            erreur.manque(end+1) = l(2);
        elseif first
            warning('Sortie optionnelle non trouvée: %s',l{2})
        end
        continue
    else
        % Vérification qu'il n'y a pas plusieures réponses (le cas ne peut normalement pas se présenter).
        if (size(result,1)>1)
            erreur.etat = true;
            erreur.multi(1,end+1) = l(2);
            erreur.multi(2,end) = num2cell(size(result,1));
            continue;
        end

        % Création des variables et leur attribuer les données
        if isempty(strfind(l{2},'Hourly')) 
            if isempty(strfind(l{2},'Daily')), error('Le type de donée n''a pas été reconnu.'); end 
            % Données journalières: prend les lignes en fin de journée
           try eval( [ l{3} ' = datas_csv( dates.id_j_h24 , result(1) );' ] ); 
           catch err
               keyboard
               disp(err)
           end
        else
            % Données horaires: prend toutes les lignes
            eval( [ l{3} ' = datas_csv(:, result(1) );' ])
        end
    end
end
clear l
if erreur.etat
    fprintf('=> ERREUR : Vérifiez les variables !\n\n');
    fprintf('- Liste des sorties présentes issues du *.csv\n');
    disp(legende_csv)
    if size (erreur.manque,2)
        disp('- Liste des sorties demandées non trouvées :');
        fprintf('    ''%s''\n',erreur.manque{:});
    end
    if size (erreur.multi,2)
        fprintf('- Liste des sorties demandées multiples :\n');
        fprintf('    ''%s'', %d occurances\n',erreur.multi{:});
    end
    error('Vérifiez les sorties demandées. (Voir description ci-dessus)');
end

nb_heures = size(datas_csv,1);

clear out_test;
clear result;
clear datas_csv;


if ~extract_lum || fid==-1
    % isfield(geometrie, 'lightzones')
    return
end

% == Lecture de la carte d'éclairement ==
fid=fopen(strrep(file, '.csv', 'Map.csv'),'r');

if fid==-1
    % Pas de carte
    return
end

ligne=fgets(fid);

id_heure=-24;
isdefined = false;

while ischar(ligne)
    if ligne(1)=='D'
        %nouvelle journées, heure du levé
        ligne  = fgets(fid);
        [~, ~, ~, H, ~, ~] = datevec(strtok(ligne, ','));
        id_heure = (fix(id_heure/24)+1)*24 + H;
        if ~isdefined
            isdefined = true;
            donnees.eclairement.brut = zeros(1,size(regexp(ligne, '='),2),24,nb_heures/24);
            donnees.eclairement.actif = false(24,nb_heures/24);
        end
        l=1; 
    elseif ligne(1)=='(' 
        % lecture des données
        donnees.eclairement.brut(l,:,id_heure) = str2double ( regexp (ligne, '(?<=\x2C)[0-9]+', 'match') );
        %(?<=expr) => Look behind from current position and test if expr is found.
        %\xN => Character of hexadecimal value N.  hex 2C = comma(,)
        %expr+ => Match expr when it occurs 1 or more times consecutively. Equivalent to {1,}.
        donnees.eclairement.actif(id_heure) = true;
        l=l+1;
    else
        %heure suivante
        id_heure = id_heure+1;
        l=1;
    end
    ligne  = fgets(fid);

end
fclose(fid);