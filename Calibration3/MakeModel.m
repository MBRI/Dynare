%function [Sm]=MakeModel()
% Load & Store name of parameters
load('.temp\M_.mat');
names=cellstr(M_.param_names);
StartingPoint=M_.params.';
clear M_
load('.temp\init.mat');
%% Make Collections
S_P=[]; % Collection of Simulated Parametes
S_G=[];% Collection of Simulated Goal outcomes

Flds=cellstr(ls('.temp\Itr*.mat'));
n_P=length(names); % Number of parameters
n_O=length(Flds); % number of simulated observations

if n_O<5
    clear
    clc
    close all
   error('No sufficient solutions found in the specified range'); 
end
h = waitbar(0/n_O,'Collect Data...');
% Gather data
for i=1:n_O
    load(['.temp\' Flds{i}]);
    S_P=[S_P;reshape(Itr.P,1,[])];
    S_G=[S_G;
        reshape(Itr.oo_.var,1,[])];
    waitbar(i/n_O)
    %Itr.oo_.var;
    %Itr.oo_.autocorr{1};
    %Itr.oo_.steady_state;
    %Itr.oo_.mean;
    %Itr.P
end
clear Itr i Flds
n_G=size(S_G,2); % Number of Goals
%% fit on polynominal
addpath('PolyfitnTools');
for d=15:-1:1 % find the biggest degree of polynominal to fit
    n= size(buildcompletemodel(d,n_P),1);% number of estimation parameters
    if n_O-n>30 % Check degree of freedom
        break;
    end
end
close (h)
Fitted=struct();
sym Sm;
h = waitbar(0/n_G,'Fit Data...');
% fit for each goal
for i=1:n_G
    waitbar(i/n_G)
    P=polyfitn(S_P,S_G(:,i),d);
    P.VarNames=names.';
    Fitted.(['G' num2str(i)])=P;
    % Find sumbolic minimum
    Sm(i,1)=polyn2sym(P);
end
save ('.temp/Fitted.mat', 'Fitted')
close (h)
%%
% Find sumbolic minimum
f=Sm.'*eye(n_G)*Sm;
x=symvar(Sm);%Find Symbolic Var names


options = optimoptions('fminunc','Display','final','Algorithm','quasi-newton', 'OptimalityTolerance',10^-20,'MaxFunctionEvaluations',1000);
fh2 = matlabFunction(f,'vars',{x});
% fh2 = objective with no gradient or Hessian
%[xfinal,fval,exitflag,output2] = fminunc(fh2,StartingPoint,options);
%}
options = optimoptions(@fmincon,'Algorithm','interior-point');

problem = createOptimProblem('fmincon','objective',...
 fh2,'x0',StartingPoint,'lb',init.Min_Par_Calib,'ub',init.Max_Par_Calib,'options',options); %   
gs = GlobalSearch;
disp('Solving started');
xfinal = run(gs,problem);
%{
gradf = jacobian(f,x).'; % column gradf
%V=solve(gradf);% 
hessf = jacobian(gradf,x);
fh = matlabFunction(f,gradf,hessf,'vars',{x});
options = optimoptions('fminunc', 'OptimalityTolerance',10^-20, 'MaxFunctionEvaluations',10^15,'StepTolerance', 10^-20,...
    'SpecifyObjectiveGradient', true, ...
    'HessianFcn', 'objective', ...
    'Algorithm','trust-region', ...
    'Display','final');
[xfinal,fval,exitflag,output] = fminunc(fh,StartinPoint,options);
%}

% reshape results
Res=dataset();
Res.Parameter=repmat({''},n_P,1);
Res.Value=zeros(n_P,1);
for i=1:n_P
    Res.Parameter{i}=char(x(i));
    Res.Value(i)=xfinal(i);
end
Res

%%
%if exist('sympoly') == 2
%  polyn2sympoly(P)
%end
%if exist('sym') == 2
%polyn2sym(P)
%end

rmpath('PolyfitnTools');