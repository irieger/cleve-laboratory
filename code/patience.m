function path = patience(arg1,~)   
% Patience puzzle.
% patience, with no arguments, initiates the puzzle.
% patience(n), with n from 1:6, toggles ring/hook number n.
% patience('mouse') gets n from a mouse click.
% patience(S), with a 1-by-6 state vector, initializes to S.
% path = patience(S,'solve'), with a 1-by-6 state vector, initializes
%     to S, solves the puzzle, and plots and returns the path.
%
% The six ring/hooks provide a binary state S evaluated in the title.
% The default initial S = zeros(1,6) has value 0.
% The state at the solution S = ones(1,6) has value 63.
%
% See Cleve's Corner blog
% http://blogs.mathworks.com/cleve/2017/02/06/patience-chinese-ring-puzzle.
%
% Thanks to Prof. Daniel Frey, MIT MechE.

%   Copyright 2017 Cleve Moler
%   Copyright 2017 The MathWorks, Inc.

    if nargin == 0 || nargin == 2 && length(arg1) < 6
        % Default initial state of the puzzle.
        S = zeros(1,6);
        h = init_graphics(S);
        set(gcf,'userdata',S)
        set(gca,'userdata',h)
    elseif length(arg1) < 6
        % Get ring/hook number, 1:6, from mouse click or input.
        S = get(gcf,'userdata');
        h = get(gca,'userdata');
        if isequal(arg1,'mouse')
            n = read_mouse;
        else
            n = arg1;
        end
        one_move(n);
    else
        % State vector input.
        S = arg1;
        h = init_graphics(S); 
        set(gcf,'userdata',S)
        set(gca,'userdata',h)
        if nargin == 2
            path = solve;
        end
    end
    
%% one_move
    
    function ok = one_move(n)
        % Is the move allowed ?
        ok = (n==1) || (n==2)&&~S(1) || (n>2)&&(~S(n-1)&&all(S(1:n-2)));
        h = get(gca,'userdata');
        set(h.msg,'string','')
        if ok 
            % move allowed
            if S(n) == 0
                slideshuttleright(n,h);
                rotateringup(n,h, 37);
                slideshuttleleft(n,h);
                slidehookdown(n,h);     
            else
                slidehookup(n,h);
                slideshuttleright(n,h);
                rotateringdown(n,h, 37);
                slideshuttleleft(n,h);
            end
            % Toggle the state of the nth puzzle piece
            S(n) = ~S(n);
         else
            % move not allowed           
            if S(n) == 0
                if S(n-1) == 1
                    rotateringdown(n,h, 8);
                    rotateringup(n,h, 8);
                else
                    lead = find(S == 0,1,'first');
                    if n == lead
                        slideshuttleright(lead+1,h);
                        rotateringup(n,h, 2);
                        rotateringdown(n,h, 2);
                        slideshuttleleft(lead+1,h);
                    else
                        slideshuttleright(lead+1,h);
                        rotateringup(n,h, 23);
                        rotateringdown(n,h, 23);
                        slideshuttleleft(lead+1,h);
                    end
                end
            else
                if S(n-1) == 1
                    rotateringdown(n,h, 8);
                    rotateringup(n,h, 8);
                else
                    lead = find(S == 0,1,'first');
                    slideshuttleright(lead+1,h);
                    rotateringup(n,h, 8);
                    rotateringdown(n,h, 8);
                    slideshuttleleft(lead+1,h);
                end
            end
            set(h.msg,'string','Illegal move','color','red')
        end
                   
        % Title = state value
        state = S*2.^(0:5)';
        set(h.title,'string',sprintf('state = %d',state))
        set(gcf,'userdata',S)
        if all(S == 1)
           set(h.msg,'string','Puzzle Solved','color','black')
           hold off
        end
    end % one_move
    
