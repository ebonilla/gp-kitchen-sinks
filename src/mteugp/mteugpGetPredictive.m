function [MeanF, VarF ] = mteugpGetPredictive( model, xstar )
%MTEUGPPREDICT Gets predictive distribution for all latent functions and all test points
% returns the mean and variances for all f* across all latent functions
% MeanF: Nstar x Q of all mean(f*)
% VarF = Nstar x Q of all var(f*)
% Edwin V. Bonilla (http://ebonilla.github.io/)

PhiStar  = feval(model.featFunc, xstar, model.Z, model.featParam);


MeanF = PhiStar*model.M;
VarF  = zeros(size(MeanF));

for q = 1 : model.Q
    VarF(:,q)  = diagProd(PhiStar*model.C(:,:,q),PhiStar');
end

end

