function z = horzcat(varargin)
    z = fp8(varargin{1});
    for k = 2:nargin
        x = fp8(varargin{k});
        z.u = [z.u x.u];
    end
end