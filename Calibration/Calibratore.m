
function Res=Calibratore(FileName,Par_Calib,Var_Calib,ACorr_Calib,SS_Calib)
% FileName without Extension
eval(['dynare ' FileName]);

load([FileName, '_results.mat']);
PC=length(M_.params);
% Restructure Dynare file
NewFile=writeNew_mFile(FileName);
% Create Loop file
writeLoopFile(FileName,NewFile,PC);

% Extract Calib Parameter
[Min_Par_Calib,Step_Par_Calib,Max_Par_Calib]=GetCalibParam(Par_Calib,M_);

% Run the Loop File
eval(['Res= ' FileName '_Calib(Min_Par_Calib,Step_Par_Calib,Max_Par_Calib);']);
fields(Res);
cleanup(FileName);
clearvars -except Res Var_Calib ACorr_Calib SS_Calib
Opt=SecondBest(Res,Var_Calib,ACorr_Calib,SS_Calib);
end
function writeLoopFile(FileName,NewFile,PC)
%Remove previous file
delete([FileName '_Calib.m']);
fid=fopen([FileName '_Calib.m'],'w+');
fprintf(fid,'%s\n',['function [Res]=' FileName '_Calib(Min_Par_Calib,Step_Par_Calib,Max_Par_Calib)']);
fprintf(fid,'%s\n','global oo_');
% Create Empty Structure Paramete
fprintf(fid,'%s\n','Res=struct();');
% Struc counter
fprintf(fid,'%s\n','SC=0;');
for i=1:PC
    fprintf(fid,'%s\n',['for Par_' num2str(i) '=Min_Par_Calib(' num2str(i) '): Step_Par_Calib(' num2str(i) '): Max_Par_Calib(' num2str(i) ')']);
end
fprintf(fid,'%s','Par_Calib=[');
for i=1:PC
    fprintf(fid,'%s',['Par_' num2str(i) ';']);
end
fprintf(fid,'%s\n','];');
fprintf(fid,'%s\n','try');
fprintf(fid,'%s\n',[FileName '_Cal(Par_Calib);']);
fprintf(fid,'%s\n','end');
% Close Fugurs
fprintf(fid,'%s\n','close all');

% Struc counter
fprintf(fid,'%s\n','SC=SC+1;');
% Save Variance
fprintf(fid,'%s\n','Res.([''V'' num2str(SC)])=oo_.var;'); % Save Var-Cov Matrix
fprintf(fid,'%s\n','Res.([''A'' num2str(SC)])=oo_.autocorr;'); % Save Auto Corelation Matrix
fprintf(fid,'%s\n','Res.([''S'' num2str(SC)])=oo_.steady_state;'); % Save Steady State Vector
fprintf(fid,'%s\n','Res.([''M'' num2str(SC)])=oo_.mean;'); % Save Mean Vector
fprintf(fid,'%s\n','Res.([''P'' num2str(SC)])=Par_Calib;'); % Save Current Calibration Matrix
%end for
for i=1:PC
    fprintf(fid,'%s\n','end');
end

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
%delete([fname, '_results.mat']);
%mkdir('dynarefiles');
%movefile([fname, '.m'], 'dynarefiles', 'f');
%movefile([fname, '.log'], 'dynarefiles', 'f');

%mkdir('calib');
%movefile([fname, '_results.mat'], 'calib', 'f');

%rmdir(fname, 's');

warning on all;
end
function [Min_Par_Calib,Step_Par_Calib,Max_Par_Calib]=GetCalibParam(Par_Calib0,M);
Par_Calib0=strrep(Par_Calib0,'=',':');
%Par_Calib=cellfun(@(x) strsplit(x,':'),Par_Calib0,'UniformOutput' , false);
Cal={'','','',''};
for i=1:length(Par_Calib0)
    Cal=[Cal;strsplit(Par_Calib0{i},':')];
end
Par_Calib0=Cal(2:end,:);
Par_Calib=cellstr(M.param_names);
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

end

function Opt=SecondBest(Res,Var_Calib,ACorr_Calib,SS_Calib)
% Number of fields 
NF=max(cellfun(@(x)str2double(x(2:end)),fields(Res))); 
for i=1:NF
    if i==1
        V=[reshape(Res.(['V' num2str(i)]),[],1); ...
       % reshape(Res.(['A' num2str(i)]),[],1); ... 
        reshape(Res.(['S' num2str(i)]),[],1); ...
         reshape(Res.(['M' num2str(i)]),[],1)]; 
    else
    V=[V,[reshape(Res.(['V' num2str(i)]),[],1); ...
       % reshape(Res.(['A' num2str(i)]),[],1); ... 
        reshape(Res.(['S' num2str(i)]),[],1); ...
         reshape(Res.(['M' num2str(i)]),[],1)]];
    end
end
Opt=V;

end
