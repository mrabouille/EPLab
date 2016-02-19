function resultats= pre_traitement(params,dates,geometrie,donnees,extract_lum)
% PRE_TRAITEMENT analyse des données 
% 
% Réalise les premieres partires des calculs des critères. Toutes les 
% limitation au intervales d'etudesles et les sommes resultantes ne seront
% réalisée qu'au dernier moment.
% 
% 
% SOUMISSIONNAIRE :
% Mickael Rabouille (création)
% Version du 11/09/2012


%% Bilan aeraulique

% Zones d'etude = zone d'étude du confort
%   %    %   %   %   %   %    %    %    %   %warning ('nom de la variable incorrecte')

if isfield(geometrie,'confzones')
    zones_etude = [geometrie.confzones{:,1}]';
else
    warning('Zones d''etude = Toutes les zones')
    zones_etude = [geometrie.zones{:,1}]';
end
% (habitable ou *chauffée* ?)
surf_hab= sum(horzcat( geometrie.surfaces{ geometrie.floor,10} ));
volumes = [geometrie.zones{zones_etude,4}];

% passage en kwh : W sur 24h -> *24*3600/1000  = kJ par 24h -> /3600 = kWh par jour
if all(isfield(donnees.zone,{'P_int','P_out','P_surf','P_sys_air','P_sys_conv'}))
    %Zone Air Balance Internal Convective Gains Rate [W](Daily)
    resultats.bilan_air.P_int=sum(donnees.zone.P_int(:,zones_etude),2)*24/(1000*surf_hab);
    %Zone Air Balance Outdoor Air Transfer Rate [W](Daily)
    resultats.bilan_air.P_out=sum(donnees.zone.P_out(:,zones_etude),2)*24/(1000*surf_hab);
    %Zone Air Balance Surface Convection Rate [W](Daily)
    resultats.bilan_air.P_surf=sum(donnees.zone.P_surf(:,zones_etude),2)*24/(1000*surf_hab);
    %Zone Air Balance System Air Transfer Rate [W](Daily)
    %Zone Air Balance System Convective Gains Rate [W](Daily)
    resultats.bilan_air.P_sys=(sum(donnees.zone.P_sys_air(:,zones_etude),2)+sum(donnees.zone.P_sys_conv(:,zones_etude),2))*24/(1000*surf_hab);
end
%% Consomations elec/sys

% Whole Building:Facility Total Purchased Electric Energy [J](Hourly)
if isfield(donnees,'E_elec_tot')
    donnees.E_elec_tot = reshape(donnees.E_elec_tot,24,dates.nb_j );
    resultats.conso.Elec_tot=sum(donnees.E_elec_tot,1)/(3600*1000*surf_hab); %x [J] => x/(3600*1000) [kWh]
    resultats.conso.Elec_pic=max(donnees.E_elec_tot,[],1)/(3600*1000); %x [J] => x/(3600*1000) [kWh]/h = [kW]
end

%resultats.conso.Elec_sys=donnees.E_elec_sys;%/(1000*surf_hab);
%resultats.energie.conso_ventilation=sum(donnees.zone.E_fan ,2);
%resultats.energie.ray_vitrages = sum(donnees.zone.E_ray(:,zones_etude),2);
%resultats.energie.enveloppe -> Performances thermiques des surfaces


% Détail des consomations systemes (calcul des plages de fonctionnement)
if false
% Zone Air System Sensible Heating Energy [J](Hourly)
resultats.energie.heat = sum(donnees.zone.E_heat(:,zones_etude),2)/(3600*1000); %x [J] => x/(3600*1000) [kWh]
% Zone Air System Sensible Cooling Energy [J](Hourly)
resultats.energie.cool = sum(donnees.zone.E_cool(:,zones_etude),2)/(3600*1000);

% add Ideal Air System


% For PTAC
%ZONE%:Zone Packaged Terminal Air Conditioner Sensible Cooling Rate [W](Hourly)
resultats.energie.PTACcool.Sensible = sum(donnees.zone.E_coolSensible(:,zones_etude),2)/(1000); %[kWh]
    %ZONE%:Zone Packaged Terminal Air Conditioner Latent Cooling Rate [W](Hourly)
resultats.energie.PTACcool.Latent = sum(donnees.zone.E_coolLatent(:,zones_etude),2)/(1000); %[kWh]
   %ZONE%:Zone Packaged Terminal Air Conditioner Total Cooling Rate [W](Hourly)
resultats.energie.PTACcool.Total = sum(donnees.zone.E_coolTotal(:,zones_etude),2)/(1000); %[kWh]

end

