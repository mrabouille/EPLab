function PC_Infos=PCE_Blatman(type, N, X_fixe, fhandle)
% PCE_Blatman communique avec la ToolBox de G. Blatman 
%
% References
%     *** chaos adaptatif : G. Blatman and B.Sudret ,An adaptive algorithm
%     to build up sparse polynomial chaos expansions for stochastic finite
%     element analysis
%     *** algo LARS G. Blatman and B.Sudret, Adaptive sparse polynomial
%     chaos expansion based on {L}east {A}ngle {R}egression
%     *** Utilisation en analyse de sensibilité G. Blatman and B.Sudret,
%     Efficient computation of global sensitivity indices using sparse
%     polynomial chaos expansions
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
%   01/03/2013  First Edition
%   12/03/2013  Last Change

% A FAIRE:
% 
%
global resultat
global params
global simulation

global legende
global local
%% Définitions générales


%=Utlilité à définir 
    % Write 'RF = 0' if no random field involved
    %RF = 0;
    
    %gPC.Order = p ;
%=
    
switch type
    case {'global','local'}
    %% Analyse de type globale/local:
    % Construction du méta modèle de base à partir des simulations
    % les entrées varies uniformément sur leurs domaines de définition.
    
    % Méthode de résolution
    NI_options.Method = 'AdapLAR';       %'Regression', 'LAR' or 'AdapLAR'
    multi = true;

    % Number of input random variables
    M=params.variables.vars_nb;
    
    
    % Selection des sorties
    PC_Infos.sorties_valide = resultat.sorties_valide;

    % Order up to which compute the sensitivity indices
    NI_options.GSA.MaxOrder = 3;   
    
    % Type de modèle
    Model.Type = 'Data' ;
    Model.Dir = fullfile( params.rep_result,'PCE_Data.txt');

    % Definition of the input random variables
    if strcmp(type,'global') 
        %% global
        Input(1:M)=struct('Type',[],'Moments',[],'Param',[],'TypePol',[]);
        vars_discet = false(1,M);
        for i=1:M
            switch params.variables.infos(params.variables.vars_index(i)).loi
                case {0,'Discret'} %discret uniforme
                    Input(i).Type = 'Uniform' ;
                    Input(i).Moments = [] ;
                    Input(i).Param = [0.5 length(params.variables.infos(params.variables.vars_index(i)).limites)+0.5] ;
                    Input(i).TypePol = 'Legendre' ;
                    vars_discet(i)=true;

                otherwise % recherche sur une plage large loi uniforme
                    Input(i).Type = 'Uniform' ;
                    Input(i).Moments = [] ;
                    Input(i).Param = params.variables.infos(params.variables.vars_index(i)).limites ;
                    Input(i).TypePol = 'Legendre' ;
            end
        end

    else
        %% local
        Input(1:M)=struct('Type',[],'Moments',[],'Param',[],'TypePol',[]);
        vars_discet = false(1,M);
        for i=1:M
            Input(i).name = params.variables.infos(params.variables.vars_index(i)).nom;
            switch params.variables.infos(params.variables.vars_index(i)).loi
                case {0,'Discret'} %discret uniforme
                    Input(i).Type = 'Uniform' ;
                    Input(i).Moments = [] ;
                    Input(i).Param = [0.5 length(params.variables.infos(params.variables.vars_index(i)).limites)+0.5] ;
                    Input(i).TypePol = 'Legendre' ;
                    vars_discet(i)=true;
                case {1,'Uniform'} %uniforme 
                    moy  = params.variables.infos(params.variables.vars_index(i)).moments(1);
                    ecart = params.variables.infos(params.variables.vars_index(i)).moments(2);
                    Input(i).Type = 'Uniform' ;  %  'Gaussian', 'Lognormal', 'Beta', 'Uniform'
                    Input(i).Moments = [] ;      %  [<mean>   <standard deviation>]
                    Input(i).Param = [moy-ecart moy+ecart] ;
                    Input(i).TypePol = 'Legendre' ;%   'Hermite', 'Legendre'
                case {3,'UniformR'} %uniforme
                    moy  = params.variables.infos(params.variables.vars_index(i)).moments(1);
                    ecart = params.variables.infos(params.variables.vars_index(i)).moments(2)/100;
                    Input(i).Type = 'Uniform' ;
                    Input(i).Moments = [] ;
                    Input(i).Param = moy+abs(moy)*ecart*[-1 1];
                    Input(i).TypePol = 'Legendre' ;
                case {2,'Gaussian'} %gaussienne
                    moy  = params.variables.infos(params.variables.vars_index(i)).moments(1);
                    ecart = params.variables.infos(params.variables.vars_index(i)).moments(2);
                    Input(i).Type = 'Gaussian' ;
                    Input(i).Moments = [moy ecart/1.96] ; %2.58 -> 99% voir: LHS()
                    Input(i).Param = [] ;
                    Input(i).TypePol = 'Hermite' ;
                case {4,'GaussianR'} %gaussienne
                    moy  = params.variables.infos(params.variables.vars_index(i)).moments(1);
                    ecart = params.variables.infos(params.variables.vars_index(i)).moments(2)/100;
                    Input(i).Type = 'Gaussian' ;
                    Input(i).Moments = [moy abs(moy)*ecart/1.96] ; %2.58 -> 99% voir: LHS_simple()
                    Input(i).Param = [] ;
                    Input(i).TypePol = 'Hermite' ;
            end
        end
