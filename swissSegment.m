function figH = swissSegment(imageFolder, imageTemplate, imageFileType, imageRange, resultFolder, segmentationCallbacks, meanImage, autostart, defaultSettings)

%% Check variables
if ~exist('imageFolder', 'var') || isempty(imageFolder)
    imageFolder = [];
end
if ~exist('resultFolder', 'var') || isempty(resultFolder)
    resultFolder = imageFolder;
end

if ~exist('imageTemplate', 'var') || isempty(imageTemplate)
    imageTemplate = [];
end
if  iscell(imageTemplate)
    imageChannelID = [imageTemplate{2:2:end}];
    imageTemplate = imageTemplate(1:2:end);
else
    imageTemplate = {imageTemplate};
    imageChannelID = 1;
end

if ~exist('imageFileType', 'var') || isempty(imageFileType)
    imageFileType = 'tif';
end

if ~exist('imageRange', 'var') || isempty(imageRange)
    imageRange = 1;
end

if ~exist('segmentationCallbacks', 'var')
    segmentationCallbacks = cell(1, 0);
end

if ~exist('meanImage', 'var')
    meanImage = [];
end

if ~exist('autostart', 'var') || isempty(autostart)
    autostart = false;
end

if ~exist('defaultSettings', 'var') || isempty(defaultSettings)
    defaultSettings = struct();
end

%% Configuration of UI
% Size of the figure in pixels
figureDim = [835, 640];

% Maximum of width/height of the image display size in pixels.
maxImageDim = min(floor((figureDim(1) - 35) / 2), figureDim(2) - 240);%400;

%% Create UI
% Create Figure
figH = figure('Units', 'pixels',...
    'Position', [100, 200, figureDim(1), figureDim(2)],...
    'Color', [1, 1, 1],...
    'Name', 'SwissSegment - Finest Segmentation Made in Switzerland', ...
    'NumberTitle', 'off',...
    'DockControls', 'off', ...
    'MenuBar', 'none', ...
    'Toolbar', 'none',...
    'WindowScrollWheelFcn', @scrollTime);

% Create Menu
segMenu = uimenu(figH, 'Label', 'Segmentation'); 
uimenu(segMenu, 'Label',...
    'New Segmentation', ...
    'Callback', @newSegmentation);
uimenu(segMenu, 'Label',...
    'Load Segmentation', ...
    'Callback', @loadSegmentation);

toolsMenu = uimenu(figH, 'Label', 'Tools'); 
uimenu(toolsMenu, 'Label', 'Show Preprocessed Image', ...
    'Callback', @showPreporcessed);

visualizationMenu = uimenu(figH, 'Label', 'Visualization'); 
uimenu(visualizationMenu, 'Label', 'Show Histogram', ...
    'Callback', @showHistogram);
uimenu(visualizationMenu, 'Label', 'Histogram over Time', ...
    'Callback', @showHistogramOverTime);

helpMenu = uimenu(figH, 'Label', 'Help'); 
uimenu(helpMenu, 'Label', 'Developer''s Homepage', ...
    'Callback', @gotoHomepage);
uimenu(helpMenu, 'Label', 'Philosophy', ...
    'Callback', @philosophy);
uimenu(helpMenu, 'Label', 'About', ...
    'Separator', 'on', ...
    'Callback', @about);

% Change icon
setWindowIcon(); 

% Place image axis for original image
myPanel = uipanel('Title', 'Segmentation Definition', 'BackgroundColor', [1, 1, 1],...
    'Units', 'pixels',...
    'Position', [5, figureDim(2) - 45 - maxImageDim, maxImageDim+10, maxImageDim+20], ...
    'Tag', 'OrgImagePanel');
%set(myPanel, 'Background', 'none');
axes('Units', 'pixels', ...
    'Position', [4, 5, maxImageDim, maxImageDim],...
    'Tag', 'OrgImageAxis',...
    'Parent', myPanel);
axis off;

% Place image axis for results
myPanel = uipanel('Title', 'Segmentation Result', 'BackgroundColor', [1, 1, 1],...
    'Units', 'pixels',...
    'Position', [maxImageDim + 20, figureDim(2) - 45 - maxImageDim, maxImageDim+10, maxImageDim+20], ...
    'Tag', 'ResultImagePanel');
%set(myPanel, 'Background', 'none');
axes('Units', 'pixels', ...
    'Position', [4,5, maxImageDim, maxImageDim],...
    'Tag', 'ResultImageAxis',...
    'Parent', myPanel);
axis off;

controlsTop = 130;
sourceSinkLeft = 5;

% Create buttons to define source and sink pixels.
insideOutsideH = uibuttongroup('visible','off', 'Units', 'pixels',...
    'Position', [sourceSinkLeft, 10, 160, controlsTop - 10], 'Title', 'Define Source/Sink',...
    'Tag', 'sinkSource_group',...
    'BackgroundColor', [1,1,1]);
%set(insideOutsideH, 'Background', 'none');
uicontrol('Style', 'text', 'String', 'Brush Size:',...
    'pos',[sourceSinkLeft+5, controlsTop-48, 60, 20],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'left');
uicontrol('Style', 'edit',...
    'pos',[sourceSinkLeft+75, controlsTop-45, 60, 20],...
    'String', '50',...
    'HorizontalAlignment', 'left',...
    'Tag', 'brushSize');

insideH = uicontrol('Style','Radio','String','Object',...
    'pos',[sourceSinkLeft+5, controlsTop-90, 60, 20],'parent', insideOutsideH,'HandleVisibility','off',...
    'Tag', 'sinkSource_source',...
    'BackgroundColor', [1,1,1]);
uicontrol('Style','Radio','String','Erase',...
    'pos',[sourceSinkLeft+5 controlsTop-110 60 20],'parent', insideOutsideH,'HandleVisibility','off',...
    'Tag', 'sinkSource_erase',...
    'BackgroundColor', [1,1,1]);
uicontrol('Style','Radio','String','Background',...
    'pos',[sourceSinkLeft+70 controlsTop-90 80 20],'parent', insideOutsideH,'HandleVisibility','off',...
    'Tag', 'sinkSource_sink',...
    'BackgroundColor', [1,1,1]);
