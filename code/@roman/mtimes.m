function r = mtimes(p,q)
%MTIMES Times for Roman numerals.
    p = roman(p);
    q = roman(q);
    r = roman(p.n * q.n);
end % roman/mtimes
