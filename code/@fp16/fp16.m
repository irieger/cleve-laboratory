function y = fp16(x, flag)
% FP16.  Constructor for "fp16" 16-bit floating point,
% also known as "half precision".
% y = fp16(x) has one field, y.u, a uint16 packed with
% one sign bit, 5 exponent bits, and 10 fraction bits.
% See also: fp16/double
% Bug fixes 12/20/2017. See http://blogs.mathworks.com/cleve/2017/12/20.

    if nargin == 0
        y.u = uint16([]);
        y = class(y,'fp16');
    elseif nargin == 2 && or(strcmpi(flag, 'packed'), strcmpi(flag, 'native')) ...
                && isa(x, 'uint16')
        y.u = x;
        y = class(y, 'fp16');
    elseif isa(x,'fp16')
        y = x;
    else
        y.u = pack16(x);
        y = class(y,'fp16');
    end

    % ---------------------------------------------------------

    function u = pack16(x)
    % u = pack16(x) packs single or double x into uint16 u,
    % with bug fixes 12/20/2017.
        rndevn = @(s) round(s-(rem(s,2)==0.5));

        % Zeros init includes if x == 0 case
        u = zeros(size(x), 'uint16');

        % elseif isnan(x)
        u(isnan(x)) = uint16(Inf);
        % elseif isinf(x)
        u(isinf(x)) = uint16(31744);


        % else case
        idx = and(and(x ~= 0, ~isnan(x)), ~isinf(x));

        [f, e] = log2(abs(x(idx)));
        f = 2.*f-1;  % Remove hidden bit
        e = e-1;

        tmp = zeros(size(f), 'uint16');

        tmp(e > 15) = uint16(31744);
        tmp(e < -14) = uint16(rndevn(2.^(24+e(e < -14)).*(1+f(e < -14))));

        idx2 = ~or(e > 15, e < -14);
        e = e(idx2);
        t = uint16(rndevn(1024.*f(idx2)));

        e(t == 1024) = e(t == 1024) + 1;
        t(t == 1024) = uint16(0);

        tmp(idx2) = bitxor(t, bitshift(uint16(e + 15), 10));

        u(idx) = tmp;


        % Working on full matrix again
        s = uint16(1 - min(sign(x) + 1, 1));
        u = bitxor(u, bitshift(s, 15));
    end
end
