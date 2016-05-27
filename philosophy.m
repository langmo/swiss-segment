function philosophy(varargin)
% Shows the philosophy frame

    figureDim = [500, 400];

    figH = figure('Units', 'pixels',...
        'Color', [1, 1, 1],...
        'Name', 'Philosophy', 'NumberTitle', 'off',...
        'DockControls', 'off', 'MenuBar', 'none', 'Resize', 'off', 'Toolbar', 'none',...
        'WindowStyle', 'modal', ...
        'Position', [300, 300, figureDim]);

    % Change icon
    setWindowIcon();  

    % Show some nice image
    img = imread('matterhorn.jpg');
    imgWidth = size(img, 2);
    imgHeight = size(img, 1);
    
    image(img); 
    axis off;
    set(gca,'ydir','normal', 'Units', 'pixels');
    set(gca, 'Position', [10, figureDim(2) - imgHeight - 10, imgWidth, imgHeight]);
    
    % Add text
    descriptionText = 'Switzerland is known for its high-quality products. Our well-trained engineers are leading in automating a wide range of processes. However, we have also learned from watch manufacturing that sometimes human precision can outperform the best machines, especially for small lot sizes where the cost for full automatization is not always justifiable. In these cases our people learned that semi-automatization with the right tools can produce the highest standards, and SwissSegment stands in this old tradition.\n\nSwissSegment gives you a wide variety of tools, allowing you to quickly implement your segmentation solution, while still offering the possibility to increase quality by manual intervention.\nSwissSegment provides Swiss quality, to help you concentrate on the things that really matter: performing successful research!';
    uicontrol(figH, 'Style', 'text', ...
        'String', sprintf(descriptionText),...
        'pos',[imgWidth + 20, 50, figureDim(1) - imgWidth - 30, figureDim(2)-60],...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [1,1,1]);
    
    % Add close button
    uicontrol('Style', 'pushbutton', ...
        'String', 'Close', ...
        'Position', [figureDim(1) - 110, 10, 100, 25], ...
        'Callback', 'close(gcf)');
    
end