%% init_graphics
    
    function h = init_graphics(S)
    % h = handles to all the graphics objects.    
        clf
        shg
        set(gcf,'menubar','none', ...
            'numbertitle','off', ...
            'name','patience', ...
            'windowbuttonupfcn',@up)
        % Define the shapes needed in the graphics
        base = [1.1  6.5  6.5 1.1 1.1;
              -1.4 -1.4  -1.3  -1.3  -1.4];
        h.shuttle = [-1  7  7 -1 -1;
              -0.3 -0.3  -0.4   -0.4  -0.3];
        ring = [0.1 -1.49  -1.49    0.1   0.1; 
              -0.15 -0.15  0.0 0.0  -0.15];
        hook = [0.3  0.3  0.4  0.4  0.3*cosd(5:225)+0.1 0.28  ...
                    0.3 0.2*cosd(225:-5:0)+0.1 ;
                0   -1.5 -1.5  0 0.3*sind(5:225) -0.25 ...
                   -0.15 0.2*sind(225:-5:0)];
        lh = length(hook);
        hook_down = hook-[zeros(1,lh); 0.5*ones(1,lh)];
        ring_down = rot(10)*ring+[0.05*ones(1,5); -0.5*ones(1,5)];
        ring_up = rot(47)*ring+[zeros(1,5); 0.1*ones(1,5)];

        % Set up the figure
        plot(base(1,:),base(2,:),'k');
        fill(base(1,:),base(2,:),'k');
        hold on
        xlim([-1.5 8.5]);
        ylim([-3 2]);
        set(gca,'xtick',[],'ytick',[])
        axis equal

        % Plot the initial state of the puzzle
        h.h = zeros(1,6);
        for n = 1:6
            if S(n) == 0
                h.h(n) = plot(hook(1,:)+n,hook(2,:),'b');
            else
                h.h(n) = plot(hook_down(1,:)+n,hook_down(2,:),'b');
            end
        end
        h.s = plot(h.shuttle(1,:),h.shuttle(2,:),'g');
        h.sf = fill(h.shuttle(1,:),h.shuttle(2,:),'g');
        for n = 6:-1:1
            if S(n) == 0
                h.r(n) = plot(ring_up(1,:)+n,ring_up(2,:),'r');
                h.rf(n) = fill(ring_up(1,:)+n,ring_up(2,:),'r');
            else
                h.r(n) = plot(ring_down(1,:)+n,ring_down(2,:),'r');
                h.rf(n) = fill(ring_down(1,:)+n,ring_down(2,:),'r');
            end
        end
        h.sfront = fill(h.shuttle(1,:),h.shuttle(2,:),'g');
        set(h.sfront,'Visible','off');

        % Binary values
        for n = 1:6
            h.val(n) = text(0.2+n,0.8,num2str(2^(n-1)), ...
                'color',[.8 .8 .8], ...
                'FontSize',12, ...
                'horiz','center');
        end
        
        % Messages
        h.msg = text(2,-3,'','fontsize',18);
       
        % State value
        state = S*2.^(0:5)';
        h.title = title(sprintf('state = %d',state));
        
        % Solve button
        h.solve= 0;
        h.tog = uicontrol('string','solve', ...
            'style','toggle', ...
            'units','normalized', ...
            'position',[.16 .14 .10 .06], ...
            'callback',@solve);
        
        % Info button
        h.info = uicontrol('string','info', ...
            'style','pushbutton', ...
            'units','normalized', ...
            'position',[.28 .14 .10 .06], ...
            'callback','helpwin(''patience'')');
    end % init_graphics

%% read_mouse

    function n = read_mouse
        % Current horizontal and vertical coordinates of the mouse.
        xy = get(gca,'currentpoint');
        x = xy(1,1);
        y = xy(1,2);
        % Map the input into the integer number of the ring, 1:6.
        if y > -.4  % shuttle base
            n = floor(x+0.4);
        else
            n = floor(x-y);
        end
    end % read_mouse

%% up
    
    function up(varargin)
        % Called at the end of mouse movement.
        patience('mouse');
    end % up

%% slideshuttle right

    function slideshuttleright(n,h)
    % Slides the shuttle to the right 
    % by an amount depending on the ring number n
        if h.solve == 0
            del = .05;
        else
            del = n/2;
        end
        for deltax = 0:del:n
            set(h.s,'xData',h.shuttle(1,:)+deltax)
            set(h.sf,'xData',h.shuttle(1,:)+deltax)
            drawnow
        end
    end

%% slideshuttleleft

    function slideshuttleleft(n,h)
    % Slides the shuttle to the left 
    % by an amount depending on the ring number n
        if h.solve == 0
            del = .05;
        else
            del = n/2;
        end
        for deltax = n:-del:0
            set(h.s,'xData',h.shuttle(1,:)+deltax)
            set(h.sf,'xData',h.shuttle(1,:)+deltax)
            set(h.sfront,'xData',h.shuttle(1,:)+deltax)
            drawnow
        end
    end

%% rotateriingup

    function rotateringup(n,h,amount)
    % Rotates the nth ring up 
    % 
        ringo = [get(h.r(n),'xData'); get(h.r(n),'yData')];
        if h.solve == 0
            del = .5;
        else
            del = amount/2;
        end
        for ang = 0:-del:-amount
            ringp = rotp(ang,ringo(1:2,1) ,ringo);
            set(h.r(n),'xData',ringp(1,:))
            set(h.r(n),'yData',ringp(2,:))
            set(h.rf(n),'xData',ringp(1,:))
            set(h.rf(n),'yData',ringp(2,:))
            drawnow
        end
    end

