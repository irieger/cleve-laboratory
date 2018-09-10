function varargout = svd(A)
    [U,s,V] = svdtx(A);
    if nargout <= 1
        varargout{1} = s;
    else
        varargout{1} = fp8(U);
        varargout{2} = fp8(diag(s));
        varargout{3} = fp8(V);
    end
end % fp8/svd
