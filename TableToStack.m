function Stack = TableToStack(TableLocs, nFrames, ImageSize)


for iFrame = 1:nFrames
    Stack(iFrame).data = zeros(ImageSize);
    idx = find(TableLocs(:,3)==iFrame);
    for i=1:length(idx)
        Stack(iFrame).data(round(TableLocs(idx(i),2)), ...
            round(TableLocs(idx(i),1))) = 1;
    end
end