function controlImage = plotComposedImage(config, frame, fluorescenceChannel, fluorMin, fluorMax, colorPercent)

    %% Load segmentation mask
    segmentationMaskFile = fullfile(config.segmentationFolder, sprintf([config.segmentTemplate, '.', config.imageFileType], frame));
    if ~exist(segmentationMaskFile, 'file')
        error('SwissSegment:SegmentationMaskNotFound', 'Segmentation Mask not found for frame %g (expected file location: "%s").', frame, segmentationMaskFile);
    end
    segmentionMask = logical(getImage(segmentationMaskFile));
    
    %% Load fluorescence image
    fluorescenceImageFile = fullfile(config.imageFolder, sprintf([config.fluoTemplates{fluorescenceChannel}, '.', config.imageFileType], frame));
    if ~exist(fluorescenceImageFile, 'file')
        error('SwissSegment:FluorescenceImageNotFound', 'Fluorescence image not found for frame %g (expected file location: "%s").', frame, fluorescenceImageFile);
    end
    fluorescenceImage = getImage(fluorescenceImageFile);
    
    %% scale BF image
    fluorescenceImage = max(min((fluorescenceImage-fluorMin) ./ (fluorMax-fluorMin), 1), 0);
        
    %% Load BF image
    bfImageFile = fullfile(config.imageFolder, sprintf([config.bfTemplate, '.', config.imageFileType], frame));
    if ~exist(bfImageFile, 'file')
        error('SwissSegment:FluorescenceImageNotFound', 'Fluorescence image not found for frame %g (expected file location: "%s").', frame, fluorescenceImageFile);
    end
    bfImage = getImage(bfImageFile);
    
    %% scale BF image
    bfMin = min(min(bfImage));
    bfMax = max(max(bfImage));
    bfImage = (bfImage-bfMin) ./ (bfMax-bfMin);
    
    %% get border of segmentation    
    H = conv2(double(segmentionMask),[-1,0,1], 'same');
    V = conv2(double(segmentionMask),[-1;0;1], 'same');
    edgeImage = abs(H)|abs(V);

    
    R = bfImage * (1-colorPercent);
    G = R + fluorescenceImage * colorPercent;
    B = R;

    R(edgeImage) = 0.7;
    G(edgeImage) = 0.1;
    B(edgeImage) = 0.1;
    controlImage = cat(3, R, G, B);
    %controlImage(:, :, 1) = R;
    %controlImage(:, :, 2) = G;
    %controlImage(:, :, 3) = B;
    
end

