function sss( )
%find the stady state of  a dynare file
%   juste use instead of dynare "steady;" command.
global M_ oo_;
global  params x;
%   modfile=M_.fname;
params=M_.params(:).'; 
if any(~isfinite(params))
   error('Some parameters not determioned'); 
end
x=zeros(size(M_.exo_names,1),1);
%y0=ones(size(M_.endo_names,1),1);
y0=real(oo_.steady_state);

%fminbnd(@f,-10*ones(size(y0)),10*ones(size(y0)))
    while( any(isnan(f(y0))))
       y0=-100+200*rand(1,length(y0));
   end
%{
   opts = optimoptions(@fmincon,'Algorithm','interior-point');
problem = createOptimProblem('fmincon','objective',...
 @(x) x.^2 + 4*sin(5*x),'x0',3,'lb',-5,'ub',5,'options',opts);
gs = GlobalSearch;
[x,f] = run(gs,problem)
   %}
%r=f(y0);
 options = optimoptions('fsolve','Display','final','Algorithm', 'trust-region-reflective','SpecifyObjectiveGradient',true,'MaxIterations',10^4,'StepTolerance',10^-30,'MaxFunctionEvaluations',10^10);% 'trust-region-dogleg' (default), 'trust-region-reflective', and 'levenberg-marquardt'.
% % ,'PlotFcn',@optimplotfirstorderopt
% % ,'UseParallel',false
% % FunctionTolerance %  MaxFunctionEvaluations % 
 [y,fval,exitflag] =fsolve(@f,y0,options);
if max(abs(fval))<10^-14
 oo_.steady_state=y(:);
 
else
%options = optimoptions('fminunc','Display','final','Algorithm','quasi-newton','SpecifyObjectiveGradient',true);%,'MaxIterations',10^4,'StepTolerance',10^-30,'MaxFunctionEvaluations',10^10);% 'trust-region-dogleg' (default), 'trust-region-reflective', and 'levenberg-marquardt'.
% ,'PlotFcn',@optimplotfirstorderopt
% ,'UseParallel',false
% FunctionTolerance %  MaxFunctionEvaluations % 
y0=real(y);
%[y,fval,exitflag] =fminunc(@f2,y0,options);
opts = optimoptions(@fminunc,'Algorithm','quasi-newton','SpecifyObjectiveGradient',true,'HessianFcn','objective');
%'active-set', 'interior-point', 'sqp', or 'trust-region-reflective'.
problem = createOptimProblem('fminunc','objective',@f2,'x0',y0,'options',opts);
gs = GlobalSearch;
[y,fval,exitflag] = run(gs,problem);

oo_.steady_state=y;
end
%max(abs(fval))
end
function [F,J]=f(y)
global M_ params x;
%r=sin(y)-cos(y);
%eval(['[F,J,H]=' M_.fname '_static([' num2str(y) '],[' num2str(x) '],['  num2str(params) ']);']);
[F,J]=feval([M_.fname '_static'],y,x,params);
if imag(F) ~= 0; F = 10^5; end
if imag(y) ~= 0;
    F = 10^5; 
end
%r=r.^2;
end
function [F,J,H]=f2(y)
global M_ params x;
%r=sin(y)-cos(y);
%eval(['[F,J,H]=' M_.fname '_static([' num2str(y) '],[' num2str(x) '],['  num2str(params) ']);']);
[F,J,H]=feval([M_.fname '_static'],y,x,params);
%r=r.^2;
HF=[];
st=size(F,1);
for i=1:st
HH.(['H' num2str(i)])=H(:,i:15:end);
HH.(['F' num2str(i)])=H(:,i:15:end)*F;
HF=[HF,H(:,i:15:end)*F];
end
H=2*(HF+J.'*J);
J=2*J.'*F;
F=F.'*F;
if ~isfinite(F)
   F=10^10; 
end

if any(~isfinite(J))
   J=ones(size(J)); 
end

if any(any(~isfinite(H)))
   H=ones(size(H)); 
end
end
