function interpthumb
%INTERPTHUMB Thumbnail for INTERPAPP.
%   Demonstrates interpolation by a piecewise linear interpolant,
%   a polynomial, a spline, and a shape preserving Hermite cubic.
%   See also SPLINETX, PCHIPTX, POLYINTERP, PIECELIN.

%   Copyright 2016-2017 Cleve Moler
%   Copyright 2016-2017 The MathWorks, Inc.

    n = 6;
    x = 1:n;
    y = randn(1,n);

    % Initialize figure

    cla
    h = diff(x);
    u = zeros(1,128*(n+1));
    j = 1:128;
    s = (1+sin((j-65)/128*pi))/2;
    u(j) = x(1)+(s-1)*h(1);
    for k = 1:n-1
      u(128*k+j) = x(k)+s*h(k);
    end
    u(128*n+j) = x(n)+s*h(n-1);
    p = plot(x,y,'o',u,zeros(4,length(u)),'-');
    ymin = min(y);
    ymax = max(y);
    ydel = ymax-ymin;
    if ydel == 0; ydel = 1; end

    set(p(1),'xdata',x,'ydata',y)
    set(p(2),'xdata',u,'ydata',piecelin(x,y,u));
    set(p(3),'xdata',u,'ydata',polyinterp(x,y,u));
    set(p(4),'xdata',u,'ydata',splinetx(x,y,u));
    set(p(5),'xdata',u,'ydata',pchiptx(x,y,u));

    % Visibility

    b = round(rand(1,4));
    onf = {'off','on'};
    for k = 1:4
       % Interpolants
       set(p(k+1),'visible',onf{b(k)+1})
    end
    
    ylim = 1.2*max(ymax,-ymin);
    axis([-1 n+2 -1.4*ylim 1.4*ylim])
    line([0 n+1 n+1 0 0],[-1 -1 1 1 -1]*ylim,'color','k')
    line([0 n+1],[0 0],'color','k')
    set(gca,'xtick',[],'ytick',[])
