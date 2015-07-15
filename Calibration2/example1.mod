var y, x;
varexo e_x;

parameters a, b, c, d;
options_.noprint=0;
a = 0.36;
b   = 0.95;
c   = 0.025;
d  = 0.99;

model(linear);
x= a*x(-1)+b*y(-1)+e_x;
y=c*x(+1);
end;


steady;

check;

shocks;
var e_x; stderr 0.009;
end;

stoch_simul(irf=20);
 