function analyzeHistogramsOverTime(segmentConfig)
if nargin < 1 || isempty(segmentConfig) || ~isstruct(segmentConfig)
    error('SwissSegment:WrongParameter', 'First parameter must be a segmentation configuration.');
end

%% Check configuration
callbacks = segmentConfig.segmentationCallbacks;
if isempty(callbacks)
    error('SwissSegment:NoCallbacks', 'No segmentation callbacks defined');
end
if ~isfield(callbacks{1}, 'callbackParams') || ~isfield(callbacks{1}.callbackParams, 'fluoTemplates')
    error('SwissSegment:UnknownCallbacks', 'Segmentation callback type unknown.');
end

%% read out configuration
imageFolder = segmentConfig.imageFolder;
imageRange = segmentConfig.imageRange;
bfTemplate = segmentConfig.imageTemplate{1};
segmentationFolder = segmentConfig.resultFolder;
imageFileType = segmentConfig.imageFileType;
resultFolder = segmentConfig.resultFolder;

segmentTemplate = [bfTemplate, '_segment'];

callbacks = segmentConfig.segmentationCallbacks;
if isempty(callbacks)
    error('SwissSegment:NoCallbacks', 'No segmentation callbacks defined');
end
if ~isfield(callbacks{1}, 'callbackParams') || ~isfield(callbacks{1}.callbackParams, 'fluoTemplates')
    error('SwissSegment:UnknownCallbacks', 'Segmentation callback type unknown.');
end
fluoTemplates = callbacks{1}.callbackParams.fluoTemplates;

config = struct(...
    'segmentTemplate', segmentTemplate,...
    'imageFolder', imageFolder,...
    'segmentationFolder', segmentationFolder, ...
    'imageRange', imageRange,...
    'imageFileType', imageFileType,...
    'resultFolder', resultFolder);
config.fluoTemplates = fluoTemplates;

%% Create Figure
figureDim = [400, 800];
figH = figure('Units', 'pixels',...
    'Position', [100, 200, figureDim(1), figureDim(2)],...
    'Color', [1, 1, 1],...
    'Name', 'SwissSegment - Fluorescence Histograms', ...
    'NumberTitle', 'off',...
    'DockControls', 'off', ...
    'MenuBar', 'none', ...
    'Toolbar', 'none',...
    'WindowScrollWheelFcn', @scrollTime);

% Change icon
setWindowIcon(); 

axes('Units', 'pixels', ...
    'Position', [50, 100, figureDim(1)-60, figureDim(2)-110],...
    'Tag', 'histogramAxis');

text(0.5, 0.5, {'Select channel and granularity', 'and press ''Calculate'''},...
    'HorizontalAlignment', 'center');
axis off;

%% Configuration panel
myPanel=uipanel('Title', 'Configuration',...
    'BackgroundColor', [1,1,1],...
    'Units', 'pixels',...
    'Position', [10, 10, 400, 80],...
    'Tag', 'configurationPanel');
%set(myPanel, 'Background', 'none');

uicontrol('Style', 'text', ...
    'String', 'Channel:',...
    'pos',[20, 50, 50, 15],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'left');

