function [X,steps] = sudoku(X,steps)
% SUDOKU  Solve a Sudoku dots using recursive backtracking.
%   sudoku(X), for a 9-by-9 array X, solves the Sudoku puzzle for X.
%   sudoku(p), with 1 <= p <= 16, uses X= sudoku_puzzle(p).
%   sudoku, with no arguments uses p = 1, the MATLAB original puzzle.
%   [X,steps] = sudoku(..) returns solution and the number of steps.
%   [X,steps] = sudoku(X,steps) is a recursive call.
%   See also sudoku_all, sudoku_assist, sudoku_basic, sudoku_puzzle. 

%   Copyright 2016-2017 Cleve Moler
%   Copyright 2016-2017 The MathWorks, Inc.

   persistent puz
   thumb = false;
   if nargin == 0
      if isempty(puz)
         puz = 1;
      end
      X = sudoku_puzzle(puz);
   elseif nargin == 1 && isscalar(X)
      puz = X;
      X = sudoku_puzzle(puz);
   elseif nargin == 1 && isequal(X,'thumb')
      thumb = true;
      puz = ceil(16*rand);
      X = sudoku_puzzle(puz);
   end
   if nargin < 2 
      steps = 0;
      gui_init(X,thumb);
   end
   if thumb
      return
   end
   sudoku_gui(X,steps);

   % Fill in all "singletons", the cells with only one candidate.
   % C is the array of candidates for each cell.
   % N is the vector of the number of candidates for each cell.
   % s is the index of the first cell with the fewest candidates.

   [C,N] = candidates(X);
   while all(N>0) && any(N==1)
      sudoku_gui(X,steps,C);
      s = find(N==1,1);
      X(s) = C{s};
      steps = steps + 1;
      sudoku_gui(X,steps,C);
      [C,N] = candidates(X);
   end
   sudoku_gui(X,steps,C);
   
   % Recursive backtracking.

   if all(N>0)
      Y = X;
      s = find(N==min(N),1);
      for t = [C{s}]                        % Iterate over the candidates.
         X = Y;
         sudoku_gui(X,steps,C);
         X(s) = t;                          % Insert a tentative value.
         steps = steps + 1;
         sudoku_gui(X,steps,C,s);           % Color the tentative value.

         [X,steps] = sudoku(X,steps);       % Recursive call.

         if all(X(:) > 0)                   % Found a solution.
            break
         end
         sudoku_gui(X,steps,C,-s);          % Revert color of tentative value.
      end
   end
   if nargin < 2
      gui_finish(X,steps);
   end

% ------------------------------

   function [C,N] = candidates(X)
      % C = candidates(X) is a 9-by-9 cell array of vectors
      % C{i,j} is the vector of allowable values for X(i,j).
      % N is a row vector of the number of candidates for each cell.
      % N(k) = Inf for cells that already have values.
      tri = @(k) 3*ceil(k/3-1) + (1:3);
      C = cell(9,9);
      for j = 1:9
         for i = 1:9
            if X(i,j)==0
               z = 1:9;
               z(nonzeros(X(i,:))) = 0;
               z(nonzeros(X(:,j))) = 0;
               z(nonzeros(X(tri(i),tri(j)))) = 0;
               C{i,j} = nonzeros(z)';
            end
         end
      end
      N = cellfun(@length,C);
      N(X>0) = Inf;
      N = N(:)';
   end % candidates