keyboard
    end
   
    case 'PC sur PC'
    %% Analyse de type PC sur PC:
    % Construction d'un second méta modèle à partir du premier (pour l'AS)
    % les entrées varies autour d'une valeur selon leurs lois de distribution.
    
    % Méthode de résolution
    NI_options.Method = 'LAR';       %'Regression', 'LAR' or 'AdapLAR'
    multi = false;
    
    vars_index = params.variables.vars_index(find(isnan(X_fixe)));
    
    % Number of input random variables
    M=sum(isnan(X_fixe)); %toutes sauf les discrètes
    keyboard
    % Type de modèle
    Model.Type = 'Matlab' ;        
    Model.Name = 'fhandle';
    % Initial sample size
    NI_options.NbSamples = 50 ;
    
    % Order up to which compute the sensitivity indices
    NI_options.GSA.MaxOrder = 4 ;    
    
    % Definition of the input random variables
    Input(1:M)=struct('Type',[],'Moments',[],'Param',[],'TypePol',[]);
    for i=1:M
        moy  = params.variables.infos(vars_index(i)).moments(1);
        ecart = params.variables.infos(vars_index(i)).moments(2);
        
        switch params.variables.infos(vars_index(i)).loi
            case {0,'Discret'}
                error ('Impossibru !!!')
                
            case {1,'Uniform'} %uniforme                
                Input(i).Type = 'Uniform' ;  %  'Gaussian', 'Lognormal', 'Beta', 'Uniform'
                Input(i).Moments = [] ;      %  [<mean>   <standard deviation>]
                Input(i).Param = [moy-ecart moy+ecart] ;
                Input(i).TypePol = 'Legendre' ;%   'Hermite', 'Legendre'
            case {3,'UniformR'} %uniforme
                Input(i).Type = 'Uniform' ;
                Input(i).Moments = [] ;
                Input(i).Param = moy*[1-ecart 1+ecart] ;
                Input(i).TypePol = 'Legendre' ;

            case {2,'Gaussian'} %gaussienne
                Input(i).Type = 'Gaussian' ;
                Input(i).Moments = [moy ecart/2.58] ; %2.58 -> 99% voir: LHS_simple()
                Input(i).Param = [] ;
                Input(i).TypePol = 'Hermite' ;
            case {4,'GaussianR'} %gaussienne
                Input(i).Type = 'Gaussian' ;
                Input(i).Moments = [moy moy*ecart/2.58] ; %2.58 -> 99% voir: LHS_simple()
                Input(i).Param = [] ;
                Input(i).TypePol = 'Hermite' ;

            % Reste 'Lognormal' et 'Gumbel'
        end
    end 

