%% Investigating the Classic Crossed Ladders Puzzle
% Today's blog post is a complete working MATLAB program investigating the
% <http://blogs.mathworks.com/cleve/2016/02/29/the-classic-crossed-ladders-puzzle
% crossed ladders problem>.
% Publish it again with the |publish| command or the |publish| editor tab.

%% The model
% Explore the interaction of eight variables satisfying five
% nonlinear equations.

%%
% The eight variables are:
%
% * $a$, length of one ladder.
% * $b$, length of the other ladder.
% * $c$, height of the point where they cross.
% * $u$, width of one base triangle.
% * $v$, width of the other base triangle.
% * $w$, width of the alley.
% * $x$, height of the point where one ladder meets the wall.
% * $y$, height of the point where the other ladder meets the other wall.

%% 
% The five equations are:
%
% $$ a^2 = x^2 + w^2 $$
%
% $$ b^2 = y^2 + w^2 $$
%
% $$ \frac{x}{w} = \frac{c}{v} $$
%
% $$ \frac{y}{w} = \frac{c}{u} $$
%
% $$ w = u + v $$

%% ladders
% The initial values provide the smallest solution that is all integers.
% Are there any other integer solutions within the range of this app?

function ladders
    % The Classic Crossed Ladders Puzzle.
    % See Cleve's Corner, Feb. 29, 2016.
    % <http://blogs.mathworks.com/cleve/2016/02/29/the-classic-crossed-ladders-puzzle>
     
    % Starting values are a minimal sum integer solution.
    w0 = 56;
    x0 = 105;
    y0 = 42;
    w = w0;
    x = x0;
    y = y0;
    c = x*y/(x+y);
    u = c*w/y;
    v = c*w/x;
    
    % Starting toggles have both labels off.
    letters = false;
    numbers = false;
    
    initialize_figure;
    
%% letters
% Snapshot with |letters = true| and a wider valley.
%
% <<ladders_app_letters.png>>

%% numbers
% Snapshot of the mirror image of the previous values with |numbers = true|.
% Four of the eight values are still integers. 
%
% <<ladders_app_numbers.png>>
    
%% initialize_figure
  
    function initialize_figure      
        % Size of the square view
        h = 160;
        clf
        shg
        set(gcf,'menubar','none', ...
            'numbertitle','off', ...
            'name','ladders', ...
            'windowbuttondownfcn',@down, ...
            'windowbuttonupfcn',@up)
        axis([-h/8 7/8*h -h/8 7/8*h])
        axis square
        lines
        buttons
        labels
    end %initialize_figure

%% motion
% Called repeatedly as the mouse moves.
    
    function motion(varargin)
        % WindowsButtonMotionFunction
        [p,q] = read_mouse;
        u = c*w/y;
        v = c*w/x;
        % Which control point?
        if q < c/2
            % Drag the alley width horizonally.
            w = p;
        elseif p < u/2
            % Drag the ladder against the left wall vertically.
            x = q;
        elseif p > w-v/2
            % Drag both the width and the other ladder.
            w = p;
            y = q;
        else
            % Drag the crossing point, creating lots of action.
            c = q;
            u = p;
            v = w-u;
            x = c*w/v;
            y = c*w/u;
        end
        c = x*y/(x+y);
        lines
    end % motion
        
%% lines
% Play dot-to-dot.
    
    function lines
        cla
        ms = 3*get(gcf,'defaultlinemarkersize');  % Large dots      
        u = c*w/y; 

        % Five markers at the vertices.
        line([0 0],[0 0],'Marker','.','MarkerSize',ms)
        line([w w],[0 0],'Marker','.','MarkerSize',ms,'Color','k')
        line([0 0],[x x],'Marker','.','MarkerSize',ms,'Color','k')
        line([w w],[y y],'Marker','.','MarkerSize',ms,'Color','k')
        line([u u],[c c],'Marker','.','MarkerSize',ms,'Color','k')
        
        % Connect the markers with six lines.
        line([0 w],[0 0])
        line([0 0],[0 x])
        line([w w],[0 y])
        line([0 w],[x 0])
        line([w 0],[y 0])
        line([u u],[c 0],'LineStyle','-.')
        box on
    end % lines

%% down
    
    function down(varargin)
        % Called at the start of mouse movement.
        % Activate the motion function.
        cla
        set(gcf,'windowbuttonmotionfcn',@motion)
    end % down

%% up
    
    function up(varargin)
        % Called at the end of mouse movement.
        % Deactivate motion function.
        set(gcf,'windowbuttonmotionfcn',[])
        set(gcf,'windowbuttondownfcn',@down)
        labels
    end % up

