function [OptMatrix, OptOutVec] = Morris_Optimized_Groups(NumFact,N,p,r,GroupMat,Diagnostic)
%
% [OptMatrix, OptOutVec] = Optimized_Groups(NumFact,N,p,r,GroupMat,Diagnostic)
%
% Optimization in the choice of trajectories for the Morris experiment
% clear all

% Inputs
% N:= [1,1]         Total number of trajectories
% p:= [1,1]         Number of levels
% r:= [1,1]         Final number of optimal trjectories
% NumFact:= [1,1]   Number of factors
% LB:= [NumFact,1]  Lower bound of the uniform distribution for each factor
% UB:= [NumFact,1]  Upper bound of the uniform distribution for each factor
% GroupMat:=[NumFact,NumGroups] Matrix describing the groups. Each column represents a group and its elements 
%                               are set to 1 in correspondence of the factors that belong to the fixed group. All
%                               the other elements are zero.
% Diagnostic:= [1,1]            Boolean 1=plot the histograms and compute the
%                               efficiency of the samplign or not, 0
%                               otherwise

if nargin<2 || isempty(N)
  N=100;
end
if nargin<3 || isempty(p)
  p = 4;        % Number of levels
end
if nargin<4 || isempty(r)
  r = 8;        % Number of replicas
end
%GroupMat = [1 0; 1 0; 1 0; 0 1; 0 1; 1 0];
if nargin<1
  disp('[OutMatrix, OutFact] = Optimized_Groups(NumFact,N,p,r,GroupMat,Diagnostic)')
  return
end
if nargin<5
  GroupMat = [];
end
if nargin<6||isempty(Diagnostic)
  Diagnostic = 0;
end

LB = zeros(NumFact,1);
UB = ones(NumFact,1);

%[OutMatrix, OutFact] = Sampling_Function(p, NumFact, N, UB, LB);        % Version without Groups
[OutMatrix, OutFact] = Sampling_Function_2(p, NumFact, N, UB, LB, GroupMat);   % Version with Groups

GroupNumber = size(GroupMat,2);
if GroupNumber ~= 0
    sizeb = GroupNumber + 1;
else
    sizeb = NumFact + 1;
end    

Dist = zeros(N,N);
Diff_Traj = [1:1:N];
% Compute the distance between all pair of trajectories (sum of the distances between points)
% The distance matrix is a matrix N*N
% The distance is defined as the sum of the distances between all pairs of points
% if the two trajectories differ, 0 otherwise
for j =1:N
    for z = j+1:N
    
        MyDist = zeros(sizeb, sizeb);
        for i = 1:sizeb
            for k = 1:sizeb  
                MyDist(i,k) = (sum((OutMatrix((j-1)*(sizeb) + i,:) - OutMatrix((z-1)*(sizeb) + k,:)).^2))^0.5;
            end
        end
        
        if size(find(MyDist==0),1) == sizeb
            % Same trajectory. If the number of zeros in Dist matrix is equal to 
            % (NumFact+1) then the trajectory is a replica. In fact (NumFact+1) is the maximum numebr of 
            % points that two trajectories can have in common
            Dist(j,z) = 0;     
            Dist(z,j) = 0;  
            
            % Memorise the replicated trajectory
            Diff_Traj(1,z) = 0; 
        else
            % Define the distance between two trajectories as 
            % the minimum distance among their points
            Dist(j,z) = sum(sum(MyDist));     
            Dist(z,j) = sum(sum(MyDist));
        end        
    end
end

New_OutMatrix = [];
New_OutFact = [];
% Eliminate replicated trajectories in the sampled matrix
for i = 1:N
    if Diff_Traj(1,i)~=0
        New_OutMatrix = [New_OutMatrix; OutMatrix((i-1)*(sizeb) + 1: (i-1)*(sizeb) + sizeb,:)]; 
        New_OutFact = [New_OutFact; OutFact((i-1)*(sizeb) + 1: (i-1)*(sizeb) + sizeb,:)];
    end
end

% Select in the distance matrix only the rows and columns of different trajectories
Dist_Diff = Dist(find(Diff_Traj),find(Diff_Traj));
New_N = size(find(Diff_Traj), 2);