uicontrol('Style','Radio','String','Forbid',...
    'pos',[sourceSinkLeft+70 controlsTop-110 80 20],'parent', insideOutsideH,'HandleVisibility','off',...
    'Tag', 'sinkSource_forbid',...
    'BackgroundColor', [1,1,1]);
set(insideOutsideH,'SelectedObject',insideH);  % No selection
set(insideOutsideH,'Visible','on');

% Create image pre-processing options
thresholdLeft = 170;
myPanel=uipanel('Title', 'Pre-Processing',...
    'BackgroundColor', [1,1,1],...
    'Units', 'pixels',...
    'Position', [thresholdLeft, 10, 265, controlsTop - 10]);
%set(myPanel, 'Background', 'none');
uicontrol('Style', 'text', ...
    'String', 'Method:',...
    'pos',[thresholdLeft+5, controlsTop-40, 50, 15],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'left');
availableFilters = preprocessImage();
uicontrol('Style', 'popupmenu',...
    'pos',[thresholdLeft+55, controlsTop-40, 70, 20],...
    'String', availableFilters,...
    'HorizontalAlignment', 'left',...
    'Tag', 'method');

uicontrol('Style', 'text', ...
    'String', 'Order:',...
    'pos',[thresholdLeft+5, controlsTop-65, 50, 15],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'left');
uicontrol('Style', 'popupmenu',...
    'pos',[thresholdLeft+55, controlsTop-65, 70, 20],...
    'String', {'3', '5', '7', '9', '11', '13', '15', '17', '19', '21'},...
    'Value', 1, ...
    'HorizontalAlignment', 'left',...
    'Tag', 'methodOrder');

uicontrol('Style', 'text', ...
    'String', 'Invert:',...
    'pos',[thresholdLeft+130, controlsTop-40, 60, 15],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'left');
uicontrol('Style', 'popupmenu',...
    'pos',[thresholdLeft+190, controlsTop-40, 70, 20],...
    'String', {'No', 'Yes'},...
    'Value', 2, ...
    'HorizontalAlignment', 'left',...
    'Tag', 'invert');

uicontrol('Style', 'text', ...
    'String', 'Threshold:',...
    'pos',[thresholdLeft+130, controlsTop-65, 60, 15],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'left');
uicontrol('Style', 'edit',...
    'pos',[thresholdLeft+190, controlsTop-65, 70, 20],...
    'String', '0.34',...
    'HorizontalAlignment', 'left',...
    'Tag', 'threshold');

uicontrol('Style', 'pushbutton', ...
    'String', 'Show Pre-Processed Image', ...
    'Position', [thresholdLeft+round((265-200)/2), controlsTop-110, 200, 25], ...
    'Callback', {@showPreporcessed},...
    'Tag', 'showPreporcessedButton');

% Create Graph cut options
segmentationLeft = 440;
myPanel = uipanel('Title', 'Segmentation',...
    'BackgroundColor', [1,1,1],...
    'Units', 'pixels',...
    'Position', [segmentationLeft, 10, 145, controlsTop - 10]);
%set(myPanel, 'Background', 'none');
uicontrol('Style', 'text', ...
    'String', 'Connectivity:',...
    'pos',[segmentationLeft+5, controlsTop-50, 70, 20],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'left');
uicontrol('Style', 'edit',...
    'pos',[segmentationLeft+75, controlsTop-45, 60, 20],...
    'String', '1',...
    'HorizontalAlignment', 'left',...
    'Tag', 'alpha');

uicontrol('Style', 'text', ...
    'String', 'Edge Out:',...
    'pos',[segmentationLeft+5, controlsTop-80, 70, 20],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'left');
uicontrol('Style', 'edit',...
    'pos',[segmentationLeft+75, controlsTop-75, 60, 20],...
    'String', '8',...
    'HorizontalAlignment', 'left',...
    'Tag', 'beta1');

uicontrol('Style', 'text', ...
    'String', 'Edge In:',...
    'pos',[segmentationLeft+5, controlsTop-110, 70, 20],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'left');
uicontrol('Style', 'edit',...
    'pos',[segmentationLeft+75, controlsTop-105, 60, 20],...
    'String', '0',...
    'HorizontalAlignment', 'left',...
    'Tag', 'beta2');

% Create post-processing options
generalLeft = 590;
myPanel = uipanel('Title', 'Post-Processing',...
    'BackgroundColor', [1,1,1],...
    'Units', 'pixels',...
    'Position', [generalLeft, 10, 135, controlsTop - 10]);
%set(myPanel, 'Background', 'none');
uicontrol('Style', 'text', 'String', 'Max. Move:',...
    'pos',[generalLeft+5, controlsTop-50, 60, 20],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'left');
uicontrol('Style', 'edit',...
    'pos',[generalLeft+65, controlsTop-45, 60, 20],...
    'String', '20',...
    'HorizontalAlignment', 'left',...
    'Tag', 'segmentationBorder');

uicontrol('Style', 'text', 'String', 'Min. Size:',...
    'pos',[generalLeft+5, controlsTop-80, 60, 20],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'left');
uicontrol('Style', 'edit',...
    'pos',[generalLeft+65, controlsTop-75, 60, 20],...
    'String', '50',...
    'HorizontalAlignment', 'left',...
    'Tag', 'segmentationMinSize');

uicontrol('Style', 'text', 'String', 'Min. Hole:',...
    'pos',[generalLeft+5, controlsTop-110, 60, 20],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'left');
uicontrol('Style', 'edit',...
    'pos',[generalLeft+65, controlsTop-105, 60, 20],...
    'String', '50',...
    'HorizontalAlignment', 'left',...
    'Tag', 'segmentationMinHole');

% Create Button to start processing
uicontrol('Style', 'pushbutton', ...
    'String', 'Segment', ...
    'Position', [figureDim(1) - 105, controlsTop-30, 100, 25], ...
    'Callback', {@segmentCurrent},...
    'Tag', 'segmentButton');

uicontrol('Style', 'pushbutton', ...
    'String', 'Save and Next', ...
    'Position', [figureDim(1) - 105, controlsTop-60, 100, 25], ...
    'Callback', {@saveNext},...
    'Enable', 'off',...
    'Tag', 'nextButton');

