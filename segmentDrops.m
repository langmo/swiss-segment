function segmentDrops(positions, autostart)

    if ~exist('positions', 'var') || isempty(positions)
        positions = 3;%4;
    end
    if ~exist('autostart', 'var') || isempty(autostart)
        autostart = false;
    end
    
    position = positions(1);
    
    positionString = sprintf('%02.0f', position);

    if 0
        imageFolder = 'T:/ML_MM/2012_11_30 HD Trp/';
        outputFolder = ['Y:/2012_11_30 HD Trp_analysis/', 'segmentation_xy', positionString, '/'];
        meanImageFile = 'Y:/2012_11_30 HD Trp_analysis/meanImage.tif';
                
        fluo1Template           = ['2012_11_30 hd trpxy', positionString, 'c1t%03.0f'];
        fluo2Template           = ['2012_11_30 hd trpxy', positionString, 'c2t%03.0f'];
        BFImageTemplate         = ['2012_11_30 hd trpxy', positionString, 'c3t%03.0f'];
        meanImageTemplate      = ['2012_11_30 hd trpxy%02.0fc3t001'];
        
        imageRange = 1:211;
    elseif 0
        imageFolder = 'Y:/2013_01_16 HD TransfectTrp/';
        outputFolder = ['Y:/2013_01_16 HD TransfectTrp_analysis/', 'segmentation_xy', positionString, '/'];
        meanImageFile = 'Y:/2013_01_16 HD TransfectTrp_analysis/meanImage.tif';
                
        fluoTemplates = cell(1, 2);
        fluoTemplates{1}           = ['2013_01_16 hd 37c transfecttrpxy', positionString, 'c1t%03.0f'];
        fluoTemplates{2}           = ['2013_01_16 hd 37c transfecttrpxy', positionString, 'c2t%03.0f'];
        BFImageTemplate         = ['2013_01_16 hd 37c transfecttrpxy', positionString, 'c3t%03.0f'];
        MeanImageTemplate      = ['2013_01_16 hd 37c transfecttrpxy%02.0fc3t001'];
        
        imageRange = 1:383;
        
        defaultSettings = struct('alpha', 1.5,...
            'beta1', 10,...
            'beta2', 0,...
            'maxMovement', 20,...
            'minSize', 50,...
            'minHole', 50,...
            'threshold', 0.30,...
            'method', 'Default',...
            'invert', true);
    elseif 0
        imageFolder = 'Y:/2013_03_13 Gravity Size -Exp13-5/Images/';
        outputFolder = ['Y:/2013_03_13 Gravity Size -Exp13-5/analysis/', 'segmentation_xy', positionString, '/'];
        
        fluoTemplates = cell(1, 4);
        for i = 1:4
            fluoTemplates{i}           = ['2013_03_13 hd sizexy', positionString, 'c', mat2str(i), 't%03.0f'];
        end
        
        BFImageTemplate         = ['2013_03_13 hd sizexy', positionString, 'c5t%03.0f'];
        
        meanImageFile = [];
        meanImageTemplate      = [];
        
        imageRange = 1:280;
        
        defaultSettings = struct('alpha', 20,...
            'beta1', 250,...
            'beta2', 300,...
            'maxMovement', 25,...
            'minSize', 50,...
            'minHole', 50,...
            'threshold', 0.35,...
            'method', 'Low9',...
            'invert', true);
    elseif 0
        imageFolder = 'Y:/2013_07_29 Phase HD -Exp13-19/images2 (004)/';
        outputFolder = ['Y:/2013_07_29 Phase HD -Exp13-19/analysis/images2/', 'segmentation_xy', positionString, '/'];
        
        fluoTemplates = cell(1, 3);
        for i = 1:length(fluoTemplates)
            fluoTemplates{i}           = ['2013_06_26 pest004xy', positionString, 'c', mat2str(i+1), 't%03.0f'];
        end
        
        BFImageTemplate         = ['2013_06_26 pest004xy', positionString, 'c1t%03.0f'];
        
        imageRange = 1:148;
        
        defaultSettings = struct('alpha', 18,...
            'beta1', 450,...
            'beta2', 100,...
            'maxMovement', 20,...
            'minSize', 20,...
            'minHole', 10,...
            'threshold', 0.30,...
            'method', 'Median',...
            'methodOrder', 9,...
            'invert', true);
    elseif 0
        imageFolder = 'Y:/2013_07_29 Phase HD -Exp13-19/images3 (005)/';
        outputFolder = ['Y:/2013_07_29 Phase HD -Exp13-19/analysis/images3/', 'segmentation_xy', positionString, '/'];
        
        fluoTemplates = cell(1, 3);
        for i = 1:length(fluoTemplates)
            fluoTemplates{i}           = ['2013_06_26 pest005xy', positionString, 'c', mat2str(i+1), 't%03.0f'];
        end
        
        BFImageTemplate         = ['2013_06_26 pest005xy', positionString, 'c1t%03.0f'];
        
        imageRange = 1:144;
        
        defaultSettings = struct('alpha', 18,...
            'beta1', 450,...
            'beta2', 100,...
            'maxMovement', 20,...
            'minSize', 20,...
            'minHole', 10,...
            'threshold', 0.26,...
            'method', 'Median',...
            'methodOrder', 9,...
            'invert', true);
    else
        imageFolder = 'Y:/2014_02_12 Osci HD/images/';
        outputFolder = ['Y:/2014_02_12 Osci HD/analysis/', 'segmentation_xy', positionString, '/'];
        
        fluoTemplates = cell(1, 3);
        for i = 1:length(fluoTemplates)
            fluoTemplates{i}           = ['2014_02_14xy', positionString, 'c', mat2str(i+1), 't%03.0f'];
        end
        BFImageTemplate         = ['2014_02_14xy', positionString, 'c1t%03.0f'];
        
        imageRange = 1:399;
        
        defaultSettings = struct('alpha', 18,...
            'beta1', 200,...
            'beta2', 100,...
            'maxMovement', 15,...
            'minSize', 20,...
            'minHole', 10,...
            'threshold', 0.55,...
            'method', 'Median',...
            'methodOrder', 9,...
            'invert', true);
    
    end

    
