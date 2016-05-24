function segmentedImage = processImage(orgImage, hardConstraints, alpha, beta1, beta2, threshold, method, methodOrder, invert, minHole, minSize)

    % Check variables
    if ~exist('alpha', 'var') || isempty(alpha)
        alpha = 20;
    end
    if ~exist('beta1', 'var') || isempty(beta1)
        beta1 = 20;
    end
    if ~exist('beta2', 'var') || isempty(beta2)
        beta2 = 20;
    end
    if ~exist('threshold', 'var') || isempty(threshold)
        threshold = 0.5;
    end
    if ~exist('method', 'var') || isempty(method)
        method = 'sobel9';
    end
    
    if ~exist('invert', 'var') || isempty(invert)
        invert = false;
    end
    
    if ~exist('minHole', 'var') || isempty(minHole)
        minHole = 40;
    end
    
    if ~exist('minSize', 'var') || isempty(minSize)
        minSize = 40;
    end
    
    [orgImageHeight, orgImageWidth]  = size(orgImage);
    
    [orgImage, h] = preprocessImage(orgImage, threshold, method, methodOrder, invert);
    
    if h > 0
        hardConstraints = hardConstraints(1+h:end-h, 1+h:end-h);
    end
    
%     method = lower(method);
%     maxSobel = -1;
%     maxPass = -1;
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
%         otherwise
%             maxSobel = -1;
%             maxPass = -1;
%     end
% 
%     
%     
%     if maxSobel > 0
%         % Calculate Sobel filters
%         sobels = cell(1, 1 + (maxSobel - 3)/2);
%         sobels{1} = [ 1 2 1 ]' * [1 0 -1];
%         for i=2:length(sobels)
%             sobels{i} = conv2( [ 1 2 1 ]' * [1 2 1], sobels{i-1});
%         end
% 
%         % Normalize Sobel filters
%         for i=1:length(sobels)
%             sobels{i} = sobels{i} / sum(sum(abs(sobels{i})))*2;
%         end
% 
%         % Sobel filter image
%         H = conv2(orgImage, sobels{end}, 'valid');
%         V = conv2(orgImage, sobels{end}', 'valid'); % valid
%         orgImage = sqrt(H.^2 + V.^2);
%         
%         % Change hard constraints to valid area
%         h = floor(maxSobel / 2);
%         hardConstraints = hardConstraints(1+h:end-h, 1+h:end-h);
%     elseif maxPass > 0
%         
%         lowPass = cell(1, 1 + (maxPass - 3)/2);
%         lowPass{1} = [ 1 2 1 ]' * [1 2 1];
%         for i=2:length(lowPass)
%             lowPass{i} = conv2(lowPass{1}, lowPass{i-1});
%         end
%         for i=1:length(lowPass)
%             lowPass{i} = lowPass{i} / sum(lowPass{i}(:));
%         end
%         orgImage = conv2(orgImage, lowPass{end}, 'valid');
%         
%         % Change hard constraints to valid area
%         h = floor(size(lowPass{end}, 1) / 2);
%         hardConstraints = hardConstraints(1+h:end-h, 1+h:end-h);
%     else
%         % do nothing
%         h = 0;
%     end
% 
%     % gamma correction
%     gamma = log(0.5) / log(threshold);
%     orgImage = orgImage.^gamma;
%     
%     % invert
%     if invert
%         orgImage = 1-orgImage;
%     end
    
    % make min cut
    output = segmentImage(orgImage, alpha, beta1, beta2, 0.5, hardConstraints, 3);
    
    if isinf(minHole)
        output = imfill(output, 'holes');
    elseif minHole > 0
        [holeLabels, numHoles] = bwlabeln(~output);
        for i=1:numHoles
            if sum(holeLabels==i) < minHole
                output(holeLabels==i) = 1;
            end
        end
    end
    
    if ~isinf(minSize) && minSize > 0
        [segLabels, numSegs] = bwlabeln(output);
        for i=1:numSegs
            if sum(segLabels==i) < minSize
                output(segLabels==i) = 0;
            end
        end
    end
    
    if h > 0
        segmentedImage = false(orgImageHeight, orgImageWidth);
        segmentedImage(1+h:end-h, 1+h:end-h) = logical(output);
    else
        segmentedImage = logical(output);
    end
end