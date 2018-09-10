function [L,U,p] = lu(A)
    [L,U,p] = lutx(A);
    L = fp8(L);
    U = fp8(U);
    % p = flints
end % fp8/lu
