function house_mult(varargin)
% HOUSE_MULT  Matrix multiplication flexes house.

%   Copyright 2016-2017 Cleve Moler
%   Copyright 2016-2017 The MathWorks, Inc.

    H = house;
    theta = 0;
    sigma1 = 1;
    sigma2 = 1;
    U = [cos(theta) sin(theta); -sin(theta) cos(theta)];
    S = diag([sigma1 sigma2]);
    A = U*S;
    initialize_graphics;
    Ut = framed_matrix(.1);
    St = framed_matrix(.4);
    At = framed_matrix(.7);
    X = A*H;
    p = dot2dot(X);
    
    % End of main program.  Motion functions take charge.

% ------------------------------------------------------

    function H = house
        % HOUSE  Outline of a house.
        H = [ -6  -6  -7   0   7   6   6  -3  -3   0   0
              -7   2   1   8   1   2  -7  -7  -2  -2  -7 ];
    end

    function initialize_graphics
        clf
        set(gcf, ...
            'name','house_mult', ...
            'menu','none', ...
            'numbertitle','off', ...
            'menubar','none', ...
            'numbertitle','off', ...
            'windowbuttondownfcn',@down, ...
            'windowbuttonupfcn',@up)
        uicontrol( ...
           'units','normalized', ...
           'position',[.86 .90 .12 .05], ...
           'style','toggle', ...
           'string','info', ...
           'callback','web(''info/house_mult_info.html'')')       
        uicontrol( ...
           'units','normalized', ...
           'position',[.86 .83 .12 .05], ...
           'style','toggle', ...
           'string','restart', ...
           'callback',@house_mult) 
        uicontrol( ...
           'units','normalized', ...
           'position',[.86 .76 .12 .05], ...
           'style','toggle', ...
           'string','exit', ...
           'callback','close(gcf)');
        shg
        fs = 14;
        axes('position',[0 0 1 1],'vis','off')
        text(.35,.15,'*','fontsize',fs,'fontweight','bold');
        text(.65,.15,'=','fontsize',fs,'fontweight','bold');
    end % initialize graphics        

    function Mt = framed_matrix(xmin)
        fs = 14;
        framed_axis([xmin .02 .2 .25]);
        Mt = [text(.08,.65,'1.00','fontsize',fs,'fontweight','bold')
              text(.08,.35,'  0 ','fontsize',fs,'fontweight','bold')
              text(.58,.65,'  0 ','fontsize',fs,'fontweight','bold')
              text(.58,.35,'1.00','fontsize',fs,'fontweight','bold')];
    end % framed_matrix

    function p = dot2dot(X,p)
        % DOT2DOT  Connect the points from a 2-by-n array.
        X(:,end+1) = X(:,1);
        if nargin == 1
            axes('position',[.18 .34 .62 .62])
            p = plot(X(1,:),X(2,:),'.-', ...
                'markersize',18, ...
                'linewidth',2);
            axis(12*[-1 1 -1 1])
            axis square
            text(-11,-9.5, ...
                'Drag the sides, or floor, or rotate the roof.', ...
                'tag','hint');
        else
            set(p,'xdata',X(1,:),'ydata',X(2,:))
            delete(findobj('tag','hint'))
        end
    end % dot2dot  

    function motion(varargin)
        % WindowsButtonMotionFunction

        z = read_mouse;
        w = U'*z;
        if w(2) > 0
            % roof
            theta = pi/2 - atan2(z(2),z(1));
            U = [cos(theta) sin(theta); -sin(theta) cos(theta)];
        else
            if abs(w(1)) < abs(w(2))
                % floor
                sigma2 = -w(2)/7;
            elseif w(1) < 0
                % left
                sigma1 = -w(1)/6;
            else
                % right
                sigma1 = w(1)/6;
            end
            S = diag([sigma1 sigma2]);
        end
        A = U*S;
        X = A*H;
        dot2dot(X,p);
        update(U,Ut)
        update(S,St)
        update(A,At)
        if norm(A+eye(2),inf) < .05
            scream
            S = eye(2);
        end
    end % motion

    function update(M,Mt)
        for k = 1:4
            Mt(k).String = sprintf('%5.2f',M(k));
        end
    end % update

    function down(varargin)
        % Called at the start of mouse movement.
        % Activate the motion function.
        set(gcf,'windowbuttonmotionfcn',@motion)
    end % down
  
    function up(varargin)
        % Called at the end of mouse movement.
        % Deactivate motion function.
        set(gcf,'windowbuttonmotionfcn',[])
        set(gcf,'windowbuttondownfcn',@down)
    end % up

    function z = read_mouse
        % Current horizontal and vertical coordinates of the mouse.
        cp = get(gca,'currentpoint');
        z = cp(1,1:2)';
    end % read_mouse

end % house_mult
 
