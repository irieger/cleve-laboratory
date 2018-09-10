function z = hex(y)
% hex(y) is an 8 bit = 2 hex digit string.
    u = y.u;
    [m,n] = size(u);
    z(m,n) = "";
    for k = 1:m
        for j = 1:n
            z(k,j) = dec2hex(u(k,j),2);
        end
    end
end
