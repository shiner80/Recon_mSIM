clear; 
close all;


% SET PARAMETERS
%________________________________________________________________________
PxSize = 108.3; % [nm]
ThresholdDots = 200; % Threshold for identifying dots in the sumFFT image 
                     % adjust to your needs.

Pinhole = 1.2;      %sigma of the gaussian mask for digital pinholing [in pixels]

maxError = 2; % maximal tolerance for identifying harmonics [pixels in scaled image];
NormalizeForEDD = 1; % if = 1 perform normalization to effective detection distribution
displayIntermediateSteps = 0; % if = 1 show some plots during reconstruction
Parameters = [ThresholdDots, maxError, Pinhole, NormalizeForEDD, ...
    displayIntermediateSteps];

nFrames = 224; % Set a number if you want to limit the analysis to a subset of 
               % frames. If left empty the number of frames will be obtained 
               % from the stack.

Deconvolve_Tag = 1; % set to 0 for no Deconvolution
                   % set to 1 for deconvolution using Richardson-Lucy
                   
Decon_iter = 5;     % deconvolution iterations


destripe_Tag = 0; % this option can be turned on if artifactual stripes appear 
                 % on the image. Since stripes with common frequency/orientation 
                 % appear  as a spot in the FFT of an image, this option 
                 % allows to load a mask that is then multiplied to the FFT 
                 % reconstructed image to get rid of specific spatial
                 % frequencies in the image. 

%==========================================================================
% Load Stack and Thunderstorm file
%__________________________________________________________________________
% Note: Thunderstorm files with the approximate positions of the illumination
% spots are generated using Thunderstorm plug in in Fiji
% A macro to generate thunderstorm lists on multiple stacks is provided
% Info on thunderstorm: https://zitmen.github.io/thunderstorm/
% M. Ovesný, P. K?ížek, J. Borkovec, Z. Švindrych,G. M. Hagen. 
% ThunderSTORM: a comprehensive ImageJ plugin for PALM and 
% STORM data analysis and super-resolution imaging. 
% Bioinformatics 30(16):2389-2390, 2014.
%__________________________________________________________________________

% Note 2: Generally we generate the thunderstorm table using the mSIM data
% from the sample itself. However, If the sample is sparse, for example beads
% or bright aggregates, it is advisable to use a uniform sample (a "lake") to
% generate the list of the positions of illumination spots.

%__________________________________________________________________________
[SIMStack_Name, SimStack_Path] = uigetfile('.tif', 'Choose mSIM stack');
[Thunderstorm_Name, Thunderstorm_Path] =...
    uigetfile('.csv', 'Choose Thunderstorm Spot List');


SIMStack = TIFread(fullfile(SimStack_Path, SIMStack_Name));
TS_List = importThunderStormCSV...
    (fullfile(Thunderstorm_Path,Thunderstorm_Name),PxSize);

% =========================================================================
% Reconstruct mSIM Image
[mSIMImage, confocalImage, LatticePL, LatticeVectors, check_SPARSE]=...
    Generate_mSIM_from_Thunderstorm_and_Image...
    (SIMStack, TS_List, Parameters, nFrames);

% reconstruct WF image
WF_Image = generateWF(SIMStack);
%%

% deconvolve using Richardson-Lucy
if Deconvolve_Tag
    [FileNamePSF, PathNamePSF] = ...
        uigetfile('.tif', 'Choose PSF Image for Deconvolution');
    disp("PSF Loaded successfully");
    
    [mSIMImage_DCNV, confocalImage_DCNV] = ...
        DCNV([PathNamePSF FileNamePSF], mSIMImage, ...
        confocalImage, WF_Image, Decon_iter, 0);
end

% Optional FFT filter (destriping)
if destripe_Tag
    [mask_name, mask_path] = uigetfile('.tif','Select mask for FFT');
    Mask_FFT = TIFread([mask_path, mask_name]);
    mSIMImage_FFTmasked = FFTelimination_freq(mSIMImage, Mask_FFT);
    if Deconvolve_Tag
        [mSIMImage_FFTmasked_DCNV, ~] = ...
            DCNV([PathNamePSF FileNamePSF], mSIMImage_DCNV, ...
            confocalImage, WF_Image, Decon_iter, 0);
    end
        
end
%%
% =========================================================================
% Save Images

disp("Saving Images...");

% Save tif of Pseudo-WF
temp = WF_Image;
OutName = '\_Widefield.tif';
imwrite(uint16(temp./max(temp(:)).*2^16-1),[SimStack_Path, OutName],'tiff');



% Save Tiff of Confocal
temp = confocalImage;
OutName = ['\_Confocal_Ph',num2str(Pinhole),'.tif'];
imwrite(uint16(temp./max(temp(:)).*2^16-1),[SimStack_Path, OutName],'tiff');


% Save Tiff of mSIM
temp = mSIMImage;
OutName = ['\_mSIM_Ph',num2str(Pinhole),'.tif'];
imwrite(uint16(temp./max(temp(:)).*2^16-1),[SimStack_Path, OutName],'tiff');

if   Deconvolve_Tag
    
    temp = mSIMImage_DCNV;
    OutName = ['\_mSIM_DCNV_Ph',num2str(Pinhole),'.tif'];
    imwrite(uint16(temp./max(temp(:)).*2^16-1),[SimStack_Path, OutName],'tiff');
    
end

if destripe_Tag
    temp = mSIMImage_FFTmasked;
    OutName = ['\_mSIM_Destriped_Ph',num2str(Pinhole),'.tif'];
    imwrite(uint16(temp./max(temp(:)).*2^16-1),[SimStack_Path, OutName],'tiff');
    
    if Deconvolve_Tag
        temp = mSIMImage_FFTmasked_DCNV;
        OutName = ['\_mSIM_Destriped_DCNV_Ph',num2str(Pinhole),'.tif'];
        imwrite(uint16(temp./max(temp(:)).*2^16-1),[SimStack_Path, OutName],'tiff');
        
    end
end

disp('Done!');
%==========================================================================


     
  
         
    