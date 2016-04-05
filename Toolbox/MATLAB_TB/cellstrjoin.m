function joinedCell = cellstrjoin(c, aDelim)
%CELLSTRJOIN Join cell matix of strings into single column cell array
%   cellstrjoin({'Sloubi ',' !!'}, {'1';'2';'3'})

numDelim = size(aDelim,1);
numC = size(c,1);

joinedCell = cell(max(numDelim,numC),1);


if numDelim==1
    for k=1:numC
        joinedCell{k} = strjoin(c(k,:), aDelim);
    end
elseif numC==1
    for k=1:numDelim
        joinedCell{k} = strjoin(c, aDelim(k,:));
    end
else
    if numDelim~=numC
        error('Wrong size of delimiter')
    end    
    for k=1:numC
        joinedCell(k) = strjoin(c(k,:), aDelim(k,:));
    end
end



