function offsetVector = getOffsetVector(Image, RealLattice, RealVector, ImageSize)

% Average the image around lattice points

idx = find(RealLattice(:,1)< ImageSize/5| RealLattice(:,1)>ImageSize*4/5 |...
    RealLattice(:,2)<ImageSize/5 | RealLattice(:,2)>ImageSize*4/5);
RealLattice(idx,:) = [];
windowSize=round(max(RealVector(:)));
sumCrop = zeros(2*windowSize +1);
for i = 1:length(RealLattice)

    Crop = getShiftedSubImage(RealLattice(i,:),windowSize,Image);
    sumCrop = sumCrop+Crop;
end


% find brightest pixel
[~, Index]=sort(sumCrop(:),'descend');
[yMax,xMax] =ind2sub(size(sumCrop),Index);
idx = find(yMax>4&yMax<2*windowSize-2&xMax>4&xMax<2*windowSize-2, 1);
yMax = yMax(idx);
xMax = xMax(idx);
% refine position
smallCrop = sumCrop(yMax-3:yMax+3, xMax-3:xMax+3);
x_par = polyfit([-3:3],smallCrop(4,:),2);
y_par = polyfit([-3:3],smallCrop(:,4)',2);
xCorr = - x_par(2)/(2*x_par(1));
yCorr = - y_par(2)/(2*y_par(1));

offsetVector = [xMax + xCorr - (windowSize +1) ,yMax + yCorr - (windowSize +1)];


    



