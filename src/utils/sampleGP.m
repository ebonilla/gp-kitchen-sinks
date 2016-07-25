function y = sampleGP(xstar, covfunc, loghyper, MIN_NOISE)
%  generates samples from the true GP

if (nargin == 3)
    MIN_NOISE = 1e-7;
end
n = size(xstar,1);
Ktilde  = feval(covfunc, loghyper, xstar) + MIN_NOISE*eye(n);
mu      = zeros(n,1);
y       = sampleGauss(mu, Ktilde, 1);

return;



