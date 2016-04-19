function test_fin(obj, event, test_delay)
%TEST_FIN Callback: teste l'existance du dernir résultat de simulation 
% 
%     test_delay  : temps d'attente entre les tests
%     file        : nom complet du fichier à tester
% 
% 

% SOUMISSIONNAIRE :
% Mickael Rabouille (création)
% 
% Version du 16/10/2012
%
% A FAIRE:
% Verifier les autres simulations (boucle).
%  Attention les dernieres simulations (sur les autres proc.) peuvent ne
%  pas etre finies.

global simulation params
persistent test
if isempty(test), test=true; end

%pause(test_delay) % met en pause matlab pour attendre les simulations

simulation.etats = test_sim(simulation.model,params.rep_simul,params.liste_fichier,simulation.etats);

barre_avancement(sum(simulation.etats~=0))

if test && any(simulation.etats==-1)

    warndlg('Echec d''une des simulations !');
    test = false;   
    if simulation.etats(1)==-1
        % erreur de la 1ere simulation !
        barre_avancement('STOP')
        stop(obj);
    else
        test = false;
    end
end

if ~any(simulation.etats==0)
    stop(obj);
end   

% persistent perso
% if isempty(perso), perso=true; end
% perso = perso+1;
% disp(perso)
% if perso>=5
%     pause off
%     stop(obj);
%     pause on
% end   

end