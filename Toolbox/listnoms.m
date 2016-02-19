function liste = listnoms(variable,nomvariable,prefixe)
if nargin<3 || isempty(prefixe)
    prefixe = '';
end


if nargin==1 || isempty(nomvariable)
    temps = fieldnames(variable);
else
    temps = eval(['fieldnames(variable.' nomvariable ')'] );
end

liste=cell(0,1);
for k=temps'
    if nargin==1 || isempty(nomvariable)
        nom = k{1};
    else
        nom = horzcat(nomvariable, '.', k{1} );
    end
    
    if eval(['isstruct(variable.' nom ')'])
        liste=vertcat(liste,listnoms(variable,nom,prefixe) );
    else
        
        liste=vertcat(liste,[prefixe nom] );  
    end
end