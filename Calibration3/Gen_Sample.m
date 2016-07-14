function Gen_Sample()
load '.temp/init.mat';
%load '.temp/input.mat';
load '.temp/input.mat'; % include MaxIt
Min_Par_Calib=init.Min_Par_Calib;
%Step_Par_Calib=init.Step_Par_Calib;
Max_Par_Calib=init.Max_Par_Calib;
n_o=0;
clear init Par_Calib;
if ~exist('Temp_Cal.m','file')
    error('Model m file not found.');
end
%if exist('.temp/LVal.mat','file')
%load '.temp/LVal.mat';
%Min_Par_Calib=Par_Calib;
%end
h = waitbar(0/MaxIt,'Generating Samples, Please wait...');
% make uniform Randome values for each parametes
    rng('shuffle') % it is use ful to determine the min and max greater than your need
Par_Calib =repmat( Min_Par_Calib,1,MaxIt) + repmat(-1*Min_Par_Calib+Max_Par_Calib,1,MaxIt).*rand(size(Max_Par_Calib,1),MaxIt); % Generate uniform Randome Numbers for each parameter in Range specified by user
% Great itration
for itr=1:MaxIt
  
    waitbar(itr / MaxIt)
    try
        [Itr.oo_]=Temp_Cal(Par_Calib(:,itr));
        %Itr.V=oo_.var;
        %Itr.A=oo_.autocorr{1};
        %Itr.S=oo_.steady_state;
        %Itr.M=oo_w.mean;
        %Itr.oo_=oo_;
        Itr.P=Par_Calib(:,itr);
        save (['.temp/Itr' num2str(itr) '.mat'], 'Itr')
        clear Itr 
        n_o=n_o+1;
    catch er 
        warning('one try is missed');
        warning(er.message)
    end
end

close (h)
cleanup(FileName);

home;
disp([num2str(n_o) ' valid points has been found from ' num2str(MaxIt) ' attempts.']);
clear;
end

