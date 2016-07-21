
function out = struct2vec(strc,field,col)
if nargin<3
    col=1;
end
if nargin<2
    field=fieldnames(strc);
end

names = fieldnames(strc);
strcCell = struct2cell(strc);
out=[];
for i=1:length(field)
    index = find(strcmp(names,field{i}),1);
    outC = strcCell(index,:,col);
    if isa(outC,'struct')
        outC=struct2vec(outC);
    elseif  isa(outC,'cell')
        outC=cell2vec(outC);
    elseif isa(outC,'double')
        outC=reshape(outC,[],1);
    else
        warning('unexpected class removed.');
        outC=[];
    end
    out=[out;outC];
end
end
function out = cell2vec(A)
B=A{:};
if isa(B,'cell')
    outA=[];
    for j1=1:size(B,1)
        for j2=1:size(B,2)
            outA=[outA;cell2vec(B(j1,j2))];
        end
    end
    B=outA;
end
out=reshape(B,[],1);
end