uicontrol('Style', 'pushbutton', ...
    'String', 'Start Iteration', ...
    'Position', [figureDim(1) - 105, controlsTop-90, 100, 25], ...
    'Callback', {@startAutoSegmentation},...
    'Tag', 'startIterationButton');

uicontrol('Style', 'pushbutton', ...
    'String', 'Stop Iteration', ...
    'Position', [figureDim(1) - 105, controlsTop-120, 100, 25], ...
    'Callback', {@stopAutoSegmentation},...
    'Tag', 'StopIterationButton');

% Time changer
timerText = uicontrol('Style', 'text',...
    'String', sprintf('Frame %g', imageRange(1)),...
    'Position', [round((figureDim(1)-20-100)/2), controlsTop + 40, 100 , 20],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'center',...
    'Tag', 'timeString');

timer = uicontrol('Style', 'slider', ...
    'Min', 0, ...
    'Max', max(length(imageRange)-1, 1), ...
    'Position', [10, controlsTop + 20, figureDim(1)-20, 20],...
    'SliderStep', 1/length(imageRange) * [1, 10], ...
    'Tag', 'time',...
    'Callback', {@timeSliderMoved}, ...
    'BackgroundColor', [1,1,1]);
if length(imageRange) <= 1
    set(timer, 'Visible', 'off');
    set(timerText, 'Visible', 'off');
end

% Initialize callbacks
callbackResults = cell(1, length(segmentationCallbacks));
for i=1:length(segmentationCallbacks)
    callbackResults{i} = segmentationCallbacks{i}.initializeCallback( segmentationCallbacks{i}.callbackParams);
end

% Save configuration as user data in figure.
segmentConfig = struct('imageFileType', imageFileType, ...
    'imageFolder', imageFolder,...
    'imageRange', imageRange,...
    'autoIteration', false,...
    'resultFolder', resultFolder,...
    'meanImage', meanImage);

segmentConfig.imageTemplate = imageTemplate;
segmentConfig.imageChannelID = imageChannelID;
segmentConfig.segmentationCallbacks = segmentationCallbacks;
segmentConfig.callbackResults = callbackResults;

% Store configuration in image user data
set(figH, 'UserData', segmentConfig);

% Load last settings, if available
restoreSettings(figH, defaultSettings);

% Load first image
moveTimer(figH, 1);

% set resize function
set(figH, 'ResizeFcn', @onResize); 

% Resize
onResize(myPanel, []);
    
% autostart segmentation
if autostart
    startAutoSegmentation(figH, []);
end
end

%% Callback when frame is resized
function onResize(handle, evd) %#ok<INUSD>
    figH = ancestor(handle, 'figure');
    % get size
    figureDim = get(figH, 'Position');
    figureDim = figureDim(3:4);
    controlsTop = 130;
    topHeight = 240;
    bgBottomMargin = 240;
    segmentConfig = get(figH, 'UserData');
    
    imgPaneWidth = floor((figureDim(1) - 35) / 2);
    imgPaneHeight = figureDim(2) - topHeight;
    
    
    if ~isfield(segmentConfig, 'BFImage')
        imgWidth = imgPaneWidth;
        imgHeight = imgPaneHeight;
    elseif imgPaneWidth / size(segmentConfig.BFImage, 2) > imgPaneHeight / size(segmentConfig.BFImage, 1)
        imgWidth = size(segmentConfig.BFImage, 2) *  imgPaneHeight / size(segmentConfig.BFImage, 1);
        imgHeight = imgPaneHeight;
    else
        imgWidth = imgPaneWidth;
        imgHeight = size(segmentConfig.BFImage, 1) *  imgPaneWidth / size(segmentConfig.BFImage, 2);
    end
    
    % Place image axis system
    set(findall(figH, 'Tag', 'OrgImagePanel'),      'Position', [5,                 figureDim(2) - 45 - imgPaneHeight, imgPaneWidth+10,    imgPaneHeight+20]);
    set(findall(figH, 'Tag', 'OrgImageAxis'), 'Position', [(imgPaneWidth-imgWidth)/2+4, (imgPaneHeight - imgHeight)/2 + 5, imgWidth,       imgHeight]);
    %axis(findall(figH, 'Tag', 'OrgImageAxis' ), 'equal');
    
    set(findall(figH, 'Tag', 'ResultImagePanel'),   'Position', [imgPaneWidth + 20,  figureDim(2) - 45 - imgPaneHeight, imgPaneWidth+10,    imgPaneHeight+20]);
    set(findall(figH, 'Tag', 'ResultImageAxis' ),   'Position', [(imgPaneWidth-imgWidth)/2+4, (imgPaneHeight - imgHeight)/2 + 5, imgWidth,       imgHeight]);
    %axis(findall(figH, 'Tag', 'ResultImageAxis' ), 'equal');
    
    % Buttons
    set(findall(figH, 'Tag', 'segmentButton'),          'Position', [figureDim(1) - 105, controlsTop-30, 100, 25]);
    set(findall(figH, 'Tag', 'nextButton'),             'Position', [figureDim(1) - 105, controlsTop-60, 100, 25]);
    set(findall(figH, 'Tag', 'startIterationButton'),   'Position', [figureDim(1) - 105, controlsTop-90, 100, 25]);
    set(findall(figH, 'Tag', 'StopIterationButton'),    'Position', [figureDim(1) - 105, controlsTop-120, 100, 25]);
    
    % Time changer
    set(findall(figH, 'Tag', 'timeString'),    'Position', [round((figureDim(1)-20-100)/2), controlsTop + 40, 100 , 20]);
    set(findall(figH, 'Tag', 'time'),          'Position', [10, controlsTop + 20, figureDim(1)-20, 20]);
    
end

%% Menu About
function about(~, ~)
    msgbox(sprintf('SwissSegment was created by\nMoritz Lang\nIST Austria\nAm Campus 1\n3400 Klosterneuburg\nAustria\n\nSwissSegment is licensed under the\nGNU GENERAL PUBLIC LICENSE, V3\n\nFor questions and comments, please contact\nmoritz.lang@outlook.com'),...
        'About SwissSegment', ...
        'modal');
end

%% Menu gotoHomepage
function gotoHomepage(~, ~)
    web('http://www.ist.ac.at', '-browser' )
end

