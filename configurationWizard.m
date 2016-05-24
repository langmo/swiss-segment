function configurationWizard(mainFigureH, callback)
%% Configuration of UI
% Size of the figure in pixels
figureDim = [500, 280];

tabStrings = {'Segmentation Image', 'Quantification Images'};
[figH, ~, sheetPanels, buttonPanel] = ...
   tabdlg('create', tabStrings, [], @tabSelectionCallback, figureDim);

% Change icon
setWindowIcon(); 

segmentationTab = sheetPanels(1);
quantificationTab = sheetPanels(2);

set(figH, 'Units', 'pixels',...
    'Color', [1, 1, 1],...
    'Name', 'New Segmentation', 'NumberTitle', 'off',...
    'DockControls', 'off', 'MenuBar', 'none', 'Resize', 'off', 'Toolbar', 'none',...
    'WindowStyle', 'modal');
set(buttonPanel, 'BackgroundColor', [1,1,1]);

%% main buttons
buttonSize = [80, 25];
buttonPanelPos = getpixelposition(buttonPanel);
buttonOffsets = [5, 10];
leftButtonOffset = buttonPanelPos(3)/2 - ...
   (buttonOffsets(1) + 2 * buttonSize(1))/2;
uicontrol('Style', 'pushbutton', 'String','OK',...
    'Position', ...
       [buttonOffsets(1) * 1 + leftButtonOffset, ...
       buttonOffsets(2)/2, buttonSize], ...
    'HandleVisibility','off',...
    'Tag', 'commitButton',...
    'BackgroundColor', [1,1,1], ...
    'Callback', {@commitData});

uicontrol('Style', 'pushbutton', 'String','Cancel',...
    'Position', ...
       [buttonOffsets(1) * 2 + leftButtonOffset + buttonSize(1), ...
       buttonOffsets(2)/2, buttonSize], ...
    'HandleVisibility','off',...
    'Tag', 'commitButton',...
    'BackgroundColor', [1,1,1], ...
    'Callback', 'close(gcbf)');

%% Segmentation Definition
% Place image axis system
segmentationPanel = uipanel(segmentationTab, 'Title', 'Segmentation Configuration',...
    'Units', 'pixels',...
    'Position', [5, 10, 330, figureDim(2)-15]);
leftElementsPos = 5;

wizardPanel = uipanel(segmentationTab, 'Title', 'Wizard', ...
    'Units', 'pixels',...
    'Position', [345, 10, 150, figureDim(2)-15]);
wizardLeftElementsPos = 5;

topElementsPos = figureDim(2)-50;
uicontrol(segmentationPanel, 'Style', 'text', 'String', 'Image folder:',...
    'pos',[leftElementsPos, topElementsPos, 300, 15],...
    'HorizontalAlignment', 'left');
uicontrol(segmentationPanel, 'Style', 'edit',...
    'pos',[leftElementsPos, topElementsPos-20, 300, 20],...
    'String', '',...
    'HorizontalAlignment', 'left',...
    'Tag', 'segmentationPath',...
    'BackgroundColor', [1,1,1]);

uicontrol(segmentationPanel, 'Style', 'text', 'String', 'Segmentation image template:',...
    'pos',[leftElementsPos, topElementsPos-45, 300, 15],...
    'HorizontalAlignment', 'left');
uicontrol(segmentationPanel, 'Style', 'edit',...
    'pos',[leftElementsPos, topElementsPos-65, 300, 20],...
    'String', '',...
    'HorizontalAlignment', 'left',...
    'Tag', 'segmentationTemplate',...
    'BackgroundColor', [1,1,1]);

uicontrol(segmentationPanel, 'Style', 'text', 'String', 'Image Range:',...
    'pos',[leftElementsPos, topElementsPos-90, 300, 15],...
    'HorizontalAlignment', 'left');
