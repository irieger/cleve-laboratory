function r = roman(a)
%ROMAN Roman numeral class constructor.
%   r = ROMAN(a) converts a number or a string to a Roman numeral.
%
% A roman object retains its double precision numeric value.
% The string representation of classic Roman numerals use just upper case
% letters.  Our "floating point" numerals use both upper and lower case.
%
%        I    1     i  1/1000 = .001
%        V    5     v  5/1000 = .002
%        X   10     x  10/1000 = .01
%        L   50     l  50/1000 = .05
%        C  100     c  100/1000 = .1
%        D  500     d  500/1000 = .5
%        M 1000     m  1000/1000 = 1
%
% The value of a string is the sum of the values of its letters,
% except a letter followed by one of higher value is subtracted.
%
% Values >= decimal 4000 are represented by 'MMMM'.
% Decimal 0 is represented by blanks.
%
% Blog: http://blogs.mathworks.com/cleve/2017/04/24.
% See also: calculator.

    if nargin == 0
       r.n = [];
       r = class(r,'roman');
       return
    elseif isa(a,'roman')
       r = a;
       return
    elseif isa(a,'char')
       a = roman_eval_string(a);
    end
    r.n = a;
    r = class(r,'roman');
    
    % ------------------------------------------------------
    function n = roman_eval_string(s)
    % Convert a string to the .n component of a Roman numeral.
        D = 'IVXLCDM';
        v = [1 5 10 50 100 500 1000];
        D = [D lower(D)];
        v = [v v/1000];
        n = 0;
        t = 0;
        for d = s
            k = find(d == D);
            if ~isempty(k)
                u = v(k);
                if t < u
                    n = n - t;
                else
                    n = n + t;
                end
                t = u;
            end
        end
        n = n + t;
        if ~isempty(s) && s(1)=='-'
            n = -n;
        end
    end
end % roman
