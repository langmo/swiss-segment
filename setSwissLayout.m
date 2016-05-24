function setSwissLayout(changeAxis, xSize, ySize, border, tight)
% Author:   Moritz Lang
%           ETH Zürich
%           Department of Biosystems Science and Engineering (D-BSSE)
%           Stelling Group
%           Mattenstrasse 26
%           4058 Basel, Switzerland
% Date:     2012-09-11

figureHandle = gcf;
set(gca, 'LineWidth', 1);

if ~exist('xSize', 'var') || isempty(xSize)
    xSize = 7;
end

if ~exist('tight', 'var') || isempty(tight)
    tight = false;
end
if ~exist('ySize', 'var') || isempty(ySize)
    ySize = 5;
end
if ~exist('border', 'var') || isempty(border)
    border = [1.5, 1, 0.5, 0.3];
end
if ~exist('changeAxis', 'var') || isempty(changeAxis)
    changeAxis = true;
end
if changeAxis
    set(gca, 'Units', 'centimeters');
    set(gca, 'Position', [border(1), border(2), xSize, ySize]);
end

legendH = legend('boxoff');
%set(legendH, 'Units', 'centimeters');
%pos1 = get(gca, 'Position');
%pos2 = get(legendH, 'Position');
%if strcmp(get(legendH, 'Location'), 'NorthWest')
%    set(legendH, 'Position', [pos1(1), pos1(2) + pos1(4)-pos2(4), pos2(3), pos2(4)])
%end

if changeAxis
    set(gcf, 'Units', 'centimeters');
    %pos = get(gcf, 'Position');
    if tight
        set(gcf, 'Position', [2, 2, xSize + border(1) + border(3), ySize + border(2) + border(4)]);
    else
        set(gcf, 'Position', [2, 2, xSize + border(1) + border(3) + 4, ySize + border(2) + border(4)]);
    end
    set(gcf, 'PaperUnits', 'centimeters');
    if tight
        set(gcf, 'PaperPosition', [2, 2, xSize + border(1) + border(3), ySize + border(2) + border(4)]);
    else
        set(gcf, 'PaperPosition', [2, 2, xSize + border(1) + border(3) + 4, ySize + border(2) + border(4)]);
    end
    set(gcf, 'PaperPositionMode', 'manual');
end

set(figureHandle, 'Color', 'white')
% Get all axes
hChild = get(figureHandle, 'Children');
for hAxis = hChild'
    % Change axes font
    if isprop(hAxis, 'XLabel')
        hXLabel = get(hAxis, 'XLabel');
        set(hXLabel, 'FontSize', 9);
        set(hXLabel, 'FontWeight', 'normal');    
        set(hXLabel, 'FontName', 'Helvetica');
    end
    if isprop(hAxis, 'YLabel')
        hYLabel = get(hAxis, 'YLabel');
        set(hYLabel, 'FontSize', 9);
        set(hYLabel, 'FontWeight', 'normal');  
        set(hYLabel, 'FontName', 'Helvetica');
    end
    % Change title font
    if isprop(hAxis, 'Title')
        hTitle = get(hAxis, 'Title');
        set(hTitle, 'FontSize', 9);
        set(hTitle, 'FontWeight', 'normal');    
        set(hTitle, 'FontName', 'Helvetica');
    end
    set(hAxis, 'FontWeight', 'normal');
    set(hAxis, 'FontSize', 9);    
    set(hAxis, 'FontName', 'Helvetica');
    hLines = get(hAxis, 'Children');
    for hLine = hLines
        try
                set(hLine, 'LineWidth', 1)
        catch %#ok<CTCH> 
            % exception occurs for errorbars
        end
    end
end

box off;

set(legendH, 'FontWeight', 'normal')