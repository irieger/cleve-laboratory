function varargout = svdtx(x,~)
% svdtx, MATLAB version of LINPACK dsvdc routine.
%   size(X) = [n,p]
%   [U,s,V] = svdtx(X)         full svd, size(u) = [n,n], s is a vector.
%   [U,s,V] = svdtx(X,'econ')  economy sized svd, size(u) = [n,p].
%   [U,s] = svdtx(X,...)       skip V
%   s = svdtx(X)               just s
%   U*[diag(s) zeros(n,p-n); zeros(n-p,min(n,p))]*V' regenerates X.
%
%     dsvdc is a subroutine to reduce a double precision nxp matrix x
%     by orthogonal transformations u and v to diagonal form.  the
%     diagonal elements s(i) are the singular values of x.  the
%     columns of u are the corresponding left singular vectors,
%     and the columns of v the right singular vectors.
%
%     linpack. this version dated 08/14/78 .
%              correction made to shift 2/84.
%     g.w. stewart, university of maryland, argonne national lab.
%
%     matlab version, renamed svdtx
%     cleve moler, mathworks, 3/14/2017
%
%     set the maximum number of iterations.
%
      maxit = 30;
%
%     work space
%
      [n,p] = size(x);
      s = zeros(min(n+1,p),1);
      e = zeros(p,1);
      work = zeros(n,1);
%
%     determine what is to be computed.
%
      econ = nargin > 1;
      wantu = nargout >= 2;
      wantv = nargout == 3;
      ncu = n;
      if econ
          ncu = min(n,p);
      end
      if wantu
         u = zeros(n,ncu);
      end
      if wantv
         v = zeros(p,p);
      end
%
%     reduce x to bidiagonal form, storing the diagonal elements
%     in s and the super-diagonal elements in e.
%
      nct = min(n-1,p);
      nrt = max(0,min(p-2,n));
      lu = max(nct,nrt);         
      for l = 1:lu
         if l <= nct
%
%           compute the transformation for the l-th column and
%           place the l-th diagonal in s(l).
%
            s(l) = norm(x(l:n,l));
            if s(l) ~= 0
               if x(l,l) ~= 0
                  s(l) = sign(x(l,l))*s(l);
               end
               x(l:n,l) = x(l:n,l)/s(l);
               x(l,l) = 1 + x(l,l);
            end
            s(l) = -s(l);
         end
         if p >= l+1
             for j = l+1:p
                if l <= nct
                    if s(l) ~= 0
