function [etat, time] = test_sim(model,rep,liste,old_etat)
liste=liste(:,1);
etat = zeros(length(liste),1);
time = nan(length(liste),1);

if nargin==4 && numel(old_etat)==numel(liste)
    etat = old_etat(:);
end
essais = etat<1;


switch upper(model)
    case {'E+','EP','ENERGYPLUS'}
        for id=find(essais')
            file = fullfile(rep,liste{id},'eplusout.end');

            if exist ( file ,'file' )
                fid = fopen(file,'r');
                line = fgets(fid);
                if strncmp(line, 'EnergyPlus Completed Successfully', 33)
                    etat(id) = 1; % ok
                    tokenStrings = regexp(line,'Elapsed Time=(\d+)hr\s+(\d+)min\s+(\d+.\d+)sec', 'tokens');
        %            if isempty(tokenStrings), keyboard, end
                    time(id) = str2double(tokenStrings{1})*[3600 60 1]';  %temp en secondes
                else
                    etat(id) = -1; % erreur présente
                end
                fclose(fid);
            end
        end

    case {'DOMUS'}
        for id=find(essais')
            
%             file = fullfile(rep,['#' liste{id} '.idf'],'saidas','sim001','simulationLog.txt');
%             if exist(file,'file')
%                 fid = fopen(file,'r');
%                 fseek(fid, -40, 'eof');
%                 line = fscanf(fid,'%c');
%                 if isempty(strfind(line, 'Execução terminada com sucesso !'))
%                     etat(id) = -1; % erreur présente
%                 else
%                     etat(id) = 1; % ok
%                     
%                     frewind(fid); line = fgetl(fid);
%                     while ~strncmp(line,'@Inicio Simulacao',17), line = fgetl(fid); end
%                     tokenStart = regexp(line,'\D(\d+)/(\d+)/(\d+) - (\d+):(\d+):(\d+)', 'tokens');
%                     while ~strncmp(line,'@Fim simulacao',14), line = fgetl(fid); end
%                     tokenEnd = regexp(line,'\D(\d+)/(\d+)/(\d+) - (\d+):(\d+):(\d+)', 'tokens');
%                     
%                     time(id) = (datenum(str2double(tokenEnd{1})) - datenum(str2double(tokenStart{1})) )*24*3600;  % em seconds
%                 end
%                 fclose(fid)
%             end
            
            file = fullfile(rep,['#' liste{id} '.idf'],'saidas','sim001','terminou.txt');
            if exist(file,'file')
                etat(id) = 1;
                time(id) = nan;
            else
                etat(id) = -1; % erreur présente
            end
        end
    otherwise
        error('Modele non reconnu')
end
