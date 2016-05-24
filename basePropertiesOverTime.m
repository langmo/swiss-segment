function [area, fluoMeans, fluoStds, backgroundMeans, backgroundStds] = basePropertiesOverTime(config, channels, callbacks)


if nargin < 3 || isempty(callbacks)
    callbacks = {};
elseif ~iscell(callbacks)
    callbacks = {callbacks};
end

%% Initialize
fluoMeans   = cell(1, length(channels));
fluoStds   = cell(1, length(channels));
backgroundMeans = cell(1, length(channels));
backgroundStds = cell(1, length(channels));

for i=1:length(channels)
    fluoMeans{i}        = zeros(1, length(config.imageRange));
    fluoStds{i}         = zeros(1, length(config.imageRange));
    backgroundMeans{i}  = zeros(1, length(config.imageRange));
    backgroundStds{i}   = zeros(1, length(config.imageRange));
end
area = zeros(1, length(config.imageRange));


%% Iterate over images
for i = 1:length(config.imageRange) 
    %% Send state to callbacks
    for cc = 1:length(callbacks)
        callbacks{cc}((i-1) / length(config.imageRange));
    end
    
    %% Load segmentation mask
    segmentationMaskFile = fullfile(config.segmentationFolder, sprintf([config.segmentTemplate, '.', config.imageFileType], config.imageRange(i)));
    if ~exist(segmentationMaskFile, 'file')
        error('SwissSegment:SegmentationMaskNotFound', 'Segmentation Mask not found for frame %g (expected file location: "%s").', frame, segmentationMaskFile);
    end
    segmentionMask = logical(getImage(segmentationMaskFile));

    for c = 1:length(channels)
        %% Load fluorescence image
        fluorescenceImageFile = fullfile(config.imageFolder, sprintf([config.fluoTemplates{channels(c)}, '.', config.imageFileType], config.imageRange(i)));
        if ~exist(fluorescenceImageFile, 'file')
            error('SwissSegment:FluorescenceImageNotFound', 'Fluorescence image not found for frame %g (expected file location: "%s").', frame, fluorescenceImageFile);
        end
        fluorescenceImage = getImage(fluorescenceImageFile);
        segFluo = fluorescenceImage(segmentionMask);
        fluoMeans{c}(i) = mean(segFluo);
        fluoStds{c}(i) = std(segFluo);
        nonsegFluo = fluorescenceImage(~segmentionMask);
        backgroundMeans{c}(i) = mean(nonsegFluo);
        backgroundStds{c}(i) = std(nonsegFluo);
    end
    area(i) = sum(sum(segmentionMask));
end

%% Send finished signal to callbacks
for cc = 1:length(callbacks)
    callbacks{cc}(1);
end