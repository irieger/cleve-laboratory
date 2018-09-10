function play_match_the_color_game(~,~)
% Play Match the Color Game
% First screen: choose a color out of 143 colors with HTML names.
% Second screen: match RGB or YIQ color values.
% Exact match earns gold star.
% See Cleve's Corner blog:
%   https://blogs.mathworks.com/cleve/2018/06/11/play-match-the-color-game

    % Copyright 2018 The MathWorks, Inc.
    % Copyright 2018 Cleve Moler

    % Variables with scope spanning multiple functions
    
    names = "";
    groups = "";
    RGB = [];
    gsize = [];
    x = [];
    y = []; 
    titl = [];
    ptch = [];
    sliders = [];
    vals = [];
    labels = [];
    score = [];
    score_vis = [];
    rgbyiq = [];
    goal = [];
    star = [];
    
    % rgb to yiq matrix.
    % colors are row vectors, so transpose
    % usual A and multiply on right,
    % yiq = (rgb/255)*A.
    
    A = [0.2989  0.5870  0.1140         
         0.5959 -0.2744 -0.3216
         0.2115 -0.5229  0.3114]';
    
    read_color_names

    % Set up screen 1

    n = 17;  % Max number of tiles per line
    d = 1/2;  % Spacing
    m = sum(ceil(gsize/n));  % Number of lines

    clf
    shg
    set(gcf,'units','normalized', ...
        'windowbuttonupfcn',@wbuf)
    set(gca,'units','normalized', ...
        'ydir','rev')
    axis([0 n+4*d 0 m+11*d])
    titl = title('Choose a color');
    box on
    no_ticks

    u = [0 1 1 0 0];  % Square patch
    v = [0 0 1 1 0];
    x = zeros(length(names),1);  % Coordinates of tiles
    y = zeros(length(names),1);

    for k = 1:length(gsize)
        s = sum(gsize(1:k-1))+(1:gsize(k));
        for j = s
            x(j) = mod(j-min(s),n) + 2*d;
            y(j) = sum(ceil(gsize(1:k-1)/n)) + floor((j-min(s))/n) + k*d;
            patch(x(j)+u,y(j)+v,RGB(j,:)/255)
        end
    end

