function Latexmath2mod(input)
% this code is may be ok. but
% * may be noy abailable all the time
% / may be not close
% ^ not
A=fileread(input);

k1=strfind(A,'\[');

k2=strfind(A,'\]');

k=[k1+2;k2-1].';
B='model;';
clear k1 k2
for i=1:size(k,1)
    B=sprintf('%s\n%s',B,Convertor(A(k(i,1):k(i,2))));
end
B=sprintf('%s\n%s',B,'end;');

[C ,C1]=Retriver(B);

B=sprintf('%s\n%s\n\n%s','var',C1,B);
fid=fopen('out.mod','w+');
fprintf(fid,'%s\n',B);
fclose(fid);
end
function C=Convertor(B)
C=B;
repl={ char(10),  char(13),' ','_{t}','_t', '_{t+', '_{t-','\left','\right','\frac','}{' , '{', '}', '[', ']' ,'\',')('; ...
            '' ,       '' ,'' , '{}'   , '' , '{+'  ,'{-'     ,''       ,   ''   ,''     ,')/(', '(', ')', '(', ')' , '',')*('};
for i=1:size(repl,2)
    C = strrep(C, repl{1,i}, repl{2,i});
end

C=matching_parenthesis(C);
%C=Retriver(C);

C=[C ';'];
end
function D=matching_parenthesis(C)
% Remove extra parentese
D=C;
k1=strfind(C,'(');
k2=strfind(C,')');
k=[[k1;ones(1,size(k1,2))],[k2;-1*ones(1,size(k2,2))]];
[~, b]=sort(k(1,:));
k=k(:,b);

for i=1:size(k,2)
    if k(2,i)~=-1
        SS=0;
        for j=i:size(k,2)
            SS=SS+k(2,j);
            if SS==0
                break;
            end
        end
        
        k(2,i)=k(1,j);
        %k(1,j)=0;
    end
end
%Remove closed
k(:,k(2,:)==-1)=[];
% set priority
k(3,:)=k(2,:)-k(1,:);
[~, b]=sort(k(3,:));
k=k(:,b);
k(3,:)=[];
k=k.';
for i=1:size(k,1)
    B=D(k(i,1):k(i,2));
    %     D=strfind(B,{'+','-','^','/'})
    if isempty(regexp(B,'+|-|^|/', 'once'))
        C(k(i,1))=' ';
        C(k(i,2))=' ';
    else
        D(k(i,1):k(i,2))=repmat('A',1,k(i,2)-k(i,1)+1);
    end
end
D=strrep(C, ' ','');
end
function [D, E]=Retriver(C)
C=strrep(C,'^','_');
D = regexp(C,'\w*','match');
%D(cellfun(@(x) isnumeric(x),D))=[];
D(~cellfun('isempty', regexp(D, '^-?\d+$')))=[];
D(1)=[];
D(end)=[];
D=cellfun(@(x) [x ', '],D,'uniformoutput',false);
D=unique(D);
E=D{1};
for i=2:length(D)
    E=[E D{i}];
end
end