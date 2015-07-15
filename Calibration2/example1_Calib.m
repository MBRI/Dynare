function example1_Calib()
global oo_
load '.temp/init.mat';
load '.temp/input.mat';
Min_Par_Calib=init.Min_Par_Calib;
Step_Par_Calib=init.Step_Par_Calib;
Max_Par_Calib=init.Max_Par_Calib;

clear init FileName Par_Calib;
Total_itration=ceil((Max_Par_Calib-Min_Par_Calib)./Step_Par_Calib);
Total_itration= 1*sum(Total_itration);

if exist('.temp/LVal.mat','file')
load '.temp/LVal.mat';
Min_Par_Calib=Par_Calib;
end
h = waitbar(itr/Total_itration,'Please wait...');

Par_1=Min_Par_Calib(1);
Par_2=Min_Par_Calib(2);
Par_3=Min_Par_Calib(3);
Par_4=Min_Par_Calib(4);
Par_Calib_Old=[Par_1;Par_2;Par_3;Par_4;];

% Great itration
for g=1:1
% single loop
itrS=itr+1;
for Par_1=Min_Par_Calib(1): Step_Par_Calib(1): Max_Par_Calib(1)
Par_Calib=[Par_1;Par_2;Par_3;Par_4;];
itr=itr+1;
save '.temp/LVal' Par_Calib itr itrS;
waitbar(itr / Total_itration)
try
example1_Cal(Par_Calib);
Itr.V=oo_.var;
Itr.A=oo_.autocorr{1};
Itr.S=oo_.steady_state;
Itr.M=oo_.mean;
Itr.P=Par_Calib;
save (['.temp/Itr' num2str(itr) '.mat'], 'Itr')
 clear Itr
end
end
Par_1=ThirdBest(Calib,Weight,itrS,itr,1);
if isnan(Par_1)
Par_1=Par_Calib_Old(1);
else
Par_Calib_Old(1)= Par_1;
end
itrS=itr+1;
for Par_2=Min_Par_Calib(2): Step_Par_Calib(2): Max_Par_Calib(2)
Par_Calib=[Par_1;Par_2;Par_3;Par_4;];
itr=itr+1;
save '.temp/LVal' Par_Calib itr itrS;
waitbar(itr / Total_itration)
try
example1_Cal(Par_Calib);
Itr.V=oo_.var;
Itr.A=oo_.autocorr{1};
Itr.S=oo_.steady_state;
Itr.M=oo_.mean;
Itr.P=Par_Calib;
save (['.temp/Itr' num2str(itr) '.mat'], 'Itr')
 clear Itr
end
end
Par_2=ThirdBest(Calib,Weight,itrS,itr,2);
if isnan(Par_2)
Par_2=Par_Calib_Old(2);
else
Par_Calib_Old(2)= Par_2;
end
itrS=itr+1;
for Par_3=Min_Par_Calib(3): Step_Par_Calib(3): Max_Par_Calib(3)
Par_Calib=[Par_1;Par_2;Par_3;Par_4;];
itr=itr+1;
save '.temp/LVal' Par_Calib itr itrS;
waitbar(itr / Total_itration)
try
example1_Cal(Par_Calib);
Itr.V=oo_.var;
Itr.A=oo_.autocorr{1};
Itr.S=oo_.steady_state;
Itr.M=oo_.mean;
Itr.P=Par_Calib;
save (['.temp/Itr' num2str(itr) '.mat'], 'Itr')
 clear Itr