%
%                      apply the transformation.
%
                       t = -(x(l:n,l)'*x(l:n,j))/x(l,l);
                       x(l:n,j) = x(l:n,j) + t*x(l:n,l);
                    end
                end
%
%               place the l-th row of x into  e for the
%               subsequent calculation of the row transformation.
%
                e(j) = x(l,j);
             end  
         end
         if wantu && l <= nct
%
%           place the transformation in u for subsequent back
%           multiplication.
%
            u(l:n,l) = x(l:n,l);
         end
         if l <= nrt 
%
%           compute the l-th row transformation and place the
%           l-th super-diagonal in e(l).
%
            e(l) = norm(e(l+1:p));
            if e(l) ~= 0
               if e(l+1) ~= 0
                   e(l) = sign(e(l+1))*e(l);
               end
               e(l+1:p) = e(l+1:p)/e(l);
               e(l+1) = 1 + e(l+1);
            end
            e(l) = -e(l);
            if l+1 <= n && e(l) ~= 0
%
%              apply the transformation.
%
               work(l+1:n) = 0;
               for j = l+1:p
                   work(l+1:n) = work(l+1:n) + e(j)*x(l+1:n,j);
               end
               for j = l+1:p
                   x(l+1:n,j) = x(l+1:n,j) - e(j)/e(l+1)*work(l+1:n);
               end
            end
            if wantv
%
%              place the transformation in v for subsequent
%              back multiplication.
%
               v(l+1:p,l) = e(l+1:p);
            end
         end
      end
%
%     set up the final bidiagonal matrix or order m.
%
      m = min(p,n+1);
      if nct < p
          s(nct+1) = x(nct+1,nct+1); 
      end
      if n < m
          s(m) = 0;
      end
      if nrt+1 < m
          e(nrt+1) = x(nrt+1,m);
      end
      e(m) = 0;
%
%     if required, generate u.
%
      if wantu
         for j = nct+1:ncu
            u(:,j) = 0;
            u(j,j) = 1;
         end
         for l = nct:-1:1
            if s(l) ~= 0
               for j = l+1:ncu
                  t = -u(l:n,l)'*u(l:n,j)/u(l,l);
                  u(l:n,j) = u(l:n,j) + t*u(l:n,l);
               end
               u(l:n,l) = -u(l:n,l);
               u(l,l) = 1 + u(l,l);
               if l-1 >= 1
                  u(1:l-1,l) = 0;
               end
            else
               u(:,l) = 0;
               u(l,l) = 1;
            end
         end
      end
%
%     if it is required, generate v.
%
      if wantv
         for l = p:-1:1
            if l <= nrt && e(l) ~= 0
               for j = l+1:p
                  t = -v(l+1:p,l)'*v(l+1:p,j)/v(l+1,l);
                  v(l+1:p,j) = v(l+1:p,j) + t*v(l+1:p,l);
               end
            end
            v(1:p,l) = 0;
            v(l,l) = 1;
         end
      end
%
%     main iteration loop for the singular values.
%
      mm = m;
      iter = 0;
      while 1  
%
%        quit if all the singular values have been found.
%
         if m == 0
%     .......break
             break
         end
%
%        if too many iterations have been performed, set
%        flag and return.
%
         if iter > maxit
            info = m;
            warning(['Did not converge, info = ' int2str(info)])
%     ......break
            break
         end
%
%        this section of the program inspects for
%        negligible elements in the s and e arrays.  on
%        completion the variables kase and l are set as follows.
%
%           kase = 1     if s(m) and e(l-1) are negligible and l.lt.m
%           kase = 2     if s(l) is negligible and l.lt.m
%           kase = 3     if e(l-1) is negligible, l.lt.m, and
%                        s(l), ..., s(m) are not negligible (qr step).
%           kase = 4     if e(m-1) is negligible (convergence).
%
         for l = m-1:-1:0
            if l == 0
%        .......break
                break
            end
            test = abs(s(l)) + abs(s(l+1));
            if abs(e(l)) <= eps(test)
               e(l) = 0;
%        ......break
               break
            end
         end
         if l == m - 1
            kase = 4;
         else
            for ls = m:-1:l
               if ls == l
%           .......break
                   break
               end
               test = 0;
               if ls ~= m
                   test = abs(e(ls));
               end
               if ls ~= l+1
                   test = test + abs(e(ls-1));
               end
               if abs(s(ls)) <= eps(test)
                  s(ls) = 0;
%           ......break
                  break
               end
            end
            if ls == l
               kase = 3;
            elseif ls == m
               kase = 1;
            else
               kase = 2;
               l = ls;
            end
         end
         l = l + 1;
%
%        perform the task indicated by kase.
%
         switch kase
%
%            deflate negligible s(m)
%
             case 1
                f = e(m-1);
                e(m-1) = 0;
                for k = m-1:l
                   t1 = s(k);
                   [cs,sn,t1] = drotg(t1,f);
                   s(k) = t1;
                   if k ~= l
                      f = -sn*e(k-1);
                      e(k-1) = cs*e(k-1);
                   end
                   if wantv
                      t = cs*v(:,k) + sn*v(:,m);
                      v(:,m) = cs*v(:,m) - sn*v(:,k);
                      v(:,k) = t;
                   end
                end
%
%            split at negligible s(l).
%
             case 2
                f = e(l-1);
                e(l-1) = 0;
                for k = l:m
                   t1 = s(k);
                   [cs,sn,t1] = drotg(t1,f);
                   s(k) = t1;
                   f = -sn*e(k);
                   e(k) = cs*e(k);
                   if wantu
                      t = cs*u(:,k) + sn*u(:,l-1);
                      u(:,l-1) = cs*u(:,l-1) - sn*u(:,k);
                      u(:,k) = t;
                   end
                end
    %
    %        perform one qr step.
    %
             case 3
    %
    %           calculate the shift.
    %
                scale = max(abs([s(m),s(m-1),e(m-1),s(l),e(l)]));
                sm = s(m)/scale;
                smm1 = s(m-1)/scale;
                emm1 = e(m-1)/scale;
                sl = s(l)/scale;
                el = e(l)/scale;
                b = ((smm1 + sm)*(smm1 - sm) + emm1^2)/2;
                c = (sm*emm1)^2;
                shift = 0;
                if b ~= 0 && c ~= 0
                   shift = sqrt(b^2+c);
                   if b < 0
                       shift = -shift;
                   end
                   shift = c/(b + shift);
                end
                f = (sl + sm)*(sl - sm) + shift;
                g = sl*el;
    %
    %           chase zeros.
    %
                for k = l:m-1
                   [cs,sn,f] = drotg(f,g);
                   if k ~= l
                       e(k-1) = f;
                   end
                   f = cs*s(k) + sn*e(k);
                   e(k) = cs*e(k) - sn*s(k);
                   g = sn*s(k+1);
                   s(k+1) = cs*s(k+1);
                   if wantv
                      t = cs*v(:,k) + sn*v(:,k+1);
                      v(:,k+1) = cs*v(:,k+1) - sn*v(:,k);
                      v(:,k) = t;
                   end
                   [cs,sn,f] = drotg(f,g);
                   s(k) = f;
                   f = cs*e(k) + sn*s(k+1);
                   s(k+1) = -sn*e(k) + cs*s(k+1);
                   g = sn*e(k+1);
                   e(k+1) = cs*e(k+1);
                   if wantu && k < n
                      t = cs*u(:,k) + sn*u(:,k+1);
                      u(:,k+1) = cs*u(:,k+1) - sn*u(:,k);
                      u(:,k) = t;
                   end

                end
                e(m-1) = f;
                iter = iter + 1;
    %
    %        convergence.
    %
             case 4
    %
    %           make the singular value  positive.
    %
                if s(l) < 0
                   s(l) = -s(l);
                   if wantv 
                       v(:,l) = -v(:,l);
                   end
                end
    %
    %           order the singular value.
    %
                while l < mm
                   if s(l) > s(l+1)
    %           .......break
                       break
                   end
                   t = s(l);
                   s(l) = s(l+1);
                   s(l+1) = t;
                   if wantv && l < p
                      t = v(:,l);
                      v(:,l) = v(:,l+1);
                      v(:,l+1) = t;
                   end
                   if wantu && l < n
                      t = u(:,l);
                      u(:,l) = u(:,l+1);
                      u(:,l+1) = t;
                   end
                   l = l + 1;
                end
                iter = 0;
                m = m - 1;
          end
       end
    s = s(1:min(n,p));
    if ~wantu
        varargout{1} = s;
    else
        varargout{1} = u;
        varargout{2} = s;
    end
    if wantv
        varargout{3} = v;
    end
    
    % ---------------------------------------------------
    
    function [c,s,r] = drotg(x,y)
    % drotg.  givens rotation.
    % [c,s,r] = drotg(x,y).
    % G = [c s; -s c] transforms [x; y] into [r; 0].
       if x == 0 && y == 0
           c = 1;
           s = 0;
           r = 0;
       else
           rho = y;
           if abs(x) > abs(y)
               rho = x;
           end
           r = sign(rho)*hypot(x,y);
           c = x/r;
           s = y/r;
       end
    end % drotg
 end