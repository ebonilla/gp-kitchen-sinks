function theta = mteugpWrapParameter(val, transform)
% transform: mapping from theta --> cal:
%  e.g. 'exp': val = exp(theta) --> theta = log(val)
% Edwin V. Bonilla (http://ebonilla.github.io/)

switch transform,
    case 'linear',
        theta = val;
    case 'exp',
        theta = log(val);
    case 'invexp',
        theta  = log(1./val);
    otherwise, 
        ME = MException('VerifyInput:InvalidInput', ...
             'Parameter transform is invalid');   
        throw(ME);
end

end