%% Menu to start new segmentation
function newSegmentation(figH, ~)
    figH = ancestor(figH, 'figure');
    configurationWizard(figH, @newSegmentationCallback);
end

function newSegmentationCallback(figH, imageFolder, imageTemplate, imageFileType, imageRange, resultFolder, quantificationImages, copyOriginals)
    figH = ancestor(figH, 'figure');
    
    segmentConfig = get(figH, 'UserData');
    
    segmentConfig.imageFileType = imageFileType;
    segmentConfig.imageFolder = imageFolder;
    segmentConfig.imageRange = imageRange;
    segmentConfig.autoIteration = false;
    segmentConfig.resultFolder = resultFolder;
    segmentConfig.imageTemplate = {imageTemplate};
    segmentConfig.imageChannelID = 1;
    segmentConfig.callbackResults = [];
    
    segmentationCallback = createSegmentationCallback(imageFolder, imageRange, imageTemplate, quantificationImages, resultFolder, imageFileType, copyOriginals);
    segmentConfig.segmentationCallbacks = {segmentationCallback};
    
    % Initialize callbacks
    callbackResults = cell(1, length(segmentConfig.segmentationCallbacks));
    for i=1:length(segmentConfig.segmentationCallbacks)
        callbackResults{i} = segmentConfig.segmentationCallbacks{i}.initializeCallback( segmentConfig.segmentationCallbacks{i}.callbackParams);
    end
    segmentConfig.callbackResults = callbackResults;
    
    set(figH, 'UserData', segmentConfig);
    
    set(findall(figH, 'Tag', 'time'), 'Max', max(length(imageRange)-1, 1));
    set(findall(figH, 'Tag', 'time'), 'SliderStep', 1/length(imageRange) * [1,10]);
    set(findall(figH, 'Tag', 'time'), 'Visible', 'on');
    set(findall(figH, 'Tag', 'timeString'), 'Visible', 'on');
    
    restoreSettings(figH, []);
    
    % Load first image
    moveTimer(figH, 1);
end

%% Menu to start load segmentation
function loadSegmentation(figH, ~)
    figH = ancestor(figH, 'figure');
    
    configFile = 'settings.mat';
    folder = '/';
    if exist(configFile, 'file')
        load(configFile, 'lastWizardSettings');
        if isfield(lastWizardSettings, 'resultFolder')
            folder = lastWizardSettings.resultFolder;
        end
    end

    folder = [uigetdir(folder, 'Select segmentation folder'), '/'];
    if length(folder) <= 0 || isnumeric(folder)
        return;
    end
    if ~exist([folder, 'configuration.mat'], 'file')
        warndlg({'Invalid segmentation folder!', ' ', 'Selected folder does not contain', 'segmentation results'}, 'Invalid Segmentation Folder', 'modal');
        return;
    end
    load([folder, 'configuration.mat'], 'segmentConfig');
    if ~exist('segmentConfig', 'var')
        warndlg({'Old program version!', ' ', 'Selected folder does contain', 'segmentation results, however,', 'of a too old version'}, 'Old Segmentation Folder', 'modal');
        return;
    end
    
    segmentationCallback = createSegmentationCallback(segmentConfig.segmentationCallbacks{1});%#ok<NODEF>
    segmentConfig.segmentationCallbacks = {segmentationCallback};
    
    for i=1:length(segmentConfig.segmentationCallbacks) 
        segmentConfig.callbackResults{i} = segmentConfig.segmentationCallbacks{i}.initializeCallback( segmentConfig.segmentationCallbacks{i}.callbackParams);
    end
    set(0,'CurrentFigure', figH);
    set(figH, 'UserData', segmentConfig);
    
    set(findall(figH, 'Tag', 'time'), 'Max', max(length(segmentConfig.imageRange)-1, 1));
    set(findall(figH, 'Tag', 'time'), 'SliderStep', 1/length(segmentConfig.imageRange) * [1, 10]);
    set(findall(figH, 'Tag', 'time'), 'Visible', 'on');
    set(findall(figH, 'Tag', 'timeString'), 'Visible', 'on');

    restoreSettings(figH, []);
    
    % Load first image
    moveTimer(figH, 1);
    
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

%% Helper function to get image name of the original image
function fileName = getOrgImageName(segmentConfig, imgID)
	fileName = cell(1, length(segmentConfig.imageTemplate));
    for i=1:length(fileName)
        fileName{i} = fullfile(segmentConfig.imageFolder, sprintf([segmentConfig.imageTemplate{i}, '.', segmentConfig.imageFileType], segmentConfig.imageRange(imgID)));
    end
end

%% Helper function to get image name of mask
function fileName = getMaskImageName(segmentConfig, imgID)
    fileName = fullfile(segmentConfig.resultFolder, sprintf([segmentConfig.imageTemplate{1}, '_mask.', segmentConfig.imageFileType], segmentConfig.imageRange(imgID)));
end

%% Helper function to get image name of segmentation
function fileName = getSegmentationImageName(segmentConfig, imgID)
    fileName = fullfile(segmentConfig.resultFolder, sprintf([segmentConfig.imageTemplate{1}, '_segment.', segmentConfig.imageFileType], segmentConfig.imageRange(imgID)));
end

%% Helper function to get image name of control image
function fileName = getControlImageName(segmentConfig, imgID)
    fileName = fullfile(segmentConfig.resultFolder, sprintf([segmentConfig.imageTemplate{1}, '_control.', segmentConfig.imageFileType], segmentConfig.imageRange(imgID)));
end

%% Function for scrolling with mouse
function scrollTime(handle, evd)
    figH = ancestor(handle, 'figure');
    segmentConfig = get(figH, 'UserData');
    time = getTime(figH) + evd.VerticalScrollCount;
    if time < 1
        time = 1;
    elseif time > length(segmentConfig.imageRange)
        time = length(segmentConfig.imageRange);
    end
    moveTimer(figH, time);
end

