function resSimul = DomusExtract(resPath)


%{
file = fullfile(resPath,'DadosRelatorios.txt');
fid = fopen(file,'r');
if fid ~= -1
    %   Tag-<NAME>-
    textscan(fid,'Tag-%s-',1)
    %   Periodo 1/1 1/31 - 0:0->23:0
    textscan(fid,'Periodo %d/%d %d/%d - %d:%d->%d:%d',1)
    %   TotalZonas 1
    TotalZonas = textscan(fid,'TotalZonas %d',1)
    %   RTQSimul 0
    textscan(fid,'RTQSimul %d')
    %   RTQ 0
    textscan(fid,'RTQ %d')
    %   Zona 1,zona
    ZonasDetalhadas = textscan(fid,'Zona %*d,%s',TotalZonas{1},'CollectOutput',1)
    %   Ocupacao 1
    textscan(fid,'Ocupacao %d',1)
    %   Amostragens 3600 3600 3600 3600 3600 3600 
    textscan(fid,'Amostragens %d%d%d%d%d%d',1)


    %   Monitoracoes 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 
    % zona
    % temperatura
    % umidade
    % pmv e ppd
    % consumo energia
    % carga termica
    % estatisticas
    % mofo
    % perfil paredes
    % ganho termico
    % ats
    % ace
    % sistemas primario/secundario
    % fotovoltaico
    % controlador
    % acs
    % propriedades edificacao
    % temperatura interna paredes
    textscan(fid,'Monitoracoes %d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d',1)
    %   Paredes 6
    TotalParedes = textscan(fid,'Paredes %d',1,'CollectOutput',1)
    %   Parede 1 Parede#1, 9.00 0 0 0 0 0 0 0 0
    ParedesDetalhadas = textscan(fid,'Parede %*d%s%f%f%f%f%f%f%f%f%f',TotalParedes{1},'Delimiter',{',',' '},'CollectOutput',1,'MultipleDelimsAsOne',1)
    %   [Dados Sistema Primario]
    %   	{Dados = 0,0,0,0,0,0,1,0,0}
    %   [Monitorar Sistema HVAC = 0]
    %   [Passo Tempo Rel HVAC = 3600]
    %   [Monitorar Consumo HVAC = 0]
    %   [Nº Fancoils = 0]
    %   [Nº Chillers Ar = 0]
    %   [Nº Chillers Agua = 0]
    %   [Nº Torres Resf. = 0]
    %   [Nº Boillers = 0]
    %   [Nº Bombas Aq. = 0]
    %   [Nº Bombas Ag. = 0]
    %   [Nº Bombas Cond. = 0]
    %   [Nº Tanque Agua Gelada = 0]
    %   [Nº Bombas Ag. Sec = 0]
    fclose(fid);
end

%}


file = fullfile(resPath, 'Zon1TUP.txt');
fid = fopen(file,'r');
if fid ~= -1
    datas = textscan(fid,'%f%f%f%f %f:%f:%f','HeaderLines',3);
    
    resSimul.TUP.Tas = datas{1};
    resSimul.TUP.Humid = datas{2};
    
    [year,~,~,~,~,~] = datevec(now);        % Be careful with the leap years
    resSimul.TUP.timeVec = horzcat(repmat(year,size(datas{1},1),1),datas{3:7});
    resSimul.TUP.timeNum = datenummx(resSimul.TUP.timeVec);  % built-in function undocumented
    
    fclose(fid);
end


%% pixelcount
if exist(fullfile(resPath,'pixelcount'),'dir')
    
%     file = fullfile(resPath,'pixelcount', 'EnergiaSolarDiaria.txt');
%     fid = fopen(file,'r');
%     if fid ~= -1
%         fclose(fid);
%     end
    
    
%     file = fullfile(resPath,'pixelcount', 'RelatorioEnergiaDireta.txt');
%     fid = fopen(file,'r');
%     if fid ~= -1
%         fclose(fid);
%     end

    listFile = dir(fullfile(resPath,'pixelcount'));
    idSurface = 0;
    for fileName = {listFile.name}
        tokens = regexp(fileName{1},'(\w*) - (\w*).txt','tokens');
        if ~isempty(tokens)
            idSurface = idSurface+1;
%                                    id         name          surface       filename
            resSimul.pixelcount.surfaces(idSurface,:) = {idSurface, tokens{1}{2}, tokens{1}{1}, fileName{1}};
        end
    end
    for k=1:size(resSimul.pixelcount.surfaces,1)
        file = fullfile(resPath,'pixelcount', resSimul.pixelcount.surfaces{k,4});
        fid = fopen(file,'r');
        if fid == -1, error('Unable to read the file.'), end
        while ~strncmp('Área ens(%)',fgetl(fid),11), end
        fgetl(fid); warning('skip first ligne at 00:00')
        datas = textscan(fid,'%f%f%f %f:%f:%f %f%f');
        
        resSimul.pixelcount.areaEns(:,k) = datas{1};
        
        fclose(fid);
    end
    
    [year,~,~,~,~,~] = datevec(now);        % Be careful with the leap years
    resSimul.pixelcount.sunTimeVec = horzcat(repmat(year,size(datas{1},1),1),datas{2:6});
    resSimul.pixelcount.sunTimeNum = datenummx(resSimul.pixelcount.sunTimeVec);  % built-in function undocumented
    resSimul.pixelcount.sunAZM = datas{7};
    resSimul.pixelcount.sunALT = datas{8};
end

