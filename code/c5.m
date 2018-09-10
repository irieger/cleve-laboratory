%% C^5, Cleve's Corner Collection Card Catalog
% A search tool for all of Cleve's stuff that is on the Internet.
%
% * Blogs.  Posts from Cleve's Corner blog.
% * News.  Columns from Cleve's Corner News and Notes edition.
% * EXM.  Chapters from Experiments with MATLAB.
% * NCM.  Chapters from Numerical Computing with MATLAB.
% * Videos.  Videos on MIT Open Courseware and elsewhere.
% * Code.  MATLAB programs from Cleve's Laboratory, EXM and NCM.
%
% Enter a query, usually just a single key word, in the edit box
% at the top.  This is a term.  The names of the various documents
% that are relevant to the term are then displayed, one at a time,
% in the document box.
%
% The arrow keys allow the document list to be scanned and changed.
% The Latent Semantic Indexing score determines the ordering of the list.  
% The term count is the number of times the term appears in the document.
% The web button accesses a copy of the document on the internet.
%
% The arrow keys can be clicked with either the left or right mouse button
% (or control-click on a one-button mouse).
%
% * left >: next document, any term count.
% * right >: next document with nonzero term count.
% * left <: previous document, any term count.
% * right <: previous document with nonzero term count.
% * left ^: use the root of the current document for the query.
% * right ^: use a random term for the query.
%
% See http://blogs.mathworks.com/cleve/2017/08/28.
%     http://blogs.mathworks.com/cleve/2017/07/31.

% Copyright 2017 The MathWorks, Inc.

%%

