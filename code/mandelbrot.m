function mandelbrot(varargin)
% MANDELBROT  Explore the Mandelbrot set.
%  mandelbrot with no arguments starts with a graphical menu.
%  mandelbrot(r) generates the r-th region in the menu
%
%  mandelbrot(center,width,grid,depth,cmapidx)
%     center = Region center (complex).  Default -.5+0i.
%     width = Region width.  Default 3.
%     grid = Grid size, usFually 2^k or 3*2^k.  Default 512.
%     depth = Trace length.  Default 256.
%     cmapidx = Index into cell array of colormap functions.  Default 1.
%
%  You can ...
%     Use the mouse to zoom in on any region.
%     Choose among several predefined regions.
%     Increase the grid size or iteration depth.
%     Change the color map.

%   Copyright 2014-2018 Cleve Moler
%   Copyright 2014-2018 The MathWorks, Inc.

% The "state" consists of
%   center
%   width
%   grid
%   depth
%   cmapidx
%   kz       % Counts on the grid, (grid+1)-by-(grid+1) uint16 array.
%   z        % z values on the grid, (grid+1)-by-(grid+1) complex array.
% As the state is modified, it is saved between callbacks in the gcf user data.

persistent menu mcounts
if isempty(menu)
   load mandelbrot_menu menu mcounts 
end
cmaps = {@parulas, @jets, @hots, @sepia, @cmyk, @flags, @fringe};
 
grid = [];
regidx = 1;

depth = [];
z = [];
kz = [];
cmapidx = [];
center = [];
width = [];

% Switchyard.

if nargin == 0 || isnumeric(varargin{1})
   if nargin == 0
      mandelbrotmenu
      return
   elseif nargin == 1
      regidx = varargin{1};
      region(regidx)
   else
      parseargs(varargin{:})
   end
   startup
   iterate(0,depth);
else
   get_state
   controls = flipud(findobj(gcf,'type','uicontrol'));
   job = varargin{1};
   switch job
      case 'depth'
         deepen
      case 'grid_'
         refine
      case 'color'
         colors
      case 'info'
         info
      otherwise
         error('Argument not recognized')
   end
end
state = {center,width,grid,depth,cmapidx,z,kz};
set(gcf,'userdata',state)

% ------------------------

function mandelbrotmenu
   clf reset
   shg
   set(gcf,'menubar','none','numbertitle','off','name','mandelbrot')  
   s = size(menu,1);
   n = ceil(sqrt(s));
   m = ceil(s/n);
   for r = 1:s
      for k = 1:length(cmaps)
         if isequal(menu{r,6},cmapname(k))
            cf = cmaps{k};
            break
         end
      end
      depth = menu{r,5};
      icon = ind2rgb(mcounts(end:-1:1,:,r),cf(depth));
      x = mod(r-1,n)/n+.01;
      y = floor((m*n-r)/n)/m+.01;
      cbs = ['figure, mandelbrot(' int2str(r) ')'];
      uicontrol('units','norm','cdata',icon,'pos',[x,y,.95/n,.95/m], ...
         'callback',cbs)
   end
end

% ------------------------

function iterate(startdepth,finaldepth)
   s = width*(-1/2:1/grid:1/2);
   [u,v] = meshgrid(s+real(center),s+imag(center));
   z0 = u + i*v;
   set(controls(6),'string','break','callback',[])
   a1 = gca;
   a2 = mwaitbar;
   for d = startdepth:finaldepth
      if mod(d,32) == 0
         set(controls(3),'string',[num2str(d) '/' num2str(finaldepth)])
         axes(a1)
         plotit
         if get(controls(6),'value') == 1
            break
         end
         if all(all(kz == kz(1,1))) && d > 0
            mwaitbar(a2,d/finaldepth);
         end
      end
      [z,kz] = mandelbrot_step(z,kz,z0,d);
%     mandelbrot_step is a c-mex file that does one step of:
%        z = z.*z + z0;
%        kz(abs(z) < 2) = d;
   end
   set(controls(3),'string',['depth = ' num2str(d)])
   set(controls(6),'value',0,'string','close','callback','close(gcf), return')
   depth = finaldepth;
   drawnow
end

% ------------------------

