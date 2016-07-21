
% this code is a revised version of STRUCTCMP By Javier Lopez-Calderon; email : javlopez@ucdavis.edu
% this make Weight with the same fields and sizes as Calib
% @ Pedram.Davoudi@gmail.com

function [CalibOut, WeightOut,Lvalue] = structcmp2(Calib, Weight, varargin)
%
% Parsing inputs
% S1 is Calib
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('S1');
p.addRequired('S2');
p.addParamValue('Tab', 6, @isnumeric);
p.addParamValue('IgnoreCase', 'off', @ischar);
p.addParamValue('IgnoreSorting', 'off', @ischar);
p.addParamValue('EqualNans', 'off', @ischar);
p.addParamValue('Report', 'off', @ischar);
p.addParamValue('FillWith', 1, @isnumeric); 
% add skip fields option
p.parse(Calib, Weight, varargin{:});
CalibOut=struct();
WeightOut=struct();
if ~isstruct(Calib);error('First input argument is not a structure');end
if ~isstruct(Weight);error('Second input argument is not a structure');end
ntab   = p.Results.Tab;
nS1    = length(Calib);
nS2    = length(Weight);
if nS1~=nS2
    Lout = false;
    fprintf('Structures have different length.\n');
    return
end % check equal length
fnameS1  = fieldnames(Calib);
fnameS2  = fieldnames(Weight);
nfnameS1 = length(fnameS1);
%nfnameS2 = length(fnameS2);
% if nfnameS1~=nfnameS2
%     Lout = false;
%     fprintf('Structures have different amount of fields.\n');
%     return
% end % check equal number of fields
[sortfnameS1, indxS1] = sort(fnameS1);
[sortfnameS2, indxS2] = sort(fnameS1);
if strcmpi(p.Results.IgnoreSorting, 'off') && ~isequal(indxS1, indxS2)
    Lout = false;
    fprintf('Structures have different sorting order.\n');
    return
end % check equal fields' sorting
% if strcmpi(p.Results.IgnoreCase, 'off')
%     if ~isequal(sortfnameS1, sortfnameS2)
%         Lout = false;
%         fprintf('Structures have different field names (case sensitive).\n');
%         return
%     end % check equal field names (case sensitive)
% else
%     if ~isequal(lower(sortfnameS1), lower(sortfnameS2))
%         Lout = false;
%         fprintf('Structures have different field names.\n');
%         return
%     end % check equal field names
% end

Lvalue = true(1,nfnameS1); % default
for kk=1:nfnameS1
    if strcmpi(p.Results.Report, 'on')
        Fcall = dbstack;callnames = {Fcall.name};
        tabstr = blanks(ntab*sum(ismember(callnames, {'structcmp2'}))-1);
    end % check number of recursive calls
    RS1 = Calib.(sortfnameS1{kk});
    if ~isfield(Weight,sortfnameS1{kk})
        Weight.(sortfnameS1{kk})=eval([class(Calib.(sortfnameS1{kk})) '.empty(1,0)']);
    end
    RS2 = Weight.(sortfnameS1{kk});
    if isstruct(RS1) && isstruct(RS2)
        if strcmpi(p.Results.Report, 'on')
            fprintf('%sComparing sub-structures "%s" and "%s" : \n', tabstr, sortfnameS1{kk}, sortfnameS2{kk});
        end % print report
        Lvalue(kk) = structcmp2(RS1, RS2, 'Tab',ntab, 'IgnoreCase', p.Results.IgnoreCase, 'Report', p.Results.Report); % recursive calls in case of substructure
    elseif iscell(RS1) && iscell(RS2)
        if strcmpi(p.Results.Report, 'on')
            fprintf('%sComparing sub-structures "%s" and "%s" : \n', tabstr, sortfnameS1{kk}, sortfnameS2{kk});
        end % print report
        Lvalue(kk)=true;
        [r1, c1]=size(RS1);
        [r2, c2]=size(RS2);
        if r2>r1 ;RS2(r1+1:end,:)=[];end;
        if c2>c1 ;RS2(:,c1+1:end)=[];end;
        if r2<r1 ;RS2(r1,end)={[]};end;
        if c2<c1 ;RS2(end,c1)={[]};end;
        for jj1=1:r1
            for jj2=1:c1
                [RS1{jj1,jj2}, RS2{jj1,jj2}] = Matcmp(RS1{jj1,jj2}, RS2{jj1,jj2},p.Results.FillWith);
            end
        end
        
    else
        if strcmpi(p.Results.Report, 'on')
            fprintf('%sComparing contains of fields %s and %s : \n', tabstr, sortfnameS1{kk}, sortfnameS2{kk});
        end     % print report
        %if strcmpi(p.Results.EqualNans, 'off')
        [RS1, RS2] = Matcmp(RS1, RS2,p.Results.FillWith);
        if ~all(size(RS1)==size(RS2));Lvalue(kk)=false;else Lvalue(kk)=true; end
        %else
        %         if ~isequalwithequalnans(RS1, RS2);Lvalue(kk) = false;else Lvalue(kk)=true;end
        % end % check equal values (including NaNs)
        %    else
        %       if strcmpi(p.Results.Report, 'on')
        %           fprintf('%sComparing %s and %s : \n', tabstr, sortfnameS1{kk}, sortfnameS2{kk});
        %      end % print report
        %      Lvalue(kk) = false;
    end
    if strcmpi(p.Results.Report, 'on')
        if Lvalue(kk); fprintf('\bOk!\n');else fprintf('\bfailed!\n');end % print report
    else
       % if ~Lvalue(kk);break;end
    end
    CalibOut.(sortfnameS1{kk})=RS1;
    WeightOut.(sortfnameS1{kk})=RS2;
end

Lout = all(Lvalue);
end
function [A1, A2] = Matcmp(A1, A2,FillWith)
[r1, c1]=size(A1);
[r2, c2]=size(A2);
if ~all(size(A1)==size(A2))
    if r2>r1
        A2(r1+1:end,:)=[];
    elseif r2<r1
        A2(r2+1:r1,1:c2)=ones(r1-r2,c2).*FillWith;
    end;
    if c2>c1
        A2(:,c1+1:end)=[];
    elseif c2<c1
        A2(1:r1,c2+1:c1)=ones(r1,c1-c2).*FillWith;
    end
end
end