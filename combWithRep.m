function [comb_indexes,Comb_Cell] = combWithRep(RawVect, nEl)
nVect = length(RawVect(:,1));
nCells =factorial(nVect+nEl - 1)/(factorial(nEl)*factorial(nVect-1));
Comb_Cell = cell(nCells,1);


comb_indexes = unique(sort(nchoosek(repmat(1:nVect,1,nEl),nEl),2),'rows'); %weird way for finding combination of indexes
for i = 1:nCells
    Comb_Cell{i}= [RawVect(comb_indexes(i,1),:);RawVect(comb_indexes(i,2),:)];
end
end