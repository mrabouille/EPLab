function modif_IDF(IDF_ini,IDF_new,variables,valeurs,test,IDSim)
%MODIF_IDF copie le fichier IDF_ini dans un nouveau fichier nom_simul 
% en incluant des modifications.
%
% IDF_ini       : nom complet du fichier idf original
% IDF_new       : nom complet du fichier à créer
% variables     : nom des variables à modifier
% valeurs(opt)  : valeurs des variables définies, si l'entrée n'est pas
%                     specifiée une copie simple est effectuée.
% test          : teste si les variables son présentes 
%
% 
% Si l'entrée 'Variable' est présente la fonction recherche dans le fichier
% 'IDF_ini' les lignes de commentaires personnel signalés par '!$$'. Ces
% commentaires permettent de signaler les valeurs à modifier sans altérer
% le fonctionnement avec EnergyPlus. Ils indiquent le nom des variables à
% placer et leurs positions parmi les lignes suivantes du fichier idf.
% 
% La valeur associée au nom du paramètre est alors placée à la position indiquée
% 
% 
% Exemple simple:
% Pour modifier l'épaisseur de la dalle et le type de rugosité
% l'epaisseur correspond au 3eme paramètre le type de surface au 2nd
% -----------------------------
% !$$ EpDalle 3 / TypeSurf 2
% Material,
%     Dalle en béton,          !- Name
%     MediumRough,             !- Roughness
%     0.2,                     !- Thickness {m}
%     1.45,                    !- Conductivity {W/m-K}
%     2080,                    !- Density {kg/m3}
%     900;                     !- Specific Heat {J/kg-K}
% -----------------------------
%    
% -----------------------------
% !$$ TypeSurf 2 EpDalle 3
% Material,
% ....
% -----------------------------
%
% -----------------------------
% !$$ TypeSurf -2
% !$$ EpDalle +3
% Material,
% ....
% -----------------------------
%
% -----------------------------
% !$$ BrickVaporResistance #12,567024-12,21373*exp(-267,0211*((13.39871602+(X-0.5)*3,185137578)*2E-7*299.85^0.81/101325)^0,7*(0,4/8)^-0,7)#2
% !$$ BrickIsotherm #(1.5+X*7.4)/1791.02#3
% !$$ BrickIsotherm #(0.66-X*0.2)/1791.02#4
% !$$ BrickIsotherm #(14-X*6.3)/1791.02#5
% !$$ BrickIsotherm #(20-X*11.5)/1791.02#6
% MaterialProperty:MoisturePenetrationDepth:Settings,
%     Brick,                   !- Name
% ....
% -----------------------------
%
% Les séparateurs penvent etre: espaceS et \ et /
% Les noms attribués ne doivent donc pas comptenir ces séparateurs...
%
% Le numéro de ligne peut etre défini comme un vecteur MatLab {1,[5:2:9],2}
% 
% L'operation mathématique doit etre definie juste devant 


% References
%
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
%   02/12/2013  Ecriture matlab des lignes à modifier
%               Opération matématique entre valiable et valeur présente
%   19/07/2013  Correction du problème au niveau des lignes vides

% A FAIRE:
%     
%     
%     


if (nargin < 4)
    %Pas de valeurs presentes: copie simple
    copyfile(IDF_ini,IDF_new);
