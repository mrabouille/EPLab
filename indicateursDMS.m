function indicateurs=indicateursDMS(resSimul, plages, range_temporal)

%global geometrie
global legende

% read the legends only at the first pass
leg = ~isfield(legende,'indicateurs');

if ~range_temporal==0
    %% Temporal analysis
    
    if range_temporal==-1
        plageSet=1:length(plages);
    else
        % only one range is studied
        plageSet=range_temporal;
    end
    
    for k=plageSet
        
        if isfield(resSimul,'pixelcount')
            
            for s=1:size(resSimul.pixelcount.areaEns,2)
                indicateurs(k).(['pixelcount' num2str(s)]) = resSimul.pixelcount.areaEns(plages(k).index_h,s);
            end
            if leg
                for s=1:size(resSimul.pixelcount.areaEns,2)
                    legende.indicateurs(k).(['pixelcount' num2str(s)]) = {sprintf('AreaEns %s-%s %s [-]',resSimul.pixelcount.surfaces{s,3}, resSimul.pixelcount.surfaces{s,2},plages(k).nom)};
                end
            end
            
            for s=1:size(resSimul.pixelcount.areaEns,2)
                indicateurs(k).(['day_pixelcount' num2str(s)]) = mean( reshape( resSimul.pixelcount.areaEns(plages(k).index_h,s) ,24,[] ) ,2);
            end
            if leg
                for s=1:size(resSimul.pixelcount.areaEns,2)
                    legende.indicateurs(k).(['day_pixelcount' num2str(s)]) = {sprintf('HourlyMean AreaEns %s-%s %s [-]',resSimul.pixelcount.surfaces{s,3}, resSimul.pixelcount.surfaces{s,2},plages(k).nom)};
                end
            end
        end
        
        
        
        
        
    end
else
    
    
    for k=1:length(plages)
    
        %% pixelcount       
        if isfield(resSimul,'pixelcount')
            indicateurs(k).pixelcount = [mean(resSimul.pixelcount.areaEns(plages(k).index_h,:),1)'];
            if leg
                legende.indicateurs(k).pixelcount = cellstrjoin( {'Moyenne AreaEns ', '-', [' ' plages(k).nom ' [-]']}, resSimul.pixelcount.surfaces(:,[3 2]));
            end
        end
    
    
    end
end

function B=nansum(A,dim)
A(isnan(A))=0;
B=sum(A,dim);

function output = myrange(output,set)
if length(output)==1 && output(1)==0
    return
else
    output = output(set);
end

function output = my24range(output,set)
if length(output)==1 && output(1)==0
    return
else
    output = mean( reshape( output(set) ,24,[] ) ,2);
end

function output = mysum(output,set)
if length(output)==1 && output(1)==0
    return
else
    output = sum(output(set));
end

function output = mymax(output,set)
if length(output)==1 && output(1)==0
    return
else
    output = max(output(set));
end