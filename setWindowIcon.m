function setWindowIcon(figureH, iconFile)

if nargin < 1 || isempty(figureH) || ~ishandle(figureH)
    figureH = gcf();
end
if nargin < 2
    iconFile = 'icon.png';
end

[img] = imread(iconFile);

oldWarn = warning('off', 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jimage = im2java(img);
jframe=get(figureH, 'javaframe') ;
jIcon=javax.swing.ImageIcon(jimage);
jframe.setFigureIcon(jIcon); 
warning(oldWarn);

end

