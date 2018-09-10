function farg = thumbnails3(f)
farg = [];
switch func2str(f)

% calculator
    case 'calculator'
        load labapp_pix
        if rand < .5
            f = calculator_pix1;
        else
            f = calculator_pix2;
        end
        [p,q,~] = size(f);
        n = max(p,q) + 40;
        x = zeros(n,n,'uint8') + uint8(255);
        x(fix((n-p)/2)+(1:p),fix((n-q)/2)+(1:q)) = f;
        showim(cat(3,x,x,x))
        
%--------------------------------------------------------------------
% roman_clock
    case 'roman_clock'
        ax = get(gca,'position');
        cla
        p = [ax(1)+.03 ax(2) .7*ax(3) .88*ax(4)];
        x = [p(1) p(1)+p(3) p(1)+p(3) p(1) p(1)];
        y = [p(2) p(2) p(2)+p(3) p(2)+p(3) p(2)];
        patch(x,y,[.9 .9 .9])
        c = fix(clock);
        for k = 4:6
            pos = [ax(1)+.25*ax(3) ax(2)+(7.2-k)/5*ax(4) .5*ax(3) .1*ax(4)];
            uicontrol('style','text', ...  
                'units','normal', ...
                'position',pos, ...
                'background','white', ...
                'string',char(roman(c(k))), ...
                'fontweight','bold', ...
                'horiz','center')
        end
               
%--------------------------------------------------------------------
% arrowhead
    case 'arrowhead'
        showim(imread('arrowhead_04.png'))
        
%--------------------------------------------------------------------
% c5
    case 'c5'
        ax = get(gca,'position');
        cla
        p = [ax(1)+.03 ax(2) .7*ax(3) .88*ax(4)];
        x = [p(1) p(1)+p(3) p(1)+p(3) p(1) p(1)];
        y = [p(2) p(2) p(2)+p(3) p(2)+p(3) p(2)];
        patch(x,y,[.9 .9 .9])
        pos = [ax(1)+.25*ax(3) ax(2)+.4*ax(4) .5*ax(3) .2*ax(4)];
        uicontrol('style','text', ...
            'units','normal', ...
            'position',pos, ...
            'background','white', ...
            'string','c^5', ...
            'fontsize',12, ...
            'fontweight','bold', ...
            'horiz','center')
        
%--------------------------------------------------------------------
% dragon
    case 'dragon'
        showim(imread('dragons_18_4.jpg'))
                
%--------------------------------------------------------------------
% play_match_the_color_game
    case 'play_match_the_color_game'
        showim(imread('match_color.png'))
        
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
