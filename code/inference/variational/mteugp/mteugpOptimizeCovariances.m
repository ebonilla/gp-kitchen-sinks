function [ model ] = mteugpOptimizeCovariances( model )
%MTEUGPOPTIMIZECOVARIANCES Summary of this function goes here
% update covariances using optimal mean
for q = 1 : model.Q
        model.C(:,:,q) = updateCovariance(model,q);
end

end


%% Cq = updateCovariance(model)
function Cq = updateCovariance(model, q)
N        = model.N;
sigma2y  = model.sigma2y;
Sigmainv = mteugpGetSigmaInv(sigma2y);
sigma2w  = model.sigma2w(q);
mq       = model.M(:,q);

H    = mteugpGetHessMq(model, mq, sigma2w, Sigmainv, N, q);
L    = getCholSafe(H);
Cq   = getInverseChol(L);
end
