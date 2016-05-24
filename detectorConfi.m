function detectorConfi(imageFolder, imageTemplate, imageRange)

%% Check variables
if ~exist('imageFolder', 'var')
    imageFolder = 'Z:/Projects/SyncOscis_ML/2012_11_15 HD 100prod_0deg_0trp/';
end

if ~exist('imageTemplate', 'var')
    imageTemplate = 'Pos001_S001_t%03.0f_ch02.tif';
end

if ~exist('imageRange', 'var')
    imageRange = 0;
end

%% Configuration of UI
% Size of the figure in pixels
figureDim = [840, 570];

% Maximum of width/height of the image display size in pixels.
maxImageDim = 400;

%% Load default image
BFImage    = getImage(sprintf([imageFolder, imageTemplate], imageRange(1)), 1);
BFImage = uint8(cat(3, BFImage, BFImage, BFImage)* double(intmax('uint8')));

%% Create UI
% Create Figure
figure('Units', 'pixels',...
    'Position', [100, 200, figureDim(1), figureDim(2)],...
    'UserData', BFImage,...
    'Color', [1, 1, 1]);

% Place image axis system
uipanel('Title', 'Segmentation Image', 'BackgroundColor', [1, 1, 1],...
    'Units', 'pixels',...
    'Position', [5, figureDim(2) - 35 - maxImageDim, maxImageDim+10, maxImageDim+8]);
if size(BFImage, 1) > size(BFImage, 2)
    imgWidth = round(size(BFImage, 2) / size(BFImage, 1) * maxImageDim);
    imgHeight = maxImageDim;
else
    imgWidth = maxImageDim;
    imgHeight = round(size(BFImage, 1) / size(BFImage, 2) * maxImageDim);
end
axes('Units', 'pixels', 'Position', [10, figureDim(2) - 40 - (maxImageDim - (maxImageDim-imgHeight)/2), imgWidth, imgHeight]);
imageH = image(BFImage);
axis off;

% Place image axis for results
uipanel('Title', 'Segmented Image', 'BackgroundColor', [1, 1, 1],...
    'Units', 'pixels',...
    'Position', [maxImageDim + 20, figureDim(2) - 35 - maxImageDim, maxImageDim+10, maxImageDim+8]);
axes('Units', 'pixels', ...
    'Position', [maxImageDim + 25, figureDim(2) - 40 - (maxImageDim - (maxImageDim-imgHeight)/2), imgWidth, imgHeight],...
    'Tag', 'ResultImageAxis');
axis off;

controlsTop = 130;

% Create buttons to define source and sink pixels.
insideOutsideH = uibuttongroup('visible','off', 'Units', 'pixels',...
    'Position', [5, 10, 140, controlsTop - 10], 'Title', 'Define Source/Sink',...
    'Tag', 'sinkSource_group',...
    'BackgroundColor', [1,1,1]);
insideH = uicontrol('Style','Radio','String','Cell',...
    'pos',[10, controlsTop-60, 100, 30],'parent', insideOutsideH,'HandleVisibility','off',...
    'Tag', 'sinkSource_source',...
    'BackgroundColor', [1,1,1]);
uicontrol('Style','Radio','String','Surrounding',...
    'pos',[10 controlsTop-90 100 30],'parent', insideOutsideH,'HandleVisibility','off',...
    'Tag', 'sinkSource_sink',...
    'BackgroundColor', [1,1,1]);
uicontrol('Style','Radio','String','Erase',...
    'pos',[10 controlsTop-120 100 30],'parent', insideOutsideH,'HandleVisibility','off',...
    'Tag', 'sinkSource_erase',...
    'BackgroundColor', [1,1,1]);
set(insideOutsideH,'SelectedObject',insideH);  % No selection
set(insideOutsideH,'Visible','on');

% Create Options to enter values
uipanel('Title', 'Settings', 'BackgroundColor', [1, 1, 1],...
    'Units', 'pixels',...
    'Position', [150, 10, 200, controlsTop - 10]);
uicontrol('Style', 'text', 'String', 'Brush Size:',...
    'pos',[155, controlsTop-60, 80, 30],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'left');
uicontrol('Style', 'edit',...
    'pos',[235, controlsTop-45, 100, 20],...
    'String', '5',...
    'HorizontalAlignment', 'left',...
    'Tag', 'brushSize');

uicontrol('Style', 'text', 'String', 'Border:',...
    'pos',[155, controlsTop-90, 100, 30],...
    'BackgroundColor', [1,1,1],...
    'HorizontalAlignment', 'left');
uicontrol('Style', 'edit',...
    'pos',[235, controlsTop-75, 100, 20],...
    'String', '20',...
    'HorizontalAlignment', 'left');


% Create Button to start processing
uicontrol('Style', 'pushbutton', 'String', 'Segment Cells',...
    'Position', [figureDim(1) - 120, controlsTop-30, 100, 30], 'Callback', {@startProcessing, imageH});

% Initialize draggin callback
set(imageH,'ButtonDownFcn',{@startDrag, imageH})
end

function startProcessing(figH, evd, imageH)
figH = ancestor(figH,'figure');
findall(figH, 'Tag', 'sinkSource_group')
orgFig = get(figH, 'UserData');
data = get(imageH, 'CData');
mask = zeros(size(orgFig, 1), size(orgFig, 2));
mask(data(:, :, 1) == uint8(0)         & data(:, :, 2) == intmax('uint8')  & data(:, :, 3) == uint8(0)) = 1;
mask(data(:, :, 1) == intmax('uint8')  & data(:, :, 2) == uint8(0)         & data(:, :, 3) == uint8(0)) = -1;
processFig = double(orgFig(:, :, 1)) / double(intmax('uint8'));
segmentedImage = processImage(processFig, mask);



