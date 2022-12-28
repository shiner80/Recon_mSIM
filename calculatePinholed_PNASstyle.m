function [confocalImage, confocalWeight,SRESImage, SRESWeight] = calculatePinholed_PNASstyle(Stack, PL, PinholeSize,nmax)


% Scale the Particle List x-y position by a factor 10.
PL(:,1:2) = round(PL(:,1:2)*10);

nPoints = length(PL(:,1));
if nmax<nPoints
    PL(nmax:end,:) = [];
end
confocalImage = zeros(size(Stack(1).data)*10);
confocalWeight = zeros(size(confocalImage));

SRESImage = zeros(size(Stack(1).data)*20);
SRESWeight = zeros(size(SRESImage));

% Gaussian Mask over a window size equal to 3 times the pinhole size
windowSize = 3*round(PinholeSize*10);
mask = fspecial('gaussian', windowSize*2+1, PinholeSize*10);
mask = mask.*10^4;


for z = 1:max(PL(:,3))
    
    disp(['Processing Frame: ',num2str(z)]);
    Image = double(Stack(z).data);
    % Scale Image by a factor 10
    SizedUpImage =imresize(Image,10,  'AntiAliasing',false, 'method','bilinear'); 
    
    idx = find(PL(:,3) == z);
    for i =1:length(idx)
    x = PL(idx(i),1);
    y = PL(idx(i),2);
    ylist= y-windowSize:y+windowSize;
    xlist= x-windowSize:x+windowSize;
    
   
    
    ylistDoubled =2*y-windowSize:2*y+windowSize;
    xlistDoubled = 2*x-windowSize:2*x+windowSize;
    Crop = SizedUpImage(ylist,xlist);
    Apertured_Image = Crop.*mask;
    confocalImage(ylist,xlist) = confocalImage(ylist,xlist)+Apertured_Image;
    SRESImage(ylistDoubled,xlistDoubled) = SRESImage(ylistDoubled,xlistDoubled)+Apertured_Image;
    SRESWeight(ylistDoubled,xlistDoubled) = SRESWeight(ylistDoubled,xlistDoubled)+mask;
    confocalWeight(ylist,xlist) = confocalWeight(ylist,xlist)+mask;
    

    
    end
    
%         if z == 224
%         imwrite(uint16(imresize(SRESImage,0.1)), [num2str(i),'.tif']);
%         imwrite(uint16(imresize(SRESWeight,0.1)), [num2str(i),'_weight.tif']);
%     end

end


 SRESImage = imresize(SRESImage,0.1, 'AntiAliasing',false, 'method','bilinear');
 confocalImage =imresize(confocalImage,0.1,  'AntiAliasing',false, 'method','bilinear');
 SRESWeight = imresize(SRESWeight,0.1,  'AntiAliasing',false, 'method','bilinear');
 confocalWeight = imresize(confocalWeight,0.1,  'AntiAliasing',false, 'method','bilinear');