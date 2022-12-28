function Outcome = checkConsistency(RawVect, Center, PositionList, MaxError)


nEl = max(2,length(RawVect(:,1)));
[~,Comb_Cell] = combWithRep(RawVect, nEl);
Outcome = 1;
for i = 1: length(Comb_Cell)
    ExpectedPos = Center + sum(Comb_Cell{i});
    Test =  max(sqrt((PositionList(:,1) - ExpectedPos(1)).^2 + (PositionList(:,2) - ExpectedPos(2)).^2)<MaxError);
    Outcome = Outcome*Test;
end
end