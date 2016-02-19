function barre_avancement(id)
%   23/05/2013  Last Change

% 
% Intégration, voir: waitbar() 
% 

global affichage

% CAS PARTICULIER
if ~isnumeric(id)
    switch upper(id)
        case 'RAZ'
            if isfield(affichage, 'id_old'), affichage = rmfield(affichage, 'id_old');  end
            if isfield(affichage, 'nb_tir'), affichage = rmfield(affichage, 'nb_tir');  end
        case 'PLUS'
            if ~isfield(affichage,'id_old')
                barre_avancement(-1) %initialisation et avance
            else
                barre_avancement(affichage.id_old+1) % avance
            end
        case 'STOP'
            fprintf(repmat('-',1,affichage.largeur-affichage.avancement));  %finalisation de la ligne
            barre_avancement('FIN') % arret
        case 'FIN'
            if ~isfield(affichage,'id_old')
                return
            end
            fprintf('%1.3f sec.\n',toc);    %affichage du temp
            barre_avancement('RAZ')         %clear
    end    
    return
end

% INIT VARS
if ~exist('affichage','var') || ~isfield(affichage,'largeur')
    error('La barre d''avancement n''est pas correctement initialisée')
elseif ~isfield(affichage,'nb_tir') || affichage.nb_tir==0
    global params
    affichage.nb_tir = params.nb_tir;
end

% INIT BARRE
if ~isfield(affichage,'id_old') || affichage.id_old>id || id==-1
    tic;
    fprintf([repmat('_',1,affichage.largeur) '\n']);
    affichage.pas = affichage.largeur/affichage.nb_tir;
    affichage.avancement=0;
    id=1;
end

affichage.id_old=id;

% AVANCE
if id*affichage.pas>affichage.avancement
    avance = round(id*affichage.pas-affichage.avancement);
    affichage.avancement=affichage.avancement+avance;
    fprintf(repmat('|',1,avance));
end

% FIN
if id>=affichage.nb_tir
        barre_avancement('FIN')
end
