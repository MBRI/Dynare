%
% Status : main Dynare file 
%
% Warning : this file is generated automatically by Dynare
%           from model file (.mod)

clear all
tic;
global M_ oo_ options_ ys0_ ex0_ estimation_info
options_ = [];
M_.fname = 'example1';
%
% Some global variables initialization
%
global_initialization;
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
 1 3;
 2 4;]';
M_.nstatic = 0;
M_.nfwrd   = 0;
M_.npred   = 2;
M_.nboth   = 0;
M_.nsfwrd   = 0;
M_.nspred   = 2;
M_.ndynamic   = 2;
M_.equations_tags = {
};
M_.static_and_dynamic_models_differ = 0;
M_.exo_names_orig_ord = [1:1];
M_.maximum_lag = 1;
M_.maximum_lead = 0;
M_.maximum_endo_lag = 1;
M_.maximum_endo_lead = 0;
oo_.steady_state = zeros(2, 1);
M_.maximum_exo_lag = 0;
M_.maximum_exo_lead = 0;
oo_.exo_steady_state = zeros(1, 1);
M_.params = NaN(4, 1);
M_.NNZDerivatives = zeros(3, 1);
M_.NNZDerivatives(1) = 6;
M_.NNZDerivatives(2) = 0;
M_.NNZDerivatives(3) = -1;
options_.noprint=0;
M_.params( 1 ) = 0.36;
a = M_.params( 1 );
M_.params( 2 ) = 0.95;
b = M_.params( 2 );
M_.params( 3 ) = 0.025;
c = M_.params( 3 );
M_.params( 4 ) = 0.99;
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
