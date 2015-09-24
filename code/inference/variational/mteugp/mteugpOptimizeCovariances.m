function [ model ] = mteugpOptimizeCovariances( model )
%MTEUGPOPTIMIZECOVARIANCES Summary of this function goes here
% update covariances using optimal mean
for q = 1 : model.Q
        model.C(:,:,q) = updateCovariance(model,q);
end


% Moving the covariance chagnes the linearization parameters for the UGP
[model.A, model.B] = mteugpUpdateLinearization(model);

end


%% Cq = updateCovariance(model)
function Cq  = updateCovariance(model, q)
N            = model.N;
diagSigmainv = 1./ model.sigma2y;
sigma2w      = model.sigma2w(q);
mq           = model.M(:,q);

H    = mteugpGetHessMq(model, mq, sigma2w, diagSigmainv, N, q);
L    = getCholSafe(H);
Cq   = getInverseChol(L);
end



