function Gen_Sample()
global oo_
global M_
load '.temp/init.mat';
load '.temp/input.mat';
load '.temp/input.mat'; % include MaxIt
Min_Par_Calib=init.Min_Par_Calib;
%Step_Par_Calib=init.Step_Par_Calib;
Max_Par_Calib=init.Max_Par_Calib;

clear init FileName Par_Calib;

%if exist('.temp/LVal.mat','file')
%load '.temp/LVal.mat';
%Min_Par_Calib=Par_Calib;
%end
h = waitbar(0/MaxIt,'Please wait...');
% make uniform Randome values for each parametes
    rng('shuffle') % it is use ful to determine the min and max greater than your need
Par_Calib =repmat( Min_Par_Calib,1,MaxIt) + repmat(-1*Min_Par_Calib+Max_Par_Calib,1,MaxIt).*rand(size(Max_Par_Calib,1),MaxIt); % Generate uniform Randome Numbers for each parameter in Range specified by user
% Great itration
for itr=1:MaxIt
  
    waitbar(itr / MaxIt)
    try
        Temp_Cal(Par_Calib(:,itr));
        %Itr.V=oo_.var;
        %Itr.A=oo_.autocorr{1};
        %Itr.S=oo_.steady_state;
        %Itr.M=oo_.mean;
        Itr.oo_=oo_;
        Itr.P=Par_Calib(:,itr);
        save (['.temp/Itr' num2str(itr) '.mat'], 'Itr')
        clear Itr
    catch
        
    end
end
save ('.temp/M_.mat', 'M_')
close (h)
cleanup(M_.fname);
clear
clc
end

