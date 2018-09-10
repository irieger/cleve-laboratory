function X = subsasgn(X,S,Y)
    Y = fp8(Y);
    X.u = subsasgn(X.u,S,Y.u);
end
