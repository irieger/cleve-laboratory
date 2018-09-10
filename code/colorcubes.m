function colorcubes(arg,~)
% COLORCUBES  A cube of cubes in the RGB color space.
%   COLORCUBES, with no arguments, shows 5^3 = 125 cubes with
%      colors equally spaced in the RGB color space.
%   COLORCUBES(n) shows n-by-n-by-n colors.
%   COLORCUBES(2) shows 8 colors: R, G, B, C, M, Y, W, K (black).
%   Rotate the cube with the mouse or arrow keys.

%   Copyright 2016 The MathWorks, Inc.

    if nargin < 1
        arg = 5;
    end
    n = initgraphics(arg);
    w = 0.85;
    [x,y,z] = cube(w);
    m = n-1;
    for i = m:-1:0
      for j = m:-1:0
         for k = 0:m
            r = k/m;
            g = 1-j/m;
            b = 1-i/m;
            if n == 1
                [r,g,b] = deal(.5,.5,.5);
            end
            surface(i+x,j+y,k+z, ...
                'facecolor',[r g b], ...
                'facelighting','gouraud');
            if n <= 5 && ~isequal(arg,'thumbnail')
                drawnow
            end
         end %k
      end %j
    end %i

    % ------------------------
    
    % INITGRAPHCS  Inialize the colorcubes axis.
    %   INITGRAPHICS(n) for n-by-n-by-n display.

    function n = initgraphics(arg)
        if isequal(arg,'thumbnail')
           n = 2;
           cla
           axis([-.5 2.5 -.5 2.5 -.5 2.5])
           axis square
           box on
           set(gca,'xtick',[],'ytick',[],'ztick',[])
        else
           n = arg;
           clf reset
           shg
           set(gcf,'color','white', ...
               'name','colorcubes', ...
               'numbertitle','off')
           axis([0 n 0 n 0 n]);
           axis off
           axis vis3d
           set(gca,'clipping','off', ...
               'userdata',n)
           h = rotate3d;
           set(gcf,'userdata',h)
           set(h,'enable','on', ...
               'ActionPreCallback',@delete_hint)
           text(0,0,-n/10,'Rotate with mouse or arrow keys', ...
               'horiz','center', ...
               'tag','hint')
           uicontrol('string','+', ...
               'units','normalized', ...
               'position',[.84 .02 .06 .06], ...
               'fontsize',12, ...
               'fontweight','bold', ...
               'callback',@plus_cb);
           uicontrol('string','-', ...
               'units','normalized', ...
               'position',[.92 .02 .06 .06], ...
               'fontsize',12, ...
               'fontweight','bold', ...
               'callback',@minus_cb);
        end
    end %initgraphics

    function [x,y,z] = cube(w)
    % CUBE  Coordinates of the faces of a cube.
    %   [x,y,z] = cube(w); surface(x,y,z)
    %   plots a cube of with w.

       u = [0 0; 0 0; w w; w w];
       v = [0 w; 0 w; 0 w; 0 w];
       z = [w w; 0 0; 0 0; w w];
       s = [nan nan]; 
       x = [u; s; v];
       y = [v; s; u];
       z = [z; s; w-z];
    end %cube

    function delete_hint(~,~)
        h = get(gcf,'userdata');
        h.ActionPreCallback = [];
        delete(findobj('tag','hint'))
    end

    function plus_cb(~,~)
        n = get(gca,'userdata');
        n = n+1;
        colorcubes(n)
    end

    function minus_cb(~,~)
        n = get(gca,'userdata');
        n = n-1;
        if n == 0
            scream
            n = 1;
        end
        colorcubes(n)
    end

end % colorcubes



