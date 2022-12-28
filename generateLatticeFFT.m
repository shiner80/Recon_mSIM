function [FFT,FFTsum] = generateLatticeFFT(Stack, nFrames, ImageSize)

FFTsum = zeros(ImageSize);

for iFrame = 1:nFrames
    
    FFT(iFrame).data = abs(fftshift(fft2(Stack(iFrame).data,ImageSize,ImageSize)));
    FFTsum = FFTsum + FFT(iFrame).data;
end