end
end
Par_3=ThirdBest(Calib,Weight,itrS,itr,3);
if isnan(Par_3)
Par_3=Par_Calib_Old(3);
else
Par_Calib_Old(3)= Par_3;
end
itrS=itr+1;
for Par_4=Min_Par_Calib(4): Step_Par_Calib(4): Max_Par_Calib(4)
Par_Calib=[Par_1;Par_2;Par_3;Par_4;];
itr=itr+1;
save '.temp/LVal' Par_Calib itr itrS;
waitbar(itr / Total_itration)
try
example1_Cal(Par_Calib);
Itr.V=oo_.var;
Itr.A=oo_.autocorr{1};
Itr.S=oo_.steady_state;
Itr.M=oo_.mean;
Itr.P=Par_Calib;
save (['.temp/Itr' num2str(itr) '.mat'], 'Itr')
 clear Itr
end
end
Par_4=ThirdBest(Calib,Weight,itrS,itr,4);
if isnan(Par_4)
Par_4=Par_Calib_Old(4);
else
Par_Calib_Old(4)= Par_4;
end
end
close (h)
end
function example1_Cal(Par_Calib)
 
 %
% Status : main Dynare file 
%
% Warning : this file is generated automatically by Dynare
%           from model file (.mod)


tic;
global M_ oo_ options_ ys0_ ex0_ estimation_info
options_ = [];
M_.fname = 'example1';
%
% Some global variables initialization
%
global_initialization;
options_.nolog=1;
options_.noprint=1;
options_.nograph=1;
options_.graph_format='none';
diary off;
diary('example1.log');
M_.exo_names = 'e_x';
M_.exo_names_tex = 'e\_x';
M_.exo_names_long = 'e_x';
M_.endo_names = 'y';
M_.endo_names_tex = 'y';
M_.endo_names_long = 'y';
M_.endo_names = char(M_.endo_names, 'x');
M_.endo_names_tex = char(M_.endo_names_tex, 'x');
M_.endo_names_long = char(M_.endo_names_long, 'x');
M_.param_names = 'a';
M_.param_names_tex = 'a';
M_.param_names_long = 'a';
M_.param_names = char(M_.param_names, 'b');
M_.param_names_tex = char(M_.param_names_tex, 'b');
M_.param_names_long = char(M_.param_names_long, 'b');
M_.param_names = char(M_.param_names, 'c');
M_.param_names_tex = char(M_.param_names_tex, 'c');
M_.param_names_long = char(M_.param_names_long, 'c');
M_.param_names = char(M_.param_names, 'd');
M_.param_names_tex = char(M_.param_names_tex, 'd');
M_.param_names_long = char(M_.param_names_long, 'd');
M_.exo_det_nbr = 0;
M_.exo_nbr = 1;
M_.endo_nbr = 2;
M_.param_nbr = 4;
M_.orig_endo_nbr = 2;
M_.aux_vars = [];
M_.Sigma_e = zeros(1, 1);
M_.Correlation_matrix = eye(1, 1);
M_.H = 0;
M_.Correlation_matrix_ME = 1;
M_.sigma_e_is_diagonal = 1;
options_.linear = 1;
options_.block=0;
options_.bytecode=0;
options_.use_dll=0;
erase_compiled_function('example1_static');
erase_compiled_function('example1_dynamic');
M_.lead_lag_incidence = [
 1 3 0;
 2 4 5;]';
