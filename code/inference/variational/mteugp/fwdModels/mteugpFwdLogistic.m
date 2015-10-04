function [ g, dg ] = mteugpFwdLogistic( f )
%MTEUGPFWDBINARYCLASS Implementation of logistic sigmoid function for binary classification
%   Detailed explanation goes here
% 

g  = logisticSigmoid(f);
dg = g.*(1-g);


end




function g = logisticSigmoid(f)
g =  1./(1+exp(-f));
end



