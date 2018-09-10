function ladders_thumb
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
    initialize_figure;
    
%% initialize_figure
  
    function initialize_figure
        cla
        % Size of the square view
        h = 160;
        axis([-h/4 3/4*h -h/8 7/8*h])
        axis square
        lines
        % buttons
        % labels
        set(gca,'xtick',[],'ytick',[])
    end %initialize_figure

       
%% lines
% Play dot-to-dot.
    
    function lines
        ms = 3*get(gcf,'defaultlinemarkersize');  % Larger dots 
        lw = get(gcf,'defaultlinelinewidth');  % Thicker lines
        u = c*w/y; 

        % Five markers at the vertices.
        line([0 0],[0 0],'Marker','.','MarkerSize',ms)
        line([w w],[0 0],'Marker','.','MarkerSize',ms,'Color','k')
        line([0 0],[x x],'Marker','.','MarkerSize',ms,'Color','k')
        line([w w],[y y],'Marker','.','MarkerSize',ms,'Color','k')
        line([u u],[c c],'Marker','.','MarkerSize',ms,'Color','k')
        
        % Connect the markers with six lines.
        line([0 w],[0 0],'Linewidth',lw)
        line([0 0],[0 x],'Linewidth',lw)
        line([w w],[0 y],'Linewidth',lw)
        line([0 w],[x 0],'Linewidth',lw)
        line([w 0],[y 0],'Linewidth',lw)
        line([u u],[c 0],'LineStyle','-.','Linewidth',lw)
        box on
    end % lines


end % ladders_thumb