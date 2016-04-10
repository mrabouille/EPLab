function [liste,loc] = listnoms(variable,nomvariable,prefixe)
if nargin<3 || isempty(prefixe)
    prefixe = '';
end


if nargin==1 || isempty(nomvariable)
    temps = fieldnames(variable);
else
    temps = eval(['fieldnames(variable.' nomvariable ')'] );
end

liste=cell(0,1);
loc = [];
for k=temps'
    if nargin==1 || isempty(nomvariable)
        nom = k{1};
    else
        nom = horzcat(nomvariable, '.', k{1} );
    end
    
    if length(variable)==1
        if isstruct(variable.(nom))
            liste=vertcat(liste,listnoms(variable,nom,prefixe) );
        else
            liste=vertcat(liste,sprintf('%s.%s',prefixe,nom) );
        end
    else
        loc=vertcat(loc, [1:length(variable)]');
        for l=1:length(variable)
            if isstruct(variable(l).(nom))
                liste=vertcat(liste,listnoms(variable(l),nom,sprintf('%s(%d)',prefixe,l)) );
            else
                liste=vertcat(liste,sprintf('%s(%d).%s',prefixe,l,nom) );
            end
        end
    end
end