uicontrol(segmentationPanel, 'Style', 'edit',...
    'pos',[leftElementsPos, topElementsPos-110, 50, 20],...
    'String', '',...
    'HorizontalAlignment', 'left',...
    'Tag', 'imageLow',...
    'String', '1',...
    'BackgroundColor', [1,1,1]);
uicontrol(segmentationPanel, 'Style', 'text', 'String', 'to',...
    'pos',[leftElementsPos+55, topElementsPos-110, 13, 15],...
    'HorizontalAlignment', 'left');
uicontrol(segmentationPanel, 'Style', 'edit',...
    'pos',[leftElementsPos+70, topElementsPos-110, 50, 20],...
    'String', '',...
    'HorizontalAlignment', 'left',...
    'Tag', 'imageHigh',...
    'String', '2',...
    'BackgroundColor', [1,1,1]);

uicontrol(segmentationPanel, 'Style', 'text', 'String', 'Result folder:',...
    'pos',[leftElementsPos, topElementsPos-135, 300, 15],...
    'HorizontalAlignment', 'left');
uicontrol(segmentationPanel, 'Style', 'edit',...
    'pos',[leftElementsPos, topElementsPos-155, 300, 20],...
    'String', '',...
    'HorizontalAlignment', 'left',...
    'Tag', 'resultFolder',...
    'BackgroundColor', [1,1,1]);

uicontrol(segmentationPanel, 'Style', 'checkbox', 'String', 'Copy raw images to result folder.',...
    'pos',[leftElementsPos, topElementsPos-180, 300, 15],...
    'Tag', 'copyOriginals',...
    'HorizontalAlignment', 'left');

wizardHelpText = 'To use the wizard, select either all images which should be analyzed, or alternatively the first and the last image which should be analyzed.';
uicontrol(wizardPanel, 'Style', 'text', 'String', sprintf(wizardHelpText),...
    'pos',[wizardLeftElementsPos, topElementsPos-110, 130, 130],...
    'HorizontalAlignment', 'left');
uicontrol(wizardPanel, 'Style', 'pushbutton', 'String', 'Start Wizard',...
    'pos',[wizardLeftElementsPos, 5, 135, 25], 'HandleVisibility','off',...
    'Tag', 'commitButton',...
    'Callback', {@selectTemplateFile});

%% Quantification Definition
quantificationPanel = uipanel(quantificationTab, 'Title', 'Quantification Images',...
    'Units', 'pixels',...
    'Position', [5, 10, figureDim(1)-10, figureDim(2)-15],...
    'Visible', 'off', ...
    'Tag', 'quantificationPanel');
leftElementsPos = 5;
topElementsPos = figureDim(2)-50;

uicontrol(quantificationPanel, 'Style', 'text', 'String', 'Defined image templates:',...
    'pos',[leftElementsPos, topElementsPos, 300, 15],...
    'HorizontalAlignment', 'left');
uicontrol(quantificationPanel, 'Style','listbox',...
    'String',{},... 
    'Tag', 'quantificationList',...
    'pos',[leftElementsPos, topElementsPos-105, figureDim(1)-30, 100],...
    'BackgroundColor', [1,1,1], ...
    'Callback', @listCallback); 
uicontrol(quantificationPanel, 'Style', 'pushbutton', 'String', 'Remove',...
    'pos',[leftElementsPos, topElementsPos-135, 80, 25], ...
    'Tag', 'removeQuantiButton',...
    'Callback', {@removeQuantification});


uicontrol(quantificationPanel, 'Style', 'text', 'String', 'Template:',...
    'pos',[leftElementsPos, topElementsPos-160, 300, 15],...
    'HorizontalAlignment', 'left');
uicontrol(quantificationPanel, 'Style', 'edit',...
    'pos',[leftElementsPos, topElementsPos-180, figureDim(1)-30, 20],...
    'String', '',...
    'HorizontalAlignment', 'left',...
    'Tag', 'quantiImageTemplate',...
    'BackgroundColor', [1,1,1]);
