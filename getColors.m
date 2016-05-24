function color = getColors(i)
switch i
    case 1
        color = [0, 0, 0];
    case 2
        color = [0, 0, 0.8];
    case 3
        color = [0, 0.8, 0];
    case 4
        color = [0.8, 0, 0];
    case 5
        color = [0.8, 0.8, 0];
    case 6
        color = [0.8, 0, 0.8];
    case 7
        color = [0, 0.8, 0.8];
    case 8
        color = [0.4,0.9,0.7];
    otherwise
        color = [0.8, 0.8, 0.8];
end
end
