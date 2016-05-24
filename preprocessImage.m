function [orgImage, shrinkPixels] = preprocessImage(orgImage, threshold, method, methodOrder, invert)
    
    if nargin == 0 && nargout == 1
        % Show available filters
        orgImage = {'None', 'Sobel', 'Low', 'Range', 'Median'};
        return;
    end

    if ~exist('threshold', 'var') || isempty(threshold)
        threshold = 0.5;
    end
    if ~exist('method', 'var') || isempty(method)
        method = 'default';
    end
    if ~exist('methodOrder', 'var') || isempty(methodOrder)
        methodOrder = 3;
    end
    
    if ~exist('invert', 'var') || isempty(invert)
        invert = false;
    end
    
    if strcmpi(method, 'sobel')
        % Calculate Sobel filters
        sobels = cell(1, 1 + (methodOrder - 3)/2);
        sobels{1} = [ 1 2 1 ]' * [1 0 -1];
        for i=2:length(sobels)
            sobels{i} = conv2( [ 1 2 1 ]' * [1 2 1], sobels{i-1});
        end

        % Normalize Sobel filters
        for i=1:length(sobels)
            sobels{i} = sobels{i} / sum(sum(abs(sobels{i})))*2;
        end

        % Sobel filter image
        H = conv2(orgImage, sobels{end}, 'valid');
        V = conv2(orgImage, sobels{end}', 'valid'); % valid
        orgImage = sqrt(H.^2 + V.^2);
        
        shrinkPixels = floor(methodOrder / 2);
    elseif strcmpi(method, 'low')
        lowPass = cell(1, 1 + (methodOrder - 3)/2);
        lowPass{1} = [ 1 2 1 ]' * [1 2 1];
        for i=2:length(lowPass)
            lowPass{i} = conv2(lowPass{1}, lowPass{i-1});
        end
        for i=1:length(lowPass)
            lowPass{i} = lowPass{i} / sum(lowPass{i}(:));
        end
        orgImage = conv2(orgImage, lowPass{end}, 'valid');
        
        shrinkPixels = floor(size(lowPass{end}, 1) / 2);
    elseif strcmpi(method, 'range')
        orgImage = rangefilt(orgImage, true(methodOrder));
        shrinkPixels = 0;
    elseif strcmpi(method, 'median')
        orgImage = medfilt2(orgImage, methodOrder * ones(1, 2));
        shrinkPixels = floor(methodOrder / 2);
        orgImage = orgImage(1+shrinkPixels:size(orgImage, 1) - shrinkPixels, 1+shrinkPixels:size(orgImage, 2) - shrinkPixels);
    else
        shrinkPixels = 0;
    end
    
    
    
%     method = lower(method);
%     maxSobel = -1;
%     maxPass = -1;
%     range = -1;
%     median = -1;
%     switch method
%         case 'sobel3'
%             maxSobel = 3;
%         case 'sobel5'
%             maxSobel = 5;
%         case 'sobel7'
%             maxSobel = 7;
%         case 'sobel9'
%             maxSobel = 9;
%         case 'sobel11'
%             maxSobel = 11;
%         case 'sobel13'
%             maxSobel = 13;
%         case 'sobel15'
%             maxSobel = 15;
%         case 'low3'
%             maxPass = 3;
%         case 'low5'
%             maxPass = 5;
%         case 'low7'
%             maxPass = 7;
%         case 'low9'
%             maxPass = 9;
%         case 'low11'
%             maxPass = 11;
%         case 'low13'
%             maxPass = 13;
%         case 'low15'
%             maxPass = 15;
%         case 'low17'
%             maxPass = 17;
%         case 'range9'
%             range = 9;
%         case 'median9'
%             median = 9;
%         case 'median21'
%             median = 21;
%         otherwise
%             maxSobel = -1;
%             maxPass = -1;
%     end
% 
%     if maxSobel > 0
%         
%     elseif maxPass > 0
%         
%         
%     elseif range > 0
%         orgImage = rangefilt(orgImage, true(9));
%         shrinkPixels = 0;
%     elseif median > 0
%         orgImage = medfilt2(orgImage, median * ones(1, 2));
%         shrinkPixels = floor(median / 2);
%         orgImage = orgImage(1+shrinkPixels:size(orgImage, 1) - shrinkPixels, 1+shrinkPixels:size(orgImage, 2) - shrinkPixels);
%         
%     else
%         % do nothing
%         shrinkPixels = 0;
%     end

    % gamma correction
    gamma = log(0.5) / log(threshold);
    orgImage = orgImage.^gamma;
    
    % invert
    if invert
        orgImage = 1-orgImage;
    end
end