% Select the optimal set of trajectories
Traj_Vec = zeros(New_N, r);
OptDist = zeros(New_N, r);
for m = 1:New_N 
    
    Traj_Vec(m, 1) = m;

    for z = 2:r
        Max_New_Dist_Diff = 0; 
    
        for j = 1:New_N   
        
            % Check that trajectory j is not already in
            Is_done = 0;
            for h = 1:z
                if j == Traj_Vec(m,h) 
                    Is_done = 1;
                end
            end
        
            if Is_done==0
                New_Dist_Diff = 0;    
            
                % Compute the distance 
                for k = 1:z-1           
                    New_Dist_Diff = New_Dist_Diff + (Dist_Diff(Traj_Vec(m, k),j))^2;  
                end
        
                % Check if the distance is greater than the old one
                if New_Dist_Diff^0.5 > Max_New_Dist_Diff
                    Max_New_Dist_Diff = New_Dist_Diff^0.5;
                    Pippo = j;
                end
            end
        end
    
        % Set the new trajectory
        Traj_Vec(m,z) = Pippo;
        OptDist(m,z) = Max_New_Dist_Diff;
    end
end

% Construct optimal matrix
SumOptDist = sum(OptDist,2);
% Find the maximum distance
Pluto = find(SumOptDist == max(SumOptDist));
Opt_Traj_Vec = Traj_Vec(Pluto(1,1),:);

OptMatrix = [];
OptOutVec = [];  %
for k =1:r
    OptMatrix = [OptMatrix; New_OutMatrix((sizeb)*(Opt_Traj_Vec(1,k)-1) + 1:(sizeb)*(Opt_Traj_Vec(1,k)-1) + sizeb,:)];
    OptOutVec = [OptOutVec; New_OutFact((sizeb)*(Opt_Traj_Vec(1,k)-1) + 1:(sizeb)*(Opt_Traj_Vec(1,k)-1)+ sizeb,:)];
end

if Diagnostic == 1
    % Clean the trajectories from repetitions and plot the histograms
    HistPlot = zeros(2*r,NumFact);
    for i = 1:NumFact
        for j = 1:r
            kk = 1;
        
            % select the first value of the factor
            HistPlot((j-1)*2+kk,i) = OptMatrix((j-1)*(sizeb)+1,i);
            
            % search the second value 
            for ii = 2:sizeb
                if OptMatrix((j-1)*(sizeb)+ii ,i) ~= OptMatrix((j-1)*(sizeb)+1,i)
                    kk = 2;        
                    HistPlot((j-1)*2+kk,i) = OptMatrix((j-1)*(sizeb)+ii ,i);
                end
            end    
        end
    end

	figure('name', 'New Strategy')
	hold on;
	DimPlots = round(NumFact/2);
	for i = 1:NumFact
        subplot(DimPlots,2,i);
        hist(HistPlot(:,i),p);
	end
        
	
	% Plot the histogram for the original samplng strategy
	% Select the matrix
	OrigSample = OutMatrix(1:r*(sizeb),:);
	OriHistPlot = zeros(2*r,NumFact);
	for i = 1:NumFact
        for j = 1:r
            kk = 1;
            
            % select the first value of the factor
            OriHistPlot((j-1)*2+kk,i) = OrigSample((j-1)*(sizeb)+1,i);
                
            % search the second value 
            for ii = 2:sizeb
                if OrigSample((j-1)*(sizeb)+ii ,i) ~= OrigSample((j-1)*(sizeb)+1,i)
                    kk = 2;        
                    OriHistPlot((j-1)*2+kk,i) = OrigSample((j-1)*(sizeb)+ii ,i);
                end
            end    
        end
	end
	
	figure('name', 'Old Strategy')
	hold on;
	for i = 1:NumFact
        subplot(DimPlots,2,i);
        hist(OriHistPlot(:,i),p);
	end
	
	% Measure the quality of the sampling strategy
	Levels = [0:(1/(p-1)):1];
	for i = 1:NumFact
        for j = 1:p
            % For each facrot and each level count the number of times the factor is on the level
            % This for the new and original sampling
            NumSPoint(i,j) = size(find(abs(HistPlot(:,i)-repmat(Levels(1,j), size(HistPlot,1),1))<1e-5),1);
            NumSOrigPoint(i,j) = size(find(abs(OriHistPlot(:,i)-repmat(Levels(1,j), size(OriHistPlot,1),1))<1e-5),1);
        end
	end
	
	% The optimal sampling has values uniformly distributed across the levels
	OptSampl = 2*r/p;
	QualMeasure = 0;
	QualOriMeasure = 0;
	for i = 1: NumFact
        for j = 1:p
            QualMeasure = QualMeasure + abs(NumSPoint(i,j)-OptSampl);
            QualOriMeasure = QualOriMeasure + abs(NumSOrigPoint(i,j)-OptSampl);
        end
	end
	
	QualMeasure = 1 - QualMeasure/(OptSampl*p*NumFact)
	QualOriMeasure = 1 - QualOriMeasure/(OptSampl*p*NumFact)
