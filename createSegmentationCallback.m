function segmentationCallback = createSegmentationCallback(imageFolder, imageRange, BFImageTemplate, fluoTemplates, outputFolder, imageFileType, copyFiles)

    if isstruct(imageFolder)
        callbackParams = imageFolder.callbackParams;
    else
        callbackParams = struct('imageFolder', imageFolder,...
            'imageRange', imageRange,...
            'BFImageTemplate', BFImageTemplate, ...
            'outputFolder', outputFolder,...
            'resultFile', 'result.mat',...
            'imageFileType', imageFileType,...
            'copyFiles', copyFiles);
        callbackParams.fluoTemplates = fluoTemplates;
    end

    segmentationCallback = struct('initializeCallback', @initializeCallback, ...
        'iterationCallback', @iterationCallback,...
        'uninitializeCallback', @uninitializeCallback,...
        'callbackParams', callbackParams);

end

%% Initialization of callback
function callbackResult = initializeCallback(callbackParams)
    if exist(fullfile(callbackParams.outputFolder, callbackParams.resultFile), 'file')
        fprintf('Loading existing quantification...\n');
        load(fullfile(callbackParams.outputFolder, callbackParams.resultFile));
        
        callbackResult.callbackParams = callbackParams;
        
        if ~isfield(callbackResult, 'fluoValues') ...
                || size(callbackResult.fluoValues, 1) ~= length(callbackParams.fluoTemplates) ...
            	|| size(callbackResult.fluoValues, 2) ~= length(callbackParams.imageRange)
            callbackResult.fluoValues = zeros(length(callbackParams.fluoTemplates), length(callbackParams.imageRange));
            callbackResult.area = zeros(1, length(callbackParams.imageRange));
        end
        
    else
        fprintf('Creating new quantification...\n');
        callbackResult = struct('fluoValues', zeros(length(callbackParams.fluoTemplates), length(callbackParams.imageRange)),...
            'area', zeros(1, length(callbackParams.imageRange)),...
            'callbackParams', callbackParams);
    end
    
    callbackResult = displayState(callbackResult);
end

%% Uninitialization of callback
function uninitializeCallback(callbackResult, ~) %#ok<INUSD>
    % Close visualization figure
%     if isfield(callbackResult, 'figureID') && ishandle(callbackResult.figureID)
%         close(callbackResult.figureID);
%     end
end

%% Iteration of callback
function callbackResult = iterationCallback(imgID, segmentedImage, callbackResult)
    callbackParams = callbackResult.callbackParams;
    %fprintf('Analyzing image %g\n', callbackParams.imageRange(imgID));

    % Get properties
    stats = regionprops(segmentedImage, {'Area'});
    callbackResult.area(imgID) = 0;
    for i= 1:length(stats)
        callbackResult.area(imgID) = callbackResult.area(imgID) + stats(i).Area;
    end

    for j=1:length(callbackParams.fluoTemplates)
        FluoImage = getImage([callbackParams.imageFolder, sprintf(callbackParams.fluoTemplates{j}, callbackParams.imageRange(imgID)), '.', callbackParams.imageFileType], 2);
        
        callbackResult.fluoValues(j, imgID) = mean(FluoImage(segmentedImage));
    end
    callbackResult = displayState(callbackResult);

    % save result
    save(fullfile(callbackParams.outputFolder, callbackParams.resultFile), 'callbackResult');

    % copy files
    if callbackParams.copyFiles
        for j=1:length(callbackParams.fluoTemplates)
            copyfile(   fullfile(callbackParams.imageFolder,  [sprintf(callbackParams.fluoTemplates{j}, callbackParams.imageRange(imgID)), '.', callbackParams.imageFileType]), ...
                        fullfile(callbackParams.outputFolder, [sprintf(callbackParams.fluoTemplates{j}, callbackParams.imageRange(imgID)), '.', callbackParams.imageFileType]));
        end
        copyfile(       fullfile(callbackParams.imageFolder,  [sprintf(callbackParams.BFImageTemplate, callbackParams.imageRange(imgID)), '.', callbackParams.imageFileType]), ...
                        fullfile(callbackParams.outputFolder, [sprintf(callbackParams.BFImageTemplate, callbackParams.imageRange(imgID)), '.', callbackParams.imageFileType]));
    end

