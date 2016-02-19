function DomusMulti(rep,IDF_dir,nb_proc,run)


% Gï¿½nere les fichiers .bat qui executent plusieures simulations Domus.
%     rep         : Repertoire des fichiers de simulation
%     noms        : Noms des fichiers *.idf et *.epw
%     nb_proc     : Nombre de groupe de simulation (nbs de processeurs)
%     run(opt)    : Si vrais, lance la simulation
% Basé sur le rôle créé par Michael Rabouille, un nouveau rôle a été faite pour la version Domus, réécrit par Lais Lagos

delete( fullfile(rep,'SimPart*.bat') )

nb_tir = max(size(IDFs));

for i=1:nb_proc
    fid(i) = fopen(fullfile(rep,sprintf('SimPart%d.bat',i)),'w'); %#ok<AGROW>
    fprintf(fid(i), 'cd "C:\Program Files (x86)\Domus - Eletrobras"\ n ');
end

for i=1:nb_tir
    group=mod(i-1,nb_proc)+1;
    fprintf(fid(group), 'title %1$s\nCALL DomusConsole.exe %1$s %2$s\n',char(IDFs(i)), char(EPWs(i)) );
end

fod = fopen(fullfile(rep,'SimMulti.bat'),'w');
fprintf(fod, 'cd "C:\Program Files (x86)\Domus - Eletrobras"\ n ');
fprintf(fod, ' CD %s\ n',rep);
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
