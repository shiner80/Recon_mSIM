# Recon_mSIM

Reconstruct mSIM images from sequences of images (mSIM data, in multi-page TIFF format), where a triangular lattice of diffraction limited spots scan the sample.

This code is composed by an FIJI/ImageJ macro and some Matlab scripts and functions.

These routines are basically an implementation in Matlab of the code developed in Python by Andrew G. York [1], with some minor differences on the identification of the lattice offset vectors and on the image rendering, that is instead akin to the approach developed by [2].

__________________
Before using the routines:

* Install the thunderstorm plugin [3] for ImageJ/FiJi: https://zitmen.github.io/thunderstorm/

* Add the folder containing the Matlab code to the Matlab path.

* To run the Imagej macro data needs to be organized in a folder** containing sub-folders*** each with a raw acquisition

	Example:

	mSIM data #1: 'C:/ExptA/SIM_001/SIM_001.tif

	mSIM data #2: 'C:/ExptA/SIM_002/SIM_002.tif
	...

	** no empty spaces in path
	
	*** each subfolder needs to have the string 'SIM' in its name.
__________________

Running the code:

1. Run the imageJ macro: 
The ImageJ macro uses the Thunderstorm plug-in [3] to generate .csv files with the approximate positions of the illumination spots in each of the image of the mSIM movies.

2. type: run recon_mSim_SingleImage.m in Matlab command window.

The code will prompt to input acquisition and reconstruction parameters. Default values usually work, except the 'Threshold for dot identification in FFT' that we usually tune in the range 100 to 500 if the standard value does not work . Additional options allow for a deconvolution step, that requires to load an xy PSF of the mSIM microscope [enabled by default]. A destriping option, that requires to input a mask for the mSIM Fourier Transform is also available [disabled by default]. 

The code will then prompt to load both the raw SIM stack and the .csv file and start to identify lattice vectors, offset vectors and reconstructing the mSIM image.
Output images are saved as 16bit tiffs, normalized for the image maximum. 

The Matlab code use bpass.m and pkfind.m from John C. Crocker and David G. Grier, 1997.  



__________________
References:

[1] York, A.G., Parekh, S.H., Nogare, D.D., Fischer, R.S., Temprine, K., Mione, M., Chitnis, A.B., Combs, C.A., and Shroff, H. (2012). Resolution doubling in live, multicellular organisms via multifocal structured illumination microscopy. Nat Methods 9, 749–754. 10.1038/nmeth.2025.

[2] Schulz, O., Pieper, C., Clever, M., Pfaff, J., Ruhlandt, A., Kehlenbach, R.H., Wouters, F.S., Großhans, J., Bunt, G., Enderlein, J. (2013). Resolution doubling in fluorescence microscopy with confocal spinning-disk image scanning microscopy. Proc Natl Acad Sci U S A. 110(52), 21000-5. 

[3] Ovesný, M., Křížek, P., Borkovec, J., Švindrych Z., and Hagen, G. M. (2014). ThunderSTORM: a comprehensive ImageJ plugin for PALM and STORM data analysis and super-resolution imaging. Bioinformatics 30(16), 2389-2390-


