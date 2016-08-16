var y$ {\hat y}$ (long_name='output'),
     x ${\chi}$ (long_name='consumption') ;
varexo e_x ${e_\chi}$ (long_name='Exogenius Shock') ;

parameters a ${\alpha}$, b${\beta}$, c${\gamma}$, d${\delta}$;
options_.noprint=0;
a = 0.36;
b = 0.05;
c = 0.002;
d =0.09;

model(linear);
x= a*x(-1)+b*y(-1)+e_x;
y=c*x(+1)+d*x(-1);
end;


steady;

check;

shocks;
var e_x; stderr 0.9;
end;



 stoch_simul(irf=20);

options_.TeX=1

write_latex_dynamic_model;
write_latex_parameter_table;
write_latex_definitions;
collect_latex_files;
