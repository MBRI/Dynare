// how to use debug command
var y$ {\hat y}$ 
     x ${\kappa}$ ;
varexo e_x;

parameters a, b, c, d;

a = 0.36;
b = 0.95;
c = 0.002;
d =0.99;


model(linear);
x= a*x(-1)+b*y(-1)+e_x;
y=c*x(+1)+d*x(-1);
end;


steady;

check;

shocks;
var e_x; stderr 0.9;
end;


//mode_check;
options_.debug=1;
model_diagnostics;