uicontrol(quantificationPanel, 'Style', 'pushbutton', 'String', 'Add',...
    'pos',[leftElementsPos, topElementsPos-205, 80, 25], ...
    'Tag', 'addQuantiButton',...
    'Callback', {@addQuantification});
uicontrol(quantificationPanel, 'Style', 'pushbutton', 'String', 'Replace',...
    'pos',[leftElementsPos+85, topElementsPos-205, 80, 25], ...
    'Tag', 'wizardQuantiButton',...
    'Callback', {@replaceQuantification});
uicontrol(quantificationPanel, 'Style', 'pushbutton', 'String', 'Wizard',...
    'pos',[leftElementsPos+170, topElementsPos-205, 80, 25], ...
    'Tag', 'wizardQuantiButton',...
    'Callback', {@selectQuantificationFile});

%% Load data and show window
set(figH, 'UserData', {mainFigureH, callback});
loadSettings(figH);

set(figH, 'Visible', 'on');

end

function selectQuantificationFile(figH, ~)
    figH = ancestor(figH,'figure');
    
    currentFolder = get(findall(figH, 'Tag', 'segmentationPath'), 'String');
    
    [FileName, ~] = uigetfile({'*.tif;*.tiff;*.jpg', 'Image Files (.tif, .tiff, .jpg)';'*.*', 'All Files'},...
        'Select First Segmentation Image',...
        currentFolder, ...
        'MultiSelect', 'on');
    if length(FileName) <= 0 || isnumeric(FileName)
        return;
    elseif ~iscell(FileName) || length(FileName) == 1
        warndlg({'Select at least two image files!', ' ', 'Usage: Select all (optional only the first and the last)', 'image which should be used for segmentation.'}, 'Invalid Selection', 'modal')
        return;
    end
    
    FileName = sort(FileName);
    firstName = FileName{1};
    lastName = FileName{end};
    if length(firstName) ~= length(lastName)
        warndlg({'Invalid file names!', ' ', 'All images file names have to have', 'the same number of characters!'}, 'Invalid Selection', 'modal')
        return;
    end
    
    firstIdx = find(firstName ~= lastName, 1, 'first');
    lastIdx = find(firstName ~= lastName, 1, 'last');
    if isempty(firstIdx) || isempty(lastIdx)
        warndlg({'Invalid file names!', ' ', 'File names must be different.'}, 'Invalid Selection', 'modal')
        return;
    end
    
    imageLow = str2double(firstName(firstIdx:lastIdx));
    imageHigh = str2double(lastName(firstIdx:lastIdx));
    if isnan(imageLow) || isnan(imageHigh)
        warndlg({'Invalid file names!', ' ', 'File names must be different only', 'in a number indicating the image index.'}, 'Invalid Selection', 'modal')
        return;
    end
    
    imageTemplate = [firstName(1:firstIdx-1), '%0', mat2str(lastIdx-firstIdx + 1),'.0f', firstName(lastIdx+1:end)];
    
    set(findall(figH, 'Tag', 'quantiImageTemplate'), 'String', imageTemplate);
end

function removeQuantification(figH, ~)
    figH = ancestor(figH,'figure');
    quantificationListH = findall(figH, 'Tag', 'quantificationList');
    values = get(quantificationListH, 'String');
    selectedIdx = get(quantificationListH, 'Value');
    if isempty(selectedIdx) || selectedIdx < 1 || selectedIdx > length(values)
        return;
    end
    values(selectedIdx) = [];
    set(quantificationListH, 'Value', 1);
    set(quantificationListH, 'String', values);
    
end

function addQuantification(figH, ~)
    figH = ancestor(figH,'figure');
    quantificationListH = findall(figH, 'Tag', 'quantificationList');
    values = get(quantificationListH, 'String');
    values{end+1} =  get(findall(figH, 'Tag', 'quantiImageTemplate'), 'String');
    set(quantificationListH, 'String', values);
    set(quantificationListH, 'Value', length(values));
end


