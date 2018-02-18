function commun_analyse
% COMMUN_ANALYSE gère les différentes analyses à réaliser suivant le type
% d'etude choisie
%
% La variable analyse contient toute les informations nécéssaire:
%     o Le type d'analyse  par son identifiant
%     o Les variables/paramètres à analyser
%         entrees = { Nom, ModeRempl, InputType, {Params} }
%             Nom       : Nom de la variable à remplacer dans le fichier idf
%             ModeRempl : Mode de remplacement (voir: modif_IDF() + modif_EPW() )
%             InputType : Type de ddp des variables (voir: modif_IDF() + les fonctions si-dessous)
%                           0- discret uniforme / déf. = [val1, val2, ..]
%                           1- uniforme / déf. = [min max]
%                           2- gaussienne / déf. = [moyenne ecart_type]
%             Params    : Paramètres de la répartition
%     o Le plan des simulation à réaliser
%     o Les E/S suprementaires nécéssaire à l'analyse
%     o La matrice des resultats
%
% Identifiants des type d'analyses présentes:
%     0 - Simulation simple du fichier de base
%     1 - Aléa
%     2 - ASL
%     3 - Random Balance Designs - FAST
%     4 - ...


% 
% SOUMISSIONNAIRE :
% Mickael Rabouille (création)
% 
% Version du 06/09/2012
% A FAIRE:
% 
%

global params
global resultat
global analyse
global simulation

nb_sorties=size(resultat.sorties,2);


switch analyse.type_etude
    case 0  %Pas d'étude: affichage des résultats
        fprintf('Pas d''étude: affichage des résultats de la première simulation.\n');
        
        analyse.M=mean(resultat.sorties(:,resultat.sorties_valide),1);
        analyse.V=var(resultat.sorties(:,resultat.sorties_valide),0,1);
        resultat.sorties(1,:)'


%     case 1  %Polynome                
%         analyse.si=zeros(params.variables.vars_nb,nb_sorties);
% 
%         %problème avec les données discretes !!!!
%         if any(strcmpi({params.variables.infos(params.variables.vars_index).loi}, 'Discret'))
%             error('Entrée non numérique présente !');
%         end
% 
%         %mise en forme des entrées
%         vals = vertcat(params.variables.infos(params.variables.vars_index).limites);
%         mini = vals(:,1)';
%         maxi = vals(:,2)';
%         variations=bsxfun(@rdivide, bsxfun(@minus,cell2mat(params.plan(:,1:params.variables.vars_nb)),mini),maxi-mini);
% 
%         %etude des sorties
%         for i=1:nb_sorties
%             ordre=10;
%             [model,effets,indices,facteurs,famille]=poly_chaos(variations,resultat.sorties(:,i),ordre,'1');
% 
%             analyse.si_poly(:,:,i)=effets;                
%             analyse.si_poly_simple(:,i)= diag(effets);
%         end

    case 2  %Polynome BLATMAN
        %pour l'instant filtre les données discretes !!!!
         if any(strcmpi({params.variables.infos(params.variables.vars_index).loi}, 'Discret'))
             warning('Entrée non numérique présente !');
         end

        %Utilisatation de la ToolBox
        analyse.PC_Infos = PCE_Blatman('global');
        