% For IDEAL LOADS AIR SYSTEM
%ZONE% IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Sensible Heating Rate [W](Hourly)  donnees.zone.E_heatSensible(:,%ZONEID%)
resultats.energie.ILASheat.Sensible = sum(donnees.zone.E_heatSensible(:,zones_etude),2)/(1000); %[kWh]
%ZONE% IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Latent Heating Rate [W](Hourly)     donnees.zone.E_heatLatent(:,%ZONEID%)
resultats.energie.ILASheat.Latent = sum(donnees.zone.E_heatLatent(:,zones_etude),2)/(1000); %[kWh]
%ZONE% IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Total Heating Rate [W](Hourly)      donnees.zone.E_heatTotal(:,%ZONEID%)
resultats.energie.ILASheat.Total = sum(donnees.zone.E_heatTotal(:,zones_etude),2)/(1000); %[kWh]
%ZONE% IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Sensible Cooling Rate [W](Hourly)   donnees.zone.E_coolSensible(:,%ZONEID%)
resultats.energie.ILAScool.Sensible = sum(donnees.zone.E_coolSensible(:,zones_etude),2)/(1000); %[kWh]
%ZONE% IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Latent Cooling Rate [W](Hourly)     donnees.zone.E_coolLatent(:,%ZONEID%)
resultats.energie.ILAScool.Latent = sum(donnees.zone.E_coolLatent(:,zones_etude),2)/(1000); %[kWh]
%ZONE% IDEAL LOADS AIR SYSTEM:Zone Ideal Loads Zone Total Cooling Rate [W](Hourly)      donnees.zone.E_coolTotal(:,%ZONEID%)
resultats.energie.ILAScool.Total = sum(donnees.zone.E_coolTotal(:,zones_etude),2)/(1000); %[kWh]

resultats.energie.heat = resultats.energie.ILASheat.Total;
resultats.energie.cool = resultats.energie.ILAScool.Total;



%% Echanges thermiques des surfaces (toutes)
%{
Surface Inside Face Convection Heat Gain Energy [J]
Heat transferred by convection between the inside face and the zone air.
The values can be positive or negative with positive indicating heat is
being added to the surface’s face by convection.
Former Name: Prior to version 7.1, these outputs were called “Surface Int Convection Heat *
” and had used the opposite sign convention !!!

%}

% Index des parois(vitrées et opaques) par localisation (Nord /Sud /Est /Ouest /Plancher /Toiture)
parois = [  and(geometrie.ext,geometrie.nord),...
            and(geometrie.ext,geometrie.sud),...
            and(geometrie.ext,geometrie.est),...
            and(geometrie.ext,geometrie.ouest),...
            and(geometrie.ext,geometrie.floor),...
            and(geometrie.ext,geometrie.roof)];

opaques = parois;  opaques(geometrie.window,:)=0;

% Dim surface brute suivant l'orientation
surf_nord= sum(horzcat( geometrie.surfaces{ and(geometrie.wall,parois(:,1)),10} ));
surf_sud = sum(horzcat( geometrie.surfaces{ and(geometrie.wall,parois(:,2)),10} ));
surf_est = sum(horzcat( geometrie.surfaces{ and(geometrie.wall,parois(:,3)),10} ));
surf_ouest=sum(horzcat( geometrie.surfaces{ and(geometrie.wall,parois(:,4)),10} ));

surf_floor=sum(horzcat( geometrie.surfaces{ parois(:,5),10} ));
surf_roof =sum(horzcat( geometrie.surfaces{ parois(:,6),10} ));


% == Flux conVectif ==

