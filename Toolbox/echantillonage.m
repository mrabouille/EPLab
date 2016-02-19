classdef echantillonage < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        type_ech
        type_plan
        nb_tir
        variables_infos
        vars_index %actives
        seed=0
    end
    
    methods 
        function obj = echantillonage(params)
        
            obj.type_ech = params.type_ech;
            obj.type_plan = params.type_plan;
            obj.nb_tir = params.nb_tir;
            obj.variables_infos = params.variables.infos;
            
            nb_vars_active = length(params.variables.infos(params.variables.vars_index)); % Nombre de variables
            
            
        end
        
        function plan = create_plan()
            %RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
            rng shuffle
            
            plan=zeros(N,nb_vars_active);
            
           switch
               case 1
                   
                   A=zeros(N,k); %indexes aléatoires
                   test_old=0;
                   
                   % Réation de l'index meilleur plan maximin parmis 10
                   for l=1:10
                       for i=1:k
                           A(:,i)=randperm(N);
                       end
                       test=minimax(A);
                       if test>test_old
                           index=A;
                       end
                       test_old=test;
                   end
              
               otherwise
                       error('Méthode de génération du plan de simulation non reconnue.')
           end
            
        end
    end
end

