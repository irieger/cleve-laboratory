function run = pawsit(count)
% PAWSIT.  Manage pause and exit buttons.
% pawsit with no args creates pause and exit and returns ~exit.value.
% pawsit(0) is the same as pawsit.
% pawsit(count) does not create buttons and is true count times.

%   Copyright 2016 Cleve Moler
%   Copyright 2016 The MathWorks, Inc.

    persistent ntimes
    if nargin == 0 || isequal(count,0)
        % Graphics state stored in current axis appdata.
        paws = getappdata(gca,'paws');
        if isempty(paws)
            paws.pause = uicontrol('style','toggle','string','pause', ...
                'fontweight','bold','visible','on','background','w', ...
                'units','norm','pos',[.90 .84 .08 .06],'value',false);
            paws.exit = uicontrol('style','toggle','string','exit', ...
                'fontweight','bold','visible','on','background','w', ...
                'units','norm','pos',[.90 .76 .08 .06],'value',false);
            setappdata(gca,'paws',paws)
            drawnow
        end
        while paws.pause.Value && ~paws.exit.Value
            paws.pause.String = 'go';
            % pause(.01)
            drawnow
        end
        paws.pause.String = 'pause';
        run = ~paws.exit.Value;
        if ~run
            delete(paws.pause)
            delete(paws.exit)
            setappdata(gca,'paws',[])
        end
    else
        % Numeric state saved in persistent variable.
        if isempty(ntimes)
            ntimes = 0;
        end
        ntimes = ntimes + 1;
        run = (ntimes <= count);
        if ~run
            ntimes = [];
        end
    end
end % pawsit