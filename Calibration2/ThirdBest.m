function Opt=ThirdBest(Calib,Weight,itrS,itr,VarId)
MaxSize=1000;
% Clibration Vaues
V0=[reshape(Calib.Var,[],1); ...
    reshape(Calib.ACorr,[],1); ...
    reshape(Calib.SS,[],1); ...
    reshape(Calib.Mean,[],1)];
% Weight Matrix
W0=[reshape(Weight.Var,[],1); ...
    reshape(Weight.ACorr,[],1); ...
    reshape(Weight.SS,[],1); ...
    reshape(Weight.Mean,[],1)];

% Load data files
%F=dir('.temp/Itr*.mat');
%F={F.name};
Res=struct();
% Number of fields
NF=itr-itrS+1;%
h=min(itrS+MaxSize,NF);
NF1=itrS;
while(1)
    V=V0;
    W=W0;
    for i=NF1:h
        try
        load(['.temp/Itr' num2str(i)]);
        
        Res.(['Itr' num2str(i)])=Itr;
        %Res.(['Itr' num2str(i)]).I=i; % Chain to .temp
        clear Itr;
        end
    end
    
    Fld=fields(Res);
   if ~isempty(Fld)
    for i=NF1:h
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
    %if length(min(V))>1
    %    warning('More than one solution found.');
    %end
    %V(V~=min(V))=nan;
    %V(V==min(V))=1;
    
    Fld(V==min(V))=[];
    Res=rmfield(Res,Fld);
   end
    if h==NF
        break;
    else
        NF1=h+1;
    end
    h=MaxSize+NF;
    if h>NF
        h=NF;
    end
end
Fld=fields(Res);
if isempty(Fld)
    Opt=nan;
else
Opt=Res.(Fld{1}).P(VarId);
end

end