function replaceQuantification(figH, ~)
    figH = ancestor(figH,'figure');
    quantificationListH = findall(figH, 'Tag', 'quantificationList');
    
    values = get(quantificationListH, 'String');
    selectedIdx = get(quantificationListH, 'Value');
    if isempty(selectedIdx) || selectedIdx < 1 || selectedIdx > length(values)
        addQuantification(figH, []);
        return;
    end
    
    values{selectedIdx} =  get(findall(figH, 'Tag', 'quantiImageTemplate'), 'String');
    set(quantificationListH, 'String', values);
    set(quantificationListH, 'Value', selectedIdx);
end

function listCallback(figH, ~)
    figH = ancestor(figH,'figure');
    quantificationListH = findall(figH, 'Tag', 'quantificationList');
    selectedIdx = get(quantificationListH, 'Value');
    values = get(quantificationListH, 'String');
    if isempty(selectedIdx) || selectedIdx < 1 || selectedIdx > length(values)
        return;
    end
    
    set(findall(figH, 'Tag', 'quantiImageTemplate'), 'String',...
        values{selectedIdx});
    
end

function tabSelectionCallback(~, ~, tabNum, ~, ~, figH)
    % Workaround for graphic error with tabs
    if tabNum == 2
        set(findall(figH, 'Tag', 'quantificationPanel'), 'Visible', 'on'); 
    end
end

function loadSettings(figH)
    configFile = 'settings.mat';
    if exist(configFile, 'file')
        load(configFile, 'lastWizardSettings');
    else
        lastWizardSettings = struct();
    end
    
    if isfield(lastWizardSettings, 'imageLow')
       set(findall(figH, 'Tag', 'imageLow'), 'String', num2str(lastWizardSettings.imageLow)); 
    end
    if isfield(lastWizardSettings, 'imageHigh')
       set(findall(figH, 'Tag', 'imageHigh'), 'String', num2str(lastWizardSettings.imageHigh)); 
    end
    if isfield(lastWizardSettings, 'segmentationPath')
       set(findall(figH, 'Tag', 'segmentationPath'), 'String', lastWizardSettings.segmentationPath); 
    end
    if isfield(lastWizardSettings, 'segmentationTemplate')
       set(findall(figH, 'Tag', 'segmentationTemplate'), 'String', lastWizardSettings.segmentationTemplate); 
    end
    if isfield(lastWizardSettings, 'resultFolder')
       set(findall(figH, 'Tag', 'resultFolder'), 'String', lastWizardSettings.resultFolder); 
    end
    if isfield(lastWizardSettings, 'copyOriginals')
       set(findall(figH, 'Tag', 'copyOriginals'), 'Value', lastWizardSettings.copyOriginals); 
    end
    if isfield(lastWizardSettings, 'quantificationImages')
       set(findall(figH, 'Tag', 'quantificationList'), 'String', lastWizardSettings.quantificationImages); 
    end
end

function saveSettings(figH)
    configFile = 'settings.mat';
    
    lastWizardSettings = struct();
    lastWizardSettings.imageLow = str2double(get(findall(figH, 'Tag', 'imageLow'), 'String'));
    lastWizardSettings.imageHigh = str2double(get(findall(figH, 'Tag', 'imageHigh'), 'String'));
    lastWizardSettings.segmentationPath = get(findall(figH, 'Tag', 'segmentationPath'), 'String');
    lastWizardSettings.segmentationTemplate = get(findall(figH, 'Tag', 'segmentationTemplate'), 'String');
    lastWizardSettings.resultFolder = get(findall(figH, 'Tag', 'resultFolder'), 'String');
    
    lastWizardSettings.copyOriginals = get(findall(figH, 'Tag', 'copyOriginals'), 'Value');
    lastWizardSettings.quantificationImages = get(findall(figH, 'Tag', 'quantificationList'), 'String');
    
    if exist(configFile, 'file')
        save(configFile, 'lastWizardSettings', '-append');
    else
        save(configFile, 'lastWizardSettings');
    end
end

