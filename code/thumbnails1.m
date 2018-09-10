function farg = thumbnails1(f)
    farg = [];
    switch func2str(f)
    % bizcard
        case 'bizcard'
            f('thumb')

    % --------------------------------------------------------------------
    % biorhythms
        case 'biorhythms'
            t0 = fix(now);
            t1 = fix(now);
            % Eight week time span centered on today.
            t = (t1-28):0.25:(t1+28);
            y = 100*[sin(2*pi*(t-t0)/23)
                     sin(2*pi*(t-t0)/28)
                     sin(2*pi*(t-t0)/33)];
            plot(t,y)
            line([t1 t1],[-100 100],'color','k')
            line([t1-28 t1+28],[0 0],'color','k')
            axis tight
            set(gca,'ylim',[-250,250])
            set(gca,'xtick',[],'ytick',[])
            line([t1-28 t1+28],[100 100],'color',[.5 .5 .5])
            line([t1-28 t1+28],[-100 -100],'color',[.5 .5 .5])

    % --------------------------------------------------------------------
    % klock
        case 'klock'
            f('thumb')

    % --------------------------------------------------------------------
    % lifex
        case 'lifex'
            cla
            i = [38 39 38 39 38 39 40 37 41 36 42 36 42 39 37 41 38 39 ...
                 40 39 36 37 38 36 37 38 35 39 34 35 39 40 36 37 36 37];
            j = [21 21 22 22 31 31 31 32 32 33 33 34 34 35 36 36 37 37 ...
                 37 38 41 41 41 42 42 42 43 43 45 45 45 45 55 55 56 56];
            plot(j,i,'.','markersize',4,'color',[0 0 2/3])
            set(gca,'xtick',[],'ytick',[])
            line([15 61 61 15 15],[15 15 61 61 15],'color','k')
            axis([10 66 10 66],[10 66 10 66])

    % --------------------------------------------------------------------
    % fibonacci
        case 'fibonacci'
            load labapp_pix
            B  = [bunny rabbit];
            E = 255*ones(25,150,'uint8');
            B = [E;E;B;E];
            contourf(flipud(B),3)
            colormap(bone)
            axis equal
            set(gca,'xtick',[],'ytick',[])

    % --------------------------------------------------------------------
    % fern
        case 'fern'
            F = finitefern(2048,2048,2048);
            spy(F,'g.');
            set(gca,'xtick',[],'ytick',[],'xlabel',[])

    % --------------------------------------------------------------------
    % house_mult
        case 'house_mult'
            H = [ -6  -6  -7   0   7   6   6  -3  -3   0   0
                  -7   2   1   8   1   2  -7  -7  -2  -2  -7 ];
            t = randn*pi/2;
            U = [cos(t) sin(t); -sin(t) cos(t)];
            X = U*H;
            X(:,end+1) = X(:,1);
            plot(X(1,:),X(2,:),'.-','markersize',14,'linewidth',2)
            axis(12*[-1 1 -1 1])
            set(gca,'xtick',[],'ytick',[])

    % --------------------------------------------------------------------
    % t_puzzle
        case 't_puzzle'
            load labapp_pix
            showim(tpuzzle_pix);
            axis on

    % --------------------------------------------------------------------
    % tictactoe
        case 'tictactoe'
            load labapp_pix
            showim(tictactoe_pix);
            axis square
            axis on
            
    % --------------------------------------------------------------------
    %flame
        case 'flame'
            load labapp_pix
            showim(flame_pix)
            axis on

    % --------------------------------------------------------------------
    %predprey
        case 'predprey'
            mu = [300 200]';
            eta = [400 100]';
            ydot = @(t,y) [(1-y(2)/mu(2))*y(1); -(1-y(1)/mu(1))*y(2)];
            opts = odeset('reltol',1.e-8);
            [~,y] = ode45(ydot,[0 6.53],eta,opts);
            plot(y(:,1),y(:,2),'k-')
            line([100 600 600 100 100],[50 50 500 500 50],'color','k')
            line([mu(1) mu(1)],[mu(2) mu(2)],'marker','.', ...
                'markersize',12, ...
                'color',[2/3 0 0])
            line([eta(1) eta(1)],[eta(2) eta(2)],'marker','.', ...
                'markersize',12, ...
                'color',[0 2/3 2/3])
            set(gca,'xtick',[],'ytick',[])
            axis([50 650 -100 650])

    % --------------------------------------------------------------------
    % mandelbrot
        case 'mandelbrot'
            load labapp_pix
            showim(mandelbrot_pix)
            axis on
            set(gca,'xtick',[],'ytick',[])

    % --------------------------------------------------------------------
    % durerperm
        case 'durerperm'
            X = [];
            load detail
            Z = 64*ones(480,480);
            Z(61+(1:359),56+(1:371)) = X;
            image(Z)
            colormap(gray(64))
            axis square
            set(gca,'xtick',[],'ytick',[])

    % --------------------------------------------------------------------
    % waterwave
        case 'waterwave'
            load labapp_pix
            showim(waterwave_pix)
            axis on

    % --------------------------------------------------------------------
    % expshow
        case 'expshow'
            t = 0:1/64:2;
            h = .0001;
            a = 1.5+1.5*rand;
            y = a.^t;
            yp = (a.^(t+h) - a.^t)/h;
            plot(t,[y;yp])
            set(gca, ...
                'xlim',[-.5 2], ...
                'xaxislocation','origin', ...
                'ylim',[-1 4], ...
                'yaxislocation','origin', ...
                'fontsize',8)

    % --------------------------------------------------------------------
    % sudoku
        case 'sudoku'
            f('thumb');

    % --------------------------------------------------------------------
    % orbits
        case 'orbits'
            cla
            load labapp_pix
            P = orbits_init;
            S = orbits_traj;
            dotsize = [24 12 18 24 16]';
            color = [4 3 0; 2 0 2; 1 1 1; 0 0 3; 4 0 0]/4;
            s = 22/16;
            axis([-s s -s s -s/4 s/4])
            set(gca,'clipping','off')
            for i = 1:5
               line(P(i,1),P(i,2),P(i,3), ...
                   'color',color(i,:), ...
                   'marker','.', ...
                   'markersize',dotsize(i)+4);
               line(S(:,1,i),S(:,2,i),S(:,3,i), ...
                   'color',color(i,:), ...
                   'linewidth',2);
            end
    %}     
    % --------------------------------------------------------------------
    % golden_spiral
        case 'golden_spiral'
            f('thumb')

    %--------------------------------------------------------------------
    % lab1
        case 'lab1'
            showim(imread('lab_01.png'))
            axis square
            text(.5,.5,'lab1', ...
                'units','normalized', ...
                'horiz','center', ...
                'fontname','courier', ...
                'fontweight','bold', ...
                'fontsize',16)

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

    % --------------------------------------------------------------------
    % otherwise
        otherwise
    end
end