% affichage de la convergence        
%         for k=10:10:600
%             if length(X)>k && X(k)>0
%                 continue
%             end
%             analyse.PC_Infos = PCE_Blatman('global');
%             SI_PCE1(k,:)=analyse.PC_Infos(3).GSA.SobolInd{1};
%             Err_PCE1(k,:)=analyse.PC_Infos(3).ErrorEstimates.Q2;
%             SI_PCE2(k,:)=analyse.PC_Infos(6).GSA.SobolInd{1};
%             Err_PCE2(k,:)=analyse.PC_Infos(6).ErrorEstimates.Q2;
%             X(k)=k;
%         end
%         semilogy(X(X>0),1-Err_PCE1(X>0,:),X(X>0),1-Err_PCE2(X>0,:))
%         plot(X(X>0),SI_PCE1(X>0,:))
%         plot(X(X>0),SI_PCE1(X>0,:))
        
              if false     

                    dossier = 'Images(b13)LARSimple' %Regression   LAR
                    mkdir(fullfile(params.rep_result,dossier));
                    hFig=figure('Visible','on');
                    %        'Isol'IsolVS'IsolComb'Chape'ventNHab'infil'Consig'
                    %         0.15, 0.10,  0.10  , 0.08,  4,       2,    21
                    X_fixe = [0.15, 0.10,  0.10  , NaN ,  NaN,     NaN,   21];
                    find_Y_valide = find(resultat.sorties_valide);
                    find_X_valide = find(isnan(X_fixe));
                    [YPC,X] = metamodelPC(PC_Infos,params.entrees_IDF.vars,1000,X_fixe);
                    for j=1:size(find_Y_valide,2)
                        for i=1:size(find_X_valide,2)
                            h=plot(X(:,find_X_valide(i)),YPC(:,j),'.');
                            title(sprintf('%s - %s',legende.sorties{find_Y_valide(j)},legende.vars{find_X_valide(i)}))
                            saveas(h, fullfile(params.rep_result,dossier,sprintf('%d-%d.jpg',j,i)) )
                        end
                    end
                    close(hFig)
              end   
    case 22  %Polynome BLATMAN
        %pour l'instant filtre les données discretes !!!!
         if any(strcmpi({params.variables.infos(params.variables.vars_index).loi}, 'Discret'))
             warning('Entrée non numérique présente !');
         end

        %Utilisatation de la ToolBox
        analyse.PC_Infos = PCE_Blatman('local');
        
        
    case 3  %Random Balance Designs
        fprintf('-> Random Balance Designs - FAST.\n')
        if ~isfield(analyse,'RBD') || ~isfield(analyse.RBD,'harmonics')
            analyse.RBD.harmonics=10;
        end
        if ~isfield(analyse,'RBD') || ~isfield(analyse.RBD,'force')
            analyse.RBD.force=false;    % outrepasse les vérifications de l'analyses
        end
        
        
        if params.type_ech==3
            analyse.SI_rbdfast=rbd_fast(1,analyse.RBD.force,analyse.RBD.harmonics,params.index_rbd_fast,resultat.sorties);
        else            
            analyse.SI_rbdfast=rbd_fast(1,analyse.RBD.force,analyse.RBD.harmonics,[],resultat.sorties((simulation.etats>=2), resultat.sorties_valide),params.plan((simulation.etats>=2),1:params.variables.vars_nb));
        end
        analyse.M=mean(resultat.sorties(:,resultat.sorties_valide),1);
        analyse.V=var(resultat.sorties(:,resultat.sorties_valide),0,1);
        analyse.SI_rbdfast;
       
        % affichage de la convergence
        if isfield(analyse,'convergence') &&  analyse.convergence
            fprintf('-> Convergence analysis.\n')
            if analyse.convergence_param.input==0
                analyse.convergence_param.input = params.variables.vars_index;
            end
            if analyse.convergence_param.output==0
                [~,IdMaxVar] = max(analyse.V);
                analyse.convergence_param.output = find(cumsum(resultat.sorties_valide)==IdMaxVar, 1, 'first');
            end
            
            % clear X Vsimple Msimple SI_rbdfast
            start = analyse.RBD.harmonics*2+1;
            steps = start:analyse.convergence_param.step:params.nb_tir; if rem(params.nb_tir-start,analyse.convergence_param.step)~=0, steps = [steps params.nb_tir]; end
            for k=1:length(steps)
                Vsimple(k,:)=var(resultat.sorties(1:steps(k),analyse.convergence_param.output),0,1);
                Msimple(k)=mean(resultat.sorties(1:steps(k),analyse.convergence_param.output),1);
                SI_rbdfast(k,:)=rbd_fast(1,1,analyse.RBD.harmonics,[],resultat.sorties(1:steps(k),analyse.convergence_param.output),params.plan(1:steps(k),analyse.convergence_param.input));
            end
            figure
            plot(steps,Vsimple/Vsimple(end),steps,Msimple/Msimple(end),steps,SI_rbdfast)
            if resultat.range_temporal==0
                title( analyse.legende_sorties(analyse.convergence_param.output) )
            else
                title( analyse.legende_sorties )
            end
            legend(horzcat( {'Var / Final Var','Mean / Final Mean'},strcat( repmat({'SI of '},params.variables.vars_nb,1), analyse.legende_entrees(:,1))') , 'Location','SouthWest')
            xlabel('Number of simulation')

        end
        
        % Indicateur Bootstrapé
        if isfield(analyse,'bootstrap') &&  analyse.bootstrap
            fprintf('-> Bootstrap analysis.\n')
            for rep=1:analyse.bootstrap_param.rep
                % Selection aléatoire de données avec retirage
                Ind = randi(size(resultat.sorties,1),analyse.bootstrap_param.ech,1);
                
                if params.type_ech==3
                    SIbs_rbdfast(:,:,rep)=rbd_fast(1,true,analyse.RBD.harmonics,params.index_rbd_fast(Ind,:),resultat.sorties(Ind,:));
                else
                    SIbs_rbdfast(:,:,rep)=rbd_fast(1,true,analyse.RBD.harmonics,[],resultat.sorties(Ind,:),params.plan(Ind,1:params.variables.vars_nb));
                end
            end
            analyse.SIbs_rbdfast_mean = mean(SIbs_rbdfast,3);
            analyse.SIbs_rbdfast_var = var(SIbs_rbdfast,0,3);
        end
        
    case 4  %Random Balance Designs for temporal analysis
        fprintf('-> Random Balance Designs - FAST.\n')
        
        
    case 5  %SOBOL
        fprintf('-> Indices de SOBOL.\n')

        analyse.SI_sobol = zeros(params.variables.vars_nb,nb_sorties);
%         if analyse.bootstrap
%             SIbs_sobol_ref(rep,:) = zeros(analyse.bootstrap_param.rep,nb_sorties);
%             SIbs_sobol_salt(rep,:) = zeros(analyse.bootstrap_param.rep,nb_sorties);
% 
%             SIbs_sobol_ref_mean = zeros(params.variables.vars_nb,nb_sorties);
%             SIbs_sobol_ref_var = zeros(params.variables.vars_nb,nb_sorties);
%             SIbs_sobol_salt_mean = zeros(params.variables.vars_nb,nb_sorties);
%             SIbs_sobol_salt_var = zeros(params.variables.vars_nb,nb_sorties);
%         end
        
        Y1=resultat.sorties(1:end/2,:);
        YB=resultat.sorties(end/2+1:end,:);
        
        % L'estimateurs de moyene et de variance 
        % (plus robuste si fait avec l'ensemble des données non triées)
        %M2=mean(Y1.*YB,1);
        analyse.M=sqrt(mean(Y1.*YB,1));
        
        %analyse.V = mean(Y1.*Y1)-M2; 
        analyse.V = var((Y1-YB)/sqrt(2),0,1);

        for i=1:params.variables.vars_nb
           % [~,tri]=sort(params.index_perm(:,i));
            [~,tri]=sort(params.index_rbd_sobol(:,i));
            
            Y2=resultat.sorties(end/2+tri,:);
            % test du reclassement: erreur si diff de zéro
            % sum(sum(abs([params.plan(1:end/2,i) -params.plan(end/2+tri,i)]))) 

            % Indicateur
            
            %analyse.SI_sobol(i,:) =(mean(Y1.*Y2,1)-M2)./analyse.V;
            analyse.SI_sobol(i,:)= mean(Y1.*(Y2-YB),1)./analyse.V;

            % Indicateur Bootstrapé
            if analyse.bootstrap
                fprintf('-> Bootstrap analysis.\n')
                for rep=1:analyse.bootstrap_param.rep
                    % Selection aléatoire de données avec retirage
                    Ind = randi(size(Y1,1),analyse.bootstrap_param.ech,1);
                    Y1bs=Y1(Ind,:);
                    Y2bs=Y2(Ind,:);

                    Variance(rep,:) = var(( Y1bs-Y2bs(randperm(length(Ind)),:) )/sqrt(2),0,1);

                    %M2b(rep,:) = mean(Y1bs.*Y2bs(randperm(length(Ind)),:),1);                    
                    %SIbs_sobol(rep,:)=(mean(Y1bs.*Y2bs,1)-M2b(rep,:))./Variance(rep,:);
                   
                    SIbs_sobol(rep,:)= mean(Y1bs.*(Y2bs-Y2bs(randperm(analyse.bootstrap_param.ech),:)),1)./Variance(rep,:);
                end
 %             analyse.SIbs_sobol(i,:,:) = SIbs_sobol;
 
 
                SIbs_sobol((isinf(SIbs_sobol)))=NaN;               
                analyse.SIbs_sobol_mean(i,:) = nanmean(SIbs_sobol(:,:),1);
                
                for s=1:nb_sorties
                    numnan = isnan(SIbs_sobol(:,s));
                    if sum(numnan)>0.25*analyse.bootstrap_param.rep
                        analyse.SIbs_sobol_var(i,s)=NaN;
                        continue
                    end
                    SIbs_sobol(numnan,s)=analyse.SIbs_sobol_mean(i,s);
                    
                    analyse.SIbs_sobol_var(i,s) = var(SIbs_sobol(:,s),0,1)*(analyse.bootstrap_param.rep-1)/(analyse.bootstrap_param.rep-1-sum(numnan));
                end
            end
            
            
        end
        
        if isfield(analyse,'convergence') &&  analyse.convergence
            warning('-> Convergence analysis bust be defined.\n')
% affichage de la convergence 
%         for i=1:params.variables.vars_nb
%             [~,tri]=sort(params.index_rbd_sobol(:,i));
%             for k=1:3000/30            
%                 X(k)=k*30/2;
%                 Y1=resultat.sorties(1:k*30/2,resultat.sorties_valide);
%                 YB=resultat.sorties(end/2+1:end/2+k*30/2,resultat.sorties_valide);
%                 V(k)=var((Y1-YB)/sqrt(2),0,1);
%                 M(k)=sqrt(mean(Y1.*YB,1));
%                 Y2=resultat.sorties(end/2+tri(1:k*30/2),resultat.sorties_valide);
%                 SI_sobol(k,i)= mean(Y1.*(Y2-YB),1)./V(k);
%             end
%         end
%         plot(X,V/V(end),X,M/M(end),X,SI_sobol)
        
%{
   for i=1:params.variables.vars_nb
            [~,tri]=sort(params.index_perm(:,i));
            Y2=resultat.sorties(end/2+tri,:);
                %analyse.si_sobol_ref(i,:)=(mean(Y1.*Y2)-M2)./V;
                for rep=1:100
                     for Nb=1:1*size(Y1,1)
                        permut=randperm(size(Y1,1));
                        Ind(Nb,1)=permut(1);
                     end
                     %Ind=repmat(1:size(Y1,1),1,10)';
                 for t=1:size(Y1,2)
                 Variance=var([(Y1(Ind,t)-Y2(Ind(randperm(length(Ind))),t))/sqrt(2)]);%Meilleur façon d'avoir l'estimateur
                       %original
                        analyse.SI_sobol(i,t,rep)=(mean(Y2(Ind,t).*Y1(Ind,t))-mean(Y2(Ind(randperm(length(Ind))),t).*Y1(Ind,t)))./(Variance);
                        %saltelli 2010 OK 
                        analyse.SI_sobol_salt(i,t,rep)= mean(Y1(Ind,t).*(bsxfun(@minus,Y2(Ind,t),Y2(Ind(randperm(length(Ind))),t))))./Variance;
                 end
                end
%}
        end
        

    case 6  %MORIS
        fprintf('-> Screening MORIS - .\n')
        
        simulationValide = simulation.etats>=2;
        if ~all(simulationValide)
            %fitre les resultats valides par trajectoire
            simulationValide = repmat(all(reshape(simulationValide,params.variables.vars_nb+1,[]),1),params.variables.vars_nb+1,1);
            simulationValide=simulationValide(:);
            
        end
        
        [analyse.SAmeasurement_Morris, OutMatrix] = Morris_Measure_Groups(params.variables.vars_nb, params.MORIS_sampledTraj(simulationValide,:), resultat.sorties(simulationValide, resultat.sorties_valide), params.MORIS_levels, params.MORIS_groupMat);
        
        analyse.M=mean(resultat.sorties(:,resultat.sorties_valide),1);
        analyse.V=var(resultat.sorties(:,resultat.sorties_valide),0,1);
        analyse.AbsMu_Morris = OutMatrix(:,1);
        analyse.Mu_Morris = OutMatrix(:,2);
        analyse.StDev_Morris = OutMatrix(:,3);
        
end


% Code for Temporal analysis of RBD FAST
% See also end of EPLab\EPLab.m
if false
    warning('Tambouille perso !!!!!!!!')
    X = params.plan((simulation.etats>=2),1:params.variables.vars_nb);
    for a=find(resultat.sorties_valide)
        Y = resultat.sorties((simulation.etats>=2), a);

        analyse.signe(:,a)=sign( robustfit(X,Y,[],[],'off') );

    %     B=regress(Y,X)
    %     C=glmfit(X,Y)
    %     [A, B, C,  analyse.SI_rbdfast(:,a) ]
    % 
    %     mdl = fitlm(X,Y,'linear','RobustOpts','on');
    %     analyse.signe(:,a)=sign( mdl.Coefficients.Estimate(2:end) );

    end
end 

end