%% Function to load the data of a given time
function imageAvailable = moveTimer(figH, time, mask, segmentedImage)
    segmentConfig = get(figH, 'UserData');

    if time < 1 ...
            || time > length(segmentConfig.imageRange) ...
            || isempty(segmentConfig.imageTemplate{1})
        imageAvailable = false;
        return;
    else
        imageAvailable = true;
    end

    sliderH = findall(figH, 'Tag', 'time');
    set(sliderH, 'Value', time - 1);
    stringH = findall(figH, 'Tag', 'timeString');
    set(stringH, 'String', sprintf('Frame %g', segmentConfig.imageRange(time)))

    fileNames = getOrgImageName(segmentConfig, time);
    orgImage    = getImage(fileNames{1}, segmentConfig.imageChannelID(1));
    if length(fileNames) > 1
        for i=2:length(fileNames)
            orgImage = orgImage + getImage(fileNames{i}, segmentConfig.imageChannelID(i));
        end
        orgImage = orgImage / length(fileNames);
    end
        
    if ~isempty(segmentConfig.meanImage)
        orgImage = min(orgImage + max(max(segmentConfig.meanImage))-segmentConfig.meanImage, 1);
    end
    
    if ~exist('mask', 'var')
        maskFile = getMaskImageName(segmentConfig, time);
        if exist(maskFile, 'file')
            mask = getImage(maskFile);
            mask = round(mask .* 3 - 2);
        else
            mask = [];
        end
    end
    setImage(figH, orgImage, mask);
    
    refreshWhole = false;
    if ~exist('segmentedImage', 'var')
        refreshWhole = true;
        segmentedImageFile = getSegmentationImageName(segmentConfig, time);
        if exist(segmentedImageFile, 'file')
            segmentedImage = logical(getImage(segmentedImageFile));
        else
            segmentedImage = [];
        end
    end
    if ~isempty(segmentedImage)
        settings = getSettings(figH);
        hardConstraints =  getHardConstraints(segmentedImage, settings.maxMovement);
        wholeImage = getWholeImage(figH, orgImage, segmentedImage);
        set(findall(figH, 'Tag', 'nextButton'), 'Enable', 'on');
    else
        hardConstraints = [];
        wholeImage = [];
        set(findall(figH, 'Tag', 'nextButton'), 'Enable', 'off');
    end
    if refreshWhole
        setResultImage(figH, wholeImage); 
    end
    
    segmentConfig = get(figH, 'UserData');
    segmentConfig.hardConstraints = hardConstraints;
    segmentConfig.segmentedImage = segmentedImage;
    segmentConfig.mask = mask;
    set(figH, 'UserData', segmentConfig);
end

%% Callback to stop the auto segmentation of all images
function stopAutoSegmentation(figH, evd) %#ok<INUSD>
    try
        figH = ancestor(figH,'figure');
        segmentConfig = get(figH, 'UserData');
        segmentConfig.autoIteration = false;
        set(figH, 'UserData', segmentConfig);
    catch exception
        errordlg(exception.message, 'Error occured', 'modal');
    end
end

%% Start auto-segmentation of images
function startAutoSegmentation(figH, evd)
    try
        figH = ancestor(figH,'figure');
        segmentConfig = get(figH, 'UserData');
        segmentConfig.autoIteration = true;
        set(figH, 'UserData', segmentConfig);

        while true
             % Check if stop button was pressed
            drawnow();
            segmentConfig = get(figH, 'UserData');
            if ~segmentConfig.autoIteration
                break;
            end

            % segment current
            segmentCurrent(figH, []);

            % go to next
            imageAvailable = saveNext(figH, evd);
            if ~imageAvailable
                segmentConfig = get(figH, 'UserData');
                callbackResults = segmentConfig.callbackResults;
                for i=1:length(segmentConfig.segmentationCallbacks)
                    if isfield(segmentConfig.segmentationCallbacks{i}, 'uninitializeCallback')
                        segmentConfig.segmentationCallbacks{i}.uninitializeCallback(callbackResults{i}, figH);
                    end
                end
                break;
            end
        end
    catch exception
        errordlg(exception.message, 'Error occured', 'modal');
    end
end

%% Function to return a struct with the current settings
function settings = getSettings(figH)
    % Get parameters for segmentation algorithm
    alpha = str2double(get(findall(figH, 'Tag', 'alpha'), 'String'));
    if isempty(alpha)
        alpha = 20;
        set(findall(figH, 'Tag', 'alpha'), 'String', '20');
    end
    beta1 = str2double(get(findall(figH, 'Tag', 'beta1'), 'String'));
    if isempty(beta1)
        beta1 = 20;
        set(findall(figH, 'Tag', 'beta1'), 'String', '20');
    end
    beta2 = str2double(get(findall(figH, 'Tag', 'beta2'), 'String'));
    if isempty(beta2)
        beta2 = 0;
        set(findall(figH, 'Tag', 'beta2'), 'String', '0');
    end
    maxMovement = str2double(get(findall(figH, 'Tag', 'segmentationBorder'), 'String'));
    if isempty(maxMovement)
        maxMovement = 30;
        set(findall(figH, 'Tag', 'segmentationBorder'), 'String', '30');
    end
    
    minSize = str2double(get(findall(figH, 'Tag', 'segmentationMinSize'), 'String'));
    if isempty(minSize)
        minSize = 50;
        set(findall(figH, 'Tag', 'segmentationMinSize'), 'String', '50');
    end
    
    minHole = str2double(get(findall(figH, 'Tag', 'segmentationMinHole'), 'String'));
    if isempty(minHole)
        minHole = 50;
        set(findall(figH, 'Tag', 'segmentationMinHole'), 'String', '50');
    end
    
    threshold = str2double(get(findall(figH, 'Tag', 'threshold'), 'String'));
    if isempty(alpha)
        threshold = 0.5;
        set(findall(figH, 'Tag', 'threshold'), 'String', '0.5');
    end
    method = get(findall(figH, 'Tag', 'method'), 'String');
    method = method{get(findall(figH, 'Tag', 'method'), 'Value')};

    methodOrders = get(findall(figH, 'Tag', 'methodOrder'), 'String');
    methodOrder = str2double(methodOrders{get(findall(figH, 'Tag', 'methodOrder'), 'Value')});
    
    invert = logical(get(findall(figH, 'Tag', 'invert'), 'Value') - 1);
    
    settings = struct('alpha', alpha,...
        'beta1', beta1,...
        'beta2', beta2,...
        'maxMovement', maxMovement,...
        'minSize', minSize,...
        'minHole', minHole,...
        'threshold', threshold,...
        'method', method,...
        'methodOrder', methodOrder,...
        'invert', invert);
