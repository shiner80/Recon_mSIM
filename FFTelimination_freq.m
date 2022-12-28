function X = FFTelimination_freq(Image,Mask)

n = unique(size(Image));

xf = fft2(Image);
F = fftshift(xf); % Center FFT
% F = abs(F); % Get the magnitude
% F = log(F+1); % Use log, for perceptual scaling, and +1 since log(0) is undefined
% F = mat2gray(F); % Use mat2gray to scale the image between 0 and 1
% % imagesc(F); colormap('gray')


px = find(Mask.data == 0);
F(px) = 0;

X = ifftshift(F);
X = ifft2(X,n,n,'symmetric');

%imagesc(X); colormap('hot')
end