% ----------------------------------------------------------------------

    function read_color_names
        % source: https://htmlcolorcodes.com/color-names
        p = 1; % color group
        q = 1; % color
        s = 0; % group size
        fid = fopen('play_match_the_color_game.m');
        while 1
            line = fgetl(fid);
            if length(line) >= 2 && line(1:2) == "%{"
                break
            end
        end
        while 1
            line = fgetl(fid);
            if length(line) >= 2 && line(1:2) == "%}"
                break
            elseif isempty(line)
                gsize(p,1) = s;
                s = 0;
                p = p + 1;
            elseif line(1) ~= " "
                % groups are delimiters, but not used otherwise.
                groups(p,1) = string(line);
            else
                names(q,1) = string(deblank_front(line(7:28)));
                RGB(q,:) = sscanf(line(29:end),'%f')';
                q = q + 1;
                s = s + 1;
            end       
        end
        gsize(p,1) = s;
        groups;  % Suppress editor warning
        fclose(fid);
    end  % read_colornames
     
    function wbuf(varargin)
        % wbuf, WindowButtonUpFunction for screen 1
        ax = get(gca,'position');
        pq = get(gcf,'currentpoint');
        p = (pq(1)-ax(1))/ax(3)*(n+4*d);
        q = (ax(2)+ax(4)-pq(2))/ax(4)*(m+11*d);
        px = fix(p);
        qy = find(q<=y+1,1,'first');
        j = px+qy-1;
        if px >= 14 && px <= 17 && qy >= 1 && qy <= 16 && ~isempty(goal)
            screen2
        elseif px <= 0 || j > length(x) || px > x(j)
            delete(titl)
            if ~isempty(ptch)
                delete(ptch)
            end
            ptch = [];
        else
            titl = title(sprintf('%s',names(j)));
            ptch = patch(n-3+4*u,1+4*v,RGB(j,:)/255);
            txt = text(n-2,3,'click me', ...
                'fontweight','bold', ...
                'color','black');
            goal = RGB(j,:);
            if (goal/255)*A(:,1) < 0.5  % luminance
                set(txt,'color','white')
            end
        end
    end

    function screen2
        % Set up screen 2
        cla
        set(gcf,'windowbuttonupfcn',[])  % Clear wbuf
        patch(3+5*u,5.5+5*v,goal/255);
        ptch = patch(10+5*u,5.5+5*v,[.5 .5 .5]);      
        for k = 1:3
            sliders = [sliders
                uicontrol('style','slider', ...
                'background','white', ...
                'units','normalized', ...
                'position',[.25 .45-.1*k .5 .04], ...
                'sliderstep',[1/255 1/255], ...
                'value',128, ...
                'max',255, ...
                'min',0, ...
                'callback',@slider_cb)];
            vals = [vals
                uicontrol('style','text', ...
                'background','white', ...
                'units','normalized', ...
                'position',[.80 .45-.1*k .10 .05], ...
                'string','xxx.yyy', ...
                'fontsize',12, ...
                'fontweight','bold')];
            caps = ["R" "G" "B"];
            labels = [labels
                uicontrol('style','text', ...
                'background','white', ...
                'units','normalized', ...
                'position',[.18 .45-.1*k .04 .05], ...
                'string',caps(k), ...
                'fontsize',12, ...
                'fontweight','bold')];
        end
        score = uicontrol('style','text', ...
            'units','normalized', ...
            'position',[.45 .75 .10 .05], ...
            'background','white', ...
            'string','xxx', ...
            'fontsize',12, ...
            'fontweight','bold', ...
            'vis','off');
        dkgold = .9*[1 215/255 0];
        star = line(.54*n,.19*n,'marker','pentagram', ...
             'markersize',36, ...
             'color',dkgold, ...
             'markerfacecolor',dkgold, ...
             'vis','off');
        rgbyiq = uicontrol('style','toggle', ...
            'units','normalized', ...
            'position',[.17 .83 .10 .06], ...
            'background','white', ...
            'string','rgb', ...
            'fontsize',10, ...
            'fontweight','bold', ...
            'callback',@rgbyiq_cb);
        score_vis = uicontrol('style','toggle', ...
            'units','normalized', ...
            'position',[.30 .83 .10 .06], ...
            'background','white', ...
            'string','score', ...
            'fontsize',10, ...
            'fontweight','bold', ...
            'callback',@score_vis_cb);
        uicontrol('style','pushbutton', ...
            'units','normalized', ...
            'position',[.64 .83 .10 .06], ...
            'background','white', ...
            'string','info', ...
            'fontsize',10, ...
            'fontweight','bold', ...
            'callback',@info_cb)
        uicontrol('style','pushbutton', ...
            'units','normalized', ...
            'position',[.77 .83 .10 .06], ...
            'background','white', ...
            'string','choose', ...
            'fontsize',10, ...
            'fontweight','bold', ...
            'callback',@play_match_the_color_game)
        slider_cb(sliders(1));  % Initialize
    end

    function slider_cb(~,~)
        % slider callback
        c = get(sliders,'value');
        c = [c{:}];
        if get(rgbyiq,'value') == 1
            % yiq
            t = max(min(c/A,1),0);
            set(ptch,'facecolor',t)
            s = norm((goal/255)*A - c,1);
        else
            % rgb
            c = round(c);
            set(ptch,'facecolor',c/255)
            s = norm(goal - c,1);
        end
        set_score(s)
        for k = 1:3
            set(sliders(k),'value',c(k))
            set(vals(k),'string',c2str(c(k)))
        end
    end

    function rgbyiq_cb(a,~)
        % switch between rgb and yip
        c = get(sliders,'value');
        c = [c{:}];
        if get(a,'value') == 1
            % switch rgb to yiq
            set(a,'string','yiq')
            mx = [1 .596 .523];
            mn = [0 -.596 -.523];
            caps = ["Y" "I" "Q"];            
            c = (c/255)*A;
            s = norm((goal/255)*A - c,1);
        else
            % switch yiq to rgb
            set(a,'string','rgb')
            mx = [255 255 255];
            mn = [0 0 0];
            caps = ["R" "G" "B"];            
            c = round(255*min(max(c/A,0),1));
            s = norm(goal - c,1);
        end
        set_score(s)
        for k = 1:3
            set(sliders(k), ...
                'value',c(k), ...
                'max',mx(k), ...
                'min',mn(k))
            set(labels(k),'string',caps(k))
            set(vals(k),'string',c2str(c(k)))
        end
    end

    function set_score(s)
        % score value
        set(score,'string',c2str(s))
        if abs(s) <= .01  % Tolerance for star
            set(star,'vis','on')
            set(score,'vis','off')
            set(score_vis,'value',0)
        else
            set(star,'vis','off')
            if get(score_vis,'value') == 1
                set(score,'vis','on')
            else
                set(score,'vis','off')
            end
        end
    end        

    function score_vis_cb(a,~)
        % score visibility
        if get(a,'value') == 1
            set(score,'vis','on')
            set(star,'vis','off')
        else
            set(score,'vis','off')
        end
    end

    function info_cb(~,~)
        web('https://blogs.mathworks.com/cleve/2018/06/11/play-match-the-color-game');
    end

    function str = c2str(c)
        if c == round(c)
            str = int2str(c);
        else
            str = deblank_front(sprintf('%7.3f',c));
        end
    end

    function str = deblank_front(str)
        str = fliplr(deblank(fliplr(str)));
    end

    function no_ticks
        set(gca,'xtick',[],'ytick',[])
    end

% ----------------------------------------------------------------------