function a = mwaitbar(a,x)
   if nargin == 0
      a(1) = axes('pos',[.4 .5 .2 .03]);
      a(2) = fill([0 0 0 0 0],[0 0 1 1 0],[0 2/3 0]);
      set(a(1),'xtick',[],'ytick',[],'xlim',[0 1])
   else
      axes(a(1))
      set(a(2),'xdata',[0 x x 0 0]);
      drawnow
   end
end

% ------------------------

function cmap = parulas(m)
   c = parula(16);
   e = ones(m/16,1);
   cmap = kron(e,c);
end

% ------------------------

function cmap = jets(m)
   c = jet(16);
   e = ones(m/16,1);
   cmap = kron(e,c);
end

% ------------------------

function cmap = hots(m)
   c = flipud(hot(16));
   e = ones(m/16,1);
   cmap = kron(e,c);
end

% ------------------------

function cmap = sepia(m)
   c = rot90(bone(16),2);
   e = ones(m/16,1);
   cmap = kron(e,c);
end

% ------------------------

function cmap = cmyk(m)
   % c = blue, green, red, cyan, magenta, yellow, gray, black.
   c = [0 0 3; 0 2 0; 3 0 0; 0 3 3; ...
        3 0 3; 3 3 0; 1 1 1; 0 0 0]/4;
   e = ones(m/8,1);
   cmap = kron(e,c);
end

% ------------------------

function cmap = flags(m)
   c = flag(4);
   e = ones(m/4,1);
   cmap = kron(e,c);
end

% ------------------------

function cmap = fringe(m)
   cmap = zeros(min(m,256),3);
   cmap(end,1) = .5;
   cmap(1:12,:) = 1;
end

% ------------------------

function cf = cmapname(k)
   if nargin == 0
       n = length(cmaps);
       cf = cell(n,1);
       for k = 1:n
           cf{k} = cmapname(k);
       end
   else
       cf = char(cmaps{k});
       cf = cf(strfind(cf,'/')+1:end);
   end
end


% ------------------------

function colors
   % New color map
   cmapidx = get(controls(2),'value');
   plotit
   state = {center,width,grid,depth,cmapidx,z,kz};
   set(gcf,'userdata',state)
end

% ------------------------

function startup
   % Initialize
   clf
   shg
   set(gcf,'menubar','none','numbertitle','off','name','mandelbrot') 
   controls = make_controls;
   set(controls(4),'string',['grid = ' num2str(grid)])
   set(controls(1),'value',regidx)
   kz = zeros(grid+1,grid+1,'uint16');
   z = complex(zeros(grid+1,grid+1));
   state = {center,width,grid,depth,cmapidx,z,kz};
   set(gcf,'userdata',state)
end

% ------------------------

function parseargs(varargin)
   defaults = [-0.5+0i, 3, 512, 256, 1];
   parms = defaults;
   parms(1:nargin) = [varargin{:}];
   center = parms(1);
   width = parms(2);
   grid = parms(3);
   depth = parms(4);
   cmapidx = parms(5);
end

% ------------------------

function get_state
   state = get(gcf,'userdata');
   center = state{1};
   width = state{2};
   grid = state{3};
   depth = state{4};
   cmapidx = state{5};
   z = state{6};
   kz = state{7};
end

% ------------------------

function region(r)
   center = menu{r,2};
   width = menu{r,3};
   grid = menu{r,4};
   depth = menu{r,5};
   cm = menu{r,6};
   for k = 1:length(cmaps)
      if isequal(cm,cmapname(k))
         cmapidx = k;
      end
   end
end

% ------------------------

function plotit
   s = width*(-1/2:1/grid:1/2);
   if width > .002
      pix = image(s+real(center),s+imag(center),kz);
      set(get(gca,'title'),'userdata',0)
   else
      pix = image(s,s,kz);
      if imag(center) < 0
          s = ' - ';
      else
          s = ' + ';
      end
      title(sprintf('%14.12g %s %14.12gi',real(center),s,abs(imag(center))));
      set(get(gca,'title'),'userdata',center)
   end
   axis square
   set(gca,'ydir','normal')
   m = max(1,max(max(kz)));
   colormap(cmaps{cmapidx}(m))
   set(pix,'userdata',z)
   drawnow
