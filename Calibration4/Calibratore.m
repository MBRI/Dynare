
function [Opt]=Calibratore(FileName,Par_Calib,ex_Calib,Calib,Weight,MaxIt)
% this file is developed to simplify the handy calibration
% the snd attemp was not good enuagh so i decided to generate randome
% numbers for each parameters and build a big sample to explore the
% behavire of the outcomes of model
% in this version leave to rebiuld .m file and use info =
% stoch_simul(var_list_); directly
global  M_ options_ oo_ it_ %var_list

if nargin==0
    if exist('.temp/input.mat','file')
        if strcmp(questdlg('Do you want to continue the previous procedure?','Reload','Yes','No','No'),'Yes')
            load '.temp/input.mat'
        else
            error('Retry by applicable arguments.')
        end
    else
        error('Bad usage, follow up the manual.')
    end
else
    %% Error Checking
    % initial errors
    if ~exist('FileName','var')
        error('Please introduce a mod file')
    end
    % if ~exist(FileName,'file')
    %     error([FileName ' doesn''t exist.'])
    % end
    if ~exist('Par_Calib','var')
        error('Please determie the calibration variables and range')
    end
    if ~exist('MaxIt','var')
        MaxIt=300;
    end
    if ~exist('Calib','var')
        warning('No calibration target specified.')
        Calib=struct();
    end
    if ~exist('Weight','var')
        warning('The equal weight assigned.')
        Weight=struct();
    end
    % file name errors
    [~,FileName,~] =fileparts(FileName);
    
    
    %% Biuld the necessary files
    % FileName without Extension
    eval(['dynare ' FileName '.mod']);
    close all;
    
    %load([FileName, '_results.mat']);
    PC=M_.param_nbr;
    VC=M_.endo_nbr;
    
    %% Second stage error checking base on mod results
    [Par_Calib,Calib,Weight]=errHandl0(Par_Calib,Calib,Weight,oo_);
    %% save to hrd drive
    if exist('.temp','dir')
        rmdir('.temp','s')
    end
    mkdir .temp
    
    % change some of options
    options_.nolog=1; options_.noprint=1; options_.nograph=1; options_.graph_format='none';
    
    save '.temp/Dynares.mat'  M_ options_ oo_ it_ %var_list% this will uses in Make Model as initial Value Storage
    % Extract Calib Parameter % [Min_Par_Calib,Step_Par_Calib,Max_Par_Calib]=
    GetCalibParam(Par_Calib,ex_Calib,M_);
    % Restructure Dynare file
 %   NewFile=writeNew_mFile(FileName);
    % Create Loop file
%    writeModFile(FileName,NewFile,PC,MaxIt,Include_exo_var);
    % from this point
    save '.temp/input.mat' FileName Par_Calib Calib Weight PC MaxIt
    %Clean Extra files
    %cleanup(FileName);
    clearvars -except Calib  Weight
    
end
%% Run the Gen File
%rehash % Refresh the files in order to recognize new file by matlab
Gen_Sample(); % generate Samples
% find the Best option
%Opt=MakeModel();
MakeModel;
end

function GetCalibParam(Par_Calib0,ex_Calib0,M)
%[Min_Par_Calib,Step_Par_Calib,Max_Par_Calib]=
%% for exo var
ex_Calib0=strrep(ex_Calib0,'=',':');
Cal={'','',''};
xCal={'','',''};
for i=1:size(ex_Calib0,1)
    try
        xCal=[xCal;strsplit(ex_Calib0{i},':')];
    catch
        error('Not appropriate use of ex_Calib. ');
    end
end
ex_Calib0=xCal(2:end,:);

ex_Calib=cellstr(M.exo_names);
if strcmp(ex_Calib0{1},'*')
    ex_Calib0=[ex_Calib,repmat(ex_Calib0(2:end),size(ex_Calib,1),1)];
end
% Par_Calib=cellstr(M.param_names);
Min_x_Calib=M.Sigma_e;
%Step_Par_Calib=ones(size(Min_Par_Calib,1),1);
Max_x_Calib=M.Sigma_e;
for i=1:length(ex_Calib)
    xCal=ex_Calib0(strcmp(ex_Calib0(:,1),ex_Calib(i)),:);
    if ~isempty(xCal)
        Min_x_Calib(i)=str2double(xCal{2});
        %Step_Par_Calib(i)=str2double(Cal{3});
        Max_x_Calib(i)=str2double(xCal{3});%{4}
    end
end

%for i=1:length(Par_Calib)
init.Min_x_Calib=Min_x_Calib;
%init.Step_Par_Calib=Step_Par_Calib;
init.Max_x_Calib=Max_x_Calib;


%% fo parameters
Par_Calib0=strrep(Par_Calib0,'=',':');
%Par_Calib=cellfun(@(x) strsplit(x,':'),Par_Calib0,'UniformOutput' , false);
%Cal={'','','',''};
Cal={'','',''};
for i=1:size(Par_Calib0,1)
    try
        Cal=[Cal;strsplit(Par_Calib0{i},':')];
    catch
        error('Not appropriate use of Par_Calib. ');
    end
end
Par_Calib0=Cal(2:end,:);

Par_Calib=cellstr(M.param_names);
if strcmp(Par_Calib0{1},'*')
    Par_Calib0=[Par_Calib,repmat(Par_Calib0(2:end),size(Par_Calib,1),1)];
end
% Par_Calib=cellstr(M.param_names);
Min_Par_Calib=M.params;
%Step_Par_Calib=ones(size(Min_Par_Calib,1),1);
Max_Par_Calib=M.params;
for i=1:length(Par_Calib)
    Cal=Par_Calib0(strcmp(Par_Calib0(:,1),Par_Calib(i)),:);
    if ~isempty(Cal)
        Min_Par_Calib(i)=str2double(Cal{2});
        %Step_Par_Calib(i)=str2double(Cal{3});
        Max_Par_Calib(i)=str2double(Cal{3});%{4}
    end
end

%for i=1:length(Par_Calib)
init.Min_Par_Calib=Min_Par_Calib;
%init.Step_Par_Calib=Step_Par_Calib;
init.Max_Par_Calib=Max_Par_Calib;
itr=0; % it is useful

save '.temp/init.mat' init itr;
end

function [Par_Calib,Calib,Weight]=errHandl0(Par_Calib,Calib,Weight,oo_)
% Var

% if the felid of Calib does exist in oo_
F1=fieldnames(Calib); % all needed fields
FF=F1(~isfield(oo_,F1));
if ~isempty(FF)
    error(['fields of calib not exist in oo_: ' FF{:}]);
end
% keep the elemnts of oo that exist in Calib
F2=fieldnames(oo_);
FF=F2(~isfield(Calib,F2));
oo_=rmfield(oo_,FF);

F2=fieldnames(Weight);
FF=F2(~isfield(Calib,F2));
Weight=rmfield(Weight,FF);

addpath('structcmp');
[~,Calib]=structcmp2(oo_,Calib,'FillWith',nan);
[~,Weight]=structcmp2(Calib, Weight,'FillWith',1);
rmpath('structcmp');
end
