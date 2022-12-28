clear; 
close all;


% SET PARAMETERS	
PxSize = 108.3; % [nm]
ThresholdDots = 200; % Threshold for identifying dots in the sumFFT image (needs to be adjusted!).

Pinhole = 1.2;

maxError = 2; % maximal tolerance for identifying harmonics [pixels in scaled image];
NormalizeForEDD = 1; % if = 1 perform normalization to effective detection distribution
displayIntermediateSteps = 0; % if = 1 show some plots during reconstruction
Parameters = [ThresholdDots, maxError, Pinhole, NormalizeForEDD, displayIntermediateSteps];

nFrames = 224; % Set a number if you want to limit the analysis to a subset of frames
               % if left empty the number of frames will be obtained from
               % the stack.
               
iter = 5; % deconvolution iterations

gaussBlur = 40; % std for gaussian blurring in normalization

% Folders and files names --> change if necessary (according to your
% experiment nominatives)
name_folders = 'SIM';
name_files = 'SIM';


% PROGRAM START
foldername = uigetdir("Choose folder with ALL mSIM data"); % selezionare la cartella complessiva con i file SIM
% una volta selezionata la cartella, lo script importerà automaticamente le
% raw images mSIM e le tabelle corrispondenti

BigFolder = dir(foldername);
kk = 1;

prompt = 'Is the sample SPARSE? Y/N [Y]: '; % se il campione è sparso (beads o campioni con spot mal distribuiti o con poco segnale) 
% viene richiesta una tabella STORM di riferimento (usare tabella di un Lake oppure di una cellula con un buon segnale) 
str = input(prompt,'s');
if isempty(str)
    str = 'Y';
end

if str == 'Y'
    sparse = 1;
else
    sparse = 0;
end

if ~sparse % se nelle acquisizioni c'è un campione sparso (spot mal distribuiti o con poco segnale per cui non riesce a trovare gli spot o a fare il
    % check di consistenza), viene richiesta una tabella STORM di riferimento --> usare tabella di un Lake oppure di una cellula con un buon segnale 
    prompt = 'If I found them, do you want to reconstruct also those SPARSE samples? Y/N [Y]: '; 
    str = input(prompt,'s');
    if isempty(str)
    	str = 'Y';
    end
    
    if str == 'Y'
        sparse2 = 1;
    else
        sparse2 = 0;
    end

    if sparse2
        [TableName, TablePath] = uigetfile('.csv', 'Select ThunderSTORM Table for SPARSE sample');
        ThunderS_PL_SPARSE = importThunderStormCSV([TablePath,TableName], PxSize);
    end
end


%Selection of PSF for deconvolution
[FileNamePSF, PathNamePSF] = uigetfile('.tif', 'Choose PSF Image for Deconvolution', foldername, 'Multiselect', 'off');
disp("PSF Loaded successfully");


%Selection of mask for FFT elimination
[mask_name, mask_path] = uigetfile('.tif','Select mask for FFT');
Mask_FFT = TIFread([mask_path, mask_name]);
disp("mSIM Reconstruction is starting...");

BigFolder(1:2) = [];
j = 1;

