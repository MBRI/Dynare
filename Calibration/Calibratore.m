
function [Opt]=Calibratore(FileName,Par_Calib,Calib,Weight)
% this file is developed to simplify the handy calibration

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

% Calib Errors
F1={'Var';'ACorr';'SS';'Mean'}; % all needed fields
FF=F1(~isfield(Calib,F1));
for i=1:size(FF,1)
    Calib.(FF{i})=nan;
end
% Weight errors
FF=F1(~isfield(Weight,F1));
for i=1:size(FF,1)
    Weight.(FF{i})=1;
end
clear FF;
%% Biuld the necessary files
% FileName without Extension
eval(['dynare ' FileName '.mod']);
close all;
load([FileName, '_results.mat']);
PC=M_.param_nbr;
VC=M_.endo_nbr;

%% Second stage error checking base on mod results
[FileName,Par_Calib,Calib,Weight]=errHandl(FileName,Par_Calib,Calib,Weight,VC);
%%

% Extract Calib Parameter % [Min_Par_Calib,Step_Par_Calib,Max_Par_Calib]=
GetCalibParam(Par_Calib,M_);
% Restructure Dynare file
NewFile=writeNew_mFile(FileName);
% Create Loop file
writeLoopFile(FileName,NewFile,PC);
%% Run the Loop File
rehash
eval([FileName '_Calib();']);
%Clean Extra files
cleanup(FileName);
clearvars -except Calib  Weight
% find the Best option
Opt=SecondBest(Calib,Weight);
end

function writeLoopFile(FileName,NewFile,PC)
%Remove previous file
if exist([FileName '_Calib.m'],'file')
    delete([FileName '_Calib.m']);
end
fid=fopen([FileName '_Calib.m'],'w+');
fprintf(fid,'%s\n',['function ' FileName '_Calib()']);%Min_Par_Calib,Step_Par_Calib,Max_Par_Calib
fprintf(fid,'%s\n','global oo_');
% Load init valus
fprintf(fid,'%s\n','load ''.temp/init.mat'';');

fprintf(fid,'%s\n','Min_Par_Calib=init.Min_Par_Calib;');
fprintf(fid,'%s\n','Step_Par_Calib=init.Step_Par_Calib;');
fprintf(fid,'%s\n','Max_Par_Calib=init.Max_Par_Calib;');


% Create Empty Structure Paramete
fprintf(fid,'%s\n','Res=struct();');
% Struc counter
%fprintf(fid,'%s\n','SC=0;');
fprintf(fid,'%s\n','h = waitbar(0,''Please wait...'');');
fprintf(fid,'%s\n','itr=0;');

%
fprintf(fid,'Total_itration=ceil((Max_Par_Calib-Min_Par_Calib)./Step_Par_Calib);');
fprintf(fid,'Total_itration=prod(Total_itration(Total_itration>0));');
for i=1:PC
    fprintf(fid,'%s\n',['for Par_' num2str(i) '=Min_Par_Calib(' num2str(i) '): Step_Par_Calib(' num2str(i) '): Max_Par_Calib(' num2str(i) ')']);
    
end
fprintf(fid,'%s','Par_Calib=[');
for i=1:PC
    fprintf(fid,'%s',['Par_' num2str(i) ';']);
end
fprintf(fid,'%s\n','];');
fprintf(fid,'%s\n','itr=itr+1;');
fprintf(fid,'%s\n','waitbar(itr / Total_itration)');
fprintf(fid,'%s\n','try');
fprintf(fid,'%s\n',[FileName '_Cal(Par_Calib);']);

% Close Fugurs
%fprintf(fid,'%s\n','close (h)');

% Struc counter
%fprintf(fid,'%s\n','SC=SC+1;');
% Save Variance

fprintf(fid,'%s\n','Itr.V=oo_.var;'); % Save Var-Cov Matrix
fprintf(fid,'%s\n','Itr.A=oo_.autocorr{1};'); % Save Auto Corelation Matrix
fprintf(fid,'%s\n','Itr.S=oo_.steady_state;'); % Save Steady State Vector
fprintf(fid,'%s\n','Itr.M=oo_.mean;'); % Save Mean Vector
fprintf(fid,'%s\n','Itr.P=Par_Calib;'); % Save Current Calibration Matrix
%fprintf(fid,'%s\n','eval([''Itr'' numstr(itr) ''=Itr;'']);');
fprintf(fid,'%s\n','save ([''.temp/Itr'' num2str(itr) ''.mat''], ''Itr'')');
fprintf(fid,'%s\n', ' clear Itr');
% end of try
fprintf(fid,'%s\n','end');
%end for
for i=1:PC
    fprintf(fid,'%s\n','end');
end
fprintf(fid,'%s\n','close (h)');
%End of Loop Function
fprintf(fid,'%s\n','end');

%Put Dynare f.m Function
fprintf(fid,'%s',NewFile);
fclose(fid);

end
function NewFile=writeNew_mFile(FileName)
global M_
PC=length(M_.params);
Originalfile = fileread([FileName, '.m']);
NewFile='';
%NewFile=sprintf('%s1 \n %s2','newpage','mine');
NewFile=sprintf('%s\n',['function ' FileName '_Cal(Par_Calib)']);

