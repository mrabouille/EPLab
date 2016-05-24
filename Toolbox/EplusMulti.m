function EplusMulti(rep,noms,nb_proc,run)
% Gï¿½nere les fichiers .bat qui executent plusieures simulations energyPlus.
% 
% 
%     rep         : Repertoire des fichiers de simulation
%     noms        : Noms des fichiers *.idf et *.epw
%     nb_proc     : Nombre de groupe de simulation (nbs de processeurs)
%     run(opt)    : Si vrais, lance la simulation
% 
% 
% SOUMISSIONNAIRES :
% Mickael Rabouille (crï¿½ation)
% Version du 06/12/2012


if (size(noms,2)==2)
    IDFs=noms(:,1);
    EPWs=noms(:,2);
%{
    for i=EPWs
        if ~exist ( fullfile( rep, [ i '.epw']) ,'file' )
            error ('Le fichier mï¿½tï¿½o ''%s'' n''est pas prï¿½sent !', i);
        end
    end
%} 
else
    % Pas de fichier EPW: utilisation du nom gï¿½nï¿½rique
    IDFs=noms(:,1);
    EPWs(size(IDFs))='meteo';
end

delete( fullfile(rep,'SimPart*.bat') )

nb_tir = max(size(IDFs));
% fid(XXX) => Simpart_XXX.bat

%ENERGYPLUS
for i=1:nb_proc
    fid(i) = fopen(fullfile(rep,sprintf('SimPart%d.bat',i)),'w'); %#ok<AGROW>
    fprintf(fid(i), '@echo off\n');
end

for i=1:nb_tir
    group=mod(i-1,nb_proc)+1;
    fprintf(fid(group), 'title %1$s\nCALL RunEPlus.bat %1$s %2$s\n',char(IDFs(i)), char(EPWs(i)) );
end


% SimMulti.bat
fod = fopen(fullfile(rep,'SimMulti.bat'),'w');
fprintf(fod, '@echo off\n');
%fprintf(fod, 'CD %s\n',rep);
for i=1:nb_proc
    fprintf(fid(i), 'EXIT\n');
    fclose(fid(i));
    fprintf(fod, 'START SimPart%d.bat \n',i );    
end
fclose(fod);

if (nargin > 3)
    if (run)
        
        locpath = pwd;
        cd(rep)
        [status,result] = dos('SimMulti.bat');
        cd(locpath)
         
        if status
            disp('Le fichier batch ne s''est pas executé correctement :');
            error(result);
        end        
    end
end
    
end