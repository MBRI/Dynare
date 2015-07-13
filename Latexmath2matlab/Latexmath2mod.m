function Latex2mod(input)
% this code is may be ok. but 
% * may be noy abailable all the time
% / may be not close
% ^ not 
A=fileread(input);

k1=strfind(A,'\[');

k2=strfind(A,'\]');

k=[k1+2;k2-1].';

clear k1 k2
fid=fopen('out.mod','w+');
for i=1:size(k,1)
    fprintf(fid,'%s\n',Convertor(A(k(i,1):k(i,2))));
end
fclose(fid);
end
function C=Convertor(B)
C=B;
repl={ char(10),  char(13),' ','_{t}','_t', '_{t+1}','\left','\right','\frac','}{' , '{', '}', '[', ']' ,'\',')('; ...
            '' ,       '' ,'' , ''   , '' , '(+1)'  ,''     ,   ''   ,''     ,')/(', '(', ')', '(', ')' , '',')*('};
for i=1:size(repl,2)
    C = strrep(C, repl{1,i}, repl{2,i});
end

C=matching_parenthesis(C);


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