%     segmentationTemplate    = ['segmentation xy', positionString, 't%03.0f'];
    imageFileType = 'tif';

%     if exist(meanImageFile, 'file') && ~isempty(meanImageFile)
%         meanImage = getImage(meanImageFile);
%     elseif exist('meanImageTemplate', 'var') && ~isempty(meanImageTemplate)
%         fprintf('Generating mean image...\n');
%         meanImage = generateMeanImage(imageFolder, meanImageTemplate, imageFileType, 1:90);
%         fprintf('Generated!\n');
%         saveImage(meanImage, meanImageFile);
%     else
%         meanImage = [];
%     end
    meanImage = [];
    
    segmentationCallback = createSegmentationCallback(imageFolder, imageRange, BFImageTemplate, fluoTemplates, outputFolder, imageFileType, true);
    
    if length(positions) > 1
        nextCallbackParams = struct();
        nextCallbackParams.nextPositions = positions(2:end);
        nextCallbackParams.autostart = autostart;
        nextCallback = struct('initializeCallback', @initializeCallback, ...
            'iterationCallback', @iterationCallback,...
            'uninitializeCallback', @uninitializeCallback,...
            'callbackParams', nextCallbackParams);
        
        segmentationCallbacks = {segmentationCallback, nextCallback};
    else
        segmentationCallbacks = {segmentationCallback};
    end
    

    swissSegment(imageFolder, BFImageTemplate, imageFileType, imageRange, outputFolder, segmentationCallbacks, meanImage, autostart, defaultSettings)
    
end


%% Initialization of callback
function callbackResult = initializeCallback(callbackParams)
    callbackResult = struct('callbackParams', callbackParams);
end

%% Uninitialization of callback
function uninitializeCallback(callbackResult, ~)
    callbackParams = callbackResult.callbackParams;

    nextPositions = callbackParams.nextPositions;
    
    if ~isempty(nextPositions)
        segmentDrops(nextPositions, callbackParams.autostart);
    end
end

%% Iteration of callback
function callbackResult = iterationCallback(~, ~, callbackResult)
    % do nothing
end


