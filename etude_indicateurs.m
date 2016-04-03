function indicateurs=etude_indicateurs(resultats, plages)

%global geometrie
global legende

leg = ~isfield(legende,'indicateurs');



if any([plages.temporel])
%%

%periode = find([plages.temporel],1 ,'first');
k=1;
legende.indicateurs(1).plage = plages(k).nom;

if isfield(resultats,'humdite') && all(isfield(resultats.humdite,{'RH_int','w_int'}))
    indicateurs(1).temp_HR=resultats.humdite.RH_int(plages(k).index_h);
    legende.indicateurs(1).temp_HR =  {['Humidité moyenne dans la zone d''étude ' plages(k).nom ' [%]']};

    indicateurs(1).temp_w=resultats.humdite.w_int(plages(k).index_h);
    legende.indicateurs(1).temp_w =  {['Humidité moyenne dans la zone d''étude ' plages(k).nom ' [-]']};

    % resultats.humdite.RH_int = gradient(resultats.humdite.RH_int);
    % indicateurs(1).temp_gradHR=resultats.humdite.RH_int(plages(k).index_h);
    % legende.indicateurs(1).temp_gradHR =  {['Humidité moyenne dans la zone d''étude ' plages(k).nom ' [-]']};
end


if all(isfield(resultats.humdite,{'Tsurf','RHsurf'}))

    M_0 = 0;            % etat initial du risque
    Sens_class=2;       % sensibilite du materiau (1=resistant, 2=medium resistant, 3=sensitive,
    Surf_quality=1;     % qualite de la surface du materiau (0=sawn surface, 1= kiln dried quaqlity)
    timb_spec=0;        % espece du bois (0= pine, 1= spruce)
    Nt=sum(plages(k).index)*24;      % nombre de valeurs
    dt=3600;            % pas de temps des valeurs en seconde
    
    l=5;   % Type de parois  (Nord /Sud /Est /Ouest /Plancher /Toiture)
    for m=size(resultats.humdite.Tsurf{l},2)
        [~,Histo] = mould_VTT(M_0,resultats.humdite.Tsurf{l}(plages(k).index_h,m),resultats.humdite.RHsurf{l}(plages(k).index_h,m),Sens_class,Surf_quality,timb_spec,Nt,dt);
        indicateurs(1).temp_M = Histo;
    end

    legende.indicateurs(1).temp_M =  {['Risque de croissance de moisissure sur les surfaces Plancher ' plages(k).nom ' [-]']};

end

%% SURFACE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
idsurface = 6; % (Nord /Sud /Est /Ouest /Plancher /Toiture)

%% Moyennes horaires

indicateurs(1).temp_MeanHourly_Tout = mean( reshape( resultats.humdite.Tsurf_out{end}(plages(k).index_h),24,[] ) ,2);
legende.indicateurs(1).temp_MeanHourly_Tout = {['Hourly Mean Surface Temperature outside face [C]']};
indicateurs(1).temp_MeanHourly_Tin = mean( reshape( resultats.humdite.Tsurf_int{end}(plages(k).index_h),24,[] ) ,2);
legende.indicateurs(1).temp_MeanHourly_Tin  = {['Hourly Mean Surface Temperature inside face [C]']};
indicateurs(1).temp_MeanHourly_FluxInt = mean( reshape( resultats.surface.cond_h.intcard(plages(k).index_h,end) ,24,[] ) ,2);
legende.indicateurs(1).temp_MeanHourly_FluxInt = {['Hourly Mean Surface Flux inside face [kWh/m^2]']};
indicateurs(1).temp_MeanHourly_Storage = mean( reshape( resultats.surface.storage_h.avgcard.pos(plages(k).index_h,6) + resultats.surface.storage_h.avgcard.neg(plages(k).index_h,6) ,24,[] ) ,2);
legende.indicateurs(1).temp_MeanHourly_Storage = {['Hourly Mean Surface Storage [kWh/m^2]']};
% Flux a traver la surface (pas tres stable)
% plot(mean( reshape( resultats.surface.cond_h.avgcard.pos(plages(k).index_h,end) + resultats.surface.cond_h.avgcard.neg(plages(k).index_h,end)  ,24,[] ) ,2))

indicateurs(1).temp_MeanHourly_ILAScoolTotal = mean( reshape( resultats.energie.ILAScool.Total(plages(k).index_h,end) ,24,[] ) ,2);
legende.indicateurs(1).temp_MeanHourly_ILAScoolTotal = {['Hourly Mean ILAS Total Cooling [kWh]']};
indicateurs(1).temp_MeanHourly_ILASheatTotal = mean( reshape( resultats.energie.ILASheat.Total(plages(k).index_h,end) ,24,[] ) ,2);
legende.indicateurs(1).temp_MeanHourly_ILASheatTotal = {['Hourly Mean ILAS Total Heating [kWh]']};

%%
indicateurs(1).temp_T=resultats.humdite.T_int(plages(k).index_h);
        legende.indicateurs(1).temp_T =  {['Température air [C]']};

if isfield(resultats,'energie') && isfield(resultats.energie,'PTAC')
    indicateurs(1).temp_PTACcoolTotal = resultats.energie.PTACcoolTotal(plages(k).index_h);
    legende.indicateurs(1).temp_PTACcoolTotal = {['PTAC Cooling Total [kWh]']};
    indicateurs(1).temp_PTACcoolSensible = resultats.energie.PTACcoolSensible(plages(k).index_h);
    legende.indicateurs(1).temp_PTACcoolSensible = {['PTAC Cooling Sensible [kWh]']};
    indicateurs(1).temp_PTACcoolLatent = resultats.energie.PTACcoolLatent(plages(k).index_h);
    legende.indicateurs(1).temp_PTACcoolLatent = {['PTAC Cooling Latent [kWh]']};
end
if isfield(resultats,'energie') && isfield(resultats.energie,'ILAScool')
    indicateurs(1).temp_ILAScoolTotal = resultats.energie.ILAScool.Total(plages(k).index_h);
    legende.indicateurs(1).temp_ILAScoolTotal = {['ILAS Cooling Total [kWh]']};
    indicateurs(1).temp_ILAScoolSensible = resultats.energie.ILAScool.Sensible(plages(k).index_h);
    legende.indicateurs(1).temp_ILAScoolSensible = {['ILAS Cooling Sensible [kWh]']};
    indicateurs(1).temp_ILAScoolLatent = resultats.energie.ILAScool.Latent(plages(k).index_h);
    legende.indicateurs(1).temp_ILAScoolLatent = {['ILAS Cooling Latent [kWh]']};
end
if isfield(resultats,'energie') && isfield(resultats.energie,'ILASheat')
    indicateurs(1).temp_ILASheatTotal = resultats.energie.ILASheat.Total(plages(k).index_h);
    legende.indicateurs(1).temp_ILASheatTotal = {['ILAS Heating Total [kWh]']};
    indicateurs(1).temp_ILASheatSensible = resultats.energie.ILASheat.Sensible(plages(k).index_h);
    legende.indicateurs(1).temp_ILASheatSensible = {['ILAS Heating Sensible [kWh]']};
    indicateurs(1).temp_ILASheatLatent = resultats.energie.ILASheat.Latent(plages(k).index_h);
    legende.indicateurs(1).temp_ILASheatLatent = {['ILAS Heating Latent [kWh]']};
end

switch -1
    case 1 % Simple
        indicateurs(1).temp_T=resultats.humdite.T_int(plages(k).index_h);
        legende.indicateurs(1).temp_T =  {['Température air [C]']};
        indicateurs(1).temp_ECond= resultats.surface.cond.intcard(plages(k).index_h,idsurface);
        legende.indicateurs(1).temp_ECond =  {['ECond [kWh/m²]']};
        % indicateurs(1).temp_ERay= resultats.vitrages.card_ray(plages(k).index_h,idsurface);
        % legende.indicateurs(1).temp_ERay =  {['ERay [kWh/m²]']};
        indicateurs(1).temp_Eheat=resultats.energie.heat(plages(k).index_h);
        legende.indicateurs(1).temp_Eheat =  {['System Heating [kWh]']};
        indicateurs(1).temp_Ecool=resultats.energie.cool(plages(k).index_h);
        legende.indicateurs(1).temp_Ecool =  {['System Cooling [kWh]']};
        indicateurs(1).temp_Tsuf=resultats.humdite.Tsurf{idsurface}(plages(k).index_h,1);
        legende.indicateurs(1).temp_Tsuf =  {['Température suface [C]']};
    case 2 % Diff
        indicateurs(1).temp_T_diff      =diff( vertcat( resultats.humdite.T_int(end), resultats.humdite.T_int(plages(k).index_h) ));
        legende.indicateurs(1).temp_T_diff      =  {['Diff Température air [C]']};
        indicateurs(1).temp_ECond_diff  = diff( vertcat(resultats.surface.cond.intcard(end,idsurface), resultats.surface.cond.intcard(:,idsurface) ) );
        legende.indicateurs(1).temp_ECond_diff  =  {['ECond [kWh/m²]']};
        indicateurs(1).temp_Eheat_diff  = diff( vertcat( resultats.energie.heat(end), resultats.energie.heat(plages(k).index_h) ));
        legende.indicateurs(1).temp_Eheat_diff  =  {['Diff System Heating [kWh]']};
        indicateurs(1).temp_Ecool_diff  = diff( vertcat( resultats.energie.cool(end), resultats.energie.cool(plages(k).index_h) ));
        legende.indicateurs(1).temp_Ecool_diff  =  {['Diff System Cooling [kWh]']};
        indicateurs(1).temp_Tsuf_diff   = diff( vertcat( resultats.humdite.Tsurf{idsurface}(end), resultats.humdite.Tsurf{idsurface}(plages(k).index_h,1) ));
        legende.indicateurs(1).temp_Tsuf_diff   =  {['Diff Température suface [C]']};
    case 3 % Moving-average
        windowSize = 3;
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;
        tres = filter(b,a, [resultats.humdite.T_int(plages(k).index_h); resultats.humdite.T_int(plages(k).index_h) ]);
        indicateurs(1).temp_T_diff      = tres(end-23:end);
        legende.indicateurs(1).temp_T_diff      =  {['Température air ' plages(k).nom ' [C]']};

    case 4 % Step - Moving-average
        windowSize = 4;
        b = [1 -(1/windowSize)*ones(1,windowSize)];
        a = 1;
        
        indicateurs(1).temp_T_diff      = filter(b,a, resultats.humdite.T_int(plages(k).index_h) , flip(resultats.humdite.T_int(end-windowSize+1:end)) );
        legende.indicateurs(1).temp_T_diff      =  {['Température air ' plages(k).nom ' [C]']};
        indicateurs(1).temp_ECond_diff  = filter(b,a, resultats.surface.cond.intcard(:,idsurface) );
        legende.indicateurs(1).temp_ECond_diff  =  {['ECond [kWh/m²]']};
        indicateurs(1).temp_Eheat_diff  = filter(b,a, resultats.energie.heat(plages(k).index_h) );
        legende.indicateurs(1).temp_Eheat_diff  =  {['Diff System Heating [kWh]']};
        indicateurs(1).temp_Ecool_diff  = filter(b,a, resultats.energie.cool(plages(k).index_h) );
        legende.indicateurs(1).temp_Ecool_diff  =  {['Diff System Cooling [kWh]']};
        indicateurs(1).temp_Tsuf_diff   = filter(b,a, resultats.humdite.Tsurf{idsurface}(plages(k).index_h,1) );
        legende.indicateurs(1).temp_Tsuf_diff   =  {['Diff Température suface [C]']};

end

if isfield(resultats.humdite,'RHsurf')
    indicateurs(1).temp_RHsuf=resultats.humdite.RHsurf{idsurface}(plages(k).index_h,1);
    legende.indicateurs(1).temp_RHsuf =  {['RHsuf [-]']};
end


% indicateurs(1).temp_cond_pos=resultats.surface.cond.intcard.pos(plages(1).index_h,6);
% indicateurs(1).temp_cond_neg=resultats.surface.cond.intcard.neg(plages(1).index_h,6);
% legende.indicateurs(1).temp_cond_pos =  {['Conduction face interne des surfaces Toiture pos ' plages(1).nom ' [kWh/m^2_(_t_o_i_t_)]']};
% legende.indicateurs(1).temp_cond_neg =  {['Conduction face interne des surfaces Toiture neg ' plages(1).nom ' [kWh/m^2_(_t_o_i_t_)]']};

else
  

for k=1:length(plages)

    
%% moyennes horaires
% keyboard
% plot(mean( reshape( resultats.humdite.Tsurf_out{end}(plages(k).index_h),24,[] ) ,2))
% plot(mean( reshape( resultats.humdite.Tsurf_int{end}(plages(k).index_h),24,[] ) ,2))
% 
% % plot(mean( reshape( resultats.surface.cond_h.avgcard.pos(plages(k).index_h,end) + resultats.surface.cond_h.avgcard.neg(plages(k).index_h,end)  ,24,[] ) ,2))
% 
% plot(mean( reshape( resultats.surface.cond_h.intcard(plages(k).index_h,end) ,24,[] ) ,2))


    
%% == Bilan aerolique ==


% == Bilan des échanges avec l'air: kWh par m2 habibable ==
if isfield(resultats,'bilan_air')
    indicateurs(k).bilan_air=[
        sum(resultats.bilan_air.P_int(plages(k).index))
        sum(resultats.bilan_air.P_out(plages(k).index))
        sum(resultats.bilan_air.P_surf(plages(k).index))
        sum(resultats.bilan_air.P_sys(plages(k).index))];
    % indicateurs(k).aerolique_adim = round (100 * indicateurs(k).aerolique./sum(abs(indicateurs(k).aerolique)) );

    if leg
        legende.indicateurs(k).bilan_air = {
            ['Apports des charges internes ' plages(k).nom ' [kWh/m^2_(_h_a_b_)]']
            ['Echanges dus au renouvellement d''air ' plages(k).nom ' [kWh/m^2_(_h_a_b_)]']
            ['Transferts interne par convection ' plages(k).nom ' [kWh/m^2_(_h_a_b_)]']
            ['Echanges du Système ' plages(k).nom ' [kWh/m^2_(_h_a_b_)]']};
    end
end

% == Energie électrique ==
if isfield(resultats,'conso') && isfield(resultats.conso,'Elec_tot')
    indicateurs(k).electricite = [sum(resultats.conso.Elec_tot(plages(k).index))
                                  max(resultats.conso.Elec_tot(plages(k).index))];
    if leg
        legende.indicateurs(k).electricite = {
            ['Consomation électrique totale ' plages(k).nom ' [kWh/m^2_(_h_a_b_)]']
            ['Consomation électrique pic ' plages(k).nom ' [kW]']};
    end
end




% == Energie système ==

if isfield(resultats,'energie')
    if isfield(resultats.energie,'heat')    
        indicateurs(k).E_heat= [  mysum(resultats.energie.heat.Total,plages(k).index_h)
                                  mysum(resultats.energie.heat.Sensible,plages(k).index_h)
                                  mysum(resultats.energie.heat.Latent,plages(k).index_h)
                                  mymax(resultats.energie.heat.Total,plages(k).index_h)];
        if leg
            legende.indicateurs(k).E_heat = {
                ['Total Heating Energy ' plages(k).nom ' [kWh]']
                ['Sensible Heating Energy ' plages(k).nom ' [kWh]']
                ['Latent Heating Energy ' plages(k).nom ' [kWh]']
                ['Peak(Hour) Heating Energy ' plages(k).nom ' [kW]']};
        end
    end
    
    if isfield(resultats.energie,'cool')
        indicateurs(k).E_cool= [  mysum(resultats.energie.cool.Total,plages(k).index_h)
                                  mysum(resultats.energie.cool.Sensible,plages(k).index_h)
                                  mysum(resultats.energie.cool.Latent,plages(k).index_h)
                                  mymax(resultats.energie.cool.Total,plages(k).index_h)];
        if leg
            legende.indicateurs(k).E_cool = {
                ['Total Cooling Energy ' plages(k).nom ' [kWh]']
                ['Sensible Cooling Energy ' plages(k).nom ' [kWh]']
                ['Latent Cooling Energy ' plages(k).nom ' [kWh]']
                ['Peak(Hour) Cooling Energy ' plages(k).nom ' [kW]']};
        end
    end

end



%% == Temperature ==
if isfield(resultats,'humdite') && isfield(resultats.humdite,{'Tsurf_int','Tsurf_out'})
    indicateurs(k).Ts_max = [
                max(resultats.humdite.Tsurf_int{end}(plages(k).index_h))
                max(resultats.humdite.Tsurf_out{end}(plages(k).index_h))];
    if leg
        legende.indicateurs(k).Ts_max = {
                ['Max Temperature Inside Face ' plages(k).nom ' [ºC]']
                ['Max Temperature Outside Face ' plages(k).nom ' [ºC]']};
    end


    indicateurs(k).Ts_max_hourly_mean = [
                max( mean (reshape( resultats.humdite.Tsurf_int{end}(plages(k).index_h) ,24,[]) ,2 ) )
                mean( mean (reshape( resultats.humdite.Tsurf_int{end}(plages(k).index_h) ,24,[]) ,2 ) )
                max( mean(reshape( resultats.humdite.Tsurf_out{end}(plages(k).index_h) ,24,[]) ,2 )' )
                mean( mean (reshape( resultats.humdite.Tsurf_out{end}(plages(k).index_h) ,24,[]) ,2 ) )];
    if leg
        legende.indicateurs(k).Ts_max_hourly_mean = {
                ['Max Hourly Mean Temperature Inside Face ' plages(k).nom ' [ºC]']
                ['Mean Temperature Inside Face ' plages(k).nom ' [ºC]']
                ['Max Hourly Mean Temperature Outside Face ' plages(k).nom ' [ºC]']
                ['Mean Temperature Outside Face ' plages(k).nom ' [ºC]']};
    end
end

%% == Bilan enveloppe ==
if isfield(resultats,'surface')
% == Performances: Parois convectif ==
if isfield(resultats.surface,'conv_int')
    % Gains/pertes journalières dues au flux convectif des surfaces vers l'air (inclu les vitrages) en kWh par m2 de surface considérée:
    %   - des surfaces par orientation en kWh/m²(de surf).jour --> resultats.surface.conv_int.card.gain (Nord /Sud /Est /Ouest /Plancher /Toiture)
    %   - des surfaces verticales en kWh/m²(de surf).jour --> resultats.surface.conv_int.verticales
    %   - de l'enveloppe totale en kWh/m²_hab.jour --> resultats.surface.conv_int.enveloppe

    indicateurs(k).parois.conv_int.card = [plages(k).index'*(resultats.surface.conv_int.card.gain(:,1:6) + resultats.surface.conv_int.card.loss(:,1:6)  )]';
    if leg
        legende.indicateurs(k).parois.conv_int.card = {
            ['Convection interne des surfaces Nord ' plages(k).nom ' [kWh/m^2_(_n_o_r_d_)]']
            ['Convection interne des surfaces Sud ' plages(k).nom ' [kWh/m^2_(_s_u_d_)]']
            ['Convection interne des surfaces Est ' plages(k).nom ' [kWh/m^2_(_e_s_t_)]']
            ['Convection interne des surfaces Ouest ' plages(k).nom ' [kWh/m^2_(_o_u_e_s_t_)]']
            ['Convection interne des surfaces Plancher ' plages(k).nom ' [kWh/m^2_(_s_o_l_)]']
            ['Convection interne des surfaces Toiture ' plages(k).nom ' [kWh/m^2_(_t_o_i_t_)]']};
    end

    indicateurs(k).parois.conv_int.verticales = sum(bsxfun(@times, resultats.surface.conv_int.verticales, plages(k).index))';
    if leg
        legende.indicateurs(k).parois.conv_int.verticales = {
            ['Gains par convection interne des surfaces vertivales ' plages(k).nom ' [kWh/m^2_(_p_a_r_o_i_s_)]']
            ['Pertes par convection interne des surfaces vertivales ' plages(k).nom ' [kWh/m^2_(_p_a_r_o_i_s_)]']};
    end
end

if isfield(resultats.surface,'conv_ext')
    indicateurs(k).parois.conv_ext.card = sum(resultats.surface.conv_ext.card(plages(k).index,:),1)';
    if leg
        legende.indicateurs(k).parois.conv_ext.card = {
            ['Convection externe des surfaces Nord ' plages(k).nom ' [kWh/m^2_(_n_o_r_d_)]']
            ['Convection externe des surfaces Sud ' plages(k).nom ' [kWh/m^2_(_s_u_d_)]']
            ['Convection externe des surfaces Est ' plages(k).nom ' [kWh/m^2_(_e_s_t_)]']
            ['Convection externe des surfaces Ouest ' plages(k).nom ' [kWh/m^2_(_o_u_e_s_t_)]']
            ['Convection externe des surfaces Plancher ' plages(k).nom ' [kWh/m^2_(_s_o_l_)]']
            ['Convection externe des surfaces Toiture ' plages(k).nom ' [kWh/m^2_(_t_o_i_t_)]']};
    end
end
% == Performances: Parois conductif ==
if isfield(resultats.surface,'cond')
    indicateurs(k).parois.cond.card = [plages(k).index'*(resultats.surface.cond.intcard.pos(:,1:6) + resultats.surface.cond.intcard.neg(:,1:6)  )]';
    if leg
        legende.indicateurs(k).parois.cond.card = {
            ['Conduction face interne des surfaces Nord ' plages(k).nom ' [kWh/m^2_(_n_o_r_d_)]']
            ['Conduction face interne des surfaces Sud ' plages(k).nom ' [kWh/m^2_(_s_u_d_)]']
            ['Conduction face interne des surfaces Est ' plages(k).nom ' [kWh/m^2_(_e_s_t_)]']
            ['Conduction face interne des surfaces Ouest ' plages(k).nom ' [kWh/m^2_(_o_u_e_s_t_)]']
            ['Conduction face interne des surfaces Plancher ' plages(k).nom ' [kWh/m^2_(_s_o_l_)]']
            ['Conduction face interne des surfaces Toiture ' plages(k).nom ' [kWh/m^2_(_t_o_i_t_)]']};
    end

    indicateurs(k).parois.cond.toit = [plages(k).index'*resultats.surface.cond.intcard.pos(:,6) plages(k).index'*resultats.surface.cond.intcard.neg(:,6)]';
    if leg
        legende.indicateurs(k).parois.cond.toit = {
            ['Conduction face interne des surfaces Toiture pos ' plages(k).nom ' [kWh/m^2_(_t_o_i_t_)]']
            ['Conduction face interne des surfaces Toiture neg ' plages(k).nom ' [kWh/m^2_(_t_o_i_t_)]']};
    end

end

if isfield(resultats.surface,'cond_h')
    indicateurs(k).parois.cond.card = sum(resultats.surface.cond_h.intcard(plages(k).index_h,1:6),1)';
    if leg
        legende.indicateurs(k).parois.cond.card = {
            ['Conduction face interne des surfaces Nord ' plages(k).nom ' [kWh/m^2_(_n_o_r_d_)]']
            ['Conduction face interne des surfaces Sud ' plages(k).nom ' [kWh/m^2_(_s_u_d_)]']
            ['Conduction face interne des surfaces Est ' plages(k).nom ' [kWh/m^2_(_e_s_t_)]']
            ['Conduction face interne des surfaces Ouest ' plages(k).nom ' [kWh/m^2_(_o_u_e_s_t_)]']
            ['Conduction face interne des surfaces Plancher ' plages(k).nom ' [kWh/m^2_(_s_o_l_)]']
            ['Conduction face interne des surfaces Toiture ' plages(k).nom ' [kWh/m^2_(_t_o_i_t_)]']};
    end
    
        
    indicateurs(k).parois.cond.toit_hourly_mean = [ min( mean(reshape(resultats.surface.cond_h.intcard(plages(k).index_h,6) ,24,[]),2)' ) 
                                                    max( mean(reshape(resultats.surface.cond_h.intcard(plages(k).index_h,6) ,24,[]),2)' ) 
                                                   mean( mean(reshape(resultats.surface.cond_h.intcard(plages(k).index_h,6) ,24,[]),2)' ) ];
    if leg
        legende.indicateurs(k).parois.cond.toit_hourly_mean = {
            ['Min Hourly Mean Roof Conduction inside face ' plages(k).nom ' [kWh/m^2]']
            ['Max Hourly Mean Roof Conduction inside face ' plages(k).nom ' [kWh/m^2]']
            ['Mean Roof Conduction inside face ' plages(k).nom ' [kWh/m^2]']};
    end
end



if isfield(resultats.surface,'storage_h')
    
    indicateurs(k).parois.storage.toit = [plages(k).index_h'*resultats.surface.storage_h.avgcard.pos(:,6) plages(k).index_h'*resultats.surface.storage_h.avgcard.neg(:,6)]';
    if leg
        legende.indicateurs(k).parois.storage.toit = {
            ['Storage Toiture Charge ' plages(k).nom ' [kWh/m^2_(_t_o_i_t_)]']
            ['Storage Toiture Decharge ' plages(k).nom ' [kWh/m^2_(_t_o_i_t_)]']};
    end
end

if isfield(resultats.surface,'rad_solar_inc_h')
    indicateurs(k).parois.rad_inc_ext = sum(resultats.surface.rad_solar_inc_h(plages(k).index_h,:),1)';
    if leg
        legende.indicateurs(k).parois.rad_inc_ext = {
            ['Rayonnement solaire ext. incident sur surfaces Nord ' plages(k).nom ' [kWh/m^2_(_n_o_r_d_)]']
            ['Rayonnement solaire ext. incident sur surfaces Sud ' plages(k).nom ' [kWh/m^2_(_s_u_d_)]']
            ['Rayonnement solaire ext. incident sur surfaces Est ' plages(k).nom ' [kWh/m^2_(_e_s_t_)]']
            ['Rayonnement solaire ext. incident sur surfaces Ouest ' plages(k).nom ' [kWh/m^2_(_o_u_e_s_t_)]']
            ['Rayonnement solaire ext. incident sur surfaces Plancher ' plages(k).nom ' [kWh/m^2_(_s_o_l_)]']
            ['Rayonnement solaire ext. incident sur surfaces Toiture ' plages(k).nom ' [kWh/m^2_(_t_o_i_t_)]']};
    end
end

if isfield(resultats.surface,'rad_solar_abs_h')
    indicateurs(k).parois.rad_abs_ext = sum(resultats.surface.rad_solar_abs_h(plages(k).index_h,:),1)';
    if leg
        legende.indicateurs(k).parois.rad_abs_ext = {
            ['Rayonnement solaire ext. absorbé sur surfaces Nord ' plages(k).nom ' [kWh/m^2_(_n_o_r_d_)]']
            ['Rayonnement solaire ext. absorbé sur surfaces Sud ' plages(k).nom ' [kWh/m^2_(_s_u_d_)]']
            ['Rayonnement solaire ext. absorbé sur surfaces Est ' plages(k).nom ' [kWh/m^2_(_e_s_t_)]']
            ['Rayonnement solaire ext. absorbé sur surfaces Ouest ' plages(k).nom ' [kWh/m^2_(_o_u_e_s_t_)]']
            ['Rayonnement solaire ext. absorbé sur surfaces Plancher ' plages(k).nom ' [kWh/m^2_(_s_o_l_)]']
            ['Rayonnement solaire ext. absorbé sur surfaces Toiture ' plages(k).nom ' [kWh/m^2_(_t_o_i_t_)]']};
    end
end

if isfield(resultats.surface,'rad_therm_h')
    indicateurs(k).parois.rad_therm = sum(resultats.surface.rad_therm_h(plages(k).index_h,:),1)';
    if leg
        legende.indicateurs(k).parois.rad_therm = {
            ['Rayonnement thermique ext. des surfaces Nord ' plages(k).nom ' [kWh/m^2_(_n_o_r_d_)]']
            ['Rayonnement thermique ext. des surfaces Sud ' plages(k).nom ' [kWh/m^2_(_s_u_d_)]']
            ['Rayonnement thermique ext. des surfaces Est ' plages(k).nom ' [kWh/m^2_(_e_s_t_)]']
            ['Rayonnement thermique ext. des surfaces Ouest ' plages(k).nom ' [kWh/m^2_(_o_u_e_s_t_)]']
            ['Rayonnement thermique ext. des surfaces Plancher ' plages(k).nom ' [kWh/m^2_(_s_o_l_)]']
            ['Rayonnement thermique ext. des surfaces Toiture ' plages(k).nom ' [kWh/m^2_(_t_o_i_t_)]']};
    end
end


indicateurs(k).parois.radconv_ext  = indicateurs(k).parois.rad_therm + indicateurs(k).parois.conv_ext.card;
   if leg
        legende.indicateurs(k).parois.radconv_ext = {
            ['Rayonnement thermique et Convection ext. des surfaces Nord ' plages(k).nom ' [kWh/m^2_(_n_o_r_d_)]']
            ['Rayonnement thermique et Convection ext. des surfaces Sud ' plages(k).nom ' [kWh/m^2_(_s_u_d_)]']
            ['Rayonnement thermique et Convection ext. des surfaces Est ' plages(k).nom ' [kWh/m^2_(_e_s_t_)]']
            ['Rayonnement thermique et Convection ext. des surfaces Ouest ' plages(k).nom ' [kWh/m^2_(_o_u_e_s_t_)]']
            ['Rayonnement thermique et Convection ext. des surfaces Plancher ' plages(k).nom ' [kWh/m^2_(_s_o_l_)]']
            ['Rayonnement thermique et Convection ext. des surfaces Toiture ' plages(k).nom ' [kWh/m^2_(_t_o_i_t_)]']};
    end
end    
% == Performances: Vitrages ==
if isfield(resultats,'vitrages')
    % Gains/pertes journalières dues au flux des vitrages et cadres vers l'air en kWh par m2 de surface vitrée totale (vitrages + frames + diviseurs) considérée:
    %   - des surfaces par orientation en kWh/m²(de vitrage).jour --> resultats.vitrages.card.gain (Nord /Sud /Est /Ouest /Plancher /Toiture)

    indicateurs(k).vitrages.card = [plages(k).index'*(resultats.vitrages.card.gain(:,1:4) + resultats.vitrages.card.loss(:,1:4) )]';
    % indicateurs(k).vitrages.card_adim = round (100 * bsxfun(@rdivide, indicateurs(k).vitrages.card, nansum(indicateurs(k).vitrages.card, 1)) );
    if leg
        legende.indicateurs(k).vitrages.card = {
            ['Energie totale entrante par les vitrages Nord ' plages(k).nom ' [kWh/m^2_(_v_i_t_r_e_)]']
            ['Energie totale entrante par les vitrages Sud ' plages(k).nom ' [kWh/m^2_(_v_i_t_r_e_)]']
            ['Energie totale entrante par les vitrages Est ' plages(k).nom ' [kWh/m^2_(_v_i_t_r_e_)]']
            ['Energie totale entrante par les vitrages Ouest ' plages(k).nom ' [kWh/m^2_(_v_i_t_r_e_)]']};
    end

    indicateurs(k).vitrages.sum = sum(bsxfun(@times, resultats.vitrages.toutes, plages(k).index))';
    if leg
        legende.indicateurs(k).vitrages.sum = {
            ['Gains par les vitrages ' plages(k).nom ' [kWh/m^2_(_v_i_t_r_e_)]']
            ['Pertes par les vitrages ' plages(k).nom ' [kWh/m^2_(_v_i_t_r_e_)]']};
    end


    % Rayonnement solaire transmis entrant des surfaces par orientation en kWh/m²(vitre).jour
    indicateurs(k).rayonnement.card = [plages(k).index'*resultats.vitrages.card_ray(:,1:4)]';
    if leg
        legende.indicateurs(k).rayonnement.card = {
            ['Rayonnement solaire entrant par les vitrages Nord ' plages(k).nom ' [kWh/m^2_(_v_i_t_r_e_)]']
            ['Rayonnement solaire entrant par les vitrages Sud ' plages(k).nom ' [kWh/m^2_(_v_i_t_r_e_)]']
            ['Rayonnement solaire entrant par les vitrages Est ' plages(k).nom ' [kWh/m^2_(_v_i_t_r_e_)]']
            ['Rayonnement solaire entrant par les vitrages Ouest ' plages(k).nom ' [kWh/m^2_(_v_i_t_r_e_)]']};
    end

    indicateurs(k).rayonnement.tot= plages(k).index'*resultats.vitrages.toutes_ray;
    if leg
        legende.indicateurs(k).rayonnement.tot = {['Rayonnement solaire total entrant ' plages(k).nom ' [kWh/m^2_(_v_i_t_r_e_)]']};
    end

end


%% == Performances: Croissance moisissure ==
if isfield(resultats,'humdite')
    if isfield(resultats.humdite,'RHsurf')
        indicateurs(k).humidite.card=zeros(6,1);    
        M_0 = 0;            % etat initial du risque
        Sens_class=2;       % sensibilite du materiau (1=resistant, 2=medium resistant, 3=sensitive,
        Surf_quality=1;     % qualite de la surface du materiau (0=sawn surface, 1= kiln dried quaqlity)
        timb_spec=0;        % espece du bois (0= pine, 1= spruce)
        Nt=sum(plages(k).index)*24;      % nombre de valeurs
        dt=3600;            % pas de temps des valeurs en seconde

        for l=1:6   % Type de parois 
    %         indicateurs(k).humidite.RHsurf_mean = 
    %         indicateurs(k).humidite.Tsurf_mean  = mean(resultats.humdite.RHsurf{k},2)
            for m=size(resultats.humdite.Tsurf{l},2)
                [M,Histo] = mould_VTT(M_0,resultats.humdite.Tsurf{l}(:,m),resultats.humdite.RHsurf{l}(:,m),Sens_class,Surf_quality,timb_spec,Nt,dt);
                indicateurs(k).humidite.card(l) = max(indicateurs(k).humidite.card(l),M);
            end
        end

        if leg
            legende.indicateurs(k).humidite.card = {
                ['Risque de croissance de moisissure sur les surfaces Nord ' plages(k).nom ' [-]']
                ['Risque de croissance de moisissure sur les surfaces Sud ' plages(k).nom ' [-]']
                ['Risque de croissance de moisissure sur les surfaces Est ' plages(k).nom ' [-]']
                ['Risque de croissance de moisissure sur les surfaces Ouest ' plages(k).nom ' [-]']
                ['Risque de croissance de moisissure sur les surfaces Plancher ' plages(k).nom ' [-]']
                ['Risque de croissance de moisissure sur les surfaces Toiture ' plages(k).nom ' [-]']};
        end

        indicateurs(k).humidite.max = max(indicateurs(k).humidite.card);
        if leg
            legende.indicateurs(k).humidite.max = {
                ['Risque de croissance de moisissure général ' plages(k).nom ' [-]']};
        end
    end
end

%% == Confort Thermique ==

% == Rationnel ==

if isfield(resultats, 'conf_ratio')
    
    categories_ratio = resultats.conf_ratio.categories.*plages(k).index_h;
    categories_ratio_sum = [
        sum(categories_ratio==4);     %Dépassement CatIII
        sum(categories_ratio==3);     % CatIII
        sum(categories_ratio==2);     % CatII
        sum(categories_ratio==1);     % CatI  (delta=0 inclue)
        sum(categories_ratio==-1);    %-CatI    
        sum(categories_ratio==-2);    %-CatII
        sum(categories_ratio==-3);    %-CatIII    
        sum(categories_ratio==-4);    %Dépassement -CatIII
        ];

    %Nombre d'heures hors de la cat. I
    indicateurs(k).conf_ratio.nb_h_inconf= sum( categories_ratio_sum([1 2 3 6 7 8]),1);
    %Intégrale de l'ecart avec la CatI(+) en PMV.jours
    indicateurs(k).conf_ratio.int_ecart =[ sum (resultats.conf_ratio.ecartCatI(:,1).*plages(k).index_h)/24
                                          -sum (resultats.conf_ratio.ecartCatI(:,2).*plages(k).index_h)/24];
    clear categories_ratio categories_ratio_sum

    if leg
        legende.indicateurs(k).conf_ratio.nb_h_inconf = {
            ['Confort Rationnel: Nombre d''heures hors de la CatI ' plages(k).nom ' [h]']};
        legende.indicateurs(k).conf_ratio.int_ecart = {
            ['Confort Rationnel: Dépassement positif de la CatI ' plages(k).nom ' [PMV.jour]']
            ['Confort Rationnel: Dépassement négatif de la CatI ' plages(k).nom ' [PMV.jour]']};
    end

end

% == Adaptatif ==
if isfield(resultats,'conf_adap')
    categories_adap = resultats.conf_adap.categories.*plages(k).index_h;
    categories_adap_sum = [
        sum(categories_adap==4);    %Dépassement CatIII
        sum(categories_adap==3);    % CatIII +4ºC
        sum(categories_adap==2);    % CatII  +3ºC
        sum(categories_adap==1);    % CatI   +2ºC (Toptimal inclu)
        sum(categories_adap==-1);   %-CatI   -2ºC 
        sum(categories_adap==-2);   %-CatII  -3ºC
        sum(categories_adap==-3);   %-CatIII -4ºC
        sum(categories_adap==-4);   %Dépassement -CatIII
        ];
    %Nombre d'heures hors de la cat. I
    indicateurs(k).conf_adap.nb_h_inconf=sum(categories_adap_sum([1 2 3 6 7 8]),1); 
    %Intégrale de l'ecart avec la CatI en °C.jours
    indicateurs(k).conf_adap.int_ecart =[ sum(resultats.conf_adap.ecartCatI(:,1).*plages(k).index_h)/24;	
                                         -sum(resultats.conf_adap.ecartCatI(:,2).*plages(k).index_h)/24];	
    clear categories_adap categories_adap_sum

    if leg
        legende.indicateurs(k).conf_adap.nb_h_inconf = {
            ['Confort Adaptatif: Nombre d''heures hors de la CatI ' plages(k).nom ' [h]']};
        legende.indicateurs(k).conf_adap.int_ecart = {
            ['Confort Adaptatif: Dépassement positif de la CatI ' plages(k).nom ' [ºC.jour]']
            ['Confort Adaptatif: Dépassement négatif de la CatI ' plages(k).nom ' [ºC.jour]']};
    end


    % == Dépassement DegréJour ==

    limite = 24;
    ecart = resultats.conf_adap.T_zone_operative-limite;

    indicateurs(k).conf_lim24.nb_h_inconf = sum(plages(k).index_h(ecart>0));
    indicateurs(k).conf_lim24.int_ecart = sum( ecart(and(ecart>0,plages(k).index_h))  )/24;

    if leg
        legende.indicateurs(k).conf_lim24.nb_h_inconf = {['Inconfort T>24ºC : Nombre d''heures au delà de 27ºC ' plages(k).nom ' [h]']};
        legende.indicateurs(k).conf_lim24.int_ecart = {['Inconfort T>24ºC : Dépassement de la limite de confort ' plages(k).nom ' [ºC.jour]']};
    end

    % inf a 27
    limite = 20;
    ecart = limite-resultats.conf_adap.T_zone_operative;

    indicateurs(k).conf_lim20.nb_h_inconf = sum(plages(k).index_h(ecart>0));
    indicateurs(k).conf_lim20.int_ecart = sum( ecart(and(ecart>0,plages(k).index_h))  )/24;

    if leg
        legende.indicateurs(k).conf_lim20.nb_h_inconf = {['Inconfort T<20ºC : Nombre d''heures en dessous de 20ºC ' plages(k).nom ' [h]']};
        legende.indicateurs(k).conf_lim20.int_ecart = {['Inconfort T<20ºC : Dépassement de la limite de confort ' plages(k).nom ' [ºC.jour]']};
    end


    % == Minimum et Maximum Journalier ==

    A=reshape(resultats.conf_adap.T_zone_operative(plages(k).index_h),24,[]);
    indicateurs(k).conf_limites = [mean(max(A)); mean(min(A))];
    clear A
    if leg
        legende.indicateurs(k).conf_limites = {
            ['Limite température : Moyenne des maximums journaliers ' plages(k).nom ' [ºC]']
            ['Limite température : Moyenne des mimimums journaliers ' plages(k).nom ' [ºC]']};
    end

end
%% == Ensoleillement ==

if isfield(resultats,'eclairement')

    % Nbs d'heures confortable
    dat= resultats.eclairement.moy_h(:,plages(k).index);
    indicateurs(k).eclairement.taux_conf = sum(sum(dat>=100 & dat<=2000))/sum(sum(dat>0));
    if leg
        legende.indicateurs(k).eclairement.taux_conf = {['Taux d''heures confortables sur les heures d''ensoleillement ' plages(k).nom ' [-]']};
    end
    
    % Nbs d'heures moyenne d'ensoleillement 
%    indicateurs(k).eclairement.nbs_heures = mean(resultats.eclairement.nbs_heures(plages(k).index));

    % Map d'eclairement moyenne sur les heures d'ensoleillement
    map_moy = mean(resultats.eclairement.map_moy_j(:,:,plages(k).index),3);

    % Moyennes d'ensoleillement sur les heures d'ensoleillement
    indicateurs(k).eclairement.moy = mean(indicateurs(k).eclairement.map_moy(:));
    if leg
        legende.indicateurs(k).eclairement.moy = {['Moyennes d''ensoleillement sur les heures d''ensoleillement ' plages(k).nom ' [-]']};
    end

end




end
end

function B=nansum(A,dim)
A(isnan(A))=0;
B=sum(A,dim);


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