end

%% display current result
function callbackResult = displayState(callbackResult)
    callbackParams = callbackResult.callbackParams;
    
    maxVal = max(1.1 * max(callbackResult.area), 1);
    
    % display sub-result
    if isfield(callbackResult, 'figureID') ...
            && ishandle(callbackResult.figureID) ...
        set(0,'CurrentFigure', callbackResult.figureID);
    clf();
    else
        callbackResult.figureID = figure('Name', 'Quantification',...
            'NumberTitle', 'off',...
            'Position', [960, 200, 400, 640],...
            'Color', [1, 1, 1],...
            'DockControls', 'off', ...
            'Toolbar', 'none', ...
            'MenuBar', 'none');
        callbackResult.figureID = callbackResult.figureID.Number;
        clf();
        % Change icon
        setWindowIcon(); 
        
        % Create Menu
    	saveMenu = uimenu(callbackResult.figureID, 'Label', 'Save'); 
        uimenu(saveMenu, 'Label',...
            'Save to Excel', ...
            'Callback', @saveToExcel);
    end
    subplot(2,1,1);
    plot(callbackParams.imageRange, callbackResult.area, 'k');
    titleH = title('Figure 1: Area of the droplet in voxels over time.');
    set(titleH, 'Units', 'normalized', 'Position', [0.0, -0.15], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left');
    ylabel('Area (voxels)');
    xlabel('Frame (-)');
    ylim([0, maxVal]);
    box off;

    subplot(2,1,2);
    legends = cell(1, length(callbackParams.fluoTemplates));
    for j = 1 : length(callbackParams.fluoTemplates)
        plotFluosH = plot(callbackParams.imageRange, callbackResult.fluoValues(j, :)/max(callbackResult.fluoValues(j, :)));
        set(plotFluosH, 'Color', getColors(j+1));

        legends{j} = ['Channel ', mat2str(j)];
        hold on;
    end

    titleH = title(sprintf('Figure 2: Mean Fluorescence of the droplet in different\nchannels, normalized to maximal values.'));
    set(titleH, 'Units', 'normalized', 'Position', [0.0, -0.15], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left');
    xlabel('Frame (-)');
    ylabel('Mean Fluorescence (normalized)');
    ylim([0, 1.1]);
    legend(legends, 'Location', 'SouthEast');
    legend('boxoff');
    box off;
    
    drawnow();
    set(callbackResult.figureID, 'UserData', callbackResult);
end

%% Save Data to CSV
function saveToExcel(figH, ~)
    figH = ancestor(figH, 'figure');
    callbackResult = get(figH, 'UserData');
    callbackParams = callbackResult.callbackParams;
    
    [FileName, PathName] = uiputfile({'*.xlsx', 'Excel 2007 (.xlsx)';'*.xls', 'Excel 97-2003  (.xls)'},...
        'Select Output File Name',...
        [callbackParams.outputFolder, 'segmentation_result.xlsx']);
    set(figH, 'Pointer', 'watch');
    
    if length(FileName) <= 0 || isnumeric(FileName)
        return;
    end
    FileName = fullfile(PathName,FileName);
    
    data = cell(length(callbackParams.imageRange) + 1, 2 + length(callbackParams.fluoTemplates));
    data{1, 1} = 'Frame';
    data{1, 2} = 'Area (voxels)';
    for j = 1 : length(callbackParams.fluoTemplates)
        data{1, j + 2} = ['Channel ', mat2str(j), ' (relative)'];
    end
    data(2:end, 1) = num2cell(callbackParams.imageRange');
    data(2:end, 2) = num2cell(callbackResult.area');
    data(2:end, 3:end) = num2cell(callbackResult.fluoValues');
    [status, message] = xlswrite(FileName, data);
    set(figH, 'Pointer', 'arrow');
    
    if ~status
        errordlg(sprintf(['Data could not be saved:\n', message.message]), 'File not saved', 'modal');
        return;
    end
end