% %% Initialization of callback
% function callbackResult = initializeCallback(callbackParams)
%     if exist([callbackParams.outputFolder, callbackParams.resultFile], 'file')
%         fprintf('Loading existing quantification...\n');
%         load([callbackParams.outputFolder, callbackParams.resultFile]);
%         
%         callbackResult.callbackParams = callbackParams;
%         
%         if ~isfield(callbackResult, 'fluoValues') ...
%                 || size(callbackResult.fluoValues, 1) ~= length(callbackParams.fluoTemplates) ...
%             	|| size(callbackResult.fluoValues, 2) ~= length(callbackParams.imageRange)
%             callbackResult.fluoValues = zeros(length(callbackParams.fluoTemplates), length(callbackParams.imageRange));
%             callbackResult.area = zeros(1, length(callbackParams.imageRange));
%         end
%         
%     else
%         fprintf('Creating new quantification...\n');
%         callbackResult = struct('fluoValues', zeros(length(callbackParams.fluoTemplates), length(callbackParams.imageRange)),...
%             'area', zeros(1, length(callbackParams.imageRange)),...
%             'callbackParams', callbackParams);
%     end
%     
%     callbackResult = displayState(callbackResult);
% end
% 
% %% Uninitialization of callback
% function uninitializeCallback(callbackResult, figH)
%     callbackParams = callbackResult.callbackParams;
% 
%     nextPositions = callbackParams.positions(2:end);
%     
%     if ~isempty(nextPositions)
%         close(figH);
%         if isfield(callbackResult, 'figureID') && ishandle(callbackResult.figureID)
%             close(callbackResult.figureID);
%         end
%         segmentDrops(nextPositions, callbackParams.autostart);
%     end
% end
% 
% %% Iteration of callback
% function callbackResult = iterationCallback(imgID, segmentedImage, callbackResult)
%     callbackParams = callbackResult.callbackParams;
%     fprintf('Analyzing image %g\n', callbackParams.imageRange(imgID));
% 
%     % Get properties
%     stats = regionprops(segmentedImage, {'Area'});
%     callbackResult.area(imgID) = 0;
%     for i= 1:length(stats)
%         callbackResult.area(imgID) = callbackResult.area(imgID) + stats(i).Area;
%     end
% 
%     for j=1:length(callbackParams.fluoTemplates)
%         FluoImage = getImage([callbackParams.imageFolder, sprintf(callbackParams.fluoTemplates{j}, callbackParams.imageRange(imgID)), '.', callbackParams.imageFileType], 2);
%         
%         callbackResult.fluoValues(j, imgID) = mean(FluoImage(segmentedImage));
%     end
%     callbackResult = displayState(callbackResult);
% 
%     % save result
%     save([callbackParams.outputFolder, callbackParams.resultFile], 'callbackResult');
% 
%     % copy files
%     if callbackParams.copyFiles
%         for j=1:length(callbackParams.fluoTemplates)
%             copyfile([callbackParams.imageFolder, sprintf(callbackParams.fluoTemplates{j}, callbackParams.imageRange(imgID)), '.', callbackParams.imageFileType], [callbackParams.outputFolder, sprintf(callbackParams.fluoTemplates{j}, callbackParams.imageRange(imgID)), '.', callbackParams.imageFileType]);
%         end
%         copyfile([callbackParams.imageFolder, sprintf(callbackParams.BFImageTemplate, callbackParams.imageRange(imgID)), '.', callbackParams.imageFileType], [callbackParams.outputFolder, sprintf(callbackParams.BFImageTemplate, callbackParams.imageRange(imgID)), '.', callbackParams.imageFileType]);
%     end
% 
% end
% 
% %% display current result
% function callbackResult = displayState(callbackResult)
%     callbackParams = callbackResult.callbackParams;
%     
%     % display sub-result
%     if isfield(callbackResult, 'figureID') ...
%             && ishandle(callbackResult.figureID) ...
%             && isfield(callbackResult, 'plotAreaH') &&ishandle(callbackResult.plotAreaH)
%         set(callbackResult.plotAreaH, 'YData', callbackResult.area/max(callbackResult.area));
%         for j = 1 : length(callbackParams.fluoTemplates)
%             set(callbackResult.plotFluosH(j), 'YData', callbackResult.fluoValues(j, :)/max(callbackResult.fluoValues(j, :)));
%         end
%     else
%         callbackResult.figureID = figure('Name', 'Detected Fluorescence', 'NumberTitle', 'off');
%         clf();
%         callbackResult.plotAreaH = plot(callbackParams.imageRange, callbackResult.area/max(callbackResult.area), 'k');
%         hold on;
%         
%         legends = cell(1, length(callbackParams.fluoTemplates) + 1);
%         legends{1} = 'Area';
%         
%         callbackResult.plotFluosH = zeros(1, length(callbackParams.fluoTemplates));
%         for j = 1 : length(callbackParams.fluoTemplates)
%             callbackResult.plotFluosH(j) = plot(callbackParams.imageRange, callbackResult.fluoValues(j, :)/max(callbackResult.fluoValues(j, :)));
%             set(callbackResult.plotFluosH(j), 'Color', getColors(j+1));
%             
%             legends{j+1} = ['Fluorescence', mat2str(j)];
%         end
%         
%         xlabel('Time (frames)');
%         ylabel('Value (normalized)');
%         ylim([0, 1.2]);
%         legend(legends, 'Location', 'SouthEast');
%         setPrintLayout(6,4);
%         drawnow();
%     end
% end