% ------------------------------

   function gui_init(X,thumb)

      % Initialize gui
      % H is the structure of handles, saved in figure userdata.

      dkblue = [0 0 2/3];
      dkgreen = [0 1/2 0];
      dkmagenta = [1/3 0 1/3];
      grey = [1/2 1/2 1/2];
      fname = 'Lucida Sans Typewriter';
      if thumb
         framed_axis(get(gca,'pos'));
         cla
         lw = 2;
         fsize = get(0,'defaulttextfontsize');
      else
         clf
         shg
         set(gcf,'menubar','none','numbertitle','off','name','sudoku', ...
             'color','white')
         lw = 4;
         fsize = get(0,'defaulttextfontsize')+6;
         axis square
         axis off
      end
      
      for m = [2 3 5 6 8 9]
         line([m m]/11,[1 10]/11,'color',grey)  
         line([1 10]/11,[m m]/11,'color',grey)
      end
      for m = [1 4 7 10]
         line([m m]/11,[1 10]/11,'color',dkmagenta,'linewidth',lw)
         line([1 10]/11,[m m]/11,'color',dkmagenta,'linewidth',lw)
      end
   
      H.a = zeros(9,9);
      for j = 1:9
         for i = 1:9
            if X(i,j) > 0
               string = int2str(X(i,j));
               color = dkblue;
            else
               string = ' ';
               color = dkgreen;
            end
            H.a(i,j) = text((j+1/2)/11,(10.5-i)/11,string, ...
              'units','normal','fontsize',fsize,'fontweight','bold', ...
              'fontname',fname,'color',color,'horizont','center');
         end
      end
      if thumb
          H.s = 0;
      else
          strings = {'step','slow','fast','finish','puzzle','close'};
          H.b = zeros(1,6);
          for k = 1:6
             H.b(k) = uicontrol('string',strings{k}, ...
                'style','pushbutton', ...
                'units','normal', ...
                'position',[0.12*k-.04,0.05,0.10,0.05], ...
                'background','white', ...
                'value',0, ...
                'callback',@buttons_cb);
          end
          set(H.b(5:6),'enable','off')

          cbs = 'web([''http://www.mathworks.com/company/newsletters/articles/solving-sudoku-with-matlab.html''])';
          H.f = uicontrol('style','pushbutton','string','info', ...
                'units','normal','position',[0.82,.05,0.10,0.05], ...
                'background','white','value',0, ...
                'callback',cbs);
          
          H.s = 1;
          H.t = title('0','fontweight','bold');
      end
      set(gcf,'userdata',H)
      drawnow
   end % gui_init

% ------------------------------

    function buttons_cb(varargin)
       H = get(gcf,'userdata');
       H.s = find(H.b==gco);
       set(gcf,'userdata',H);
    end

% ------------------------------

   function sudoku_gui(X,steps,C,z)

      H = get(gcf,'userdata');    
      if H.s == 0
         return   % thumb
      elseif H.s >= 4
         if mod(steps,100) == 0
            set(H.t,'string',int2str(steps))
            drawnow
         end
         return
      else
         set(H.t,'string',int2str(steps))
      end
      k = [1:H.s-1 H.s+1:4];
      set(H.b(k),'value',0);
      dkblue = [0 0 2/3];
      dkred = [2/3 0 0];
      dkgreen = [0 1/2 0];
      cyan = [0 2/3 2/3];
      fsize = get(0,'defaulttextfontsize');

      % Update entire array, except for initial entries.

      for j = 1:9
         for i = 1:9
            if ~isequal(get(H.a(i,j),'color'),dkblue) && ...
               ~isequal(get(H.a(i,j),'color'),cyan)
               if X(i,j) > 0
                  set(H.a(i,j),'string',int2str(X(i,j)),'fontsize',fsize+6, ...
                     'color',dkgreen)
               elseif nargin < 3
                  set(H.a(i,j),'string',' ')
               elseif length(C{i,j}) == 1
                  set(H.a(i,j),'string',char3x3(C{i,j}),'fontsize',fsize-4, ...
                     'color',dkred)
               else
                  set(H.a(i,j),'string',char3x3(C{i,j}),'fontsize',fsize-4, ...
                     'color',dkgreen)
               end
            end
         end
      end
      if nargin == 4
         if z > 0
            set(H.a(z),'color',cyan)
         else
            set(H.a(-z),'color',dkgreen)
            return
         end
      end

      % Gui action = single step, brief pause, or no pause

      switch H.s
         case 1
            H.s = 0;
            set(gcf,'userdata',H);
            while H.s == 0
               drawnow
               H = get(gcf,'userdata');
            end
         case 2
            pause(0.5)
         case 3
            drawnow
      end
      if nargin == 4
         if z > 0
            set(H.a(z),'color',cyan)
         else
            set(H.a(-z),'color',dkgreen)
            return
         end
      end

      % ------------------------------
   
      function s = char3x3(c)
         % 3-by-3 character array of candidates.
         b = blanks(5);
         s = {b; b; b};
         for k = 1:length(c)
            d = c(k);
            p = ceil(d/3);
            q = 2*mod(d-1,3)+1;
            s{p}(q) = int2str(d);
         end
      end

   end % gui

% ------------------------------

   function gui_finish(X,steps)
 
      H = get(gcf,'userdata');
      if H.s == 0
         return  % thumb
      end
      H.s = 2;
      set(H.b(1:4),'enable','off')
      set(H.b(5:6),'enable','on')
      set(H.b(5),'callback',@sudoku_choose)
      set(H.b(6),'string','close', ...
         'value',0, ...
         'callback','close(gcf)')
      set(gcf,'userdata',H)          
      sudoku_gui(X,steps)
    
   end % gui_finish

end % sudoku