end

%% Function to load settings saved previously into layout
function restoreSettings(figH, defaultSettings)

    segmentConfig = get(figH, 'UserData');
    settingsFile = [segmentConfig.resultFolder, 'configuration.mat'];
    if ~exist(settingsFile, 'file')
        if isempty(defaultSettings)
            return;
        end
        settings = defaultSettings;
    else
        load(settingsFile, 'settings');
    end
        
    if isfield(settings, 'alpha')
        set(findall(figH, 'Tag', 'alpha'), 'String', num2str(settings.alpha));
    end
    if isfield(settings, 'beta1')
        set(findall(figH, 'Tag', 'beta1'), 'String', num2str(settings.beta1));
    end
    if isfield(settings, 'beta2')
        set(findall(figH, 'Tag', 'beta2'), 'String', num2str(settings.beta2));
    end
    if isfield(settings, 'maxMovement')
        set(findall(figH, 'Tag', 'segmentationBorder'), 'String', num2str(settings.maxMovement));
    end
    if isfield(settings, 'threshold')
        set(findall(figH, 'Tag', 'threshold'), 'String', num2str(settings.threshold));
    end
    
    if isfield(settings, 'minSize')
        set(findall(figH, 'Tag', 'segmentationMinSize'), 'String', num2str(settings.minSize));
    end
    if isfield(settings, 'minHole')
        set(findall(figH, 'Tag', 'segmentationMinHole'), 'String', num2str(settings.minHole));
    end
    
    if isfield(settings, 'method')
        % Compatibility to older versions with combined method/order
        if ~isfield(settings, 'methodOrder')
            [methodOrderStr, methodOrderStart] = regexp(settings.method, '\d*$', 'match');
            if isempty(methodOrderStart)
                settings.methodOrder = 3;
            else
                settings.methodOrder = str2double(methodOrderStr);
                settings.method = settings.method(1:methodOrderStart-1);
            end
        end
        
        methods = get(findall(figH, 'Tag', 'method'), 'String');
        for i=1:length(methods)
            if strcmpi(methods{i}, settings.method)
                set(findall(figH, 'Tag', 'method'), 'Value', i);
                break;
            end
        end
        
        set(findall(figH, 'Tag', 'methodOrder'), 'Value', floor(settings.methodOrder/2));
    end
    if isfield(settings, 'invert')
        if settings.invert
            set(findall(figH, 'Tag', 'invert'), 'Value', 2);
        else
            set(findall(figH, 'Tag', 'invert'), 'Value', 1);
        end
    end
end

%% Function to segment current image.
function segmentCurrent(figH, evd) %#ok<INUSD>
    try
        % Load configuration
        figH = ancestor(figH,'figure');
        set(figH, 'Pointer', 'watch');
        drawnow();
        segmentConfig = get(figH, 'UserData');

        settings = getSettings(figH);

        % Load image which should be segmented
        orgImage    = segmentConfig.orgImage;

        % Define hard constraint for segmentation
        % Create segmentation mask containing user defined sink and source pixel
        % definitions
        data = get(segmentConfig.imageH, 'CData');
        mask = zeros(size(orgImage, 1), size(orgImage, 2));
        mask(data(:, :, 2) == intmax('uint8')) = 1;
        mask(data(:, :, 3) == intmax('uint8')) = -1;
        mask(data(:, :, 1) == intmax('uint8')) = -2;

        % Segment image, using the mask.
        segmentedImage = processImage(orgImage, mask, settings.alpha, settings.beta1, ...
            settings.beta2, settings.threshold, settings.method, settings.methodOrder, settings.invert,...
            settings.minHole, settings.minSize);

        % Create hard constraints for segmentation for next image
        hardConstraints =  getHardConstraints(segmentedImage, settings.maxMovement);
        hardConstraints(data(:, :, 1) == intmax('uint8')) = -2;
        wholeImage = getWholeImage(figH, orgImage, segmentedImage);
        setResultImage(figH, wholeImage); 

        % Save last state
        segmentConfig = get(figH, 'UserData');
        segmentConfig.hardConstraints = hardConstraints;
        segmentConfig.segmentedImage = segmentedImage;
        segmentConfig.mask = mask;
        set(figH, 'UserData', segmentConfig);
        set(findall(figH, 'Tag', 'nextButton'), 'Enable', 'on');

        set(figH, 'Pointer', 'arrow');
    catch exception
        errordlg(exception.message, 'Error occured', 'modal');
    end
end

%% Show histogram
function showHistogram(figH, ~)
    figH = ancestor(figH,'figure');
    segmentConfig = get(figH, 'UserData');
    analyzeHistograms(segmentConfig);
end

%% Show histogram over time
function showHistogramOverTime(figH, ~)
    figH = ancestor(figH,'figure');
    segmentConfig = get(figH, 'UserData');
    analyzeHistogramsOverTime(segmentConfig);
end
%% Show preprocessed image
function showPreporcessed(figH, ~)
    try
        % Load configuration
        figH = ancestor(figH,'figure');
        set(figH, 'Pointer', 'watch');
        drawnow();
        segmentConfig = get(figH, 'UserData');
        
        if ~isfield(segmentConfig, 'orgImage')
            error('SwissSegment:NoImageLoaded', 'No image loaded which could be pre-processed.')
        end
        
        settings = getSettings(figH);
        
        % Segment image, using the mask.
        orgImage = preprocessImage(segmentConfig.orgImage, settings.threshold, settings.method, settings.methodOrder, settings.invert);
        set(figH, 'Pointer', 'arrow');
    catch exception
        errordlg(exception.message, 'Error occured', 'modal');
        set(figH, 'Pointer', 'arrow');
        return;
    end
    
    imageWidth = 400;
    
    % show image
    figure('Name', 'Preoprocessed Image',...
            'NumberTitle', 'off',...
            'Position', [300, 300, imageWidth, size(orgImage,1) * imageWidth / size(orgImage,2)],...
            'Color', [1, 1, 1],...
            'DockControls', 'off', ...
            'Toolbar', 'none', ...
            'MenuBar', 'none');
    % Change icon
    setWindowIcon(); 
        
    image(orgImage*double(intmax('uint8')));
    %%colormap(gray(double(intmax('uint8'))));
    colormap([autumn(double(intmax('uint8') / uint8(2))); flipud(summer(double(intmax('uint8') / uint8(2))+1))]);
    axis off;
    axis equal;
