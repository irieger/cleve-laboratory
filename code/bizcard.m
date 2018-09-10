function bizcard(~)
    % BIZCARD  Future version of MathWorks business card.
    %   Click on the background, then on the logo.

    %   Copyright 2014-2018 Cleve Moler
    %   Copyright 2014-2018 The MathWorks, Inc.

    thumb = nargin==1;
    if thumb
        cla
        ax1 = framed_axis([.02 .82 .16 .11]);
        fs1 = 4;
        fs2 = 8;
        fs3 = 3;
    else
        clf reset
        shg
        set(gcf,'name','bizcard', ...
            'menu','none','numbertitle','off');
        ax1 = axes('pos',[.125 .25 .75 .5], ...
            'xtick',[],'ytick',[],'box','on');
        fs1 = 12;
        fs2 = 24;
        fs3 = 10;
    end
    text(.4,.8,'MathWorks, Inc.','fontsize',fs2, ...
       'fontname','Times New Roman','fontweight','normal');
    text(.45,.6,'CLEVE MOLER','fontsize',fs1);
    text(.45,.5,'Chief Mathematician','fontsize',fs1);
    text(.45,.4,'moler@mathworks.com','fontsize',fs1);
    text(.45,.3,'508.647.7000','fontsize',fs1);
    text(.1,.17,'www.mathworks.com','fontsize',fs3);
    text(.1,.1,'MathWorks, 3 Apple Hill Drive, Natick, MA', ...
       'fontsize',fs3);
    L{1} = 30*membrane(1,25);
    L{2} = 2*membrane(2,25);
    L{3} = -2*membrane(3,25);
    L{4} = 5*membrane(4,25);
    L{5} = -3*membrane(5,25);
    L{6} = 4*membrane(6,25);
    if thumb
        pos = [.012 .85 .08 .08];
    else
        pos = [.15 .40 .3 .3];
    end
    axes('Position',pos, ...
         'CameraPosition', [-193.4013 -265.1546  220.4819],...
         'CameraTarget',[26 26 10], ...
         'CameraUpVector',[0 0 1], ...
         'CameraViewAngle',9.5, ...
         'DataAspectRatio', [1 1 .9],...
         'Visible','off', ...
         'XLim',[1 51], ...
         'YLim',[1 51], ...
         'ZLim',[-13 40]);
    s = surface(L{1}, ...
         'EdgeColor','none', ...
         'FaceColor',[0.9 0.2 0.2], ...
         'FaceLighting','phong', ...
         'AmbientStrength',0.3, ...
         'DiffuseStrength',0.6, ... 
         'Clipping','off',...
         'BackFaceLighting','lit', ...
         'SpecularStrength',1.0, ...
         'SpecularColorReflectance',1, ...
         'SpecularExponent',7);
    light('Position',[40 100 20], ...
         'Style','local', ...
         'Color',[0 0.8 0.8]);
    light('Position',[.5 -1 .4], ...
         'Color',[0.8 0.8 0]);

    mu = sqrt([9.6397238445, 15.19725192, 2*pi^2, ...
               29.5214811, 31.9126360, 41.4745099]);
    set(gcf,'userdata',false);
    set(ax1,'buttondownfcn','set(gcf,''userdata'',~get(gcf,''userdata''))');
    set(s,'buttondownfcn',@s_cb);
    stop = uicontrol('style','toggle', ...
        'string','X', ...
        'units','norm', ...
        'pos',[.95 .95 .05 .05]);
    if thumb
        set(stop,'vis','off')
    end

    t = 0;
    delta = .025;
    while ~get(stop,'value')
       Z = cos(mu(1)*t)*L{1} + sin(mu(2)*t)*L{2} + sin(mu(3)*t)*L{3} +  ...
           sin(mu(4)*t)*L{4} + sin(mu(5)*t)*L{5} + sin(mu(6)*t)*L{6};
       set(s,'zdata',Z)
       pause(.01)
       if get(gcf,'userdata')
          t = t + delta;
       end
       if thumb
           break
       end
    end
    if ~thumb
        close(gcf)
    end
    
    function s_cb(~,~)
        figure
        logo_wave
        set(stop,'value',1)
    end
end
