function figH = analyzeHistograms(segmentConfig)
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
    'imageFileType', imageFileType);
config.fluoTemplates = fluoTemplates;
%% Create Figure
figureDim = [600, 400];
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

% Time changer
timerText = uicontrol('Style', 'text',...
    'String', sprintf('Frame %g', segmentConfig.imageRange(1)),...
    'Position', [round((figureDim(1)-20-100)/2), 40, 100 , 20],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'center',...
    'Tag', 'timeString');

timer = uicontrol('Style', 'slider', ...
    'Min', 0, ...
    'Max', max(length(segmentConfig.imageRange)-1, 1), ...
    'Position', [10, 20, figureDim(1)-20, 20],...
    'SliderStep', 1/length(segmentConfig.imageRange) * [1, 10], ...
    'Tag', 'time',...
    'Callback', {@timeSliderMoved}, ...
    'BackgroundColor', [1,1,1]);
if length(segmentConfig.imageRange) <= 1
    set(timer, 'Visible', 'off');
    set(timerText, 'Visible', 'off');
end

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
    'Callback', {@updateHistogram},...
    'Tag', 'channelChooser');

uicontrol('Style', 'text', ...
    'String', 'Granularity:',...
    'pos',[20, 20, 60, 15],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'left');

uicontrol('Style', 'edit',...
    'pos',[90, 20, 70, 20],...
    'String', '100',...
    'HorizontalAlignment', 'left',...
    'Callback', {@updateHistogram},...
    'Tag', 'granularityChooser');

uicontrol('Style', 'text', ...
    'String', 'Min Intensity:',...
    'pos',[170, 50, 90, 15],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'left');

uicontrol('Style', 'edit',...
    'pos',[240, 50, 70, 20],...
    'String', '0.0',...
    'HorizontalAlignment', 'left',...
    'Callback', {@updateHistogram},...
    'Tag', 'minIntChooser');

uicontrol('Style', 'text', ...
    'String', 'Max Intensity:',...
    'pos',[170, 20, 90, 15],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'left');

uicontrol('Style', 'edit',...
    'pos',[240, 20, 70, 20],...
    'String', '1.0',...
    'HorizontalAlignment', 'left',...
    'Callback', {@updateHistogram},...
    'Tag', 'maxIntChooser');

%% Store configuration in image user data
set(figH, 'UserData', config);

%% load first histogram
moveTimer(figH, 1);

% set resize function
set(figH, 'ResizeFcn', @onResize); 

%% Layout components
onResize(figH)

end

%% Callback when the timer was moved by the user 
% (and only by the user, i.e. not programmatically).
function timeSliderMoved(handle, evd) %#ok<INUSD>
    figH = ancestor(handle, 'figure');
    time = getTime(figH);
    moveTimer(figH, time);
end

%% Function to get current selected image index
function time = getTime(figH)
    sliderH = findall(figH, 'Tag', 'time');
    time = round(get(sliderH, 'Value')) + 1;
end

%% Function for scrolling with mouse
function scrollTime(figH, evd)
    figH = ancestor(figH, 'figure');
    config = get(figH, 'UserData');
    time = getTime(figH) + evd.VerticalScrollCount;
    if time < 1
        time = 1;
    elseif time > length(config.imageRange)
        time = length(config.imageRange);
    end
    moveTimer(figH, time);
end

%% Function to change the current frame
function imageAvailable = moveTimer(figH, frame)
    figH = ancestor(figH, 'figure');
    config = get(figH, 'UserData');

    if frame < 1 ...
            || frame > length(config.imageRange)
        imageAvailable = false;
        return;
    else
        imageAvailable = true;
    end

    sliderH = findall(figH, 'Tag', 'time');
    set(sliderH, 'Value', frame - 1);
    stringH = findall(figH, 'Tag', 'timeString');
    set(stringH, 'String', sprintf('Frame %g', config.imageRange(frame)))
    
    updateHistogram(figH);
end

