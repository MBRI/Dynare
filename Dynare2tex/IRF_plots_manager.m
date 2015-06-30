% IRF_plots_manager
% This code is easy way to call IRF_plot.m. IRF_plot function uses
% matlab2tikz toolbox available on Mathworks.
clc
close all;
tic;
% The path for plots
% This would be  path of output
% All the tex files will be saved in this directory
% CAUTION: all the files and directories other than Path in this folder will be deleted.
Path='Comp1';
% The .mod or .mat files would be determined here
% The mat file must be Dynare results and should be
% in the same folder of this function.
% For new cases just follow the pattern Mfile{#}='New.mod(mat)';
% If the Mfiles are *.mod files, using nograph, noprint and graph_format=none in *.mod files are highly recomended to
% speed up the code.
Mfile{1}='New_Keynesian_Discretionary.mod';
Mfile{2}='New_Keynesian.mod';
Mfile{3}='New_Keynesian_Optimal_Policy.mod';

% Which variable(s) to be drawn
% The Vlist{i} includes the endogenous variable in the Mfile{i}
% The order is important for cross mod files
% To plot all the variables leave it empty
% CAUTION: In the last case ensure that all variables have the same order in all mode (mat) files
VList{1}='x pi i';
VList{2}='@';
VList{3}='@';

% If the IRFs of just some variables are needed, variable names are just needed
% in the first VList and @ sign can be used in the others. For example if
% just y, c, i and h are the prefered variables the following format is
% needed:
% VList{1}='y c i h';
% VList{2}='@';
% VList{3}='@';

% Which shoks to be drawn
% The Slist{i} includes the shocks in the Mfile{i}
% The order is important for cross mod files
% To plot all the shocks leave it empty
% CAUTION: In the last case ensure thet all shocks have the same order in
% all mode files. Use @ sign instead of repeating the shocks name in the
% remaining SLists
SList{1}='e_pi e_x e_nu';
SList{2}='@';
SList{3}='@';

% Title of each model
Tmod{1}='Discretionary Policy';
Tmod{2}='Rule-based Policy';
Tmod{3}='Optimal Policy';

% Extra Image file
% if you want to have the plot in another format exceet tikz, say below
% Avalabe format: tikz ; fig ; bmp ; eps ; emf ; jpg ; pcx ; pbm ; pdf ; pgm ; png
% ;ppm ; svg ;tif1 ; tif2 
%Image_Format={'tikz' ; 'fig' ; 'bmp' ; 'eps' ; 'emf' ; 'jpg' ; 'pcx' ; 'pbm' ; 'pdf' ; 'pgm' ; 'png' ; 'ppm' ; 'svg' ;'tif1' ; 'tif2'};%
Image_Format={'eps'; 'tex'};
% To normal the data regarding the greatest time series data so that the
% IRFs with different scales can be compared use ReScale=1 and use
% ReScale=0 to see the exat scale of the IRFs.
ReScale=0;
% Number of columns for each page. If nan it would be determined automaticaly
% and also It must be an integer
Column=3;
% Number of rows for each page. If nan it would be determined automaticaly
% and also It must be an integer
Row=3;
% Number of perids to plot. It is recomended to use a high value of irf
% command in .mod files so that it can be easily managed here.

irf_duration=20;
% Call the IRF_plots function
IRF_plots(Path,Mfile,VList,SList,Tmod,Image_Format,ReScale,Row, Column, irf_duration);

% Output Folder includes:
% 1. a folder which is named "Graphs" and consist of all single figure tex
% files
% 2. an excell file named "FileGuid.xls" wich gather all the figrues name
% and corespondence Variable and shock name for every file.
% 3. a sample tex file by the name "Multi.tex" that show how t use the
% outcomes
% 4. some miscellaneous files came out of compiling of  "Multi.tex" and
% likle included "Multi.pdf"


% showing up 
home;
t=toc;
disp('Total computing time :'); disp(datestr(datenum(0,0,0,0,0,t),'HH:MM:SS'))
clear;