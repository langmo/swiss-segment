function varargout = swissWaitbar(varargin)


persistent wbh;
persistent wbhIndex;
persistent wbhMessages;
persistent wbhStates;
persistent wbhTextHandels;
persistent wbhStateHandels1;
persistent wbhStateHandels2;

width = 300;
hMargin = 15;
vMargin = 15;
verticalDist = 40;

if nargin == 1 && ischar(varargin{1}) && strcmpi(varargin{1}, 'CloseAll')
    wbhIndex = [];
    wbhStates = [];
    wbhMessages = [];
    wbhTextHandels = [];
    wbhStateHandels1 = [];
    wbhStateHandels2 = [];
    if exist('wbh', 'var') && ~isempty(wbh) && ishandle(wbh)
        delete(wbh);
    end
    wbh = [];
    return;
end

if ~exist('wbh', 'var') || isempty(wbh) || ~ishandle(wbh)
    if nargin == 3
        warning('SwissSegment:WaitbarClosed', 'Waitbar closed by user.');
        return;
    end
    
    wbh = figure();
    set(wbh, 'DockControls', 'off');
    set(wbh, 'ToolBar', 'none');
    set(wbh, 'MenuBar', 'none');
    set(wbh, 'Resize', 'off');
    set(wbh, 'Color', [0.8 0.8 0.8]);
    set(wbh, 'CloseRequestFcn', 'swissWaitbar(''CloseAll'')');
    set(wbh, 'Name', 'Waitbar');
    set(wbh, 'NumberTitle', 'off');
    set(wbh, 'NextPlot', 'new');
    %set(wbh, 'WindowStyle', 'modal');
    % Change icon
    setWindowIcon(); 
else
    figure(wbh);
end

if ~exist('wbhIndex', 'var') || isempty(wbhIndex)
    wbhIndex = 0;
    wbhMessages = cell(1, 0);
    wbhStates = cell(1, 0);
    wbhTextHandels = cell(1, 0);
    wbhStateHandels1 = cell(1, 0);
    wbhStateHandels2 = cell(1, 0);    
end
if nargin == 1 && ischar(varargin{1})
    if strcmpi(varargin{1}, 'CloseAll')
        wbhIndex = [];
        wbhStates = [];
        wbhMessages = [];
        wbhTextHandels = [];
        wbhStateHandels1 = [];
        wbhStateHandels2 = [];
        delete(wbh);
        wbh = [];
        return;
    elseif  strcmpi(varargin{1}, 'close')
        if wbhIndex <= 1
            wbhIndex = [];
            wbhStates = [];
            wbhMessages = [];
            wbhTextHandels = [];
            wbhStateHandels1 = [];
            wbhStateHandels2 = [];
            delete(wbh);
            wbh = [];
            return;
        else
            delete(wbhTextHandels{wbhIndex});
            delete(wbhStateHandels1{wbhIndex});
            delete(wbhStateHandels2{wbhIndex});
            wbhStates(wbhIndex) = [];
            wbhMessages(wbhIndex) = [];
            wbhTextHandels(wbhIndex) = [];
            wbhStateHandels1(wbhIndex) = [];
            wbhStateHandels2(wbhIndex) = [];
            wbhIndex = wbhIndex - 1; 
        end
    end
elseif nargin == 2
    wbhIndex = wbhIndex+1;
    handle = wbhIndex;
    wbhStates{1, handle} = varargin{1};
    wbhMessages{1, handle} = varargin{2};

    heigth = wbhIndex * verticalDist;
    pos = get(wbh, 'Position');
    pos(3) = width + 2 * hMargin;
    pos(4) = heigth + 2 * vMargin;
    set(wbh, 'Position', pos);
    if wbhIndex == 1
        set(wbh, 'Name', sprintf('Waitbar (%g%%)', round(wbhStates{1}*100)));
    end
    
    wbhStateHandels1{wbhIndex}=uicontrol('style','text', ... 
              'units','pixel', ...
              'position',[hMargin vMargin + ((wbhIndex-1)*verticalDist) width 20], ... 
              'backgroundcolor',[.95 .95 .95], ...
              'HorizontalAlignment', 'right'); 
    progress = round((width-2)*wbhStates{wbhIndex});
    if progress < 0.01
        progress = 0.01;
    end
    wbhStateHandels2{wbhIndex}=uicontrol('style','text', ... 
                  'units','pixel', ... 
                  'position',[hMargin+1, vMargin+1+((wbhIndex-1)*verticalDist), progress, 20-2], ... 
                  'backgroundcolor',[.4 .4 .4], ... 
                  'foregroundcolor',[.95 .95 .95], ...
                  'HorizontalAlignment', 'right'); 
    wbhTextHandels{wbhIndex}=uicontrol('style','text', ... 
                  'units','pixel', ... 
                  'position',[hMargin+1, 20+vMargin+((wbhIndex-1)*verticalDist), width, 16],...
                  'backgroundcolor',[0.8 0.8 0.8], ... 
                  'HorizontalAlignment', 'left', ...
                  'String', wbhMessages{wbhIndex}); 
              
    if wbhStates{wbhIndex} > 0.1
        set(wbhStateHandels2{handle}, 'String', sprintf('%g%% ', round(wbhStates{wbhIndex}*100)));
        set(wbhStateHandels1{handle}, 'String', '');
    else
        set(wbhStateHandels1{handle}, 'String', sprintf('%g%% ', round(wbhStates{wbhIndex}*100)));
        set(wbhStateHandels2{handle}, 'String', '');
    end          
              
    for i = 1:wbhIndex
        pos = get(wbhStateHandels1{i}, 'Position');
        pos(2) = vMargin + ((wbhIndex-i)*verticalDist);
        set(wbhStateHandels1{i}, 'Position', pos);

        pos = get(wbhStateHandels2{i}, 'Position');
        pos(2) = vMargin+1+((wbhIndex-i)*verticalDist);
        set(wbhStateHandels2{i}, 'Position', pos);

        pos = get(wbhTextHandels{i}, 'Position');
        pos(2) = 20+vMargin+((wbhIndex-i)*verticalDist);
        set(wbhTextHandels{i}, 'Position', pos);
    end
elseif nargin == 3
    handle = varargin{2};
    wbhStates{1, handle} = varargin{1};
    wbhMessages{1, handle} = varargin{3};
    set(wbhTextHandels{handle}, 'String', wbhMessages{1, handle});
    pos = get(wbhStateHandels2{wbhIndex}, 'Position');
    progress = round((width-2)*wbhStates{handle});
    if progress < 0.01
        progress = 0.01;
    end
    pos(3) = progress;
    set(wbhStateHandels2{handle}, 'Position', pos);
    if wbhStates{handle} > 0.1
        set(wbhStateHandels2{handle}, 'String', sprintf('%g%% ', round(wbhStates{handle}*100)));
        set(wbhStateHandels1{handle}, 'String', '');
    else
        set(wbhStateHandels1{handle}, 'String', sprintf('%g%% ', round(wbhStates{handle}*100)));
        set(wbhStateHandels2{handle}, 'String', '');
    end
    
    if handle == 1
        set(wbh, 'Name', sprintf('Waitbar (%g%%)', round(wbhStates{1}*100)));
    end
end

if nargout > 0
    varargout{1} = handle;
end

drawnow;