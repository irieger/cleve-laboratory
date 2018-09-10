function z = binary(y)
% binary(y) is an size(y)-by-10-bit string displaying 
% the s, e, and f fields.
    u = y.u;
    [m,n] = size(u);
    z(m,n) = "";
    for k = 1:m
        for j = 1:n
            v = dec2bin(u(k,j),8);
            z(k,j) = [v(1) ' ' v(2:4) ' ' v(5:8)];
        end
    end
end