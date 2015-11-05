function [ g, dg, d2g ] = mteugpFwdLogistic( f )
%MTEUGPFWDBINARYCLASS Implementation of logistic sigmoid function for binary classification
%   Detailed explanation goes here
% 

g  = logisticSigmoid(f);
dg = g.*(1-g);

d2g = dg.*(1-2*g);

end




function g = logisticSigmoid(f)
g =  1./(1+exp(-f));
end



