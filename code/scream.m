function scream
% SCREAM  The Wilhelm scream, a classic film sound bite.
% For over 50 years, this was an in-group joke among
% Hollywood sound editors, who have used in over 130 films.
%    Google: "Wilhelm scream".
%    See: 
%      http://youtu.be/W0V-2WdubTs
%      http://www.youtube.com/watch?v=_PxALy22utc
%      http://en.wikipedia.org/wiki/Wilhelm_scream 
%      http://www.hollywoodlostandfound.net/wilhelm
%      http://ia802706.us.archive.org/20/items/WilhelmScreamSample

    load wilhelm
    figure('tag','wilfig', ...
           'units','normalized', ...
           'position',[.4 .4 .12 .15], ...
           'menubar','none', ...
           'toolbar','none', ...
           'numbertitle','off');
    showim(W.jpeg)
    play(W.player)
    pause(1.5)
end % scream