else
    
    % Condition d'affichage des resultats
    if (nargin < 5) affichage=false; 
    else affichage=logical(test); end
    
    % Recherche des éléments à ne pas modifier (NaN)
    A=isnan(valeurs);
    % Si rien n'est à modifier, copie simple.
    if all(A)
        modif_IDF(IDF_ini,IDF_new)
        return
    end    

    
    variables=variables([find([variables.actif]),find(~[variables.actif])]);
    
    pile=cell(0,4); % stockage des remplacements à venir {Ligne,Nom,Op,Val}
    nb_com = 0;     % nombre de remplacements trouvés
    nb_rempl = 0;   % nombre de remplacements effectué
    trouve = false(length(variables),1);  % variables trouvées
    
    % Ouverture des fichiers en lecture et en écriture
    fid = fopen(IDF_ini,'r');
    fod = fopen(IDF_new,'w');
    
    % Lecture de la premiere ligne
    ligne  = fgets(fid);

    % Boucle tant qu'il y a des lignes
    while ischar(ligne)
        % ---------------------------------------------
        %|Si une notes de remplacement est identifiées |
        % ---------------------------------------------
        if ( strfind(ligne, char('!$$')) )
            % Coupe selon les espaces
            A = regexp(ligne(4:end), '[\s]','split');
            % Effaces les réponses vides
            k=1; while true,
                if isempty(A{k}), A(k)=[]; else,  k=k+1; end
                if k>length(A), break, end
            end
            
            % Mise en forme: {Nom(s), Ligne(s)}
            if mod(length(A),2)~=0
                error('La ligne suivante est incorrecte:\n%s',ligne)
            end
            A = reshape(A,2,[])';
            
            % Traitement des notes trouvées
            for k=1:size(A,1)


                % Recherche d'une opération  
                operation=[];              
                if ~isempty(strfind( '+-*/', A{k,2}(1)))
                    operation = ['V' A{k,2}(1) 'X'];
                    A{k,2}(1)=[];
                elseif  ~isempty(strfind( '#', A{k,2}(1)))
                    [operation,A{k,2}] = regexp(A{k,2},'#([\w\(\)\[\]\^.*+-/]*)#|#*','tokens','split');
                    if isempty(operation{1})
                        error('La ligne suivante n''a pas été interprétée:\n%s',ligne)
                    end
                    operation = char(operation{1});
                    A{k,2} = strjoin(A{k,2},'');
                end
                if ~isempty(operation)                    
                    % remplacement du nom des variables presentes dans l'operation                    
                    for a=1:length({variables.nom})                  
                        if strfind(operation, variables(a).nom)~=0
                            operation = strrep(operation, variables(a).nom, num2str(valeurs(a),'%f') );
                            trouve(a)=true; % La variable est présente
                        end
                    end
                    if strfind(operation, 'IDSim')~=0
                        operation = strrep(operation, 'IDSim', num2str(IDSim, '%d') );
                    end
                    operation = strrep(operation, 'V', '%1$f'); % valeur initiale
                    operation = strrep(operation, 'X', '%2$f'); % valeur échantillonné
                end
                
                % Mise en forme des numéros de lignes
                lignes=eval(regexp(A{k,2},'([0-9:;,/{/}/[/] ])+','match','once'));
                if iscell(lignes)
                    lignes=cell2mat(lignes);
                end
                
                
                % Recherche de la variables titre dans les entrées
                rech = strcmp({variables.nom}, A{k,1});
                if any(rech) 
                    % Identification du type de donnée et mise en forme
                    index = min(find(rech)); %id de la variable                    
                    if strcmpi(variables(index).loi, 'Discret')
                        chaine = variables(index).limites{valeurs(index)};
                        if isnumeric(chaine)
                            chaine = num2str(chaine, '%f');
                        else
                            chaine = char(chaine);
                        end
                    else
                        chaine = num2str(valeurs(index), '%f');
                    end
                    
                elseif strcmp(A{k,1}, 'IDSim')
                    % La variable correspond a l ID de la simulation
                    chaine = num2str(IDSim, '%d');
                else
                    if affichage, fprintf('Erreur, variable #%s# non trouvée !\n', A{k,1} );  end
                    continue
                end
                
                


                % Ajout de la modification dans la pile
                trouve(index)=true;
                for l=lignes(:)'
                    pile = vertcat (pile, {l, A{k,1}, operation, chaine} );
                    nb_com = nb_com + 1;
                end
            end        

            % Trie selon les lignes
            % Rq: ordre des opérations = ordre des variables
            pile = sortrows(pile,1);
            
            %Copie la note dans le fichier enfant (optionnel)
            fprintf(fod,'%s',ligne); 
            
            % Raz: Fin de l'object
            char_fin='';
            
% UTILE ??? =======================================
            % Condition d'écriture directe (ligne = -1)
            while ~isempty(pile) && pile{1,1}<=0
                % Cas particulier (ex : affichage du nom du fichier EPW)
                if (pile{1,1}==-1)
                    pile{1,4} = ['!--> ' pile{1,4}];
                end
                fprintf(fod,'%s\n', pile{1,4});
                pile(1,:) = [];   % Efface la variable de la pile
                nb_rempl = nb_rempl + 1;
            end