NewFile=sprintf('%s \n %s',NewFile,Originalfile);

NewFile=strrep(NewFile,'clear all','');
% Capter the Param count

% BuildUp .m file to function
for i=1:PC
    NewFile=strrep(NewFile,['M_.params( ' num2str(i) ' ) = ' num2str(M_.params(i))],['M_.params( ' num2str(i) ' ) = Par_Calib(' num2str(i) ')']);
end
% Clear All Print Options
NewFile=strrep(NewFile,'options_.noprint','% options_.noprint');
NewFile=strrep(NewFile,'options_.nograph','% options_.nograph');
NewFile=strrep(NewFile,'options_.graph_format','% options_.graph_format');
% Set  No Output
NewFile=strrep(NewFile,'options_ = [];',['options_ = [];' char(10)  'options_.noprint=1;' char(10)  'options_.nograph=1;' char(10)  'options_.graph_format=''none'';']);

% End the created function
NewFile=sprintf('%s \n %s',NewFile,'end ');
end
function [] = cleanup(fname)
% Cleans up files no longer required once a .MOD file has been executed by DYNARE
% Dirk Muir, Jan 2012
close all;
%

warning off all;
delete([fname, '_static.m']);
delete([fname, '_dynamic.m']);
delete([fname, '_dynamic.bin']);
delete([fname, '_dynamic.cod']);
delete([fname, '_set_auxiliary_variables.m']);
delete([fname, '_static.bin']);
delete([fname, '_static.cod']);
delete([fname, '.log']);
delete([fname, '.m']);
delete([fname, '_results.mat']);
delete([fname, '.log']);
delete([fname, '*.eps']);
delete([fname, '*.asv']);
delete([fname, '_Calib.m']);
rmdir(fname,'s');
%delete([fname, '_results.mat']);
%mkdir('dynarefiles');
%movefile([fname, '.m'], 'dynarefiles', 'f');
%movefile([fname, '.log'], 'dynarefiles', 'f');

%mkdir('calib');
%movefile([fname, '_results.mat'], 'calib', 'f');

%rmdir(fname, 's');

warning on all;
end
function GetCalibParam(Par_Calib0,M)
%[Min_Par_Calib,Step_Par_Calib,Max_Par_Calib]=
Par_Calib0=strrep(Par_Calib0,'=',':');
%Par_Calib=cellfun(@(x) strsplit(x,':'),Par_Calib0,'UniformOutput' , false);
Cal={'','','',''};
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
Step_Par_Calib=ones(size(Min_Par_Calib,1),1);
Max_Par_Calib=M.params;
for i=1:length(Par_Calib)
    Cal=Par_Calib0(strcmp(Par_Calib0(:,1),Par_Calib(i)),:);
    if ~isempty(Cal)
        Min_Par_Calib(i)=str2double(Cal{2});
        Step_Par_Calib(i)=str2double(Cal{3});
        Max_Par_Calib(i)=str2double(Cal{4});
    end
end

%for i=1:length(Par_Calib)
init.Min_Par_Calib=Min_Par_Calib;
init.Step_Par_Calib=Step_Par_Calib;
init.Max_Par_Calib=Max_Par_Calib;
if exist('.temp','dir')
    rmdir('.temp','s')
end
mkdir .temp
save '.temp/init.mat' init;
end
function Opt=SecondBest(Calib,Weight)

% Clibration Vaues
V=[reshape(Calib.Var,[],1); ...
    reshape(Calib.ACorr,[],1); ...
    reshape(Calib.SS,[],1); ...
    reshape(Calib.Mean,[],1)];
% Weight Matrix
W=[reshape(Weight.Var,[],1); ...
    reshape(Weight.ACorr,[],1); ...
    reshape(Weight.SS,[],1); ...
    reshape(Weight.Mean,[],1)];

% Load data files
F=dir('.temp/Itr*.mat');
F={F.name};

% Number of fields
NF=length(F);%max(cellfun(@(x)str2double(x(4:end)),fields(Res)));
for i=1:NF
    load(['.temp/' F{i}]);
    Res.(['Itr' num2str(i)])=Itr;
    Res.(['Itr' num2str(i)]).I=i; % Chain to .temp
    clear Itr;
end

for i=1:NF
    %     if i==1
    %         V=[reshape(Res.(['V' num2str(i)]),[],1); ...
    %             % reshape(Res.(['A' num2str(i)]),[],1); ...
    %             reshape(Res.(['S' num2str(i)]),[],1); ...
    %             reshape(Res.(['M' num2str(i)]),[],1)];
    %     else
    V=[V,[reshape(Res.(['Itr' num2str(i)]).V,[],1); ...
        reshape(Res.(['Itr' num2str(i)]).A,[],1); ...
        reshape(Res.(['Itr' num2str(i)]).S,[],1); ...
        reshape(Res.(['Itr' num2str(i)]).M,[],1)]];
    %     end
end
W(isnan(V(:,1)),:)=[];
V(isnan(V(:,1)),:)=[];
V(isnan(W(:,1)),:)=[];
W(isnan(W(:,1)),:)=[];

