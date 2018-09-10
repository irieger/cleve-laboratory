function calculator(ri,fj,pk)
% calculator.  Multi-precision calculator.
% calculator(ri,fi,pi) initializes the register to ri, initializes the
% format buttons to the fj-th, and initializes the precision buttons
% to the pk-th.  Default is calculator([],1,4).
% See also: roman, f8, f16

    set(gcf, ...
        'color','w', ...
        'numbertitle','off', ...
        'menubar','none', ...
        'name','calculator', ...
        'inverthardcopy','off')

    % initialize
    if nargin < 1
        ri = [];
    end
    if nargin < 2
        fj = 1;
    end
    if nargin < 3
        pk = 4;
    end
    r = ri;       % Contents of reg (the register).
    s = [];       % Previous r.
    m = [];       % Memory stack.
    init = true;  % Clear reg.
    op = ' ';     % Operator
    rng('shuffle')
    
    % fontsize
    fs = get(0,'defaultuicontrolfontsize') + 6;
    
    % coordinates of buttons
    x = .10 + .14*(0:5);
    y = .12 + .16*(0:4);
    
    % frame
    uicontrol('style','frame', ...
        'units','normalized', ...
        'position',[.05 .05 .90 .90], ...
        'background',[.9 .9 .9]);

    % precision
    str = {' 8','16','32','64'};
    pre_radio = zeros(1,4);
    for k = 1:4
       pre_radio(k) = radio(str(k),@precision_cb,x(6)-.01,y(5)+.16-.05*k);
    end
    precision = ['fp' fliplr(deblank(fliplr(str{pk})))];
    set(pre_radio(pk),'value',1);
    
    % form
    str = {'dec','hex','binary','roman'};
    form_radio = zeros(1,3);
    for k = 1:4
       form_radio(k) = radio(str(k),@form_cb,x(1)-.01,y(5)+.16-.05*k);
    end
    form = str{fj};
    set(form_radio(fj),'value',1)  
        
    % register
    if isempty(ri)
        ri = 'click to clear';
    end
    reg = bigbutton(ri,@clearreg,x(2)+.02,y(5));
    setreg(ri)
    
    % keys
    keys = zeros(10,1);
    for k = 0:9
       if k == 0
           xk = x(2); yk = y(1);
       else
           xk = x(mod(k-1,3)+1); yk = y(ceil(k/3)+1);    
       end
       keys(k+1) = button(int2str(k),@keys_cb,xk,yk);
    end
    
    % operators
    d = '+-*/';
    for k = 1:4
        button(d(k),@oper_cb,x(4),y(5-k));
    end

    % evaluate
    button('=',@equ_cb,x(3),y(1));
    
    % decimal point
    button('.',@keys_cb,x(1),y(1));
    
    % xpowy
    button('x^y',@xpowy_cb,x(5),y(4));
    
    % reciprocal
    button('1/x',@reciprocal_cb,x(5),y(3));
    
    % log2
    button('log2',@log2_cb,x(5),y(2));
 
    % info
    button('info',@info_cb,x(6),y(1));

    % rand
    button('rand',@rand_cb,x(6),y(4));
    
    % eps
    button('eps',@eps_cb,x(5),y(1));
    
    % push memory
    button('push',@push_cb,x(6),y(3));
 
    % pop memory
    button('pop',@pop_cb,x(6),y(2));
 
    %% uicontrols ----------------------------------------------------
    
    %% button
    function btn = button(str,cb,xx,yy)
        btn = uicontrol('style','pushbutton',  ...
            'units','normalized', ...
            'position',[xx yy .10 .10], ...
            'background','white', ...
            'string',str, ...
            'fontsize',fs, ...
            'fontweight','bold', ...
            'callback',cb);
    end

    %% bigbutton
    function btn = bigbutton(str,cb,xx,yy)
        btn = uicontrol('style','pushbutton', ...
            'units','normalized', ...
            'position',[xx yy .48 .12], ...
            'background','white', ...
            'fontweight','bold', ...
            'fontsize',fs, ...
            'horiz','center', ...
            'string',str, ...
            'callback',cb);
    end

    %% radio
    function rad = radio(str,cb,xx,yy)
        rad = uicontrol('style','radiobutton',  ...
            'units','normalized', ...
            'position',[xx yy .16 .05], ...
            'string',str, ...
            'background',[.9 .9 .9], ...
            'fontsize',fs, ...
            'fontweight','bold', ...
            'value',0, ...
            'callback',cb);
    end
 
    %% utilities ----------------------------------------------------
    
    %% cast
    function y = cast(x)
        switch precision
            case 'fp8'
                y = fp8(x);
            case 'fp16'
                y = fp16(x);
            case 'fp32'
                y = single(x);
            case 'fp64'
                y = double(x);
        end
    end
        
    %% setreg
    function setreg(t)
        if ischar(t)
            set(reg,'string',t)
        else
            t = cast(t);
            set(reg,'string',calcprintf(t))
        end
    end

    %% clearreg
    function clearreg(~,~)
        set(reg,'value',0)
        r = [];
        setreg(r)
        init = true;
    end
 
    %% call backs ----------------------------------------------------

    %% keys_cb
    function keys_cb(~,~)
        if init
            clearreg
            init = false;
        end
        str = [get(reg,'string') get(gco,'string')];
        if isequal(form,'roman')
            r = double(roman(str));
        else
            r = str2double(str);
        end
        setreg(str)
    end
    
    %% oper_cb
    function oper_cb(~,~)
        op = get(gco,'string');
        if op == '-' && init
            % unary minus
            setreg(op)
            r = [];
            init = false;
            op = ' ';
        else
            s = r;
            clearreg
            init = false;
        end
    end

    %% equ_cb
    function equ_cb(~,~)
        % Evaluate
        t = r;
        switch op
            case '+'
                r = s + r;
            case '-'
                r = s - r;
            case '*'
                r = s * r;
            case '/'
                r = s / r; 
            case '^'
                r = s ^ r;
        end
        s = t;
        setreg(r)
    end

    %% xpowy_cb
    function xpowy_cb(~,~)
        op = '^';
        s = r;
        clearreg    
    end

    %% reciprocal_cb
    function reciprocal_cb(~,~)
        r = 1/r;
        setreg(r);
    end

    %% log2_cb
    function log2_cb(~,~)
        r = log2(r);
        setreg(r);
    end

    %% info_cb
    function info_cb(~,~)
        helpwin('roman')
    end

    %% rand_cb
    function rand_cb(~,~)
        if r == round(r)
            r = randi(1000);
        else
            r = rand;
        end
        setreg(r)
    end 

    %% eps_cb
    function eps_cb(~,~)
        if isempty(r)
            r = eps(cast(1));
        else
            r = eps(cast(r));
        end
        setreg(r)
    end

    %% push_cb
    function push_cb(~,~)
        m = [r; m];
    end

    %% pop_cb
    function pop_cb(~,~)
        if ~isempty(m)
            r = m(1);
            m(1) = [];
        else
            r = [];
        end
        setreg(r)
    end

    %% precision
    function precision_cb(~,~)
        dlb = @(c) fliplr(deblank(fliplr(c)));
        for k = 1:4
            if pre_radio(k) ~= gco
                set(pre_radio(k),'value',0)
            elseif get(pre_radio(k),'value') == 1
                precision = ['fp' dlb(char(get(pre_radio(k),'string')))];
            end
        end
        setreg(r)
    end

    %% form
    function form_cb(arg,~)
        set(form_radio,'value',0)
        set(arg,'value',1)
        form = char(get(arg,'string'));
        setkeys(arg)
        setreg(r)
    end

    function setkeys(arg)
        % Set key labels
        switch char(get(arg,'string'))
            case {'dec','hex'}
                for k = 0:9
                    set(keys(k+1),'string',int2str(k), ...
                        'visible','on')
                end
            case 'roman'
                rom = 'IVXLCDM';
                for k = [3 5:10]
                    set(keys(k),'string',rom(k-3+(k==3)), ...
                        'visible','on')
                end
                for k = [1 2 4]
                    set(keys(k),'visible','off')
                end
        end
    end    
 
    %% printer ----------------------------------------------------
   
    %% calcprintf
    function v = calcprintf(t)
        if isempty(double(t))
            v = ' ';
        else
            switch class(t)
                case 'fp8'
                    p = 4;
                    q = 3;
                    formf = '%6.3f';
                    forme = formf;
                case 'fp16'
                    p = 10;
                    q = 5;
                    formf = '%8.5f';
                    forme = formf;
                case 'single'
                    p = 23;
                    q = 8;
                    formf = '%12.7f';
                    forme = '%15.7e';
                case 'double'
                    p = 52;
                    q = 11;
                    formf = '%20.16f';
                    forme = '%24.16e';
            end
            emax = 2^(q-1);
            fmax = 2^p;
            dt = double(t);
            switch form
                case 'dec'
                    if dt == round(dt) && abs(dt) < fmax
                        v = sprintf('%d',dt);
                    elseif abs(dt) > .001 && abs(dt) < 1000
                        v = sprintf(formf,dt);
                    else
                        v = sprintf(forme,dt);
                    end
                case {'hex','binary'}
                    sig = floor((1-sign(dt))/2);  % 0 or 1
                    [f,e] = log2(abs(dt));   % t = pow2(f,e)
                    if isinf(f)
                        f = 0;
                        ebias = 2^q-1;
                    elseif f == 0
                        ebias = 0;
                    elseif e <= -(emax-2)
                        % Denorms
                        ebias = 0;   % t = pow2(f,e), no hidden bit
                        f = f*2^(e+emax-2);
                    else                   
                        f = 2*f-1;   % t = pow2(1+f,e), hidden bit
                        e = e-1;
                        ebias = e+emax-1;
                    end
                    switch form
                        case 'hex'
                            v = [dec2hex(sig) ' ' ...
                                 dec2hex(ebias,ceil(q/4)) ' ' ...
                                 dec2hex(fix(fmax*f),ceil(p/4))];
                        case 'binary'
                            vs = dec2bin(sig);
                            ve = dec2bin(ebias,q);
                            vf = dec2bin(fix(fmax*f),p);
                            klass = class(t);
                            if isequal(klass,'single') || ...
                               isequal(klass,'double')
                                  vf = [vf(1:6) '..', vf(end-5:end)];
                            end
                            v = [vs ' ' ve ' ' vf];
                    end
                case 'roman'
                    v = char(char(roman(t)));               
            end
            v = fliplr(deblank(fliplr(v))); % remove leading blanks
        end
    end

end % calculator