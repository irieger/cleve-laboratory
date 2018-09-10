function moebiusapp(varargin)
    %MOEBIUSAPP  Investigate moebius strip.
    %   Vary curvature,  width and  number of twists.

    %   Copyright 2000-2017 Cleve Moler
    %   Copyright 2000-2017 The MathWorks, Inc.

    if nargin == 0
       [curve,width,twist,grid] = init_graphics;
    else
       [curve,width,twist,grid] = get_graphics;
    end
    
    c = get(curve,'value');
    c = max(c,eps);  % Avoid zero curvature.
    w = get(width,'value');
    k = get(twist,'value');
    [n,m] = size(grid);
    
    [s,t] = meshgrid(-1:2/(m-1):1, -1:2/(n-1):1);
    r = (1-w) + w*s.*sin(k/2*pi*t);
    x = r.*sin(c*pi*t)/c;
    y = r.*(1 - (1-cos(c*pi*t))/c);
    z = w*s.*cos(k/2*pi*t);

    update_graphics(x,y,z,t)
    
% ----------------------------------------------------------------        
    
    function [curve,width,twist,s] = init_graphics
       clf
       cmax = 1;  % Maximum curvature
       wmax = 1;  % Maximum strip width
       kmax = 6;  % Maximum number of twists
       n = 256;   % Grid size
       m = 12;
       set(gcf,'color','white', ...
           'name','moebiusapp', ...
           'menu','none', ...
           'numbertitle','off')
       curve = uicontrol('string','curve', ...
           'style','slider', ...
           'units','normalized', ...
           'position',[.07 .015 .24 .05], ...
           'max',cmax, ...
           'value',cmax/4, ...
           'sliderstep',[1/48 1/24], ...
           'callback',@moebiusapp);
       width = uicontrol('string','width', ...
           'style','slider', ...
           'units','normalized', ...
           'position',[.38 .015 .24 .05], ...
           'max',wmax, ...
           'value',wmax/4, ...
           'sliderstep',[1/48 1/24], ...
           'callback',@moebiusapp);
       twist = uicontrol('string','twist', ...
           'style','slider', ...
           'units','normalized', ...
           'position',[.69 .015 .24 .05], ...
           'max',kmax, ...
           'value',0, ...
           'sliderstep',[1/48 1/24], ...
           'callback',@moebiusapp);
       
       choices = {'choose', ...
                 'classic', ...
                 'triple', ...
                 'four leaf', ...
                 'kermit', ...
                 'prism', ...
                 'titan'};
       uicontrol('style','popupmenu', ...
           'units','normalized', ...
           'position',[.09 .09 .15 .06], ...
           'tag','choices', ...
           'string',choices, ...
           'callback',@choose_cb);
       
       colors = {'hsv', ...
           'cool', ...
           'parula', ...
           'copper', ...
           'prism', ...
           'titan'};
       uicontrol('style','popupmenu', ...
           'units','normalized', ...
           'position',[.28 .09 .15 .06], ...
           'tag','colors', ...
           'string',colors, ...
           'callback',@color_cb);            
       
       uicontrol('style','toggle', ...
           'units','normalized', ...
           'position',[.47 .09 .12 .06], ...
           'background','white', ...
           'string','light', ...
           'callback',@light_cb);            
       
       uicontrol('style','toggle', ...
           'units','normalized', ...
           'position',[.63 .09 .12 .06], ...
           'background','white', ...
           'string','toolbar', ...
           'callback',@toolbar_cb); 
       
       uicontrol('style','toggle', ...
           'units','normalized', ...
           'position',[.79 .09 .12 .06], ...
           'background','white', ...
           'string','spin', ...
           'callback',@spin_cb); 
       
       uicontrol('style','pushbutton', ...
           'units','normalized', ...
           'position',[.90 .92 .08 .06], ...
           'background','white', ...
           'string','info', ...
           'fontweight','bold', ...
           'callback','web(''http://blogs.mathworks.com/cleve/2016/04/25'')')
       
       [s,t] = meshgrid(-1:2/(m-1):1, -1:2/(n-1):1);
       surf(s,t,s,t);
       color_cb('copper')
       axis([-1 1 -1 1 -1 1])
       axis off
       set(gca,'cameraviewangle',8, ...
            'clipping','off');       
    end

    function [curve,width,twist,grid] = get_graphics
       curve = findobj('string','curve');
       twist = findobj('string','twist');
       width = findobj('string','width');
       h = findobj(gcf,'type','surface');
       grid = get(h,'xdata');
    end

    function update_graphics(x,y,z,t)
       h = findobj(gcf,'type','surface');
       set(h,'xdata',x);
       set(h,'ydata',y);
       set(h,'zdata',z);
       set(h,'cdata',t);
    end

    function light_cb(v,~)
        % Let there be light.
        if get(v,'value')
            shading interp
            lighting phong
            camlight('headlight')
        else
            delete(findobj(gcf,'type','light'))
        end
    end

    function toolbar_cb(v,~)
        % Lot's of goodies on the camera toolbar.
        if get(v,'value')
            cameratoolbar('show')
            cameratoolbar('setmode','orbit')
        else
            cameratoolbar('hide')
        end
    end

    function spin_cb(v,~)
        % Psychedelic action with prism.
        while ~isempty(findobj('string','spin')) && get(v,'value')
            cm = colormap;
            colormap([cm(2:end,:); cm(1,:)])
            pause(.025)
        end
    end

    function color_cb(v,~)
        % Install a color map.
        if nargin == 2   % callback
            vj = get(v,'value');
            vs = get(v,'string');
            v = vs{vj};
        end
        switch v
            case 'hsv'
                colormap(hsv)
                set(findobj('tag','colors'),'value',1)
            case 'cool'
                colormap([cool(256); flipud(cool(256))])
                set(findobj('tag','colors'),'value',2)
            case 'parula'
                colormap([parula(256); flipud(parula(256))])
                set(findobj('tag','colors'),'value',3)
            case 'copper'
                cm = copper(512);
                colormap([cm(257:512,:); cm(512:-1:257,:)]);
                set(findobj('tag','colors'),'value',4)
            case 'prism'
                colormap(prism(240))
                set(findobj('tag','colors'),'value',5)            
            case 'titan'
                ct = circshift(flipud(hsv(256)),80);
                colormap(ct)
                set(findobj('tag','colors'),'value',6)
        end
    end

    function choose_cb(varargin)
       choices = {'choose', ...
             'classic', ...
             'triple', ...
             'four leaf', ...
             'kermit', ...
             'prism', ...
             'titan'};
       [curve,width,twist,grid] = get_graphics;
       v = get(findobj('tag','choices'),'value');

        switch choices{v}
            
        case 'classic'
           set(curve,'value',1)
           set(width,'value',1/4)
           set(twist,'value',1)
           shading interp
           color_cb('parula')
           view(3)
           lighting phong
           set(gca,'cameraviewangle',7)
           delete(findobj(gcf,'type','light'))
           light('position',[0 -1 1]);
           moebiusapp(v)

        case 'triple'
           % Triple twist
           set(curve,'value',1)
           set(width,'value',1/4)
           set(twist,'value',3)
           color_cb('hsv')
           shading interp
           lighting phong
           light('position',[0 -1 1])
           material([.3 .8 .6 8 1])
           % zoom(1.3)
           moebiusapp(v)

        case 'four leaf'
           % V5 Gallery
           set(curve,'value',1)
           set(width,'value',1/2)
           set(twist,'value',4)
           shading interp
           color_cb('cool')
           view(-40,40)
           lighting phong
           set(gca,'cameraviewangle',7)
           delete(findobj(gcf,'type','light'))
           light('position',[0 -1 1]);
           material([.3 .8 .6 8 1])
           moebiusapp(v)

        case 'kermit'
           % Kermit Sigmon, MATLAB Primer, Fifth Edition
           set(curve,'value',1)
           set(width,'value',3/5)
           set(twist,'value',5)
           shading interp
           color_cb('hsv')
           view(0,90)
           lighting phong
           set(gca,'cameraviewangle',7)
           delete(findobj(gcf,'type','light'))
           light('position',[0 -1 2]);
           light('position',[-.5 .5 2]);
           material([.3 .8 .6 8 1])
           moebiusapp(v)

        case 'prism'
           set(curve,'value',1)
           set(width,'value',1)
           set(twist,'value',6)
           delete(findobj(gcf,'type','light'))
           color_cb('prism')
           view(0,90)
           moebiusapp(v)
           
        case 'titan'
           % Ardent Titan and IEEE Computer, 1988.
           set(curve,'value',1)
           set(width,'value',.78)
           set(twist,'value',4)
           moebiusapp(v)
           h = findobj(gcf,'type','surface');
           x = get(h,'xdata');
           y = get(h,'ydata');
           z = get(h,'zdata');
           t = get(h,'cdata');
           update_graphics(-z,x,y,t)
           set(h,'LineStyle','none');
           color_cb('titan')
           view(117, 54);
           camup([4 0 10])
           camlight('headlight');
           set(h,'ambientstrength',0)
           set(h,'diffusestrength',0.9)
           set(h,'specularstrength',0)

        otherwise
           clf
           moebiusapp
           return
        end
    end
end
