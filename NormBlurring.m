function [SRESIMAGE_FLAT] = NormBlurring(I, blur)

if max(I(:)) > 2^16-1
    I = uint32(I);
else
    I = uint16(I);
end

% Flat-field image, by dividing image for its blurred version
ImageBlurred = imgaussfilt(I, blur);
SRESIMAGE_FLAT = double(I)./double(ImageBlurred);

disp("Normalization was done!");

end

