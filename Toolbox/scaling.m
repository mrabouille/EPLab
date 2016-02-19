function scale=scaling(valeurs)
mini = min(valeurs);
maxi = max(valeurs);

plage = maxi-mini;
if plage==0
    scale =[mini*0.9,maxi*1.1];
    return
end
% Quand la plage de variation est 3 plus plus petite que la distance au 0 on zoom
facteur = 3;


if mini>0 && mini<plage*facteur
    bas = 0;
else
    bas = mini;
end


if maxi<0 && maxi>plage*facteur
    haut = 0;
else
    haut = maxi;  %10^ceil(log10( maxi )
end

scale =[bas,haut];