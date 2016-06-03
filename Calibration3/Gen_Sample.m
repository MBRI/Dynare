function Gen_Sample()
global oo_
global M_
load '.temp/init.mat';
load '.temp/input.mat';
Min_Par_Calib=init.Min_Par_Calib;
%Step_Par_Calib=init.Step_Par_Calib;
Max_Par_Calib=init.Max_Par_Calib;

clear init FileName Par_Calib;
Total_itration=3000;%ceil((Max_Par_Calib-Min_Par_Calib)./Step_Par_Calib);
%Total_itration= 3*sum(Total_itration);

%if exist('.temp/LVal.mat','file')
%load '.temp/LVal.mat';
%Min_Par_Calib=Par_Calib;
%end
h = waitbar(0/Total_itration,'Please wait...');

% Great itration
for itr=1:Total_itration
    rng('shuffle')
    Par_Calib = Min_Par_Calib + (-1*Min_Par_Calib+Max_Par_Calib).*rand(size(Max_Par_Calib,1),1); % Generate uniform Randome Numbers for each parameter in Range specified by user
    
    
    waitbar(itr / Total_itration)
    try %#ok<TRYNC>
        Temp_Cal(Par_Calib);
        %Itr.V=oo_.var;
        %Itr.A=oo_.autocorr{1};
        %Itr.S=oo_.steady_state;
        %Itr.M=oo_.mean;
        Itr.oo_=oo_;
        Itr.P=Par_Calib;
        save (['.temp/Itr' num2str(itr) '.mat'], 'Itr')
        clear Itr
    end
end
save ('.temp/M_.mat', 'M_')
close (h)

clear
clc
end

