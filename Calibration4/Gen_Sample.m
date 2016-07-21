function Gen_Sample()
global M_ options_ oo_ it_ %var_list
load '.temp/Dynares.mat'
load '.temp/init.mat';
load '.temp/input.mat'; % include MaxIt
var_list=[]; % it is would use by  stoch_simul . but i dont know why
Min_Par_Calib=init.Min_Par_Calib;
%Step_Par_Calib=init.Step_Par_Calib;
Max_Par_Calib=init.Max_Par_Calib;
Min_x_Calib=init.Min_x_Calib;
%Step_Par_Calib=init.Step_Par_Calib;
Max_x_Calib=init.Max_x_Calib;
n_o=0;
clear init Par_Calib;
%{ 
if ~exist('Temp_Cal.m','file')
    if exist('.temp\Temp_Cal.m','file')
        movefile('.temp\Temp_Cal.m','Temp_Cal.m');
        rehash
    else
        error('Model m file not found.');
    end
end
%}
%if exist('.temp/LVal.mat','file')
%load '.temp/LVal.mat';
%Min_Par_Calib=Par_Calib;
%end
h = waitbar(0/MaxIt,'Generating Samples, Please wait...');
% make uniform Randome values for each parametes
rng('shuffle') % it is use ful to determine the min and max greater than your need
Par_Calib =repmat( Min_Par_Calib,1,MaxIt) + repmat(-1*Min_Par_Calib+Max_Par_Calib,1,MaxIt).*rand(size(Max_Par_Calib,1),MaxIt); % Generate uniform Randome Numbers for each parameter in Range specified by user
% it must be revised at leat for determined shock and also digonal and non
% diagnal error covariance matrix
ex_Calib =repmat( Min_x_Calib,1,MaxIt) + repmat(-1*Min_x_Calib+Max_x_Calib,1,MaxIt).*rand(size(Max_x_Calib,1),MaxIt); % Generate uniform Randome Numbers for each parameter in Range specified by user
% Great itration
for itr=1:MaxIt
    
    waitbar(itr / MaxIt)
    try
        M_.params=Par_Calib(:,itr);
        M_.Sigma_e=ex_Calib(:,itr);
        stoch_simul(var_list);
        Itr.oo_=oo_;
        Itr.P=Par_Calib(:,itr);
        Itr.ex=ex_Calib(:,itr);
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

end

