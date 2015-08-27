function [ model ] = mteugpInit( model )
%MTEUGPINIT Summary of this function goes here
%   Detailed explanation goes here


% Initializing features
model.featParam = feval(model.initFeatFunc);
model.Phi       = feval(model.featFunc, model.X, model.featParam); 
model.D         = size(model.Phi,2); % actual number of features

% means, lineariz. and covariances
model.M            = randn(model.D,model.Q);
[model.A, model.B] = mteugpUpdateLinearization(model); % lineariz. parameters
model  = mteugpOptimizeCovariances( model );
fprintf('Initial Nelbo = %.2f\n', mteugpNelbo( model ) );

end