%{
reds
     1             indianred   205   92   92
     2            lightcoral   240  128  128
     3                salmon   250  128  114
     4            darksalmon   233  150  122
     5           lightsalmon   255  160  122
     6               crimson   220   20   60
     7                   red   255    0    0
     8             firebrick   178   34   34
     9               darkred   139    0    0

pinks
    10                  pink   255  192  203
    11             lightpink   255  182  193
    12               hotpink   255  105  180
    13              deeppink   255   20  147
    14       mediumvioletred   199   21  133
    15         palevioletred   219  112  147

oranges
    16           lightsalmon   255  160  122
    17                 coral   255  127   80
    18                tomato   255   99   71
    19             orangered   255   69    0
    20            darkorange   255  140    0
    21                orange   255  165    0

yellows
    22                  gold   255  215    0
    23                yellow   255  255    0
    24           lightyellow   255  255  224
    25          lemonchiffon   255  250  205
    26  lightgoldenrodyellow   250  250  210
    27            papayawhip   255  239  213
    28              moccasin   255  228  181
    29             peachpuff   255  218  185
    30         palegoldenrod   238  232  170
    31                 khaki   240  230  140
    32             darkkhaki   189  183  107

purples
    33              lavender   230  230  250
    34               thistle   216  191  216
    35                  plum   221  160  221
    36                violet   238  130  238
    37                orchid   218  112  214
    38               fuchsia   255    0  255
    39               magenta   255    0  255
    40          mediumorchid   186   85  211
    41          mediumpurple   147  112  219
    42         rebeccapurple   102   51  153
    43            blueviolet   138   43  226
    44            darkviolet   148    0  211
    45            darkorchid   153   50  204
    46           darkmagenta   139    0  139
    47                purple   128    0  128
    48                indigo    75    0  130
    49             slateblue   106   90  205
    50         darkslateblue    72   61  139
    51       mediumslateblue   123  104  238

greens
    52           greenyellow   173  255   47
    53            chartreuse   127  255    0
    54             lawngreen   124  252    0
    55                  lime     0  255    0
    56             limegreen    50  205   50
    57             palegreen   152  251  152
    58            lightgreen   144  238  144
    59     mediumspringgreen     0  250  154
    60           springgreen     0  255  127
    61        mediumseagreen    60  179  113
    62              seagreen    46  139   87
    63           forestgreen    34  139   34
    64                 green     0  128    0
    65             darkgreen     0  100    0
    66           yellowgreen   154  205   50
    67             olivedrab   107  142   35
    68                 olive   128  128    0
    69        darkolivegreen    85  107   47
    70      mediumaquamarine   102  205  170
    71          darkseagreen   143  188  139
    72         lightseagreen    32  178  170
    73              darkcyan     0  139  139
    74                  teal     0  128  128

blues
    75                  aqua     0  255  255
    76                  cyan     0  255  255
    77             lightcyan   224  255  255
    78         paleturquoise   175  238  238
    79            aquamarine   127  255  212
    80             turquoise    64  224  208
    81       mediumturquoise    72  209  204
    82         darkturquoise     0  206  209
    83             cadetblue    95  158  160
    84             steelblue    70  130  180
    85        lightsteelblue   176  196  222
    86            powderblue   176  224  230
    87             lightblue   173  216  230
    88               skyblue   135  206  235
    89          lightskyblue   135  206  250
    90           deepskyblue     0  191  255
    91            dodgerblue    30  144  255
    92        cornflowerblue   100  149  237
    93       mediumslateblue   123  104  238
    94             royalblue    65  105  225
    95                  blue     0    0  255
    96            mediumblue     0    0  205
    97              darkblue     0    0  139
    98                  navy     0    0  128
    99          midnightblue    25   25  112

browns
   100              cornsilk   255  248  220
   101        blanchedalmond   255  235  205
   102                bisque   255  228  196
   103           navajowhite   255  222  173
   104                 wheat   245  222  179
   105             burlywood   222  184  135
   106                   tan   210  180  140
   107             rosybrown   188  143  143
   108            sandybrown   244  164   96
   109             goldenrod   218  165   32
   110         darkgoldenrod   184  134   11
   111                  peru   205  133   63
   112             chocolate   210  105   30
   113           saddlebrown   139   69   19
   114                sienna   160   82   45
   115                 brown   165   42   42
   116                maroon   128    0    0

whites
   117                 white   255  255  255
   118                  snow   255  250  250
   119              honeydew   240  255  240
   120             mintcream   245  255  250
   121                 azure   240  255  255
   122             aliceblue   240  248  255
   123            ghostwhite   248  248  255
   124            whitesmoke   245  245  245
   125              seashell   255  245  238
   126                 beige   245  245  220
   127               oldlace   253  245  230
   128           floralwhite   255  250  240
   129                 ivory   255  255  240
   130          antiquewhite   250  235  215
   131                 linen   250  240  230
   132         lavenderblush   255  240  245
   133             mistyrose   255  228  225

grays
   134             gainsboro   220  220  220
   135             lightgray   211  211  211
   136                silver   192  192  192
   137              darkgray   169  169  169
   138                  gray   128  128  128
   139               dimgray   105  105  105
   140        lightslategray   119  136  153
   141             slategray   112  128  144
   142         darkslategray    47   79   79
   143                 black     0    0    0
%}

end % match_color

