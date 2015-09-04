function [ g, dg ] = mteugpToyFwdModel( benchmark, f )
%MTEUGPTESTFWDFUNC Fwd models in toy experiments
%   Detailed explanation goes here
switch benchmark,
case 'lineardata',
    g  = f;
    dg = ones(size(f));
case 'poly3data',
    g  = f.^3 + f.^2 + f;
    dg = 3*f.^2 + 2*f + 1;
case 'expdata',
    g  = exp(f);
    dg = exp(f);
case 'sindata',
    g  = sin(f);
    dg = cos(f);
case 'tanhdata',
    g  = tanh(2*f);
    dg =  2 - 2*(tanh(2*f)).^2;
end

end

