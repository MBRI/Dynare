function IRF_plots(Path,Mfile,VList,SList,Tmod,Image_Format, ReScale,Row, Column, irf_duration)
%% Help
% This function runs some different dynare *.mod files and plots their IRFs
% so that one can easily compare them. To Run this code, *.mod(mat) files
% should be in the same folder of this function.
% This code is easy way to call IRF_plot.m. IRF-plot function uses
% matlab2tikz toolbox available on Mathworks.
% Path: the puput Path
% All the tex files will be saved in this directory
% CAUTION: all the files and directories in this folder will be deleted.
% Mfile: a cell that in each elemets determine The .mod or .mat files
% The mat file must be Dynare results and should be
% in the same folder of this function.
% For new cases just follow the pattern Mfile{#}='New.mod(mat)';
% If the Mfiles are *.mod files, using nograph, noprint and
% graph_format=none in *.mod files are highly recomended to
% speed up the code.
% VList a cell that in each elemets determine Which variable(s) to be drawn
% The Vlist{i} includes the endogenous variable in the Mfile{i}
% The order is important for cross mod files
% To plot all the variables leave it empty
% CAUTION: In the last case ensure that all variables have the same order
% in all mode (mat) files % If the IRFs of just some variables are needed,
% variable names are just needed % in the first VList and @ sign can be
% used in the others. For example if just y, c, i and h are the prefered
% variables the following format is needed:
% VList{1}='y c i h';
% VList{2}='@';
%
% SList: a cell that in each elemets determine Which shocks to be drawn
% The Slist{i} includes the shocks in the Mfile{i}
% The order is important for cross mod files
% To plot all the shocks leave it empty
% CAUTION: In the last case ensure thet all shocks have the same order in
% all mode files. Use @ sign instead of repeating the shocks name in the
% remaining SLists
%
% Tmod: a cell that in each elemets determine correspondence Title of mod
% file
%
% ReScale: normaling the data regarding the greatest time series data so
% that the IRFs with different scales can be compared use ReScale=1 and use
% ReScale=0 to see the exat scale of the IRFs.
%
% Column: indicate the Number of columns for each page. If nan it would be
% determined automaticaly and also It must be an integer
%
% Row:  indicate the Number of rows for each page. If nan it would be
% determined automaticaly and also It must be an integer
%
% irf_duration: Number of perids to plot. It is recomended to use a high
% value of irf command in .mod files so that it can be easily managed here.
%
% Output Folder includes:
% 1. a folder which is named "tikz" and consist of all single figure tex
% files
% 2. an excell file named "FileGuid.xls" wich gather all the figrues name
% and corespondence Variable and shock name for every file.
% 3. a sample tex file by the name "Multi.tex" that show how t use the
% outcomes
% 4. some miscellaneous files came out of compiling of  "Multi.tex" and
% likle included "Multi.pdf"
%
%% Developers
% - Hossein Tavakolian, assistant professor of Allameh Tabataba'i
% University of Tehran & Monetary and Banking Research Institute
% - Pedram Davoudi, Researcher
% June 2015.

% Error Handling
if ~exist('Mfile','var')
    error('Please Determine at List One mod(mat) file');
end

if ~exist('ReScale','var') || isa(ReScale,'char')
    warning('ReScale parameter not defined correctly. I use false as default')
    ReScale=0;
end

if ~exist('irf_duration','var')
    irf_duration=nan;
end
if ~exist('Column','var')
    Column=nan;
end
if ~exist('Row','var')
    Row=nan;
end
Row =fix(Row);
Column =fix(Column);

if ~isa(Mfile,'cell')
    error('Mfile must be a cell');
end
% Check the existance of file in Mfile and extention to be mod or mat file
if ~exist('Tmod','var')
    warning('default values used instead of title of files');
    for i=1:length(Mfile)
        Tmod{i}=['File ' num2str(i)] ;
    end
elseif length(Tmod)<length(Mfile)
    for i=length(Tmod)+1:length(Mfile)
        Tmod{i}=['File ' num2str(i)] ;
    end
end

if ~isa(Tmod,'cell')
    error('Tmod must be a cell');
end
if ~exist('SList','var')
    SList=repmat({''},length(Mfile),1) ;
else
    for i=1:length(SList)
        if strcmp(SList(i),'@')
            if i==1
                SList(i)={''};
            else
                SList(i)=SList(i-1);
            end
            
        end
    end
end


if ~exist('VList','var')
    VList=repmat({''},length(Mfile),1) ;
else
    for i=1:length(VList)
        if strcmp(VList(i),'@')
            if i==1
                VList(i)={''};
            else
                VList(i)=VList(i-1);
            end
            
        end
    end
end

%%
% Change the default line styles. It does not work on octave
%[m2t.env, m2t.envVersion] = getEnvironment();
set(groot,'DefaultAxesColorOrder',[0 0 0],'DefaultLineLineWidth',1.5,'DefaultLineMarkerSize',1.5,'DefaultAxesLineStyleOrder',' - | -- | : | -. | -+ | -o | -* | -x | -s | -d | -^ | -v | -> | -< '); % | -p | -h % these two not recogized by latex
set(groot, 'defaultTextInterpreter','latex');
% Create Bink of plot format
Image_Format_Tank=[{'bmp' ; 'eps' ; 'emf' ; 'jpg' ; 'pcx' ; 'pbm' ; 'pdf' ; 'pgm' ; 'png' ; 'ppm' ; 'svg' ;'tif1' ; 'tif2'} ...
    ,{'-dbmp' ; '-depsc' ; '-dmeta' ; '-djpeg' ; '-dpcx256' ; '-dpbm' ; '-dpdf' ; '-dpgmraw' ; '-dpng' ; '-dppm' ; '-dsvg' ;'-dtiff' ; '-dtiffn'}];

%%
% Check error of Path
% Remove \ or / frome the end of directory
if strcmp(Path(end),'/') || strcmp(Path(end),'\')
    Path=Path( 1:end-1);
end
if strcmp(strtrim(Path),pwd) || strcmp(strtrim(Path),'')
    % Add default name
    Path=[pwd '/Multi'];
end
if  ~isdir(fileparts(Path))% check the parent Folder Exist?
    % Add default path
    Path=fullfile(pwd,Path);
end

if isdir(Path)
    if strcmp(questdlg(['Could i REMOVE  ' Path],'Removing Path','Yes','No','No'),'Yes')
        fclose('all');
        system('taskkill /F /IM jxbrowser-chromium.exe') ;% They may keep files open
        system('taskkill /F /IM smpd.exe');% They may keep files open
        rmdir (Path,'s'); % Remove folder if exists
    else
        error('Don''t be kidding me, Please choose an unimportante folder.')
    end
end
Path=strrep(Path,'\','/');
mkdir(Path); % Create the Folder
if sum(strcmp(Image_Format,'tex'))
    Is_tex=1;
    Image_Format(strcmp(Image_Format,'tex'))=[];
else
    Is_tex=0;
end
if sum(strcmp(Image_Format,'fig'))
    Is_fig=1;
    Image_Format(strcmp(Image_Format,'fig'))=[];
else
    Is_fig=0;
end
if Is_tex
    mkdir([Path '/Graphs_tex']); % Create the subfolder to store the single plots
end
if Is_fig
    mkdir([Path '/Graphs_fig']); % Create the subfolder to store the single plots
end
for i=1:length(Image_Format)
    mkdir([Path '/Graphs_' Image_Format{i}]); % Create the subfolder to store the single plots image
    % Determined the Enging
    Image_Format_Engine(i,1)= Image_Format_Tank(strcmp(Image_Format_Tank(:,1),Image_Format{i}),2);
end

%-*---*----*----------------------

%%
% Captur the non mat file and run them to get mat file
matF=matReturn(Mfile);

% Extract the irfs
[IRF VList0 SList0]=GetIRF(matF); %#ok<NCOMMA>

% Return the variable and shocks list
[VList, SList]=RefList(VList0, SList0,VList,SList);

% Add the corresponding sereis together
[Ser,SerTitle]=GetSeries(IRF,VList,SList,ReScale, irf_duration);

[ShockTitle,SerTitle]=GetTitles(matF,SerTitle,SList);
%%
Fld=fields(Ser);
% Find the subplot Row and Column count
M=length(Fld); % The last reserved for the legend
if isnan(Column) || isempty(Column)
    C=floor(M^0.5); %column
    R=floor(M^0.5); % Row
    while(1)
        if M>C*R
            R=R+1;
        else
            break;
        end
    end
else
    C=Column;
    R=ceil(M/C);
end
if ~(isnan(Row) || isempty(Row))
    R=Row;
end

if isnan(irf_duration) || isempty(irf_duration) ||  irf_duration>size(Ser.(Fld{1}),1)
    irf_duration=size(Ser.(Fld{1}),1);
end

warning ('off');
h = waitbar(0,'Initializing waitbar...');
for m=1:M
    hold on
    set(gcf,'Visible','off');
    plot(Ser.(Fld{m})(1:irf_duration,:));
    axis([1 irf_duration -0.0001+min(min(Ser.(Fld{m})(1:irf_duration,:))) 0.0001+max(max(Ser.(Fld{m})(1:irf_duration,:)))]);
    plot(zeros(200,1),'-','LineWidth',0.5)
    
    title(SerTitle.(Fld{m}), 'FontSize', 25);
    hold off
    for i=1:length(Image_Format)
        print(gcf,Image_Format_Engine{i},'-r300',[Path '/Graphs_' Image_Format{i} '/' Fld{m}])
    end
    if Is_tex
        matlab2tikz([Path '/Graphs_tex/' Fld{m} '.tex'],'height', '\figureheight','width', '\figurewidth',  'showInfo', false);
    end
    if Is_fig
        savefig([Path '/Graphs_fig/' Fld{m}]);
    end
    close gcf;
    perc =fix(m/M*100);
    waitbar(perc/100,h,sprintf('%d%% of IRFs created',perc))
end
close (h)
warning ('on');

% Save series name
SaveTiles(Ser,VList,SList,Path)

% Create sample tex file
if Is_tex
    comp_latex(Path, ShockTitle, VList, R, C, Tmod, 'tex');
end
for i=1:length(Image_Format)
        comp_latex(Path, ShockTitle, VList, R, C, Tmod, Image_Format{i}) 
    end
end
function [matF]=matReturn(Mfile)
% This function changes the mod file to mat file
mod=Mfile(strcmp('mod',cellfun(@(x) x(end-2:end),Mfile,'UniformOutput',false)));
matF=Mfile(strcmp('mat',cellfun(@(x) x(end-2:end),Mfile,'UniformOutput',false)));
for h=1:length(mod)
    dynare (mod{h},'nolog') ;
    rmdir(mod{h}(1:end-4),'s');
    delete([mod{h}(1:end-4) '.m']);
end
close all;
matF =[matF cellfun(@(x) [x(1:end-4) '_results.mat'],mod,'UniformOutput',false)];

% Some commands to delete or remove extra files or directories
try %#ok<TRYNC>
    delete *_IRF_*
    delete *_dynamic.m
    delete *_static.m
    delete *.jnl
    delete *.log
    delete *.eps
    delete *.aux
    delete *.dvi
    delete *.asv
    delete *_set_auxiliary_variables.m
    delete *.gz
    delete *_objective
    rmdir *_objective
    
end
end
function [IRF, Var, Shock]=GetIRF(matF)
% Load mat file and extract the oo_.irfs
for h=1:length(matF)
    load(matF{h})
    IRF.(['F' num2str(h)])=oo_.irfs;
    Shock.(['F' num2str(h)])=M_.exo_names;
    Var.(['F' num2str(h)])=M_.endo_names;
end
end
function [VList, SList]=RefList(VList0, SList0,VList1,SList1)
% Check wether the Vlist1 or SList1 is empty and return the corresponding 0
% instead
H=length(VList1);
for h=1:H
    if strcmp(strtrim(VList1(h)),'')
        VList.(['F' num2str(h)])=cellstr(VList0.(['F' num2str(h)]));
        
    else
        eval(['VV={''' strrep(VList1{h},' ' ,''';''') '''};']);
        VV(strcmp((strtrim(VV)),''))=[];
        VList.(['F' num2str(h)])=VV;
    end
    
    if strcmp(strtrim(SList1(h)),'')
        SList.(['F' num2str(h)])=cellstr(SList0.(['F' num2str(h)]));
    else
        eval(['VV={''' strrep(SList1{h},' ' ,''';''') '''};']);
        VV(strcmp((strtrim(VV)),''))=[];
        SList.(['F' num2str(h)])=VV;
    end
    
end
% Store file of varables and shocks count
VlN(H)=0; % initial Value for Vlist Count
SlN(H)=0; % initial Value for Slist Count
for h=1:H
    VlN(h)=size(VList.(['F' num2str(h)]),1);
    SlN(h)=size(SList.(['F' num2str(h)]),1);
end
if sum(VlN-min(VlN))>0
    warning('Not eqaul number of variables, extra''s droped' );
    VlN=min(VlN);
    for h=1:H
        VList.(['F' num2str(h)])(VlN+1:end)=[];
    end
    
end

if sum(SlN-min(SlN))>0
    warning('Not eqaul number of shocks, \n drop extra''s');
    SlN=min(SlN);
    for h=1:H
        SList.(['F' num2str(h)])(SlN+1:end)=[];
    end
    
end
for h=1:H
    VList.(['F' num2str(h)])(cellfun(@(x) strcmp(x(1:min(3,end)), 'AUX'), VList.(['F' num2str(h)])))=[];
end
end
function [Ser,SerTitle]=GetSeries(IRF,VList,SList,ReScale,irf_duration)
if isnan(irf_duration) || isempty(irf_duration)
    irf_duration=inf;
end
% Return joint series for each subplot
H=length(fields(IRF));

I=size(VList.F1,1);
J=size(SList.F1,1);
for j=1:J
    for i=1:I
        s=[];
        for h=1:H
            if isfield(IRF.(['F' num2str(h)]), [VList.F1{i} '_' SList.F1{j}])
                s1= (IRF.(['F' num2str(h)]).([VList.F1{i} '_' SList.F1{j}])).';
                
                if ReScale
                    mm=max(abs(s1(1:min(irf_duration,end))));
                    if mm~=0 ; s1=s1/mm;end;
                end
                if isempty(s)
                    s=s1;
                elseif size(s,1)==size(s1,1)
                    s=[s,s1]; %#ok<AGROW>
                elseif size(s,1)> size(s1,1)
                    s=[s,[s1;nan(size(s,1)-size(s1,1),size(s1,2))]];
                    warning('Uneqaul irf duration''s in file''s');
                elseif size(s,1)< size(s1,1)
                    s=[[s;nan(size(s1,1)-size(s,1),size(s,2))],s1];
                    warning('Uneqaul irf duration''s in file''s');
                else
                    error('Unknown Situation in irf''s dimension');
                end
            else
                warning([VList.F1{i} '_' SList.F1{j} ' was not found.'])
            end
        end
        if ~isempty(s)
            Ser.(['S' repmat('0',1,5-fix(log10(j))) num2str(j) '_' repmat('0',1,5-fix(log10(i))) num2str(i)])=s;
            SerTitle.(['S' repmat('0',1,5-fix(log10(j))) num2str(j) '_' repmat('0',1,5-fix(log10(i))) num2str(i)])=VList.F1{i};
        end
    end
    
end
end
function[ShockTitle,SerTitle]=GetTitles(matF,VList,SList)
h=1;
% Load Dynar results
load(matF{h})
% Store Variables' tex names
Shk=[cellstr(M_.exo_names), cellstr(M_.exo_names_tex)];
Var=[cellstr(M_.endo_names), cellstr(M_.endo_names_tex)];
% Temprary variables for tractability
St=SList.(['F' num2str(h)]);
Vt=fields(VList);
% Find the coreesponding tex names
for i=1:size(St,1)
    St{i}=['$' Shk{strcmp(Shk(:,1),St(i)) ,2} '$'];
end
% Ser titles are diffrent structures
for i=1:size(Vt,1)
    VList.(Vt{i})=['$' Var{strcmp(Var(:,1),VList.(Vt{i})) ,2} '$'];
end

%Store the titles
ShockTitle=St;
SerTitle=VList;

end
function comp_latex(Path, SList, VList, Row, Column, Tmod, Image_Format)
% Initial values
% Line styles
% matlab plot line styles ' - | -- | : | -. | -+ | -o | -* | . | -x | -s | -d | -^ | -v | -> | -< '
LinSty={'Solid';'Dashed';'Dotted'; 'Dash Dotted';'Plus';'Circle';'Asterisk'; '-X'; 's'; 'd' ; '^' ; 'v'; '>' ; '<'};
%LinSty={'solid';'dashed';'dotted'; 'dash pattern=on 1pt off 3pt on 3pt off 3pt';'-x';'-s';'-d';'-^';'-v';'>->';'<-<';'';'';'';'';'';''};
% Paper height in cm
PH=27.94;
Top=2;
Bottom=2;
HSpace=0.3; % Horizontal space between graphs
% Paper width in cm
PW=21.59;
Left=1.5;
Right=1.5;
VSpace=0;% Vertical space between graphs
% Figure height
FH=num2str((PH-Top-Bottom)/Row-HSpace);
% Figure width
FW=num2str((PW-Left-Right)/Column-VSpace);

% Recognize the file name
FF=dir([Path '/Graphs_' Image_Format '/*.' Image_Format]);
FF = {FF(:).name}.';
FF=sort(FF);
% Capture the shock list numbers
ShN=unique(cellfun(@(x) x(strfind(x,'S')+1:strfind(x,'_')-1),FF,'UniformOutput',false));
ShN=sort(ShN);
Path=strrep(Path,'\','/');
if strcmp(Image_Format, 'tex')
% Building example file
fid = fopen([Path '/Multi_tex.tex'],'w+');
fprintf(fid,'%s\n','\documentclass[11pt,a4paper]{article}');
fprintf(fid,'%s\n','\usepackage[letterpaper,margin=1.500000cm]{geometry}');
fprintf(fid,'%s\n','\usepackage{pdflscape, booktabs, pgfplots, colortbl, adjustbox, multicol}');
fprintf(fid,'%s\n','\pgfplotsset{compat=1.5.1}\makeatletter');
fprintf(fid,'%s\n','\usepackage{amsmath}');
fprintf(fid,'%s\n','\usepackage{amsfonts}');
fprintf(fid,'%s\n','\usepackage{amssymb}');
fprintf(fid,'%s\n','\usepackage{authblk}');
%fprintf(fid,'%s\n','\usepackage{xepersian}');
%fprintf(fid,'%s\n','\settextfont{XB Niloofar}');
%fprintf(fid,'%s\n','\setlatintextfont{Times New Roman}');
% and optionally (as of Pgfplots 1.3):
fprintf(fid,'%s\n','\pgfplotsset{compat=newest}');
fprintf(fid,'%s\n','\pgfplotsset{plot coordinates/math parser=false}');
fprintf(fid,'%s\n','\newlength\figureheight');
fprintf(fid,'%s\n','\newlength\figurewidth');
fprintf(fid,'%s\n','\begin{document}');
for h=1:length(ShN)
    FF1=FF(cellfun(@(x) strcmp(x(1:7),['S' ShN{h}]),FF));
    if h>1
        fprintf(fid,'%s\n','\newpage');
    end
    fprintf(fid,'%s\n','\centering');
    fprintf(fid,'%s\n','\begin{tabular}[t]{c}');
    fprintf(fid,'%s\n',['\multicolumn{1}{c}{ {\bf Impulse Response to} ', '{\bf', SList{h},'}}\\']);
    fprintf(fid,'%s\n','\multicolumn{1}{c}{');
    
    for iT=1:length(Tmod)
        fprintf(fid,'%s\n',[Tmod{iT} ': ' LinSty{iT} '\quad']);
        % a line break for every 4 file
        if rem(iT,4)==0
            fprintf(fid,'%s\n','} \\  \multicolumn{1}{c}{');
        end
    end
    fprintf(fid,'%s\n','}\\');
    fprintf(fid,'%s\n','\maxsizebox{\textwidth}{!}{');
    fprintf(fid,'%s\n','\setlength\tabcolsep{0em}');
    fprintf(fid,'%s\n','\begin{tabular}[t]{llllllllllllllllllll}');
    
    for i=1:size(FF1,1)
        
        if rem(i,Column)==0
            %fprintf(fid,'%s\n','\newlength\figureheight');
            %fprintf(fid,'%s\n','\newlength\figurewidth');
            fprintf(fid,'%s\n',['\setlength\figureheight{' FH ' cm}']);
            fprintf(fid,'%s\n',['\setlength\figurewidth{' FW ' cm}']);
            fprintf(fid,'%s\n',['\input{Graphs_tex/' FF1{i} '}\\']);
        else
            fprintf(fid,'%s\n',['\setlength\figureheight{' FH ' cm}']);
            fprintf(fid,'%s\n',['\setlength\figurewidth{' FW ' cm}']);
            fprintf(fid,'%s\n',['\input{Graphs_tex/' FF1{i} '}&']);
        end
        if rem(i,Row*Column)==0
            fprintf(fid,'%s\n','\end{tabular}}');
            fprintf(fid,'%s\n','\end{tabular}');
            if size(FF1,1)~=i%i>Row*Column
                
                fprintf(fid,'%s\n','\newpage');
                fprintf(fid,'%s\n','\begin{tabular}[t]{c}');
                fprintf(fid,'%s\n',['\multicolumn{1}{c}{ {\bf Impulse Response to}  ', '{\bf', SList{h},'}}\\']);
                fprintf(fid,'%s\n','\multicolumn{1}{c}{');
                for iT=1:length(Tmod)
                    fprintf(fid,'%s\n',[Tmod{iT} ': ' LinSty{iT} '\quad']);
                    if rem(iT,4)==0
                        fprintf(fid,'%s\n','} \\  \multicolumn{1}{c}{');
                    end
                end
                fprintf(fid,'%s\n','}\\');
                fprintf(fid,'%s\n','\maxsizebox{\textwidth}{!}{');
                fprintf(fid,'%s\n','\setlength\tabcolsep{0em}');
                fprintf(fid,'%s\n','\begin{tabular}[t]{llllllllllllllllllll}');
            end
        end
        
        
    end
    if rem(i,Row*Column)~=0
        fprintf(fid,'%s\n','\end{tabular}}');
        fprintf(fid,'%s\n','\end{tabular}');
    end
end

fprintf(fid,'%s\n','\end{document}');


else
% Building example file
fid = fopen([Path '/Multi_',Image_Format, '.tex'],'w+');
fprintf(fid,'%s\n','\documentclass[11pt,a4paper]{article}');
fprintf(fid,'%s\n','\usepackage[letterpaper,margin=1.500000cm]{geometry}');
fprintf(fid,'%s\n','\usepackage{pdflscape, booktabs, pgfplots, colortbl, adjustbox, multicol}');
fprintf(fid,'%s\n','\pgfplotsset{compat=1.5.1}\makeatletter');
fprintf(fid,'%s\n','\usepackage{amsmath}');
fprintf(fid,'%s\n','\usepackage{amsfonts}');
fprintf(fid,'%s\n','\usepackage{amssymb}');
fprintf(fid,'%s\n','\usepackage{authblk}');
fprintf(fid,'%s\n','\usepackage{epstopdf}');
fprintf(fid,'%s\n','\usepackage{graphicx}');
%fprintf(fid,'%s\n','\setlatintextfont{Times New Roman}');
% and optionally (as of Pgfplots 1.3):
fprintf(fid,'%s\n','\pgfplotsset{compat=newest}');
fprintf(fid,'%s\n','\pgfplotsset{plot coordinates/math parser=false}');
fprintf(fid,'%s\n','\newlength\figureheight');
fprintf(fid,'%s\n','\newlength\figurewidth');
fprintf(fid,'%s\n','\begin{document}');
for h=1:length(ShN)
    FF1=FF(cellfun(@(x) strcmp(x(1:7),['S' ShN{h}]),FF));
    if h>1
        fprintf(fid,'%s\n','\newpage');
    end
    fprintf(fid,'%s\n','\centering');
    fprintf(fid,'%s\n','\begin{tabular}[t]{c}');
    fprintf(fid,'%s\n',['\multicolumn{1}{c}{ {\bf Impulse Response to} ', '{\bf', SList{h},'}}\\']);
    fprintf(fid,'%s\n','\multicolumn{1}{c}{');
    
    for iT=1:length(Tmod)
        fprintf(fid,'%s\n',[Tmod{iT} ': ' LinSty{iT} '\quad']);
        % a line break for every 4 file
        if rem(iT,4)==0
            fprintf(fid,'%s\n','} \\  \multicolumn{1}{c}{');
        end
    end
    fprintf(fid,'%s\n','}\\');
    fprintf(fid,'%s\n','\maxsizebox{\textwidth}{!}{');
    fprintf(fid,'%s\n','\setlength\tabcolsep{0em}');
    fprintf(fid,'%s\n','\begin{tabular}[t]{llllllllllllllllllll}');
    
    for i=1:size(FF1,1)
        
        if rem(i,Column)==0
            %fprintf(fid,'%s\n','\newlength\figureheight');
            %fprintf(fid,'%s\n','\newlength\figurewidth');
            fprintf(fid,'%s\n',['\includegraphics[trim=0cm 0cm 0cm 0cm, clip=true,totalheight=.42\textheight, angle=0]{Graphs_' Image_Format '/' FF1{i} '}\\']);
        else
            fprintf(fid,'%s\n',['\setlength\figureheight{' FH ' cm}']);
            fprintf(fid,'%s\n',['\setlength\figurewidth{' FW ' cm}']);
            fprintf(fid,'%s\n',['\includegraphics[trim=0cm 0cm 0cm 0cm, clip=true,totalheight=.42\textheight, angle=0]{Graphs_' Image_Format '/' FF1{i} '}&']);
        end
        if rem(i,Row*Column)==0
            fprintf(fid,'%s\n','\end{tabular}}');
            fprintf(fid,'%s\n','\end{tabular}');
            if size(FF1,1)~=i%i>Row*Column
                
                fprintf(fid,'%s\n','\newpage');
                fprintf(fid,'%s\n','\begin{tabular}[t]{c}');
                fprintf(fid,'%s\n',['\multicolumn{1}{c}{ {\bf Impulse Response to}  ', '{\bf', SList{h},'}}\\']);
                fprintf(fid,'%s\n','\multicolumn{1}{c}{');
                for iT=1:length(Tmod)
                    fprintf(fid,'%s\n',[Tmod{iT} ': ' LinSty{iT} '\quad']);
                    if rem(iT,4)==0
                        fprintf(fid,'%s\n','} \\  \multicolumn{1}{c}{');
                    end
                end
                fprintf(fid,'%s\n','}\\');
                fprintf(fid,'%s\n','\maxsizebox{\textwidth}{!}{');
                fprintf(fid,'%s\n','\setlength\tabcolsep{0em}');
                fprintf(fid,'%s\n','\begin{tabular}[t]{llllllllllllllllllll}');
            end
        end
        
        
    end
    if rem(i,Row*Column)~=0
        fprintf(fid,'%s\n','\end{tabular}}');
        fprintf(fid,'%s\n','\end{tabular}');
    end
end

fprintf(fid,'%s\n','\end{document}');
end

fclose(fid);
% compili the latex file
CPath=pwd; % Save current address
cd(Path);
disp('Compiling the tex file...');
if ispc
    system(['PDFlatex -synctex=1 -interaction=nonstopmode Multi_',Image_Format, '.tex']);
    system('PDFlatex X');
else
    system(['/usr/texbin/pdflatex -synctex=1 -interaction=nonstopmode ', Path, '/Multi_' ,Image_Format,'.tex']);
    system(['/usr/texbin/pdflatex X']);
end

if exist(['Multi_',Image_Format, '.pdf'],'file')
    open (['Multi_',Image_Format, '.pdf']);
    delete (['Multi_',Image_Format, '.aux'])
    delete (['Multi_',Image_Format, '.log'])
    delete (['Multi_',Image_Format, '.synctex.gz'])
    delete ('IRF_plots.asv')
    delete ('IRF_plots.m~')
    delete *.log
else
    warning('pdf file not found')
end

cd(CPath);
end
function SaveTiles(Ser,VList,SList,Path)
disp('Creating title guid file');
Tbl=dataset();
Tbl.Filenames=fields(Ser);
Tbl.Sock_Order=cellfun(@(x) str2double(x(2:7)),Tbl.Filenames, 'UniformOutput', false);
Tbl.Variable_Order=cellfun(@(x) str2double(x(9:end)),Tbl.Filenames, 'UniformOutput', false);
fls=fields(VList);
for h=1:length(fls)
    Tbl.(['File' num2str(h) '_Variable'])=repmat({''},size(Tbl,1),1);
    Tbl.(['File' num2str(h) '_Shock'])=repmat({''},size(Tbl,1),1);
    for i=1:size(Tbl,1)
        Tbl.(['File' num2str(h) '_Variable'])(i)=VList.(fls{h})(Tbl.Variable_Order{i});
        Tbl.(['File' num2str(h) '_Shock'])(i)=SList.(fls{h})(Tbl.Sock_Order{i});
    end
end
export(Tbl,'xlsfile',[Path '/FileGuide']);

end