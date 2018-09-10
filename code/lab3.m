function lab3
%LAB3 Check out Cleve's Laboratory.
%  LAB1, 2 and 3 provide interfaces to a collection of MATLAB experiments.
%  Click on any icon to access the underlying experiment.

%   Copyright 2000-2018 Cleve Moler
%   Copyright 2000-2018 The MathWorks, Inc.

    clf
    f = findobj('name','lab3');
    if ~isempty(f)
        close(f)
    end

    set(gcf, ...
        'numbertitle','off', ...
        'menubar','none', ...
        'name','lab3', ...
        'inverthardcopy','off')
    axs = cell(20,1);
    funs = cell(20,1);
    args = cell(20,1);
    for k = 1:20
        p = rem(k-1,5);
        q = (16-k+p)/5;
        d = .01;
        axk = [p/5+d q/4+d 1/5-2*d 1/4-2*d];
        framed_axis(axk);
        switch k
            case  1, f = @calculator;
            case  2, f = @roman_clock;
            case  3, f = @arrowhead;
            case  4, f = @c5;
            case  5, f = @dragon;
            case  6, f = @play_match_the_color_game;
            case 19, f = @lab3;
            case 20, f = @lab1;
            otherwise, f = [];
        end
        text(.5,.5,char(f), ...
            'Horizontal','center', ...
            'Interpreter','none')
        axs{k} = gca;
        funs{k} = f;
    end
    set(gcf, ...
        'units','normalized', ...
        'userdata',funs, ...
        'windowbuttonupfcn',@woof);
    for j = 1:20     
        axes(axs{j})
        f = funs{j};
        if ~isempty(f)
            args{j} = thumbnails3(f);
        end
    end
       
% ----------------------------------------------------------------------
    
    function woof(varargin)
    % woof = WindowbuttonUpFunction
       pq = get(gcf,'currentpoint');
       p = pq(1);
       q = pq(2);
       r = 16+floor(5*p)-5*floor(4*q);
       f = funs{r};
       if ~isempty(f)
           figure('units','normal','pos',get(gcf,'pos'))
           if isempty(args{r})
               f();
           else
               f(args{r})
           end
       end
      end % woof
end %lab3