function c5(keyterm)

    clf
    shg
    set(gcf, ...
        'color','w', ...
        'numbertitle','off', ...
        'menubar','none', ...
        'name','C^5, Cleve''s Corner Collection Card Catalog', ...
        'inverthardcopy','off')

    % initialize
    
    load c5database T D A L
    
    docs = "";
    scores = [];
    perms = [];
    querie = "";
    arrow = '  ';
    webhandle = [];

    % fontsize
    fs = get(0,'defaultuicontrolfontsize') + 4;
    
    % coordinates of buttons
    x = .10 + .17*(0:4);
    y = .07 + .14*(0:5);
    
    % frame
    uicontrol('style','frame', ...
        'units','normalized', ...
        'position',[.05 .05 .90 .90], ...
        'background',[.9 .9 .9]);

    % key words
    kwds = bigedit('query',@keyword_cb,x(2)-.02,y(6));
    
    % document
    dox = bigedit('document',@(~,~)scream,x(2)-.02,y(5));
   
    % term count, score and data
    tcnt = midtext('term count',x(1),y(4));
    skore = midtext('lsi score',(x(2)+x(3))/2,y(4));
    date = midtext('date',x(4),y(4));
        
    % arrow control
    delta = .08;
    button('^',@arrow_cb,x(3),y(3)-delta/2);
    button('<',@arrow_cb,x(2)+delta,y(2));
    button('>',@arrow_cb,x(4)-delta,y(2));
    set(gcf,'WindowButtonDownFcn',@wbdf)
    
    % web button
    web_toggle = button('web',@web_cb,x(3),y(1)+delta/2);
    
    % rank slider
    n = length(D);
    rank_slider = slider(n,@slider_cb,x(1),y(1));
    rank_text = smalltext('rank',x(1),y(2)-.06);
    
    % log and help buttons
    log = toggle('log',@log_cb,x(5)-.05,y(1));
    button('help',@help_cb,x(5)+.05,y(1));
    
    if nargin > 0
        set(kwds,'string',keyterm)
        keyword_cb(kwds)
    end
    
    %% keyboard callback
    
    function keyword_cb(arg,~)
        % Rank k approximation to term/document matrix.
        [U,S,V] = svd(full(A),'econ');
        k = get(rank_slider,'value');
        Uk = U(:,1:k);
        Sk = S(1:k,1:k);
        Vk = V(:,1:k);

        querie = split(string(get(arg,'string')));
        for j = 1:length(querie)
            if isempty(word_index(T,querie{j}))
                % querie{k|} is not in T.  find closest.
                qj = closest(T,querie{j});
                querie{j} = qj{1};
                qb = insertAfter(querie,strlength(querie),' ');
                qb = [qb{:}];
                set(kwds,'string',qb(1:end-1))
            end
        end
        [docs,scores,perms] = query(querie,T,Uk,Sk,Vk,D);
        update(1)
    end

    %% arrow callback
    
    function arrow_cb(arg,~)
        arrow = [get(arg,'string') ' '];
        switch arrow
            case '> '
                p = find(contains(docs,get(dox,'string')));
                p = p+1;
                update(p)
            case '< '
                p = find(contains(docs,get(dox,'string')));
                p = max(1,p-1);
                update(p)            
            case '^ '
                uparrow_cb(arrow)
            otherwise
                disp(get(gcf,'selection'))
        end
    end

    %% web callback
    
    function web_cb(arg,~)
        if get(arg,'value') == 0
            close(webhandle)
            webhandle = [];
        else
            p = find(contains(docs,get(dox,'string')));
            update(p)
         end
    end

    %% slider callback

    function slider_cb(slide,~)
        ranc = round(get(slide,'value'));
        set(slide,'value',ranc);
        set(rank_text,'string',sprintf('%d/%d',ranc,n));
        keyword_cb(kwds)
    end
 
    %% windowbuttondownfcn
    
    function wbdf(~,~)
        [p,q] = read_mouse;
        if .28 <= p && p <= .39 && .12 <= q && q <= .22
            alt_cb('<')
        elseif .51 <= p && p <= .62 && .12 <= q && q <= .22
            alt_cb('>')
        elseif .40 <= p && p <= .50 && .25 <= q && q <= .34
            uparrow_cb('^^')
        end
    end

    %% alt (right click) callback

    function alt_cb(arg)
        p = find(contains(docs,get(dox,'string')));
        r = word_index(T,querie);
        j = find(A(r,perms));
        arrow = [arg arg];
        switch arrow
            case '>>'
                if any(j>p)
                    p = min(j(j>p));
                end
                update(p)
            case '<<'
                if any(j<p)
                    p = max(j(j<p));
                end
                update(p)
        end
    end

    %%  uparrow_cb
    function uparrow_cb(arrow,~)
        switch arrow
            case('^ ')
                %% Single uparrow, promote root of doc name
                s = get(dox,'string');
                    s = extractBefore(s,'.');
                s = extractAfter(s,'/');
                if any(contains(s,'.'))
                    s = extractBefore(s,'.');
                end
                if any(contains(s,'_'))
                    s = extractBefore(s,'_');
                end
                set(kwds,'string',s)
                keyword_cb(kwds)
            case('^^')
                % Double uparrow, pick random term
                m = length(T);
                tag = zeros(m,1,'logical');
                for k = 1:m
                    tag(k) = nnz(A(k,:)) > 5 && length(char(T{k})) > 5;
                end
                R = T(tag);
                set(kwds,'string',R(randi(length(R))))
                keyword_cb(kwds)
        end
    end

    %% query
    
    function [docs,scores,perms] = query(querie,T,Uk,Sk,Vk,D)
        % [docs,scores,perms] = query(queries,T,Uk,Sk,Vk,D) 

        % Construct the score vector by element-wise product.
        n = size(Vk,1);
        scores = ones(n,1);
        qz = split(querie);
        for i = 1:length(qz)
            % Find the index of the query key term in the term list.
            q = double(contains(T,lower(qz{i})));

            % Project the indivual query onto the document space.
            qhat = Sk\Uk'*q;
            si = Vk*qhat;
            
            % Element-wise product of individual scores.
            scores = si.*scores;
        end
        scores = scores/norm(scores);
        
        % Return docs sorted by scores in decreasing order.
        [~,perms] = sort(scores,'descend');
        scores = scores(perms);
        docs = D(perms);
    end

    %% update

    function update(p)
        if p > length(docs)
            set(dox,'string','no more documents')
            set(skore,'string','')
            set(tcnt,'string',' ')
            set(date,'string',' ')
        else
            j = contains(D,docs(p));
            r = word_index(T,querie);
            tc(1) = A(r,j);                % Term count
            tc(2) = sum(A(r,perms(1:p)));  % Cumulative term count
            tc(3) = sum(A(r,:));           % Total term count
            for i = 2:length(querie)
                r = word_index(T,querie{i});
                tc(1) = min(tc(1),A(r,j));
                tc(2) = min(tc(2),sum(A(r,perms(1:p))));
                tc(3) = min(tc(3),sum(A(r,:)));
            end    
            tc = full(tc);
                
            if any(contains(docs{p},'video/'))
                docs{p} = erase(docs{p},'.txt');
            end
            set(dox,'string',docs{p})
            set(tcnt,'string',sprintf('%d,  %d/%d',tc))
            set(skore,'string',sprintf('%6.3f',scores(p)))
            dc = contains(L.links,docs{p});
            if nnz(dc) > 0
                d = L.links{dc,3};
                if length(d) > 4
                    d = datestr(d);
                end
            else
                d = ' ';
            end
            set(date,'string',d)
            if get(log,'value')
                fprintf('%%  %s %33s %4d %4d/%d %8.3f  %s\n', ...
                    arrow,docs{p},tc,scores(p),d)
            end
      
            if ~isempty(webhandle)
                close(webhandle)
                pause(.5)
                webhandle = [];
            end
            ranc = get(rank_slider,'value');
            set(rank_text,'string',sprintf('%d/%d',ranc,n));
            if get(web_toggle,'value')
                if contains(docs{p},'blog')
                    url = L.prefix{1};
                elseif contains(docs{p},'news')
                    url = L.prefix{2};
                elseif contains(docs{p},'exmm')
                    url = L.prefix{7};
                elseif contains(docs{p},'exm')
                    url = L.prefix{3};
                elseif contains(docs{p},'ncmm')
                    url = L.prefix{8};
                elseif contains(docs{p},'ncm')
                    url = L.prefix{4};   
                elseif contains(docs{p},'video')
                    url = L.prefix{5};                
                elseif contains(docs{p},'lab')
                    url = L.prefix{6};
                else
                    error('impossible url')
                end
                jc = contains(L.links,docs{p});
                if any(contains(L.links(jc,1),'blog'))
                    url = url + L.links(jc,3) + '/';
                end
                url = url + L.links(jc,2);
                if any(contains(url,"video-series-overview"))
                    url = erase(url,'solving-odes-in-matlab/');
                elseif any(contains(url,"hhxx_talk"))
                    url = "https://blogs.mathworks.com/cleve/2017/" + ...
                          "07/01/householder-seminar-hhxx-on-" + ...
                          "numerical-linear-algebra";
                end
                url = replace(url,' ','-');
                [~,webhandle] = web(url);
            else
                close(webhandle)
            end
        end
    end

    %% closest
    
    function [C,d] = closest(T,s)
        % [C,d] = closest(T,s) is the string array of strings in T that have
        % minimum levenshtein distance d from s.
            n = length(T);
            v = zeros(n,1);
            for k = 1:n
                t = char(T{k});
                t(1:find(t=='/',1,'last')) = [];
                t(find(t=='.',1,'first'):end) = [];
                t = erase(t,'-blog');
                t = split(t,'-');
                w = zeros(1,length(t));
                for j = 1:length(t)
                    w(j) = levenshtein(t(j),s);
                end        
                v(k) = min(w);
            end
            d = min(v);
            C = T(v == d);
    end

    %% word_index

    function p = word_index(list,w)
        % Index of w in list.
        % Returns empty if w is not in list.
        % Binary search
        w = lower(w);
        m = length(list);
        p = fix(m/2);
        q = ceil(p/2);
        t = 0;
        tmax = ceil(log2(m));
        while list(p) ~= w
            if list(p) > w
                p = max(p-q,1);
            else
                p = min(p+q,m);
            end
            q = ceil(q/2);
            t = t+1;
            if t == tmax
                p = [];
                break
            end
        end
    end  

    %% Levenshtein
        
    function d = levenshtein(s,t)
    % levenshtein(s,t) is the number of deletions, insertions, or
    % substitutions required to transform string s to string t.
    % https://en.wikipedia.org/wiki/Levenshtein_distance

        s = char(s);
        t = char(t);
        m = length(s);
        n = length(t);
        v0 = 0:n;
        v1 = zeros(1,n+1);   
        for i = 1:m
            v1(1) = i;
            for j = 1:n
                c = (s(i) ~= t(j));
                v1(j+1) = min([v1(j)+1, v0(j+1)+1, v0(j)+c]);
            end
            [v0,v1] = deal(v1,v0);
        end
        d = v0(n+1);
    end   

    %% log callback

    function log_cb(arg,~)
        if get(arg,'value')
           p = find(contains(docs,get(dox,'string')));
           arrow = '  ';
           if ~isempty(p)
               fprintf('\n%% %s\n',querie)
               fprintf(['\n%% arrow %19s document %3s term counts' ...
                   ' %3s lsi   date\n'],' ',' ',' ')
               update(p)
           end
        end
    end

    %% help callback
    
    function help_cb(~,~)
        helpwin('c5')
    end

    %% button
    
    function btn = button(str,cb,xx,yy)
        btn = uicontrol('style','pushbutton',  ...
            'units','normalized', ...
            'position',[xx yy .08 .08], ...
            'background','white', ...
            'string',str, ...
            'fontsize',fs, ...
            'fontweight','bold', ...
            'callback',cb);
    end

    %% toggle
    
    function btn = toggle(str,cb,xx,yy)
        btn = uicontrol('style','togglebutton',  ...
            'units','normalized', ...
            'position',[xx yy .08 .08], ...
            'background','white', ...
            'string',str, ...
            'fontsize',fs, ...
            'fontweight','bold', ...
            'callback',cb);
    end

    %% slider
    
    function sldr = slider(top,cb,xx,yy)
        sldr = uicontrol('style','slider',  ...
            'units','normalized', ...
            'position',[xx yy .16 .06], ...
            'background','white', ...
            'min',1, ...
            'max',top, ...
            'sliderstep',[1/top 10/top], ...
            'value',round(top/2), ...
            'callback',cb);
    end

    %% bigedit
    
    function btn = bigedit(str,cb,xx,yy)
        btn = uicontrol('style','edit', ...
            'units','normalized', ...
            'position',[xx yy .48 .08], ...
            'background','white', ...
            'fontweight','bold', ...
            'fontsize',fs, ...
            'horiz','center', ...
            'string',str, ...
            'callback',cb);
    end

    %% midtext
    
    function btn = midtext(str,xx,yy)
        btn = uicontrol('style','text', ...
            'units','normalized', ...
            'position',[xx yy .24 .08], ...
            'background','white', ...
            'fontweight','bold', ...
            'fontsize',fs, ...
            'horiz','center', ...
            'string',str);
    end

    %% smalltext

    function btn = smalltext(str,xx,yy)
        btn = uicontrol('style','text', ...
            'units','normalized', ...
            'position',[xx yy .16 .06], ...
            'background','white', ...
            'fontweight','bold', ...
            'fontsize',fs, ...
            'horiz','center', ...
            'string',str);
    end

    %% read mouse

    function [p,q] = read_mouse
        % Current horizontal and vertical coordinates of the mouse.
        pq = get(gca,'currentpoint');
        p = pq(1,1);
        q = pq(1,2);
    end % read_mouse
end % c5app