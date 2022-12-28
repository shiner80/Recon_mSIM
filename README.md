# Recon_mSIM
Build mSIM image from raw data.
The code renders multispot structured illumination microscopy images, starting from RAW data. 
The code is composed by an ImageJ macro: Storm_PositionsTables_Lake+Samples_autom.ijm and some Matlab scripts and functions.

The ImageJ macro that uses the Thunderstorm plug-in [1] to generate .csv files with the positions of the illumination spots in each of the image of the mSIM movies. 
The Matlab files load the movies and the .csv files positions to reconstruct an mSIM image.

Data needs to be organized in a folder containing folders each with a raw acquisition (multi-TIF).

** each subfolder needs to have SIM in its name.

*** no empty spaces in path




[1] M. Ovesný, P. Křížek, J. Borkovec, Z. Švindrych, G. M. Hagen. ThunderSTORM: a comprehensive ImageJ plugin for PALM and STORM data analysis and super-resolution imaging. Bioinformatics 30(16):2389-2390, 2014.