V=V-diag(V(:,1))*ones(size(V));
V(:,1)=[];
V=V.'*diag(W)*V;
V=diag(V);
if length(min(V))>1
    warning('More than one solution found.');
end
V(V~=min(V))=nan;
V(V==min(V))=1;


for i=1:NF
    if V(i)~=1
        Res=rmfield(Res,['Itr' num2str(i)]);
    end
end
Opt=Res;
end
function [FileName,Par_Calib,Calib,Weight]=errHandl(FileName,Par_Calib,Calib,Weight,VC)
% Var
if size(Calib.Var,1)>VC;
    warning('Calib.Var has extra rows. I drop them')
    Calib.Var(VC+1:end,:)=[];
end
if size(Calib.Var,2)>VC;
    warning('Calib.Var has extra columns. I drop them')
    Calib.Var(:,VC+1:end)=[];
end
if size(Calib.ACorr,1)>VC;
    warning('Calib.ACorr has extra rows. I drop them')
    Calib.Var(VC+1:end,:)=[];
end
if size(Calib.ACorr,2)>VC;
    warning('Calib.ACorr has extra columns. I drop them')
    Calib.Var(:,VC+1:end)=[];
end

if length (Calib.SS)>VC;
    warning('Calib.SS has extra elements. I drop them')
    Calib.Var(VC+1:end)=[];
end
if length (Calib.Mean)>VC;
    warning('Calib.Mean has extra elements. I drop them')
    Calib.Var(VC+1:end)=[];
end

if size(Calib.Var,1)<VC;
    warning('Calib.Var has not adequate rows. I fill with nan')
    Calib.Var=[Calib.Var;nan(VC-size(Calib.Var,1),size(Calib.Var,2))];
end
if size(Calib.Var,2)<VC;
    warning('Calib.Var has  not adequate columns. I fill with nan')
    Calib.Var=[Calib.Var,nan(size(Calib.Var,1),VC-size(Calib.Var,2))];
end
if size(Calib.ACorr,1)<VC;
    warning('Calib.ACorr has not adequate rows. I fill with nan')
    Calib.ACorr=[Calib.ACorr;nan(VC-size(Calib.ACorr,1),size(Calib.ACorr,2))];
end
if size(Calib.ACorr,2)<VC;
    warning('Calib.ACorr has not adequate columns. I fill with nan')
    Calib.ACorr=[Calib.ACorr,nan(size(Calib.ACorr,1),VC-size(Calib.ACorr,2))];
end

if length (Calib.SS)<VC;
    warning('Calib.SS has not adequate elements. I fill with nan')
    Calib.SS(end+1:VC)=nan;
end
if length (Calib.Mean)<VC;
    warning('Calib.Mean has not adequate elements. I fill with nan')
    Calib.Mean(end+1:VC)=nan;
end

% Weight
if size(Weight.Var,1)>VC;
    warning('Calib.Var has extra rows. I drop them')
    Weight.Var(VC+1:end,:)=[];
end
if size(Weight.Var,2)>VC;
    warning('Calib.Var has extra columns. I drop them')
    Weight.Var(:,VC+1:end)=[];
end
if size(Weight.ACorr,1)>VC;
    warning('Calib.ACorr has extra rows. I drop them')
    Weight.Var(VC+1:end,:)=[];
end
if size(Weight.ACorr,2)>VC;
    warning('Calib.ACorr has extra columns. I drop them')
    Weight.Var(:,VC+1:end)=[];
end

if length (Weight.SS)>VC;
    warning('Calib.SS has extra elements. I drop them')
    Weight.Var(VC+1:end)=[];
end
if length (Weight.Mean)>VC;
    warning('Calib.Mean has extra elements. I drop them')
    Weight.Var(VC+1:end)=[];
end

if size(Weight.Var,1)<VC;
    warning('Calib.Var has not adequate rows. I fill with nan')
    Weight.Var=[Weight.Var;ones(VC-size(Weight.Var,1),size(Weight.Var,2))];
end
if size(Weight.Var,2)<VC;
    warning('Calib.Var has  not adequate columns. I fill with nan')
    Weight.Var=[Weight.Var,ones(size(Weight.Var,1),VC-size(Weight.Var,2))];
end
if size(Weight.ACorr,1)<VC;
    warning('Calib.ACorr has not adequate rows. I fill with nan')
    Weight.ACorr=[Weight.ACorr;ones(VC-size(Weight.ACorr,1),size(Weight.ACorr,2))];
end
if size(Weight.ACorr,2)<VC;
    warning('Calib.ACorr has not adequate columns. I fill with nan')
    Weight.ACorr=[Weight.ACorr,ones(size(Weight.ACorr,1),VC-size(Weight.ACorr,2))];
end

if length (Weight.SS)<VC;
    warning('Calib.SS has not adequate elements. I fill with nan')
    Weight.SS(end+1:VC)=ones();
end
if length (Weight.Mean)<VC;
    warning('Calib.Mean has not adequate elements. I fill with nan')
    Weight.Mean(end+1:VC)=ones();
end
end