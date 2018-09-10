function Z = subsref(X,S)
    if isequal(S.type,'.')
        Z = X;
    else
        Z = fp8(subsref(double(X),S));
    end
end
