function showim(X)
% showim(X) substitute for imshow.
    image(X)
    axis image
    set(gca,'xtick',[],'ytick',[])
end 