end

%% Définition de l'analyse

if multi
    % s boucle sur chaque sortie: 1 méta-modèle par sortie
    sortie=resultat.sorties_valide_index;
else
    % s est un vecteur colonne -> pas de boucle: 1 méta-modèle global
    % base polynomiale commune à toutes les sorties !AdapLAR!
    sortie=resultat.sorties_valide_index';
end

%%

if ~exist('N','var') || isempty(N)
    N = params.nb_tir;
end

% for boucle=1:22
%     if boucle<10
%         N = boucle*20
%     elseif boucle<18
%          N = (boucle-10)*50+200
%     else        
%          N = (boucle-18)*100+600
%     end


tic
for s=sortie
    switch NI_options.Method
        case {'Regression'}
            p = 6;      %13                           % Ordre du polynome
            q = 0.5;                                % Norm for PC truncation: q must belong to (0,1]

            NI_options.SamplingScheme = 'LHS' ;     % Monte Carlo ('MCS'), Latin Hypercube ('LHS')
                                                    % or quasi-random sequences:
                                                    % Sobol' ('S'), Faure ('F') or
                                                    % Halton ('H')

        case {'LAR'}
            p = 8;                                 % Ordre du polynome
            q = 0.8;                                % Norm for PC truncation: q must belong to (0,1]

            NI_options.NbSamples = 3*nchoosek(M+p,p);
            NI_options.SamplingScheme = 'LHS';      %  Monte Carlo ('MCS'), Latin Hypercube ('LHS')
                                                    %  or quasi-random sequences:
                                                    %  Sobol' ('S'), Faure ('F') or
                                                    %  Halton ('H')
            NI_options.LarsMethod = 'lasso' ;       %  'lars' or 'lasso' (LASSO allows one to discard insignificant PC terms,
                                                    %  but the calculations may take more
                                                    %  time than LARS


        case {'AdapLAR'}
            NI_options.Param.NormType = 1 ;  % 0.7    % Norm for PC truncation (in (0,1])  see p78  2.2.1
            NI_options.Param.MaxDegree = 12 ;  % 12    % Maximal PC degree 
            NI_options.LarsMethod = 'lasso' ;        % 'lars' or 'lasso' (LASSO allows one to discard insignificant PC terms,
                                                    % but the calculations may take more time than LARS
            NI_options.Param.TargetCrit = 1 ;  % Target relative accuracy (maximum=1)

    end
    % NON modifiable:
    NI_options.RecValues = 'yes';            % 'yes' to store input/output data in the 'Results' structure
    % NON ajouté
    NI_options.Param.HigherMoments='no';    % 'yes' to compute the skewness and kurtosis coefficients
                                            % CAUTION: may be time consuming, especially in the case of a full PC expansion!
    %     Le coefficient de Skewness mesure le degré d'asymétrie de la distribution
    %     (soit le moment d'ordre trois centré sur le cube de l'écart-type)
    %         S'il est égal à 0 la distribution est symétrique  
    %         Plus petit que 0, la distribution est asymétrique vers la gauche.
    %         Plus grand que 0, la distribution est asymétrique à droite
    %     Le coefficient de Kurtosis mesure le degré d'écrasement de la distribution. 
    %     soit le rapport entre le moment d'ordre quatre centré et le carré de la variance
    %         Lorsqu'il est positif, cela indique que la distribution est "pointue".
    %         Lorsqu'il est négatif, cela indique que la distribution est relativement "écrasée".

    clear Results gPC;
    InputRV = Input;
    
    if any(strcmp(type,{'global','local'}) )
        if all(simulation.etats==2)
            PCE_Data = [params.plan(1:N,1:M) resultat.sorties(1:N,s)];            
        else
            warning('Incomplet !!')
            PCE_Data = [params.plan(simulation.etats==2,1:M) resultat.sorties(simulation.etats==2,s)];
        end
        
        save(Model.Dir,'PCE_Data','-ascii')
    end

    warning('off','MATLAB:oldPfileVersion')
    Non_Intrusive_PCE()
    warning('on','MATLAB:oldPfileVersion')

    % Sauvegarde
    if (length(s)==1) id=s; else id=1; end
    
    PC_Infos(id).NI_options = NI_options;
    PC_Infos(id).InputRV = InputRV;
    
    PC_Infos(id).gPC = gPC;
    PC_Infos(id).Coefs = Results.Coefs;
    
    if NI_options.GSA.MaxOrder>0
        PC_Infos(id).GSA = Results.GSA;
        PC_Infos(id).GSA.index = Z;
    end
    
    if isfield(Results,'ErrorEstimates')
        PC_Infos(id).ErrorEstimates = Results.ErrorEstimates;
    end

end
PC_Infos(1).vars_discet=vars_discet;


if false
% Evaluate the PC metamodel at the sample points
% évaluation déjà réalisée dans le PC
YPC = metamodelPC(PC_Infos,params.variables,X);
Err = mean((resultat.sorties(simulation.etats==2,1:resultat.sorties_valide_index(end))-YPC).^2) ./ var(resultat.sorties(simulation.etats==2,1:resultat.sorties_valide_index(end)));
Err(~resultat.sorties_valide) = NaN;
fprintf('Erreur L² du polynome:\n');
fprintf([repmat(' \t%g',1,length(Err)), '\n'],Err);

elseif false
% Evaluate the PC metamodel at other points
%save(fullfile(params.rep_result,'data_to_exp.mat'), 'ext_dat')
load(fullfile(params.rep_result, 'data_to_imp.mat'));

fprintf('======= Les résultats de simulation ''%s'' ont été chargés =======\n', ext_dat.nom)
YPC = metamodelPC(PC_Infos,params.variables, ext_dat.plan(1:N,:));

sortie_ext = zeros(size(YPC));
sortie_ext(:,resultat.sorties_valide_index) = ext_dat.results(1:N,:);
Err = 1-mean((sortie_ext-YPC).^2) ./ var(sortie_ext);
fprintf('Erreur R² du polynome:\n');
fprintf([repmat(' \t%g',1,length(Err)), '\n'],Err);

% converg1(boucle,:) = [Err(1) struct2array(PC_Infos(1).ErrorEstimates)];
% converg2(boucle,:) = [Err(7) struct2array(PC_Infos(7).ErrorEstimates)];
% converg3(boucle,:) = [Err(13) struct2array(PC_Infos(13).ErrorEstimates)];
% converg4(boucle,:) = [Err(17) struct2array(PC_Infos(17).ErrorEstimates)];
% abscise(boucle) = N;
% 
% end 


fprintf(' R2croisée ; R2local; Q2')
A= [Err(resultat.sorties_valide_index); [struct2array(PC_Infos(1).ErrorEstimates)',struct2array(PC_Infos(7).ErrorEstimates)',struct2array(PC_Infos(13).ErrorEstimates)',struct2array(PC_Infos(17).ErrorEstimates)']]

fprintf('indices de sensibilité: principaux / totaux')
%= [PC_Infos(1).GSA.SobolInd{1}, PC_Infos(7).GSA.SobolInd{1}, PC_Infos(13).GSA.SobolInd{1}, PC_Infos(17).GSA.SobolInd{1}]
% B= [PC_Infos(1).GSA.TotalSobolInd, PC_Infos(7).GSA.TotalSobolInd, PC_Infos(13).GSA.TotalSobolInd, PC_Infos(17).GSA.TotalSobolInd]
end

toc
%%


if false
    
    % Création du répertoire de destination
    rep_image = fullfile(params.rep_result,[local.noms.image '_PC']); n=1;
    while isdir(rep_image)
        n=n+1;
        rep_image=fullfile(params.rep_result,[local.noms.image '_PC(' int2str(n) ')']);
    end
    mkdir(fullfile(rep_image,'Erreurs'));

for prout=1:4
    h=figure
    plot(abscise, 1-eval(['converg' num2str(prout)]),'LineWidth',2)
    set(gca,'YLim',[0.000001 1])
    set(gca,'Ytick', [0.00001,0.0001,0.001,0.01,0.1,1;])
    set(gca,'Yscale','log', 'FontSize', local.images.fontsize);
    set(gca, 'YGrid', 'on')
    set(gca,'XGrid', 'off');
    set(get(gca,'Xlabel'),'String','Nombre de simulations', 'FontSize', local.images.fontsize)
    set(get(gca,'Ylabel'),'String',['Erreurs :', legende.sorties(resultat.sorties_valide_index(prout))], 'FontSize', local.images.fontsize)

    legend(gca,{'\epsilon_{croisée}';'\epsilon_{local}';'\epsilon_{PRESS}'},'Location','Best','Orientation','vertical')
    saveas(h, fullfile(rep_image,'Erreurs',['1_' num2str(prout) '.jpg']) )
end
   



    
    %  Affiche la corrélation entre le model et le metamodel
    h=figure
    col=hsv(sum(resultat.sorties_valide,2));
    for k=1:sum(resultat.sorties_valide,2)
        plot (sortie_ext(:,resultat.sorties_valide_index(k)),YPC(:,resultat.sorties_valide_index(k)),'+', 'Color', col(k,:))
        hold on
    end
    hold off
      set(gca,'YLim',[-10 200],'XLim',[-10 200], 'FontSize', 13, 'XGrid', 'on', 'YGrid', 'on');
             
    set(get(gca,'Xlabel'),'String','Model STD', 'FontSize', local.images.fontsize)
    set(get(gca,'Ylabel'),'String','Méta-modèle PCE', 'FontSize', local.images.fontsize)
    legend(gca,legende.sorties(resultat.sorties_valide_index),'Location','NorthWest','Orientation','vertical')
     
%        title(sprintf('%s - %s',legende.sorties{j},legende.vars{i,1}))
    saveas(h,  fullfile(rep_image,'Erreurs',['1_corrélation300.jpg']) )


    

    %   Compare the PDFs of the model and the metamodel
    for k=1:sum(resultat.sorties_valide,2)
        h=figure;
  %      subplot(sum(resultat.sorties_valide,2),1,k);
        hold on
        kernel1(ext_dat.results(:,k))
        v=findobj(gcf, 'Type','line');
        set(v(1),'color', col(k,:), 'LineStyle','-','LineWidth',2)%, 'Marker',form{k}

        kernel1(YPC(:,sortie(k)))
        v=findobj(gcf, 'Type','line');
        set (v(1),'color', col(k,:), 'LineStyle','--','LineWidth',2)%, 'Marker',form{k}
        hold off    
        
        
        legend(gca, 'Model','PC metamodel','Location','Best')  %,'Orientation','vertical'
        
        set(get(gca,'Xlabel'),'String',legende.sorties(resultat.sorties_valide_index(k)), 'FontSize', local.images.fontsize)
        set(get(gca,'Ylabel'),'String','Densité de probabilité', 'FontSize', local.images.fontsize)
%        title(sprintf('%s - %s',legende.sorties{j},legende.vars{i,1}))
        saveas(h, fullfile(rep_image,'Erreurs',sprintf('2_densité sortie %d.jpg',k)) )
    end
end

end

function clc()
end

 