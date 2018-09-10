function fibonacci(~)
% FIBONACCI  Fibonacci's rabbit pen.
% How fast does the population grow?
% It takes one month for baby rabbits to mature.
% The population is initialized with one blue baby bunny.
% Clicking on a blue bunny turns it into a blue mature rabbit.
% Clicking on a blue rabbit creates a gray bunny and turns the rabbit gray.
% Clicking on a gray bunny or gray rabbit does nothing.
% When all the bunnies and rabbits are gray, they are counted and turned blue.
% The month button does the clicking automatically.

%   Copyright 2016 Cleve Moler
%   Copyright 2016 The MathWorks, Inc.

   % R = structure of rabbit images.
   % pos = history of positions.
   R = [];
   pos = [];
   
   exit = init_graphics;
   
   while ~exit.Value
       update
       drawnow
   end
   
   close(gcf)
  
% ------------------------------

   function exit = init_graphics
      clf reset
      shg
      set(gcf, ...
          'menubar','none', ...
          'numbertitle','off', ...
          'name','fibonacci', ...
          'units','pixels')

      R = load('rabbits.mat');
      R.graybunny = cat(3,R.bunny,R.bunny,R.bunny); 
      R.grayrabbit = cat(3,R.rabbit,R.rabbit,R.rabbit); 
      R.bluebunny = cat(3,R.bunny,R.bunny,255*ones(size(R.bunny),'uint8'));
      R.bluerabbit = cat(3,R.rabbit,R.rabbit,255*ones(size(R.rabbit),'uint8'));

      f = get(gcf,'position');
      p = ceil(.45*f(3:4));
      pos = p;

      % Single bunny
      uicontrol('style','pushbutton', ...
          'position',[p 80 80], ...
          'background','white', ...
          'cdata',R.bluebunny, ...
          'tag','bluebunny', ...
          'callback',@bluebunny);

      % Population counter
      uicontrol('style','text', ...
          'fontsize',16,...
          'fontweight','bold', ...
          'position',[f(3)/2-56 f(4)-40 84 28], ...
          'string','   1');
      
      % Auto toggle
       uicontrol('style','toggle', ...
          'position',[20 20 80 30], ...
          'fontsize',12, ...
          'string','month', ...
          'callback',@month);
     
      % Exit
      exit = uicontrol('style','toggle', ...
         'position',[120 20 80 30], ...
         'fontsize',12, ...
         'string','exit');
   end

% ------------------------------

   function bluebunny(handle,varargin)
      % A blue bunny turns into a gray rabbit.
      set(handle,'cdata',R.grayrabbit,'tag','grayrabbit', ...
         'callback',@update)
   end

% ------------------------------

   function bluerabbit(handle,varargin)
      % A blue rabbit creates a gray bunny and turns gray itself.
      p = find_good_position;
      uicontrol('style','pushbutton','position',[p 80 80], ...
         'background','white','cdata',R.graybunny,'tag','graybunny', ...
         'callback',@update);
      set(handle,'cdata',R.grayrabbit,'tag','grayrabbit', ...
         'callback',@update);
   end

% ------------------------------

   function p = find_good_position
      % Avoid toggle and population counter.
      f = get(gcf,'position');
      ds = -Inf;
      % Choose best of several random positions.
      for k = 1:20
         p = ceil(.80*f(3:4).*rand(1,2));
         % Avoid toggles in lower right hand corner.
         if p(1) < 200 && p(2) < 50
            continue
         end
         % Avoid population counter centered near the top.
         f = get(gcf,'pos');
         if (p(2)+80 > f(4)-40) && (p(1)+100 > f(3)/2-14) ...
            && (p(1) < f(3)/2+14)
            continue
         end
         r = p(ones(size(pos,1),1),:);
         d = min(min(abs(pos-r)'));
         if d > ds
            ds = d;
            ps = p;
         end
      end
      p = ps;
      pos = [pos; p];
   end

% ------------------------------

   function update(varargin)
      % When all are gray, turn them all blue.
      b = findobj(gcf,'style','pushbutton');
      n = length(b);
      c = get(b,'tag');
      if n == 1
         c = {c};
      end
      % Check for all gray.
      if length(strfind([c{:}],'gray')) == n
         for k = 1:n
            if strfind(c{k},'graybunny')
               set(b(k),'cdata',R.bluebunny,'tag','bluebunny', ...
                  'callback',@bluebunny)
            else
               set(b(k),'cdata',R.bluerabbit,'tag','bluerabbit', ...
                  'callback',@bluerabbit);
            end
         end
         % Update population counter.
         set(findobj(gcf,'style','text'),'string',n)
      end
   end

% ------------------------------

   function month(h,~)
      % Auto toggle callback
      % Complete one month's growth
      set(h,'enable','off')
      b = [findobj(gcf,'tag','bluebunny')
           findobj(gcf,'tag','bluerabbit')];
      n = length(b);
      b = b(randperm(n));
      for k = 1:n
          b(k).Callback(b(k))
          pause(.025)
      end
      set(h,'enable','on','value',0)
   end

end % fibonacci
