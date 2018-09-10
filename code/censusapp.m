function censusapp(model)
%CENSUSAPP Try to predict the US population.
% This example is older than MATLAB.  It started as an exercise in
% "Computer Methods for Mathematical Computations", by Forsythe,
% Malcolm and Moler, published by Prentice-Hall in 1977.
% The data set has been updated every ten years since then.
% Today, MATLAB makes it easier to vary the parameters and see the
% results, but the underlying mathematical principles are unchanged:
%
%    Using polynomials of even modest degree to predict
%    the future by extrapolating data is a risky business.
%
% The data is from the decennial census of the United States for the
% years 1900 to 2010.  The task is to extrapolate beyond 2010.
%
% In addition to polynomials of various degrees, you can choose
% interpolation by a cubic spline or a shape-preserving
% Hermite cubic, and least squares fits by an exponential,
% a logistic sigmoid, and a double exponential(gompertz).
%
% Error estimates attempt to account for errors in the data,
% but not in the extrapolation model.

%   Copyright 2014-2018 Cleve Moler
%   Copyright 2014-2018 The MathWorks, Inc.

% Census data for 1900 to 2010.
% The population on April 1, 2010 was 308,745,538, according to:
% http://www.census.gov/2010census/data/

p = [ 75.995  91.972 105.711 123.203 131.669 150.697 ...
     179.323 203.212 226.505 249.633 281.422 308.746]';
t = (1900:10:2010)';   % Census years
x = (1890:2030)';      % Evaluation years
w = 2018;              % Extrapolation target
z = 327.879;           % Census Bureau model
dmax = length(t)-1;    % Maximum polynomial degree
models = {'census data','polynomial','pchip','spline', ...
          'exponential','logistic','gompertz'}';

if nargin==0 || isempty(get(gcf,'userdata'))
   % Initialize plot and uicontrols
   h = init_graphics;
   model = 'census data';
else
   h = get(gcf,'userdata');
end

% Update plot with new model

% model = models{get(h.model,'value')};
w = get(h.predict,'userdata');
x = (1890:max(2030,w+30))';
switch model  
   case 'census data'
      y = NaN*x;
      z = 324.790 + (w-2017)*(2.64 + 0.0042*(w-2017));
   case 'polynomial'
      set(h.deg,'vis','on')
      d = get(h.deg,'userdata');
      s = (t-1955)/55;   
      c = polyfit(s,p,d);
      s = (x-1955)/55;   
      y = polyval(c,s);
      s = (w-1955)/55;   
      z = polyval(c,s);
   case 'pchip'
      y = pchip(t,p,x);
      z = pchip(t,p,w);
   case 'spline'
      y = spline(t,p,x);
      z = spline(t,p,w);
   case 'exponential'
      c = polyfit(log(t),log(p),1);
      y = exp(polyval(c,log(x)));
      z = exp(polyval(c,log(w)));
   case 'logistic'
      logistic = @(k,t) k(1)./(1+k(2)*exp(-k(3)*t));
      a = fminbnd(@(a)logistic_fit(a,t,p),500,1000);
      [~,b,c] = logistic_fit(a,t,p);
      y = logistic([a,b,c],x);
      z = logistic([a,b,c],w);
   case 'gompertz'
      gompertz = @(k,t)k(1)*exp(-k(2)*exp(-k(3)*t));
      a = fminbnd(@(a)gompertz_fit(a,t,p),1000,6000);
      [~,b,c] = gompertz_fit(a,t,p);
      y = gompertz([a,b,c],x);
      z = gompertz([a,b,c],w);
end
set(h.plot(2),'xdata',x,'ydata',y);
set(h.plot(3),'vis','on','xdata',w,'ydata',z);
ax = axis;
set(h.extrap,'pos',[w,min(max(z+20,30),ax(4)-30)], ...
    'vis','on', ...
    'string',sprintf('%6.1f',z))
set(h.title,'string',['Predict U.S. Population in ' int2str(w)])

% Update controls

switch model
   case 'census data'
      set(h.err,'vis','off', ...
         'value',0);
      set([h.deg; h.gt; h.lt],'vis','off');
      set(h.extrap,'pos',[w,min(max(z+20,30),ax(4)-30)], ...
             'string','predict')
   case 'polynomial'
      set(h.err,'vis','on','pos',[.20 .58 .20 .05])
      d = get(h.deg,'userdata');
      onoff = {'on','off'};
      set(h.lt,'vis','on', ...
         'enable',onoff{(d==0)+1});
      set(h.gt,'vis','on', ...
         'enable',onoff{(d==dmax)+1});
   otherwise
      set(h.err,'vis','on', ...
         'pos',[.20 .65 .20 .05]);
      set([h.deg; h.gt; h.lt], ...
         'vis','off');
