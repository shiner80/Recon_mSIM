// La macro avvia l'analisi ThunderSTORM sulle immagini acquisite con la mSIM (raw e lake) per ottenere le posizioni dei singoli spot ad ogni frame. 
// Nella cartella globale occorre avere le cartelle relative alle raw-images e ai lake e nel nome delle cartelle deve esserci la parola "SIM" e "Lake", rispettivamente.
// Le posizioni degli spot vengono salvati come file CSV per poi essere caricati nel programma Matlab per la ricostruzione

// Per la detection degli spot vengono utlizzate due soglie diverse: 2*std() per le raw-images e 1*std() per i lake


path=getDirectory("Choose a Directory");
list=getFileList(path);

// Camera parameters setting in ThunderSTORM
PixelSize = 108.3; //[nm]
offset = 100;
ph_elect = 0.22;
////////////////////////////////////////////

magn = 1;

run("Camera setup", "readoutnoise=0.0 offset="+offset+" quantumefficiency=1.0 isemgain=false photons2adu="+ph_elect+" pixelsize="+PixelSize);

for (i = 0; i < list.length; i++){
//	print("Folder: "+list[i]);
	if (endsWith(list[i], "/")){
		list2=getFileList(path+list[i]);
		
		for (j = 0; j < list2.length; j++){

			if(indexOf(list2[j], "SIM") > -1){
			open(path+list[i]+list2[j]);

			run("Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood threshold=2*std(Wave.F1) estimator=[PSF: Integrated Gaussian] sigma=1.6 fitradius=4 method=[Weighted Least squares] full_image_fitting=false mfaenabled=false renderer=[Normalized Gaussian] dxforce=false magnification="+magn+ " colorize=false dx=100.0 threed=false dzforce=false repaint=50");
			run("Export results", "floatprecision=5 filepath="+path+list[i]+"Table_Cell.csv fileformat=[CSV (comma separated)] sigma=true intensity=true chi2=true offset=true saveprotocol=true x=true y=true bkgstd=true id=true uncertainty_xy=true frame=true");

			close('*');
			} else {
				
			if((indexOf(list2[j], "Lake") > -1) || (indexOf(list2[j], "lake") > -1)){
			open(path+list[i]+list2[j]);
					
			run("Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood threshold=std(Wave.F1) estimator=[PSF: Integrated Gaussian] sigma=1.6 fitradius=4 method=[Weighted Least squares] full_image_fitting=false mfaenabled=false renderer=[Normalized Gaussian] dxforce=false magnification="+magn+ " colorize=false dx=100.0 threed=false dzforce=false repaint=50");
			run("Export results", "floatprecision=5 filepath="+path+list[i]+"Table_LAKE.csv fileformat=[CSV (comma separated)] sigma=true intensity=true chi2=true offset=true saveprotocol=true x=true y=true bkgstd=true id=true uncertainty_xy=true frame=true");

			close('*'); 
					}}
				}
	}}