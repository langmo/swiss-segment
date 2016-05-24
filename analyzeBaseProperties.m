function [area, fluoMeans, backgroundMeans, radialNum, fluoRadialMeans, varargout] = analyzeImages(imageFolder, segmentTemplate, fluoTemplates, imageRange, maxRadius)

if ~exist(fullfile(imageFolder, sprintf(segmentTemplate, imageRange(end))), 'file')
    area = -1;
    fluoMeans = -1;
    backgroundMeans = -1;
    radialNum = -1;
    fluoRadialMeans = -1;
    return;
end

%% Analyze images
fluoMeans   = cell(1, length(fluoTemplates));
backgroundMeans = cell(1, length(fluoTemplates));
fluoMedians   = cell(1, length(fluoTemplates));
backgroundMedians = cell(1, length(fluoTemplates));
for i=1:length(fluoTemplates)
    fluoMeans{i}   = zeros(1, length(imageRange));
    backgroundMeans{i}   = zeros(1, length(imageRange));
    fluoMedians{i}   = zeros(1, length(imageRange));
    backgroundMedians{i}   = zeros(1, length(imageRange));
end
area        = zeros(1, length(imageRange));

if maxRadius > 0
    fluoRadialMeans = cell(1, length(fluoTemplates));
    radialNum = zeros(length(imageRange), maxRadius);
    for i=1:length(fluoTemplates)
        fluoRadialMeans{i} = NaN(length(imageRange), maxRadius);
    end
else
    fluoRadialMeans = [];
    radialNum = [];
end

wbh_out = waitbar(0, 'Initializing...');
for imgID = 1 : length(imageRange)
    wbh_out = waitbar((imgID-1)/length(imageRange), wbh_out, sprintf('Processing time %g of %g...', imgID, length(imageRange)));
    segmentedImage = logical(getImage(fullfile(imageFolder, sprintf(segmentTemplate, imageRange(imgID)))));
    fluoImages = cell(1, length(fluoTemplates));
    for i=1:length(fluoTemplates)
        fluoImages{i} = getImage(fullfile(imageFolder, sprintf(fluoTemplates{i}, imageRange(imgID))));
    end
    
    if maxRadius > 0
        distImage =  round(bwdist(~segmentedImage));
        distances = unique(distImage(:));
        distances(distances==0) = [];
        if length(distances) >= 100
            wbh = waitbar(0, 'analyzing radial fluorescence');
        end
        for i = 1 : length(distances)
            if length(distances) >= 100 && mod(i, 30) == 0
                wbh = waitbar((i-1) / length(distances), wbh, sprintf('Radius %g of %g', i, length(distances)));
            end
            idx = distImage == distances(i);
            radialNum(imgID, distances(i)) = sum(sum(idx));
            for j=1:length(fluoTemplates)
                fluoRadialMeans{j}(imgID, distances(i)) = mean(fluoImages{j}(idx));
            end
        end
        if length(distances) >= 100
            waitbar('close');
        end
    end
    
    %% mean values
    stats = regionprops(segmentedImage, {'Area'});
    for i= 1:length(stats)
        area(imgID) = area(imgID) + stats(i).Area;
    end
    for j=1:length(fluoTemplates)
        fluoMeans{j}(imgID) = mean(fluoImages{j}(segmentedImage));
        backgroundMeans{j}(imgID) = mean(fluoImages{j}(~segmentedImage));
        fluoMedians{j}(imgID) = median(fluoImages{j}(segmentedImage));
        backgroundMedians{j}(imgID) = median(fluoImages{j}(~segmentedImage));
    end
end
waitbar('close');
%%
if nargout >= 6
    varargout(1) = {fluoMedians};
end
if nargout >= 7
    varargout(2) = {backgroundMedians};
end
