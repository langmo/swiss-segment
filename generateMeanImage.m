function meanImage = generateMeanImage(imageFolder, BFImageTemplate, imageFileType, positions)

meanImage = [];
imageNum = 0;
for position = positions
    BFImageFile         = [sprintf(BFImageTemplate, position), '.', imageFileType];
    BFImage = getImage([imageFolder, BFImageFile], 1);
    if isempty(meanImage)
        meanImage = BFImage;
    else
        meanImage = meanImage + BFImage;
    end
    imageNum = imageNum + 1;
end
meanImage = meanImage ./ imageNum;

figure();
imagesc(meanImage, [0,1]);
axis off;
axis equal;
end