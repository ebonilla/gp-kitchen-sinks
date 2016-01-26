function [val, grad]  = mteugpUnwrapParameter(theta, transform)
% transform: mapping from theta --> s2:
%  e.g. 'exp': s2 = exp(theta) --> theta = log(s2)
% grad: ds2_dtheta 
switch transform,
    case 'linear',
        val  = theta;
        grad = ones(size(theta)); 
    case 'exp',
        val  = exp(theta);
        grad = val; 
    case 'invexp',
        val    = exp(-theta);
        grad   = - val;
    otherwise, 
        ME = MException('VerifyInput:InvalidInput', ...
             'Parameter transform is invalid');   
        throw(ME);
end

end



   