end	
	
	
	
function [Outmatrix, OutFact] = Sampling_Function_2(p, k, r, UB, LB, GroupMat)
%[Outmatrix, OutFact] = Sampling_Function_2(p, k, r, UB, LB, GroupMat)
%	Inputs: k (1,1)                      := number of factors examined or number of groups examined.
%                                           In case the groups are chosen the number of factors is stores in NumFact and
%                                           sizea becomes the number of created groups. 
%           NumFact (1,1)                := number of factors examined in the case when groups are chosen
%	    	r (1,1)                      := sample size  
%           p (1,1)                      := number of intervals considered in [0, 1]
%           UB(sizea,1)                  := Upper Bound for each factor 
%           LB(sizea,1)                  := Lower Bound for each factor 
%           GroupNumber(1,1)             := Number of groups (eventually 0)
%           GroupMat(NumFact,GroupNumber):= Matrix which describes the chosen groups. Each column represents a group and its elements 
%                                           are set to 1 in correspondence of the factors that belong to the fixed group. All
%                                           the other elements are zero.
%   Local Variables:  
%	    	sizeb (1,1)         := sizea+1
%           sizec (1,1)         := 1
%           randmult (sizea,1)  := vector of random +1 and -1  
%           perm_e(1,sizea)     := vector of sizea random permutated indeces    
%           fact(sizea)         := vector containing the factor varied within each traj
% 	        DDo(sizea,sizea)    := D*       in Morris, 1991   
%	        A(sizeb,sizea)      := Jk+1,k   in Morris, 1991
%	        B(sizeb,sizea)      := B        in Morris, 1991
%	        Po(sizea,sizea)     := P*       in Morris, 1991
%           Bo(sizeb,sizea)     := B*       in Morris, 1991
%	        Ao(sizeb,sizec)     := Jk+1,1   in Morris, 1991
%	        xo(sizec,sizea)     := x*       in Morris, 1991 (starting point for the trajectory)
%           In(sizeb,sizea)     := for each loop orientation matrix. It corresponds to a trajectory
%                                  of k step in the parameter space and it provides a single elementary
%                                  effect per factor 
%           MyInt()
%           Fact(sizea,1)       := for each loop vector indicating which factor or group of factors has been changed 
%                                  in each step of the trajectory
%           AuxMat(sizeb,sizea) := Delta*0.5*((2*B - A) * DD0 + A) in Morris, 1991. The AuxMat is used as in Morris design
%                                  for single factor analysis, while it constitutes an intermediate step for the group analysis.
%
%	Output: Outmatrix(sizeb*r, sizea) := for the entire sample size computed In(i,j) matrices
%           OutFact(sizea*r,1)        := for the entire sample size computed Fact(i,1) vectors
%           
%   Note: B0 is constructed as in Morris design when groups are not considered. When groups are considered the routine
%         follows the following steps:
%           1- Creation of P0 and DD0 matrices defined in Morris for the groups. This means that the dimensions of these
%              2 matrices are (GroupNumber,GroupNumber).
%           2- Creation of AuxMat matrix with (GroupNumber+1,GroupNumber) elements.
%           3- Definition of GroupB0 starting from AuxMat, GroupMat and P0.
%           4- The final B0 for groups is obtained as [ones(sizeb,1)*x0' + GroupB0]. The P0 permutation is present in GroupB0
%              and it's not necessary to permute the matrix (ones(sizeb,1)*x0') because it's already randomly created. 
%   Reference:
%   A. Saltelli, K. Chan, E.M. Scott, "Sensitivity Analysis" on page 68 ss
%
%   F. Campolongo, J. Cariboni, JRC - IPSC Ispra, Varese, IT
%   Last Update: 15 November 2005 by J.Cariboni
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Parameters and initialisation of the output matrix
sizea = k;
Delta = p/(2*p-2);
%Delta = 1/3
NumFact = sizea;
GroupNumber = size(GroupMat,2);

if GroupNumber ~ 0;
    sizea = size(GroupMat,2);
end    

sizeb = sizea + 1;
sizec = 1;
Outmatrix = [];
OutFact = [];

