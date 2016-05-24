function plotHistogramOverTime(times, intensityBinCenters, histogramValues, quantileValues, numColors)
    %% check variables
    if nargin < 5
        numColors = 500;
    end

    %% plot histogram over time
    scaledValues = histogramValues ./ repmat(max(histogramValues, [], 2), 1, size(histogramValues,2));

    minDens = min(min(scaledValues));
    maxDens = 1;

    [~, plotH] = contourf(times, intensityBinCenters, scaledValues');
    set(plotH, 'LineStyle', 'none', 'LevelStep', (maxDens-minDens)/numColors);
    set(get(get(plotH, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
    cbh = colorbar('EastOutside');
    if ~isnan(minDens) && ~isnan(maxDens)
        colorsf = [zeros(round(numColors*minDens), 3); hot(round(numColors*(maxDens - minDens)))];
        colormap(colorsf);
    end
    set(get(cbh,'ylabel'),'String','Density (A.U.)');

    hold on;
    plot(times, quantileValues(:, 2), 'k');
    plot(times, quantileValues(:, 1), 'k-.');
    plot(times, quantileValues(:, 3), 'k-.');

    minIdx = find(max(cumsum(histogramValues, 2), [], 1)<=0.05, 1, 'last');
    maxIdx = find(min(cumsum(histogramValues, 2), [], 1)>=0.95, 1, 'first');

    ylim(intensityBinCenters([minIdx, maxIdx]));
end