%% rotateringdown

    function rotateringdown(n,h,amount)
    % Rotates the nth ring down 
    % 
        ringo = [get(h.r(n),'xData'); get(h.r(n),'yData')];
        if h.solve == 0
            del = .5;
        else
            del = amount/2;
        end
        for ang = 0:del:amount
            ringp = rotp(ang,ringo(1:2,1) ,ringo);
            set(h.r(n),'xData',ringp(1,:))
            set(h.r(n),'yData',ringp(2,:))
            set(h.rf(n),'xData',ringp(1,:))
            set(h.rf(n),'yData',ringp(2,:))
            drawnow
        end
    end

%% slidehookdown

    function slidehookdown(n,h)
    % Slides the nth hook down 
    % 
        ringo = [get(h.r(n),'xData'); get(h.r(n),'yData')];
        hooko = [get(h.h(n),'xData'); get(h.h(n),'yData')];
        set(h.sfront,'Visible','on')
        yl = ylim;
        if h.solve == 0
            del = 0.02;
        else
            del = 0.35;
        end
        for deltay = 0:del:0.70
            set(h.r(n),'yData',ringo(2,:)-deltay);
            set(h.rf(n),'yData',ringo(2,:)-deltay);
            set(h.h(n),'yData',hooko(2,:)-deltay)
            ylim(yl)
            drawnow
        end
        set(h.val(n),'color','k')
        set(h.sfront,'Visible','off')
    end

%% slidehookup

    function slidehookup(n,h)
    % Slides the nth hook up 
    % 
        ringo = [get(h.r(n),'xData'); get(h.r(n),'yData')];
        hooko = [get(h.h(n),'xData'); get(h.h(n),'yData')];
        set(h.sfront,'Visible','on')
        if h.solve == 0
            del = 0.02;
        else
            del = 0.35;
        end
        for deltay = 0:del:0.70
            set(h.r(n),'yData',ringo(2,:)+deltay);
            set(h.rf(n),'yData',ringo(2,:)+deltay);
            set(h.h(n),'yData',hooko(2,:)+deltay)
            drawnow
        end
        set(h.val(n),'color',[.8 .8 .8])
        set(h.sfront,'Visible','off')
    end

%% solve

    function path = solve(varargin)
    % Find a solution with a brute force recursive search
        S = get(gcf,'userdata');
        h = get(gca,'userdata');
        if isequal(get(h.tog,'string'),'solve')
            h.solve = 1;
            set(gca,'userdata',h)
            pow2 = 2.^(0:5);
            path = shortest_path(S*pow2');
            h = init_graphics([1 1 1 1 1 1]);
            set(h.tog,'string','plot', ...
                    'callback',@solve, ...
                    'value',0);
            set(gca,'userdata',h)
            set(h.tog,'userdata',path)
        else
            path = get(h.tog,'userdata');
            clf
            plot(0:length(path)-1,path,'o-')
            xlabel('step')
            ylabel('state')
            title('path')        
            uicontrol('string','restart', ...
                'style','pushbutton', ...
                'units','normalized', ...
                'position',[.76 .14 .10 .06], ...
                'callback',@patience);
        end
    end % solve

%% shortest_path

    function path = shortest_path(state,m,path)
    % shortest_path(state), where state is a decimal state value between
    % 0 and 63, is the shortest path of allowable patience puzzle moves
    % from that state to the objective, which is 63.
    %
    % shortest_path(S,m,path) is the recursive call.

            if nargin == 1
                % Initial call
                m = 0;  % Previous n
                path = [];
            end
            if state == 63  % Terminate recursion
                path = state;
                return
            end
            if state == 31
                m = 0;
            end
            % Search for shortest path
            pow2 = 2.^(0:5);
            lmin = inf;
            for n = [1:m-1 m+1:6]
                Sn = mod(floor(state./pow2),2);  % Convert to binary
                Sn(n) = ~Sn(n);  % Flip one bit
                ok = (n==1) || (n==2)&&~Sn(1) || ...
                     (n>2)&&(~Sn(n-1)&&all(Sn(1:n-2)));  % Allowable move
                if ok
                    one_move(n);
                    staten = Sn*pow2';
                    pn = shortest_path(staten,n,[path staten]);  % Resursion
                    if length(pn) < lmin
                        lmin = length(pn);
                        pbest = pn;
                    end
                end
            end
            path = [state pbest];
    end % shortest_path


%% utilities

    % Define functions useful for movement in animations
    function G = rot(d)
        % Rotate by d degrees
        G = [cosd(d) -sind(d);
             sind(d) cosd(d)];
    end

    function obj_trans = tp(p,obj) 
        obj_trans =  obj+[p(1)*ones(1,length(obj))
                          p(2)*ones(1,length(obj))];
    end

    function obj_rot = rotp(a,p,obj) 
        obj_rot =  tp(p,(rot(a)*(tp(-p,obj))));
    end

end % patience