M_.nstatic = 0;
M_.nfwrd   = 0;
M_.npred   = 1;
M_.nboth   = 1;
M_.nsfwrd   = 1;
M_.nspred   = 2;
M_.ndynamic   = 2;
M_.equations_tags = {
};
M_.static_and_dynamic_models_differ = 0;
M_.exo_names_orig_ord = [1:1];
M_.maximum_lag = 1;
M_.maximum_lead = 1;
M_.maximum_endo_lag = 1;
M_.maximum_endo_lead = 1;
oo_.steady_state = zeros(2, 1);
M_.maximum_exo_lag = 0;
M_.maximum_exo_lead = 0;
oo_.exo_steady_state = zeros(1, 1);
M_.params = NaN(4, 1);
M_.NNZDerivatives = zeros(3, 1);
M_.NNZDerivatives(1) = 6;
M_.NNZDerivatives(2) = 0;
M_.NNZDerivatives(3) = -1;
% options_.noprint=0;
M_.params( 1 ) = Par_Calib(1);
a = M_.params( 1 );
M_.params( 2 ) = Par_Calib(2);
b = M_.params( 2 );
M_.params( 3 ) = Par_Calib(3);
c = M_.params( 3 );
M_.params( 4 ) = Par_Calib(4);
d = M_.params( 4 );
steady;
oo_.dr.eigval = check(M_,options_,oo_);
%
% SHOCKS instructions
%
make_ex_;
M_.exo_det_length = 0;
M_.Sigma_e(1, 1) = (0.009)^2;
options_.irf = 20;
var_list_=[];
info = stoch_simul(var_list_);
save('example1_results.mat', 'oo_', 'M_', 'options_');
if exist('estim_params_', 'var') == 1
  save('example1_results.mat', 'estim_params_', '-append');
end
if exist('bayestopt_', 'var') == 1
  save('example1_results.mat', 'bayestopt_', '-append');
end
if exist('dataset_', 'var') == 1
  save('example1_results.mat', 'dataset_', '-append');
end
if exist('estimation_info', 'var') == 1
  save('example1_results.mat', 'estimation_info', '-append');
end


disp(['Total computing time : ' dynsec2hms(toc) ]);
if ~isempty(lastwarn)
  disp('Note: warning(s) encountered in MATLAB/Octave code')
end
diary off
 
 end 
function Opt=ThirdBest(Calib,Weight,itrS,itr,VarId)
MaxSize=1000;
% Clibration Vaues
V0=[reshape(Calib.Var,[],1); ...
    reshape(Calib.ACorr,[],1); ...
    reshape(Calib.SS,[],1); ...
    reshape(Calib.Mean,[],1)];
% Weight Matrix
W0=[reshape(Weight.Var,[],1); ...
    reshape(Weight.ACorr,[],1); ...
    reshape(Weight.SS,[],1); ...
    reshape(Weight.Mean,[],1)];

% Load data files
%F=dir('.temp/Itr*.mat');
%F={F.name};
Res=struct();
% Number of fields
NF=itr-itrS+1;%
h=min(itrS+MaxSize,NF);
NF1=itrS;
while(1)
    V=V0;
    W=W0;
    for i=NF1:h
        try
        load(['.temp/Itr' num2str(i)]);
        
        Res.(['Itr' num2str(i)])=Itr;
        %Res.(['Itr' num2str(i)]).I=i; % Chain to .temp
        clear Itr;
        end
    end
    
    Fld=fields(Res);
   if ~isempty(Fld)
    for i=NF1:h
        V=[V,[reshape(Res.(['Itr' num2str(i)]).V,[],1); ...
            reshape(Res.(['Itr' num2str(i)]).A,[],1); ...
            reshape(Res.(['Itr' num2str(i)]).S,[],1); ...
            reshape(Res.(['Itr' num2str(i)]).M,[],1)]];
        %     end
    end
    W(isnan(V(:,1)),:)=[];
    V(isnan(V(:,1)),:)=[];
    V(isnan(W(:,1)),:)=[];
    W(isnan(W(:,1)),:)=[];
    
    V=V-diag(V(:,1))*ones(size(V));
    V(:,1)=[];
    V=V.'*diag(W)*V;
    V=diag(V);
    %if length(min(V))>1
    %    warning('More than one solution found.');
    %end
    %V(V~=min(V))=nan;
    %V(V==min(V))=1;
    
    Fld(V==min(V))=[];
    Res=rmfield(Res,Fld);
   end
    if h==NF
        break;
    else
        NF1=h+1;
    end
    h=MaxSize+NF;
    if h>NF
        h=NF;
    end
end
Fld=fields(Res);
if isempty(Fld)
    Opt=nan;
else
Opt=Res.(Fld{1}).P(VarId);
end

end
