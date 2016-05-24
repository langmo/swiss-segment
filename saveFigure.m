function saveFigure(fileName, saver, minimal, fgh)
    if ~exist('saver', 'var') || isempty(saver)
        saver = 'painters'; %opengl
    end
    if ~exist('minimal', 'var') || isempty(minimal)
        minimal = false;
    end
    if ~exist('fgh', 'var') || isempty(fgh)
        fgh = gcf();
    end
    [pathstr,basename,~] =fileparts(fileName);
    figName = fullfile(pathstr,[basename, '.fig']);
    if strcmpi(saver, 'painters')
        saveas(fgh,fileName, 'epsc');
    else
         print(fgh, '-depsc2',  ['-', saver], fileName);
    end
    if ~minimal
        saveas(gcf,figName);
    end
end