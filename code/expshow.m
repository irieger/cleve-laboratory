function expshow(~)
% EXPGUI  Discover e graphically.

%   Copyright 2014-2017 Cleve Moler
%   Copyright 2014-2017 The MathWorks, Inc.

   t = 0:1/64:2;
   h = .0001;

   if nargin == 0
      initialize_graphics
      a = 2;
   else
      a = read_mouse;
   end

   % Compute y = a^t and its approximate derivative

   y = real(a.^t);
   yp = real(a.^(t+h) - a.^t)/h;

   % Update the plot.
   
   p = get(gca,'children');
   set(p(3),'ydata',y)
   set(p(2),'ydata',yp)
   set(p(1),'string',sprintf('a = %5.3f',a))

   % ----------------------------------

   function initialize_graphics
      clf
      shg
      set(gcf,'menubar','none','numbertitle','off','name','expshow')
      plot(t,ones(2,length(t)));
      axis([0 2 0 9])
      set(gcf, ...
         'windowbuttondownfcn', ...
         'set(gcf,''windowbuttonmotionfcn'',''expshow(0)'')', ...
         'windowbuttonupfcn', ...
         'set(gcf,''windowbuttonmotionfcn'',[])');
      fs = get(0,'defaulttextfontsize')+2;
      text(0.3,6.0,'a = 0','fontsize',fs,'fontweight','bold')
      title('y = a^t','fontsize',fs,'fontweight','bold')
      legend('y','dy/dt','location','northwest')
      xlabel('t')
      ylabel('y')
      
      uicontrol('style','pushbutton', ...
         'units','normalized', ...
         'position',[.92 .92 .07 .06], ...
         'string','info', ... 
         'fontweight','bold', ...
         'callback', ...
           'web(''info/expshow_info.html'',''-notoolbar'')');   
         
      uicontrol('style','pushbutton', ...
         'units','normalized', ...
         'position',[.92 .84 .07 .06], ...
         'string','exit', ...
         'fontweight','bold', ...
         'callback','close(gcf)')
   end

   % ----------------------------------

   function a = read_mouse
      point = get(gca,'currentpoint');
      ta = point(1,1);
      ya = point(1,2);
      a = ya^(1/ta);
      e = exp(1);
      if abs(a - e) < .005
         a = e;
      end
   end

end
