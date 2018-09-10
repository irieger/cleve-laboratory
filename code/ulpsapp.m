function ulpsapp(varargin)
% Generate plots for ulps plot blog post.
% ulpsapp(f)
% ulpsapp(f,a,b,ulpsmax)
% Ex: ulpsapp(@erf,0,2,1.25)

%   Copyright 2016-2017 The MathWorks, Inc.

    funs = {'ulpsapp','sin','tan','atan','exp','erfinv', ...
        'lambertw','besselj0','info','exit'};
    
    switch nargin
        case 0
            init_popup
        case {1,4}
            ulpsplot(varargin{:})
        case 2  % popup callback
            p = get(varargin{1},'value');
            f = str2func(funs{p});
            ulpsplot(f);
    end
    
    function init_popup(varargin)
        set(gcf,'menubar','none', ...
            'numbertitle','off', ...
            'name','ulpsapp')
        clf
        shg
        uicontrol('string',funs, ...
           'style','popupmenu', ...
           'units','normalized', ...
           'position',[.40 .50 .20 .06], ...
           'callback',@ulpsapp);
    end
      
    function ulpsplot(f,a,b,ulpsmax)
    % Generate plots for ulps plot blog post.
    % ulpsplot(f)
    % ulpsplot(f,a,b,ulpsmax)
    % Ex: ulpsplot(@erf,0,2,1.25)

    set(gcf,'menubar','none', ...
        'numbertitle','off', ...
        'name','ulpsapp')
    clf
    shg        
    colors = get(gca,'colororder');
    charf = char(f);
    if nargin < 4
        switch charf
            case 'sin'
                a = 0;
                b = 2*pi;
                ulpsmax = 1.2;
                dotc = colors(1,:);
                set(gca,'xtick',(1:2:7)*pi/4, ...
                    'xticklabel',{'\pi/4','3\pi/4','5\pi/4','7\pi/4'})
            case 'tan'
                a = 0;
                b = 2*pi;
                ulpsmax = 1.2;
                dotc = colors(2,:);
                set(gca,'xtick',(1:2:7)*pi/4, ...
                    'xticklabel',{'\pi/4','3\pi/4','5\pi/4','7\pi/4'})
            case 'exp'
                a = -2;
                b = 2;
                ulpsmax = 1.2;
                dotc = colors(3,:);
                set(gca,'xtick',(-5:2:5)*log(2)/2, ...
                    'xticklabel', ...
                    {'-5*r/2','-3*r/2','-r/2','r/2','3*r/2','5*r/2'})
                xlabel('r = log(2)')
            case 'atan'
                a = 0;
                b = 39/16;
                ulpsmax = 1.2;
                dotc = colors(4,:);
                set(gca,'xtick',[0 7 11 19 39]/16, ...
                    'xticklabel',{'0','7/16','11/16','19/16','39/16'})
            case 'lambertw'
                ebar = -1/exp(1);
                a = ebar;
                b = 2;
                ulpsmax = 3.25; 
                dotc = colors(5,:);
                xtick = [ebar 0  .14 .32 .82 2];
                set(gca,'xtick',xtick, ...
                    'xticklabel',{'-1/e','0','.14','.32','.82','2'})
                ytick = [-9/4 -4/3 -1 1 4/3 9/4];
                set(gca,'ytick',ytick, ...
                    'yticklabels',{'-9/4','-4/3','-1','1','4/3','9/4'})
            case 'besselj0'
                f = @(x) besselj(0,x);
                a = 0;
                j01 = fzero(f,pi);
                j02 = fzero(f,2*pi);
                b = j02 + 2.0;
                ulpsmax = 8;
                dotc = colors(6,:);
                set(gca,'xtick',[0 j01 j02])
            case 'erfinv'
                a = 0;
                b = 1;
                ulpsmax = 2;
                dotc = colors(7,:);
            case 'info'
                web('http://blogs.mathworks.com/cleve/2017/01/23');
                init_popup
                return
            case 'exit'
                close(gcf)
                return
            otherwise
                init_popup
                return
        end
    else
        dotc = colors(ceil(7*rand),:);    
    end

    axis([a b -ulpsmax ulpsmax]);
    box on
    hold on
    line([a b],[.5 .5],'color','k')
    line([a b],[-.5 -.5],'color','k')
    stop = uicontrol('string','stop', ...
        'units','normalized', ...
        'position',[.02 .02 .10 .06], ...
        'style','toggle');
    cnt = 0;
    umin = 0;
    umax = 0;  
    
    while cnt < 100000 && get(stop,'value') == 0
       x = a + rand(1000,1)*(b-a);   
       y = f(x);
       Y = vpa(f(sym(x,'f')));
       ulps = eps(double(Y));
       u = double(Y-sym(y,'f'))./ulps;
       plot(x,u,'.','color',dotc)
       umin = min(umin,min(u));
       umax = max(umax,max(u));
       cnt = cnt + 1000;
       title(sprintf('%s, cnt = %1.0f',charf,cnt))
       drawnow
    end

    line([a b],[umax umax],'color','k')
    line([a b],[umin umin],'color','k')
    if umin > -ulpsmax && umax < ulpsmax
        ytick = [-1.0 umin -0.5 0 0.5 umax 1.0]; 
    elseif ~isequal(f,@lambertw)
        ytick = [-ulpsmax -ulpsmax/2 -1.0 1.0 ulpsmax/2 ulpsmax]; 
    end
    set(gca,'ytick',sort(ytick))
    title(charf)
    set(stop,'string','close', ...
        'callback',@init_popup)
    end % ulpsplot
end % ulpsapp