end

%% Function to set the image displaying the segmentation result
function setResultImage(figH, wholeImage)
    % display output image
    set(0,'CurrentFigure', figH);
    axisH = findall(figH, 'Tag', 'ResultImageAxis');
    set(figH, 'CurrentAxes', axisH);
    if ~isempty(wholeImage)
        image(wholeImage);
        colormap gray;
    else
        cla();
    end
    axis off;
        
    
    figureDim = get(figH, 'Position');
    figureDim = figureDim(3:4);
    panWidth = floor((figureDim(1) - 35) / 2);
    panHeight = figureDim(2) - 240;
%     if ~isempty(wholeImage)
%         if size(wholeImage, 1) / panHeight > size(wholeImage, 2) / panWidth
%             imgWidth = round(size(wholeImage, 2) / size(wholeImage, 1) * panHeight);
%             imgHeight = panHeight;
%         else
%             imgWidth = panWidth;
%             imgHeight = round(size(wholeImage, 1) / size(wholeImage, 2) * panWidth);
%         end
%     else
%         cla();
%         imgWidth = panWidth;
%         imgHeight = panHeight;
%         
%     end
      
    set(axisH, 'Tag', 'ResultImageAxis');
    onResize(axisH, []);
end

%% Saves the current segmentation result and switches to the next image
function imageAvailable = saveNext(figH, evd) %#ok<INUSD>
    try
        % Load current state
        figH = ancestor(figH,'figure');
        set(figH, 'Pointer', 'watch');
        drawnow();
        segmentConfig = get(figH, 'UserData');
        if isempty(segmentConfig.segmentedImage)
            return;
        end
        imgID = getTime(figH);

        % Save current result
        if ~exist(segmentConfig.resultFolder, 'dir')
            mkdir(segmentConfig.resultFolder);
        end
        settings = getSettings(figH); %#ok<NASGU>
        save(fullfile(segmentConfig.resultFolder, 'configuration.mat'), 'settings', 'segmentConfig');
        saveImage(segmentConfig.segmentedImage, getSegmentationImageName(segmentConfig, imgID));
        saveImage((segmentConfig.mask + 2) ./ 3, getMaskImageName(segmentConfig, imgID));

        % Create simple control image
        H = conv2(double(segmentConfig.segmentedImage),[-1,0,1], 'same');
        V = conv2(double(segmentConfig.segmentedImage),[-1;0;1], 'same');
        edgeImage = abs(H)|abs(V);
        edgeImage = logical(conv2(double(edgeImage), ones(3), 'same'));
        R = (segmentConfig.orgImage - min(min(segmentConfig.orgImage))) / (max(max(segmentConfig.orgImage)) - min(min(segmentConfig.orgImage)));
        G = R; 
        B = R;
        R(edgeImage) = 0.1;
        G(edgeImage) = 0.1;
        B(edgeImage) = 0.7;
        controlImage = cat(3, R, G, B);
        controlImage(:, :, 1) = R;
        controlImage(:, :, 2) = G;
        controlImage(:, :, 3) = B;
        saveImage(controlImage, getControlImageName(segmentConfig, imgID));

        % Call callbacks
        segmentConfig = get(figH, 'UserData');
        callbackResults = segmentConfig.callbackResults;
        for i=1:length(segmentConfig.segmentationCallbacks)
            callbackResults{i} = segmentConfig.segmentationCallbacks{i}.iterationCallback(imgID, segmentConfig.segmentedImage, callbackResults{i});
        end
        segmentConfig = get(figH, 'UserData');
        segmentConfig.callbackResults = callbackResults;
        set(figH, 'UserData', segmentConfig);

        % Go to next image if possible
        imageAvailable = moveTimer(figH, imgID+1, segmentConfig.hardConstraints, []);
        set(figH, 'Pointer', 'arrow');
    catch exception
        imageAvailable = false;
        errordlg(exception.message, 'Error occured', 'modal');
    end
end

%% Helper function to create nice image
function wholeImage = getWholeImage(~, orgImage, segmentedImage)

% Find borders of segmentated object
H = conv2(double(segmentedImage),[-1,0,1], 'same');
V = conv2(double(segmentedImage),[-1;0;1], 'same');
edgeImage = abs(H)|abs(V);
edgeImage = logical(conv2(double(edgeImage), ones(3), 'same'));

wholeImage = zeros(size(orgImage,1), size(orgImage,2), 3);
R = (orgImage - min(min(orgImage))) / (max(max(orgImage)) - min(min(orgImage)));
G = R;
B = R;

R(edgeImage) = 0.1;
G(edgeImage) = 0.1;
B(edgeImage) = 0.7;

wholeImage(:, :, 1) = R;
wholeImage(:, :, 2) = G;
wholeImage(:, :, 3) = B;

wholeImage = uint8(double(intmax('uint8')) * wholeImage);
end

%% Helper function to get hard constraints from segmentation result.
function hardConstraints = getHardConstraints(segmentedImage, maxMovement)
    hardConstraints =  (bwdist(~segmentedImage) > maxMovement) - (bwdist(segmentedImage) > maxMovement);
end

%% helper function to apply already existing mask
function setImage(figH, orgImage, hardConstraints)
    
    R = (orgImage - min(min(orgImage))) / (max(max(orgImage)) - min(min(orgImage)))* (double(intmax('uint8'))-1);
    G = R;
    B = R;
    segmentConfig = get(figH, 'UserData');
    segmentConfig.BFImage = uint8(cat(3, R, G, B));
    set(figH, 'UserData', segmentConfig);
    
    if exist('hardConstraints', 'var') && ~isempty(hardConstraints)
        G(hardConstraints > 0)   = double(intmax('uint8'));
        B(hardConstraints == -1) = double(intmax('uint8'));
        R(hardConstraints < -1)  = double(intmax('uint8'));
    end
    
    BFImage = uint8(cat(3, R, G, B));
    
    set(0,'CurrentFigure', figH);
    axisH = findall(figH, 'Tag', 'OrgImageAxis');
    set(figH, 'CurrentAxes', axisH);
    imageH = image(BFImage);
    axis off;
    
    figureDim = get(figH, 'Position');
    figureDim = figureDim(3:4);
    panWidth = floor((figureDim(1) - 35) / 2);
    panHeight = figureDim(2) - 240;
    set(axisH, 'Tag', 'OrgImageAxis');

    % Initialize draggin callback
    set(imageH,'ButtonDownFcn',{@startDrag})

    % Save handle to new image.
    segmentConfig = get(figH, 'UserData');
    segmentConfig.imageH = imageH;
    segmentConfig.orgImage = orgImage;
    set(figH, 'UserData', segmentConfig);
    
    onResize(axisH, []);