% For each i generate a trajectory  
for i=1:r
    
    % Construct DD0 - OLD VERSION - it does not need communication toolbox
    % RAND(N,M) is an NXM matrix with random entries, chosen from a uniform distribution on the interval (0.0,1.0).
    % Note that DD0 tells if the factor have to be increased or ddecreased
    % by Delta.
    randmult = ones(k,1);           
    v = rand(k,1);                  
    randmult (find(v < 0.5))=-1;
    randmult = repmat(randmult,1,k);
    DD0 = randmult .* eye(k);
    
    % Construct DD0 - NEW VERSION - it needs communication toolbox
    % randsrc(m) generates an m-by-m matrix, each of whose entries independently takes the value -1 with probability 1/2,
    % and 1 with probability 1/2.
    % DD0 = randsrc(NumFact) .* eye(NumFact);      
    
    % Construct B (lower triangular)
    B = ones(sizeb,sizea);
    for j = 1:sizea
       B(1:j,j)=0;    
    end
    
    % Construct A0, A
    A0 = ones(sizeb,1);
    A = ones(sizeb,NumFact);

    % Construct the permutation matrix P0. In each column of P0 one randomly chosen element equals 1
    % while all the others equal zero. 
    % P0 tells the order in which order factors are changed in each
    % trajectory. P0 is created as it follows:
    % 1) All the elements of P0 are set equal to zero ==> P0 = zeros (sizea, sizea);
    % 2) The function randperm create a random permutation of integer 1:sizea, without repetitions ==> perm_e; 
    % 3) In each column of P0 the element indicated in perm_e is set equal to one.    
    % Note that P0 is then used reading it by rows. 
    P0 = zeros (sizea, sizea);
    perm_e = randperm(sizea);               % RANDPERM(n) is a random permutation of the integers from 1 to n.
    for j = 1:sizea
        P0(perm_e(j),j) = 1;    
    end    
    
    % When groups are present the random permutation is done only on B. The effect is the same since 
    % the added part (A0*x0') is completely random. 
    if GroupNumber ~= 0
        B = B * (GroupMat*P0')';
    end
    
    % Compute AuxMat both for single factors and groups analysis. For Single factors analysis
    % AuxMat is added to (A0*X0) and then permutated through P0. When groups are active AuxMat is
    % used to build GroupB0. AuxMat is created considering DD0. If the element on DD0 diagonal
    % is 1 then AuxMat will start with zero and add Delta. If the element on DD0 diagonal is -1 
    % then DD0 will start Delta and goes to zero.
    AuxMat = Delta*0.5*((2*B - A) * DD0 + A);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % a --> Define the random vector x0 for the factors. Note that x0 takes value in the hypercube
    % [0,...,1-Delta]*[0,...,1-Delta]*[0,...,1-Delta]*[0,...,1-Delta] 
    MyInt = repmat([0:(1/(p-1)):(1-Delta)],NumFact,1);     % Construct all possible values of the factors
    
    % OLD VERSION - it needs communication toolbox
    % w = randint(NumFact,1,[1,size(MyInt,2)]);              
    
    % NEW VERSION - construct a version of random integers
    % 1) create a vector of random integers
    % 2) divide [0,1] into the needed steps
    % 3) check in which interval the random numbers fall
    % 4) generate the corresponding integer
    v = repmat(rand(NumFact,1),1,size(MyInt,2)+1);     % 1)
    IntUsed = repmat([0:1/size(MyInt,2):1],NumFact,1); % 2)
    DiffAuxVec = IntUsed - v;                          % 3)
    
    for ii = 1:size(DiffAuxVec,1)
        w(1,ii) = max(find(DiffAuxVec(ii,:)<0));       % 4)
    end
    x0 = MyInt(1,w)';                                  % Define x0    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    % b --> Compute the matrix B*, here indicated as B0. Each row in B0 is a
    % trajectory for Morris Calculations. The dimension of B0 is (Numfactors+1,Numfactors) 
    if GroupNumber ~= 0
        B0 = (A0*x0' + AuxMat);
    else
        B0 = (A0*x0' + AuxMat)*P0;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    % c --> Compute values in the original intervals
    % B0 has values x(i,j) in [0, 1/(p -1), 2/(p -1), ... , 1].
    % To obtain values in the original intervals [LB, UB] we compute
    % LB(j) + x(i,j)*(UB(j)-LB(j))
    In = repmat(LB,1,sizeb)' + B0 .* repmat((UB-LB),1,sizeb)';

    % Create the Factor vector. Each component of this vector indicate which factor or group of factor
    % has been changed in each step of the trajectory.
    for j=1:sizea
        Fact(1,j) = find(P0(j,:));
    end
    Fact(1,sizea+1) = 0;
    
    Outmatrix = [Outmatrix; In];
    OutFact = [OutFact; Fact'];
    
end
            
            
            
        