% ??? UTILE =======================================  
            
            % Passage à la ligne suivante
            ligne = fgets(fid); 
            continue
        end
        
        % ------------------------------------
        %|Si des modifications sont à prévoir |
        % ------------------------------------
        if ~isempty(pile)            
            [ligne_val, ligne_com] = strtok(ligne);
            
            % La ligne est vide OU est un commentaire
            if isempty(ligne_val) || ligne_val(1)=='!'
                % Copie et passage à la ligne suivante sans décrémentation
                fprintf(fod,'%s',ligne);
                ligne = fgets(fid);
                continue
            end
            
            % Réalisation des changements
            if (pile{1,1}==0)

                % Recherche du caractère de fin , ou ;
                char_fin = ligne_val(end);
                while ~or( char_fin==',', char_fin==';')
                    [ligne_1, ligne_com] = strtok(ligne_com);
                    ligne_val = [ligne_val ' ' ligne_1];
                    char_fin = ligne_val(end);
                    if isempty (ligne_com)
                        break
                    end
                end               
                if ~isempty(ligne_com)
                    while ligne_com(1)==' '
                        ligne_com(1)=[];
                    end
                end
                ligne_val(end)=[];
                
                % Traitement de la ligne en cours
                while ~isempty(pile) && pile{1,1}==0
                    if isempty(pile{1,3})
                        ligne_val = pile{1,4};                    
                    else  % Opération mathématique
                        
                        V = str2num(ligne_val);     % Valeur initiale de la ligne
                        X = str2num(pile{1,4});     % Valeur echantillonne
                        if isempty(V) || isempty(X)
                            error(sprintf('Opération matématique impossible !\n Variable:\t''%s''\n Opération:\t''%s''\n Ligne:\t''%s''', pile{1,2}, strcat(ligne_val,pile{1,[3 4]}),ligne))
                        end
                        ligne_val = num2str( eval(sprintf(pile{1,3},V,X) ) );
                    end
                    
                    nb_rempl = nb_rempl + 1;  % Compte un remplacement
                    pile(1,:) = [];           % Effacement de la pile
                end

                % Recomposition de la ligne modifiée
                espaces='';
                if length(ligne_val)< 24
                    espaces(1: (24-length(ligne_val)) ) = ' ';
                    ligne = ['    ' ligne_val char_fin espaces ligne_com]; 
                elseif length(ligne_val)< 35
                    espaces(1: (35-length(ligne_val)) ) = ' ';
                    ligne = ['    ' ligne_val char_fin espaces ligne_com]; 
                else
                    fprintf(fod,'%s\n',['    ' ligne_val char_fin]);
                    espaces(1:40) = ' ';
                    ligne = [espaces ligne_com]; 
                end

            end   
            
            % Décrémentation des modifications restantes dans la pile
            if ~isempty (pile)
                if char_fin==';'
                    error(sprintf('Variable:\t''%s'' --> Modification après la fin de l''object !\n ', pile{:,2}))
                end 
                
%                 %Vérification qu'il n'y ai pas d'autre variables pour la meme position
%                 if (pile{1,2}<1)
%                     fprintf('Erreur, position de la variable #%s# déjà attribuée !\n', pile{1,1});
%                     pause
%                 end

                %decrémentation des indices restant
                pile(:,1) = num2cell (cell2mat(pile(:,1))-1);
            end
        end
        
        fprintf(fod,'%s',ligne);
        ligne = fgets(fid);
        
    end
    
     fclose(fid);
     fclose(fod);
    
    if affichage
        fprintf('-> %d remplacement(s) effectués sur %d variable(s).\n', nb_rempl, sum(trouve));
        if (nb_com~=nb_rempl)
            fprintf('!!!%d remplacements impossibles!\n', nb_com-nb_rempl);
            fprintf('Continuer...\n' );
            pause
        end
        if ~all(trouve)
            disp ('----------------------------');
            fprintf('Les variables suivantes n''ont pas été attribuées:\n', nb_com);
            disp({variables(~trouve).nom})
            disp('L''échantillonnage du plan de simulation risque de ne pas être correct.')
            error('Veuilliez corriger les variables !');
        end
    end
end



