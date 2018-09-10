function farg = thumbnails2(f)
farg = [];
switch func2str(f)

% hello_world
    case 'hello_world'
        cla
        text((1+rand)/3,4*rand/5,'Hello World','horiz','center')

 %--------------------------------------------------------------------
 % eigshow
    case 'eigshow'
        cla
        xcolor = [0 .6 0];
        Axcolor = [0 0 .8];
        mats = {
            '[5/4 0; 0 3/4]'
            '[5/4 0; 0 -3/4]'
            '[1 0; 0 1]'
            '[0 1; 1 0]'
            '[0 1; -1 0]'
            '[1 3; 4 2]/4'
            '[1 3; 2 4]/4'
            '[3 1; 4 2]/4'
            '[3 1; -2 4]/4'
            '[2 4; 2 4]/4'
            '[2 4; -1 -2]/4'
            '[6 4; -1 2]/4'
            'randn(2,2)'};
        mindex = ceil(rand*length(mats));
        A = eval(mats{mindex});
        s = 1.1*max(1,norm(A));
        axis([-s s -s s])
        axis square
        dt = rand*2*pi;
        N = 36;
        t = 0:1/N:1;
        z = exp(2*pi*(t+dt)*1i);
        x = real(z);
        y = imag(z);
        Axy = A*[x;y];
        line(x,y, ...
           'color',xcolor)
        line(Axy(1,:),Axy(2,:), ...
           'color',Axcolor)
        line([0,x(1)],[0,y(1)], ...
           'color',xcolor)
        line([0,Axy(1,1)],[0,Axy(2,1)], ...
           'color',Axcolor)
        farg = mats{mindex};

%--------------------------------------------------------------------
% blackjack
    case 'blackjack'
        cla
        z = exp((0:16)/16*pi/2*i)/16;
        edge = [z+1/2+7*i/8 i*z-1/2+7*i/8 -z-1/2-7*i/8 ...
                -i*z+1/2-7*i/8 9/16+7*i/8];
        fs = 24;
        pips = ['A','2':'9','T','J','Q','K'];
        rng('shuffle')
        rngsd = rng;
        ncards = 4*52;  % 4 decks
        deck = mod(0:ncards-1,52)+1;
        deck = deck(randperm(ncards));  % Shuffle
        for x = [-1 1]
           patch(real(edge)+2*x/3,imag(edge),'w')
           c = deck(ncards);
           ncards = ncards - 2;   % Skip over card to dealer.
           suit = ceil(c/13);
           p = pips(mod(c-1,13)+1);
           switch suit
              case {1,4}, redblack = [0 0 0];
              case {2,3}, redblack = [2/3 0 0];
           end
           text(2*x/3,0,p, ...
               'color',redblack, ...
               'fontname','courier', ...
               'fontsize',fs, ...
               'horizontal','center', ...
               'fontweight','bold')
        end
        axis([-1.5 1.5 -1.5 1.5])
        axis equal
        farg = rngsd;
        
%--------------------------------------------------------------------
% swinger
    case 'swinger'
        cla
        axis([-1 1 -1 1])
        t1 = rand*2*pi;
        t2 = rand*2*pi;
        r = .4;
        x = [0 r*cos(t1)];
        y = [0 r*sin(t1)];
        x = [x x(2)+r*cos(t2)];
        y = [y y(2)+r*sin(t2)];
        line(x,y,'marker','o','color','black')
        
%--------------------------------------------------------------------
% eigsvdgui
    case 'eigsvdgui'
        A = diag(8:-1:1) + diag(10*rand(7,1),1);
        A(10,8) = 0;
        imagesc(A)
        axis equal
        set(gca,'xtick',[],'ytick',[])
         
%--------------------------------------------------------------------
% censusapp
    case 'censusapp'
        x = imread('census_clock.png');
        [p,q,~] = size(x);
        w = q+50;
        h = w;
        z = zeros(h,w,3,'uint8') + 255;
        z((h-p)/2+(1:p),(w-q)/2+(1:q),:) = x;
        showim(z)
        
%--------------------------------------------------------------------
% touchtone
    case 'touchtone'
        load touchtone
        imagesc(D)
        colormap(gca,gray)
        axis equal
        set(gca,'xtick',[],'ytick',[])
        
%--------------------------------------------------------------------
% pdegui
    case 'pdegui'
        [x,y] = meshgrid(-pi:2*pi/32:pi);
        z = (pi-abs(x)).*(pi-abs(y)).*sin(2*x).*sin(2*y);
        contourf(z,6)
        axis square
        set(gca,'xtick',[],'ytick',[])    
       
%--------------------------------------------------------------------
% interpgui
    case 'interpgui'
        interpthumb
        
%--------------------------------------------------------------------
% waves
    case 'waves'
        waves('thumb')
        
%--------------------------------------------------------------------
% tumbling_box
    case 'tumbling_box'
        tumbler

% --------------------------------------------------------------------
% ladders
    case 'ladders'
        ladders_thumb
                
% --------------------------------------------------------------------
% walker
    case 'walker'
        f('thumb')
        
% --------------------------------------------------------------------
% moebiusapp
    case 'moebiusapp'
        load labapp_pix
        showim(moebius_pix)
        axis on
        axis square
        box on
        
% --------------------------------------------------------------------
% ulpsapp
    case 'ulpsapp'
        load labapp_pix
        showim(ulps_pix)
        axis on
        axis square
        box on

% --------------------------------------------------------------------
% patience
    case 'patience'
        load labapp_pix
        [h,w,~] = size(patience_pix);
        d = (w-h)/2;
        f = 255*ones(d,w,3,'uint8');
        p = [f;patience_pix;f];
        showim(p);
        axis on

%--------------------------------------------------------------------
% morse_tree
    case 'morse_tree'
        morse_tree('thumbnail')

        %--------------------------------------------------------------------
% colorcubes
    case 'colorcubes'
        colorcubes('thumbnail')
        
%--------------------------------------------------------------------
% lab2
    case 'lab2'
        showim(imread('lab_02.png'))
        axis square
        text(.5,.5,'lab2', ...
            'units','normalized', ...
            'horiz','center', ...
            'fontname','courier', ...
            'fontweight','bold', ...
            'fontsize',16)  
        
%--------------------------------------------------------------------
% lab3
    case 'lab3'
        showim(imread('lab_03.png'))
        axis square
        text(.5,.5,'lab3', ...
            'units','normalized', ...
            'horiz','center', ...
            'fontname','courier', ...
            'fontweight','bold', ...
            'fontsize',16)
       
%--------------------------------------------------------------------
% otherwise
    otherwise
end
