function morse_tree(~,~)
    % Digraph of binary tree for Morse code.
    % Left on the tree is a dot; right is a dash.
    
    %   Copyright 2017 The MathWorks, Inc.
   
    thumbnail = (nargin == 1);
    [dot,dash,delta,Fs,wpm,extend,textbox] = initialize(nargin);
    greeting(nargin)
    
    % 26 letters of English alphabet, plus an asterisk and four blanks.
    morse = '*ETIANMSURWDKGOHVF L PJBXCYZQ  ';
    
    if thumbnail
        morse = morse(1:7);
    elseif get(extend,'value')
        % Add 27 more characters and two levels.
        morse = extend_morse(morse);
    end

    % Adjacency matrix for a full binary tree.
    n = length(morse);
    j = 2:n;
    k = floor(j/2);
    S = sparse(k,j,1,n,n);
    A = S + S';

    % Retrieve coordinates for the unlabeled full binary tree.
    p = plot(graph(A),'layout','layer');
    x = p.XData;
    y = p.YData;

    % Remove unlabeled nodes.
    m = find(morse == ' ');
    A(:,m) = [];
    A(m,:) = [];
    x(m) = [];
    y(m) = [];
    nodes = num2cell(morse);
    nodes(m) = '';

    % Create the unlabeled directed graph.
    G = graph(A,nodes);

    % Plot the graph, using the coordinates from the full tree.
    Gp = plot(G,'xdata',x,'ydata',y, ...
        'showarrows','off','nodelabel',{});
    set(gca,'xtick',[],'ytick',[])

    % Install node labels and callbacks.
    labels = morse_labels(x,y,nodes,thumbnail);
    
    % Save vital quantities for call backs
    set(gcf,'userdata', ...
        {dot,dash,delta,Fs,wpm,extend,textbox,morse,Gp,labels});     
     
    % ------------------------------------
    
    function morse = extend_morse(morse)
        % Fill in blanks on level five.
        morse(morse == ' ') = ['Ü' 'Ä' 'Ö' '×'];

        % Level six
        morse = [morse blanks(32)];
        morse(31+[1 2 4 7 8 11 14 16]) = ['5' '4' '3' 'Ð' '2' '+' 'À' '1'];
        morse(47+[1 6 9 10 12 13 15 16])=['6' '<' '7' '>' 'Ñ' '8' '9' '0'];

        % Level seven
        morse = [morse blanks(64)];
        morse(63+[13 22 27 34 43 52 57]) = ['?' '.' '@' '-' ';' ',' ':'];
    end % extend_morse

    function labels = morse_labels(x,y,nodes,thumbnail)
        % Install node labels and callbacks.
        labels = text(x,y,nodes);
        for k = 1:length(labels)
            c = labels(k).String;
            if c == '<' || c == '>'
                c = ' ';
            end
            labels(k).String = [' ' c];
            if ~thumbnail
                labels(k).ButtonDownFcn = @morse_node_cb;
            end
        end
    end % morse_labels
    
    function [dot,dash,delta,Fs,wpm,extend,textbox] = initialize(narg)
        if narg == 0
            clf
            set(gcf,'name','morse_tree', ...
               'menu','none', ...
               'numbertitle','off')
            axis;
            box on
            set(gca,'xtick',[],'ytick',[])
            wpms = {' 3 wpm',' 5 wpm',' 8 wpm','10 wpm','15 wpm'};
            uicontrol('string',wpms, ...
                'style','popupmenu', ...
                'units','normalized', ...
                'position',[.24 .04 .12 .05], ...
                'value',2, ...
                'callback',@wpm_cb);
            wpm = 5;
            extend = uicontrol('string','extend', ...
                'style','toggle', ...
                'units','normalized', ...
                'position',[.13 .04 .09 .05], ...
                'callback',@morse_tree);
            textbox = uicontrol('string', ...
                'click on a node or enter text here', ...
                'style','edit', ...
                'units','normalized', ...
                'position',[.38 .04 .31 .05], ...
                'callback',@textbox_cb);
            uicontrol('string','info', ...
                'style','toggle', ...
                'units','normalized', ...
                'position',[.705 .04 .09 .05], ...
                'callback',@info_cb);
            uicontrol('string','close', ...
                'style','pushbutton', ...
                'units','normalized', ...
                'position',[.815 .04 .09 .05], ...
                'callback',@morse_close);
            [dot,dash,delta,Fs] = dot_dash;
        elseif narg == 2
            % Callback
            usrdat = get(gcf,'userdata');
            [dot,dash,delta,Fs,wpm,extend,textbox,morse,Gp,labels] = ...
                deal(usrdat{:});
            if get(extend,'value')
                set(extend,'string','basic')
            else
                set(extend,'string','extend')
            end
        else
            % Thumbnail
            dot = [];
            dash = [];
            delta = [];
            Fs = [];
            extend = [];
            wpm = [];
            textbox = [];
        end
    end % initialize

    function [dot,dash,delta,Fs] = dot_dash
        Fs = 44100;   % sample rate
        if ~exist('wpm','var')   % words per minute
            wpm = 5;
        end
        omega = 1200/Fs;
        L = fix(0.3*Fs/wpm);
        t = 1:L;
        s = sin(2*pi*omega*t);
        dot = [s zeros(1,3*L)];
        t = 1:3*L;
        s = sin(2*pi*omega*t);
        dash = [s zeros(1,3*L)];
        delta = length(dot)/Fs;  % one time unit
    end % dot_dash

    function greeting(narg)      
        if narg == 0
            % CQ, "invitation to respond"
            morse_sound([1 0 1 0])
            pause(1.5*delta)
            morse_sound([1 1 0 1])
        end
    end % greeting
    
    function morse_node_cb(arg,~)
        % Morse node callback
        id = arg.String(2);
        if id ~= ' '
            colors = get(gca,'colororder');
            arg.Color = colors(2,:);
            highlight(Gp,id,'markersize',8, ...
                'nodecolor',colors(2,:));
            c = find(id == morse);
            morse_sound(c)
            arg.Color = [0 0 0];
            highlight(Gp,id,'markersize',4, ...
                'nodecolor',colors(1,:));         
        else
            scream
        end
    end % morse_node_cb

    function info_cb(~,~)
       web('http://blogs.mathworks.com/cleve/2017/03/20');
    end

    function morse_close(~,~)
        % 73, "best regards"
        morse_sound([1 1 0 0 0])
        pause(1.5*delta)
        morse_sound([0 0 0 1 1])
        close(gcf)
    end

    function morse_sound(arg)
        % MORSE_SOUND  Play dots and dashes.
        % morse_sound(c) plays c, a single char, or
        % morse_sound(b) plays b, a vector of 0's and 1's.
        pow2 = 2.^(6:-1:0);
        f2b = @(n) mod(floor(n./pow2),2);  % flint to binary
        if length(arg) == 1
            b = f2b(arg);
            b = b(find(b==1,1,'first')+1:end); % bits after the first 1
        else
            b = arg;
        end
        for k = 1:length(b)
            switch b(k)
               case 0
                  sound(dot,Fs)
                  pause(delta)
               case 1
                  sound(dash,Fs)
                  pause(1.5*delta)
               otherwise
                  % Skip the character
            end
        end
    end  % morse_sound

    function wpm_cb(arg,~)
        v = get(arg,'value');
        wpms = get(arg,'string');
        wv = wpms{v};
        wpm = str2double(wv(1:3));
        [dot,dash,delta,Fs] = dot_dash; 
        set(gcf,'userdata', ...
            {dot,dash,delta,Fs,wpm,extend,textbox,morse,Gp,labels});
        morse_tree([],[])
    end % wpm_cb

    function textbox_cb(arg,~)
        usrdat = get(gcf,'userdata');
        [dot,dash,delta,Fs,wpm,extend,textbox,morse,Gp,labels] = ...
                deal(usrdat{:});
        s = upper(get(arg,'string'));
        for c = s
            if isequal(c,' ')
                pause(4*delta)
            else
                for k = 1:length(labels)
                    if isequal(labels(k).String,[' ' c])
                        morse_node_cb(labels(k))
                        pause(1.5*delta)
                        break
                    end
                end
            end
        end
    end % textbox_cb
end % morse_tree