%% buttons

    function buttons
        % Two toggles and three pushbuttons.
        posit = [.88 .64 .10 .06];
        delta = [  0 .08   0   0];
        
        % letters
        uicontrol('style','toggle', ...
            'units','normalized', ...
            'position',posit, ...
            'string','letters', ...
            'value',letters, ...
            'callback',@letters_cb);
        
        % numbers
        uicontrol('style','toggle', ...
            'units','normalized', ...
            'position',posit-delta, ...
            'string','numbers', ...        
            'value',numbers, ...
            'callback',@numbers_cb); 
        
        % mirror
        uicontrol('style','pushbutton', ...
            'units','normalized', ...
            'position',posit-2*delta, ...
            'string','mirrror', ...        
            'callback',@mirror_cb);
        
        % reset
        uicontrol('style','pushbutton', ...
            'units','normalized', ...
            'position',posit-3*delta, ...
            'string','reset', ...
            'callback',@reset_cb);
        
          % info
      uicontrol('style','pushbutton', ...
            'units','normalized', ...
            'position',posit-4*delta, ...
            'string','info', ...
            'callback',@info_cb);
        
        % close
        uicontrol('style','pushbutton', ...
            'units','normalized', ...
            'position',posit-5*delta, ...
            'string','close', ...
            'callback','close(gcf)');        
    end % buttons

%% labels

    function labels
        % Label lines with either letters or numbers.
        u = c*w/y;
        v = c*w/x;
        lines
        if letters
            f = '%s';
            xs = 'x  ';
            ys = '  y';
            ws = ' w ';
            as = '  a';
            bs = 'b  ';
            us = ' u ';
            vs = ' v ';
            cs = 'c  ';
            top = 'Drag a black dot.';
        elseif numbers
            % This is the only place values of a and b are needed.
            a = sqrt(x^2 + w^2);
            b = sqrt(y^2 + w^2);
            z = [a b c u v w x y];
            if all(abs(z-round(z)) < .001)
                f = '%.0f';
            else
                f = '%.1f';
            end
            if sum(z) < 50 || sum(z) > 1000
                scream
            end
            xs = x;
            ys = y;
            ws = w;
            as = a;
            bs = b;
            us = u;
            vs = v;
            cs = c;
            top = ['sum = ' sprintf(f,sum(z))];
        else
            top = 'Drag a black dot.';
        end
        if letters || numbers
            text(0,x/2,sprintf(f,xs),'horiz','right')
            text(w,y/2,sprintf(f,ys),'horiz','left')
            text(w/2,-3,sprintf(f,ws),'horiz','center')
            text(w/2,x/2,sprintf(f,as),'horiz','left')
            text(w/2,y/2,sprintf(f,bs),'horiz','right')
            text(u/2,3,sprintf(f,us),'horiz','center')
            text(w-v/2,3,sprintf(f,vs),'horiz','center')
            text(u,c/2,sprintf(f,cs),'horiz','right')
        end
        title(top)
     end % labels
     
%% letters_cb

    function letters_cb(varargin)
        % Called when letters button is toggled.
        letters = get(findobj(gcf,'string','letters'),'value');
        % Make sure numbers is false.
        numbers = false;
        set(findobj(gcf,'string','numbers'),'value',numbers)
        labels
    end % letter_cb
    
%% numbers_cb

    function numbers_cb(varargin)
        % Called when numbers button is toggled.
        numbers = get(findobj(gcf,'string','numbers'),'value');
        % Make sure letters is false.
        letters = false;
        set(findobj(gcf,'string','letters'),'value',letters)
        labels
    end % numbers_cb

%% mirror_cb

    function mirror_cb(varargin)
        % Called when mirror button is pushed.
        % Interchange x and y.
        t = x;
        x = y;
        y = t;
        % c = x*y/(x+y) is unchanged
        lines
        labels
    end % mirror_cb

%% reset_cb

    function reset_cb(varargin)
        % Called when reset button is pushed.
        % Restore initial values.
        w = w0;
        x = x0;
        y = y0;
        c = x*y/(x+y);
        u = c*w/y;
        v = c*w/x;
        lines
        labels
    end % reset_cb

%% info_cb

    function info_cb(varargin)
        web('http://blogs.mathworks.com/cleve/2016/02/29/the-classic-crossed-ladders-puzzle', ...
            '-notoolbar'); 
    end

%% read_mouse

    function [p,q] = read_mouse
        % Current horizontal and vertical coordinates of the mouse.
        pq = get(gca,'currentpoint');
        p = pq(1,1);
        q = pq(1,2);
    end % read_mouse

end % ladders_app