uicontrol('Style', 'popupmenu',...
    'pos',[90, 50, 70, 20],...
    'String', num2cell(num2str((1:length(fluoTemplates))'), 2)',...
    'HorizontalAlignment', 'left',...
    'Tag', 'channelChooser');

uicontrol('Style', 'text', ...
    'String', 'Granularity:',...
    'pos',[20, 20, 60, 15],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'left');

uicontrol('Style', 'edit',...
    'pos',[90, 20, 70, 20],...
    'String', '300',...
    'HorizontalAlignment', 'left',...
    'Tag', 'granularityChooser');

% Create Button to start processing
uicontrol('Style', 'pushbutton', ...
    'String', 'Calculate', ...
    'Position', [105, 60, 100, 25], ...
    'Callback', {@actualizePlot},...
    'Tag', 'startButton');

uicontrol('Style', 'pushbutton', ...
    'String', 'Save Image', ...
    'Position', [105, 30, 100, 25], ...
    'Callback', {@savePlot},...
    'Tag', 'saveButton',...
    'Enable', 'off');

%% Store configuration in image user data
set(figH, 'UserData', config);

% set resize function
set(figH, 'ResizeFcn', @onResize); 

%% Layout components
onResize(figH)

end
function savePlot(figH, ~)
    figH = ancestor(figH,'figure');
    config = get(figH, 'UserData');
    if ~isfield(config, 'lastResult')
        warndlg({'Histogram yet not calculated!', ' ', 'Press "calculate" first'}, 'Not yet calculated', 'modal');
        return;
    end
    [FileName,PathName] = uiputfile(fullfile(config.resultFolder,'histogram_over_time.eps'), 'Choose file to save');
    if ~ischar(FileName) || ~ischar(PathName)
        return;
    end
    file = fullfile(PathName, FileName);
    wbh = swissWaitbar(0, 'Creating image...');
    drawnow();
    fgh = figure('Visible', 'off');
    plotHistogramOverTime(config.imageRange, config.lastResult.binX, config.lastResult.histogramValues, config.lastResult.quantileValues);
    xlabel('Frame (-)');
    ylabel('Intensity (A.U.)');
    setPrintLayout();
    wbh = swissWaitbar(0.5, wbh, 'Saving image...');
    saveFigure(file, 'opengl', [], fgh);
    close(fgh);
    swissWaitbar('close');
    msgbox({'File successfully saved to', file}, 'File Saved', 'modal');
end
function actualizePlot(figH, ~)
    figH = ancestor(figH,'figure');
    set(figH, 'Pointer', 'watch');
    drawnow();
    config = get(figH, 'UserData');
        
    channelChooser = findall(figH, 'Tag', 'channelChooser');
    fluoChannel = get(channelChooser, 'Value');
    granularityChooser = findall(figH, 'Tag', 'granularityChooser');
    numBins = str2double(get(granularityChooser, 'String'));
    
    quantileSteps = [0.25, 0.5, 0.75];
    
    %% Get data
    wbh = swissWaitbar(0, 'Initializing...');
    wbhCallback = @(t) swissWaitbar(0.9*t, wbh, 'Analyzing Frames...');
    [binX, histogramValues, quantileValues] = histogramsOverTime(config, fluoChannel, numBins, quantileSteps, wbhCallback);
    
    %% Plot Histograms over time
    swissWaitbar(0.9, wbh, 'Creating Plot...');
    histogramAxis = findall(figH, 'Tag', 'histogramAxis');
    cla(histogramAxis);
    axes(histogramAxis);
    
    plotHistogramOverTime(config.imageRange, binX, histogramValues{1}, quantileValues{1})
    xlabel('Frame (-)');
    ylabel('Intensity (A.U.)');
    
    set(histogramAxis, 'Tag', 'histogramAxis');
    
    lastResult = struct();
    lastResult.binX = binX;
    lastResult.histogramValues = histogramValues{1};
    lastResult.quantileValues=quantileValues{1};
    config.lastResult = lastResult;
    set(figH, 'UserData', config);
    
    saveButton = findall(figH, 'Tag', 'saveButton');
    set(saveButton, 'Enable', 'on');
    
    swissWaitbar('close');
    
    set(figH, 'Pointer', 'arrow');
end

%% Callback when frame is resized
function onResize(handle, evd) %#ok<INUSD>
    figH = ancestor(handle, 'figure');
    % get size
    figureDim = get(figH, 'Position');
    figureDim = figureDim(3:4);
    topHeight = 180;
    
    imgWidth = floor((figureDim(1) - 80));
    imgHeight = figureDim(2) - topHeight;
    % Place histogram
    set(findall(figH, 'Tag', 'histogramAxis'),       'Position', [60,                figureDim(2) - 40 - imgHeight, imgWidth,       imgHeight]);
    
    configPanelSize = get(findall(figH, 'Tag', 'configurationPanel'), 'Position');
    configPanelSize(1) = 10;
    configPanelSize(3) = figureDim(1)-20;
    set(findall(figH, 'Tag', 'configurationPanel'), 'Position', configPanelSize);
    
    set(findall(figH, 'Tag', 'startButton'),          'Position', [figureDim(1) - 120, 50, 100, 25]);
    set(findall(figH, 'Tag', 'saveButton'),          'Position', [figureDim(1) - 120, 20, 100, 25]);
end

