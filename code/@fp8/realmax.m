function rm = realmax(~)
    e = eps(fp8(1));
    rm = 2^3*(2-e);
end
