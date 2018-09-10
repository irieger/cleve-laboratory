function tumbler
   % Angular momentum of tumbling box.
   % Strang, Differential Equations and Linear Algebra, pp. 176-178.
   % Alar Toomre, MIT

   function ydot = momemtum(t,y,y0)
      ydot = [ y(2)*y(3)
            -2*y(1)*y(3)
               y(1)*y(2)];
   end

   function [val,isterm,dir] = gstop(t,y,y0)
      % Event function for periodicity
      % See C. Moler, Numerical Computing with MATLAB, Section 7.2.
      d = y - y0;
      v = momemtum(t,y);
      val = d'*v;
      isterm = 1;
      dir = 1;
   end

   opt = odeset('RelTol',1.e-6,'events',@gstop);
   cla
   [X,Y,Z] = sphere(36);
   h = surface(X,Y,Z);
   view(3)
   shading interp
   axis equal
   axis vis3d
   % axis off
   set(gca,'xdir','rev','ydir','rev')
   dkblue = [0 0 .5];
   line(0,0,1.01,'marker','.','color',dkblue,'markersize',12)
   line(0,1.01,0,'marker','.','color',dkblue,'markersize',12)
   line(1.01,0,0,'marker','.','color',dkblue,'markersize',12)
   
   for k = 1:10
      y0 = randn(3,1);
      y0 = y0/norm(y0);
      [t,y] = ode45(@momemtum,[0,100],y0,opt,y0);
      line(y(:,1),y(:,2),y(:,3),'color','k')
   end
end



