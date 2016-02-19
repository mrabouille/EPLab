function [si,vars_ok,YPC]=analyse_rapide(PC_Infos, variables, X_fixe, nb_tir)

for k=1:length(X_fixe)
    if strcmpi(variables.infos(variables.vars_index(k)).loi,'Discret')
        if isnan(X_fixe(k)), error('S.A. impossible! Veuillez choisir une valeur pour les variables discrètes.'), end
        variables.infos(variables.vars_index(k)).limites={variables.infos(variables.vars_index(k)).limites{X_fixe(k)}};
        X_fixe(k)=NaN;
    else
        if isnan(X_fixe(k))
            variables.infos(variables.vars_index(k)).moments(2)=0;
        else
            variables.infos(variables.vars_index(k)).moments(1)=X_fixe(k);
        end
    end
end
%variables analysées
vars_ok = ~isnan(X_fixe);

% ech
fprintf('-> Latin Hypercube Sampling pour SOBOL (simple).\n')
plan=LHS_local(nb_tir, {variables.infos(variables.vars_index).loi}, {variables.infos(variables.vars_index).moments});

% Réation de l'index de permutation
for i=1:length(vars_ok)
    index_perm(:,i)=randperm(nb_tir);
    plan2(:,i)=plan(index_perm(:,i),i);
end
plan = cell2mat(vertcat(plan,plan2));
nb_tir = nb_tir*2;


% simulation
YPC = metamodelPC(PC_Infos,variables,plan);

%reduction aux sorties valides
YPC = YPC(:,PC_Infos(1).sorties_valide);
% SA
si = zeros(length(vars_ok),size(YPC,2));

Y1=YPC(1:end/2,:);
Y2=YPC(end/2+1:end,:);

M2=mean(Y1.*Y2,1);
V=var((Y1-Y2)/sqrt(2),0,1);

for i=find(vars_ok)'
    [~,tri]=sort(index_perm(:,i));
    Y2=YPC(end/2+tri,:);
    %                   [params.plan(1:end/2,i) params.plan(end/2+tri,i)]
    si(i,:)=(mean(Y1.*Y2,1)-M2)./V;
end

