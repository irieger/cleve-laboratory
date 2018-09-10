function lab1
%LAB1 Check out Cleve's Laboratory.
%  LAB1 and LAB2 provide interfaces to a collection of MATLAB experiments.
%  Click on any icon to access the underlying experiment.

%   Copyright 2016-2017 Cleve Moler
%   Copyright 2016-2017 The MathWorks, Inc.

    clf
    f = findobj('name','lab1');
    if ~isempty(f)
        close(f)
    end
    set(gcf,'numbertitle','off', ...
        'menubar','none', ...
        'name','lab1', ...
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
            case  1, f = @bizcard;
            case  2, f = @biorhythms;
            case  3, f = @klock;
            case  4, f = @lifex;
            case  5, f = @fibonacci;
            case  6, f = @fern;
            case  7, f = @house_mult;
            case  8, f = @t_puzzle;
            case  9, f = @tictactoe;
            case 10, f = @flame;
            case 11, f = @predprey;
            case 12, f = @mandelbrot;
            case 13, f = @durerperm;
            case 14, f = @waterwave;
            case 15, f = @expshow;
            case 16, f = @sudoku;
            case 17, f = @orbits;
            case 18, f = @golden_spiral;
            case 19, f = @lab1;
            case 20, f = @lab2;
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
        args{j} = thumbnails1(f);
    end
      
% ----------------------------------------------------------------------

    function woof(varargin)
       % woof = WindowbuttonUpFunction
       pq = get(gcf,'currentpoint');
       p = pq(1);
       q = pq(2);
       r = 16+floor(5*p)-5*floor(4*q);
       f = funs{r};
       figure
       if isempty(args{r})
           f();
       else
           f(args{r})
       end
    end % woof

end %lab1
