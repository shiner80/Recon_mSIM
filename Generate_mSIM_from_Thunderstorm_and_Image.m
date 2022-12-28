function [SRESImage, confocalImage, LatticePL, LatticeVectors, check_SPARSE]=...
    Generate_mSIM_from_Thunderstorm_and_Image(Data, ThunderS_PL, Parameters, nFrames)

% Generate_mSIM_from_Thunderstorm_and_Image, reconstructs an mSIM image
% starting from an mSIM acquisition, and the rough positions of the
% illumination points as estimated running ThunderStorm on the acquisition.
% The algorithm identifies the most likely lattice vectors to convert 
% the noisy positions of the illumination patterns into a regular pattern, as
% described in York et al., Nat Meth. 2012. For each frame of the
% acquisition an offset vector is calculated, in order to align the lattice
% to the pattern. After defining the positions of the illumination dots in
% each frame the SIM reconstruction is performed as described in Schultz et
% al., PNAS 2013. The code provides the option to normalize the image for
% the effective detection distribution (EDD), that accounts for the possibility
% that different regions of the image can be probed more frequently than
% others, due to 'noise' in the positioning of the illumination dots. We
% find that such normalization is crucial for obtaining images without
% artefactual patterns.
%__________________________________________________________________________
% Input:
%Data: the mSim stack
%ThunderS_PL: Rough estimation of the position of the illumination points
%             obtained using thunderstorm
% Parameters: List of parameters to reconstruct the image:
% Parameters(1): ThresholdDots, Threshold for detecting dots in the FFT
%                image
% Parameters(2): maxError: Tolerance in looking for harmonics [pixels]
% Parameters(3): Pinhole, size of the digital pinhole [pixels]
% Parameters(4): NormalizeFlag, if equal to 1 performs EDD normalization
% Parameters(5): displayIntermediateSteps, if equal to 1 plots stuff
%__________________________________________________________________________
% Output:
% SRESImage: Resulting mSIM image;
% confocalImage: Resulting confocal image;
% LatticePL: frame by frame positions of the illumination points;
% LatticeVectors: BaseVectors (in real space) for the generation of the
%                 0-offset lattice
%__________________________________________________________________________

% Read in Parameters
ThresholdDots = Parameters(1);
maxError = Parameters(2);
Pinhole = Parameters(3);
NormalizeFlag = Parameters(4);
displayIntermediateSteps = Parameters(5);

% Estimate image size.

if isempty(nFrames)
    nFrames = length(Data);
end
if Data(1).width ~= Data(1).height
    error('This routine works only with square images!');
end
ImageSize = Data(1).height;

% Convert Thunderstorm PositionList to image (that has 1 in pixels where
% an illumination point is found);
PL_map = TableToStack(ThunderS_PL, nFrames, ImageSize);
% Calculate Fourier transform for each frame and their sum 
[~,FFTsum] = generateLatticeFFT(PL_map, nFrames, ImageSize);

% find dots in FFTsum image
% band pass filter (via bpass) with 1 and 3 as lower and higher limit), 
% and then local maxima identification via pkfnd
PL_fft = pkfnd (bpass(FFTsum,1,3),ThresholdDots,5);

if isempty(PL_fft)
    check_SPARSE = 0;
else 
    check_SPARSE = 1;
end

if displayIntermediateSteps
    figure;
    imagesc(FFTsum)
    colormap('gray');
    hold on;
    plot(PL_fft(:,1), PL_fft(:,2),'or');
    title('Sum FFT lattice')

waitforbuttonpress();
close(gcf);
end

if check_SPARSE
% Find Base Vectors in the fourier space
FourierVectors = findBaseVectors(PL_fft, FFTsum, ImageSize, maxError);


if displayIntermediateSteps
    figure;
    imagesc(FFTsum)
    colormap('gray');
    hold on;
    plot(PL_fft(:,1), PL_fft(:,2),'or');
    title('Sum FFT lattice - Base Vectors')
    plot([ImageSize/2+1, ImageSize/2+1 + FourierVectors(1,1)], ...
        [ImageSize/2+1, ImageSize/2+1 + FourierVectors(1,2)],'g')
    plot([ImageSize/2+1, ImageSize/2+1 + FourierVectors(2,1)], ...
        [ImageSize/2+1, ImageSize/2+1 + FourierVectors(2,2)],'b')
    waitforbuttonpress()
    close(gcf);
end


% calculate Lattice vectors in real space
[RealLattice0, LatticeVectors] = getRealLatticeFromFFTVectors(FourierVectors,ImageSize);


if displayIntermediateSteps
    % calculate the offset vector for the first step and display the lattice
    % with and without offset
    offsetVector = getOffsetVector(double(Data(1).data), RealLattice0, LatticeVectors, ImageSize);
    RealLattice_Offset0 = getRealLatticeFromRealVectors(LatticeVectors,offsetVector, ImageSize);
    figure;
    imagesc(PL_map(1).data);
    hold on;
    plot(RealLattice0(:,1), RealLattice0(:,2),'or');
    plot(RealLattice_Offset0(:,1), RealLattice_Offset0(:,2),'og');
    waitforbuttonpress()
    title('Real Lattice - 1st Frame')
    close(gcf);
end


% Calculate Lattice for every frame 
LatticePL = [];

for i=1:nFrames
    disp(['Calculating Offset Vector for frame ', num2str(i)]);
    offsetVector = getOffsetVector(double(Data(i).data), RealLattice0, LatticeVectors, ImageSize);
    Lattice_temp = getRealLatticeFromRealVectors(LatticeVectors,offsetVector, ImageSize);
    Lattice_temp(:,3) = i;
    LatticePL = [LatticePL;Lattice_temp];
end

% Generate Confocal and mSIM image
nmax = Inf;


% exclude lattice points within 9 pixels from border

idx = find(LatticePL(:,1) <9|...
    LatticePL(:,1)>Data(1).width - 9|...
    LatticePL(:,2) <9| LatticePL(:,2)>Data(1).height - 9);
LatticePL(idx,:) = [];

% tic
[confocalImage, confocalWeight,SRESImage, SRESWeight] = calculatePinholed_PNASstyle(Data, LatticePL, Pinhole,nmax);
% toc

% Normalize images to their EDD if NormalizeFlag = 1
if NormalizeFlag == 1
    confocalImage = confocalImage./confocalWeight.*mean(confocalWeight(:));
    SRESImage = SRESImage./SRESWeight.*mean(SRESWeight(:));
end

else
    SRESImage = [];
    confocalImage = [];
    LatticePL = [];
    LatticeVectors = [];
end  



end
    




