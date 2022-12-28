# Recon_mSIM
Build mSIM image from raw data.
The code renders multispot structured illumination microscopy images, starting from RAW data. 
The code is composed by an ImageJ macro and some Matlab scripts and functions.

Data needs to be organized in a folder* containing sub-folders** each with a raw acquisition (multi-TIF).

Example:
mSIM data #1: 'C:/ExptA/SIM_001/SIM_001.tif
mSIM data #2: 'C:/ExptA/SIM_002/SIM_002.tif

* no empty spaces in path
** each subfolder needs to have the string 'SIM' in its name.

1. Run the imageJ macro: 
The ImageJ macro uses the Thunderstorm plug-in [1] to generate .csv files with the positions of the illumination spots in each of the image of the mSIM movies: one file per acquisition, added to each subfolder.

2. Add the folder containing the Matlab code to the Matlab path.

3. type: run recon_mSim.m in Matlab command window

The Matlab code use bpass.m and pkfind.m from John C. Crocker and David G. Grier, 1997.  






[1] M. Ovesný, P. Křížek, J. Borkovec, Z. Švindrych, G. M. Hagen. ThunderSTORM: a comprehensive ImageJ plugin for PALM and STORM data analysis and super-resolution imaging. Bioinformatics 30(16):2389-2390, 2014.
