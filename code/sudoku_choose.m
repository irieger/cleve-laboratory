function sudoku_choose(~,~)
    shg
    clf
    fid = fopen('sudoku_puzzle.m');
    g = '';
    while length(g) < 8 || ~isequal(g(5:8),'p = ')
        g = fgetl(fid);
    end
    s = {'Choose sudoku_puzzle(p).'}; 
    while length(g) >=  8 && isequal(g(5:8),'p = ')
        s{end+1,1} = g(4:end);
        g = fgetl(fid);
    end
    uicontrol('style','popupmenu', ...
        'string',s, ...
        'fontsize',12, ...
        'units','normalized', ...
        'position',[.05 .2 .9 .3], ...
        'tag','choose', ...
        'callback',@menu_cb);
    fclose(fid); 
    
    function menu_cb(cbh,~)
        sudoku(sudoku_puzzle(get(cbh,'value')-1));
    end
end