function commitData(figH, ~)
    figH = ancestor(figH,'figure');
    userData = get(figH, 'UserData');
    mainFigureH = userData{1};
    callback = userData{2};
    
    imageLow = str2double(get(findall(figH, 'Tag', 'imageLow'), 'String'));
    imageHigh = str2double(get(findall(figH, 'Tag', 'imageHigh'), 'String'));
    imageFolder = get(findall(figH, 'Tag', 'segmentationPath'), 'String');
    imageTemplate = get(findall(figH, 'Tag', 'segmentationTemplate'), 'String');
    
    
    
    [~, imageTemplate, imageFileType] = fileparts(imageTemplate);    
    imageFileType = imageFileType(2:end);
%     imageFileType = imageTemplate(find(imageTemplate == '.', 1, 'last') + 1:end);
%     imageTemplate = imageTemplate(1:find(imageTemplate == '.', 1, 'last') -1);
    resultFolder = get(findall(figH, 'Tag', 'resultFolder'), 'String');
    
    copyOriginals = get(findall(figH, 'Tag', 'copyOriginals'), 'Value');
    quantificationImages = get(findall(figH, 'Tag', 'quantificationList'), 'String');
    for i=1:length(quantificationImages)
        [~, quantificationImages{i}, ~] = fileparts(quantificationImages{i});
    end
    
    callback(mainFigureH, imageFolder, imageTemplate, imageFileType, imageLow:imageHigh, resultFolder, quantificationImages, copyOriginals);
    
    saveSettings(figH)
    close(figH);
end

function selectTemplateFile(figH, ~)
    figH = ancestor(figH,'figure');
    
    currentFolder = get(findall(figH, 'Tag', 'segmentationPath'), 'String');
    
    [FileName, PathName] = uigetfile({'*.tif;*.tiff;*.jpg', 'Image Files (.tif, .tiff, .jpg)';'*.*', 'All Files'},...
        'Select First Segmentation Image',...
        currentFolder, ...
        'MultiSelect', 'on');
    if length(FileName) <= 0 || isnumeric(FileName)
        return;
    elseif ~iscell(FileName) || length(FileName) == 1
        warndlg({'Select at least two image files!', ' ', 'Usage: Select all (optional only the first and the last)', 'image which should be used for segmentation.'}, 'Invalid Selection', 'modal')
        return;
    end
    
    FileName = sort(FileName);
    firstName = FileName{1};
    lastName = FileName{end};
    if length(firstName) ~= length(lastName)
        warndlg({'Invalid file names!', ' ', 'All images file names have to have', 'the same number of characters!'}, 'Invalid Selection', 'modal')
        return;
    end
    
    firstIdx = find(firstName ~= lastName, 1, 'first');
    lastIdx = find(firstName ~= lastName, 1, 'last');
    if isempty(firstIdx) || isempty(lastIdx)
        warndlg({'Invalid file names!', ' ', 'File names must be different.'}, 'Invalid Selection', 'modal')
        return;
    end
    
    imageLow = str2double(firstName(firstIdx:lastIdx));
    imageHigh = str2double(lastName(firstIdx:lastIdx));
    if isnan(imageLow) || isnan(imageHigh)
        warndlg({'Invalid file names!', ' ', 'File names must be different only', 'in a number indicating the image index.'}, 'Invalid Selection', 'modal')
        return;
    end
    
    imageTemplate = [firstName(1:firstIdx-1), '%0', mat2str(lastIdx-firstIdx + 1),'.0f', firstName(lastIdx+1:end)];
    
    set(findall(figH, 'Tag', 'imageLow'), 'String', imageLow);
    set(findall(figH, 'Tag', 'imageHigh'), 'String', imageHigh);
    set(findall(figH, 'Tag', 'segmentationPath'), 'String', PathName);
    set(findall(figH, 'Tag', 'resultFolder'), 'String', [PathName, 'analysis/']);
    set(findall(figH, 'Tag', 'segmentationTemplate'), 'String', imageTemplate);
end