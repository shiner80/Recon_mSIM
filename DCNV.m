function [SRES_deconv, Confocal_deconv] = DCNV(address, SRES, Confocal, WF, iter, show)


PSF = TIFread(address);
    if min(PSF.data(:)) < 0
        PSF.data = PSF.data - min(PSF.data(:));
    end

SRES(isnan(SRES(:))) = 0;
Confocal(isnan(Confocal(:))) = 0;

SRES_deconv = deconvlucy(SRES, PSF.data, iter);
Confocal_deconv = deconvlucy(Confocal, PSF.data, iter);

odg1 = log10(max(SRES_deconv(:)));
SRES_deconv = SRES_deconv.*10^(3-odg1);

odg2 = log10(max(Confocal_deconv(:)));
Confocal_deconv = Confocal_deconv.*10^(3-odg2);

if show
figure
subplot(2,2,1)
imagesc(WF);
title("Widefield");

subplot(2,2,2);
imagesc(Confocal);
title("Confocal");

subplot(2,2,3)
imagesc(SRES);
title('Super-resolved Image');

subplot(2,2,4)
imagesc(SRES_deconv);
title(strcat("SRES-Image + Deconvolution iterations = ", num2str(iter)));
colormap('hot');
end

disp("Deconvolution was done!");

end