end

% Display error estimates if requested

if get(h.err,'value') == 1
   errest = errorestimates(model,t,p,x,y);
   set(h.plot(4),'vis','on', ...
       'xdata',[x;NaN;x],'ydata',errest);
else
   set(h.plot(4),'vis','off');
end

% ------------------------------------------------

    function h = init_graphics
        shg
        clf reset
        set(gcf,'name','censusapp', ...
           'menu','none', ...
           'numbertitle','off')
        h.plot = plot(t,p,'bo', ...
           x,0*x,'k-', ...
           w,0,'.', ...
           [x;NaN;x],[x;NaN;x],'m:');
        darkgreen = [0 2/3 0];
        darkmagenta = [2/3 0 2/3];
        marksize = get(0,'defaultlinemarkersize');
        set(h.plot(3),'color',darkgreen, ...
           'markersize',4*marksize-6)
        set(h.plot(4),'color',darkmagenta)
        axis([1890 2036 0 420])
        h.title = title(['Predict U.S. Population in ' int2str(w)]);
        ylabel('Millions')

        h.extrap = text(w,z+20,'predict', ...
           'horiz','right', ...
           'color',darkgreen, ...
           'fontweight','bold');
        h.predict = uicontrol('string','predict', ...
           'userdata',w, ...
           'units','norm', ...
           'pos',[.26 .78 .08 .05], ...
           'horiz','center', ...
           'style','text', ...
           'background','white');
        h.minus = uicontrol('string','-', ...
           'units','norm', ...
           'pos',[.20 .78 .05 .04], ...
           'style','push', ...
           'fontweight','bold', ...
           'callback',@pm_cb);
        h.plus = uicontrol('string','+', ...
           'units','norm', ...
           'pos',[.35 .78 .05 .04], ...
           'style','push', ...
           'fontweight','bold', ...
           'callback',@pm_cb);        
        h.model = uicontrol('string',models, ...
           'units','norm', ...
           'pos',[.20 .70 .20 .05], ...
           'style','popup', ...
           'background','white', ...
           'callback',@model_cb);
        h.deg = uicontrol('string','degree = 2', ...
           'userdata',2, ...
           'units','norm', ...
           'pos',[.26 .65 .13 .04], ...
           'style','text', ...
           'background','white');
        h.lt = uicontrol('string','<', ...
           'units','norm', ...
           'pos',[.20 .65 .05 .04], ...
           'style','push', ...
           'fontweight','bold', ...
           'callback',@lt_cb);
        h.gt = uicontrol('string','>', ...
           'units','norm', ...
           'pos',[.40 .65 .05 .04], ...
           'style','push', ...
           'fontweight','bold', ...
           'callback',@gt_cb);
        h.err = uicontrol('string','error estimates', ...
           'units','norm', ...
           'pos',[.20 .55 .20 .05], ...
           'style','check', ...
           'background','white', ...
           'callback',@model_cb);
        uicontrol('style','pushbutton', ...
            'units','normalized', ...
            'position',[.92 .90 .07 .06], ...
            'string','info', ...
            'callback',@info_cb);
        uicontrol('style','pushbutton', ...
            'units','normalized', ...
            'position',[.92 .82 .07 .06], ...
            'string','clock', ...
            'callback',@clock_cb);
        uicontrol('style','pushbutton', ...
            'units','normalized', ...
            'position',[.92 .74 .07 .06], ...
            'string','close', ...
            'callback','close(gcf)');
        set(gcf,'userdata',h);
    end

    function model_cb(varargin)
        m = get(h.model,'value');
        censusapp(models{m})
    end
 
    function pm_cb(varargin)
       sig = 2*(get(varargin{1},'string') == '+') - 1;
       w = get(h.predict,'userdata');
       if w < 2030
          w = w + sig;
       else
          w = w + 10*sig;
       end
       axis([1890 max(2030,w+20) 0 max(420,3*(w-1890))])
       set(h.predict,'userdata',w)
       model_cb
    end

    function lt_cb(varargin)
        d = get(h.deg,'userdata');
        d = d - 1;      
        set(h.deg,'vis','on', ...
            'string',['degree = ' num2str(d)], ...
            'userdata',d)
        if d == 0
            set(h.lt,'enable','off')
        end
        censusapp('polynomial')
    end

    function gt_cb(varargin)
        d = get(h.deg,'userdata');
        d = d + 1;
        set(h.deg,'vis','on', ...
            'string',['degree = ' num2str(d)], ...
            'userdata',d)
        if d == dmax
            set(h.gt,'enable','off')
        end
        censusapp('polynomial')
    end

    function info_cb(varargin)
        web(['http://blogs.mathworks.com/cleve/2017/01/05/' ...
                 'fitting-and-extrapolating-us-census-data'], ...
            '-notoolbar'); 
    end

    function clock_cb(varargin)
        web('http://www.census.gov/popclock/', ...
            '-notoolbar'); 
    end

    function errest = errorestimates(model,t,p,x,y)
    % Provide error estimates for censusapp
        switch model
           case 'polynomial'
              d = get(h.deg,'userdata');
              if d > 0
                 V(:,d+1) = ones(size(t));
                 s = (t-1955)/55;
                 for j = d:-1:1
                    V(:,j) = s.*V(:,j+1);
                 end
                 [~,R] = qr(V);
                 R = R(1:d+1,:);
                 RI = inv(R);
                 E = zeros(length(x),d+1);
                 s = (x-1955)/55;
                 for j = 1:d+1
                    E(:,j) = polyval(RI(:,j),s);
                 end
                 sig = 10;   % Rough estimate
                 e = sig*sqrt(1+diag(E*E'));
                 errest = [y-e; NaN; y+e];
              else
                 errest = [y-NaN; NaN; y+NaN];
              end
           case {'exponential','logistic','gompertz'}
              V = [ones(size(t)) log(t)];
              [Q,R] = qr(V);
              q = R\(Q'*log(p));
              r = log(p) - V*q;
              E = [ones(size(x)) log(x)]/R(1:2,1:2);
              sig = norm(r);
              e = sig*sqrt(1+diag(E*E'));
              errest = [y.*exp(-e); NaN; y.*exp(e)];
           case {'pchip','spline'}
              n = length(t);
              I = eye(n,n);
              E = zeros(length(x),n);
              for j = 1:n
                 switch model
                    case 'pchip'
                       E(:,j) = pchip(t,I(:,j),x);
                    case 'spline'
                       E(:,j) = spline(t,I(:,j),x);                    
                 end
              end
              sig = 10;  % Rough estimate
              e = sig*sqrt(1+diag(E*E'));
              errest = [y-e; NaN; y+e];
        end % switch
    end % errorestimates

    function [rnorm,b,c] = logistic_fit(a,t,p)
    % LOGISTIC_FIT.  Objective function for one dimensional search.
    % [rnorm,b,c] = logistic_fit(a,t,p)
    %    fits p with a./(1+b*exp(-c*t)).
    %    Returns norm(fit - p).
    % Uses linear fit of log(a./p-1) by log(b)-c*t.
    % Call a = fminbnd(@(a)logistic_fit(a,t,p),a_1,a_2).
        logistic = @(k,t) k(1)./(1+k(2)*exp(-k(3)*t));
        A = [ones(size(t)) -t];
        rhs = log(a./p-1);
        k = A\rhs;
        b = exp(k(1));
        c = k(2);
        r = logistic([a,b,c],t) - p;
        rnorm = norm(r);
    end

    function [rnorm,b,c] = gompertz_fit(a,t,p)
    %GOMPERTZ_FIT.  Objective function for one dimensional search.
    % [rnorm,b,c] = gompertz_fit(a,t,p)
    %    fits p with a*exp(-b*exp(-c*t))).
    %    Returns norm(fit - p).
    % Uses linear fit of log(log(a/p)) by log(b)-c*t.
    % Call a = fminbnd(@(a)gompertz_fit(a,t,p),a_1,a_2).
        gompertz = @(k,t) k(1)*exp(-k(2)*exp(-k(3)*t));
        A = [ones(size(t)) -t];
        rhs = log(log(a./p));
        k = A\rhs;
        b = exp(k(1));
        c = k(2);
        r = gompertz([a,b,c],t) - p;
        rnorm = norm(r);
    end 
   
end % censusapp
