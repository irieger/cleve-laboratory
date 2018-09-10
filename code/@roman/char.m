function sea = char(r)
% char Generate Roman representation of Roman numeral.
%   c = CHAR(r) converts an @roman number or matrix to a
%   cell array of character strings.
    rn = r.n;
    [p,q] = size(rn);
    sea = cell(p,q);
    for k = 1:p
        for j = 1:q 
            if isempty(rn(k,j))
                c = '';           
            elseif ~isfinite(rn(k,j)) || rn(k,j) >= 4000
                c = 'MMMM';
            else
                % Integer part
                n = fix(abs(rn(k,j)));
                f = abs(rn(k,j)) - n;
                c = flint2rom(n);
                % Fractional part, thousandths.
                if f > 0
                   fc = flint2rom(round(1000*double(f)));
                   c = [c lower(fc)];
                end
                % Adjust sign
                if rn(k,j) < 0
                   c = ['-' c];
                end
            end
            sea{k,j} = c;
        end
    end
    
    function c = flint2rom(x) 
    D = {'','I','II','III','IV','V','VI','VII','VIII','IX'
         '','X','XX','XXX','XL','L','LX','LXX','LXXX','XC'
         '','C','CC','CCC','CD','D','DC','DCC','DCCC','CM'
         '','M','MM','MMM','  ',' ','  ','   ','    ','  '}; 
    n = max(fix(x),0);
    i = 1;
    c = '';
    while n > 0
       c = [D{i,rem(n,10)+1} c];
       n = fix(n/10);
       i = i + 1;
    end
end

end % roman/char