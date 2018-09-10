function ax = framed_axis(position)
% framed_axis(position)

%   Copyright 2016 Cleve Moler
%   Copyright 2016 The MathWorks, Inc.
    if nargin < 1
        position = get(gca,'Position');
        close
    end
    ax = axes;
    ax.Position = position;
    ax.XTick = [];
    ax.YTick = [];
    ax.ZTick = [];
    ax.Box = 'on';
    ax.LineWidth = 1.0;
    ax.Color = 'white';
end