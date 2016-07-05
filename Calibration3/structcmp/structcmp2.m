
% STRUCTCMP True if two structures are equal.
%     STRUCTCMP(A,B) returns logical 1 (TRUE) if structure A and B are the same
%     size, contain the same field names (case sensitive), same field sorting, and same values;
%     and logical 0 (FALSE) otherwise.
%
%     If A is defined and you set B = A, STRUCTCMP(A,B) is not necessarily
%     true. If A's or B's field contains a NaN (Not a Number) element, STRUCTCMP returns
%     false because NaNs are not equal to each other by definition. To considers NaN values to be equal
%     use STRUCTCMP(A,B, 'EqualNans', 'on')
%
%     The order in which the fields of each structure were created is important. To ignore the field
%     sorting use STRUCTCMP(A,B, 'IgnoreSorting', 'on')
%
%     Field names comparison is case sensitive. To ignore any differences in letter case use
%     STRUCTCMP(A,B, 'IgnoreCase', 'on')
%
%     STRUCTCMP(A,B, 'Report', 'on') displays a report on the command window
%
%     See also isequal, isequalwithequalnans, eq.
%
% Author: Javier Lopez-Calderon
% email : javlopez@ucdavis.edu
% Davis, CA
% 2013
%
% 12-Sep-2013: JLC -  Added error msg when any input is not a structure.
% 12-Sep-2013: JLC -  When report is 'on' the checking loop continues until the last field (does not use "break")

function Lout = structcmp2(Calib, S2, varargin)
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
% add skip fields option
p.parse(Calib, S2, varargin{:});

if ~isstruct(Calib);error('First input argument is not a structure');end
if ~isstruct(S2);error('Second input argument is not a structure');end
ntab   = p.Results.Tab;
nS1    = length(Calib);
nS2    = length(S2);
if nS1~=nS2
    Lout = false;
    fprintf('Structures have different length.\n');
    return
end % check equal length
fnameS1  = fieldnames(Calib);
fnameS2  = fieldnames(S2);
% nfnameS1 = length(fnameS1);
% nfnameS2 = length(fnameS2);
% if nfnameS1~=nfnameS2
%     Lout = false;
%     fprintf('Structures have different amount of fields.\n');
%     return
% end % check equal number of fields
[sortfnameS1 indxS1] = sort(fnameS1);
[sortfnameS2 indxS2] = sort(fnameS1);
if strcmpi(p.Results.IgnoreSorting, 'off') && ~isequal(indxS1, indxS2)
    Lout = false;
    fprintf('Structures have different sorting order.\n');
    return
end % check equal fields' sorting
if strcmpi(p.Results.IgnoreCase, 'off')
    if ~isequal(sortfnameS1, sortfnameS2)
        Lout = false;
        fprintf('Structures have different field names (case sensitive).\n');
        return
    end % check equal field names (case sensitive)
else
    if ~isequal(lower(sortfnameS1), lower(sortfnameS2))
        Lout = false;
        fprintf('Structures have different field names.\n');
        return
    end % check equal field names
end
Lvalue = true(1,nfnameS1); % default
for kk=1:nfnameS1
    if strcmpi(p.Results.Report, 'on')
        Fcall = dbstack;callnames = {Fcall.name};
        tabstr = blanks(ntab*sum(ismember(callnames, {'structcmp'}))-1);
    end % check number of recursive calls
    RS1 = Calib.(sortfnameS1{kk});
    RS2 = S2.(sortfnameS2{kk});
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
        if ~all(size(RS1)==size(RS2))
            Lvalue(kk)=false;
        else
            for jj1=1:size(RS1,1)
                for jj2=1:size(RS1,2)
                    if ~all(size(RS1(jj1,jj2))==size(RS2(jj1,jj2)))
                        Lvalue(kk)=false;
                    end
                end
            end
            
        end
        
    else
        if strcmpi(p.Results.Report, 'on')
            fprintf('%sComparing contains of fields %s and %s : \n', tabstr, sortfnameS1{kk}, sortfnameS2{kk});
        end     % print report
        %if strcmpi(p.Results.EqualNans, 'off')
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
        if ~Lvalue(kk);break;end
    end
end
Lout = all(Lvalue);