end

%% Function to start dragging.
function startDrag(figH, evd)

    figH = ancestor(figH,'figure');

    % get the values and store them in the figure's appdata
    props.WindowButtonMotionFcn = get(figH,'WindowButtonMotionFcn');
    props.WindowButtonUpFcn = get(figH,'WindowButtonUpFcn');

    setappdata(figH,'TestGuiCallbacks',props);

    drag(figH, evd);
    
    set(figH, 'WindowButtonMotionFcn', {@drag})
    set(figH, 'WindowButtonUpFcn', {@stopDrag})
end

%% Dragging function to define sink and source pixels
function drag(figH, evd) %#ok<INUSD>

    % Load parameters
    segmentConfig = get(figH, 'UserData');
    mousePos = get(figH,'CurrentPoint');
    axisPos = get(findall(figH, 'Tag', 'OrgImageAxis'), 'Position');
    
    panelPos = get(findall(figH, 'Tag', 'OrgImagePanel'), 'Position');
    
    
    data = get(segmentConfig.imageH, 'CData');
    width = size(data, 2);
    height = size(data, 1);

    % Get mouse position
    x = (mousePos(1)-axisPos(1)-panelPos(1)) / axisPos(3);
    y = 1- (mousePos(2)-axisPos(2)-panelPos(2)) / axisPos(4);
    xData = ceil(width * x);
    yData = ceil(height * y);

    % Define pixels which should be painted
    paintRadius = str2double(get(findall(figH, 'Tag', 'brushSize'), 'String'));
    if isempty(paintRadius)
        paintRadius = 5;
        set(findall(figH, 'Tag', 'brushSize'), 'String', '5');
    end
    paintImg = zeros(1+2*paintRadius, 1+2*paintRadius);
    paintImg(1+paintRadius, 1+paintRadius) = 1;
    paintImg = bwdist(paintImg);
    [rows, cols] = find(paintImg <= paintRadius);
    rows = rows - paintRadius - 1 + yData;
    cols = cols - paintRadius - 1 + xData;
    invID = rows < 1 | rows > size(data,1) | cols < 1 | cols > size(data,2);
    rows(invID) = [];
    cols(invID) = [];
    if isempty(rows) || isempty(cols)
        return;
    end

    % Paint
    segmentConfig = get(figH, 'UserData');
    orgFig = segmentConfig.BFImage;
        
    selectedChoice = get(findall(figH, 'Tag', 'sinkSource_group'), 'SelectedObject');
    if selectedChoice == findall(figH, 'Tag', 'sinkSource_source')
        data(sub2ind(size(data), rows, cols, 1 * ones(size(rows, 1), size(rows, 2)))) = orgFig(sub2ind(size(data), rows, cols, 1 * ones(size(rows, 1), size(rows, 2))));
        data(sub2ind(size(data), rows, cols, 2 * ones(size(rows, 1), size(rows, 2)))) = intmax('uint8');
        data(sub2ind(size(data), rows, cols, 3 * ones(size(rows, 1), size(rows, 2)))) = orgFig(sub2ind(size(data), rows, cols, 3 * ones(size(rows, 1), size(rows, 2))));
    elseif selectedChoice == findall(figH, 'Tag', 'sinkSource_sink')
        data(sub2ind(size(data), rows, cols, 1 * ones(size(rows, 1), size(rows, 2)))) = orgFig(sub2ind(size(data), rows, cols, 1 * ones(size(rows, 1), size(rows, 2))));
        data(sub2ind(size(data), rows, cols, 2 * ones(size(rows, 1), size(rows, 2)))) = orgFig(sub2ind(size(data), rows, cols, 2 * ones(size(rows, 1), size(rows, 2))));
        data(sub2ind(size(data), rows, cols, 3 * ones(size(rows, 1), size(rows, 2)))) = intmax('uint8');
    elseif selectedChoice == findall(figH, 'Tag', 'sinkSource_forbid')
        data(sub2ind(size(data), rows, cols, 1 * ones(size(rows, 1), size(rows, 2)))) = intmax('uint8');
        data(sub2ind(size(data), rows, cols, 2 * ones(size(rows, 1), size(rows, 2)))) = orgFig(sub2ind(size(data), rows, cols, 2 * ones(size(rows, 1), size(rows, 2))));
        data(sub2ind(size(data), rows, cols, 3 * ones(size(rows, 1), size(rows, 2)))) = orgFig(sub2ind(size(data), rows, cols, 3 * ones(size(rows, 1), size(rows, 2))));
    else % erase
        data(sub2ind(size(data), rows, cols, 1 * ones(size(rows, 1), size(rows, 2)))) = orgFig(sub2ind(size(data), rows, cols, 1 * ones(size(rows, 1), size(rows, 2))));
        data(sub2ind(size(data), rows, cols, 2 * ones(size(rows, 1), size(rows, 2)))) = orgFig(sub2ind(size(data), rows, cols, 2 * ones(size(rows, 1), size(rows, 2))));
        data(sub2ind(size(data), rows, cols, 3 * ones(size(rows, 1), size(rows, 2)))) = orgFig(sub2ind(size(data), rows, cols, 3 * ones(size(rows, 1), size(rows, 2))));
    end
    set(segmentConfig.imageH, 'CData', data);

end

%% Function to stop dragging.
function stopDrag(figH,evd) %#ok<INUSD>

fig = ancestor(figH,'figure');

props = getappdata(fig,'TestGuiCallbacks');
set(fig,props);
end