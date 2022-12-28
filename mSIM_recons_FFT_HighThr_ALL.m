%% Process mSIM Stack/Thunderstorm FFT method - High Throughput

%% This part of the code if you want to Generate a new mSIM Image, starting from the RAW data and the Thunderstorm derived approximate lattice positions
% Deconvolution and normalization through Gaussian blurring is also
% performed --> please check all the parameters below
%__________________________________________________________________________

clear; 
close all;


% SET PARAMETERS	
PxSize = 108.3; % [nm]
ThresholdDots = 1200; % Threshold for identifying dots in the sumFFT image (needs to be adjusted!).

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


disp("Loading Data...");

for i = 1:length(BigFolder)

    if contains(BigFolder(i).name, name_folders)
        list{1,kk} = fullfile(BigFolder(i).folder, BigFolder(i).name);
        
        smallFolder = dir(fullfile(BigFolder(i).folder, BigFolder(i).name));
           
        for j = 1:length(smallFolder)
            if contains(smallFolder(j).name, name_files)
                Data(kk,:) = TIFread(fullfile(BigFolder(i).folder, BigFolder(i).name, smallFolder(j).name)); % Load Raw Data
                % list2{1,kk} = smallFolder(i).name;
            elseif ~sparse && contains(smallFolder(j).name, 'Table') && ~contains(smallFolder(j).name, 'protocol') % Load Thunderstorm Table
                ThunderS_PL{1,kk} = importThunderStormCSV(fullfile(BigFolder(i).folder, BigFolder(i).name, smallFolder(j).name), PxSize);
            end
        end
        kk = kk+1;
        
    end       
end

nRaw = size(Data, 1);
disp("Data loaded successfully");
 
%Selection of PSF for deconvolution
[FileNamePSF, PathNamePSF] = uigetfile('.tif', 'Choose PSF Image for Deconvolution', foldername, 'Multiselect', 'off');
disp("PSF Loaded successfully");

disp("mSIM Reconstruction is starting...");
i = 1;

% Generate Lattice and sResImages
tic
for j = 1:nRaw
    disp(['Processing Image ' num2str(j) ' of ' num2str(nRaw)]);
    
    if sparse
        [SRESImage{1,j}, confocalImage{1,j}, LatticePL{1,j}, LatticeVectors{1,j}, check_SPARSE{1,j}]=...
        Generate_mSIM_from_Thunderstorm_and_Image(Data(j,:), ThunderS_PL_SPARSE, Parameters, nFrames);
    else
        [SRESImage{1,j}, confocalImage{1,j}, LatticePL{1,j}, LatticeVectors{1,j}]=...
        Generate_mSIM_from_Thunderstorm_and_Image(Data(j,:), ThunderS_PL{1,j}, Parameters, nFrames);
    end
    
    if isempty(SRESImage{1,j})
        disp(['Reconstruction failed for image ' num2str(j) ' of ' num2str(nRaw) ': it will be reconstruct as a SPARSE sample!']);
        SPARSE_Ifound(i,1) = j;
        i = i+1;
    
    end
   
    WFImage{1,j} = generateWF(Data(j,:));
    
    if ~isempty(SRESImage{1,j})
    confocalImage{1,j} = imresize(confocalImage{1,j}, 2);
    SRESImage_NORM{1,j} = NormBlurring(SRESImage{1,j}, gaussBlur); % normalizzazione immagine super-risolta
    clc
    end
    
end

if sparse2
    for j = 1:length(SPARSE_Ifound)
        disp(['Processing SPARSE Image ' num2str(j) ' of ' num2str(length(SPARSE_Ifound))]);
        idj = SPARSE_Ifound(j);
    
        [SRESImage{1,idj}, confocalImage{1,idj}, LatticePL{1,idj}, LatticeVectors{1,idj}, check_SPARSE{1,idj}]=...
            Generate_mSIM_from_Thunderstorm_and_Image(Data(idj,:), ThunderS_PL_SPARSE, Parameters, nFrames);
    
        confocalImage{1,idj} = imresize(confocalImage{1,idj}, 2);
        SRESImage_NORM{1,idj} = NormBlurring(SRESImage{1,idj}, gaussBlur); % normalizzazione immagine super-risolta
    clc
    end
