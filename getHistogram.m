function [binX, binY] = getHistogram(fluorescenceImage, segmentionMask, numBins, minInt, maxInt)

    if nargin < 4
        minInt = 0;
    end
    if nargin < 5
        maxInt = 1;
    end
    
    binEdges = minInt:((maxInt-minInt)/numBins):maxInt;
    binY = histc(fluorescenceImage(segmentionMask), binEdges)' / sum(segmentionMask(:));
    binY(end-1) = binY(end-1) + binY(end);
    binY(end) = [];
    binX = binEdges(1:end-1) + diff(binEdges);
end

