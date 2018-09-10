function z = double(y)
    u = y.u;
    [m,n] = size(u);
    z = zeros(m,n);
    for k = 1:m
        for j = 1:n
            z(k,j) = unpack8(u(k,j));
        end
    end
    
    % ------------------------------------------------------
    
    function x = unpack8(u)
    % x = unpack8(u) reverses u = pack8(x), x is a double
        sg = bitshift(u,-7);
        s = 1-2*double(sg);   % (-1)^sg
        u = bitxor(u,bitshift(sg,7));
        ebias = bitshift(u,-4);
        u = bitxor(u,bitshift(ebias,4));
        e = double(ebias)-3;
        if e == 4 && u ~= 0 
            f = NaN;
        elseif e == 4
            f = Inf;
        elseif e < -2
            % Denormal
            f = double(u)/16;
            e = -2;
        else
            % Normal
            f = 1+double(u)/16;
        end
        x = s*f*2^e;
    end
end