end
toc

% Deconvolution (all samples)
for i = 1:nRaw
    
    disp(['Image ' num2str(i) ' of ' num2str(nRaw)]);
    [SRESImage_deconv{1,i}, confocalImage_deconv{1,i}] = DCNV([PathNamePSF FileNamePSF], SRESImage{1,i}, confocalImage{1,i}, WFImage{1,i}, iter, 0);
    SRESImage_deconv_NORM{1,i} = NormBlurring(SRESImage_deconv{1,i}, gaussBlur); % normalizzazione immagine super-risolta e deconvolta
    
end


% Saving all images
disp("Saving Images...");
for i = 1:nRaw
    
    % SaveTiffofConfocal
    temp = confocalImage{1,i};
    if NormalizeForEDD
        OutName = ['\Confocal_EED_Ph',num2str(Pinhole),'.tif'];
    else
        OutName = ['\_Confocal_Ph',num2str(Pinhole),'.tif'];
    end
    imwrite(uint16(temp./max(temp(:)).*2^16-1),[list{1,i}, OutName],'tiff');
    

    % SaveTiffofSRES
    temp = SRESImage{1,i};
    if NormalizeForEDD
        OutName = ['\mSIM_SRes_EED_Ph',num2str(Pinhole),'.tif'];
    else
        OutName = ['\mSIM_Ph',num2str(Pinhole),'.tif'];
    end
    imwrite(uint16(temp./max(temp(:)).*2^16-1),[list{1,i}, OutName],'tiff');
    
    
    % SaveTiffofSRES_Deconvolution
    temp = SRESImage_deconv{1,i};
    if NormalizeForEDD
        OutName = ['\mSIM_EED_SRes_DECONV_Ph',num2str(Pinhole),'.tif'];
    else
        OutName = ['\mSIM_Ph',num2str(Pinhole),'.tif'];
    end
    imwrite(uint16(temp./max(temp(:)).*2^16-1),[list{1,i}, OutName],'tiff');
    

    % SaveTiffofWidefield
    temp = WFImage{1,i};
    if NormalizeForEDD
        OutName = ['\mSIM_WF.tif'];
    else
        OutName = ['\mSIM_WF.tif'];
    end
    imwrite(uint16(temp./max(temp(:)).*2^16-1),[list{1,i}, OutName],'tiff');
    
    
     % SaveTiffofSRES_Deconv_Normalized
    temp = SRESImage_deconv_NORM{1,i};
    if NormalizeForEDD
        OutName = ['\_mSIM_EED_SRes_Deconv_Norm_Ph',num2str(Pinhole),'.tif'];
    else
        OutName = ['\_mSIM_SRes_Deconv_Norm_Ph',num2str(Pinhole),'.tif'];
    end
    imwrite(uint16(temp./max(temp(:)).*2^16-1),[list{1,i}, OutName],'tiff');
    
      
     % SaveTiffofSRES_Normalized
    temp = SRESImage_NORM{1,i};
    if NormalizeForEDD
        OutName = ['\_mSIM_EED_SRes_onlyNorm_Ph',num2str(Pinhole),'.tif'];
    else
        OutName = ['\_mSIM_SRes_onlyNorm_Ph',num2str(Pinhole),'.tif'];
    end
    imwrite(uint16(temp./max(temp(:)).*2^16-1),[list{1,i}, OutName],'tiff');
end

disp("All images were saved successfully");

% SaveWorkspace in BigFolder
OutName =  '\LatticeVariables.mat';
save([foldername, OutName], 'Parameters', 'LatticeVectors', 'LatticePL', 'BigFolder', 'list', 'PathNamePSF');
disp('I FINISHED! CONTINUE WITH STEP 3...BYE!')