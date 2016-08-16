var y$ {\hat y}$ ,
     x ${\kappa}$ ;
varexo e_x,e_y;

parameters a, b, c;

a = 0.36;
b   = 0.95;
c   = 0.025;


model(linear);
x= a*x(-1)+b*y+e_x;
y=c*y(+1)+e_y;
end;


steady;

check;

shocks;
var e_x; 
periods 3:9;
values 9;
end;

stoch_simul;