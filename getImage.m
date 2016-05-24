function loadedImage = getImage(fileName, channel)
rawImage = imread(fileName, 'tif');

switch class(rawImage)
    case 'uint8'
        loadedImage = double(rawImage) / double(intmax('uint8'));
    case 'uint16'
        loadedImage = double(rawImage) / double(intmax('uint16'));
    case 'uint32'
        loadedImage = double(rawImage) / double(intmax('uint32'));
    otherwise
        error('CSB:ImageFormat', 'Only 1-4 bytes/pixel grayscale images allowed.');
end

s = size(loadedImage);
if length(s) == 3
    if s(3) == 1
        loadedImage = reshape(loadedImage, s(1), s(2));
    else
        if ~exist('channel', 'var')
            channel = 1;
        end
        loadedImage = reshape(loadedImage(:,:,channel), s(1), s(2));
    end
elseif length(s) > 3
    error('CSB:ImageFormat', 'Images maximal 2D with colors.');
end

end