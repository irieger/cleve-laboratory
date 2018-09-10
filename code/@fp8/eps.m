function z = eps(x)
   [~,e] = log2(abs(double(x)));
   z = fp8(pow2(1,e-5));
end