H = conv2(double(segmentedImage),[-1,0,1], 'same');
V = conv2(double(segmentedImage),[-1;0;1], 'same');
edgeImage = abs(H)|abs(V);
edgeImage = logical(conv2(double(edgeImage), ones(3), 'same'));



maxMovement = 60;
hardConstraints =  (bwdist(~segmentedImage) > maxMovement) - (bwdist(segmentedImage) > maxMovement);

wholeImage = zeros(size(processFig,1), size(processFig,2), 3);
R = processFig;
G = processFig;
B = processFig;

R(hardConstraints <0) = min(R(hardConstraints <0) * 1.0, 1);
G(hardConstraints <0) = max(G(hardConstraints <0) * 0.6, 0);
B(hardConstraints <0) = max(B(hardConstraints <0) * 0.6, 0);

R(hardConstraints >0) = max(R(hardConstraints >0) * 0.6, 0);
G(hardConstraints >0) = min(G(hardConstraints >0) * 1.2, 1);
B(hardConstraints >0) = max(B(hardConstraints >0) * 0.6, 0);

R(hardConstraints==0) = min(R(hardConstraints==0) * 1.1, 1);
G(hardConstraints==0) = min(G(hardConstraints==0) * 1.1, 1);
B(hardConstraints==0) = max(B(hardConstraints==0) * 0.6, 0);

R(edgeImage) = 0.1;
G(edgeImage) = 0.1;
B(edgeImage) = 0.7;

wholeImage(:, :, 1) = R;
wholeImage(:, :, 2) = G;
wholeImage(:, :, 3) = B;

wholeImage = uint8(double(intmax('uint8')) * wholeImage);



set(0,'CurrentFigure', figH);
set(figH, 'CurrentAxes', findall(figH, 'Tag', 'ResultImageAxis'));
image(wholeImage);
colormap gray;
axis off;

end
function startDrag(figH, evd, imageH)

fig = ancestor(figH,'figure');

% get the values and store them in the figure's appdata
props.WindowButtonMotionFcn = get(fig,'WindowButtonMotionFcn');
props.WindowButtonUpFcn = get(fig,'WindowButtonUpFcn');

setappdata(fig,'TestGuiCallbacks',props);


set(fig, 'WindowButtonMotionFcn', {@drag,imageH})
set(fig, 'WindowButtonUpFcn', {@stopDrag})
end

function drag(figH, evd, imageH)
mousePos = get(figH,'CurrentPoint');
axisPos = get(gca, 'Position');
x = (mousePos(1)-axisPos(1)) / axisPos(3);
y = 1- (mousePos(2)-axisPos(2)) / axisPos(4);
if(x  < 0 || x > 1 || y < 0 || y > 1)
    return;
end

paintRadius = str2double(get(findall(figH, 'Tag', 'brushSize'), 'String'));
if isempty(paintRadius)
    paintRadius = 5;
    set(findall(figH, 'Tag', 'brushSize'), 'String', '5');
end

data = get(imageH, 'CData');
width = size(data, 2);
height = size(data, 1);
xData = ceil(width * x);
yData = ceil(height * y);

selectedChoice = get(findall(figH, 'Tag', 'sinkSource_group'), 'SelectedObject');
if selectedChoice == findall(figH, 'Tag', 'sinkSource_source')
    data(yData-paintRadius : yData+paintRadius, xData-paintRadius : xData+paintRadius, 1) = uint8(0);
    data(yData-paintRadius : yData+paintRadius, xData-paintRadius : xData+paintRadius, 2) = intmax('uint8');
    data(yData-paintRadius : yData+paintRadius, xData-paintRadius : xData+paintRadius, 3) = uint8(0);
elseif selectedChoice == findall(figH, 'Tag', 'sinkSource_sink')
    data(yData-paintRadius : yData+paintRadius, xData-paintRadius : xData+paintRadius, 1) = intmax('uint8');
    data(yData-paintRadius : yData+paintRadius, xData-paintRadius : xData+paintRadius, 2) = uint8(0);
    data(yData-paintRadius : yData+paintRadius, xData-paintRadius : xData+paintRadius, 3) = uint8(0);
else
    orgFig = get(figH, 'UserData');
    data(yData-paintRadius : yData+paintRadius, xData-paintRadius : xData+paintRadius, 1) = orgFig(yData-paintRadius : yData+paintRadius, xData-paintRadius : xData+paintRadius, 1);
    data(yData-paintRadius : yData+paintRadius, xData-paintRadius : xData+paintRadius, 2) = orgFig(yData-paintRadius : yData+paintRadius, xData-paintRadius : xData+paintRadius, 2);
    data(yData-paintRadius : yData+paintRadius, xData-paintRadius : xData+paintRadius, 3) = orgFig(yData-paintRadius : yData+paintRadius, xData-paintRadius : xData+paintRadius, 3);
end
set(imageH, 'CData', data);

end

% ---------------------------
function stopDrag(figH,evd)

fig = ancestor(figH,'figure');

props = getappdata(fig,'TestGuiCallbacks');
set(fig,props);
end