%% Function to update histogram
function updateHistogram(figH, ~)
    figH = ancestor(figH, 'figure');
    config = get(figH, 'UserData');
    
    frame = getTime(figH);
    
    channelChooser = findall(figH, 'Tag', 'channelChooser');
    fluoChannel = get(channelChooser, 'Value');
    granularityChooser = findall(figH, 'Tag', 'granularityChooser');
    granularity = str2double(get(granularityChooser, 'String'));
    
    minIntChooser = findall(figH, 'Tag', 'minIntChooser');
    minInt = str2double(get(minIntChooser, 'String'));
    
    maxIntChooser = findall(figH, 'Tag', 'maxIntChooser');
    maxInt = str2double(get(maxIntChooser, 'String'));
    
    if isnan(minInt)
        minInt = 0;
    elseif minInt < 0
        minInt = 0;
    elseif minInt > 0.99
        minInt = 0.99;
    end
    
    if isnan(maxInt)
        maxInt = 1;
    elseif minInt > 1
        maxInt = 1;
    elseif maxInt < minInt + 0.01
        maxInt = minInt + 0.01;
    end
    
    set(minIntChooser, 'String', num2str(minInt));
    set(maxIntChooser, 'String', num2str(maxInt));
    
    %% Load segmentation mask
    segmentationMaskFile = fullfile(config.segmentationFolder, sprintf([config.segmentTemplate, '.', config.imageFileType], config.imageRange(frame)));
    if ~exist(segmentationMaskFile, 'file')
        error('SwissSegment:SegmentationMaskNotFound', 'Segmentation Mask not found for frame %g (expected file location: "%s").', frame, segmentationMaskFile);
    end
    segmentionMask = logical(getImage(segmentationMaskFile));

    %% Load fluorescence image
    fluorescenceImageFile = fullfile(config.imageFolder, sprintf([config.fluoTemplates{fluoChannel}, '.', config.imageFileType], config.imageRange(frame)));
    if ~exist(fluorescenceImageFile, 'file')
        error('SwissSegment:FluorescenceImageNotFound', 'Fluorescence image not found for frame %g (expected file location: "%s").', frame, fluorescenceImageFile);
    end
    fluorescenceImage = getImage(fluorescenceImageFile);

    %% get histogram and mean and std
    [binX, binY] = getHistogram(fluorescenceImage, segmentionMask, granularity, minInt, maxInt);
    segFluo = fluorescenceImage(segmentionMask);
    quantVal = quantile(segFluo, [0.25,0.5,0.75]);
    
    %% plot histogram
    histogramAxis = findall(figH, 'Tag', 'histogramAxis');
    cla(histogramAxis);
    axes(histogramAxis);
    plotH = fill( [0,binX,1], [0,binY / max(binY),0], 'k');
    set(plotH, ...
        'FaceColor', 0.8*ones(1,3),...
        'EdgeColor', 0*ones(1,3));
    
    hold on;
    plotH = plot(quantVal(2) * ones(1,2), [0,1]);
    set(plotH, 'Color', 0.5*ones(1,3));
    plotH = plot(quantVal(1) * ones(1,2), [0,1], '-.');
    set(plotH, 'Color', 0.5*ones(1,3));
    plotH = plot(quantVal(3) * ones(1,2), [0,1], '-.');
    set(plotH, 'Color', 0.5*ones(1,3));
    
    xlabel('Intensity (-)');
    ylabel('Density (A.U.)');
    xlim([minInt,maxInt]);
    ylim([0,1]);
    set(histogramAxis, 'Tag', 'histogramAxis');
end

%% Callback when frame is resized
function onResize(handle, evd) %#ok<INUSD>
    figH = ancestor(handle, 'figure');
    % get size
    figureDim = get(figH, 'Position');
    figureDim = figureDim(3:4);
    controlsTop = 80;
    topHeight = 240;
    
    imgWidth = floor((figureDim(1) - 80));
    imgHeight = figureDim(2) - topHeight;
    % Place histogram
    set(findall(figH, 'Tag', 'histogramAxis'),       'Position', [60,                figureDim(2) - 40 - imgHeight, imgWidth,       imgHeight]);
    
    % Time changer
    set(findall(figH, 'Tag', 'timeString'),    'Position', [round((figureDim(1)-20-100)/2), controlsTop + 40, 100 , 20]);
    set(findall(figH, 'Tag', 'time'),          'Position', [10, controlsTop + 20, figureDim(1)-20, 20]);
    
    configPanelSize = get(findall(figH, 'Tag', 'configurationPanel'), 'Position');
    configPanelSize(1) = 10;
    configPanelSize(3) = figureDim(1)-20;
    set(findall(figH, 'Tag', 'configurationPanel'), 'Position', configPanelSize);
end
