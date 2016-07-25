function  kl  = mteugpGetKL( model )
%MTEUGPGETKL Summary of this function goes here
%   kl divergence
% Edwin V. Bonilla (http://ebonilla.github.io/)

Q = model.Q;

kl = 0;
for q = 1 : Q
    kl = kl + getSingleKL(model, q);
end

end

%%  function kl = getSingleKL(model, q)
function kl = getSingleKL(model, q)
D = model.D; % dimensionality of new features (bases)
C      = model.C(:,:,q); % posterior covariance
m      = model.M(:,q) - model.priorMean(:,q); % posterior mean 
cholC  = getCholSafe(C);
sigma2w = model.sigma2w(q);
kl     = (1/sigma2w)*trace(C) ...
             + (1/sigma2w)*(m'*m) ... 
             - getLogDetChol(cholC) ...
             + D*log(sigma2w) ...
             -D;
kl     = 0.5*kl;         

end


 