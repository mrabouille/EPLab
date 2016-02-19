function sequence = haltonseq(ech,dim)
% haltonseq - S�quence quasi-al�atoire de Halton
%
% Description
%   Tirs speudo-al�atoire uniformes dans l'hypercube de taille 1
%
% Requirements
% 
% References
%   Wikip�dia :D
%
% Authors
%   Mickael RABOUILLE <mickael.rabouille(at)gmail.com>
%
% License
%   The program is free for non-commercial academic use. Please 
%   contact the authors if you are interested in using the software
%   for commercial purposes. The software must not modified or
%   re-distributed without prior permission of the authors.
%
% Changes
%   04/10/2013  Last Change

if ~exist('dim','var')
    dim = 2;
elseif(dim >99)
error('La dimension de la s�quence demand�e est trop importante.')
end

sequence = zeros(ech,dim);

base=2;
for d=1:dim
    % La base est choisie dans les nombres premiers pour reduire la 
    % discr�pence. Voir Faure, 1980 repris dans Niederreiter, 1992
    % cf: Franco J., Planification d�exp�riences num�riques en phase exploratoire pour la simulation des ph�nom�nes complexes 2008.
    while ~isprime(base)
        base=base+1;
    end

    for nb=1:ech
        sequence(nb,d) = halton(nb, base);
    end
    base=base+1;   
end

end

 
function result = halton(index, base)
result = 0;
f = 1 / base;
i = index;
while (i > 0)
    result = result + f*rem(i,base);
    i = floor(i / base);
    f = f / base;
end
end