end

% ------------------------

function controls = make_controls
   controls = zeros(6,1);
   bs = {'region','color','depth','grid_','info','close'};
   for k = 1:6
      controls(k) = uicontrol('string',bs{k},'units','normal', ...
         'position',[.84,.75-.08*k,.15,.06],'style','toggle', ...
         'callback',['mandelbrot(''' bs{k} ''')']);
   end
   set(controls(3),'string',['depth = ' num2str(depth)])
   set(controls(4),'string',['grid = ' num2str(grid)])
   set(controls(2),'style','popup','string',cmapname)
   set(controls(6),'callback','close(gcf), return')
   regionlist = {menu{:,1}};
   set(controls(1),'style','popup','string',regionlist, ...
         'callback','mandelbrot(get(gcbo,''value''))');
   set(zoom,'enable','on','actionpostcallback',@zoomer)
end

% ------------------------

function deepen
   pix = get(gca,'child');
   kz = get(pix,'cdata');
   z = get(pix,'userdata');
   % Keep depth = 2^k or 3*2^k.
   if rem(depth,3) == 0
      finaldepth = 4*depth/3;
   else
      finaldepth = 3*depth/2;
   end
   set(controls(3),'value',0,'callback',[])
   iterate(depth,finaldepth);
   set(controls(4),'callback','mandelbrot(''depth'')')
end

% ------------------------

function refine
   pix = get(gca,'child');
   xlim = get(gca,'xlim');
   ylim = get(gca,'ylim');
   center = (xlim(1)+xlim(2))/2 + (ylim(1)+ylim(2))/2*i + ...
      get(get(gca,'title'),'userdata');
   x = get(pix,'xdata');
   width = x(end)-x(1);
   % Keep grid = 2^k or 3*2^k.
   if rem(grid,3) == 0
      grid = 4*grid/3;
   else
      grid = 3*grid/2;
   end
   set(controls(4),'string',['grid = ' num2str(grid)],'value',0);
   kz = zeros(grid+1,grid+1,'uint16');
   z = complex(zeros(grid+1,grid+1));
   iterate(0,depth);
   plotit;
end

% ------------------------

function zoomer(varargin)
   set(zoom,'enable','on','actionpostcallback',@zoomoff)
   get_state
   controls = flipud(findobj(gcf,'type','uicontrol'));
   pix = get(gca,'child');
   xlim = get(gca,'xlim');
   ylim = get(gca,'ylim');
   x = get(pix,'xdata');
   y = get(pix,'ydata');
   j = [find(abs(x-xlim(1)) == min(abs(x-xlim(1)))), ...
        find(abs(x-xlim(2)) == min(abs(x-xlim(2))))];
   k = [find(abs(y-ylim(1)) == min(abs(y-ylim(1)))), ...
        find(abs(y-ylim(2)) == min(abs(y-ylim(2))))];
   zoomgrid = 2.^(floor(log2(round(sqrt((k(2)-k(1))*(j(2)-j(1)))))));
   j = round((sum(j)-zoomgrid)/2):round((sum(j)+zoomgrid)/2);
   k = round((sum(k)-zoomgrid)/2):round((sum(k)+zoomgrid)/2);
   width = (x(j(end))-x(j(1)) + y(k(end))-y(k(1)))/2;
   axisshift = get(get(gca,'title'),'userdata');
   center = (x(j(end))+x(j(1)))/2 + i*(y(k(end))+y(k(1)))/2 + axisshift;
   kz = zeros(grid+1,grid+1,'uint16');
   z = complex(zeros(grid+1,grid+1));
   iterate(0,depth)
   plotit
   state = {center,width,grid,depth,cmapidx,z,kz};
   set(gcf,'userdata',state)
   set(controls(4),'string',['grid = ' num2str(grid)])
   set(zoom,'enable','on','actionpostcallback',@zoomer)
end

% ------------------------

function zoomoff
fprintf('zoomoff:\n')
return
end

% ------------------------

function info
    dos('explorer https://www.mathworks.com/content/dam/mathworks/mathworks-dot-com/moler/exm/chapters/mandelbrot.pdf');
end

end % function mandelbrot
