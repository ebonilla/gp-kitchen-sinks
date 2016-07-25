function [g, dg]  = mteugpFwdSoftmax( f )
%MTEUGPFWDSOFTMAX Summary of this function goes here
%   Detailed explanation goes here
% [N, C] = size(f)
% [P Q] = size(dg) % only done fo a single n :-( 
% Edwin V. Bonilla (http://ebonilla.github.io/)

g = softmax(f);


if (nargout == 1)
    return;
end

% gradient/Jacobian only works for a single f_n vector
Q  = size(f,2); % assumes row vector
v  = bsxfun(@minus, eye(Q), g);
dg = bsxfun(@times,g',v);

end


function g = softmax(f)
a = max(f,[], 2);
g = exp(bsxfun(@minus, f, a)); % avoiding overflow
g = bsxfun(@rdivide, g, sum(g,2));
end

