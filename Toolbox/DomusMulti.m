function DomusMulti(rep,noms,nb_proc,run,dir_model)
% Gï¿½nere les fichiers .bat qui executent plusieures simulations Domus.
%     rep         : Repertoire des fichiers de simulation
%     noms        : Noms des fichiers *.idf et *.epw
%     nb_proc     : Nombre de groupe de simulation (nbs de processeurs)
%     run(opt)    : Si vrais, lance la simulation
% Basé sur le rôle créé par Michael Rabouille, un nouveau rôle a été faite pour la version Domus, réécrit par Lais Lagos

IDFs=noms(:,1);   

delete( fullfile(rep,'SimPart*.bat') )

nb_tir = max(size(IDFs));

%DOMUS
for i=1:nb_proc
    fid(i) = fopen(fullfile(rep,sprintf('SimPart%d.bat',i)),'w'); %#ok<AGROW>
%    fprintf(fid(i), '@echo off\n');
    fprintf(fid(i), 'cd /d "%s"\n',dir_model);
end

for i=1:nb_tir
    group=mod(i-1,nb_proc)+1;
    fprintf(fid(group), 'title %s\n',char(IDFs(i)));
    fprintf(fid(group), 'IF EXIST "%1$s" rmdir /s /q "%1$s"\n',fullfile(rep,['#' char(IDFs(i)) '.idf'],'saidas'));
    fprintf(fid(group), 'DomusConsole.exe -q -txt "%s.idf"\n',fullfile(rep,char(IDFs(i))));
end


% SimMulti.bat
fod = fopen(fullfile(rep,'SimMulti.bat'),'w');
fprintf(fod, '@echo off\n');
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
        [status,result] = dos('CALL SimMulti.bat');
        cd(locpath)
         
        if status
            disp('Le fichier batch ne s''est pas executé correctement :');
            error(result);
        end        
    end
end
    
end

