var y, x;
varexo e_x;

parameters a, b, c, d;
options_.noprint=0;
a = 0.36;
b   = 0.95;
c   = 0.025;
d  =0.99;

model(linear);
x= a*x(-1)+b*y(-1)+e_x;
y=c*x(+1)+d*x(-1);
end;


steady;

check;

shocks;
var e_x; stderr 0.9;
end;
clc;

varobs y x; 
estimated_params;
a, uniform_pdf, -1.5, .5;
b, uniform_pdf, -1.5, .5;
c, uniform_pdf, 0, .5;
d, uniform_pdf, 0, .5;

end;

irf_calibration ;
y(1:4), e_x, -;
end;

moment_calibration;
y,y, [0.5 1.5]; //[unconditional variance]
x,y(1:4), +; //[sign restriction for first year acf with logical OR]

end;

dynare_sensitivity;
//stoch_simul(irf=20);
 //