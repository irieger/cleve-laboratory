function biorhythms(birthday)
% BIORHYTHMS  Plot your biorhythm for an 8 week period.
%
% BIORHYTHMS(birthday)
% The input argument can be a string, a vector, or a datenum.
% Examples:
%    biorhythm('Aug 17, 1939')
%    biorhythm([1939 8 17])
%    biorhythm(fix(now-28))
% You can edit the resulting plot title to change the birthday.
%
% Biorhythms were very popular in the '60's.  You can still find
% many Web sites today that offer to prepare personalized biorhythms,
% or that sell software to compute them.
% Biorhythms are based on the notion that three sinusoidal cycles
% influence our lives.  The physical cycle has a period of 23 days,
% the emotional cycle has a period of 28 days, and the intellectual
% cycle has a period of 33 days.  For any individual, the cycles are
% initialized at birth, as shown by
%   biorhythms(now)

% Copyright 2016-2017 Cleve Moler
% Copyright 2016-2017 The MathWorks, Inc.
% From "Experiments with MATLAB"
% See http://www.mathworks.com/moler/exm/chapters/calendar.pdf

    if nargin == 0
        birthday = datestr(fix(now));
    end

    top = initialize(birthday);
    t0 = datenum(bday(top));
    t1 = fix(now);

    % Eight week time span centered on today.

    t = (t1-28):0.25:(t1+28);
    y = 100*[sin(2*pi*(t-t0)/23)
             sin(2*pi*(t-t0)/28)
             sin(2*pi*(t-t0)/33)];
    plot(t,y)

    finalize
             
% ------------------------------------

   function top = initialize(birthday)
      clf
      shg
      set(gcf, ...
          'menubar','none', ...
          'numbertitle','off', ...
          'name','biorhythms')
      set(gca,'position',[.10 .30 .80 .50])
      uicontrol( ...
          'style','text', ...
          'units','normalized', ...
          'position',[.35 .86 .32 .05], ...
          'string','Enter your birthday:');
      t0 = datenum(birthday);   
      top = uicontrol( ...
          'style','edit', ...
          'units','normalized', ...
          'position',[.35 .82 .32 .05], ...
          'string',['birthday: ' datestr(t0,1)], ...
          'callback',@top_cb);
      uicontrol('style','pushbutton', ...
          'units','normalized', ...
          'position',[.90 .92 .08 .06], ...
          'string','info', ...
          'fontweight','bold', ...
          'callback', ...
              'web(''info/biorhythms_info.html'',''-notoolbar'')');   
      uicontrol( ...
          'style','toggle', ...
          'string','exit', ...
          'fontweight','bold', ...
          'visible','on', ...
          'units','normalized', ...
          'position',[.90 .84 .08 .06], ...
          'callback','close(gcf)');
   end

    function b = bday(top)
        b = strrep(top.String,'birthday:','');
    end

    function top_cb(varargin)
        % callback function
        bday = strrep(get(top,'string'),'birthday:','');
        set(top,'string',['birthday: ' datestr(bday,1)])
        biorhythms(bday)
    end

   function finalize(~)
      line([t1 t1],[-100 100],'color','k')
      line([t1-28 t1+28],[0 0],'color','k')
      axis tight
      set(gca,'xtick',(t1-28):7:(t1+28))
      datetick('x',6,'keeplimits','keepticks')
      t1 = fix(now);
      text(t1-5,-130,['today: ' datestr(t1,1)]);
      legnd = legend('Physical','Emotional','Intellectual');
      set(legnd,'position',[.10 .07 .18 .12])
      drawnow
      shg
   end %finalize
end % biorhythm
