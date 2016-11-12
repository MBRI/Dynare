function sss( )
%find the stady state of  a dynare file
%   juste use instead of dynare "steady;" command.
global M_ oo_;
global  params x;
%   modfile=M_.fname;
params=M_.params(:).'; 
x=zeros(size(M_.exo_names,1),1);
x=x(:).';
%y0=ones(size(M_.endo_names,1),1);
y0=oo_.steady_state(:).';
y0=y0(:).';
%r=f(y0);
options = optimoptions('fsolve','Display','none','Algorithm','levenberg-marquardt','SpecifyObjectiveGradient',true);% 'trust-region-dogleg' (default), 'trust-region-reflective', and 'levenberg-marquardt'.
% ,'PlotFcn',@optimplotfirstorderopt
% ,'UseParallel',false
[y,fval,exitflag] =fsolve(@f,y0,options);
oo_.steady_state=y(:);

end
function [F,J,H]=f(y)
global M_ params x;
%r=sin(y)-cos(y);
eval(['[F,J,H]=' M_.fname '_static([' num2str(y) '],[' num2str(x) '],['  num2str(params) ']);']);
%r=r.^2;
end
