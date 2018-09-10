function lab2
%LAB2 Check out Cleve's Laboratory.
%  LAB1 and LAB2 provide interfaces to a collection of MATLAB experiments.
%  Click on any icon to access the underlying experiment.

%   Copyright 2000-2017 Cleve Moler
%   Copyright 2000-2017 The MathWorks, Inc.

    clf
    f = findobj('name','lab2');
    if ~isempty(f)
        close(f)
    end

    set(gcf, ...
        'numbertitle','off', ...
        'menubar','none', ...
        'name','lab2', ...
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
            case  1, f = @hello_world;
            case  2, f = @blackjack;
            case  3, f = @swinger;
            case  4, f = @eigsvdgui;
            case  5, f = @censusapp;
            case  6, f = @touchtone;
            case  7, f = @pdegui;
            case  8, f = @interpgui;
            case  9, f = @waves;
            case 10, f = @tumbling_box;
            case 11, f = @ladders;
            case 12, f = @eigshow;
            case 13, f = @walker;
            case 14, f = @moebiusapp;
            case 15, f = @ulpsapp;
            case 16, f = @patience;               
            case 17, f = @morse_tree;
            case 18, f = @colorcubes;
            case 19, f = @lab2;
            case 20, f = @lab3;
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
            args{j} = thumbnails2(f);
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
end %lab2
