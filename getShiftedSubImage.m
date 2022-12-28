function Crop = getShiftedSubImage(Position,windowSize,Image)

% Note: this function crops an image around a - not necessary integer -
% position. In order to do so, it first identify the closer pixel to the
% position, and generates a crop with size 2*windowSize + 1 centered around
% this position. Then it interpolates the image so that in the "new crop" the position of interest
% maps to the central pixel

roundPos = round(Position);
Shift = -Position+roundPos;
Crop = Image(roundPos(2)-windowSize:roundPos(2)+windowSize, ...
    roundPos(1)-windowSize:roundPos(1)+windowSize);
Crop = imtranslate(Crop, Shift);
