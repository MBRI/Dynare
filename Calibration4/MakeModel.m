%function [Sm]=MakeModel()
global Fitted
Max_Degree=20;
% Load & Store name of parameters
load '.temp/Dynares.mat'
names=cellstr(M_.param_names);
xnames=cellstr(M_.exo_names);
StartingPoint=M_.params.';
xStartingPoint= M_.Sigma_e;% it must be revised
clear M_
load('.temp\init.mat');
%% Make Collections
S_P=[]; % Collection of Simulated Parametes
S_G=[];% Collection of Simulated Goal outcomes

Flds=cellstr(ls('.temp\Itr*.mat'));

n_O=length(Flds); % number of simulated observations

if n_O<5
    clear
    clc
    close all
    error('No sufficient solutions found in the specified range');
end
h = waitbar(0/n_O,'Collect Data...');
%
load('.temp\input.mat');
F1=fieldnames(Calib);
addpath('structcmp');
S_G0=struct2vec(Calib,F1); %Taget Values
S_W=struct2vec(Weight,F1);
S_G=[];
S_P=[];
S_ex=[];
% Gather data
for i=1:n_O
    load(['.temp\' Flds{i}]);
    S_P=[S_P,reshape(Itr.P,[],1)];
    S_ex=[S_ex,reshape(Itr.ex,[],1)];% it must be revised
    S_G=[S_G,struct2vec(Itr.oo_,F1)];
    waitbar(i/n_O)
    %Itr.oo_.var;
    %Itr.oo_.autocorr{1};
    %Itr.oo_.steady_state;
    %Itr.oo_.mean;
    %Itr.P
end
close (h)
clear Itr i Flds
rmpath('structcmp');
% refine S_G to be deviation from clib
S_W(~isfinite(S_G0(:,1)),:)=[];
S_G(~isfinite(S_G0(:,1)),:)=[];
S_G0(~isfinite(S_G0(:,1)),:)=[];
S_G(~isfinite(S_W(:,1)),:)=[];
S_W(~isfinite(S_W(:,1)),:)=[];
S_G(S_W(:,1)==0,:)=[];
S_G0(S_W(:,1)==0,:)=[];
S_W(S_W(:,1)==0,:)=[];
%Defrence frome Calibrated variance
%S_G=S_G-diag(S_G(:,1))*ones(size(S_G));
% Remove the calibrated variance
%S_G(:,1)=[];
%
n_G=size(S_G,1); % Number of Goals
No_variance=0;

%% remove unchanged parameter
ii=var(S_P,0,2)./mean(S_P,2)<0.00000000000000005;
names(ii,:)=[];
S_P(ii,:)=[];
StartingPoint(:,ii)=[];
n_P=length(names); % Number of parameters

%% remove unchanged exo var
ii=var(S_ex,0,2)./mean(S_ex,2)<0.00000000000000005;
xnames(ii,:)=[];
S_ex(ii,:)=[];
xStartingPoint(:,ii)=[];
n_x=length(xnames); % Number of exo var

%% fit on polynominal
addpath('PolyfitnTools');
for d=Max_Degree:-1:1 % find the biggest degree of polynominal to fit
    n= size(buildcompletemodel(d,n_P+n_x),1);% number of estimation parameters
    if n_O-n>300 % Check degree of freedom
        break;
    end
end
%
Fitted=struct();
sym Sm;
h = waitbar(0/n_G,'Fit Data...');
% fit for each goal
for i=1:n_G
    waitbar(i/n_G)
    % check variance of data
    if var(S_G(i,:))>0.0000005
        P=polyfitn([S_P.',S_ex.'],S_G(i,:),d);
        P.VarNames=[names.',xnames.'];
        Fitted.(['G' num2str(i)])=P;
        %  sumbolic
        Sm(i,1)=polyn2sym(P);
    else
        No_variance=No_variance+1;
        warning(['No variance found in ' num2str(No_variance) 'of ' num2str(n_G) ' Target(s)']);
        Fitted.(['G' num2str(i)])=0;
        % sumbolic
        Sm(i,1)=0;
    end
    
end

rmpath('PolyfitnTools');
save ('.temp/Fitted.mat', 'Fitted')
close (h)
%%
if No_variance==n_G
    error('No Valid Variance')
end
% Find sumbolic minimum
f=(Sm-S_G0).'*diag(S_W)*(Sm-S_G0);
% try %#ok<TRYNC> % may f is not convertable
% if double(f)==0
%    error('No Variance in data');
% end
% end
x=symvar(Sm);%Find Symbolic Var names


options = optimoptions('fminunc','Display','final','Algorithm','quasi-newton', 'OptimalityTolerance',10^-20,'MaxFunctionEvaluations',1000);
fh2 = matlabFunction(f,'vars',{x});
%fh2 = objective with no gradient or Hessian
[xfinal,fval,exitflag,output2] = fminunc(fh2,[StartingPoint,xStartingPoint],options);
%}
% options = optimoptions(@fmincon,'Algorithm','interior-point');
% 
% problem = createOptimProblem('fmincon','objective',...
%     fh2,'x0',StartingPoint,'lb',init.Min_Par_Calib,'ub',init.Max_Par_Calib,'options',options); %
% gs = GlobalSearch;
% disp('Solving started');
% [xfinal, XfX] = run(gs,problem);
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
Res.Parameter=repmat({''},n_P+n_x,1);
Res.Value=zeros(n_P+n_x,1);
for i=1:n_P+n_x
    Res.Parameter{i}=char(x(i));
    Res.Value(i)=xfinal(i);
end


Res

Fitted.G1.AdjustedR2
Fitted.G1.R2

for i=1:n_G
    Fitted.(['G' num2str(i)]).OptimalValue=double(subs(Sm(i,1),Res.Parameter,Res.Value ));
end
S_G_Predicted=nan(size(S_G));
for i=1:n_G
    nf=size(Fitted.(['G' num2str(i)]).ModelTerms,1);
    np=size(S_P,2);
    A1=sum(kron([S_P.',S_ex.'],ones(nf,1)).^kron(ones(np,1),Fitted.(['G' num2str(i)]).ModelTerms),2);
    S_G_Predicted(i,:)=Fitted.(['G' num2str(i)]).Coefficients*reshape(A1,nf,[]);
    figure();
    plot(S_G_Predicted(i,:),'*')
    hold on
     plot(S_G(i,:),'o')
    hold off
end
%%
%if exist('sympoly') == 2
%  polyn2sympoly(P)
%end
%if exist('sym') == 2
%polyn2sym(P)
%end

