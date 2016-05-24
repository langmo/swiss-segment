function [binX, histogramValues, quantileValues] = histogramsOverTime(config, channels, granularity, quantileSteps, callbacks)

if nargin < 3
    granularity = 300;
end

if nargin < 4
    quantileSteps = [0.25, 0.5, 0.75];
end

if nargin < 5 || isempty(callbacks)
    callbacks = {};
elseif ~iscell(callbacks)
    callbacks = {callbacks};
end

%% Initialize
histogramValues = cell(1, length(channels));
quantileValues = cell(1, length(channels));
for c = 1:length(channels)
    histogramValues{c} = zeros(length(config.imageRange), granularity);
    quantileValues{c} = zeros(length(config.imageRange), length(quantileSteps));
end

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
        
        [binX, binY] = getHistogram(fluorescenceImage, segmentionMask, granularity);
        histogramValues{c}(i, :) = binY;
        
        segFluo = fluorescenceImage(segmentionMask);
        quantileValues{c}(i, :) = quantile(segFluo, quantileSteps);
    end
end

%% Send finished signal to callbacks
for cc = 1:length(callbacks)
    callbacks{cc}(1);
end
