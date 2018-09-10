function dragon
    % Investigate the Dragon Curve.
    % See Cleve's Corner:
    %    https://blogs.mathworks.com/cleve/2018/04/06/the-dragon-curve.
    
    %   Copyright 2018 The MathWorks, Inc.
    
    z = [0 1];    % Start with this segment
    n = 0;        % 2^(n+1) segments
    r = 1;        % r rotations
    w = (1+i)/2;  % Vertex
    
    init_graphics;
    plot_z
    
    % Callbacks are responsible for all the action.
    
    % ----------------------------------------------------

    function fold(~,~)
        % Double the number of segments.
        % '>' callback.
        z(1);  % Insectifuge.
        n = n+1;
        zleft = w*z;
        zright = 1 - w'*fliplr(z);
        z = [zleft zright];
        plot_z
        enable('<')
    end

    function unfold(~,~)
        % Half the number of segments.
        % '<' callback.
        n = n-1;
        m = length(z)/2;
        z = z(1:m)/w;
        plot_z
        if n == 0, disable('<'), end
    end

    function rotate(~,~)
        % Increase the number of rotations.
        % '>>' callback.
        r = r+1;
        plot_z
        if r == 4, disable('>>'), end
        enable('<<')
    end

    function unrotate(~,~)
        % Decrease the number of rotations.
        % '<<' callback.
        r = r-1;
        plot_z
        if r == 0, disable('<<'), end
        enable('>>')
    end

    function enable(s)
        set(findobj('string',s), ...
            'enable','on', ...
            'background','white')
    end

    function disable(s)
        set(findobj('string',s), ...
            'enable','off', ...
            'background',[.9 .9 .9])
    end

    function plot_z
        % Does all the plotting.
        cla
        m = ceil((length(z)+1)/2);
        z1 = z(1:m);
        z2 = z(m:end);
        
        % 2*r segments in the complex plane.
        h = line(zeros(2,2*r),zeros(2,2*r));
        
        f = 1;  % Rotation factor
        for k = 0:r-1
            set(h(2*k+1),'xdata',real(f*z1),'ydata',imag(f*z1))
            set(h(2*k+2),'xdata',real(f*z2),'ydata',imag(f*z2))
            f = i*f;
        end
        
        title(sprintf('%2d,%2d',n,r))
    end
       
    function init_graphics
        clf
        shg
        % s = 149/128;  % Exact fit
        s = 5/4;        % A little extra room.
        axis([-s s -s s])
        axis square
        box on
        set(gca,'xtick',[],'ytick',[])
        
        % Permute Handle Graphics default color order.
        % Include black to give eight colors, just enough.
        c = get(gca,'colororder');
        black = [0 0 0];
        c = [black; c([1:5 7 6],:)];
        set(gca,'colororder',c)
        
        % Four pushbuttons.
        strings = {'<<','<','>','>>'};
        callbacks = {@unrotate, @unfold, @fold, @rotate};
        for k = 1:4
            uicontrol( ...
                'string',strings{k}, ...
                'fontsize',16, ...
                'units','normalized', ...
                'position',[.18+.12*k .02 .07 .07], ...
                'background','white', ...
                'callback',callbacks{k});
        end
        disable('<')
        disable('<<')        
    end
end