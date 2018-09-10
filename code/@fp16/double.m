function z = double(y)
    z = unpack16(y.u);

    % ------------------------------------------------------

    function x = unpack16(u)
    % x = unpack16(u) reverses u = pack16(x), x is a double
        sg = bitshift(u, -15);
        s = 1 - 2 .* double(sg);   % (-1)^sg

        u = bitxor(u, bitshift(sg, 15));

        ebias = bitshift(u, -10);
        u = bitxor(u, bitshift(ebias, 10));
        e = double(ebias) - 15;

        f = zeros(size(u));

        % if e == 16 && u ~= 00
        f(and(e == 16, u ~= 0)) = NaN;
        % elseif e == 16
        f(and(e == 16, u == 0)) = Inf;
        % elseif e < -14
        subnormal_idx = e < -14;
        f(subnormal_idx) = double(u(subnormal_idx)) ./ 1024;
        e(subnormal_idx) = -14;
        % else
        normal_idx = ~(or(e == 16, subnormal_idx));
        f(normal_idx) = 1 + double(u(normal_idx)) ./ 1024;

        x = s .* f .* 2.^e;
    end
end