for i = 1:length(BigFolder) %BIG CYCLE
    
    disp(['Processing Image ' num2str(i) ' of ' num2str(length(BigFolder))]);

    if contains(BigFolder(i).name, name_folders)
        list = fullfile(BigFolder(i).folder, BigFolder(i).name);
        
        smallFolder = dir(fullfile(BigFolder(i).folder, BigFolder(i).name));
           
        for j = 1:length(smallFolder)
            if contains(smallFolder(j).name, name_files)
                Data = TIFread(fullfile(BigFolder(i).folder, BigFolder(i).name, smallFolder(j).name)); % Load Raw Data
                % list2{1,kk} = smallFolder(i).name;
            elseif ~sparse && contains(smallFolder(j).name, 'Table') && ~contains(smallFolder(j).name, 'protocol') % Load Thunderstorm Table
                ThunderS_PL = importThunderStormCSV(fullfile(BigFolder(i).folder, BigFolder(i).name, smallFolder(j).name), PxSize);
            end
        end
        %kk = kk+1;
        
    end
    
    disp('Data Loaded...');
    
    if sparse
        [SRESImage, confocalImage, LatticePL, LatticeVectors, check_SPARSE]=...
        Generate_mSIM_from_Thunderstorm_and_Image(Data, ThunderS_PL_SPARSE, Parameters, nFrames);
    else
        [SRESImage, confocalImage, LatticePL, LatticeVectors]=...
        Generate_mSIM_from_Thunderstorm_and_Image(Data, ThunderS_PL, Parameters, nFrames);
    end
    
    if isempty(SRESImage)
        disp(['Reconstruction failed for image ' num2str(i) ' of ' num2str(length(BigFolder)) ': it will be reconstruct as a SPARSE sample!']);
        SPARSE_Ifound(j,1) = i;
        j = j+1;
    
    end
   
    WFImage = generateWF(Data);
    
    if ~isempty(SRESImage)
    confocalImage = imresize(confocalImage, 2);
    SRESImage_NORM = NormBlurring(SRESImage, gaussBlur); % normalizzazione immagine super-risolta
    end    
        
    disp(['Deconvolution of Image ' num2str(i) ' of ' num2str(length(BigFolder))]);
    [SRESImage_deconv, confocalImage_deconv] = DCNV([PathNamePSF FileNamePSF], SRESImage, confocalImage, WFImage, iter, 0);
    SRESImage_deconv_NORM = NormBlurring(SRESImage_deconv, gaussBlur); % normalizzazione immagine super-risolta e deconvolta
    
    SRESImage_deconv_FFT = FFTelimination_freq(SRESImage_deconv, Mask_FFT);  
    SRESImage_deconv_FFT_Norm = NormBlurring(SRESImage_deconv_FFT, gaussBlur);
    
    disp("Saving Images...");
    % SaveTiffofConfocal
    temp = confocalImage;
    if NormalizeForEDD
        OutName = ['\Confocal_EED_Ph',num2str(Pinhole),'.tif'];
    else
        OutName = ['\_Confocal_Ph',num2str(Pinhole),'.tif'];
    end
    imwrite(uint16(temp./max(temp(:)).*2^16-1),[list, OutName],'tiff');
    

    % SaveTiffofSRES
    temp = SRESImage;
    if NormalizeForEDD
        OutName = ['\mSIM_SRes_EED_Ph',num2str(Pinhole),'.tif'];
    else
        OutName = ['\mSIM_Ph',num2str(Pinhole),'.tif'];
    end
    imwrite(uint16(temp./max(temp(:)).*2^16-1),[list, OutName],'tiff');
    
    
    % SaveTiffofSRES_Deconvolution
    temp = SRESImage_deconv;
    if NormalizeForEDD
        OutName = ['\mSIM_EED_SRes_DECONV_Ph',num2str(Pinhole),'.tif'];
    else
        OutName = ['\mSIM_Ph',num2str(Pinhole),'.tif'];
    end
    imwrite(uint16(temp./max(temp(:)).*2^16-1),[list, OutName],'tiff');
    
    % SaveTiffofSRES_Deconvolution without freq stripes
    temp = SRESImage_deconv_FFT;
    if NormalizeForEDD
        OutName = ['\mSIM_EED_SRes_DECONV_FFT_Ph',num2str(Pinhole),'.tif'];
    else
        OutName = ['\mSIM_Devonv_FFT_Ph',num2str(Pinhole),'.tif'];
    end
    imwrite(uint16(temp./max(temp(:)).*2^16-1),[list, OutName],'tiff');
    
    % SaveTiffofSRES_Deconvolution Normalized withou freq stripes
    temp = SRESImage_deconv_FFT_Norm;
    if NormalizeForEDD
        OutName = ['\mSIM_EED_SRes_DECONV_FFT_Norm_Ph',num2str(Pinhole),'.tif'];
    else
        OutName = ['\mSIM_Devonv_FFT_Norm_Ph',num2str(Pinhole),'.tif'];
    end
    imwrite(uint16(temp./max(temp(:)).*2^16-1),[list, OutName],'tiff');
    

    % SaveTiffofWidefield
    temp = WFImage;
    if NormalizeForEDD
        OutName = ['\mSIM_WF.tif'];
    else
        OutName = ['\mSIM_WF.tif'];
    end
    imwrite(uint16(temp./max(temp(:)).*2^16-1),[list, OutName],'tiff');
    
    
     % SaveTiffofSRES_Deconv_Normalized
    temp = SRESImage_deconv_NORM;
    if NormalizeForEDD
        OutName = ['\_mSIM_EED_SRes_Deconv_Norm_Ph',num2str(Pinhole),'.tif'];
    else
        OutName = ['\_mSIM_SRes_Deconv_Norm_Ph',num2str(Pinhole),'.tif'];
    end
    imwrite(uint16(temp./max(temp(:)).*2^16-1),[list, OutName],'tiff');
    
      
     % SaveTiffofSRES_Normalized
    temp = SRESImage_NORM;
    if NormalizeForEDD
        OutName = ['\_mSIM_EED_SRes_onlyNorm_Ph',num2str(Pinhole),'.tif'];
    else
        OutName = ['\_mSIM_SRes_onlyNorm_Ph',num2str(Pinhole),'.tif'];
    end
    imwrite(uint16(temp./max(temp(:)).*2^16-1),[list, OutName],'tiff');
    
    disp("All images were saved successfully");

    
    % SaveWorkspace in each subfolder
    OutName =  '\LatticeVariables.mat';
    save([list, OutName], 'Parameters', 'LatticeVectors', 'LatticePL', 'BigFolder', 'list', 'PathNamePSF');
    
    clear Data ThunderS_PL SRESImage_NORM SRESImage_deconv_NORM WFImage SRESImage_deconv_FFT_Norm
    clear SRESImage_deconv_FFT SRESImage_deconv SRESImage confocalImage
    
    clc  
    
    
end