if isfield(donnees.surface, 'E_conv_int')
    % Selection des flux (de la surface vers l'air) (inclu les vitrages)
    flux_nord= -donnees.surface.E_conv_int(:,parois(:,1));
    flux_sud = -donnees.surface.E_conv_int(:,parois(:,2));
    flux_est = -donnees.surface.E_conv_int(:,parois(:,3));
    flux_ouest=-donnees.surface.E_conv_int(:,parois(:,4));
    flux_floor=-donnees.surface.E_conv_int(:,parois(:,5));
    flux_roof =-donnees.surface.E_conv_int(:,parois(:,6));

    % Sommation des partie positives et négatives de chaque paroi pour chaque heure
    flux_nord = [ sum(flux_nord.*(flux_nord>0),2) , sum(flux_nord.*(flux_nord<0),2) ];
    flux_sud = [ sum(flux_sud.*(flux_sud>0),2) , sum(flux_sud.*(flux_sud<0),2) ];
    flux_est = [ sum(flux_est.*(flux_est>0),2) , sum(flux_est.*(flux_est<0),2) ];
    flux_ouest = [ sum(flux_ouest.*(flux_ouest>0),2) , sum(flux_ouest.*(flux_ouest<0),2) ];
    flux_floor = [ sum(flux_floor.*(flux_floor>0),2) , sum(flux_floor.*(flux_floor<0),2) ];
    flux_roof = [ sum(flux_roof.*(flux_roof>0),2) , sum(flux_roof.*(flux_roof<0),2) ];

    % Gains/pertes journalieres des surfaces par orientation en kWh/m²(de surf).jour
    % X [J par heure] --> X/3600 [J/sec]=[W]=[Wh]par heure
    resultats.surface.conv_int.card.gain = [ sum(reshape(flux_nord(:,1),24,dates.nb_j ),1)'/(3600*1000*surf_nord),...
                                            sum(reshape(flux_sud(:,1),24,dates.nb_j),1)' / (3600*1000*surf_sud),...
                                            sum(reshape(flux_est(:,1),24,dates.nb_j),1)' / (3600*1000*surf_est),...
                                            sum(reshape(flux_ouest(:,1),24,dates.nb_j),1)' / (3600*1000*surf_ouest),...
                                            sum(reshape(flux_floor(:,1),24,dates.nb_j),1)' / (3600*1000*surf_floor),...
                                            sum(reshape(flux_roof(:,1),24,dates.nb_j),1)' / (3600*1000*surf_roof)];

    resultats.surface.conv_int.card.loss = [ sum(reshape(flux_nord(:,2),24,dates.nb_j),1)' / (3600*1000*surf_nord),...
                                            sum(reshape(flux_sud(:,2),24,dates.nb_j),1)' / (3600*1000*surf_sud),...
                                            sum(reshape(flux_est(:,2),24,dates.nb_j),1)' / (3600*1000*surf_est),...
                                            sum(reshape(flux_ouest(:,2),24,dates.nb_j),1)' / (3600*1000*surf_ouest),...
                                            sum(reshape(flux_floor(:,2),24,dates.nb_j),1)' / (3600*1000*surf_floor),...
                                            sum(reshape(flux_roof(:,2),24,dates.nb_j),1)' / (3600*1000*surf_roof)];


    % Gains/pertes journalieres des surfaces verticales en kWh/m²(de surf).jour
    resultats.surface.conv_int.verticales = [ sum(reshape( flux_nord(:,1)+flux_sud(:,1)+flux_est(:,1)+flux_ouest(:,1) ,24,dates.nb_j ),1)',...
                                    sum(reshape( flux_nord(:,2)+flux_sud(:,2)+flux_est(:,2)+flux_ouest(:,2) ,24,dates.nb_j ),1)']/(3600*1000*(surf_nord + surf_sud + surf_est + surf_ouest));   


    % Gains/pertes journalieres de l'enveloppe totale en kWh/m²_hab.jour
    resultats.surface.conv_int.enveloppe = [ sum(reshape(  flux_nord(:,1)+flux_sud(:,1)+flux_est(:,1)+flux_ouest(:,1)+flux_floor(:,1)+flux_roof(:,1) ,24,dates.nb_j),1)',...
                                   sum(reshape(  flux_nord(:,2)+flux_sud(:,2)+flux_est(:,2)+flux_ouest(:,2)+flux_floor(:,2)+flux_roof(:,2) ,24,dates.nb_j),1)']/(3600*1000*(surf_hab));


    clear flux_nord flux_sud flux_est flux_ouest flux_floor flux_roof
end

%Surface Outside Face Convection Heat Gain Rate [W](Hourly)
if isfield(donnees.surface, 'P_conv_ext_h')    
    resultats.surface.conv_ext.card = [ sum( donnees.surface.P_conv_ext_h(:,parois(:,1)) ,2) / (1000*surf_nord),...
                                        sum( donnees.surface.P_conv_ext_h(:,parois(:,2)) ,2) / (1000*surf_sud),...
                                        sum( donnees.surface.P_conv_ext_h(:,parois(:,3)) ,2) / (1000*surf_est),...
                                        sum( donnees.surface.P_conv_ext_h(:,parois(:,4)) ,2) / (1000*surf_ouest),...
                                        sum( donnees.surface.P_conv_ext_h(:,parois(:,5)) ,2) / (1000*surf_floor),...
                                        sum( donnees.surface.P_conv_ext_h(:,parois(:,6)) ,2) / (1000*surf_roof)];   %en kWh/m²(de surf) horaire
end
%% == Flux conDuctif ==
% (centre de la parois vers la face interieure/exterieure)


if isfield(donnees.surface, { 'P_cond_int_pos','P_cond_int_neg'} )
    
% flux des faces interieures journalier des surfaces par orientation
% X [W]par jour --> X*3600*24 [J] --> X*24 [Wh] en kWh/m²(de surf).jour
resultats.surface.cond.intcard.pos = [sum( donnees.surface.P_cond_int_pos(:,opaques(:,1)) ,2)/surf_nord,...
                sum( donnees.surface.P_cond_int_pos(:,opaques(:,2)) ,2)/surf_sud,...
                sum( donnees.surface.P_cond_int_pos(:,opaques(:,3)) ,2)/surf_est,...
                sum( donnees.surface.P_cond_int_pos(:,opaques(:,4)) ,2)/surf_ouest,...
                sum( donnees.surface.P_cond_int_pos(:,opaques(:,5)) ,2)/surf_floor,...
                sum( donnees.surface.P_cond_int_pos(:,opaques(:,6)) ,2)/surf_roof]*24/1000;   %en kWh/m²(de surf) journalier

resultats.surface.cond.intcard.neg = -[sum( donnees.surface.P_cond_int_neg(:,opaques(:,1)) ,2)/surf_nord,...
                sum( donnees.surface.P_cond_int_neg(:,opaques(:,2)) ,2)/surf_sud,...
                sum( donnees.surface.P_cond_int_neg(:,opaques(:,3)) ,2)/surf_est,...
                sum( donnees.surface.P_cond_int_neg(:,opaques(:,4)) ,2)/surf_ouest,...
                sum( donnees.surface.P_cond_int_neg(:,opaques(:,5)) ,2)/surf_floor,...
                sum( donnees.surface.P_cond_int_neg(:,opaques(:,6)) ,2)/surf_roof]*24/1000;    %en kWh/m²(de surf) journalier
end
% if isfield(donnees.surface, { 'P_cond_int_pos','P_cond_int_neg'} )
% resultats.surface.cond.... = [sum( donnees.surface.P_cond_ext_pos(:,opaques(:,1)) ,2)/surf_nord,...
%                 sum( donnees.surface.P_cond_ext_pos(:,opaques(:,2)) ,2)/surf_sud,...
%                 sum( donnees.surface.P_cond_ext_pos(:,opaques(:,3)) ,2)/surf_est,...
%                 sum( donnees.surface.P_cond_ext_pos(:,opaques(:,4)) ,2)/surf_ouest,...
%                 sum( donnees.surface.P_cond_ext_pos(:,opaques(:,5)) ,2)/surf_floor,...
%                 sum( donnees.surface.P_cond_ext_pos(:,opaques(:,6)) ,2)/surf_roof]*24/1000;   %en kWh/m²(de surf) journalier
%             
% resultats.surface.cond..... = -[sum( donnees.surface.P_cond_ext_neg(:,opaques(:,1)) ,2)/surf_nord,...
%                 sum( donnees.surface.P_cond_ext_neg(:,opaques(:,2)) ,2)/surf_sud,...
%                 sum( donnees.surface.P_cond_ext_neg(:,opaques(:,3)) ,2)/surf_est,...
%                 sum( donnees.surface.P_cond_ext_neg(:,opaques(:,4)) ,2)/surf_ouest,...
%                 sum( donnees.surface.P_cond_ext_neg(:,opaques(:,5)) ,2)/surf_floor,...
%                 sum( donnees.surface.P_cond_ext_neg(:,opaques(:,6)) ,2)/surf_roof]*24/1000;   %en kWh/m²(de surf) journalier
% end


if isfield(donnees.surface, 'P_cond_int')
    resultats.surface.cond.intcard = [sum( donnees.surface.P_cond_int(:,opaques(:,1)) ,2)/surf_nord,...
                sum( donnees.surface.P_cond_int(:,opaques(:,2)) ,2)/surf_sud,...
                sum( donnees.surface.P_cond_int(:,opaques(:,3)) ,2)/surf_est,...
                sum( donnees.surface.P_cond_int(:,opaques(:,4)) ,2)/surf_ouest,...
                sum( donnees.surface.P_cond_int(:,opaques(:,5)) ,2)/surf_floor,...
                sum( donnees.surface.P_cond_int(:,opaques(:,6)) ,2)/surf_roof]*24/1000;   %en kWh/m²(de surf) journalier
end

if isfield(donnees.surface, 'P_cond_int_h')
    % Surface Inside Face Conduction Heat Transfer Rate [W](Hourly)
    resultats.surface.cond_h.intcard = [sum( donnees.surface.P_cond_int_h(:,opaques(:,1)) ,2)/surf_nord,...
                sum( donnees.surface.P_cond_int_h(:,opaques(:,2)) ,2)/surf_sud,...
                sum( donnees.surface.P_cond_int_h(:,opaques(:,3)) ,2)/surf_est,...
                sum( donnees.surface.P_cond_int_h(:,opaques(:,4)) ,2)/surf_ouest,...
                sum( donnees.surface.P_cond_int_h(:,opaques(:,5)) ,2)/surf_floor,...
                sum( donnees.surface.P_cond_int_h(:,opaques(:,6)) ,2)/surf_roof]/1000;    %en kWh/m²(de surf) horaire
end

if isfield(donnees.surface, { 'P_avg_cond_pos_h','P_avg_cond_neg_h'} )
    % Surface Average Face Conduction Heat Gain Rate [W](Hourly)
    resultats.surface.cond_h.avgcard.pos = [sum( donnees.surface.P_avg_cond_pos_h(:,opaques(:,1)) ,2)/surf_nord,...
                sum( donnees.surface.P_avg_cond_pos_h(:,opaques(:,2)) ,2)/surf_sud,...
                sum( donnees.surface.P_avg_cond_pos_h(:,opaques(:,3)) ,2)/surf_est,...
                sum( donnees.surface.P_avg_cond_pos_h(:,opaques(:,4)) ,2)/surf_ouest,...
                sum( donnees.surface.P_avg_cond_pos_h(:,opaques(:,5)) ,2)/surf_floor,...
                sum( donnees.surface.P_avg_cond_pos_h(:,opaques(:,6)) ,2)/surf_roof]/1000;    %en kWh/m²(de surf) horaire
    % Surface Average Face Conduction Heat Loss Rate [W](Hourly)
    resultats.surface.cond_h.avgcard.neg = -[sum( donnees.surface.P_avg_cond_neg_h(:,opaques(:,1)) ,2)/surf_nord,...
                sum( donnees.surface.P_avg_cond_neg_h(:,opaques(:,2)) ,2)/surf_sud,...
                sum( donnees.surface.P_avg_cond_neg_h(:,opaques(:,3)) ,2)/surf_est,...
                sum( donnees.surface.P_avg_cond_neg_h(:,opaques(:,4)) ,2)/surf_ouest,...
                sum( donnees.surface.P_avg_cond_neg_h(:,opaques(:,5)) ,2)/surf_floor,...
                sum( donnees.surface.P_avg_cond_neg_h(:,opaques(:,6)) ,2)/surf_roof]/1000;    %en kWh/m²(de surf) horaire
end

%% == Surface Heat Storage ==
%{
These “heat storage” report variables combine the inside face conduction and outside face
conduction reports together to describe the thermal storage situation in a heat transfer
surface in a nominal way. This is simply the difference between the inside and outside face
conduction, but with the sign convention arranged so that positive values indicate heat being
added to the core of the surface.
%}
if isfield(donnees.surface, {'P_avg_storage_pos_h','P_avg_storage_neg_h'} )
    % Surface Heat Storage Gain Rate [W](Hourly)
    resultats.surface.storage_h.avgcard.pos = [sum( donnees.surface.P_avg_storage_pos_h(:,opaques(:,1)) ,2)/surf_nord,...
                sum( donnees.surface.P_avg_storage_pos_h(:,opaques(:,2)) ,2)/surf_sud,...
                sum( donnees.surface.P_avg_storage_pos_h(:,opaques(:,3)) ,2)/surf_est,...
                sum( donnees.surface.P_avg_storage_pos_h(:,opaques(:,4)) ,2)/surf_ouest,...
                sum( donnees.surface.P_avg_storage_pos_h(:,opaques(:,5)) ,2)/surf_floor,...
                sum( donnees.surface.P_avg_storage_pos_h(:,opaques(:,6)) ,2)/surf_roof]/1000;    %en kWh/m²(de surf) horaire
	% Surface Heat Storage Loss Rate [W](Hourly)
    resultats.surface.storage_h.avgcard.neg = -[sum( donnees.surface.P_avg_storage_neg_h(:,opaques(:,1)) ,2)/surf_nord,...
                sum( donnees.surface.P_avg_storage_neg_h(:,opaques(:,2)) ,2)/surf_sud,...
                sum( donnees.surface.P_avg_storage_neg_h(:,opaques(:,3)) ,2)/surf_est,...
                sum( donnees.surface.P_avg_storage_neg_h(:,opaques(:,4)) ,2)/surf_ouest,...
                sum( donnees.surface.P_avg_storage_neg_h(:,opaques(:,5)) ,2)/surf_floor,...
                sum( donnees.surface.P_avg_storage_neg_h(:,opaques(:,6)) ,2)/surf_roof]/1000;    %en kWh/m²(de surf) horaire

end

%% == Flux Radiatif ==
%Surface Outside Face Incident Solar Radiation Rate per Area [W/m2](Hourly)
if isfield(donnees.surface, 'Ps_rad_solar_inc_ext_h' )
    resultats.surface.rad_solar_inc_h = [sum( donnees.surface.Ps_rad_solar_inc_ext_h(:,find(opaques(:,1), 1, 'first')) ,2),...
                sum( donnees.surface.Ps_rad_solar_inc_ext_h(:,find(opaques(:,2), 1, 'first')) ,2),...
                sum( donnees.surface.Ps_rad_solar_inc_ext_h(:,find(opaques(:,3), 1, 'first')) ,2),...
                sum( donnees.surface.Ps_rad_solar_inc_ext_h(:,find(opaques(:,4), 1, 'first')) ,2),...
                sum( donnees.surface.Ps_rad_solar_inc_ext_h(:,find(opaques(:,5), 1, 'first')) ,2),...
                sum( donnees.surface.Ps_rad_solar_inc_ext_h(:,find(opaques(:,6), 1, 'first')) ,2)]/1000;   %en kWh/m² horaire
end             

%Surface Outside Face Solar Radiation Heat Gain Rate [W](Hourly)
if isfield(donnees.surface, 'P_rad_solar_abs_ext_h')
    resultats.surface.rad_solar_abs_h = [sum( donnees.surface.P_rad_solar_abs_ext_h(:,opaques(:,1)) ,2)/surf_nord,...
                sum( donnees.surface.P_rad_solar_abs_ext_h(:,opaques(:,2)) ,2)/surf_sud,...
                sum( donnees.surface.P_rad_solar_abs_ext_h(:,opaques(:,3)) ,2)/surf_est,...
                sum( donnees.surface.P_rad_solar_abs_ext_h(:,opaques(:,4)) ,2)/surf_ouest,...
                sum( donnees.surface.P_rad_solar_abs_ext_h(:,opaques(:,5)) ,2)/surf_floor,...
                sum( donnees.surface.P_rad_solar_abs_ext_h(:,opaques(:,6)) ,2)/surf_roof]/1000;   %en kWh/m²(de surf) horaire
end

%Surface Outside Face Net Thermal Radiation Heat Gain Rate [W](Hourly)
if isfield(donnees.surface, 'P_rad_therm_ext_h' )
    resultats.surface.rad_therm_h = [sum( donnees.surface.P_rad_therm_ext_h(:,opaques(:,1)) ,2)/surf_nord,...
                sum( donnees.surface.P_rad_therm_ext_h(:,opaques(:,2)) ,2)/surf_sud,...
                sum( donnees.surface.P_rad_therm_ext_h(:,opaques(:,3)) ,2)/surf_est,...
                sum( donnees.surface.P_rad_therm_ext_h(:,opaques(:,4)) ,2)/surf_ouest,...
                sum( donnees.surface.P_rad_therm_ext_h(:,opaques(:,5)) ,2)/surf_floor,...
                sum( donnees.surface.P_rad_therm_ext_h(:,opaques(:,6)) ,2)/surf_roof]/1000;   %en kWh/m²(de surf) horaire
end

clear surf_nord surf_sud surf_est surf_ouest surf_floor surf_roof


%% Echanges thermiques des vitrages (conv+ray)
%{
Window Heat Gain/Loss Energy[J]
The total window heat flow can be thought of as the sum of the solar and conductive
gain/loss from the window glazing.
    + [Window transmitted solar]
    + [Convective heat flow to the zone from the air flowing through the gap between glazing
    and shading device]
    + [Convective heat flow to the zone from the zone side of the shading device]
    + [Net IR heat flow to the zone from the zone side of the glazing]
    + [Net IR heat flow to the zone from the zone side of the shading device]
    – [Short-wave radiation from zone transmitted back out the window]
    + [Conduction to zone from window frame and divider, if present]

%}
if any(isfield(donnees.surface, {'E_win_gain', 'E_win_loss', 'E_win_ray'}))
    % Toutes les fenetre donnant sur l'extérieur
    fenetres = bsxfun(@and,parois(:,1:6)',geometrie.window')';

    % Surface totale (vitrages + frames + diviseurs) suivant l'orientation
    surf_nord= sum(horzcat( geometrie.surfaces{fenetres(:,1),9} ));
    surf_sud = sum(horzcat( geometrie.surfaces{fenetres(:,2),9} ));
    surf_est = sum(horzcat( geometrie.surfaces{fenetres(:,3),9} ));
    surf_ouest=sum(horzcat( geometrie.surfaces{fenetres(:,4),9} ));
    surf_floor=sum(horzcat( geometrie.surfaces{fenetres(:,5),9} ));
    surf_roof= sum(horzcat( geometrie.surfaces{fenetres(:,6),9} ));
end
if all(isfield(donnees.surface, {'E_win_gain', 'E_win_loss', 'E_win_ray'}))
    % Gains/pertes journalieres des surfaces par orientation en kWh/m²(vitre).jour
    resultats.vitrages.card.gain= [sum( donnees.surface.E_win_gain(:,fenetres(:,1)) ,2)/(3600*1000*surf_nord),...
                    sum( donnees.surface.E_win_gain(:,fenetres(:,2)) ,2)/(3600*1000*surf_sud),...
                    sum( donnees.surface.E_win_gain(:,fenetres(:,3)) ,2)/(3600*1000*surf_est),...
                    sum( donnees.surface.E_win_gain(:,fenetres(:,4)) ,2)/(3600*1000*surf_ouest),...
                    sum( donnees.surface.E_win_gain(:,fenetres(:,5)) ,2)/(3600*1000*surf_floor),...
                    sum( donnees.surface.E_win_gain(:,fenetres(:,6)) ,2)/(3600*1000*surf_roof)];

    resultats.vitrages.card.loss= -[sum( donnees.surface.E_win_loss(:,fenetres(:,1)) ,2)/(3600*1000*surf_nord),...
                    sum( donnees.surface.E_win_loss(:,fenetres(:,2)) ,2)/(3600*1000*surf_sud),...
                    sum( donnees.surface.E_win_loss(:,fenetres(:,3)) ,2)/(3600*1000*surf_est),...
                    sum( donnees.surface.E_win_loss(:,fenetres(:,4)) ,2)/(3600*1000*surf_ouest),...
                    sum( donnees.surface.E_win_loss(:,fenetres(:,5)) ,2)/(3600*1000*surf_floor),...
                    sum( donnees.surface.E_win_loss(:,fenetres(:,6)) ,2)/(3600*1000*surf_roof)];

    % Gains/pertes journalieres de toutes les surfaces en kWh/m²(vitre).jour
    resultats.vitrages.toutes= [sum( donnees.surface.E_win_gain ,2), -sum( donnees.surface.E_win_loss ,2)]/(3600*1000*sum(horzcat( geometrie.surfaces{any(fenetres,2),9} )));
end

if isfield(donnees.surface, 'E_win_ray')
    % Rayonnement solaire entrant par orientation en kWh/m²(vitre).jour
    resultats.vitrages.card_ray= [sum( donnees.surface.E_win_ray(:,fenetres(:,1)) ,2)/(3600*1000*surf_nord),...
                    sum( donnees.surface.E_win_ray(:,fenetres(:,2)) ,2)/(3600*1000*surf_sud),...
                    sum( donnees.surface.E_win_ray(:,fenetres(:,3)) ,2)/(3600*1000*surf_est),...
                    sum( donnees.surface.E_win_ray(:,fenetres(:,4)) ,2)/(3600*1000*surf_ouest),...
                    sum( donnees.surface.E_win_ray(:,fenetres(:,5)) ,2)/(3600*1000*surf_floor),...
                    sum( donnees.surface.E_win_ray(:,fenetres(:,6)) ,2)/(3600*1000*surf_roof)];

    % Rayonnement solaire entrant de toutes les surfaces en kWh/m²(vitre).jour
    resultats.vitrages.toutes_ray= sum( donnees.surface.E_win_ray ,2)  /(3600*1000*sum(horzcat( geometrie.surfaces{any(fenetres,2),9} )));

end
clear surf_nord surf_sud surf_est surf_ouest surf_floor surf_roof


%% Humidité
% Etude condensation sur les parois

if isfield(donnees.surface,'HR_surf_int')
    for k=1:6
        resultats.humdite.RHsurf{k} = [donnees.surface.HR_surf_int(:,opaques(:,k))];   
    end
end
if isfield(donnees.zone,'RH_int')
    resultats.humdite.RH_int = (donnees.zone.RH_int(:,zones_etude)*volumes')/sum(volumes);
end

if isfield(donnees.zone,'w_int')
    resultats.humdite.w_int = (donnees.zone.w_int(:,zones_etude)*volumes')/sum(volumes);
end

if isfield(donnees.surface,'T_surf_int')
    for k=1:6       
        resultats.humdite.Tsurf_int{k}  = [donnees.surface.T_surf_int(:,opaques(:,k)) ];
    end
end
if isfield(donnees.surface,'T_surf_out')
    for k=1:6       
        resultats.humdite.Tsurf_out{k}  = [donnees.surface.T_surf_out(:,opaques(:,k)) ];
    end
end
if isfield(donnees.zone,'T_int')
    resultats.humdite.T_int  = (donnees.zone.T_int(:,zones_etude)*volumes')/sum(volumes);
end

%% Identification des modes de fonctionnement

if false
% mois le plus chaud
keyboard
periode_j = 60;
Tj = sum(reshape(donnees.site.T_air,24,[]));
Tmax=0;
for i=1:length(Tj)-periode_j
    Tsum = sum(Tj(i:i+periode_j));
    if Tsum>Tmax
        jour=i;
        Tmax=Tsum;
    end
end
jour
for i=1:length(Tj)-periode_j
    Tsum = sum(Tj(i:i+periode_j));
    if Tsum<Tmax
        jour=i;
        Tmax=Tsum;
    end
end
jour

% A=ones(length(Tj),1)*560
% A(jour:jour+periode_j) = 580
% plot(1:length(Tj),Tj,1:length(Tj),A)
end

premier = 1;
dernier = dates.nb_j;
resultats.plages.chauff = false(dates.nb_j,1);
resultats.plages.clim = false(dates.nb_j,1);

% Limites simple de la condition d'évolution libre du bâtiment
resultats.plages.libre = resultats.energie.heat<=0; 
plages.libre = resultats.plages.libre; 

%warning('plage de fonctionnement obsolette !')
% limiter à ce qui peut etre utile pour, après, choisir des plages de fonctionnement
% exemple somme de toutes les plages de mise en route du chauffage et calcul de la periode probable
% de demarrage ou faire du premier jour de chauffage une variable de sortie

premier = 1;
dernier = dates.nb_j;
plages.ete = false(dates.nb_j,1);
plages.ete_h = false(dates.nb_h,1,1);
plages.hiver = true(dates.nb_j,1);
plages.hiver_h = true(dates.nb_h,1);
plages.clim = false(dates.nb_j,1);
plages.clim_h = false(dates.nb_h,1);


% Détermination de la *période estivale* (bâtiment en évo. libre uniquement)
for i=1:dates.nb_j
    if plages.libre(i)>0
        if  dates.j(i)<datenum([dates.vec(1,1) 08 15]) % dernier jour de chauffe avant été
           premier = i+1;
        else % premier jour de chauffe apres été
            dernier = i-1;
        end
    end
end    
plages.ete(premier:dernier) = true;
plages.nb_j_ete = dernier-premier+1;
if plages.nb_j_ete>0
    plages.ete_h(  find(dates.h == dates.j(premier))  :  find(dates.h == dates.j(dernier))+23  ) = true;
end
% Détermination de la *période hivernale* (bâtiment en chauffage uniquement)
plages.chauff = resultats.energie.heat>0;
if any(plages.chauff)
    premier = ceil(find(plages.chauff, 1 , 'first')/24);
    dernier = ceil(find(plages.chauff, 1, 'last' )/24);
    plages.hiver(premier:dernier) = false;
    plages.nb_j_hiver = dates.nb_j -(dernier-premier+1);
    plages.hiver_h( find(dates.h == dates.j(premier)) : find(dates.h == dates.j(dernier))+23  ) = false;
else
    plages.hiver(:)= false;
    plages.nb_j_hiver = 0;
    plages.hiver_h(:)= false;
    
end

% Détermination de l'*inter saison* (le reste)
plages.inter = ~or(plages.ete,plages.hiver);
plages.inter_h = ~or(plages.ete_h,plages.hiver_h);
plages.nb_j_inter = dates.nb_j -(plages.nb_j_ete + plages.nb_j_hiver);

% Détermination de la période estivale (climatisation)
climmm = resultats.energie.cool;
premier = find(climmm, 1, 'first');
dernier = find(climmm, 1, 'last');
if ~isempty(premier)
    plages.clim(premier:dernier) = true;
    plages.clim_h( find(dates.h == dates.h(premier)) : find(dates.h == dates.h(dernier))+23  ) = true;
end

clear premier;
clear dernier;




%% Confort rationnel
if isfield(geometrie,'confzones')

zone_fanger = [geometrie.confzones{:,3}]==1;
if any(zone_fanger)
    error('A verifier') 
    % PMV moyennées sur les zones à inspecter (pondération volumiqie)
    PMV = (donnees.zone.PMV(:,zones_etude)*volumes')/sum(volumes);

    % Définition des catégories
    resultats.conf_ratio.categories = (PMV>0.7) + (PMV>0.5) + (PMV>0.2) + 1 -2*(PMV<0) -(PMV<-0.2) -(PMV<-0.5) -(PMV<-0.7);

    % Ecart avec la CatI en PMV.heure
    resultats.conf_ratio.ecartCatI = [(PMV>0.2).*(PMV-0.2) (PMV<-0.2).*(PMV+0.2)];	
    clear type_plage PMV_res
end

end
%% Confort adaptatif
%VERSION NF EN 15251 Août 2007

if isfield(donnees,'simple') && isfield(donnees.simple,'T_ext') && length(donnees.simple.T_ext)>=7
    % Moyenne journaliere glissante de la température exterieure journalière
    T_em = zeros(dates.nb_j,1);
    T_e = donnees.simple.T_ext;
    alpha = 0.8;    % Ponderation de la moyenne glissante
    if (dates.nb_j>360) %simulation annuelle -> bouclage avec les 10 derniers jours de la fin d'année
        for i=(dates.nb_j-10):dates.nb_j; T_em (i) = (1 - alpha)*T_e(i-1) + alpha*T_em(i-1); end
        T_em (1) = (1 - alpha)*T_e(dates.nb_j) + alpha*T_em(dates.nb_j);
    else %si non -> demarre avec la moyenne des 7 premiers jours
        T_em(1) = (T_e(1) + alpha*T_e(2) + (alpha^2)*T_e(3) + (alpha^3)*T_e(4) + (alpha^4)*T_e(5) + (alpha^5)*T_e(6) + (alpha^6)*T_e(7))*(1-alpha)/(1-alpha^7);
    end

    for i=2:dates.nb_j; T_em(i) = (1 - alpha)*T_e(i-1) + alpha*T_em(i-1); end
    clear alpha;
    T_em = reshape(repmat(T_em',24,1),[],1); % passage en données horaire

    % Conditions sur la température extérieure
    % Limites haute/basse contantes pour T_em superieure à 30°C (hyp. perso)
    T_em(T_em>30)=30; % T_op(T_em>30°C) = T_op(30°C)
    % Limite haute contante pour T_em inferieure à 10°C
    T_op_sup = max(0.33*10 + 18.8,0.33*T_em + 18.8);
    % Limite basse contante pour T_em inferieure à 15°C
    T_op_inf = max(0.33*15 + 18.8,0.33*T_em + 18.8);

    clear T_em T_e;

    % Température intérieure optimale en confort adaptatif
    resultats.conf_adap.T_optimale = (T_op_sup+T_op_inf)/2; %(hyp. perso)
    % Températures moyennées des zones à inspecter (pondération volumiqie)
    T_z = (donnees.zone.T_operative(:,zones_etude)*volumes')/sum(volumes);

    % Définition des catégories
    %si 1:T<lim  2:T>lim+-2   3:T>lim+-3   4:T>lim+-4
    %    Cat I      Cat II      Cat III      Hors Cat
    resultats.conf_adap.categories= (T_z>=resultats.conf_adap.T_optimale).*((T_z>T_op_sup+4)+(T_z>T_op_sup+3)+(T_z>T_op_sup+2)+1)...
                                   -(T_z< resultats.conf_adap.T_optimale).*((T_z<T_op_inf-4)+(T_z<T_op_inf-3)+(T_z<T_op_inf-2)+1);

    % Ecart avec la CatI en °C
    resultats.conf_adap.ecartCatI = [max(0,T_z-(T_op_sup+2)), min(0,T_z-(T_op_inf-2))];

    % Enregistrement de la température de zone étudiée
    resultats.conf_adap.T_zone_operative = T_z;

    clear T_z T_op_inf T_op_sup

end

%% Eclairage

if isfield(geometrie,'lightzones') && geometrie.lightzones{:,1} && extract_lum

% Nombres heures d'ensoleillement journalier
resultats.eclairement.nbs_heures=sum(donnees.eclairement.actif',2);
% Eclairement moyen heure par heure
resultats.eclairement.moy_h = reshape(squeeze(mean(mean(donnees.eclairement.brut(:,:,:),1),2)),24,[]);
% Eclairement moyen maximum journalier
[resultats.eclairement.max_j,index] = max(resultats.eclairement.moy_h',[],2);

% Cartes d'éclairement maximales journalières
resultats.eclairement.map_max_j = donnees.eclairement.brut(:,:, index+24*(0:size(index,1)-1)' );
% Carte d'eclairement moyenne journalières (sur les heures d'ensoleillement)
for k=1:dates.nb_j
    resultats.eclairement.map_moy_j(:,:,k) = mean(donnees.eclairement.brut(:,:,donnees.eclairement.actif(:,k),k),3);
end

end 

 
 
resultats.plages=plages;
