// Endogenous Variables

var x $\hat{x}$ i $\hat{i}$ pi $\hat{\pi}$ u_x $\hat{u}_{x}$ nu $\hat{\nu}$ u_pi $\hat{u}_{\pi}$ nu $\hat{\nu}$;

// Exogenous Variables

varexo u $\hat{u}$ e_nu $\hat{\upsilon_{\nu}}$ e_x $\hat{\upsilon_{x}}$ e_pi $\hat{\upsilon_{\pi}}$;

// Parameters 

parameters sigma $\hat{\sigma}$ beta $\beta$ kappa $\kappa$ rhox $\rho_{x}$ rhopi 
$\rho_{\pi}$ rhonu $\rho_{\nu}$ delta $\delta$ omega $\omega$ lambdax $\lambda_{x}$ lambdapi $\lambda_{\pi}$;

sigma=1;
beta=0.99;
delta=1.5;
rhox=0.8;
rhopi=0.8;
rhonu=0.8;
omega=0.8;
kappa=(1-omega)*(1-beta*omega)/omega;
lambdax=0.25;
lambdapi=1;

// The Model

model(linear);
// The NK IS Curve

x=x(+1)-sigma^(-1)*(i-pi(+1))+u_x;

// The NKPC

pi=beta*pi(+1)+kappa*x+u_pi;

// IS Shock

u_x=rhox*u_x(-1)+e_x;

// Mark-up Shock
u_pi=rhopi*u_pi(-1)+e_pi;

// Monetary Policy Shock

nu=rhonu*nu(-1)+e_nu;

end;

// The Steady States

initval;
x=0;
i=0;
pi=0;
u_x=0;
u_pi=0;
nu=0;
end;


// The Exogenous Shocks 

shocks;
var e_x;
stderr 0.01;
var e_pi;
stderr 0.01;
var e_nu; 
stderr 0.01;
end;

// The objective function of the central bank

planner_objective lambdax*x^2+lambdapi*pi^2;

discretionary_policy(periods=10092,irf=50,order=1, planner_discount=0.99,discretionary_tol=1e-8, instruments=(i), maxit=50000, nodisplay, noprint, graph_format=none);







