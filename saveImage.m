function saveImage(myImage, fileName)
% saveImage(myImage, fileName)
% Convert image from [0,1] to uint8 and saves it in fileName.

rawImage = uint8(myImage * double(intmax('uint8')));

 imwrite(rawImage, fileName, 'tif');
end

