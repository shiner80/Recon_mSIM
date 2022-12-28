

function [wfImage] =  generateWF(Stack)
% Generate Widefield image from series of multifocal illuminations



    wfImage = zeros(size(Stack(1).data));


    for i= 1: length(Stack)
        wfImage = wfImage + double(Stack(i).data);
    end
   
    wfImage = imresize(wfImage,2);
    
    
end